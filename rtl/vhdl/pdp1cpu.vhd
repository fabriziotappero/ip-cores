----------------------------------------------------------------------------------
-- Company:     None
-- Engineer:    Yann Vernier
-- 
-- Create Date:    13:29:13 02/09/2009 
-- Design Name: 
-- Module Name:    pdp1cpu - Behavioral 
-- Project Name:   PDP-1
-- Target Devices: Xilinx Spartan 3A
-- Tool versions:  WebPack 10.1
-- Description:  PDP-1 CPU (main logic) module, executes instructions.
--
-- Dependencies: Requires a RAM and a clock source. RAM is accessed in alternating read and write.
--               Original clock is 200kHz memory cycle, where each cycle both
--               reads and writes (core memory). CPU itself must be clocked 10
--               times faster (original logic modules could keep up with 4MHz).
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--   Aim is currently a PDP-1B level.
--   B version had multiply and divide Step to accelerate the subroutines,
--   and the first had pure software subroutines. C had full hardware multiply(?).
--   PDP-1D implements several more instructions not included here.
--   Extensions (including sequence break and extended memory) are not implemented.
--
--   Goal: Run Spacewar! in hardware. Initial target version is that used by Java
--   emulator, which is a PDP-1B, with multiply and divide steps.
--   That emulator doesn't have DIP.
--   PDP-1C had full multiply and divide instructions of variable time.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity pdp1cpu is
    Port (
      -- memory interface
      M_DI : out STD_LOGIC_VECTOR(0 to 17) := (others=>'0');
      M_DO : in STD_LOGIC_VECTOR(0 to 17);
      MW : inout STD_LOGIC	:= '0';
      MA : out std_logic_vector(0 to 11)	:= (others=>'0');
			  
      CLK : in STD_LOGIC;	   -- in progress: adapt to 10x clock

      -- CPU status
      AWAKE : out STD_LOGIC;

      -- user visible registers
      AC : inout STD_LOGIC_VECTOR(0 to 17)	:= (others=>'0');  -- accumulator
      IO : inout STD_LOGIC_VECTOR(0 to 17)	:= (others=>'0');  -- I/O
      PC : inout unsigned(0 to 11)	:= (others=>'0');  -- program counter
      PF : inout STD_LOGIC_VECTOR(1 to 6)	:= (others=>'0');  -- program flags
      OV : inout STD_LOGIC := '0';      -- overflow flag

      -- user settable switches
      SW_TESTA : in std_logic_vector(0 to 11) := (others => '0');  -- test address
      SW_TESTW : in std_logic_vector(0 to 17) := (others => '0');  -- test word
      SW_SENSE : in std_logic_vector(1 to 6) := (others => '0');  -- sense switches
      
      -- I/O interface
      IOT : out STD_LOGIC_VECTOR(0 to 63) := (others=>'0');  -- I/O transfer pulse lines
      IODOPULSE : out STD_LOGIC := '0';  -- signal to I/O device to send a
                                         -- pulse when done
      IODONE : in STD_LOGIC := '0';     -- I/O device done signal
      IO_SET : in STD_ULOGIC := '0';	-- used to set I/O register to IO_IN value (synchronous!)
      IO_IN : in STD_LOGIC_VECTOR(0 to 17) := o"000000";	-- bus for I/O devices to report values
           
      RESET : in STD_LOGIC
      );
end pdp1cpu;

