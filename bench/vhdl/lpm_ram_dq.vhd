--------------------------------------------------------------------------
--   This VHDL file was developed by Altera Corporation.  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Altera Corporation does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--
--------------------------------------------------------------------------
-- LPM Synthesizable Models (Support string type generic)
--------------------------------------------------------------------------
-- Version 2.0 (lpm 220)      Date 01/04/00
--
-- 1. Fixed LPM_RAM_DQ, LPM_RAM_DP, LPM_RAM_IO and LPM_ROM to correctly
--    read in values from LPM_FILE (*.hex) when the DATA width is greater
--    than 16 bits.
-- 2. Explicit sign conversions are added to standard logic vector
--    comparisons in LPM_RAM_DQ, LPM_RAM_DP, LPM_RAM_IO, LPM_ROM, and
--    LPM_COMPARE.
-- 3. LPM_FIFO_DC is rewritten to have correct outputs.
-- 4. LPM_FIFO outputs zeros when nothing has been read from it, and
--    outputs LPM_NUMWORDS mod exp(2, LPM_WIDTHU) when it is full.
-- 5. Fixed LPM_DIVIDE to divide correctly.
--------------------------------------------------------------------------
-- Version 1.9 (lpm 220)      Date 11/30/99
--
-- 1. Fixed UNUSED file not found problem and initialization problem
--    with LPM_RAM_DP, LPM_RAM_DQ, and LPM_RAM_IO.
-- 2. Fixed LPM_MULT when SUM port is not used.
-- 3. Fixed LPM_FIFO_DC to enable read when rdclock and wrclock rise
--    at the same time.
-- 4. Fixed LPM_COUNTER comparison problem when signed library is loaded
--    and counter is incrementing.
-- 5. Got rid of "Illegal Character" error message at time = 0 ns when
--    simulating LPM_COUNTER.
--------------------------------------------------------------------------
-- Version 1.8 (lpm 220)      Date 10/25/99
--
-- 1. Some LPM_PVALUE implementations were missing, and now implemented.
-- 2. Fixed LPM_COUNTER to count correctly without conversion overflow,
--    that is, when LPM_MODULUS = 2 ** LPM_WIDTH.
-- 3. Fixed LPM_RAM_DP sync process sensitivity list to detect wraddress
--    changes.
--------------------------------------------------------------------------
-- Version 1.7 (lpm 220)      Date 07/13/99
--
-- Changed LPM_RAM_IO so that it can be used to simulate both MP2 and
--   Quartus behaviour and LPM220-compliant behaviour.
--------------------------------------------------------------------------
-- Version 1.6 (lpm 220)      Date 06/15/99
--
-- 1. Fixed LPM_ADD_SUB sign extension problem and subtraction bug.
-- 2. Fixed LPM_COUNTER to use LPM_MODULUS value.
-- 3. Added CIN and COUT port, and discarded EQ port in LPM_COUNTER to
--    comply with the specfication.
-- 4. Included LPM_RAM_DP, LPM_RAM_DQ, LPM_RAM_IO, LPM_ROM, LPM_FIFO, and
--    LPM_FIFO_DC; they are all initialized to 0's.
--------------------------------------------------------------------------
-- Version 1.5 (lpm 220)      Date 05/10/99
--
-- Changed LPM_MODULUS from string type to integer.
--------------------------------------------------------------------------
-- Version 1.4 (lpm 220)      Date 02/05/99
-- 
-- 1. Added LPM_DIVIDE module.
-- 2. Added CLKEN port to LPM_MUX, LPM_DECODE, LPM_ADD_SUB, LPM_MULT
--    and LPM_COMPARE
-- 3. Replaced the constants holding string with the actual string.
--------------------------------------------------------------------------
-- Version 1.3                Date 07/30/96
--
-- Modification History
--
-- 1. Changed the DEFAULT value to "UNUSED" for LPM_SVALUE, LPM_AVALUE,
-- LPM_MODULUS, and LPM_NUMWORDS, LPM_HINT,LPM_STRENGTH, LPM_DIRECTION,
-- and LPM_PVALUE
--
-- 2. Added the two dimentional port components (AND, OR, XOR, and MUX).
--------------------------------------------------------------------------
-- Excluded Functions:
--
--   LPM_FSM and LPM_TTABLE
--
--------------------------------------------------------------------------
-- Assumptions:
--
-- 1. All ports and signal types are std_logic or std_logic_vector
--    from IEEE 1164 package.
-- 2. Synopsys std_logic_arith, std_logic_unsigned, and std_logic_signed
--    package are assumed to be accessible from IEEE library.
-- 3. lpm_component_package must be accessible from library work.
-- 4. The default value of LPM_SVALUE, LPM_AVALUE, LPM_MODULUS, LPM_HINT,
--    LPM_NUMWORDS, LPM_STRENGTH, LPM_DIRECTION, and LPM_PVALUE is
--    string "UNUSED".
--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 
--use IEEE.std_logic_unsigned.all;
use std.textio.all;

