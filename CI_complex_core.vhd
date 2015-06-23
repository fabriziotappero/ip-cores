-- -------------------------------------------------------
-- CI_complex_core
--
-- Purpose of this unit:
-- Speed up operations such as 
-- - image processing 
-- - .. to be completed
-- - .. to be completed
-- For examples see: no address available 
-- Description:
--
--
-- Dependencies:
-- Version: not finished
-- Date:	24/5/2010
-- Created by Philipp Digeser
-- -------------------------------------------------------
-- The following pipe line settings are chosen for the mega functions
-- Multiplier	6
-- Adder		12
-- Divider		18*
-- -------------------------------------------------------
-- *The divider uses 6 pipe line stage, but since it has a 
-- frequency of just clk/3 it is three times slower.
-- Additionally the pipeline can just be fed each third clock
-- this compromise was done to keep a high operation speed 
-- of more than 300 MHz (STRATIX I), current cores are supposed
-- to be faster
-- -------------------------------------------------------

-- necessary libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY CI_complex_core IS
PORT(
----- general control signals ----------------------------
	signal clk : in std_logic; 							-- CPU's master-input clk <required for multi-cycle>
	signal reset : in std_logic; 						-- CPU's master asynchronous reset <required for multi-cycle>
	signal clk_en: in std_logic; 						-- Clock-qualifier <required for multi-cycle>
	signal start: in std_logic; 						-- True when this instr. issues <required for multi-cycle>
	signal done: out std_logic; 						-- True when instr. completes <required for variable muli-cycle>
	
------ input signals from general purpose registers ------
	signal dataa: in std_logic_vector (31 downto 0); 	-- operand A <always required>
	signal datab: in std_logic_vector (31 downto 0); 	-- operand B <optional>
	signal result : out std_logic_vector (31 downto 0); -- result <always required>
	
------ for choosing multiple instructions ----------------
	signal n: in std_logic_vector (2 downto 0)); 		-- N-field selector <required for extended> 
	
END CI_complex_core;

ARCHITECTURE core OF CI_complex_core IS

	-- for state machine
	type state_type is (s0, s1, s2, s3, s4, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s19, s20, s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32);
	signal state : state_type;
	
	type  clock_type is (clk0, clk1, clk2);
	signal clk_div1 : clock_type;
	
	signal data_A:			std_logic_vector(31 downto 0);
	signal data_B:			std_logic_vector(31 downto 0);
	signal data_C:			std_logic_vector(31 downto 0);
	signal data_D:			std_logic_vector(31 downto 0);
	signal result_s0:		std_logic_vector(31 downto 0);
	
	signal datapath_dataa:		std_logic_vector(31 downto 0);
	signal datapath_datab:		std_logic_vector(31 downto 0);
	signal datapath_result:		std_logic_vector(31 downto 0);
	signal selected_op:			std_logic_vector(1 downto 0);
	signal result_buffer:		std_logic_vector(31 downto 0);	
	signal result_buffer1:		std_logic_vector(31 downto 0);	
	
	constant mult : std_logic_vector := "00";
	constant add_sub : std_logic_vector := "01";
	constant div : std_logic_vector := "10";
	
	signal gl_nan:			std_logic;
	signal gl_overflow:		std_logic;
	signal gl_underflow:	std_logic;
	signal gl_zero:			std_logic;
	signal gl_div_by_zero:	std_logic;
	signal gl_n:			std_logic_vector(2 downto 0);	-- stores the value of n in the first state
	