architecture Behavioral of pdp1cpu is
	subtype word is STD_LOGIC_VECTOR(0 to 17);
	subtype opcode is std_logic_vector(0 to 5);
        -- Formally the opcode is 5 bits; I've included the indirection bit.

	signal MB: word;                -- memory buffer
	signal op: opcode := o"00";     -- current operation (user visible originally)

        signal IOWAIT, HALT : boolean := false;

	alias ib : std_logic is op(5);  -- indirection bit
	alias y : std_logic_vector(0 to 11) is MB(6 to 17);  -- address/operand

	-- operations - note that "load" here is OR, for some reason.
	alias cli : std_logic is MB(6);	        -- clear IO
	alias lat : std_logic is MB(7);	        -- load AC with Test.Switches
	alias cma : std_logic is MB(8);	        -- complement AC
	alias hlt : std_logic is MB(9);  	-- halt
	alias cla : std_logic is MB(10);	-- clear AC
	alias lap : std_logic is MB(11);	-- load AC from PC
	alias flag_setto : std_logic is MB(14);	-- set program flag(s) - value
	alias flag_which : std_logic_vector(2 downto 0) is MB(15 to 17);
	-- skip conditions
	alias spi : std_logic is MB(7);		-- Skip if Positive IO
	alias szo : std_logic is MB(8);		-- skip if zero OV
	alias sza : std_logic is MB(9);		-- skip if zero AC
	alias spa : std_logic is MB(10);	-- skip if positive AC
	alias sma : std_logic is MB(11);	-- skip if negative AC
	alias szs : std_logic_vector(0 to 2) is MB(12 to 14);	-- skip if Zero Switches
	alias szf : std_logic_vector(0 to 2) is MB(15 to 17);	-- skip if Zero Flags
	
	-- Opcodes      -- loading group
	constant op_and : opcode := o"02";	-- AC&=M
	constant op_ior : opcode := o"04";	-- AC|=M
	constant op_xor : opcode := o"06";	-- AC^=M
	constant op_add : opcode := o"40";	-- AC+=M
	constant op_sub : opcode := o"42";	-- AC-=M
	constant op_lac : opcode := o"20";	-- load AC
	constant op_lio : opcode := o"22";	-- load IO
	constant op_sad : opcode := o"50";	-- skip if AC/=M(y)
	constant op_sas : opcode := o"52";	-- skip if AC=M(y)
	-- storing group
	constant op_dac : opcode := o"24";	-- store AC
	constant op_dap : opcode := o"26";	-- deposit address part of AC
	constant op_dip : opcode := o"30";	-- deposit instruction part -- missing in Java emulator
	constant op_dio : opcode := o"32";	-- deposit IO
	constant op_dzm : opcode := o"34";	-- deposit zero
	-- jumping group
	constant op_skip: opcode := o"64";	-- adds 1 to IP; SAD and SAS, load group, also do this
	constant op_skipi: opcode := o"65";	-- as above, but inverts condition
	constant op_jmp : opcode := o"60";	-- jump
	constant op_jsp : opcode := o"62";	-- jump and save PC
	constant op_cal : opcode := o"16";	-- call subroutine
	constant op_jda : opcode := o"17";	-- jump and deposit AC
	-- immediate group
	constant op_rotshiftl: opcode := o"66";	-- rotate/shift (IB is direction)
	constant op_rotshiftr: opcode := o"67";
	constant op_law : opcode := o"70";	-- load accumulator immediate
	constant op_lawm: opcode := o"71";
	constant op_opr : opcode := o"76";	-- operate group
	-- miscellaneous
	constant op_idx : opcode := o"44";		-- index - AC=++M[y]
	constant op_isp : opcode := o"46";		-- same, and skip if positive
--	constant op_mul : opcode := o"54";		-- full multiply (PDP-1C)
--	constant op_div : opcode := o"56";		-- full divide (PDP-1C)
	constant op_mus : opcode := o"54";		-- multiply step (PDP-1B)
	constant op_dis : opcode := o"56";		-- divide step (PDP-1B)
	constant op_xct : opcode := o"10";		-- execute
	constant op_iot : opcode := o"73";		-- I/O transfer group, ib is wait for completion
	constant op_iot_nw : opcode := o"72";

        -- cycletype tracks the memory cycle reason
	type cycle_type is (load_instruction, load_indirect, load_data, store_data);
	signal cycletype : cycle_type;
	signal cycle : integer range 0 to 9 := 0;	-- 10 cycles per memory access cycle
        -- NOTE: rotshift relies on this range!
	constant cycle_setup_read: integer := 0;
	constant cycle_read: integer := 2;  -- memory is over-registered
	constant cycle_execute: integer := 3;
	constant cycle_setup_write: integer := 5;
	constant cycle_wrote: integer := 6;  -- not actually used
	constant cycle_skip: integer := 9;

	COMPONENT onecomplement_adder
	PORT(
		A : IN std_logic_vector(0 to 17);
		B : IN std_logic_vector(0 to 17);
		CI : IN std_logic;          
		SUM : OUT std_logic_vector(0 to 17);
		OV : OUT std_logic;
		CSUM : OUT std_logic_vector(0 to 17)
		);
	END COMPONENT;

	COMPONENT pdp1rotshift
	PORT(
		ac : IN std_logic_vector(0 to 17);
		io : IN std_logic_vector(0 to 17);
		right : IN std_logic;
		shift : IN std_logic;
		words : IN std_logic_vector(0 to 1);
		acout : OUT std_logic_vector(0 to 17);
		ioout : OUT std_logic_vector(0 to 17)
		);
	END COMPONENT;
	signal rotshift_ac, rotshift_io: word;
	signal rotshift_right, rotshift_shift: std_logic;
	signal rotshift_words: std_logic_vector(0 to 1);
	signal add_a, add_b, add_sum, add_csum, dis_term: word;
	signal add_ci, add_ov: std_logic;
	signal skipcond: std_logic;     -- skip condition for op_skip
        signal ac_eq_mb : boolean;
        -- purpose: value of a sense switch if n valid, else '1'
        function sense_or_one (
          n        : integer;          -- which sense flag
          sense_sw : std_logic_vector(1 to 6))  -- sense switches
          return std_logic is
        begin  -- sense_or_one
          for i in 1 to 6 loop
            if n=i then
              return sense_sw(n);
            end if;
          end loop;  -- i
          return '1';
        end sense_or_one;