entity LPM_RAM_DQ is
	generic (LPM_WIDTH : positive;
			 LPM_WIDTHAD : positive;
			 LPM_NUMWORDS : natural := 0;
			 LPM_INDATA : string := "REGISTERED";
			 LPM_ADDRESS_CONTROL: string := "REGISTERED";
			 LPM_OUTDATA : string := "REGISTERED";
			 LPM_FILE : string := "UNUSED";
			 LPM_TYPE : string := "LPM_RAM_DQ";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  ADDRESS : in std_logic_vector(LPM_WIDTHAD-1 downto 0);
		  INCLOCK : in std_logic := '0';
		  OUTCLOCK : in std_logic := '0';
		  WE : in std_logic;
		  Q : out std_logic_vector(LPM_WIDTH-1 downto 0));

	function int_to_str( value : integer ) return string is
	variable ivalue,index : integer;
	variable digit : integer;
	variable line_no: string(8 downto 1) := "        ";  
	begin
		ivalue := value;
		index := 1;
		while (ivalue > 0) loop
			digit := ivalue MOD 10;
			ivalue := ivalue/10;
			case digit is
				when 0 =>
					line_no(index) := '0';
				when 1 =>
					line_no(index) := '1';
				when 2 =>
					line_no(index) := '2';
				when 3 =>
					line_no(index) := '3';
				when 4 =>
					line_no(index) := '4';
				when 5 =>
					line_no(index) := '5';
				when 6 =>
					line_no(index) := '6';
				when 7 =>
					line_no(index) := '7';
				when 8 =>
					line_no(index) := '8';
				when 9 =>
					line_no(index) := '9';
				when others =>
					ASSERT FALSE
					REPORT "Illegal number!"
					SEVERITY ERROR;
			end case;
			index := index + 1;
		end loop;
		return line_no;
	end;

	function hex_str_to_int( str : string ) return integer is
	variable len : integer := str'length;
	variable ivalue : integer := 0;
	variable digit : integer;
	begin
		for i in len downto 1 loop
			case str(i) is
				when '0' =>
					digit := 0;
				when '1' =>
					digit := 1;
				when '2' =>
					digit := 2;
				when '3' =>
					digit := 3;
				when '4' =>
					digit := 4;
				when '5' =>
					digit := 5;
				when '6' =>
					digit := 6;
				when '7' =>
					digit := 7;
				when '8' =>
					digit := 8;
				when '9' =>
					digit := 9;
				when 'A' =>
					digit := 10;
				when 'a' =>
					digit := 10;
				when 'B' =>
					digit := 11;
				when 'b' =>
					digit := 11;
				when 'C' =>
					digit := 12;
				when 'c' =>
					digit := 12;
				when 'D' =>
					digit := 13;
				when 'd' =>
					digit := 13;
				when 'E' =>
					digit := 14;
				when 'e' =>
					digit := 14;
				when 'F' =>
					digit := 15;
				when 'f' =>
					digit := 15;
				when others =>
					ASSERT FALSE
					REPORT "Illegal character "&  str(i) & "in Intel Hex File! "
					SEVERITY ERROR;
			end case;
			ivalue := ivalue * 16 + digit;
		end loop;
		return ivalue;
	end;

	procedure Shrink_line(L : inout LINE; pos : in integer) is
	subtype nstring is string(1 to pos);
	variable stmp : nstring;
	begin
		if pos >= 1 then
			read(l, stmp);
		end if;
	end;

