--===========================================================================--
--
--  S Y N T H E Z I A B L E    CPU05   6805 comaptible CPU
--
--  This core adheres to the GNU public license  
--
-- File name      : cpu05.vhd
--
-- Purpose        : 6805 compatible CPU
--                  Differences to 6805
--                  64 K addressing range
--                  stack starts at $00FF and is 128 bytes deep
--                  
-- Dependencies   : ieee.Std_Logic_1164
--                  ieee.std_logic_unsigned
--
-- Author         : John E. Kent      
--
--
--=====================================================================
--
-- Revision History
--
--=====================================================================
--
-- 0.0   6 Sept 2002 - John Kent - design started
-- 0.1  30 May  2004 - John Kent - Initial release
--
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cpu05 is
	port (	
	 clk       : in  std_logic;
    rst       : in  std_logic;
    vma       : out std_logic;
    rw        : out std_logic;
    addr      : out std_logic_vector(15 downto 0);
    data_in   : in  std_logic_vector(7 downto 0);
	 data_out  : out std_logic_vector(7 downto 0);
	 irq_ext   : in  std_logic;
	 irq_timer : in  std_logic;
	 irq_uart  : in  std_logic );
end;

architecture cpu_arch of cpu05 is
	type state_type is (reset_state, reset1_state, reset2_state,
                       fetch_state, decode_state, exec_state, halt_state,
	                    brbit_state,
 							  branch_state, bsr_state, jsr_state, jsr1_state, jmp_state,
							  swi_state, stop_state,
							  rti_state, rti_cc_state, rti_ac_state, rti_ix_state, rti_pch_state, rti_pcl_state,
							  rts_state, rts_pch_state, rts_pcl_state,
							  wait_state, wait1_state, wait2_state, wait3_state, wait4_state,
							  int_state, int1_state, int2_state, int3_state, int4_state, int5_state, int6_state,
                       dir_state, ext_state, ix2_state, ix1_state, ix0_state,
						     write_state );
	type addr_type is (reset_addr, idle_addr, fetch_addr, read_addr, write_addr, push_addr, pull_addr, vect_hi_addr, vect_lo_addr );
	type data_type is (ac_data, ix_data, cc_data, md_data, pc_lo_data, pc_hi_data );
	type pc_type is (reset_pc, latch_pc, inc_pc, jmp_pc, bra_pc, pull_lo_pc, pull_hi_pc );
   type ea_type is (reset_ea, latch_ea, fetch_first_ea, fetch_next_ea, loadix_ea, addix_ea, addpc_ea );
   type op_type is (reset_op, latch_op, fetch_op );
   type ac_type is (reset_ac, latch_ac, load_ac, pull_ac );
	type ix_type is (reset_ix, latch_ix, load_ix, pull_ix );
	type sp_type is (reset_sp, latch_sp, load_sp, inc_sp, dec_sp );
   type cc_type is (reset_cc, latch_cc, load_cc, pull_cc );
	type md_type is (reset_md, latch_md, load_md, fetch_md );
	type iv_type is (latch_iv, rst_iv, swi_iv, irq_iv, tim_iv, uart_iv );
	type left_type  is (ac_left, ix_left, md_left );
	type right_type is (md_right, bset_right, bclr_right, zero_right, one_right );
   type alu_type   is (alu_add, alu_adc, alu_sub, alu_sbc,
                       alu_and, alu_ora, alu_eor,
                       alu_tst, alu_inc, alu_dec, alu_clr, alu_neg, alu_com,
						     alu_lsr, alu_lsl, alu_ror, alu_rol, alu_asr,
						     alu_sei, alu_cli, alu_sec, alu_clc,
							  alu_bset, alu_bclr, alu_btst,
						     alu_ld, alu_st, alu_nop );

  constant HFLAG : integer := 4;
  constant IFLAG : integer := 3;
  constant NFLAG : integer := 2;
  constant ZFLAG : integer := 1;
  constant CFLAG : integer := 0;

	--
	-- internal registers
	--
  	signal ac:          std_logic_vector(7 downto 0);	-- accumulator
	signal ix:          std_logic_vector(7 downto 0);  -- index register
	signal sp:          std_logic_vector(6 downto 0);  -- stack pointer
	signal cc:          std_logic_vector(4 downto 0);  -- condition codes from alu
	signal pc:	        std_logic_vector(15 downto 0); -- program counter for opcode access
	signal ea:          std_logic_vector(15 downto 0); -- effective addres for memory access
	signal op:          std_logic_vector(7 downto 0);  -- opcode register
	signal md:          std_logic_vector(7 downto 0);  -- memory data
	signal iv:          std_logic_vector(2 downto 0);  -- interrupt vector number
	signal state:       state_type;

	--
	-- unregistered signals
	-- (combinational logic)
	--
   signal alu_left:    std_logic_vector(8 downto 0);  -- alu left input (bit 8 for carry)
   signal alu_right:   std_logic_vector(8 downto 0);  -- alu right input
	signal alu_out:     std_logic_vector(8 downto 0);  -- alu result output (unlatched)
	signal cc_out:      std_logic_vector(4 downto 0);  -- alu condition code outout (unlatched)
	signal bset_data_out: std_logic_vector(7 downto 0);
	signal bclr_data_out: std_logic_vector(7 downto 0);
	signal next_state:  state_type;

   --
	-- Syncronous Register Controls
	--
	signal ac_ctrl:     ac_type;
	signal ix_ctrl:     ix_type;
	signal sp_ctrl:     sp_type;
	signal cc_ctrl:     cc_type;
   signal pc_ctrl:     pc_type;
   signal ea_ctrl:     ea_type; 
   signal op_ctrl:     op_type;
	signal md_ctrl:     md_type;
   signal iv_ctrl:     iv_type;

	--
	-- Asynchronous Multiplexer Controls
	--
	signal addr_ctrl:   addr_type;       -- address bus mutiplexer
	signal data_ctrl: data_type;   -- data output mutiplexer
   signal left_ctrl:   left_type;       -- Left ALU input
	signal right_ctrl:  right_type;     -- Right ALU input
   signal alu_ctrl:    alu_type;        -- ALU opeartion

   --
	-- bit set decoder table
	--
   component bset_rom is
     port (
       addr     : in  Std_Logic_Vector(2 downto 0);
	    data     : out Std_Logic_Vector(7 downto 0)
     );
   end component bset_rom;
   --
	-- bit clear decoder table
	--
   component bclr_rom is
     port (
       addr     : in  Std_Logic_Vector(2 downto 0);
	    data     : out Std_Logic_Vector(7 downto 0)
     );
   end component bclr_rom;

begin

   rom_set : bset_rom port map (
	  addr       => op(3 downto 1),
     data       => bset_data_out
	  );

   rom_clear : bclr_rom port map (
 	  addr       => op(3 downto 1),
     data       => bclr_data_out
	  );


----------------------------------
--
-- opcode register
--
----------------------------------

op_reg: process( clk, op_ctrl, data_in, op )
begin
  if clk'event and clk = '0' then
    case op_ctrl is
	 when reset_op =>
	   op <= "10011101";	-- reset with NOP
  	 when fetch_op =>
      op <= data_in;
	 when others =>
--	 when latch_op =>
	   op <= op;
    end case;
  end if;
end process;