begin
        AWAKE <= '0' when IOWAIT or RESET='1' or HALT else '1';

	Inst_pdp1rotshift: pdp1rotshift PORT MAP(
		ac => AC,			-- shift operation is read from memory
		io => IO,
		right => rotshift_right,
		shift => rotshift_shift,
		words => rotshift_words,
		acout => rotshift_ac,
		ioout => rotshift_io
	);
	with op select
          rotshift_right <= '1' when op_mus,
          '0' when op_dis,
          M_DO(5) when others;
	with op select
          rotshift_shift <= '1' when op_mus,
          '-' when op_dis,
          M_DO(6) when others;
	with op select
          rotshift_words <= "11" when op_mus,
          "11" when op_dis,
          M_DO(7 to 8) when others;

	Inst_onecomplement_adder: onecomplement_adder PORT MAP(
		A => add_a,
		B => add_b,
		CI => add_ci,
		SUM => add_sum,
		OV => add_ov,
		CSUM => add_csum
	);
        -- we use this same adder for addition, subtraction, indexing and multiply/divide step
	with io(17) select
          dis_term <= not MB when '1',
                      MB when '0',
                      (others=>'-') when others;
	with op select
          add_a <= o"000001" when op_idx | op_isp,
                   AC when op_add|op_mus|op_dis,
                   (others=>'-') when others;
	with op select
          add_b <= MB when op_add|op_idx|op_isp|op_mus,
                   not MB when op_sub,
                   dis_term when op_dis,
                   (others=>'-') when others;
	add_ci <= '1' when op=op_dis and io(17)='0' else
                  '0';

        M_DI <= MB;
        ac_eq_mb <= AC=MB;

	skipcond <= '1' when (
          (sza='1' and AC=o"00_0000") or	-- accumulator zero
          (spa='1' and AC(0)='0') or	-- accumulator positive
          (sma='1' and AC(0)='1') or	-- accumulator negative
          (szo='1' and OV='0') or		-- zero overflow
          (spi='1' and IO(0)='0') or	-- positive IO register
          (MB(12 to 14)=o"7" and sw_sense=o"00") or	-- all sense switches 0
          (sense_or_one(to_integer(unsigned(MB(12 to 14))),sw_sense)='0') or
          false                         -- so all lines above end with or
          ) else '0';

	process (CLK, RESET)
          variable idx: unsigned(0 to 17);
          variable tmp_w: word;
	begin
          if RESET='1' then					-- asynchronous reset
            AC <= (others => '0');
            IO <= (others => '0');
            PC <= o"0000";
            OV <= '0';
            PF <= (others => '0');
            -- memory control
            MW <= '0';
            MA <= o"0000";
            -- reset our internal state
            op <= o"00";
            IOWAIT <= false;
            IOT <= (others => '0');
            cycletype <= load_instruction;
            cycle <= cycle_setup_read;
          elsif rising_edge(CLK) then
            if IO_set='1' then
              IO <= IO_in;
            end if;
            IOT <= (others => '0');     -- ordinarily no io trigger pulse
            -- Advance the cycle, unless we're halted
            if IOWAIT then
              if IODONE='1' then
                IOWAIT <= false;
              end if;
            end if;
            -- pause during setup_read cycle for halt or iowait
            if not ((IOWAIT or HALT) and (cycle=cycle_setup_read)) then
              if cycle=9 then
                cycle <= 0;
              else
                cycle <= cycle+1;
              end if;
              
              -- common logic for signals
              if cycle=cycle_setup_write then
                MW <= '1';
              else
                MW <= '0';
              end if;
              if (op=op_rotshiftr or op=op_rotshiftl) then
                case cycle is
                  when 9 =>          -- don't shift on cycle 9
                  when others =>
                    if MB(9+cycle)='1' then
                      AC <= rotshift_ac;    -- perform rotate/shift instructions
                      if IO_set/='1' then
                        IO <= rotshift_io;
                      end if;
                    end if;
                end case;
              end if;
              
              case cycle is
                when cycle_read =>		-- have read something from memory
                  MB <= M_DO;
                  case cycletype is
                    when load_instruction =>	-- it's our next instruction
                      op <= M_DO(0 to 5);
                      if op/=op_xct then  -- indirect execution
                        PC<=PC+1;
                      end if;
                    when load_indirect =>		-- completing an indirect instruction
                      ib <= M_DO(5);		-- update indirection bit
                    when others =>		-- data access cycle
                  end case;
                when cycle_skip =>
                  if ((op=op_skip or op=op_skipi) and (skipcond xor ib)='1') or
                     (op=op_isp and cycletype=store_data and AC(0)='0') or
                     (op=op_sas and cycletype=load_data and ac_eq_mb) or
                     (op=op_sad and cycletype=load_data and not ac_eq_mb) or
                     FALSE then    -- increase PC an extra time
                    PC <= PC+1;
                  end if;
                  if (op=op_skip or op=op_skipi) and szo='1' then
                    OV <= '0';          -- clear overflow after checking it
                  end if;
                when cycle_setup_read => 	-- set up the memory address
                  case cycletype is
                    when load_instruction|load_indirect =>
                      case (op) is
                        -- memory loading instructions - will execute after loading data
                        when op_sas|op_sad|op_lac|op_lio|op_and|op_xor|op_ior|op_add|
                          op_sub|op_idx|op_isp|op_mus|op_dis =>
                          cycletype <= load_data;
                          MA <= y;
                        when op_xct =>	    -- load specified instruction, do not change PC
                          cycletype <= load_instruction;
                          MA <= y;
                        when op_dac|op_dap|op_dip|op_dio|op_dzm =>        -- deposit instructions
                          cycletype <= store_data;
                          MA <= y;
                        when op_jmp|op_jsp|op_cal|op_jda =>		-- jumping instructions
                          if op/=op_jmp then
                            AC(0) <= OV;
                            AC(1 to 5) <= (others => '0');	-- extended PC
                            AC(6 to 17) <= std_logic_vector(PC);
                          end if;
                          if op=op_cal or op=op_jda then
                            if op=op_cal then
                              PC <= o"0101";
                              MA <= o"0100";
                            else
                              PC <= unsigned(y)+1;
                              MA <= y;
                            end if;
                            cycletype <= store_data;
                          else
                            MA <= y;
                            PC <= unsigned(y);
                            cycletype <= load_instruction;
                          end if;
                        when op_skipi|op_rotshiftr|op_lawm|op_iot_nw =>
                          -- instructions with IB set, yet are immediate
                          MA <= std_logic_vector(PC);
                          cycletype <= load_instruction;
                        when others =>	-- most instructions are followed by the next instruction
                          if ib='1' then  -- handle indirection bit
                            MA <= y;
                            cycletype <= load_indirect;
                          else
                            MA <= std_logic_vector(PC);
                            cycletype <= load_instruction;
                          end if;
                      end case;   -- end of by-instruction memory setup
                    when others =>      -- have done data load/store
                      MA <= std_logic_vector(PC);
                      cycletype <= load_instruction;
                  end case;
                when cycle_execute =>
                  -- execute common instructions - instr or operand has been read
                  case cycletype is
                    when load_instruction|load_indirect =>   -- new instr,
                      case op is
                        when op_law =>	-- load accumulator immediate
                          AC(0 to 5) <= (others => '0');
                          AC(6 to 17) <= y;
                        when op_lawm =>		-- load accumulator immediate negative
                          AC(0 to 5) <= (others => '1');
                          AC(6 to 17) <= not y;
                        when op_opr =>		-- operate group
                          if cli='1'  and IO_set/='1' then IO <= o"00_0000"; end if;
                          if hlt='1' then HALT <= TRUE; end if;	-- HALT
                          if cla='1' then
                            tmp_w := (others => '0');
                          else
                            tmp_w := AC;
                          end if;
                          if lat='1' then tmp_w := tmp_w or sw_testw; end if;
                          if lap='1' then	-- or AC with PC and OV
                            tmp_w(6 to 17) := tmp_w(6 to 17) or std_logic_vector(PC);
                            tmp_w(0) := tmp_w(0) or OV;
                          end if;
                          if cma='1' then tmp_w := not tmp_w; end if;
                          AC <= tmp_w;
                          for j in 1 to 6 loop
                            if unsigned(flag_which)=j or unsigned(flag_which)=7 then
                              PF(j) <= flag_setto;	-- set or clear program flags
                            end if;
                          end loop;
                        when op_rotshiftl|op_rotshiftr =>
                          -- handled in a separate block
                        when op_skip|op_skipi =>
                          -- inverted skip is not documented in 1960 manual.
                          -- it does occur in PDP-1B emulator and 1963 manual.
                          -- all skips are handled in skip phase, for no
                          -- real reason
                        when op_iot|op_iot_nw =>		-- I/O transfer
                          -- Java emulator Spacewar! binary supports:
                          -- typewriter sequence break input,
                          -- display on ordinary display (7),
                          -- reading of controls using undocumented device 11,
                          --   should load 4 bits of button controls in low and
                          --   high ends of the word
                          -- and does display 3 display commands (disabled point?).
                          -- It uses nowait+pulse, nowait, and wait+noop modes, so waiting
                          -- has to be implemented.
                          IODOPULSE <= MB(5) xor MB(6);		-- generate an IODONE for this event
                          IOWAIT <= IB='1';
                          IOT(to_integer(unsigned(MB(12 to 17)))) <= '1';
                          
                        when others =>
                          if ib='1' then		-- likely turns into a valid op once IB is cleared
                            cycletype <= load_indirect;
                          end if;
                      end case;     --  end of instruction check in execute phase
                    when load_data =>	-- loaded data for loading instruction
                      case (op) is
                        when op_sas|op_sad =>  -- handled in skip phase
                        when op_lac =>
                          AC <= M_DO;
                        when op_idx|op_isp =>
                          AC <= add_sum;
                          MB <= add_sum;
                        when op_lio =>
			  if IO_set/='1' then
                            IO <= MB;
                          end if;
                        when op_and =>
                          AC <= AC and MB;
                        when op_xor =>
                          AC <= AC xor MB;
                        when op_ior =>
                          AC <= AC or MB;
                        when op_add =>
                          AC <= add_csum;			-- no negative 0
                          OV <= OV or add_ov;
                        when op_sub =>
                          AC <= add_sum;
                          OV <= OV or add_ov;
                          -- Multiply Step and Divide Step are the same opcode as Multiply and Divide.
                          -- There's no reasonable way for the CPU to determine which a program wants.
