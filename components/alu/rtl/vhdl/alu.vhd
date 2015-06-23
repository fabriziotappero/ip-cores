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

--	Description 	: 	ALU controller
--  Entity			: 	alu_controller
--	Architecture	: 	behavioural
--  Created on  	: 	07/03/2004

library	ieee;

use ieee.std_logic_1164.all;
use	ieee.std_logic_unsigned.all;

entity alu is
	port	(
			A			: in	std_logic_vector(7 downto 0);
			B			: in 	std_logic_vector(7 downto 0);
			S			: in 	std_logic_vector(3 downto 0);
			Y			: out	std_logic_vector(7 downto 0);
			CLR 		: in	std_logic					;
			CLK			: in	std_logic					;
			C			: out	std_logic					;
			V			: out	std_logic					;
			Z			: out	std_logic
			);
end alu;

architecture structural of alu is
component alu_controller
	port	(
			add_AB		: out	std_logic;
			sub_AB		: out	std_logic;
			inc_A		: out	std_logic;
			inc_B		: out	std_logic;
			dec_A		: out	std_logic;
			dec_B		: out	std_logic;
			cmp_AB		: out	std_logic;
			and_AB		: out	std_logic;
			or_AB		: out	std_logic;
			xor_AB		: out	std_logic;
			cpl_B		: out	std_logic;
			cpl_A		: out	std_logic;
			sl_AB		: out	std_logic;
			sr_AB		: out	std_logic;
			clr			: out	std_logic;
			
			clr_Z		: out	std_logic;
			clr_V		: out	std_logic;
			clr_C		: out	std_logic;
			
			load_inputs	: out	std_logic;
			load_outputs: out	std_logic;
			
			
			opcode		: in	std_logic_vector(3 downto 0);			
			reset		: in	std_logic;
			clk			: in	std_logic
			);
end component;
component alu_datapath
	port	(
			A			: in	std_logic_vector(7 downto 0);
			B			: in	std_logic_vector(7 downto 0);
			Y			: out	std_logic_vector(7 downto 0);

			add_AB		: in	std_logic;
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
			clr			: in	std_logic;
			
			clr_Z		: in	std_logic;
			clr_V		: in	std_logic;
			clr_C		: in	std_logic;

			C			: out	std_logic;
			V			: out	std_logic;
			Z			: out	std_logic;
			
			load_inputs	: in	std_logic;
			load_outputs: in	std_logic;
			
			reset		: in	std_logic;

			clk			: in	std_logic
			);
end component;

signal					add_AB		: 	std_logic					;
signal					sub_AB		: 	std_logic					;
signal					inc_A		: 	std_logic					;
signal					inc_B		: 	std_logic					;
signal					dec_A		: 	std_logic					;
signal					dec_B		: 	std_logic					;
signal					cmp_AB		: 	std_logic					;
signal					and_AB		: 	std_logic					;
signal					or_AB		: 	std_logic					;
signal					xor_AB		: 	std_logic					;
signal					cpl_B		: 	std_logic					;
signal					cpl_A		: 	std_logic					;
signal					sl_AB		: 	std_logic					;
signal					sr_AB		: 	std_logic					;
signal					clr_ALL		: 	std_logic					;

signal					clr_Z		: 	std_logic					;
signal					clr_V		: 	std_logic					;
signal					clr_C		: 	std_logic					;
			
signal					reset		: 	std_logic					;
signal					load_inputs	: 	std_logic					;
signal					load_outputs:	std_logic					;

begin
	-- clear is the same as reset
	reset	<=	CLR;

	controller	:	alu_controller
		port map	(
					add_AB		,
					sub_AB		,
					inc_A		,
					inc_B		,
					dec_A		,
					dec_B		,
					cmp_AB		,
					and_AB		,
					or_AB		,
					xor_AB		,
					cpl_B		,
					cpl_A		,
					sl_AB		,
					sr_AB		,
					clr_ALL		,
					
					clr_Z		,
					clr_V		,
					clr_C		,
					
					load_inputs	,
					load_outputs,
					
					S			,
					
					reset		,
					clk
					);
	datapath	:	alu_datapath
		port map	(
					A			,
					B			,
					Y			,
		
					add_AB		,
					sub_AB		,
					inc_A		,
					inc_B		,
					dec_A		,
					dec_B		,
					cmp_AB		,
					and_AB		,
					or_AB		,
					xor_AB		,
					cpl_B		,
					cpl_A		,
					sl_AB		,
					sr_AB		,
					clr_ALL		,
					
					clr_Z		,
					clr_V		,
					clr_C		,
		
					C			,
					V			,
					Z			,
					
					load_inputs	,
					load_outputs,
					
					reset,
		
					clk
					);	
end structural;
