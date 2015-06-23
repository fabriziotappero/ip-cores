--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Module   - Introduction to VLSI Design [03ELD005]
-- Lecturer - Dr V. M. Dwyer
-- Course   - MEng Electronic and Electrical Engineering
-- Year     - Part D
-- Student  - Sahrfili Leonous Matturi A028459 [elslm]
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Final coursework 2004
-- 
-- Details: 	Design and Layout of an ALU
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--	Description 	: 	ALU testbench
--  Entity			: 	alu_tb
--	Architecture	: 	behavioural
--  Created on  	: 	07/03/2004

library	ieee;

use ieee.std_logic_1164.all;
use	ieee.std_logic_unsigned.all;	
use ieee.std_logic_arith.all; 		-- for unsigned()

use std.textio.all;					-- for file i/o
use work.txt_util.all;				-- for string<->other types conversions

entity alu_tb is
end alu_tb;

architecture behavioural of alu_tb is
component alu
	port	(
			A			: in	std_logic_vector(7 downto 0);
			B			: in 	std_logic_vector(7 downto 0);
			S			: in 	std_logic_vector(3 downto 0);
			Y			: out	std_logic_vector(7 downto 0);
			CLR		: in	std_logic					;
			CLK			: in	std_logic					;
			C			: out	std_logic					;
			V			: out	std_logic					;
			Z			: out	std_logic
			);
end component;

-- ALU test vector record
type test_vector is record
	A			: string(8 downto 1)	; -- ALU input operand 1
	B			: string(8 downto 1)	; -- ALU input operand 2
	S			: string(3 downto 1)	; -- ALU input opcode
end record test_vector;

--	records to store stimulus for verification
signal	this_record, next_record	: test_vector;
-- ALU access signals
signal			A			: std_logic_vector(7 downto 0)	;
signal			B			: std_logic_vector(7 downto 0)	;
signal			S			: std_logic_vector(3 downto 0)	;
signal			Y			: std_logic_vector(7 downto 0)	;
signal			CLR			: std_logic						;
signal			CLK			: std_logic						;
signal			C			: std_logic						;
signal			V			: std_logic						;
signal			Z			: std_logic						;

-- finished = '1' indicates end of test run
signal		finished		: std_logic;

-- used to synchronise verification with stimulus
signal		started			:	boolean := false;

-- testbench clock half period					
constant	CLK_HALF_PERIOD	: time	:= 10 ns				;
constant	zero			: std_logic_vector(7 downto 0)	
									:= (others => '0');
									
-- procedure to write a string to the screen
procedure writestr (s : string) is
	variable lout : line;
	begin
		write(lout, s);
		writeline(output, lout);
	end writestr;

-- procedure to write a character to the screen
procedure writechr (s : character) is
	variable lout : line;
	begin
		write(lout, s);
		writeline(output, lout);
	end writechr;