---------- components -----------------------------------------

	component datapath is
	port
	(
		clk :  IN  STD_LOGIC;
		clk_en :  IN  STD_LOGIC;
		aclr :  IN  STD_LOGIC;
		dataa :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		datab :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		sel :  IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		NaN :  OUT  STD_LOGIC;
		underflow :  OUT  STD_LOGIC;
		zero :  OUT  STD_LOGIC;
		overflow :  OUT  STD_LOGIC;
		division_by_zero :  OUT  STD_LOGIC;
		result :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
	end component;
	
begin


datapath_inst : datapath PORT MAP(
	
		clk => clk,
		clk_en =>clk_en,
		aclr =>reset,
		dataa =>datapath_dataa,
		datab =>datapath_datab,
		sel =>selected_op,
		NaN =>gl_nan,
		underflow =>gl_underflow,
		zero =>gl_zero,
		overflow =>gl_overflow,
		division_by_zero =>gl_div_by_zero,
		result =>datapath_result
	);

------ state machine ----------------------------------------------------
	
	state_machine: process(clk, reset, clk_en) is
	begin
		if (reset='1') then
			state <= s0;
		elsif (falling_edge(clk) and clk_en = '1') then
			-- list of modes (n):
			-- 0: return / get A/C		n = "000" -> ok
			-- 1: division				n = "001" -> ok
			-- 2: multiplication		n = "010" -> ok
			-- 3: addition				n = "011" 
			-- 4: subtraction			n = "100"
			-- 5: inverse 				n = "101"
			-- 6: modulo				n = "110"
			-- 7: return errors			n = "111" -> ok
			case state is
				when s0  =>
					gl_n	<= n;		-- store n for further processes
					if (start = '1') then				
						if (n = "000") then				-- n=0 (load & return)
							datapath_dataa 	<= dataa;		-- load the first data
							datapath_datab 	<= datab;		-- load the second data 
							data_A		<= dataa;		-- and store both data
							data_C		<= datab;
							result		<= result_buffer;	-- return one result
							state 		<= s0;			-- resetstate machine
							done 		<= '1';			-- enable done 
						elsif (n<"111") then
							if (n = "100") then			-- like a subtraction
								datapath_dataa 	<= data_A;
								datapath_datab 	<= (data_C xor "10000000000000000000000000000000");								
							else
								datapath_dataa 	<= dataa;
								datapath_datab 	<= datab;	
							end if;
							data_B		<= dataa;		
							data_D		<= datab;		
							done		<= '0';			
							state 		<= s1;
						elsif (n = "111") then			-- RETURN THE ERRORS (Bit 31..27 of result)
							state 		<= s0;
							done 		<= '1';
							result 		<= (gl_nan, gl_overflow, gl_underflow, gl_zero, gl_div_by_zero, others => '0');
						else							-- this state does not exist
							state		<= s0;
							done 		<= '1';			
						end if;	
					end if;
				when s1  =>
					state 		<= s2;
					if (gl_n = "100") then
						datapath_dataa  <= data_B; -- sub
						datapath_datab	<= (data_D xor "10000000000000000000000000000000");	
					else
						datapath_dataa  <= data_B; -- mult
						datapath_datab	<= data_C;			
					end if;
				when s2  =>
					state 		<= s3;
					datapath_dataa  <= data_A; --mult
					datapath_datab	<= data_D;
				when s3  =>
					state 		<= s4;
					datapath_dataa  <= data_C; --mult
					datapath_datab	<= data_C;
				when s4  =>
					state 		<= s6;
					datapath_dataa  <= data_D; --mult
					datapath_datab	<= data_D;	
					selected_op <= mult;
				when s6  =>
					state 		<= s7;	
					datapath_dataa 	<= datapath_result;	-- AC addition 
				when s7  =>
					state 		<= s8;
					if (gl_n = "001") then
						datapath_datab 	<= datapath_result;	-- BD addition -- first addition starts
					elsif (gl_n = "010") then
						datapath_datab 	<= (datapath_result xor "10000000000000000000000000000000");
					end if;
				when s8  => 
					state 		<= s9;
					if (gl_n = "001") then
						datapath_dataa 	<= (datapath_result xor "10000000000000000000000000000000");	-- -BC
					elsif (gl_n = "010") then
						datapath_dataa 	<= datapath_result; -- for multiplication we just need BC
					end if;
				when s9  =>
					state 		<= s10;
					datapath_datab <= datapath_result;	-- AD
				when s10  =>
					state 		<= s11;
					if (gl_n = "001") then --add
						datapath_dataa 	<= datapath_result;	-- CC
					end if;
				when s11 =>
					if (gl_n = "001") then --add
						datapath_datab 	<= datapath_result;	-- DD
					end if;
					if (gl_n = "011") then
						selected_op <= add_sub;
					end if;
					state 		<= s12;
				when s12 =>
					if (gl_n = "011") then
						result_buffer1 		<= datapath_result; -- real part from addition
						state		<= s13;				-- OPERATION ADDITION FINISHED  ->> OK
					elsif (gl_n = "100") then
						selected_op <= add_sub;
						state 		<= s13;
					else
						state 		<= s13;
					end if;
				when s13 =>
					if (gl_n = "011") then
						done 		<= '1';
						state 		<= s0;
						result 		<= result_buffer1;
						result_buffer 		<= datapath_result; -- imag result from addition
					elsif (gl_n = "100") then
						result_buffer1 		<= datapath_result; -- real result from subtraction
						state 		<= s14;			-- OPERATION SUBTRACTION FINISHED  ->> OK
					else
						state 		<= s14;
					end if;
				when s14 =>
					if (gl_n = "100") then
						state 		<= s0; -- subtraction finished
						result_buffer 		<= datapath_result; -- imag result from subtraction
						result		<= result_buffer1;
						done 		<= '1';
					else
						state 		<= s15;
					end if;
				when s15 =>
					state 		<= s16;
				when s16 =>
					state 		<= s17;
				when s17 =>
					state 		<= s19;
					selected_op <= add_sub;
				when s19 =>
					state 		<= s20;
				when s20 =>
					if (gl_n = "010") then
						result_buffer1	<= datapath_result; -- real part of multiplication ->> OK
					elsif (gl_n = "001") then
						datapath_dataa 	<= datapath_result; -- AC+BD
					end if;
					state 			<= s21;
				when s21 =>
					state 		<= s22;
				when s22 =>
					if (gl_n = "010") then
						state 	<= s0;
						result <= result_buffer1;
						result_buffer 	<= datapath_result;
						done <= '1';
					else
						result_buffer <= datapath_result;
						state 		<= s23;	-- AD-BC
					end if;
				when s23 =>
					state 		<= s24;
					result 			<= datapath_result; -- for testing	
				when s24 =>
					datapath_datab 	<= datapath_result;	--CC+DD
					state 		<= s25;
				when s25 =>
					state 		<= s26;
					selected_op <= div;
				when s26 =>
					datapath_dataa  <= (result_buffer xor "10000000000000000000000000000000"); --AD-BC
					state 		<= s27;
				when s27 =>
					state 		<= s28;
				when s28 =>
					state 		<= s29;
				when s29 =>
					state 		<= s30;
				when s30 =>	
					state 		<= s31;
					result_buffer1		<= datapath_result;
				when s31 =>	
					state 		<= s32;
				when s32 =>
					state		<= s0;				
					result_buffer		<= datapath_result;
					result		<= result_buffer1;	
					done 		<= '1';					
			end case;
		end if;
	end process state_machine;

end core;
