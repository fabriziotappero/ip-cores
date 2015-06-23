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
--use	ieee.std_logic_unsigned.all;	
--use ieee.std_logic_arith.all; 		-- for unsigned()

-- use std.textio.all;					-- for file i/o
-- use work.txt_util.all;				-- for string<->other types conversions

entity alu_analog_cadence_tb is
    port    (
			clock_tb			: in	std_logic
            );
end alu_analog_cadence_tb;

architecture behavioural of alu_analog_cadence_tb is
component alu
	port	(
			A			: in	std_logic_vector(7 downto 0);
			B			: in 	std_logic_vector(7 downto 0);
			S			: in 	std_logic_vector(3 downto 0);
			Y			: out	std_logic_vector(7 downto 0);
			reset		: in	std_logic					;
			CLK			: in	std_logic					;
			C			: out	std_logic					;
			V			: out	std_logic					;
			Z			: out	std_logic
			);
end component;

-- ALU test vector record
--	records to store stimulus for verification
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
-- signal			clock_tb			: std_logic						;
-- 
-- -- finished = '1' indicates end of test run
-- 
-- -- testbench clock half period					
-- constant	clock_tb_HALF_PERIOD	: time	:= 10 ns				;
constant	zero			: std_logic_vector(7 downto 0)	
									:= (others => '0');
signal  finished :std_logic;
									
-- procedure to write a string to the screen
-- procedure writestr (s : string) is
-- 	variable lout : line;
-- 	begin
-- 		write(lout, s);
-- 		writeline(output, lout);
-- 	end writestr;
-- 
-- -- procedure to write a character to the screen
-- procedure writechr (s : character) is
-- 	variable lout : line;
-- 	begin
-- 		write(lout, s);
-- 		writeline(output, lout);
-- 	end writechr;
-- 
type out_vector is record
      A           : std_logic_vector(8 downto 1)    ;
      B           : std_logic_vector(8 downto 1)    ;
      S           : std_logic_vector(4 downto 1)    ;
      Y           : std_logic_vector(8 downto 1)    ;
      CLR         : std_logic                       ;
      CLK         : std_logic                       ;
      C           : std_logic                       ;
      V           : std_logic                       ;
      Z           : std_logic                       ;
 end record;
type out_vectors is array (natural range <>) of out_vector;
constant vectors  : out_vectors :=  (
("UUUUUUUU", "UUUUUUUU", "UUUU", "UUUUUUUU", '1', '1', 'U', 'U', 'U'),
("01010101", "00000001", "0000", "00000000", '1', '1', '0', '0', '0'),
("01010101", "00000000", "0000", "00000000", '1', '1', '0', '0', '0'),
("01010101", "00000010", "0000", "00000000", '1', '1', '0', '0', '0'),
("01010101", "00000000", "0000", "00000000", '1', '1', '0', '0', '0'),
("01010101", "00000100", "0000", "00000000", '0', '1', '0', '0', '0'),
("01010101", "00000100", "0000", "00000000", '0', '1', '0', '0', '0'),
("01010101", "00000100", "0000", "00000000", '0', '1', '0', '0', '0'),
("01010101", "00000000", "0000", "01011001", '0', '1', '0', '0', '0'),
("01010101", "00001000", "0000", "01011001", '0', '1', '0', '0', '0'),
("01010101", "00000000", "0000", "01010101", '0', '1', '0', '0', '0'),
("01010101", "00010000", "0000", "01011101", '0', '1', '0', '0', '0'),
("01010101", "00000000", "0000", "01010101", '0', '1', '0', '0', '0'),
("01010101", "00100000", "0000", "01100101", '0', '1', '0', '0', '0'),
("01010101", "00000000", "0000", "01010101", '0', '1', '0', '0', '0'),
("01010101", "01000000", "0000", "01110101", '0', '1', '0', '0', '0'),
("01010101", "00000000", "0000", "01010101", '0', '1', '0', '0', '0'),
("01010101", "10000000", "0000", "10010101", '0', '1', '0', '0', '0'),
("01010101", "00000001", "0010", "01010101", '0', '1', '0', '0', '0'),
("01010101", "00000000", "0010", "11010101", '0', '1', '0', '0', '0'),
("01010101", "00000010", "0010", "01010100", '0', '1', '0', '0', '0'),
("01010101", "00000000", "0010", "01010101", '0', '1', '0', '0', '0'),
("01010101", "00000100", "0010", "01010011", '0', '1', '0', '0', '0'),
("01010101", "00010000", "0010", "01010101", '0', '1', '0', '0', '0'),
("01010101", "01000000", "0010", "01010001", '0', '1', '0', '0', '0'),
("01010101", "00000000", "0010", "01000101", '0', '1', '0', '0', '0'),
("01010101", "10000000", "0010", "00010101", '0', '1', '0', '0', '0'),
("01010101", "00000001", "0100", "01010101", '0', '1', '0', '0', '0'),
("01010101", "00000000", "0100", "11010101", '0', '1', '0', '0', '0'),
("01010101", "00000010", "0101", "10101010", '0', '1', '0', '0', '0'),
("01010101", "00000000", "0101", "01010101", '0', '1', '0', '0', '0'),
("01010101", "00000100", "0100", "00010101", '0', '1', '0', '0', '0'),
("01010101", "00010000", "0101", "01010101", '0', '1', '0', '0', '0'),
("01010101", "01000000", "0010", "01010000", '0', '1', '1', '0', '0'),
("01010101", "00000000", "0010", "01010101", '0', '1', '0', '0', '0'),
("01010101", "10000000", "0010", "00010101", '0', '1', '0', '0', '0'),
("01010101", "10000000", "0010", "01010101", '0', '1', '0', '0', '0'));


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
-- 	clock_stim	: 	process
-- 					begin
-- 						clock_tb	<= '1', '0' after clock_tb_HALF_PERIOD;
-- 						
-- 						if (finished /= '1') then
-- 							wait for 2 * clock_tb_HALF_PERIOD;
-- 						else
-- 							wait; -- end test
-- 						end if;
-- 					end process clock_stim;

    vector_stim_in : process ( clock_tb )
                    variable i  : integer := 0;
                 begin
                    if (clock_tb'event and clock_tb = '1') then
                        if ( i <= vectors'high) then
                            A <= vectors(i).A;
                            B <= vectors(i).B;
                            S <= vectors(i).S;
                            --Y <= vectors(i).Y;
                            CLR <= vectors(i).CLR;
                            CLK <= vectors(i).CLK;
                            --C <= vectors(i).C;
                            --V <= vectors(i).V;
                            --Z <= vectors(i).Z;
                            
                            i := i + 1;
                        else
                            finished <= '1';
                        end if;
                    else
                        CLK <= clock_tb;
                    end if;

                end process vector_stim_in;
end behavioural;