end LPM_RAM_DQ;

architecture LPM_SYN of lpm_ram_dq is

--type lpm_memory is array(lpm_numwords-1 downto 0) of std_logic_vector(lpm_width-1 downto 0);
type lpm_memory is array(integer range (2**lpm_widthad)-1 downto 0) of std_logic_vector(lpm_width-1 downto 0);

signal data_tmp, data_reg : std_logic_vector(lpm_width-1 downto 0);
signal q_tmp, q_reg : std_logic_vector(lpm_width-1 downto 0) := (others => '0');
signal address_tmp, address_reg : std_logic_vector(lpm_widthad-1 downto 0);
signal we_tmp, we_reg : std_logic;

begin

	sync: process(data, data_reg, address, address_reg,
				  we, we_reg, q_tmp, q_reg)
	begin
		if (lpm_address_control = "REGISTERED") then
			address_tmp <= address_reg;
			we_tmp <= we_reg;
		else
			address_tmp <= address;
			we_tmp <= we;
		end if;
		if (lpm_indata = "REGISTERED") then
			data_tmp <= data_reg;
		else
			data_tmp <= data;
		end if;
		if (lpm_outdata = "REGISTERED") then
			q <= q_reg;
		else
			q <= q_tmp;
		end if;
	end process;

	input_reg: process (inclock)
	begin
		if inclock'event and inclock = '1' then
			data_reg <= data;
			address_reg <= address;
			we_reg <= we;
		end if;
	end process;

	output_reg: process (outclock)
	begin
		if outclock'event and outclock = '1' then
			q_reg <= q_tmp;
		end if;
	end process;

	memory: process(data_tmp, we_tmp, address_tmp)
	variable mem_data : lpm_memory;
	variable mem_data_tmp : integer := 0;
	variable mem_init: boolean := false;
	variable i,j,k,lineno: integer := 0;
	variable buf: line ;
	variable booval: boolean ;
	FILE unused_file: TEXT IS OUT "UNUSED";
	FILE mem_data_file: TEXT IS IN LPM_FILE;
	variable base, byte, rec_type, datain, addr, checksum: string(2 downto 1);
	variable startadd: string(4 downto 1);
	variable ibase: integer := 0;
	variable ibyte: integer := 0;
	variable istartadd: integer := 0;
	variable check_sum_vec, check_sum_vec_tmp: unsigned(7 downto 0);
	begin
		-- INITIALIZE --
		if NOT(mem_init) then
			-- INITIALIZE TO 0 --
			for i in mem_data'LOW to mem_data'HIGH loop
				mem_data(i) := (OTHERS => '0');
			end loop;

			if (LPM_FILE = "UNUSED") then
				ASSERT FALSE
				REPORT "Initialization file not found!"
				SEVERITY WARNING;
			else
				WHILE NOT ENDFILE(mem_data_file) loop
					booval := true;
					READLINE(mem_data_file, buf);
					lineno := lineno + 1;
					check_sum_vec := (OTHERS => '0');
					if (buf(buf'LOW) = ':') then
						i := 1;
						shrink_line(buf, i);
						READ(L=>buf, VALUE=>byte, good=>booval);
						if not (booval) then
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format!"
							SEVERITY ERROR;
						end if;
						ibyte := hex_str_to_int(byte);
						check_sum_vec := unsigned(check_sum_vec) + to_unsigned(ibyte, check_sum_vec'length);
						READ(L=>buf, VALUE=>startadd, good=>booval);
						if not (booval) then
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
							SEVERITY ERROR;
						end if;
						istartadd := hex_str_to_int(startadd);
						addr(2) := startadd(4);
						addr(1) := startadd(3);
						check_sum_vec := unsigned(check_sum_vec) + to_unsigned(hex_str_to_int(addr), check_sum_vec'length);
						addr(2) := startadd(2);
						addr(1) := startadd(1);
						check_sum_vec := unsigned(check_sum_vec) + to_unsigned(hex_str_to_int(addr), check_sum_vec'length);
						READ(L=>buf, VALUE=>rec_type, good=>booval);
						if not (booval) then
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
							SEVERITY ERROR;
						end if;
						check_sum_vec := unsigned(check_sum_vec) + to_unsigned(hex_str_to_int(rec_type), check_sum_vec'length);
					else
						ASSERT FALSE
						REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
						SEVERITY ERROR;
					end if;
					case rec_type is
						when "00"=>     -- Data record
							i := 0;
							k := lpm_width / 8;
							if ((lpm_width MOD 8) /= 0) then
								k := k + 1; 
							end if;
							-- k = no. of bytes per CAM entry.
							while (i < ibyte) loop
								mem_data_tmp := 0;
								for j in 1 to k loop
									READ(L=>buf, VALUE=>datain,good=>booval); -- read in data a byte (2 hex chars) at a time.
									if not (booval) then
										ASSERT FALSE
										REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
										SEVERITY ERROR;
									end if;
									check_sum_vec := unsigned(check_sum_vec) + to_unsigned(hex_str_to_int(datain), check_sum_vec'length);
									mem_data_tmp := mem_data_tmp * 256 + hex_str_to_int(datain);
								end loop;
								i := i + k;
								mem_data(ibase + istartadd) := STD_LOGIC_VECTOR(to_unsigned(mem_data_tmp, lpm_width));
								istartadd := istartadd + 1;
							end loop;
						when "01"=>
							exit;
						when "02"=>
							ibase := 0;
							if (ibyte /= 2) then
								ASSERT FALSE
								REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format for record type 02! "
								SEVERITY ERROR;
							end if;
							for i in 0 to (ibyte-1) loop
								READ(L=>buf, VALUE=>base,good=>booval);
								ibase := ibase * 256 + hex_str_to_int(base);
								if not (booval) then
									ASSERT FALSE
									REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
									SEVERITY ERROR;
								end if;
								check_sum_vec := unsigned(check_sum_vec) + to_unsigned(hex_str_to_int(base), check_sum_vec'length);
							end loop;
							ibase := ibase * 16;
						when OTHERS =>
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal record type in Intel Hex File! "
							SEVERITY ERROR;
					end case;
					READ(L=>buf, VALUE=>checksum,good=>booval);
					if not (booval) then
						ASSERT FALSE
						REPORT "[Line "& int_to_str(lineno) & "]:Checksum is missing! "
						SEVERITY ERROR;
					end if;

					check_sum_vec := unsigned(not (check_sum_vec)) + 1 ;
					check_sum_vec_tmp := to_unsigned(hex_str_to_int(checksum), check_sum_vec_tmp'length);

					if (unsigned(check_sum_vec) /= unsigned(check_sum_vec_tmp)) then
						ASSERT FALSE
						REPORT "[Line "& int_to_str(lineno) & "]:Incorrect checksum!"
						SEVERITY ERROR;
					end if;
				end loop;
			end if;
			mem_init := TRUE;
		end if;

		-- MEMORY FUNCTION --
		if we_tmp = '1' then
			mem_data (to_integer(unsigned(address_tmp))) := data_tmp;
		end if;
		q_tmp <= mem_data(to_integer(unsigned(address_tmp)));
	end process;

end LPM_SYN;


-- pragma translate_off
configuration lpm_ram_dq_c0 of lpm_ram_dq is

  for lpm_syn
  end for;

end lpm_ram_dq_c0;
-- pragma translate_on
