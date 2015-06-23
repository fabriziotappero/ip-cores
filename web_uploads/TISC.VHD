-- Tiny Instruction Set (TISC) VHDL CPU Core
-- Copyright Vincent Crabtree, 15th Nov 2001
--
-- My first attempt at processor design, thanks to :-
-- Tim Boscke - CPU8BIT2, Rockwell - 6502, Microchip - Pic
-- Jien Chung Lo - EL405 , Steve Scott - Tisc,
-- Giovanni Moretti - Intro to Asm
-- Uses 12 bit program word, and 8 bit data memory

-- 2 reg machine,accumulator based, with akku and index regs
-- Harvard architecture, uses return x so as to eliminate need of pmem
-- indirect instructions like 8051.
-- pc is 10 bits, akku and idx are 8 bit.

-- Has carry and zero flags,
-- three addressing modes:- immediate, indirect and reg.
-- seperate program and data memory for pipelining later...

-- Instructions coded as thus:-


-- Long instructions first - program jump.
-- Both store return address for subroutine calls, 1 deep stack.
-- 0 0 xxxxxxxxxx	jc	pmem10		; if c==1, stack = pc, pc <- pmem10, fi
-- 0 1 xxxxxxxxxx	jz 	pmem10		; if z==1, stack = pc, pc <- pmem10, fi

-- Immediate ops
-- bits 9 and 8 select what to do
-- 1 00 0 xxxxxxxx		lda	#imm8		; a= imm8, c=0,
-- 1 00 1 xxxxxxxx		ret	#imm8		; a= imm8, pc = stack

-- 1 01 0 xxxxxxxx		adc	#imm8		; add with carry imm8, cy and z set
-- 1 01 1 xxxxxxxx		adx	#imm8		; add imm8 to idx reg, z=(a==0)

-- Indirect and alu ops
-- bit 9 selects indirect or alu ops

-- Indirect - bits 7 and 8 select what to do
-- 1 10 0 0  xxxxxxx	lda	[ix]	; load a indirect data mem
-- 1 10 0 1  xxxxxxx	sta	[ix]	; store a indirect data mem

-- register register
-- 1 10 1 0  xxxxxxx	tax		; x = a,
-- 1 10 1 1  xxxxxxx	txa		; a = x

-- Arithmetic ops use indirect addressing
-- all alu ops indirect, bits 7 and 8 select alu op.
-- 1 11 00  xxxxxxx	add	a,[ix]	; add with carry
-- 1 11 01  xxxxxxx	sub	a,[ix]	; a = a + ~[idx], inc a after for proper subtract
-- 1 11 10  xxxxxxx	and	a,[ix]	; and mem contents into a
-- 1 11 11  xxxxxxx	nor	a,[ix]	; nor