begin

	-- instantiate ALU
	alu_inst0	:	alu
		port map	(
					A			,
					B			,
					S			,
					Y			,
					CLR			,
					CLK			,
					C			,
					V			,
					Z
					);

	-- apply clock stimulus
	clock_stim	: 	process
					begin
						CLK	<= '1', '0' after CLK_HALF_PERIOD;
						
						if (finished /= '1') then
							wait for 2 * CLK_HALF_PERIOD;
						else
							wait; -- end test
						end if;
					end process clock_stim;

	apply_test_vectors
				:	process
					-- uncomment this line for VHDL '87 file i/o
					--file		infile	:	text is in "alu_test.txt";
					file		infile	:	text open read_mode is "alu_test.txt";
					variable	buff	:	line;
					variable	in_vec	:	test_vector;
					variable	aa, bb, yy 
										: string(A'low  + 1 to A'high + 1);
					variable	ss, last_ss
										: string(1 to 3);
					variable	cc, vv, zz, clrc, space
										: character;
					variable	count	: integer;
					
					-- function to return the opcode as a std_logic_vector
					-- from the given string
					function	string2opcode(s: string) return std_logic_vector is
						variable	opcode : std_logic_vector(3 downto 0);
						begin
							if 		(s = "add") then
								opcode := "0000";
							elsif 	(s = "inc") then
								opcode := "0001";
							elsif 	(s = "sub") then
								opcode := "0010";
							elsif 	(s = "cmp") then
								opcode := "0011";
							elsif 	(s = "and") then
								opcode := "1100";
							elsif 	(s = "or ") then
								opcode := "1101";
							elsif 	(s = "xor") then
								opcode := "1110";
							elsif 	(s = "cpl") then
								opcode := "1111";
							elsif 	(s = "asl") then
								opcode := "0100";
							elsif 	(s = "asr") then
								opcode := "0101";
							elsif 	(s = "clr") then
								opcode := "0110";
							end if;
							return opcode;
						end string2opcode;
					begin
						finished <= '0';
						count	:= 0;
						CLR	<= '1';
						started <= false;
						while ( not endfile(infile) ) loop
							count := count + 1;
							-- verify outputs are as expected
							readline 	(infile, buff);
							if (count = 1) then
								readline 	(infile, buff); -- first read was the header
								writestr("**** Start of Test ****");
							end if;
							read		(buff, aa);
							read		(buff, space);
							
							read		(buff, bb);
							read		(buff, space);
							
							read		(buff, ss);
							read		(buff, space);
							
							read		(buff, clrc);
							
							-- wait for falling edge of clk
							wait until (CLK'event and CLK = '0');
							-- wait for half of half a period
							wait for (CLK_HALF_PERIOD / 2);
							
							-- apply stimulus to inputs
							A	<=	to_std_logic_vector(aa);
							B	<=	to_std_logic_vector(bb);
							S	<=	string2opcode(ss);
							CLR	<=	to_std_logic(clrc);
							
							-- store stimulus for use when verifying outputs
							if (last_ss = "clr") then
								next_record.A	<= str(zero);
								next_record.B	<= str(zero);
							else
								next_record.A	<= aa;
								next_record.B	<= bb;
							end if;
							next_record.S	<= ss;
							last_ss			:= ss;
							-- wait for rising edge of clock when data 
							-- should be loaded from registers into ALU
							wait until clk'event and clk = '1';
							
							-- set local 'started' flag so verification can
							-- start
							-- grace period of 2 clock cycles for ALU to read
							-- first set of data
							if (clr = '0' and started = false) then
								wait until clk'event and clk = '1';						
								wait until clk'event and clk = '1';
								started <= true;
							end if;
						end loop;
						
						-- end test
						finished <= '1';
						wait;
					end process apply_test_vectors;

	verify_test	: 	process
					variable	result	: std_logic_vector(7 downto 0);
					variable	op1, op2: std_logic_vector(7 downto 0);
					begin
						-- await positive clock edge
						wait until clk'event and clk = '1';
						-- wait a little more after results appear
						wait for (CLK_HALF_PERIOD/2);
						
						-- get expected record
						this_record <= next_record;

						if (started = true and clr = '0') then
							-- convert string operands from this_record
							-- into std_logic_vectors
							op1	:= to_std_logic_vector(this_record.A);
							op2	:= to_std_logic_vector(this_record.B);

							-- depending on opcode command string...perform
							-- high level equivalent of ALU operation and store
							-- in 'result'
							if 		(this_record.S = "add") then
								result := op1 + op2;
							elsif 	(this_record.S = "inc") then
								result := op1 + 1;
							elsif 	(this_record.S = "sub") then
								result := op1 - op2;
							elsif 	(this_record.S = "cmp") then
								result := y;
							elsif 	(this_record.S = "and") then
								result := op1 and op2;
							elsif 	(this_record.S = "or ") then
								result := op1 or op2;
							elsif 	(this_record.S = "xor") then
								result := op1 xor op2;
							elsif 	(this_record.S = "cpl") then
								result := not op2;
							
							-- VHDL functions sla and sra require left operand = bit_vector
							-- and right operand = integer
							-- bv2slv [see above] converts bit_vector to std_logic_vector
							elsif 	(this_record.S = "asl") then
								result := bv2slv(to_bitvector(op1) sla conv_integer(unsigned(op2 and x"07")));
								-- Also, these functions fill shifted bit positions with 1s not 0s
								-- so this has to be taken care of
								if (conv_integer(unsigned(op2 and x"07")) > 0) then
									result(conv_integer(unsigned(op2 and x"07")) - 1 downto 0) := (others => '0');
								end if;
							elsif 	(this_record.S = "asr") then
								result := bv2slv(to_bitvector(op1) sra conv_integer(unsigned(op2 and x"07")));
								if (conv_integer(unsigned(op2 and x"07")) > 1) then
									result(result'high - 1  downto result'high - conv_integer(unsigned(op2 and x"07")) + 1 ) := (others => '0');
								end if;
							elsif 	(this_record.S = "clr") then
								result := y;
							end if;
								
							writestr(hstr(to_std_logic_vector(this_record.A)) & " " & this_record.S & " " & hstr(to_std_logic_vector(this_record.B)) & " = " & hstr(Y) & " expected " & hstr(result));
							assert Y = result
								report "Output Y is wrong"
								severity warning;
							--assert C = to_std_logic(cc)
							--	report "Output C is wrong"
							--	severity warning;
							--assert V = to_std_logic(vv)
							--	report "Output V is wrong"
							--	severity warning;
							--assert Z = to_std_logic(zz)
							--	report "Output Z is wrong"
							--	severity warning;
						end if;
					end process verify_test;

    vector_stim_out : process ( A			,
                                B			,
                                S			,
                                Y			,
                                CLR			,
                                CLK			,
                                C			,
                                V			,
                                Z
                                )
--                 type out_vector is record
--                      A           : string(8 downto 0)   ;
--                      B           : string(8 downto 0)   ;
--                      S           : string(4 downto 0)   ;
--                      Y           : string(8 downto 0)   ;
--                      CLR         : string(1 downto 1)   ;
--                      CLK         : string(1 downto 1)   ;
--                      C           : string(1 downto 1)   ;
--                      V           : string(1 downto 1)   ;
--                      Z           : string(1 downto 1)   ;
--                 end record;
					file		infile	:	text open write_mode is "alu_test.out";
                    variable    buff    :   line    ;  
                    constant    space   :   string := " ";
                begin
                    if (CLK'event) then
                        write (buff, str(A));
                        write (buff, space);
                        write (buff, str(B));
                        write (buff, space);
                        write (buff, str(S));
                        write (buff, space);
                        write (buff, str(Y));
                        write (buff, space);
                        write (buff, str(CLR));
                        write (buff, space);
                        write (buff, str(CLK));
                        write (buff, space);
                        write (buff, str(C));
                        write (buff, space);
                        write (buff, str(V));
                        write (buff, space);
                        write (buff, str(Z));
                        writeline (infile, buff);
                    end if;

                end process vector_stim_out;
end behavioural;