-----------------------------------
--
-- accumulator
--
------------------------------------
ac_reg : process( clk, ac_ctrl, alu_out, ac, ix, data_in )
begin
   if clk'event and clk = '0' then
     case ac_ctrl is
     when reset_ac =>             -- released from reset
	    ac <= "00000000";
	  when load_ac =>               -- single or dual operation
  	    ac <= alu_out(7 downto 0);
	  when pull_ac =>                -- read acc / increment sp
		 ac <= data_in;
  	  when others =>               -- halt on undefine states
--	  when latch_ac =>             -- no operation on acc
	    ac <= ac;
     end case;						
  end if;
end process;

------------------------------------
--
-- condition code register
--
------------------------------------
cc_reg : process( clk, cc_ctrl, cc_out  )
begin
  if clk'event and clk = '0' then
     case cc_ctrl is
     when reset_cc =>             -- released from reset
	    cc <= "00000";
	  when load_cc =>               -- single or dual operation
  	    cc <= cc_out;
	  when pull_cc =>                -- read cc / increment sp
		 cc <= data_in(4 downto 0);
  	  when others =>               -- halt on undefine states
--	  when latch_cc =>             -- no operation on acc
	    cc <= cc;
     end case;						
  end if;
end process;

------------------------------------
--
-- index register
--
------------------------------------
ix_reg : process( clk, ix_ctrl, alu_out, ac, ix, data_in )
begin
  if clk'event and clk = '0' then
    case ix_ctrl is
     when reset_ix =>                 -- released from reset
	    ix <= "00000000";
	  when load_ix =>                   -- execute /  = alu out
	    ix <= alu_out(7 downto 0);
	  when pull_ix =>                    -- read ixreg / increment sp
		 ix <= data_in;
  	  when others =>
--	  when latch_ix =>                 -- no change in ix
	    ix <= ix;
    end case;						
  end if;
end process;


------------------------------------
--
-- stack pointer
--
------------------------------------
sp_reg : process( clk, sp_ctrl, sp )
begin
  if clk'event and clk = '0' then
    case sp_ctrl is
     when reset_sp =>                 -- released from reset
       sp <= "1111111";
	  when inc_sp =>                   -- pop registers
	    sp <= sp + 1;
     when dec_sp =>                   -- push registes
		 sp <= sp - 1;
  	  when others =>
--	  when latch_sp =>                 -- no change in sp
 	    sp <= sp;
    end case;						
  end if;
end process;

------------------------------------
--
-- program counter
--
------------------------------------
pc_reg : process( clk, pc_ctrl, pc, ea, data_in )
variable offset : std_logic_vector(15 downto 0);
begin
  if clk'event and clk = '0' then
    case pc_ctrl is
     when reset_pc =>                 -- released from reset
       pc <= "0000000000000000";
	  when inc_pc =>                   -- fetch next opcode
	    pc <= pc + 1;
     when jmp_pc =>                   -- load pc with effective address
		 pc <= ea;
     when bra_pc =>                   -- add effective address to pc
	    if ea(7) = '0' then				  -- sign extend offset
		   offset := "00000000" & ea(7 downto 0);
       else
		   offset := "11111111" & ea(7 downto 0);
		 end if;
		 pc <= pc + offset;
     when pull_lo_pc =>               -- load pc lo byte from memory
		 pc(15 downto 8) <= pc(15 downto 8);
		 pc(7 downto 0)  <= data_in;
     when pull_hi_pc =>               -- load pc hi byte from memory
		 pc(15 downto 8) <= data_in;
		 pc(7 downto 0)  <= pc(7 downto 0);
	  when others =>                   -- halt on undefine states
--	  when latch_pc =>                 -- no change in pc
 	    pc <= pc;
    end case;						
  end if;
end process;

------------------------------------
--
-- effective address register
--
------------------------------------
ea_reg: process( clk, ea_ctrl, ea, pc, ix, data_in )
variable offset : std_logic_vector(15 downto 0);
begin
  if clk'event and clk = '0' then
    case ea_ctrl is
     when reset_ea =>                     -- released from reset / fetch
       ea <= "0000000000000000";
	  when loadix_ea =>                    -- load ea with index register
	    ea <= "00000000" & ix;
	  when addpc_ea =>                     -- add pc to ea
	    if ea(7) = '0' then				  -- sign extend offset
		   offset := "00000000" & ea(7 downto 0);
       else
		   offset := "11111111" & ea(7 downto 0);
		 end if;
	    ea <= offset + pc;
     when addix_ea =>                     -- add index register to ea
		 ea <= ea + ("00000000" & ix );
     when fetch_first_ea =>               -- load ea lo byte from memory
		 ea(15 downto 8) <= "00000000";
		 ea(7 downto 0) <= data_in;
     when fetch_next_ea =>               -- load ea with second from memory
		 ea(15 downto 8) <= ea(7 downto 0);
		 ea(7 downto 0) <= data_in;
  	  when others =>                   -- halt on undefine states
--	  when latch_ea =>                 -- no change in ea
	    ea <= ea;
    end case;						
  end if;
end process;

----------------------------------
--
-- memory data register 
-- latch memory byte input
--
----------------------------------

md_reg: process( clk, md_ctrl, data_in, md )
begin
  if clk'event and clk = '0' then
    case md_ctrl is
	 when reset_md =>
	   md <= "00000000";
	 when latch_md =>
	   md <= md;
  	 when load_md =>                  -- latch alu output
      md <= alu_out(7 downto 0);
  	 when fetch_md =>
      md <= data_in;
	 when others =>
      null;
    end case;
  end if;
end process;

----------------------------------
--
-- interrupt vector register
--
----------------------------------

iv_reg: process( clk, iv_ctrl, iv )
begin
  if clk'event and clk = '0' then
    case iv_ctrl is
	 when rst_iv =>
	   iv <= "111"; -- $FFFE/$FFFF
	 when swi_iv =>
	   iv <= "110"; -- $FFFC/$FFFD
  	 when irq_iv =>
      iv <= "101"; -- $FFFA/$FFFB
	 when tim_iv =>
	   iv <= "100"; -- $FFF8/$FFF9
    when uart_iv =>
	   iv <= "011"; -- $FFFA/$FFFB
	 when others =>
--	 when latch_iv =>
	   iv <= iv;
    end case;
  end if;
end process;

----------------------------------
--
-- Address output multiplexer
-- Work out which register to apply to the address bus
-- Note that the multiplexer output is asyncronous
--
----------------------------------

mux_addr: process( clk, addr_ctrl, pc, ea, sp, iv )
begin
   case addr_ctrl is
     when reset_addr =>                 -- when held in reset
       addr <= "1111111111111111";
  		 vma  <= '0';
		 rw   <= '1';
	  when fetch_addr =>                 -- fetch opcode from pc
		 addr <= pc;
  		 vma  <= '1';
		 rw   <= '1';
	  when read_addr =>                  -- read from memory
	    addr <= ea;
		 vma  <= '1';
		 rw   <= '1';
	  when write_addr =>                 -- write to memory
	    addr <= ea;
		 vma  <= '1';
		 rw   <= '0';
	  when pull_addr =>                  -- read from stack
	    addr <= ("000000001" & sp);
		 vma  <= '1';
		 rw   <= '1';
	  when push_addr =>                  -- write to stack
	    addr <= ("000000001" & sp);
		 vma  <= '1';
		 rw   <= '0';
	  when vect_hi_addr =>               -- fetch interrupt vector hi
	    addr <= "111111111111" & iv & "0";
		 vma  <= '1';
		 rw   <= '1';
	  when vect_lo_addr =>               -- fetch interrupt vector lo
	    addr <= "111111111111" & iv & "1";
		 vma  <= '1';
		 rw   <= '1';
  	  when others =>                   -- undefined all high
       addr <= "1111111111111111";
  		 vma  <= '0';
		 rw   <= '1';
   end case;						
