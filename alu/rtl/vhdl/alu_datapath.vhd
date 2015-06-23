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

--	Description 	: 	ALU datapath description
--  Entity			: 	alu_datapath
--	Architecture	: 	behavioural
--  Created on  	: 	07/03/2004

library	ieee;

use ieee.std_logic_1164.all;
use	ieee.std_logic_unsigned.all;

entity alu_datapath is
	generic	(
			ALU_WIDTH : integer := 8
			);
	port	(
			A			: in	std_logic_vector(ALU_WIDTH - 1 downto 0);
			B			: in	std_logic_vector(ALU_WIDTH - 1 downto 0);
			Y			: out	std_logic_vector(ALU_WIDTH - 1 downto 0);

			add_AB		: in	std_logic;	-- ALU control commands
			sub_AB		: in	std_logic;
			inc_A		: in	std_logic;
			inc_B		: in	std_logic;
			dec_A		: in	std_logic;
			dec_B		: in	std_logic;
			cmp_AB		: in	std_logic;
			and_AB		: in	std_logic;
			or_AB		: in	std_logic;
			xor_AB		: in	std_logic;
			cpl_B		: in	std_logic;
			cpl_A		: in	std_logic;
			sl_AB		: in	std_logic;
			sr_AB		: in	std_logic;
			clr			: in	std_logic; 	-- soft reset! via opcode
			
			clr_Z		: in	std_logic;
			clr_V		: in	std_logic;
			clr_C		: in	std_logic;

			C			: out	std_logic;	-- carry flag
			V			: out	std_logic;  -- overflow flag
			Z			: out	std_logic;	-- ALU result = 0
			
			load_inputs	: in	std_logic;
			load_outputs: in	std_logic;
			
			reset		: in	std_logic; 	-- hard reset!
			
			clk			: in	std_logic	-- clk signal
			);
end alu_datapath;

architecture behavioural of alu_datapath is
component alu_adder
	generic	(
			adder_width	: integer := ALU_WIDTH
			);
	port 	(
			x			: in	std_logic_vector(ALU_WIDTH - 1 downto 0);
			y			: in	std_logic_vector(ALU_WIDTH - 1 downto 0);
			carry_in	: in	std_logic								;
			ORsel		: in	std_logic								;
			XORsel		: in	std_logic								;
			carry_out	: out	std_logic_vector(ALU_WIDTH	   downto 0);
			xor_result	: out	std_logic_vector(ALU_WIDTH - 1 downto 0);
			or_result	: out	std_logic_vector(ALU_WIDTH - 1 downto 0);
			and_result	: out	std_logic_vector(ALU_WIDTH - 1 downto 0);
			z			: out	std_logic_vector(ALU_WIDTH - 1 downto 0)
			);
end component;
component mux8to1_1bit is
	PORT	(
			sel			: in		std_logic_vector(2 downto 0);
			din0		: in		std_logic					;
			din1		: in		std_logic					;
			din2		: in		std_logic					;
			din3		: in		std_logic					;
			din4		: in		std_logic					;
			din5		: in		std_logic					;
			din6		: in		std_logic					;
			din7		: in		std_logic					;
			dout		: out 		std_logic
			);
end component;
component 	alu_barrel_shifter
	port 	(
			x			: in		std_logic_vector(7 downto 0);
			y			: in		std_logic_vector(7 downto 0);
			z			: out		std_logic_vector(7 downto 0);
			c			: out		std_logic					;
			direction	: in		std_logic
			);
end component;
component mux2to1_1bit is
	port	(
			sel			: in		std_logic					;
			din0		: in		std_logic					;
			din1		: in		std_logic					;
			dout		: out 		std_logic
			);
end component;

signal	adder_in_a	,
		adder_in_b	,
		adder_out		: std_logic_vector(ALU_WIDTH - 1 downto 0)	;
signal	shifter_inA	,
		shifter_inB	,
		shifter_out		: std_logic_vector(ALU_WIDTH - 1 downto 0)	;
signal	shifter_carry,
		shifter_direction
						: std_logic									;
signal	carry_in	,
		carry		,
		adderORsel	,
		adderXORsel		: std_logic									;
signal	carry_out		: std_logic_vector(ALU_WIDTH 	 downto 0)	;
signal	Areg		,
		Breg		,
		Yreg		,
		B_path		,
		alu_out			: std_logic_vector(ALU_WIDTH - 1 downto 0)	;
signal	Zreg,
		Creg,
		Vreg			: std_logic									;
		
