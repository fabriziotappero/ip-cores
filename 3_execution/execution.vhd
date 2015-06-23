--
-- Etapa Execution (EX) del procesador MIPS Segmentado
--
-- Licencia: Copyright 2008 Emmanuel Luján
--
-- 	This program is free software; you can redistribute it and/or
-- 	modify it under the terms of the GNU General Public License as
-- 	published by the Free Software Foundation; either version 2 of
-- 	the License, or (at your option) any later version. This program
-- 	is distributed in the hope that it will be useful, but WITHOUT
-- 	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
-- 	or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
-- 	License for more details. You should have received a copy of the
-- 	GNU General Public License along with this program; if not, write
-- 	to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
-- 	Boston, MA 02110-1301 USA.
-- 
-- Autor:	Emmanuel Luján
-- Email:	info@emmanuellujan.com.ar
-- Versión:	1.0
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records_pkg.all;
use work.segm_mips_const_pkg.all;

entity EXECUTION is
	port( 
		--Entradas
     		CLK			: in STD_LOGIC;					--Reloj
		RESET			: in STD_LOGIC;					--Reset asincrónico
     		WB_CR			: in WB_CTRL_REG; 				--Estas señales se postergarán hasta la etapa WB
		MEM_CR			: in MEM_CTRL_REG;				--Estas señales se postergarán hasta la etapa MEM
		EX_CR			: in EX_CTRL_REG;				--Estas señales se usarán en esta etapa 	     	
		NEW_PC_ADDR_IN		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Nueva dirección del PC
		RS	 		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Datos leidos de la dir. Rs
	    	RT 			: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Datos leidos de la dir. Rt
		OFFSET			: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Offset de la instrucción  [15-0]
		RT_ADDR			: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	--Dirección del registro RT [20-16]
		RD_ADDR			: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	--Dirección del registro RD [15-11]			 				
				     	      
		--Salidas
		WB_CR_OUT		: out WB_CTRL_REG;				--Estas señales se postergarán hasta la etapa WB
		MEM_CR_OUT		: out MEM_CTRL_REG;				--Estas señales se postergarán hasta la etapa MEM
		NEW_PC_ADDR_OUT		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Nueva dirección del PC
		ALU_FLAGS_OUT		: out ALU_FLAGS;				--Las flags de la ALU
		ALU_RES_OUT		: out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	--El resultado generado por la ALU
		RT_OUT			: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Entrará como Write Data en la etapa MEM
		RT_RD_ADDR_OUT		: out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0)	--Se postergará hasta la etapa WB			
	);
end EXECUTION;

architecture EXECUTION_ARC of EXECUTION is	

--Declaración de componentes
	component ALU_CONTROL is
		port(
			--Entradas
			CLK		: in STD_LOGIC;				-- Reloj
			FUNCT		: in STD_LOGIC_VECTOR(5 downto 0);	-- Campo de la instrucción FUNC
			ALU_OP_IN	: in ALU_OP_INPUT;			-- Señal de control de la Unidad de Control
			--Salidas
		     	ALU_IN		: out ALU_INPUT				-- Entrada de la ALU
		);
	end component ALU_CONTROL;
	
	component ALU is 
		generic (N:INTEGER := INST_SIZE);
		port(
			X		: in STD_LOGIC_VECTOR(N-1 downto 0);
			Y		: in STD_LOGIC_VECTOR(N-1 downto 0);
			ALU_IN		: in ALU_INPUT;
			R		: out STD_LOGIC_VECTOR(N-1 downto 0);
			FLAGS		: out ALU_FLAGS	
		);
	end component ALU;
	
	component ADDER is 
		generic (N:INTEGER := INST_SIZE);    
		port(
			X	: in	STD_LOGIC_VECTOR(N-1 downto 0);
			Y	: in	STD_LOGIC_VECTOR(N-1 downto 0);
			CIN	: in	STD_LOGIC;
			COUT	: out	STD_LOGIC;
			R	: out	STD_LOGIC_VECTOR(N-1 downto 0)
		);
	end component ADDER;
	
	component EX_MEM_REGISTERS is  
	    port(
			--Entradas
			CLK		: in STD_LOGIC;					--Reloj
			RESET		: in STD_LOGIC;					--Reset asincrónico
			WB_CR_IN	: in WB_CTRL_REG; 				--Estas señales se postergarán hasta la etapa WB
			MEM_CR_IN	: in MEM_CTRL_REG;				--Estas señales se postergarán hasta la etapa MEM
			NEW_PC_ADDR_IN	: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Nueva dirección del PC
			ALU_FLAGS_IN	: in ALU_FLAGS;					--Las flags de la ALU
			ALU_RES_IN	: in STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	--El resultado generado por la ALU
			RT_IN		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Entrará como Write Data en la etapa MEM
			RT_RD_ADDR_IN	: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	--Se postergará hasta la etapa WB)	
			 						     	      
			--Salidas
			WB_CR_OUT	: out WB_CTRL_REG; 				--Estas señales se postergarán hasta la etapa WB
			MEM_CR_OUT	: out MEM_CTRL_REG;				--Estas señales se postergarán hasta la etapa MEM
			NEW_PC_ADDR_OUT	: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Nueva dirección del PC
			ALU_FLAGS_OUT	: out ALU_FLAGS;				--Las flags de la ALU
			ALU_RES_OUT	: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--El resultado generado por la ALU
			RT_OUT		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Entrará como Write Data en la etapa MEM
			RT_RD_ADDR_OUT	: out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0)	--Se postergará hasta la etapa WB)
			
		);
	end component EX_MEM_REGISTERS;
	