-- States. 
-- 000	instruction decode 
-- 010  load a indirect - lda [ix]
-- 011  stor a indirect - sta [ix]
-- 100	add a,[ix] 
-- 101	sub a,[ix[
-- 110	and a,[ix]
-- 111  nor a,[ix]

library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; -- has adder built in

entity tisc is
	port(
		-- bus
		-- db only 8 bits wide on dmem side, 12 on pmem side.
		data		:	inout 	std_logic_vector(11 downto 0);
		address		:	out	std_logic_vector(9 downto 0);
		
		-- control - active low
		rd			:	out	std_logic;		-- dram
		wr			:	out	std_logic;		-- dram
		psen		:	out	std_logic;	-- pmem

		-- machine control
		clock		: 	in	std_logic;
		reset		: 	in	std_logic);
end;

architecture cpu_arch of tisc is
	-- Program control 
	signal 	stack		:	std_logic_vector(9 downto 0);	-- stack, 1 deep
	signal	pc			:	std_logic_vector(9 downto 0);	-- program counter
	
	-- Registers
	signal	akku	:	std_logic_vector(8 downto 0);	-- accumulator, cy is bit 8
	signal	idx		:	std_logic_vector(7 downto 0);	-- index reg
	signal	z		:	std_logic;						-- zero flag
	
	-- ALU controls
	signal	aluout		:	std_logic_vector(9 downto 0);	-- alu result 
	signal	temp		:	std_logic_vector(8 downto 0);	-- temp storage for alu
	signal	aludest		:	std_logic_vector(1 downto 0);	-- output mux alu
	signal	aluop		:	std_logic_vector(1 downto 0);	-- alu operation
	signal	aluinput	:	std_logic_vector(9 downto 0);	-- input to alu

	-- machine control	
	signal 	states		:	std_logic_vector(2 downto 0);	-- state controller

begin -- start logic decleration

process(clock,reset)	-- sequential section
begin
		-- check if reset or not
		if(reset = '0' ) then	-- async reset parameters
		   -- how do I stop the annoying async error?
		   pc	<= (others => '0');-- reset
		   states <= (others => '0'); -- decode sub state 		
		   aludest  <= "01";		-- reset destination dest
					   		
		elsif rising_edge(clock) then	--	actual machine 
		
		-- check state machine for indirect alu ops
		if( states(2) = '1') then

			if( states(1 downto 0) = "01") then	--sub add ind
		   		temp <= "0" & (Not data(7 downto 0));
			else   
		   		temp <= "0" & data(7 downto 0);
			end if;   
		   
		   aluop <= states(1 downto 0);	-- 00 adc indirect
										-- 01 not add ind
										-- 10 and indirect
										-- 11 nor indirect		
		   -- sort out muxers for alu
		   aludest <= "00";	-- akku destination
		   states <= "000";	-- decode

		else
		
		   -- States decode
		   case states(1 downto 0) is	-- action dependent on states 
		   when "00" =>		-- instruction decode

			-- increment pc first
			temp <= "000000001";	-- inc
			aludest <= "10";	-- pc and increment and idle
			pc <= aluout;		-- get result	
			
			-- Now decode instr on data bus
			-- sort out jz or jc	
	 		if( (data(11) = '0') and	-- top bit nought, sio a jump...
	 		 	( ((akku(8) = '1') and (data(10) = '0')) or -- JC
	 				((z='1') and (data(10)='1'))) ) then -- Jz
		    	   stack <= pc;							--return stack
		    	   pc <= data(9 downto 0);
			   -- states already at decode		   

			else	-- top bit is one, so not a jump instruction...
				case data(10 downto 9) is
				when "01" => -- adc #imm/adx #imm
					temp <= "0" & data(7 downto 0);
		   			aluop <= "01";				-- add
					aludest <= data(8) & data(8) ; --00 is akku, 11 is idx
	   	   			-- states already at decode
					   
				when "00" =>  -- lda #imm/ret #imm clear cy
		  	   		if( data(8) = '1' ) then	-- ret ##imm
		  	   			pc <= stack;
		  	   		end if;
		  	   		akku <= "0" & data(7 downto 0);
		  	   		-- states already at decode
			
				when "10" =>	-- lda/store or reg/reg
		   			if( data(8) = '1') then	-- ld ind /store ind
		   				states <= "01" & data(7);-- "010";
		   			-- reg/reg
		   			elsif( data(7) = '0') then	-- tax
						idx <= akku(7 downto 0);		
					else	-- txa	
		   				akku <= "0" & idx(7 downto 0);		
					end if;
			   -- states already at decode
		  	
		  		when "11" =>	-- add ind, and
		   			states <= "1" & data(8 downto 7); -- "100";	-- add/sub ind
													  -- "110";	-- and/nor ind			
				when others =>			   
		        	states <= "000";	-- if non of above, decode/nop 		
				end case;	-- end of instruction decode   		
		
			end if;	-- jump if 
			
		when "10" =>    -- lda [ix] - buses should be setup  
		   akku <= "0" & data(7 downto 0);
		   states <= "000";	-- decode
			
		when "11" =>    -- sta [ix]
		   -- akku placed on data bus now	
		   states <= "000";	-- decode
					
		when others =>
		   states <= "000";	-- decode
		
		end case; -- end of state decode
	end if;	-- end of alu indirect if
end if;		-- rising edge if
	

	-- Sort out alu ops and source/destination regs				
	case aludest is 
		when "00" =>	-- destination is alu
			akku <= aluout(8 downto 0);
		when "11" =>	-- alu destination is idx
			idx <= aluout(7 downto 0);
		when others => null;
	end case; -- end of dest decode
	
end process;	-- end sequential section
	
	-- concurrent section
	z <= '1' when akku = "000000000" and reset='1' else '0'; -- nice nand here

	-- alu input muxer	
	with aludest select	
	aluinput <= ("0" & akku) when "00",
				("00" & idx) when "11",
				pc 	when "10",
				("0" & temp) when others;

	-- Decode and perform arithmetic ops		
	with aluop select
		aluout <= aluinput + ("0" & temp) when "01",		-- add
					aluinput and ("0" & temp) when "10",	-- and
					aluinput nor ("0" & temp) when "11",	-- nor
					not ("0" & temp) when others;	-- any use? 
					
	-- assign pins 
	address <= pc when states = "000" else "00"&idx;
	
	data	<= ("000" & akku) when states = "011" else "ZZZZZZZZZZZZ";
	
	psen	<= '0' when states="000" else '1';	-- pmem read
	
	rd 	<= '0' when (states(2)='1') or (states="010") else '1'; 	-- dmem read
	wr	<= '0' when states="011" else '1';	-- dmem write
	
end cpu_arch;


