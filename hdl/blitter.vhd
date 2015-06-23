--ECE395 GPU:
--Blitter Subunit
--=====================================================
--Designed by:
--Zuofu Cheng
--James Cavanaugh
--Eric Sands
--
--of the University of Illinois at Urbana Champaign
--under the direction of Dr. Lippold Haken
--====================================================
--
--Heavily based off of HDL examples provided by XESS Corporation
--www.xess.com
--
--Based in part on Doug Hodson's work which in turn
--was based off of the XSOC from Gray Research LLC.
--										
--
--release under the GNU General Public License
--and kindly hosted by www.opencores.org

library IEEE, UNISIM;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use UNISIM.VComponents.all;
use WORK.common.all;
use WORK.xsasdram.all;
use WORK.sdram.all;
use WORK.vga_pckg.all;
use WORK.fifo_cc_pckg.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
		  

package Blitter_pckg is
	component Blitter 
	  	generic(
	    FREQ                :     natural := 50_000;  -- operating frequency in KHz
	    PIPE_EN    			:     boolean := true;  -- enable pipelined operations
       DATA_WIDTH          :     natural := 16;  -- host & SDRAM data width
	    ADDR_WIDTH          :     natural := 23  -- host-side address width
	  );
	  port(
     clk                   : in  std_logic;  -- master clock
     rst				    	   : in  std_logic;  -- reset for this entity
     rd                    : out std_logic;  -- initiate read operation
     wr                    : out std_logic;  -- initiate write operation
     opBegun               : in std_logic;   -- read/write/self-refresh op begun (clocked)
     earlyopBegun				: in std_logic;
	  done                  : in std_logic;   -- read or write operation is done
	  rddone					   : in std_logic;   -- read operation is done
	  rdPending				   : in std_logic;   -- read operation is not done
     Addr                  : out  std_logic_vector(ADDR_WIDTH-1 downto 0);  -- address to SDRAM
     DIn                   : out  std_logic_vector(DATA_WIDTH-1 downto 0);  -- data to dualport to SDRAM
     DOut                  : in std_logic_vector(DATA_WIDTH-1 downto 0);  -- data from dualport to SDRAM

	  blit_begin  		      : in std_logic;
	  source_address		   : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	  source_lines				: in std_logic_vector(15 downto 0);
	  
	  target_address		   : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	  line_size					: in std_logic_vector(11 downto 0);
	  alphaOp					: in std_logic;  -- if true then current operation is a blend alphaOp
	  front_buffer				: in std_logic;  -- if false, then we are writing to back buffer
	  blit_done					: out std_logic --line has been completely copied
	  );
	end component Blitter;
end package Blitter_pckg;

library IEEE, UNISIM;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use UNISIM.VComponents.all;
use WORK.common.all;
use WORK.xsasdram.all;
use WORK.sdram.all;
use WORK.vga_pckg.all;
use WORK.fifo_cc_pckg.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
		  
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Blitter is
  	  generic(
	    FREQ                :     natural := 50_000;  -- operating frequency in KHz
	    PIPE_EN    			:     boolean := true;  -- enable pipelined operations
       DATA_WIDTH          :     natural := 16;  -- host & SDRAM data width
	    ADDR_WIDTH          :     natural := 23  -- host-side address width
	  );
	  port(
     clk                   : in  std_logic;  -- master clock
     rst				    	   : in  std_logic;  -- reset for this entity
     rd                    : out  std_logic;  -- initiate read operation
     wr                    : out  std_logic;  -- initiate write operation
     opBegun               : in std_logic;  -- read/write/self-refresh op begun (clocked)
     earlyopBegun				: in std_logic;
	  done                  : in std_logic;  -- read or write operation is done
	  rddone					   : in std_logic;  -- read operation is done
	  rdPending				   : in std_logic;	-- read operation is not done
     Addr                  : out  std_logic_vector(ADDR_WIDTH-1 downto 0);  -- address to SDRAM
     DIn                   : out  std_logic_vector(DATA_WIDTH-1 downto 0);  -- data to dualport to SDRAM
     DOut                  : in std_logic_vector(DATA_WIDTH-1 downto 0);  -- data from dualport to SDRAM

	  blit_begin  		      : in std_logic;
	  source_address		   : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	  source_lines				: in std_logic_vector(15 downto 0);
	
	  target_address		   : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	  line_size					: in std_logic_vector(11 downto 0);
	  alphaOp					: in std_logic;  -- if true then current operation is a blend alphaOp
	  front_buffer				: in std_logic;  -- if false, then we are writing to back buffer
	  blit_done					: out std_logic --line has been completely copied
	  );
end Blitter;

