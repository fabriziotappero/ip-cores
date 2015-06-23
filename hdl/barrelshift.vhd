-- This file is part of ARM4U CPU
-- 
-- This is a creation of the Laboratory of Processor Architecture
-- of Ecole Polytechnique Fédérale de Lausanne ( http://lap.epfl.ch )
--
-- barrelshift.vhd  --  Describes the barrel shifter inside the execute pipeline stage
--
-- Written By -  Jonathan Masur and Xavier Jimenez (2013)
--
-- This program is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the
-- Free Software Foundation; either version 2, or (at your option) any
-- later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- In other words, you are welcome to use, share and improve this program.
-- You are forbidden to forbid anyone else to use, share and improve
-- what you give them.   Help stamp out software-hoarding!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arm_types.all;

entity barrelshift is
	port(
		c : in std_logic;
		exe_barrelshift_operand : in std_logic;
		exe_barrelshift_type : in std_logic_vector(1 downto 0);
		exe_literal_shift_amnt : in std_logic_vector(4 downto 0);
		exe_literal_data : in std_logic_vector(23 downto 0);
		exe_opb_is_literal : in std_logic;
		op_b_data : in unsigned(31 downto 0);
		op_c_data : in unsigned(31 downto 0);
		barrelshift_c : out std_logic;
		barrelshift_out : out unsigned(31 downto 0)
	);
end;

-- Note : This architecture synthetizes poorly
architecture rtl of barrelshift is
begin
	-- barrel shifter
	barrelshift : process(exe_barrelshift_operand, exe_barrelshift_type, op_b_data, op_c_data, exe_opb_is_literal, exe_literal_shift_amnt, exe_literal_data, c) is
	variable shift_positions : integer range 0 to 31;
	variable shift_in : unsigned(31 downto 0);
	begin
			-- shift by register (opc)
		if exe_barrelshift_operand = '1'
		then
			shift_positions := to_integer(op_c_data(4 downto 0));
		else
			-- shift by literal value
			shift_positions := to_integer(unsigned(exe_literal_shift_amnt));
		end if;
		
		if exe_opb_is_literal = '1'
		then
			-- sign extend literal value
			shift_in := (31 downto 24 => exe_literal_data(23)) & unsigned(exe_literal_data);
		else
			shift_in := op_b_data;
		end if;
		
		case exe_barrelshift_type is	
		-- LSR
		when "01" =>
			-- shift by register > 32 -> overflows, all bits are out
			if exe_barrelshift_operand = '1' and op_c_data(7 downto 0) > x"20"
			then
				barrelshift_out <= (others => '0');
				barrelshift_c <= '0';

			-- shift by register or literal, 32 positions
			elsif (exe_barrelshift_operand = '1' and op_c_data(7 downto 0) = x"20")
			   or (exe_barrelshift_operand = '0' and exe_literal_shift_amnt = "00000")
			then
				barrelshift_out <= (others => '0');
				barrelshift_c <= shift_in(31);


			-- shift by register = 0, opb passes through and C is unaffected
			elsif exe_barrelshift_operand = '1' and op_c_data(7 downto 0) = x"00"
			then
				barrelshift_out <= shift_in;
				barrelshift_c <= c;

			-- shift by literal or register, range 1..31
			else
				barrelshift_out <= shift_in srl shift_positions;
				barrelshift_c <= shift_in(shift_positions - 1);
			end if;

		-- ASR
		when "10" =>
			-- shift by register or literal >= 32 -> overflows, all bits are the sign bit
			-- shift by register or literal, 32 positions
			if (exe_barrelshift_operand = '1' and op_c_data(7 downto 0) >= x"20")
			or (exe_barrelshift_operand = '0' and exe_literal_shift_amnt = "00000")
			then
				barrelshift_out <= (others => shift_in(31));
				barrelshift_c <= shift_in(31);

			-- shift by register = 0, opb passes through and C is unaffected
			elsif exe_barrelshift_operand = '1' and op_c_data(7 downto 0) = x"00"
			then
				barrelshift_out <= shift_in;
				barrelshift_c <= c;

			-- shift by literal or register, range 1..31
			else			
				barrelshift_out <= unsigned(shift_right(signed(shift_in), shift_positions));
				barrelshift_c <= shift_in(shift_positions - 1);
			end if;

		-- ROR / RRX
		when "11" =>
			-- RRX - 33 bit rotation with carry
			if exe_barrelshift_operand = '0' and exe_literal_shift_amnt = "00000"
			then
				barrelshift_out <= c & shift_in(31 downto 1);
				barrelshift_c <= shift_in(0);

			-- ROR by register = 0, opb passes through and C is unaffected
			elsif exe_barrelshift_operand = '1' and op_c_data(7 downto 0) = x"00"
			then
				barrelshift_out <= shift_in;
				barrelshift_c <= c;
			
			-- ROR by register = 32, 64, etc.... opb passes through but C is affected
			elsif exe_barrelshift_operand = '1' and op_c_data(4 downto 0) = "00000"
			then
				barrelshift_out <= shift_in;
				barrelshift_c <= shift_in(31);

			-- ROR by literal or register, range 1..31 (if ROR by register, 33 => 1, 34 => 2, etc....)
			else
				barrelshift_out <= shift_in ror shift_positions;
				barrelshift_c <= shift_in(shift_positions - 1);
			end if;

		-- LSL
		when others =>	-- "00"
			-- shift by register > 32 -> overflows, all bits are out
			if exe_barrelshift_operand = '1' and op_c_data(7 downto 0) > x"20"
			then
				barrelshift_out <= (others => '0');
				barrelshift_c <= '0';

			-- shift by register = 32 positions
			elsif exe_barrelshift_operand = '1' and op_c_data(7 downto 0) = x"20"
			then
				barrelshift_out <= (others => '0');
				barrelshift_c <= shift_in(0);

			-- shift by register = 0 or literal = 0, opb passes through and C is unaffected
			elsif shift_positions = 0
			then
				barrelshift_out <= shift_in;
				barrelshift_c <= c;

			-- shift by literal or register, range 1..31
			else
				barrelshift_out <= shift_in sll shift_positions;
				barrelshift_c <= shift_in(32 - shift_positions);
			end if;
		end case;
	end process;
end;

-- optimized architecture expliciting all stages of the barrel shifter
-- (individual shifters by power of 2 bits in series)
-- synthetizes in something way better
architecture optimized of barrelshift is
	signal shift_in : unsigned(31 downto 0);
	signal shift_amnt : unsigned(4 downto 0);
	signal stage1_dout, stage2_dout, stage3_dout, stage4_dout, stage5_dout : unsigned(31 downto 0);
	signal stage1_cout, stage2_cout, stage3_cout, stage4_cout, stage5_cout : std_logic;
begin
	-- Barrelshifter made manually with 5 individual shift stages in series

	-- shift by 1 position
	stage1 : process(shift_in, c, shift_amnt, exe_barrelshift_type) is
	begin
		if shift_amnt(0) = '1'
		then	
			case exe_barrelshift_type is
			when "00" =>		-- LSL #1
				stage1_dout <= shift_in(30 downto 0) & '0';
				stage1_cout <= shift_in(31);
			when "01" =>		-- LSR #1
				stage1_dout <= '0' & shift_in(31 downto 1);
				stage1_cout <= shift_in(0);
			when "10" =>		-- ASR #1
				stage1_dout <= shift_in(31) & shift_in(31 downto 1);
				stage1_cout <= shift_in(0);
			when others =>		-- ROR #1
				stage1_dout <= shift_in(0) & shift_in(31 downto 1);
				stage1_cout <= shift_in(0);
			end case;
		else
			stage1_dout <= shift_in;
			stage1_cout <= c;
		end if;
	end process;

	-- shift by 2 positions
	stage2 : process(stage1_dout, stage1_cout, shift_amnt, exe_barrelshift_type) is
	begin
		if shift_amnt(1) = '1'
		then
			case exe_barrelshift_type is
			when "00" =>		-- LSL #2
				stage2_dout <= stage1_dout(29 downto 0) & "00";
				stage2_cout <= stage1_dout(30);
			when "01" =>		-- LSR #2
				stage2_dout <= "00" & stage1_dout(31 downto 2);
				stage2_cout <= stage1_dout(1);
			when "10" =>		-- ASR #2
				stage2_dout <= (1 downto 0 => stage1_dout(31)) & stage1_dout(31 downto 2);
				stage2_cout <= stage1_dout(1);
			when others =>		-- ROR #2
				stage2_dout <= stage1_dout(1 downto 0) & stage1_dout(31 downto 2);
				stage2_cout <= stage1_dout(1);
			end case;
		else
			stage2_dout <= stage1_dout;
			stage2_cout <= stage1_cout;
		end if;
	end process;

	-- shift by 4 positions
	stage3 : process(stage2_dout, stage2_cout, shift_amnt, exe_barrelshift_type) is
	begin
		if shift_amnt(2) = '1'
		then
			case exe_barrelshift_type is
			when "00" =>		-- LSL #4
				stage3_dout <= stage2_dout(27 downto 0) & "0000";
				stage3_cout <= stage2_dout(28);
			when "01" =>		-- LSR #4
				stage3_dout <= "0000" & stage2_dout(31 downto 4);
				stage3_cout <= stage2_dout(3);
			when "10" =>		-- ASR #4
				stage3_dout <= (3 downto 0 => stage2_dout(31)) & stage2_dout(31 downto 4);
				stage3_cout <= stage2_dout(3);
			when others =>		-- ROR #4
				stage3_dout <= stage2_dout(3 downto 0) & stage2_dout(31 downto 4);
				stage3_cout <= stage2_dout(3);
			end case;
		else
			stage3_dout <= stage2_dout;
			stage3_cout <= stage2_cout;
		end if;
	end process;

	-- shift by 8 positions
	stage4 : process(stage3_dout, stage3_cout, shift_amnt, exe_barrelshift_type) is
	begin
		if shift_amnt(3) = '1'
		then
			case exe_barrelshift_type is
			when "00" =>		-- LSL #8
				stage4_dout <= stage3_dout(23 downto 0) & (7 downto 0 => '0');
				stage4_cout <= stage3_dout(24);
			when "01" =>		-- LSR #8
				stage4_dout <= (7 downto 0 => '0') & stage3_dout(31 downto 8);
				stage4_cout <= stage3_dout(7);
			when "10" =>		-- ASR #8
				stage4_dout <= (7 downto 0 => stage3_dout(31)) & stage3_dout(31 downto 8);
				stage4_cout <= stage3_dout(7);
			when others =>		-- ROR #8
				stage4_dout <= stage3_dout(7 downto 0) & stage3_dout(31 downto 8);
				stage4_cout <= stage3_dout(7);
			end case;
		else
			stage4_dout <= stage3_dout;
			stage4_cout <= stage3_cout;
		end if;
	end process;

	-- shift by 16 positions
	stage5 : process(stage4_dout, stage4_cout, shift_amnt, exe_barrelshift_type) is
	begin
		if shift_amnt(4) = '1'
		then
			case exe_barrelshift_type is
			when "00" =>		-- LSL #16
				stage5_dout <= stage4_dout(15 downto 0) & (15 downto 0 => '0');
				stage5_cout <= stage4_dout(15);
			when "01" =>		-- LSR #16
				stage5_dout <= (15 downto 0 => '0') & stage4_dout(31 downto 16);
				stage5_cout <= stage4_dout(15);
			when "10" =>		-- ASR #16
				stage5_dout <= (15 downto 0 => stage4_dout(31)) & stage4_dout(31 downto 16);
				stage5_cout <= stage4_dout(15);
			when others =>		-- ROR #16
				stage5_dout <= stage4_dout(15 downto 0) & stage4_dout(31 downto 16);
				stage5_cout <= stage4_dout(15);
			end case;
		else
			stage5_dout <= stage4_dout;
			stage5_cout <= stage4_cout;
		end if;
	end process;

	-- Barelshifter control logic
	barrelshift : process(exe_barrelshift_operand, exe_barrelshift_type, op_b_data, op_c_data, exe_opb_is_literal,
						  exe_literal_shift_amnt, exe_literal_data, c, shift_in, stage5_dout, stage5_cout) is
	begin
			-- shift by register (opc)
		if exe_barrelshift_operand = '1'
		then
			shift_amnt <= op_c_data(4 downto 0);
		else
			-- shift by literal value
			shift_amnt <= unsigned(exe_literal_shift_amnt);
		end if;
		
		if exe_opb_is_literal = '1'
		then
			-- sign extend literal value
			shift_in <= (31 downto 24 => exe_literal_data(23)) & unsigned(exe_literal_data);
		else
			shift_in <= op_b_data;
		end if;

		case exe_barrelshift_type is	
		-- LSL
		when "00" =>
			-- shift by register > 32 -> overflows, all bits are out
			if exe_barrelshift_operand = '1' and op_c_data(7 downto 0) > x"20"
			then
				barrelshift_out <= (others => '0');
				barrelshift_c <= '0';

			-- shift by register = 32 positions
			elsif exe_barrelshift_operand = '1' and op_c_data(7 downto 0) = x"20"
			then
				barrelshift_out <= (others => '0');
				barrelshift_c <= shift_in(0);

			-- shift by literal or register, range 0..31
			else
				barrelshift_out <= stage5_dout;
				barrelshift_c <= stage5_cout;
			end if;

		-- LSR
		when "01" =>
			-- shift by register > 32 -> overflows, all bits are out
			if exe_barrelshift_operand = '1' and op_c_data(7 downto 0) > x"20"
			then
				barrelshift_out <= (others => '0');
				barrelshift_c <= '0';

			-- shift by register or literal = 0, 32 positions
			elsif (exe_barrelshift_operand = '1' and op_c_data(7 downto 0) = x"20")
			   or (exe_barrelshift_operand = '0' and exe_literal_shift_amnt = "00000")
			then
				barrelshift_out <= (others => '0');
				barrelshift_c <= shift_in(31);

			-- shift by literal or register, range 0..31
			else
				barrelshift_out <= stage5_dout;
				barrelshift_c <= stage5_cout;
			end if;

		-- ASR
		when "10" =>
			-- shift by register >= 32 or literal = 0, 32 positions -> overflows, all bits are the sign bit
			if (exe_barrelshift_operand = '1' and op_c_data(7 downto 0) >= x"20")
			or (exe_barrelshift_operand = '0' and exe_literal_shift_amnt = "00000")
			then
				barrelshift_out <= (others => shift_in(31));
				barrelshift_c <= shift_in(31);

			-- shift by literal or register, range 0..31
			else			
				barrelshift_out <= stage5_dout;
				barrelshift_c <= stage5_cout;
			end if;

		-- ROR / RRX
		when others =>		-- "11"
			-- RRX - 33 bit rotation with carry
			if exe_barrelshift_operand = '0' and exe_literal_shift_amnt = "00000"
			then
				barrelshift_out <= c & op_b_data(31 downto 1);
				barrelshift_c <= shift_in(0);

			-- ROR by register = 32, 64, etc.... opb passes through but C is affected
			elsif exe_barrelshift_operand = '1' and op_c_data(4 downto 0) = "00000"
			then
				barrelshift_out <= stage5_dout;
				barrelshift_c <= shift_in(31);

			-- ROR by literal or register, range 0..31 (if ROR by register, 33 => 1, 34 => 2, etc....)
			else
				barrelshift_out <= stage5_dout;
				barrelshift_c <= stage5_cout;
			end if;
		end case;
	end process;

end;