end process;

----------------------------------
--
-- Data Output Multiplexer
-- select data to be written to memory
-- note that the output is asynchronous
--
----------------------------------

mux_data: process( clk, data_ctrl, md, pc, cc, ac, ix )
variable data_out_v : std_logic_vector(7 downto 0);
begin
    case data_ctrl is
  	 when cc_data =>                   -- save condition codes
      data_out <= "000" & cc;
  	 when ac_data =>                   -- save accumulator
      data_out <= ac;
  	 when ix_data =>                   -- save index register
      data_out <= ix;
  	 when pc_lo_data =>                  -- save pc low byte
      data_out <= pc(7 downto 0);
  	 when pc_hi_data =>
      data_out <= pc(15 downto 8); -- save pc high byte
	 when others =>
--  	 when md_data =>                  -- alu latched output
      data_out <= md;
    end case;
end process;

----------------------------------
--
-- alu left mux
-- asynchronous input as register is already latched
--
----------------------------------

mux_left: process( clk, left_ctrl, ac, ix, md )
begin
    case left_ctrl is
	 when ac_left =>
	   alu_left <= "0" & ac; -- dual op argument
	 when ix_left =>
	   alu_left <= "0" & ix; -- dual op argument
	 when md_left =>
	   alu_left <= "0" & md;
	 when others =>
      alu_left <= "000000000";
    end case;
end process;


----------------------------------
--
-- alu right mux
-- asynchronous input as register is already latched
--
----------------------------------

mux_right: process( clk, right_ctrl, data_in, bset_data_out, bclr_data_out, md )
begin
    case right_ctrl is
	 when bset_right =>
	   alu_right <= "0" & bset_data_out;
	 when bclr_right =>
      alu_right <= "0" & bclr_data_out;
	 when zero_right =>
	   alu_right <= "000000000";
	 when one_right =>
	   alu_right <= "000000001";
	 when others =>
--	 when md_right =>
	   alu_right <= "0" & md; -- dual op argument
  end case;
end process;


----------------------------------
--
-- Arithmetic Logic Unit
--
----------------------------------

mux_alu: process( clk, alu_ctrl, cc, alu_left, alu_right )
variable alu_v   : std_logic_vector(8 downto 0);
variable low_v   : std_logic_vector(4 downto 0);
variable high_v  : std_logic_vector(4 downto 0);
begin

    case alu_ctrl is
  	 when alu_bset =>
	   alu_v := alu_left or alu_right; 	-- bit
  	 when alu_bclr =>
	   alu_v := alu_left and alu_right; 	-- bclr
  	 when alu_btst =>
	   alu_v := alu_left and alu_right; 	-- tst
  	 when alu_add =>
		low_v   := ("0" & alu_left(3 downto 0)) + ("0" & alu_right(3 downto 0));
		high_v  := ("0" & alu_left(7 downto 4)) + ("0" & alu_right(7 downto 4)) + low_v(4);
	   alu_v   := high_v(4 downto 0) & low_v(3 downto 0); 	-- add
  	 when alu_adc =>
		low_v   := ("0" & alu_left(3 downto 0)) + ("0" & alu_right(3 downto 0)) + ("0000" & cc(CFLAG));
		high_v  := ("0" & alu_left(7 downto 4)) + ("0" & alu_right(7 downto 4)) + low_v(4);
	   alu_v   := high_v(4 downto 0) & low_v(3 downto 0); 	-- adc
  	 when alu_sub =>
	   alu_v   := alu_left - alu_right; 	-- sub / cmp
  	 when alu_sbc =>
	   alu_v   := alu_left - alu_right - ("00000000" & cc(CFLAG)); 	-- sbc
  	 when alu_and =>
	   alu_v   := alu_left and alu_right; 	-- and/bit
  	 when alu_ora =>
	   alu_v   := alu_left or alu_right; 	-- or
  	 when alu_eor =>
	   alu_v   := alu_left xor alu_right; 	-- eor/xor
  	 when alu_lsl =>
	   alu_v   := alu_left(7 downto 0) & "0"; 	-- lsl
  	 when alu_lsr =>
	   alu_v   := alu_left(0) & "0" & alu_left(7 downto 1); 	-- lsr
  	 when alu_asr =>
	   alu_v   := alu_left(0) & alu_left(7) & alu_left(7 downto 1); 	-- asr
  	 when alu_rol =>
	   alu_v   := alu_left(7 downto 0) & cc(CFLAG); 	-- rol
  	 when alu_ror =>
	   alu_v   := alu_left(0) & cc(CFLAG) & alu_left(7 downto 1); 	-- ror
  	 when alu_inc =>
	   alu_v   := alu_left + "000000001"; 	-- inc
  	 when alu_dec =>
	   alu_v   := alu_left(8 downto 0) - "000000001"; -- dec
  	 when alu_neg =>
	   alu_v   := "000000000" - alu_left(8 downto 0); 	-- neg
  	 when alu_com =>
	   alu_v   := not alu_left(8 downto 0); 	-- com
  	 when alu_clr =>
	   alu_v  := "000000000"; 	   -- clr
	 when alu_ld =>
	   alu_v  := alu_right(8 downto 0);
	 when alu_st =>
	   alu_v  := alu_left(8 downto 0);
  	 when others =>
	   alu_v  := alu_left(8 downto 0); -- nop
    end case;

	 --
	 -- carry bit
	 --
    case alu_ctrl is
  	 when alu_add | alu_adc | alu_sub | alu_sbc | 
  	      alu_lsl | alu_lsr | alu_rol | alu_ror | alu_asr |
  	      alu_neg | alu_com =>
      cc_out(CFLAG) <= alu_v(8);
	 when alu_btst =>
      cc_out(CFLAG) <= not( alu_v(7) or alu_v(6) or alu_v(5) or alu_v(4) or
	                   alu_v(3) or alu_v(2) or alu_v(1) or alu_v(0) );
  	 when alu_sec =>
      cc_out(CFLAG) <= '1';
  	 when alu_clc =>
      cc_out(CFLAG) <= '0';
  	 when others =>
      cc_out(CFLAG) <= cc(CFLAG);
    end case;

	 --
	 -- Zero flag
	 --
    case alu_ctrl is
  	 when alu_add | alu_adc | alu_sub | alu_sbc |
  	      alu_and | alu_ora | alu_eor |
  	      alu_lsl | alu_lsr | alu_rol | alu_ror | alu_asr |
  	      alu_inc | alu_dec | alu_neg | alu_com | alu_clr |
		   alu_ld  | alu_st =>
      cc_out(ZFLAG) <= not( alu_v(7) or alu_v(6) or alu_v(5) or alu_v(4) or
	                         alu_v(3) or alu_v(2) or alu_v(1) or alu_v(0) );
  	 when others =>
      cc_out(ZFLAG) <= cc(ZFLAG);
    end case;

    --
	 -- negative flag
	 --
    case alu_ctrl is
  	 when alu_add | alu_adc | alu_sub | alu_sbc |
	      alu_and | alu_ora | alu_eor |
  	      alu_lsl | alu_lsr | alu_rol | alu_ror | alu_asr |
  	      alu_inc | alu_dec | alu_neg | alu_com | alu_clr |
			alu_ld  | alu_st =>
      cc_out(NFLAG) <= alu_v(7);
  	 when others =>
      cc_out(NFLAG) <= cc(NFLAG);
    end case;

    --
	 -- Interrupt mask flag
    --
    case alu_ctrl is
  	 when alu_sei =>
		cc_out(IFLAG) <= '1';               -- set interrupt mask
  	 when alu_cli =>
		cc_out(IFLAG) <= '0';               -- clear interrupt mask
  	 when others =>
		cc_out(IFLAG) <= cc(IFLAG);             -- interrupt mask
    end case;

    --
    -- Half Carry flag
	 --
    case alu_ctrl is
  	 when alu_add | alu_adc =>
		cc_out(HFLAG) <= low_v(4);
  	 when others =>
		cc_out(HFLAG) <= cc(HFLAG);
    end case;

	 alu_out <= alu_v;