architecture Behavioral of Blitter is

  -- states of the memory tester state machine
  type blitState is (
    STANDBY,
	 INIT1,                              -- init
    INIT2,
	 READ,                               -- load queue with line
    EMPTY_PIPE,                         -- empty read pipeline
	 READ_B,										 -- read contents of VRAM for blend
	 EMPTY_PIPE_B,								 -- empty read pipeline again
	 WRITE1,                             -- compare memory contents with pseudo-random data
    WRITE2,
	 STOP                                -- stop and indicate memory status
    );
  signal state_r, state_x : blitState;  -- state register and next state

  -- registers
  signal addr_r, addr_x : unsigned(addr'range);  -- address register
 
  signal s_addr_r, s_addr_x : std_logic_vector(ADDR_WIDTH - 1 downto 0); --per line start address
  signal t_addr_r, t_addr_x : std_logic_vector(ADDR_WIDTH - 1 downto 0); --per line target address
  
  signal current_line_r, current_line_x : std_logic_vector(15 downto 0);
  signal count_r, count_x	: std_logic_vector(11 downto 0);
  signal tot_pix_r, tot_pix_x : std_logic_vector(11 downto 0); 
  signal blend_data_r, blend_data_x : std_logic_vector(15 downto 0);

  -- internal signals
  signal rd_q : std_logic;
  signal wr_q : std_logic;
  signal empty_q : std_logic;
  signal reset_q : std_logic;
  signal out_q : std_logic_vector(15 downto 0);
  signal level_q: std_logic_vector(7 downto 0);

  signal rd_b : std_logic;
  signal wr_b : std_logic;
  signal empty_b : std_logic;
  signal reset_b : std_logic;
  signal out_b : std_logic_vector(15 downto 0);
  signal level_b: std_logic_vector(7 downto 0);

  signal q_write : std_logic; 
  signal b_write : std_logic;

begin

 	-- fifo buffer
	u1 : fifo_cc
	port map( 
		clk=>clk,
		rst=>reset_q,
		rd=>rd_q,
		wr=>wr_q,
		data_in=>dOut,
		data_out=>out_q,
		full=>open,
		empty=>empty_q,
		level=>level_q
	);
	
	u2 : fifo_cc
	port map( 
		clk=>clk,
		rst=>reset_q, --hack
		rd=>rd_b,
		wr=>wr_b,
		data_in=>dOut,
		data_out=>out_b,
		full=>open,
		empty=>empty_b,
		level=>level_b
	);

  -- connect internal registers to external busses 
  
  -- memory address bus driven by memory address register     
  addr <= std_logic_vector(addr_r);   -- linear memory addressing
  wr_q <= rdDone and q_write;  -- whenever something is causing rdDone to go high, we need to queue it
  wr_b <= rdDone and b_write;
  
  --if not doing an AlphaOp, we can directly copy pixel, wire vram input to blend result register
  dIn <=  blend_data_r when alphaOp = YES else out_q;	
  
   -- memory test controller state machine operations
  combinatorial : process(state_r, addr_r, current_line_r,
  								  s_addr_r, t_addr_r,
								  earlyOpbegun, rdPending,
								  source_address, target_address,
								  empty_q, source_lines, line_size, count_r,
								  alphaOp, level_q, level_b, tot_pix_r, blit_begin, front_buffer)	  -- *********** added by Eric
  begin

    -- default operations (do nothing unless explicitly stated in the following case statement)
    rd      <= NO;                      -- no memory write
    wr      <= NO;                      -- no memory read
    rd_q 	<= NO;
	 rd_b		<= NO;
	 reset_q <= NO;
    blit_done <= NO;
	 q_write <= NO;
	 b_write <= NO;

	 current_line_x <= current_line_r;
	 s_addr_x <= s_addr_r;
	 t_addr_x <= t_addr_r;
	 count_x <= count_r;
	 tot_pix_x <= tot_pix_r;
	 addr_x  <= addr_r;                  -- next address is the same as current address
    state_x <= state_r;
	 blend_data_x <= blend_data_r;       

    -- **** compute the next state and operations ****
    case state_r is

      ------------------------------------------------------
      -- initialize blitter
      ------------------------------------------------------
      when STANDBY =>								 	 -- goto this state at beginning of operation
			if (blit_begin = YES) then
				state_x <= INIT1;
			end if;
		
		when INIT1 =>			                      -- latch in blit parameters
		  if (front_buffer = YES) then
		  		t_addr_x <= target_address;
		  else
		  		t_addr_x <= target_address + x"009600";
		  end if;

		  s_addr_x <= source_address;
		  tot_pix_x <= line_size;
		  current_line_x <= x"0000";
	 	  count_x <= x"000";
		  reset_q  <= YES;
		  blit_done <= NO;
		  state_x <= INIT2;
			
		when INIT2 =>										  -- this state happens for every line
		  addr_x   <= unsigned(s_addr_r);
		  count_x <= x"000";
	  	  q_write <= YES;
		  state_x <= READ;

		when READ =>                                -- Read data in from the source address into the FIFO
        q_write <= YES;
		  rd <= YES;										  -- actual write to FIFO is straight through assignment
		  if (earlyOpBegun = YES) then 				  -- which is somewhere above
				addr_x <= addr_r + 1;                 -- increment address read next memory location
				count_x <= count_r + 1;
        end if;
		  if count_r = tot_pix_r then
            state_x <= EMPTY_PIPE;
        end if;

      when EMPTY_PIPE =>
		 q_write <= YES;
		 if (rdPending = NO) then
			  count_x <= x"000";	
        	  addr_x <= unsigned(t_addr_r);         -- set address to target	
			  if (alphaOp = NO) then 					 -- if not doing alpha operation then we can write the pixels
			  		state_x <= WRITE1;
			  else 
			  		state_x <= READ_B;					 -- otherwise we need to read the current contents of the VRAM
			  end if;
		  end if;

		when READ_B =>
		  b_write <= YES;
		  rd <= YES;										  -- read from VRAM into buffer FIFO_B
		  if (earlyOpBegun = YES) then				  
				addr_x <= addr_r + 1;
				count_x <= count_r + 1;
        end if;
		  if (count_r = tot_pix_r) then
		  	   state_x <= EMPTY_PIPE_B;
		  end if;

      when EMPTY_PIPE_B =>
		 b_write <= YES;
		 if (rdPending = NO) then
			  count_x <= x"000";	
        	  addr_x <= unsigned(t_addr_r);         -- set address to target	
		 	  rd_q <= YES;    
		     rd_b <= YES;
		 	  state_x <= WRITE1;
		
		  end if;

		when WRITE1 =>
		  count_x <= x"000";
		  rd_q <= YES;    
		  rd_b <= YES;
		  --perform blending here (synchronous)
		  if (out_q(15 downto 8) = x"E7") then
			  blend_data_x(15 downto 8) <= out_b(15 downto 8);
		  else 
			  blend_data_x(15 downto 8 )<= out_q(15 downto 8);
  		  end if;

		  if (out_q(7 downto 0) = x"E7") then
			  blend_data_x(7 downto 0) <= out_b(7 downto 0);
		  else 
			  blend_data_x(7 downto 0)<= out_q(7 downto 0);
  		  end if;

		  state_x <= WRITE2;
						
      when WRITE2 =>                                -- write to memory
        wr <= YES;							             -- with data from FIFO

		  if (earlyOpBegun = YES) then
		     rd_q <= YES;
			  rd_b <= YES;	  
	
			  --perform blending here (synchronous)
			  if (out_q(15 downto 8) = x"E7") then
				  blend_data_x(15 downto 8) <= out_b(15 downto 8);
			  else 
				  blend_data_x(15 downto 8 )<= out_q(15 downto 8);
	  		  end if;

			  if (out_q(7 downto 0) = x"E7") then
				  blend_data_x(7 downto 0) <= out_b(7 downto 0);
			  else 
				  blend_data_x(7 downto 0)<= out_q(7 downto 0);
	  		  end if;

			  if empty_q /= YES then					    -- if we still have more data to write to VRAM
           	 addr_x  <= addr_r + 1;                 -- increment address
				 count_x <= count_r + 1;
			  else
        		current_line_x <= current_line_r + 1;	 -- we're done with a whole line
			   state_x <= STOP;	
			  end if;
        end if;
      
		when others =>           							 -- stop and unreachable states                    
    	 	if (current_line_r = source_lines) then
				blit_done <= YES;				           	 -- Operation is complete, so we just sit here
			else													 -- all per line stuff neeeds to be reset here
				count_x <= x"000";
				s_addr_x <= s_addr_r + x"0000A0";	
				t_addr_x <= t_addr_r + x"0000A0";							
				reset_q <= YES;
				state_x <= INIT2;
			end if;
		end case;

  end process;


  -- update the registers of the memory tester controller       
  update : process(clk)
  begin
    if (clk'event and clk = '1') then
      if rst = YES then
        state_r <= STANDBY;
      else
        addr_r  <= addr_x;
        state_r <= state_x;
		  current_line_r <= current_line_x;
		  s_addr_r <= s_addr_x;
	 	  t_addr_r <= t_addr_x;
		  count_r <= count_x;
		  tot_pix_r <= tot_pix_x;
		  blend_data_r <= blend_data_x;       
		end if;
    end if;
  end process;

end Behavioral;