--Declaración de señales
	signal CARRY_AUX	: STD_LOGIC;
	signal ALU_IN_AUX	: ALU_INPUT;
	signal PC_ADDR_AUX	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0); 
	signal RT_RD_ADDR_AUX	: STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
	signal OFFSET_SHIFT2	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
	signal ALU_REG_IN	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0); 
	signal ALU_RES_AUX	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0); 
	signal ALU_FLAGS_AUX	: ALU_FLAGS;
	 
begin
	OFFSET_SHIFT2 <= OFFSET(29 downto 0) & "00";

	--Port maps
	ALU_CTRL:
		ALU_CONTROL port map(
			CLK		=> CLK,
			FUNCT		=> OFFSET(5 downto 0),
			ALU_OP_IN	=> EX_CR.ALUOp,
		     	ALU_IN		=> ALU_IN_AUX
		);
	
	ADDER_MIPS: 
		ADDER generic map (N => INST_SIZE) 
		port map(
			X	 => NEW_PC_ADDR_IN,
			Y	 => OFFSET_SHIFT2,
			CIN	 => '0',
			COUT	 => CARRY_AUX,
			R	 => PC_ADDR_AUX
		);
        
	MUX_RT_RD:
		process(EX_CR.RegDst,RT_ADDR,RD_ADDR) is
    		begin
    	 		if( EX_CR.RegDst = '0') then
    	 			RT_RD_ADDR_AUX <= RT_ADDR; 
	    	 	else
    		 		RT_RD_ADDR_AUX <= RD_ADDR;
    		 	end if;
    	 	end process MUX_RT_RD;
	 
	MUX_ALU:
		process(EX_CR.AluSrc,ALU_REG_IN,RT,OFFSET)
		begin
			if( EX_CR.AluSrc = '0') then
				ALU_REG_IN <= RT; 
			else
				ALU_REG_IN <= OFFSET;
			end if;
		end process MUX_ALU;
	 
	ALU_MIPS: 
		ALU generic map (N => INST_SIZE)
		port map(
			X	=> RS,
			Y	=> ALU_REG_IN,
			ALU_IN	=> ALU_IN_AUX,
			R	=> ALU_RES_AUX,
			FLAGS	=> ALU_FLAGS_AUX
		);

	EX_MEM_REGS:
		 EX_MEM_REGISTERS port map(
			--Entradas
			CLK		=> CLK,
			RESET		=> RESET,
			WB_CR_IN	=> WB_CR,
			MEM_CR_IN	=> MEM_CR,
			NEW_PC_ADDR_IN	=> PC_ADDR_AUX,
			ALU_FLAGS_IN	=> ALU_FLAGS_AUX,
			ALU_RES_IN	=> ALU_RES_AUX,
			RT_IN		=> RT,
			RT_RD_ADDR_IN	=> RT_RD_ADDR_AUX,	
			--Salidas
			WB_CR_OUT	=> WB_CR_OUT,
			MEM_CR_OUT	=> MEM_CR_OUT,
			NEW_PC_ADDR_OUT	=> NEW_PC_ADDR_OUT,
			ALU_FLAGS_OUT	=> ALU_FLAGS_OUT,
			ALU_RES_OUT	=> ALU_RES_OUT,
			RT_OUT		=> RT_OUT,
			RT_RD_ADDR_OUT	=> RT_RD_ADDR_OUT	
		);

end EXECUTION_ARC;