end process;


------------------------------------
--
-- state sequencer
--
------------------------------------

sequencer : process( state, data_in, 
                     ac, cc, ix, sp, ea, md, pc, op,
                     irq_ext, irq_timer, irq_uart )
begin
		  case state is
--
-- RESET:
-- Here if processor held in reset
-- On release of reset go to RESET1
--
          when reset_state =>        -- release from reset
	         ac_ctrl    <= reset_ac;
	         cc_ctrl    <= reset_cc;
	         ix_ctrl    <= reset_ix;
	         sp_ctrl    <= reset_sp;
            pc_ctrl    <= reset_pc;
            op_ctrl    <= reset_op;
            ea_ctrl    <= reset_ea; 
	         md_ctrl    <= reset_md;
				iv_ctrl    <= rst_iv;
            left_ctrl  <= ac_left;        -- Left ALU input
	         right_ctrl <= md_right;       -- Right ALU input
            alu_ctrl   <= alu_nop;        -- ALU opeartion
	         addr_ctrl  <= reset_addr;     -- address bus mutiplexer
	         data_ctrl  <= md_data;        -- data output mutiplexer
			   next_state <= reset1_state;
--
-- RESET1:
-- address bus = reset vector hi
-- Load PC high with high byte
-- go to RESET2
--
          when reset1_state =>        -- fetch hi reset vector
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
				 pc_ctrl    <= pull_hi_pc;
             op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= vect_hi_addr;
	          data_ctrl  <= md_data;       -- data output mutiplexer
			    next_state <= reset2_state;
--
-- RESET2:
-- address bus = reset vector lo
-- Load PC low with low byte
-- go to FETCH
-- 
          when reset2_state =>        -- fetch low reset vector
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
				 pc_ctrl    <= pull_lo_pc;
             op_ctrl    <= latch_op;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= vect_lo_addr;
	          data_ctrl  <= md_data;       -- data output mutiplexer
			    next_state <= fetch_state;
--
-- FETCH:
-- fetch opcode,
-- advance the pc,
-- clear the effective address (ea) register
-- goto DECODE
--
          when fetch_state =>         -- fetch instruction
             case op(7 downto 4) is
--				 when "0000" =>				-- BRSET/ BRCLR
--				   null;
--				 when "0001" =>				-- BSET/ BCLR
--				   null;
--				 when "0010" =>				-- BR conditional
--				   null;
--				 when "0011" =>				--	single op direct
--				   null;
				 when "0100" =>            -- single op accum
  	            ac_ctrl    <= load_ac;
					cc_ctrl    <= load_cc;
	            ix_ctrl    <= latch_ix;
	            sp_ctrl    <= latch_sp;
					left_ctrl  <= ac_left;
				   case op( 3 downto 0 ) is
				   when "0000" =>            -- neg
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_neg;
				   when "0011" =>            -- com
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_com;
				   when "0100" =>            -- lsr
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_lsr;
				   when "0110" =>            -- ror
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_ror;
				   when "0111" =>            -- asr
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_asr;
				   when "1000" =>            -- lsl
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_lsl;
				   when "1001" =>            -- rol
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_rol;
				   when "1010" =>            -- dec
					  right_ctrl <= one_right;
					  alu_ctrl   <= alu_dec;
				   when "1011" =>            -- undef
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
				   when "1100" =>            -- inc
					  right_ctrl <= one_right;
					  alu_ctrl   <= alu_inc;
				   when "1101" =>            -- tst
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_tst;
				   when "1110" =>            -- undef
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
				   when "1111" =>            -- clr
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_clr;
					when others =>
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
					end case;

				 when "0101" =>            -- single op ix reg
  	            ac_ctrl    <= latch_ac;
					cc_ctrl    <= load_cc;
	            ix_ctrl    <= load_ix;
	            sp_ctrl    <= latch_sp;
					left_ctrl  <= ix_left;
				   case op( 3 downto 0 ) is
				   when "0000" =>            -- neg
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_neg;
				   when "0011" =>            -- com
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_com;
				   when "0100" =>            -- lsr
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_lsr;
				   when "0110" =>            -- ror
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_ror;
				   when "0111" =>            -- asr
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_asr;
				   when "1000" =>            -- lsl
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_lsl;
				   when "1001" =>            -- rol
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_rol;
				   when "1010" =>            -- dec
					  right_ctrl <= one_right;
					  alu_ctrl   <= alu_dec;
				   when "1011" =>            -- undef
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
				   when "1100" =>            -- inc
					  right_ctrl <= one_right;
					  alu_ctrl   <= alu_inc;
				   when "1101" =>            -- tst
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_tst;
				   when "1110" =>            -- undef
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
				   when "1111" =>            -- clr
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_clr;
					when others =>
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
					end case;
--           when "0110" =>            -- single op IX1
--             null;
--           when "0111" =>            -- single op IX0
--             null;
--           when "1000" =>            -- inherent stack operators
--             null;
				 when "1001" =>            -- inherent operators
				   case op( 3 downto 0 ) is
--				   when "0000" =>            -- undef
--					  null;
--     		   when "0001" =>            -- undef
--					  null;
-- 				when "0010" =>            -- undef
--					  null;
--				   when "0011" =>            -- undef
--					  null;
--				   when "0100" =>            -- undef
--					  null;
--				   when "0101" =>            -- undef
--					  null;
--				   when "0110" =>            -- undef
--					  null;
				   when "0111" =>            -- tax
                 ac_ctrl    <= latch_ac;
					  cc_ctrl    <= latch_cc;
                 ix_ctrl    <= load_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= bclr_right;
					  alu_ctrl   <= alu_st;

				   when "1000" =>            -- clc
                 ac_ctrl    <= latch_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= bclr_right;
					  alu_ctrl   <= alu_clc;

				   when "1001" =>            -- sec
                 ac_ctrl    <= latch_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= bclr_right;
					  alu_ctrl   <= alu_sec;

				   when "1010" =>            -- cli
                 ac_ctrl    <= latch_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= bclr_right;
					  alu_ctrl   <= alu_cli;

				   when "1011" =>            -- sei
                 ac_ctrl    <= latch_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= bclr_right;
					  alu_ctrl   <= alu_sei;

				   when "1100" =>            -- rsp
                 ac_ctrl    <= latch_ac;
					  cc_ctrl    <= latch_cc;
                 ix_ctrl    <= latch_ix;
					  sp_ctrl    <= reset_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= bclr_right;
					  alu_ctrl   <= alu_nop;

