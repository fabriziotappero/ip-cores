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

--	Description 	: 	ALU opcode_seller
--  Entity			: 	alu_opcode_seller
--	Architecture	: 	behavioural
--  Created on  	: 	07/03/2004

library	ieee;

use ieee.std_logic_1164.all;
use	ieee.std_logic_unsigned.all;

entity alu_controller is 
	generic	(
			ALU_WIDTH : integer := 8
			);
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

end alu_controller;


architecture behavioural of alu_controller is

subtype		opcode_selLER_opcode is std_logic_vector(3 downto 0);
type		OPERATION is (add_op, inc_op, sub_op, cmp_op, and_op, or_op, xor_op, cpl_op, asl_op,asr_op, clr_op);
signal 		this_opcode, next_opcode
						: opcode_selLER_opcode;
signal		opcode_sel		: std_logic_vector(16 downto 0);
signal		control			: std_logic_vector(2 downto 0);

constant	addAB		:	integer := 00;
constant	subAB		:	integer := 01;
constant	incA		:	integer := 02;
constant	incB		:	integer := 03;

constant	decA		:	integer := 04;
constant	decB		:	integer := 05;
constant	cmpAB		:	integer := 06;
constant	andAB		:	integer := 07;

constant	orAB		:	integer := 08;
constant	xorAB		:	integer := 09;
constant	cplB		:	integer := 10;
constant	cplA		:	integer := 11;

constant	slAB		:	integer := 12;
constant	srAB		:	integer := 13;
constant	clrALL		:	integer := 14;
constant	clrZ		:	integer := 0;

constant	clrV		:	integer := 1;
constant	clrC		:	integer := 2;
 			
constant 	cADD_AB		: opcode_selLER_opcode	:= "0000";
constant 	cINC_A		: opcode_selLER_opcode	:= "0001";
constant	cSUB_AB		: opcode_selLER_opcode	:= "0010";
constant	cCMP_AB		: opcode_selLER_opcode	:= "0011";
constant	cAND_AB		: opcode_selLER_opcode	:= "1100";
constant	cOR_AB		: opcode_selLER_opcode	:= "1101";
constant	cXOR_AB		: opcode_selLER_opcode	:= "1110";
constant	cCPL_B		: opcode_selLER_opcode	:= "1111";
constant 	cASL_AbyB	: opcode_selLER_opcode	:= "0100";
constant 	cASR_AbyB	: opcode_selLER_opcode	:= "0101";
constant	cCLR		: opcode_selLER_opcode	:= "0110";


begin


	add_AB	<=	opcode_sel(addAB);
	sub_AB	<=	opcode_sel(subAB);
	inc_A	<=	opcode_sel(incA);
	inc_B	<=	opcode_sel(incB);
	dec_A	<=	opcode_sel(decA);
	dec_B	<=	opcode_sel(decB);
	cmp_AB	<=	opcode_sel(cmpAB);
	and_AB	<=	opcode_sel(andAB);
	or_AB	<=	opcode_sel(orAB);
	xor_AB	<=	opcode_sel(xorAB);
	cpl_B	<=	opcode_sel(cplB);
	cpl_A	<=	opcode_sel(cplA);
	sl_AB	<=	opcode_sel(slAB);
	sr_AB	<=	opcode_sel(srAB);
	clr		<=	opcode_sel(clrALL);
	
	clr_Z	<=	control(clrZ);
	clr_V	<=	control(clrV);
	clr_C	<=	control(clrC);
	
	state	:	process (clk)
				begin
					if		(reset = '1') then
						this_opcode <= cCLR;
					elsif 	(clk'event and clk = '1') then
						this_opcode <= opcode;
					end if;
				end process state;

	comb	:	process (this_opcode)
				begin
					-- reset opcode_sel signals
					opcode_sel <= (others => '0');
					load_inputs 	<= '0';
					case (this_opcode) is
						when cCLR 		=>
							opcode_sel(clrALL)	<= '1'	;
						when cADD_AB	=>
							opcode_sel(addAB) 	<= '1';
							load_inputs 	<= '1';
							load_outputs 	<= '1';							
						when cINC_A		=>
							opcode_sel(incA) 	<= '1';
							load_inputs 	<= '1';
							load_outputs 	<= '1';							
						when cSUB_AB	=>
							opcode_sel(subAB) 	<= '1';
							load_inputs 	<= '1';
							load_outputs 	<= '1';							
						when cCMP_AB	=>
							opcode_sel(cmpAB) 	<= '1';
							load_inputs 	<= '1';
						when cAND_AB	=>
							opcode_sel(andAB) 	<= '1';
							load_inputs 	<= '1';
							load_outputs 	<= '1';							
						when cOR_AB		=>
							opcode_sel(orAB) 	<= '1';
							load_inputs 	<= '1';
							load_outputs 	<= '1';							
						when cXOR_AB	=>
							opcode_sel(xorAB) 	<= '1';
							load_inputs 	<= '1';
							load_outputs 	<= '1';							
						when cCPL_B		=>
							opcode_sel(cplB) 	<= '1';
							load_inputs 	<= '1';
							load_outputs 	<= '1';							
						when cASL_AbyB	=>
							opcode_sel(slAB) 	<= '1';
							load_inputs 	<= '1';
							load_outputs 	<= '1';							
						when cASR_AbyB	=>
							opcode_sel(srAB) 	<= '1';
							load_inputs 	<= '1';
							load_outputs 	<= '1';							
						when others		=>
							next_opcode		<= this_opcode;
					end case;
				end process comb;
end behavioural;