--          when op_mul =>		-- multiply originally takes 3-5 cycles. this one takes 2.
--		tmp_w := AC;
--		tmp_w2 := M_DO;
--		if tmp_w(0)='1' then tmp_w:=not tmp_w; end if;
--		if tmp_w2(0)='1' then tmp_w2:=not tmp_w2; end if;
--		product := tmp_w(1 to 17)*tmp_w2(1 to 17);
--		if AC(0)/=M_DO(0) then
--	        	product:=not product;			-- preserve sign
--	        	AC(0)<='1';
--		        IO(0)<='1';
--		else
--			AC(0)<='0';
--			IO(0)<='0';
--		end if;
--		AC(1 to 17)<=product(0 to 16);
--		IO(1 to 17)<=product(17 to 33);
                        when op_mus =>		-- PDP-1B multiply step
                          if IO(17)='1' then
                            AC <= add_csum;
                          end if;
                          -- continued in next cycle
                        when op_dis =>		-- PDP-1B divide step
                          AC <= rotshift_ac;
                          IO(0 to 16) <= rotshift_io(0 to 16);
                          IO(17) <= not AC(0);
                          -- continued in next cycle
                        when others =>
                              -- can't happen, see cases leading to load_data.
                      end case;     -- end of load ops, execute cycle
                    when store_data =>
                      case op is
                        when op_dac =>
                          MB <= AC;
                        when op_dap =>
                          --MB(0 to 5) <= MB(0 to 5);
                          MB(6 to 17) <= AC(6 to 17);
                        when op_dip =>
                          MB(0 to 5) <= AC(0 to 5);
                          --MB(6 to 17) <= MB(6 to 17);
                        when op_dio =>
                          MB <= IO;
                        when op_dzm =>
                          MB <= o"00_0000";
                        when others =>  -- others should not occur
                      end case;
                  end case;         -- end of cycletype cases for execute cycle
                      -- FIXME more to fix here
                when cycle_execute+1 =>
                  case op is    -- multiply, divide and I/O use two stages
                    when op_mus =>
                      AC <= rotshift_ac;
                      if IO_set/='1' then
                        IO <= rotshift_io;
                      end if;
                    when op_dis =>
                      AC <= add_csum;
                    when others =>  -- note: rotshift uses 9 cycles
                  end case;
                when others =>
              end case;
            end if;
          end if;
	end process;
end Behavioral;