--				   when "1101" =>            -- nop
--					  null;
--				   when "1110" =>            -- undef
--					  null;
				   when "1111" =>            -- txa
                 ac_ctrl    <= load_ac;
					  cc_ctrl    <= latch_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ix_left;
					  right_ctrl <= bclr_right;
					  alu_ctrl   <= alu_st;

					when others =>
                 ac_ctrl    <= latch_ac;
					  cc_ctrl    <= latch_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ix_left;
					  right_ctrl <= bclr_right;
					  alu_ctrl   <= alu_nop;
					end case;
             --
			    -- dual operand addressing modes
			    --
				 when "1010" |            -- dual op imm
				      "1011" |            -- dual op dir
				      "1100" |            -- dual op ext
				      "1101" |            -- dual op ix2
				      "1110" |            -- dual op ix1
				      "1111" =>           -- dual op ix0
				   case op( 3 downto 0 ) is
				   when "0000" =>            -- sub
                 ac_ctrl    <= load_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= md_right;
					  alu_ctrl   <= alu_sub;
 				   when "0001" =>            -- cmp
                 ac_ctrl    <= latch_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= md_right;
					  alu_ctrl   <= alu_sub;
 				   when "0010" =>            -- sbc
                 ac_ctrl    <= load_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= md_right;
					  alu_ctrl   <= alu_sbc;
				   when "0011" =>            -- cpx
                 ac_ctrl    <= latch_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ix_left;
					  right_ctrl <= md_right;
					  alu_ctrl   <= alu_sub;
				   when "0100" =>            -- and
                 ac_ctrl    <= load_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= md_right;
					  alu_ctrl   <= alu_and;
				   when "0101" =>            -- bit
                 ac_ctrl    <= latch_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= md_right;
					  alu_ctrl   <= alu_and;
				   when "0110" =>            -- lda
                 ac_ctrl    <= load_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= md_right;
					  alu_ctrl   <= alu_ld;
				   when "0111" =>            -- sta
                 ac_ctrl    <= latch_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= md_right;
					  alu_ctrl   <= alu_st;
				   when "1000" =>            -- eor
                 ac_ctrl    <= load_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= md_right;
					  alu_ctrl   <= alu_eor;
				   when "1001" =>            -- adc
                 ac_ctrl    <= load_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= md_right;
					  alu_ctrl   <= alu_adc;
				   when "1010" =>            -- ora
                 ac_ctrl    <= load_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= md_right;
					  alu_ctrl   <= alu_ora;
				   when "1011" =>            -- add
                 ac_ctrl    <= load_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= md_right;
					  alu_ctrl   <= alu_add;
--				   when "1100" =>            -- jmp
--					  null;
--				   when "1101" =>            -- jsr
--					  null;
				   when "1110" =>            -- ldx
                 ac_ctrl    <= latch_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= load_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ix_left;
					  right_ctrl <= md_right;
					  alu_ctrl   <= alu_ld;
				   when "1111" =>            -- stx
                 ac_ctrl    <= latch_ac;
					  cc_ctrl    <= load_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ix_left;
					  right_ctrl <= md_right;
					  alu_ctrl   <= alu_st;
					when others =>
                 ac_ctrl    <= latch_ac;
					  cc_ctrl    <= latch_cc;
                 ix_ctrl    <= latch_ix;
	              sp_ctrl    <= latch_sp;
					  left_ctrl  <= ac_left;
					  right_ctrl <= md_right;
					  alu_ctrl   <= alu_nop;
					end case;
				 when others =>
               ac_ctrl    <= latch_ac;
					cc_ctrl    <= latch_cc;
               ix_ctrl    <= latch_ix;
	            sp_ctrl    <= latch_sp;
					left_ctrl  <= ac_left;
					right_ctrl <= md_right;
					alu_ctrl   <= alu_nop;
				 end case;

             ea_ctrl    <= latch_ea; 
             md_ctrl    <= latch_md;
				 pc_ctrl    <= inc_pc;
             op_ctrl    <= fetch_op;
				 addr_ctrl  <= fetch_addr;
	          data_ctrl  <= md_data;       -- data output mutiplexer
             if irq_ext = '1' and cc(IFLAG) = '0' then
				   iv_ctrl    <= irq_iv;
					next_state <= int_state;
				 elsif irq_timer = '1' and cc(IFLAG) = '0' then
				   iv_ctrl    <= tim_iv;
					next_state <= int_state;
				 elsif irq_uart = '1' and cc(IFLAG) = '0' then
				   iv_ctrl    <= uart_iv;
					next_state <= int_state;
				 else
	            iv_ctrl    <= latch_iv;
			      next_state <= decode_state;
				 end if;