signal	AandB,
		AxorB,
		AorB			: std_logic_vector(ALU_WIDTH - 1 downto 0)	;
signal	logic1,
		logic0			: std_logic_vector(ALU_WIDTH - 1 downto 0)	;
begin

	logic1		<= (others => '1')	;
	logic0		<= (others => '0')	;

	-- assign registers to outputs
	Y		<= Yreg;
	Z		<= Zreg;
	C		<= Creg;
	V		<= Vreg;
	
	-- inputs to adder
	adder_in_a	<=	(others => '0') when (cpl_B = '1') else
					Areg ;
	adder_in_b	<=	Breg 			when 
						(sub_AB = '0' and inc_A = '0' and cpl_B = '0') else
					not Breg 		when 
						((sub_AB = '1' and inc_A = '0') or cpl_B = '1') else
					(others => '0') when 
						(sub_AB = '0' and inc_A = '1' and cpl_B = '0');
	
	-- carry_in to adder is set to 1 during subtract and increment
	-- operations
	carry_in	<= 	'1' when
						(sub_AB = '1' or inc_A = '1' ) else
					'0';
					
	-- select appropriate alu_output to go to Z depending
	-- on control signals
	alu_out		<=	carry_out(ALU_WIDTH downto 1) 	when 
						((and_AB = '1' or or_AB = '1') and (sl_AB = '0' and sr_AB = '0')) else
					shifter_out						when 
						(sl_AB = '1' or sr_AB = '1') else
					adder_out;
					
	-- selects use of the Adder as an OR gate
	adderORsel	<=  '1' when 
						(or_AB = '1') else
					'0';
	-- selects use of the Adder as an XOR gate
	-- or as a compare [which uses the XOR function]
	adderXORsel	<=	'0' when 
						(xor_AB = '1' or cmp_AB = '1') else
					'1';
					
	-- set/unset carry flag depending on relevant conditions
	carry 		<=  carry_out(carry_out'high) 	when
						(add_AB = '1' and and_AB = '0' and or_AB = '0' and xor_AB = '0' and cpl_B = '0' and clr = '0') else
					'0' 						when 
						(and_AB = '1' or  or_AB  = '1' or xor_AB = '1' or cpl_B = '1' or clr = '1') else
					shifter_carry 				when
						(sl_AB  = '1' or  sr_AB  = '1');
					
	-- barrel shifter signals
	shifter_direction	<=	'1'	when 
								(sr_AB = '1') else
							'0';
							
	shifter_inA			<=	Areg;
	shifter_inB			<=	Breg;
	
	adder	: alu_adder
		port map	(
					x			=> adder_in_a		,
					y			=> adder_in_b		,
					carry_in	=> carry_in			,
					ORsel		=> adderORsel		,
					XORsel		=> adderXORsel		,
					carry_out	=> carry_out		,
					z			=> adder_out
					);

	shifter		:	alu_barrel_shifter
		port map	(
					x			=>	shifter_inA		,
					y			=>	shifter_inB		,
					z			=>	shifter_out		,
					c			=>	shifter_carry	,
					direction	=>	shifter_direction
					);

	registered_ios	:	process (reset, clr, clk, A, B, adder_out, Creg, Zreg, Vreg, load_inputs, load_outputs)
						begin
							if (reset = '1') then
								Areg	<=	(others => '0');
								Breg	<=	(others => '0');
								Yreg	<=	(others => '0');

								Zreg	<= 	'1';
								Creg	<= 	'0';
								Vreg	<= 	'0';
							elsif (clk'event and clk = '1') then
								if (load_inputs = '1') then
									Areg	<=	A;
									Breg	<=	B;
								end if;
								if (load_outputs = '1') then
									Yreg		<= alu_out;
								end if;
								
								-- clear command clears all registers
								-- and the carry bit
								if (clr = '1') then
									Areg	<=	(others => '0');
									Breg	<=	(others => '0');
									Yreg	<=	(others => '0');
	
									Creg	<= 	'0';
								end if;


								if (clr_Z = '1') then
									Zreg	<= '0';
								end if;
								if (clr_C = '1') then
									Creg	<= '0';
								end if;
								if (clr_V = '1') then
									Vreg	<= '0';
								end if;
								
								-- set the Z register 
								if 		(alu_out = 0) then
									Zreg	<= '1';
								else
									Zreg	<= '0';
								end if;
								
                                
								Creg	<= carry;
							end if;
						end process registered_ios;
	
	
end behavioural;


