--ECE395 GPU:
--GPU Core Intermediate Block
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
use WORK.sdram.all;

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
		  

package GPU_core_pckg is
	component GPU_core 
	  	generic(
	    FREQ                 :     natural := 50_000;  -- operating frequency in KHz
	    DATA_WIDTH           :     natural := 16;  -- host & SDRAM data width
	    HADDR_WIDTH          :     natural := 23  -- host-side address width
	    );
	  port(
    clk                  : in  std_logic;  -- master clock
	 rst					 :	in  std_logic;  -- reset for this entity
 	 rd1                  : out  std_logic;  -- initiate read operation
    wr1                  : out  std_logic;  -- initiate write operation
    opBegun1             : in std_logic;  -- read/write/self-refresh op begun (clocked)
    done1                : in std_logic;  -- read or write operation is done
	 rddone1					 : in std_logic;  -- read operation is done
	 rdPending1				 : in std_logic;	-- read operation is not done
    hAddr1               : out  std_logic_vector(HADDR_WIDTH-1 downto 0);  -- address to SDRAM
    hDIn1                : out  std_logic_vector(DATA_WIDTH-1 downto 0);  -- data to dualport to SDRAM
    hDOut1               : in std_logic_vector(DATA_WIDTH-1 downto 0);  -- data from dualport to SDRAM
	 start_read				 : in std_logic;
	 source_address		 : in std_logic_vector(HADDR_WIDTH-1 downto 0);
	 target_address		 : in std_logic_vector(HADDR_WIDTH-1 downto 0);
	 end_address			 : in std_logic_vector(HADDR_WIDTH-1 downto 0)
	);
	end component GPU_core;
end package GPU_core_pckg;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.fifo_cc_pckg.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity GPU_core is
  	generic(
    FREQ                 :     natural := 50_000;  -- operating frequency in KHz
    DATA_WIDTH           :     natural := 16;  -- host & SDRAM data width
    HADDR_WIDTH          :     natural := 23  -- host-side address width
    );
    Port ( 
    clk                  : in  std_logic;  -- master clock
	 rst					 	 :	in  std_logic;  -- reset for this entity
 	 rd1                  : out  std_logic;  -- initiate read operation
    wr1                  : out  std_logic;  -- initiate write operation
    opBegun1             : in std_logic;  -- read/write/self-refresh op begun (clocked)
    done1                : in std_logic;  -- read or write operation is done
	 rddone1					 : in std_logic;  -- read operation is done
	 rdPending1				 : in std_logic;	-- read operation is not done
    hAddr1               : out  std_logic_vector(HADDR_WIDTH-1 downto 0);  -- address to SDRAM
    hDIn1                : out  std_logic_vector(DATA_WIDTH-1 downto 0);  -- data to dualport to SDRAM
    hDOut1               : in std_logic_vector(DATA_WIDTH-1 downto 0);  -- data from dualport to SDRAM
	 start_read				 : in std_logic;
	 source_address		 : in std_logic_vector(HADDR_WIDTH-1 downto 0);
	 target_address		 : in std_logic_vector(HADDR_WIDTH-1 downto 0);
	 end_address			 : in std_logic_vector(HADDR_WIDTH-1 downto 0)
	 );
end GPU_core;

architecture Behavioral of GPU_core is

--------------------------------------------------------------------------------------------------------------
-- Signal Declarations
--------------------------------------------------------------------------------------------------------------

type state_type is (halt, read0, read1, read2, read3, write0, write1, write2);
signal current_state,next_state : state_type;

signal address : std_logic_vector(HADDR_WIDTH-1 downto 0);
signal output : std_logic_vector(15 downto 0);
--signal stop_address : std_logic_vector(HADDR_WIDTH-1 downto 0);

signal wr_q, rd_q, full_q, empty_q : std_logic;
signal datain_q, dataout_q : std_logic_vector(DATA_WIDTH-1 downto 0);
signal level_q : std_logic_vector(7 downto 0);

begin
--------------------------------------------------------------------------------------------------------------
-- Beginning of Submodules
-- All instances of submodules and signals associated with them
-- are declared within. Signals not directly associated with
-- submodules are declared elsewhere.
--  
--------------------------------------------------------------------------------------------------------------
u1 : fifo_cc
port map(
		clk=>clk,
		rst=>rst,
		rd=>rd_q,
		wr=>wr_q,
		data_in=>datain_q,
		data_out=>dataout_q,
		full=>full_q,
		empty=>empty_q,
		level=>level_q
);

--------------------------------------------------------------------------------------------------------------
-- End of Submodules
--------------------------------------------------------------------------------------------------------------
-- Begin GPUCore Module

-- Process that puts data into the FIFO whenever on rising edge of clk when rdDone1 is high
	getdata : process ( clk, rdDone1, hDOut1)
	begin
		if rising_edge(clk) then
			if rdDone1 = '1' then
				wr_q <= '1';
				datain_q <= hDOut1;
			else
				wr_q <= '0';
			end if;

--			if rdDone1 = '0' and done1 = '1' then
--				rd_q <= '1';
--				hDIn1 <= dataout_q;
--			else
--				rd_q <= '0';
--			end if;
		end if;
	end process;

-- Main state machine sequential process
	sync_proc : process(clk, rst)
	begin
		if (rst = '1') then
			current_state <= halt;
		elsif rising_edge(clk) then
			current_state <= next_state;
		end if;
	end process;

-- Main state machine combinatoric process
	comb_proc : process(current_state)
	begin
	case current_state is
		when halt =>

			rd1 <= '0';
			address <= source_address;
			hAddr1 <= "00000000000000000000000";

			if start_read = '1' then
				next_state <= read0;
			end if;

		when read0 =>

			rd1 <= '1';
			hAddr1 <= address;
						
			-- EXIT CONDITION
			if	end_address = address then
				next_state <= read3;
			elsif opBegun1 = '1' then
				next_state <= read1;
			end if;

		when read1 =>

			rd1 <= '1';
			address <= address + 1;
			hAddr1 <= address;

			-- EXIT CONDITION
			if end_address = address then
				next_state <= read3;
			elsif opBegun1 = '1' then
				next_state <= read2;
			end if;

		when read2 =>

			rd1 <= '1';
			address <= address + 1;
			hAddr1 <= address;

			-- EXIT CONDITION
			if end_address = address then
				next_state <= read3;
			elsif opBegun1 = '1' then
				next_state <= read1;
			end if;
						
		when read3 =>

			rd1 <= '0';
			address <= target_address;

			if rdPending1 = '0' and done1 = '0' then
				next_state <= write0;
			end if;

		when write0 =>

			wr1 <= '1';
			hAddr1 <= address;
			rd_q <= '1';
			hDIn1 <= dataout_q;

			if opBegun1 = '1' then
				next_state <= write1;
			end if;

		when write1 =>
			wr1 <= '1';
			hAddr1 <= address;
			address <= address + 1;
			rd_q <= '1';
			hDin1 <= dataout_q;

			if (empty_q = '0' and opBegun1 = '1') then
				next_state <= write2;
			elsif (empty_q = '1') then
				next_state <= halt;
			end if;

		when write2 =>
			wr1 <= '1';
			hAddr1 <= address;
			address <= address + 1;
			rd_q <= '1';
			hDin1 <= dataout_q;

			if (empty_q = '0' and opBegun1 = '1') then
				next_state <= write1;
			elsif (empty_q = '1') then
				next_state <= halt;
			end if;

	end case;
	end process;





end Behavioral;