--
-- DECODE:
-- decode the new opcode, 
-- fetch the next byte into the low byte of the ea ,
-- work out if you need to advance the pc, (two or three byte op)
-- work out the next state based on the addressing mode.
-- evaluate conditional branch execution
--
          when decode_state =>             -- decode instruction / fetch next byte
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
             ea_ctrl    <= fetch_first_ea; 
	          md_ctrl    <= fetch_md;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= fetch_addr;
	          data_ctrl  <= md_data;       -- data output mutiplexer
	   		 case op(7 downto 4) is -- addressing modes
				 --
				 -- branch on bit set / clear
				 --
	 	    	 when "0000" =>
 				   pc_ctrl    <= inc_pc;     -- advance the pc
				   next_state <= dir_state;
				 --
				 -- bit set / clear direct page
				 --
				 when "0001" =>
 				   pc_ctrl    <= inc_pc;     -- advance the pc
				   next_state <= dir_state;
				 --
				 -- branch on condition codes
             --   if condtion = true
             --       go to "branch" state
             --   if conition = false
             --       go to "fetch" state
				 --
				 when "0010" =>
 				   pc_ctrl    <= inc_pc;     -- advance the pc
				   case op(3 downto 0) is
					when "0000" => -- bra
					  next_state <= branch_state;
					when "0001" => -- brn
					  next_state <= fetch_state;
					when "0010" => -- bhi
					  if cc(CFLAG) = '0' and cc(ZFLAG) = '0' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
					when "0011" => -- bls
					  if cc(CFLAG) = '1' or cc(ZFLAG) = '1' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
					when "0100" => -- bcc
					  if cc(CFLAG) = '0' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
					when "0101" => -- bcs
					  if cc(CFLAG) = '1' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
					when "0110" => -- bne
					  if cc(ZFLAG) = '0' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
					when "0111" => -- beq
					  if cc(ZFLAG) = '1' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
					when "1000" => -- bhcc
					  if cc(HFLAG) = '0' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
					when "1001" => -- bhcs
					  if cc(HFLAG) = '1' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
					when "1010" => -- bpl
					  if cc(NFLAG) = '0' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
					when "1011" => -- bmi
					  if cc(NFLAG) = '1' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
					when "1100" => -- bmc
					  if cc(IFLAG) = '0' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
					when "1101" => -- bms
					  if cc(IFLAG) = '1' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
					when "1110" => -- bil
					  if irq_ext = '0' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
					when "1111" => -- bih
					  if irq_ext = '1' then
					    next_state <= branch_state;
					  else
					    next_state <= fetch_state;
					  end if;
					when others =>
					  null;
					end case; -- end of conditional branch decode
				 --
				 -- Single Operand direct addressing
				 --
				 when "0011" =>
 				   pc_ctrl    <= inc_pc;     -- advance the pc (2 byte instruction)
				   next_state <= dir_state;
				 --
				 -- Single Operand accumulator
				 --
				 when "0100" =>
 				   pc_ctrl    <= latch_pc;
				   next_state <= fetch_state;
				 --
				 -- Single Operand index register
				 --
				 when "0101" =>
 				   pc_ctrl    <= latch_pc;
				   next_state <= fetch_state;
				 --
				 -- Single Operand memory 8 bit indexed
				 --
				 when "0110" =>
 				   pc_ctrl    <= inc_pc;     -- advance the pc (2 byte instruction)
				   next_state <= ix1_state;
				 --
				 -- Single Operand memory 0 bit indexed
				 --
				 when "0111" =>
 				   pc_ctrl    <= latch_pc;     -- hold the pc (1 byte instruction)
				   next_state <= ix0_state;
             --
				 -- stack and interrupt operators
				 --
  				 when "1000" =>
 				   pc_ctrl    <= latch_pc;
				   case op(3 downto 0) is
					when "0000" =>
					  next_state <= rti_state;
					when "0001" =>
					  next_state <= rts_state;
               when "0011" =>
					  next_state <= swi_state;
 				   when "1110" =>
					  next_state <= stop_state;
					when "1111" =>
					  next_state <= wait_state;
					when others =>
					  next_state <= fetch_state;
					end case; -- end of stack decode
				 --
				 -- Inherent operators
				 --
				 when "1001" =>
 				   pc_ctrl    <= latch_pc;
					next_state <= fetch_state;
				 --
				 -- dual operand immediate addressing
				 --
	          when "1010" =>
 				   pc_ctrl   <= inc_pc;     -- advance the pc (2 byte instruction)
				   case op(3 downto 0) is
					when "1101" => -- bsr
					  next_state <= bsr_state;
					when others =>
					  next_state <= fetch_state;
					end case;
				 --
				 -- dual operand direct addressing
				 --
				 when "1011" =>
 				   pc_ctrl    <= inc_pc;     -- advance the pc (2 byte instruction)
					next_state <= dir_state;
				 --
				 -- dual operand extended addressing
				 --
			    when "1100" =>
 				   pc_ctrl    <= inc_pc;     -- advance the pc (3 byte instruction)
				   next_state <= ext_state;
				 --
				 -- dual operand 16 bit indexed addressing
				 --
				 when "1101" =>
 				   pc_ctrl    <= inc_pc;     -- advance the pc (3 byte instruction)
					next_state <= ix2_state;
				 --
				 -- dual operand 8 bit indexed addressing
				 --
			    when "1110" =>
 				   pc_ctrl    <= inc_pc;     -- advance the pc (3 byte instruction)
					next_state <= ix1_state;
				 --
				 -- dual operand direct page indexed addressing
				 --
				 when "1111" =>
 				   pc_ctrl    <= latch_pc;
					next_state <= ix0_state;
             --
				 -- catch undefined states
				 --
				 when others =>
 				   pc_ctrl    <= latch_pc;
				   next_state <= fetch_state;
				 end case; 
				 -- end of instruction decode state
			  --
			  -- perform addressing state sequence
			  --
			  when ext_state => -- fetch second address byte
  	          ac_ctrl    <= latch_ac;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
	          cc_ctrl    <= latch_cc;
 				 pc_ctrl    <= inc_pc;
             ea_ctrl    <= fetch_next_ea; 
             op_ctrl    <= latch_op;
	          md_ctrl    <= latch_md;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= fetch_addr;     -- read effective address
	          data_ctrl  <= pc_lo_data;       -- read memory data
			    next_state <= dir_state;

			  when ix2_state => -- fetch second index offest byte
  	          ac_ctrl    <= latch_ac;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
	          cc_ctrl    <= latch_cc;
 				 pc_ctrl    <= inc_pc;
             ea_ctrl    <= fetch_next_ea; 
             op_ctrl    <= latch_op;
	          md_ctrl    <= fetch_md;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= fetch_addr;
	          data_ctrl  <= pc_lo_data;
			    next_state <= ix1_state;

			  when ix1_state => -- add ixreg to effective address
  	          ac_ctrl    <= latch_ac;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
	          cc_ctrl    <= latch_cc;
 				 pc_ctrl    <= latch_pc;
             ea_ctrl    <= addix_ea; 
             op_ctrl    <= latch_op;
	          md_ctrl    <= latch_md;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= idle_addr;
	          data_ctrl  <= pc_lo_data;
			    next_state <= dir_state;

			  when ix0_state => -- load effective address with ixreg
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
             ea_ctrl    <= loadix_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= idle_addr;
	          data_ctrl  <= pc_lo_data;
			    next_state <= dir_state;

			  when dir_state => -- read memory cycle
  	          ac_ctrl    <= latch_ac;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
	          cc_ctrl    <= latch_cc;
             ea_ctrl    <= latch_ea; 
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
	          data_ctrl  <= pc_lo_data;
				 case op(7 downto 4) is
				 when "0000" |  -- BRSET / BRCLR
				      "0001" |  -- BSET / BCLR
				      "0011" |  -- single op DIR
				      "0110" |  -- single op IX1
						"0111" => -- single op IX0
	            md_ctrl    <= fetch_md;
               left_ctrl  <= ac_left;       -- Left ALU input
	            right_ctrl <= md_right;      -- Right ALU input
               alu_ctrl   <= alu_nop;       -- ALU opeartion
				   addr_ctrl  <= read_addr;     -- read effective address
			      next_state <= exec_state;
				 when "1011" |     -- dual op direct
				      "1100" |     -- dual op extended
				      "1101" |     -- dual op ix2
				      "1110" |     -- dual op ix1
				      "1111" =>    -- dual op ix0
				   case op(3 downto 0) is
					when "0111" =>   -- sta
	              md_ctrl    <= load_md;
                 left_ctrl  <= ac_left;       -- Left ALU input
	              right_ctrl <= md_right;      -- Right ALU input
                 alu_ctrl   <= alu_st;        -- ALU opeartion
				     addr_ctrl  <= idle_addr;     -- read effective address
					  next_state <= write_state;
               when "1100" =>  -- jmp
	              md_ctrl    <= latch_md;
                 left_ctrl  <= ac_left;       -- Left ALU input
	              right_ctrl <= md_right;      -- Right ALU input
                 alu_ctrl   <= alu_nop;       -- ALU opeartion
				     addr_ctrl  <= idle_addr;     -- idle address
					  next_state <= jmp_state;
               when "1101" =>  -- jsr
	              md_ctrl    <= latch_md;
                 left_ctrl  <= ac_left;       -- Left ALU input
	              right_ctrl <= md_right;      -- Right ALU input
                 alu_ctrl   <= alu_nop;       -- ALU opeartion
				     addr_ctrl  <= idle_addr;     -- idle address
					  next_state <= jsr_state;
					when "1111" =>  -- stx
	              md_ctrl    <= load_md;
                 left_ctrl  <= ix_left;       -- Left ALU input
	              right_ctrl <= md_right;      -- Right ALU input
                 alu_ctrl   <= alu_st;       -- ALU opeartion
				     addr_ctrl  <= idle_addr;     -- read effective address
					  next_state <= write_state;
					when others =>
	              md_ctrl    <= fetch_md;
                 left_ctrl  <= ac_left;       -- Left ALU input
	              right_ctrl <= md_right;      -- Right ALU input
                 alu_ctrl   <= alu_nop;       -- ALU opeartion
				     addr_ctrl  <= read_addr;     -- read effective address
					  next_state <= fetch_state;
					end case;
			    when others =>
	            md_ctrl    <= fetch_md;
               left_ctrl  <= ac_left;       -- Left ALU input
	            right_ctrl <= md_right;      -- Right ALU input
               alu_ctrl   <= alu_nop;       -- ALU opeartion
				   addr_ctrl  <= read_addr;     -- read effective address
				   next_state <= fetch_state;
             end case;

           --
			  -- EXECUTE:
			  -- decode opcode
           -- to determine if output of the ALU is transfered to a register
			  -- or if alu output is written back to memory
           --
			  -- if opcode = dual operand                 or
			  --    opcode = single operand accum / ixreg or
			  --    opcode = branch on bit                then
			  --    goto fetch_state
			  --
			  -- if opcode = single operand memory        or
			  --    opcode = bit set / clear              or
			  --    goto write_state
			  --
			  when exec_state => -- execute alu operation
 				 pc_ctrl    <= latch_pc;
             ea_ctrl    <= latch_ea; 
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
				 addr_ctrl  <= idle_addr;
	          data_ctrl  <= md_data;

             case op(7 downto 4) is
				 when "0000" =>            -- branch set / clear
  	            ac_ctrl    <= latch_ac;
	            ix_ctrl    <= latch_ix;
	            sp_ctrl    <= latch_sp;
					left_ctrl  <= md_left;
					right_ctrl <= bset_right;
					alu_ctrl   <= alu_btst;
               md_ctrl    <= load_md;
					cc_ctrl    <= load_cc;
				   next_state <= brbit_state;

 				 when "0001" =>            -- bit set / clear
  	            ac_ctrl    <= latch_ac;
	            ix_ctrl    <= latch_ix;
	            sp_ctrl    <= latch_sp;
				   case op(0) is
					when '0' =>             -- bset
					  left_ctrl  <= md_left;
					  right_ctrl <= bset_right;
					  alu_ctrl   <= alu_ora;
                 md_ctrl    <= load_md;
					  cc_ctrl    <= load_cc;

					when '1' =>             -- bclr
					  left_ctrl  <= md_left;
					  right_ctrl <= bclr_right;
					  alu_ctrl   <= alu_and;
                 md_ctrl    <= load_md;
					  cc_ctrl    <= load_cc;

					when others =>
					  left_ctrl  <= md_left;
					  right_ctrl <= bclr_right;
					  alu_ctrl   <= alu_nop;
                 md_ctrl    <= latch_md;
					  cc_ctrl    <= latch_cc;
					end case;
				   next_state <= write_state;

				 when "0011" |            -- single op direct
				      "0110" |            -- single op ix1
				      "0111" =>           -- single op ix0
  	            ac_ctrl    <= latch_ac;
	            ix_ctrl    <= latch_ix;
	            sp_ctrl    <= latch_sp;
					left_ctrl  <= md_left;
               md_ctrl    <= load_md;
					cc_ctrl    <= load_cc;
				   case op( 3 downto 0 ) is
				   when "0000" =>            -- neg
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_neg;
				   when "0011" =>            -- com
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_com;
				   when "0100" =>            -- lsr
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_lsr;
				   when "0110" =>            -- ror
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_ror;
				   when "0111" =>            -- asr
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_asr;
				   when "1000" =>            -- lsl
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_lsl;
				   when "1001" =>            -- rol
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_rol;
				   when "1010" =>            -- dec
					  right_ctrl <= one_right;
					  alu_ctrl   <= alu_dec;
				   when "1011" =>            -- undef
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
				   when "1100" =>            -- inc
					  right_ctrl <= one_right;
					  alu_ctrl   <= alu_inc;
				   when "1101" =>            -- tst
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_tst;
				   when "1110" =>            -- undef
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
				   when "1111" =>            -- clr
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_clr;
					when others =>
					  right_ctrl <= zero_right;
					  alu_ctrl   <= alu_nop;
					end case;
				   next_state <= write_state;

			    when others =>
  	            ac_ctrl    <= latch_ac;
					cc_ctrl    <= latch_cc;
	            ix_ctrl    <= latch_ix;
	            sp_ctrl    <= latch_sp;
               md_ctrl    <= latch_md;
					left_ctrl  <= md_left;
					right_ctrl <= zero_right;
					alu_ctrl   <= alu_nop;
					next_state <= fetch_state;
			    end case;
           --
			  -- WRITE:
			  -- write latched alu output to memory pointed to by ea register
			  -- go to fetch state
			  --
			  when write_state => -- write alu output to memory
  	          ac_ctrl    <= latch_ac;
			    cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
             ea_ctrl    <= latch_ea; 
             md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
			    left_ctrl  <= md_left;
			    right_ctrl <= zero_right;
				 alu_ctrl   <= alu_nop;
				 addr_ctrl  <= write_addr;
			    data_ctrl  <= md_data;        -- select latched alu output to data bus
			    next_state <= fetch_state;
			  --
			  -- BRBIT
			  -- Branch on condition of bit
			  -- fetch the address offset
			  -- advance the pc
           -- evaluate the carry bit to determine if we take the branch
			  -- Carry = 0 if tested bit set
			  -- Carry = 1 if tested bit clear
			  -- op(0) = 0 if BRSET
			  -- op(0) = 1 if BRCLR
			  -- if carry = '1'
			  --   goto branch state
			  -- else
			  --   goto execute state
			  -- 
			  when brbit_state => -- fetch address offset
  	          ac_ctrl    <= latch_ac;
			    cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
				 ea_ctrl    <= fetch_first_ea;
             md_ctrl    <= latch_md;
				 pc_ctrl    <= inc_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
			    left_ctrl  <= md_left;
			    right_ctrl <= zero_right;
				 alu_ctrl   <= alu_nop;
				 addr_ctrl  <= fetch_addr;
			    data_ctrl  <= md_data;        -- select latched alu output to data bus
			    if (cc(CFLAG) xor op(0)) = '0' then -- check this ... I think it's right
			      next_state <= branch_state;
				 else
				   next_state <= fetch_state;
				 end if;

           --
			  -- BRANCH:
			  -- take conditional branch
			  -- branch (pc relative addressing)
           -- add effective address (ea register) to pc
           -- go to "fetch" state
           ---
			  when branch_state => -- calculate branch address
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= bra_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= idle_addr;     -- idle address bus
	          data_ctrl  <= md_data;       -- read memory data
	          next_state <= fetch_state;
			  --
			  -- jump to subroutine
			  --
			  when bsr_state =>     -- calculate effective jump address
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
             ea_ctrl    <= addpc_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU operation
				 addr_ctrl  <= idle_addr;
	          data_ctrl  <= md_data;
			    next_state <= jsr_state;

			  when jsr_state =>     -- store pc low / decrement sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= dec_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= push_addr;     -- write stack address
	          data_ctrl  <= pc_lo_data;    -- write PC low
			    next_state <= jsr1_state;

			  when jsr1_state =>    -- store pc high / decrement sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= dec_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= push_addr;     -- write stack address
	          data_ctrl  <= pc_hi_data;    -- write PC high
			    next_state <= jmp_state;
			  --
			  -- jump to address
			  --
			  when jmp_state =>     -- load pc with effective address
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= jmp_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion (do nothing)
				 addr_ctrl  <= idle_addr;     -- idle address
	          data_ctrl  <= pc_lo_data;    -- 
			    next_state <= fetch_state;
			  --
			  -- return from subroutine
			  --
			  when rts_state => -- increment stack pointer
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= inc_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= idle_addr;
	          data_ctrl  <= md_data;
			    next_state <= rts_pch_state;

			  when rts_pch_state => -- load pc high return address / increment sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= inc_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= pull_hi_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= pull_addr;
	          data_ctrl  <= pc_hi_data;
			    next_state <= rts_pcl_state;

			  when rts_pcl_state => -- load pc low return address
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= pull_lo_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= pull_addr;
	          data_ctrl  <= pc_lo_data;
			    next_state <= fetch_state;

			  --
			  --
			  -- return from interrupt
			  --
			  when rti_state => -- increment sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= inc_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= fetch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= idle_addr;
	          data_ctrl  <= md_data;
			    next_state <= rti_cc_state;

			  when rti_cc_state => -- read cc / increment sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= pull_cc;			-- read Condition codes
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= inc_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= pull_addr;     -- read stack address
	          data_ctrl  <= cc_data;       -- output old CC
			    next_state <= rti_ac_state;

			  when rti_ac_state => -- read acc / increment sp
  	          ac_ctrl    <= pull_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= inc_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= pull_addr;     -- read stack address
	          data_ctrl  <= ac_data;       -- output Accumulator
			    next_state <= rti_ix_state;

			  when rti_ix_state => -- read ix / increment sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= pull_ix;		  -- read IX register
	          sp_ctrl    <= inc_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= pull_addr;     -- read stack address
	          data_ctrl  <= ix_data;       -- output old ix register
			    next_state <= rti_pch_state;

			  when rti_pch_state => -- read pc hi / increment sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= inc_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= pull_hi_pc;	   -- read PC high
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= pull_addr;		-- read stack address
	          data_ctrl  <= pc_hi_data;		-- output old PC high
			    next_state <= rti_pcl_state;

			  when rti_pcl_state => -- read pc lo
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= pull_lo_pc;		-- read PC low
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= pull_addr;		-- read stack address
	          data_ctrl  <= pc_lo_data;		-- output old PC Low
			    next_state <= fetch_state;
           --
			  -- sofwtare interrupt (or any others interrupt state)
			  --
			  when swi_state =>
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= swi_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= idle_addr;
	          data_ctrl  <= md_data;
			    next_state <= int_state;

			  --
			  -- any sort of interrupt
			  --
			  when int_state =>  -- store pc low / decrement sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= dec_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= push_addr;
	          data_ctrl  <= pc_lo_data;
			    next_state <= int1_state;

			  when int1_state => -- store pc hi / decrement sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= dec_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= push_addr;
	          data_ctrl  <= pc_hi_data;
			    next_state <= int2_state;

           when int2_state => -- store ix / decrement sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= dec_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= push_addr;
	          data_ctrl  <= ix_data;
				 next_state <= int3_state;

           when int3_state => -- store ac / decrement sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= dec_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= push_addr;
	          data_ctrl  <= ac_data;
				 next_state <= int4_state;

           when int4_state => -- store cc / decrement sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= dec_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU opeartion
				 addr_ctrl  <= push_addr;
	          data_ctrl  <= cc_data;
				 next_state <= int5_state;

           when int5_state => -- fetch pc hi = int vector hi
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= load_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= pull_hi_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_sei;       -- ALU operation
				 addr_ctrl  <= vect_hi_addr;
	          data_ctrl  <= pc_hi_data;
				 next_state <= int6_state;

           when int6_state => -- fetch pc low = int vector low
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= load_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= pull_lo_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_sei;       -- ALU operation
				 addr_ctrl  <= vect_lo_addr;
	          data_ctrl  <= pc_lo_data;
				 next_state <= fetch_state;
			  --
			  -- stop the processor
			  --
			  when stop_state =>
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU operation
				 addr_ctrl  <= idle_addr;
	          data_ctrl  <= md_data;
			    next_state <= stop_state;
           --
			  -- wait for interrupt
			  --
			  when wait_state => -- push pclow / decrement sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= dec_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU operation
				 addr_ctrl  <= push_addr;
	          data_ctrl  <= pc_lo_data;
			    next_state <= wait1_state;

			  when wait1_state => -- push pchi / decrement sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= dec_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU operation
				 addr_ctrl  <= push_addr;
	          data_ctrl  <= pc_hi_data;
			    next_state <= wait2_state;

           when wait2_state => -- push ix / decrement sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= dec_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU operation
				 addr_ctrl  <= push_addr;
	          data_ctrl  <= ix_data;
				 next_state <= wait3_state;

           when wait3_state => -- push ac / decrement sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= dec_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU operation
				 addr_ctrl  <= push_addr;
	          data_ctrl  <= ac_data;
				 next_state <= wait4_state;

           when wait4_state => -- push cc / decrement sp
  	          ac_ctrl    <= latch_ac;
	          cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= dec_sp;
             ea_ctrl    <= latch_ea; 
	          md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
             left_ctrl  <= ac_left;       -- Left ALU input
	          right_ctrl <= md_right;      -- Right ALU input
             alu_ctrl   <= alu_nop;       -- ALU operation
				 addr_ctrl  <= push_addr;
	          data_ctrl  <= cc_data;
				 next_state <= halt_state;
           --
			  -- halt cpu
			  --
  			  when halt_state => -- halt on halt
  	          ac_ctrl    <= latch_ac;
			    cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
             ea_ctrl    <= latch_ea; 
             md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
			    left_ctrl  <= md_left;
			    right_ctrl <= zero_right;
				 alu_ctrl   <= alu_nop;
				 addr_ctrl  <= idle_addr;
			    data_ctrl  <= md_data;        -- select latched alu output to data bus
			    next_state <= halt_state;
           --
			  -- undefined instruction
		     --
  			  when others => -- halt on undefine states
  	          ac_ctrl    <= latch_ac;
			    cc_ctrl    <= latch_cc;
	          ix_ctrl    <= latch_ix;
	          sp_ctrl    <= latch_sp;
             ea_ctrl    <= latch_ea; 
             md_ctrl    <= latch_md;
 				 pc_ctrl    <= latch_pc;
             op_ctrl    <= latch_op;
	          iv_ctrl    <= latch_iv;
			    left_ctrl  <= md_left;
			    right_ctrl <= zero_right;
				 alu_ctrl   <= alu_nop;
				 addr_ctrl  <= idle_addr;
			    data_ctrl  <= md_data;        -- select latched alu output to data bus
			    next_state <= halt_state;

		  end case;						

end process;
--------------------------------
--
-- state machine
--
--------------------------------

change_state: process( clk, rst, state )
begin
  if rst = '1' then
 	 state <= reset_state;
  elsif clk'event and clk = '0' then
    state <= next_state;
  end if;
end process;
	-- output
	
end CPU_ARCH;
	
