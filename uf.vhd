--! @file raytrac.vhd
--! @brief Descripci&oacute;n del sistema aritmetico usado por raytrac.
--! @author Juli&acute;n Andr&eacute;s Guar&iacute;n Reyes.
-- RAYTRAC
-- Author Julian Andres Guarin
-- uf.vhd
-- This file is part of raytrac.
-- 
--     raytrac is free software: you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation, either version 3 of the License, or
--     (at your option) any later version.
-- 
--     raytrac is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
-- 
--     You should have received a copy of the GNU General Public License
--     along with raytrac.  If not, see <http://www.gnu.org/licenses/>.

--! Libreria de definicion de senales y tipos estandares, comportamiento de operadores aritmeticos y logicos.
library ieee;
--! Paquete de definicion estandard de logica. 
use ieee.std_logic_1164.all;

--! Paquete para el manejo de aritmŽtica con signo sobre el tipo std_logic_vector 
use ieee.std_logic_signed.all;

--! Paquete para calculo de funciones reales.
use ieee.math_real.all;

--! Paquete estandar de texto
use std.textio.all;

--! Se usaran en esta descripcion los componentes del package arithpack.vhd. 
use work.arithpack.all;


--! uf es la descripci&oacute;on del circuito que realiza la aritm&eacute;tica del Rt Engine.

--! La entrada opcode indica la operaci&oacute;n que se est&aacute; realizando, en los sumadores, es la misma se&ntilde;al que se encuentra en la entidad opcoder, que selecciona si se est&aacute; realizando un producto punto o un producto cruz. Dentro de la arquitectura de uf, la se&ntilde;al opcode selecciona en la primera etapa de sumadores, si la operaci&oacute;n a realizar ser&aacute; una resta o una suma. 
--! Los resultados estar&acute;n en distintas salidas dependiendo de la operaci&oacute;n, lo cual es apenas natural: El producto cruz tiene por resultado un vector, mientras que el producto punto tiene por resultado un escalar. 
--! Esta entidad utiliza las se&ntilde;ales de control clk y rst.
--! \n\n
--! La caracter&iacute;stica fundamental de uf, es que puede realizar 2 operaciones de producto punto al mimso tiempo &oacute; una operaci&oacute;n de producto cruz. La otra caracter&iacute;stica importante es que el pipe de producto punto es mas largo que el pipe de producto cruz: el producto punto tomar&acute; 3 clocks para realizarse, mientras que el procto punto tomara 4 clocks para realizarse.    
--! Es importante entender que las resultados de las operaciones, correspondientes a las salidas de esta entidad no est'an conectadas directamente a la salida del circuito combinatorio que ejecuta sus repectivas operaciones: en vez de ello, los resutados est'an conectados a la salida de un registro. 
--! Este circuito es una ALU
entity uf is
	generic (
		square_root_width : integer := 16;
		use_std_logic_signed : string := "NO";
		testbench_generation : string := "NO";
		carry_logic : string := "CLA"
	);
	port (
		opcode		: in std_logic; --! Entrada que dentro de la arquitectura funciona como selector de la operaci&oacute;n que se lleva a cabo en la primera etapa de sumadores/restadores. 
		exp0,exp1	: in std_logic_vector(integer(ceil(log(real(square_root_width),2.0)))-1 downto 0); --! Junto con la mantissa este es el exponente del valor flotante, mejora muchisimo la precisi'on. 
		m0f0,m0f1,m1f0,m1f1,m2f0,m2f1,m3f0,m3f1,m4f0,m4f1,m5f0,m5f1 : in std_logic_vector(17 downto 0); --! Entradas que van conectadas a los multiplicadores en la primera etapa de la descripci&oacute;n.  
		cpx,cpy,cpz,dp0,dp1,kvx0,kvy0,kvz0,kvx1,kvy1,kvz1 : out std_logic_vector(31 downto 0); --! Salidas donde se registran los resultados de las operaciones aritm&eacute;ticas: cpx,cpy,cpz ser&acute;n los componentes del vector que da por resultado el producto cruz entre los vectores AxB &oacute; CxD. kvx0, kvy0, kvz0, kvx1, kvy1, kvz1 es el resultado de los multiplicadores   
		clk,rst		: in std_logic --! Las entradas de control usuales.  
	);
end uf;

architecture uf_arch of uf is 

	-- Stage 0 signals
	
	signal stage0mf00,stage0mf01,stage0mf10,stage0mf11,stage0mf20,stage0mf21,stage0mf30,stage0mf31,stage0mf40,stage0mf41,stage0mf50,stage0mf51 : std_logic_vector(17 downto 0); --! Señales que conectan los operandos seleccionados en opcode a las entradas de los multiplicadores.
	signal stage0p0,stage0p1, stage0p2, stage0p3, stage0p4, stage0p5 : std_logic_vector(31 downto 0); --! Se&ntilde;ales / buses, con los productos de los multiplicadores. 
	signal stageMopcode : std_logic; --! Señal de atraso del opcode. Revisar el diagrama de bloques para mayor claridad.
	signal stage0exp0	: std_logic_vector(integer(ceil(log(real(square_root_width),2.0)))-1 downto 0);
	signal stage0exp1	: std_logic_vector(integer(ceil(log(real(square_root_width),2.0)))-1 downto 0);
	
	--Stage 1 signals 
	
	signal stage1p0, stage1p1, stage1p2, stage1p3, stage1p4, stage1p5 : std_logic_vector (31 downto 0); --! Señales provenientes de los productos de la etapa previa de multiplicadores.
	signal stage1a0, stage1a1, stage1a2 : std_logic_vector (31 downto 0); --! Señales / buses, con los resultados de los sumadores. 
	signal stageSRopcode : std_logic; --! Señal proveniente del opcode que selecciona si los sumadores deben ejecutar una resta o una suma dependiendo de la operaci&oacute;n que se ejecute en ese momento del pipe.  
	signal stage1exp0	: std_logic_vector(integer(ceil(log(real(square_root_width),2.0)))-1 downto 0);
	signal stage1exp1	: std_logic_vector(integer(ceil(log(real(square_root_width),2.0)))-1 downto 0);
	
	-- Some support signals
	signal stage1_internalCarry	: std_logic_vector(2 downto 0); --! Cada uno de los 3 sumadores de la etapa de sumadores est&acute; compuesto de una cascada de 2 sumadores Carry Look Ahead: aXhigh y aXlow. El carry out del componente low y el carry in del componente high, se conectar&acute; a trav&eacute;s de las señales internal carry.   
	signal stage2_internalCarry : std_logic_vector(1 downto 0); --! Cada uno de los 2 sumadores de la última etapa de sumadores est&acute; compuesto de una cascada de 2 sumadores Carry Look AheadÑ: aXhigh y aXlow. El carry out del componente low y el carry in del componente high, se conectar&acute; a trav&eacute;s de las señales internal carry.  
	
	--Stage 2 signals	
	signal stage2a0, stage2a2, stage2a3, stage2a4, stage2p2, stage2p3 : std_logic_vector (31 downto 0); --! Estas señales corresponden a los sumandos derivados de la primera etapa de multiplicadores (stage2p2, stage2p3) y a los sumandos derivados del resultado de las sumas en la primera etapa de sumadores. 
	
	  	
	
begin

	-- Multiplicator Instantiation (StAgE 0)
	--! Multiplicador 0 
	m0 : lpm_mult
	generic map (
		lpm_hint =>  "DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=9",
		lpm_pipeline =>  2,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => 18,
		lpm_widthb => 18,
		lpm_widthp => 32
	)
	port map (
		aclr	=> rst,
		clock	=> clk,
		dataa	=> stage0mf00,
		datab	=> stage0mf01,
		result	=> stage0p0
	);
	kvx0 <= stage0p0;
	--! Multiplicador 1
	m1 : lpm_mult 
	generic map (
		lpm_hint =>  "DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=9",
		lpm_pipeline =>  2,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => 18,
		lpm_widthb => 18,
		lpm_widthp => 32
	)
	port map (
		aclr	=> rst,
		clock	=> clk,
		dataa	=> stage0mf10,
		datab	=> stage0mf11,
		result	=> stage0p1
	);
	kvy0 <= stage0p1;
	
	--! Multiplicador 2
	m2 : lpm_mult 
	generic map (
		lpm_hint =>  "DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=9",
		lpm_pipeline =>  2,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => 18,
		lpm_widthb => 18,
		lpm_widthp => 32
	)
	port map (
		aclr	=> rst,
		clock	=> clk,
		dataa	=> stage0mf20,
		datab	=> stage0mf21,
		result	=> stage0p2
	);
	kvz0 <= stage0p2;
	
	--! Multiplicador 3
	m3 : lpm_mult 
	generic map (
		lpm_hint =>  "DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=9",
		lpm_pipeline =>  2,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => 18,
		lpm_widthb => 18,
		lpm_widthp => 32
	)
	port map (
		aclr	=> rst,
		clock	=> clk,
		dataa	=> stage0mf30,
		datab	=> stage0mf31,
		result	=> stage0p3
	);
	kvx1 <= stage0p3;
	--! Multiplicador 4
	m4 : lpm_mult 
	generic map (
		lpm_hint =>  "DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=9",
		lpm_pipeline =>  2,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => 18,
		lpm_widthb => 18,
		lpm_widthp => 32
	)
	port map (
		aclr	=> rst,
		clock	=> clk,
		dataa	=> stage0mf40,
		datab	=> stage0mf41,
		result	=> stage0p4
	);
	kvy1 <= stage0p4;
	
	--! Multiplicador 5
	m5 : lpm_mult 
	generic map (
		lpm_hint =>  "DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=9",
		lpm_pipeline =>  2,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => 18,
		lpm_widthb => 18,
		lpm_widthp => 32
	)
	port map (
		aclr	=> rst,
		clock	=> clk,
		dataa	=> stage0mf50,
		datab	=> stage0mf51,
		result	=> stage0p5
	);
	kvz1 <= stage0p5;
	
	
	useIeee:
	if use_std_logic_signed="YES" generate
		-- Adder Instantiation (sTaGe 1)
		stage1adderProc: 
		process (stage1p0,stage1p1,stage1p2,stage1p3,stage1p4,stage1p5,stageSRopcode)
		begin
			case (stageSRopcode) is
				when '1' =>		-- Cross Product
					stage1a0 <= stage1p0-stage1p1;
					stage1a2 <= stage1p4-stage1p5;
				when others => 	-- Dot Product
					stage1a0 <= stage1p0+stage1p1;
					stage1a2 <= stage1p4+stage1p5;
			end case;
		end process stage1adderProc;
		stage1a1 <= stage1p2-stage1p3;	-- This is always going to be a substraction
		
		-- Adder Instantiation (Stage 2)
		stage2a3 <= stage2a0+stage2p2;
		stage2a4 <= stage2p3+stage2a2;
		
	end generate useIeee;
						
	-- Incoming from opcoder.vhd signals into pipeline's stage 0.
	stage0mf00 <= m0f0;
	stage0mf01 <= m0f1;
	stage0mf10 <= m1f0;
	stage0mf11 <= m1f1;
	stage0mf20 <= m2f0;
	stage0mf21 <= m2f1;
	stage0mf30 <= m3f0;
	stage0mf31 <= m3f1;
	stage0mf40 <= m4f0;
	stage0mf41 <= m4f1;
	stage0mf50 <= m5f0;
	stage0mf51 <= m5f1;
	
	-- Signal sequencing: as the multipliers use registered output and registered input is not necessary to write the sequence of stage 0 signals to stage 1 signals.
	-- so the simplistic path is taken: simply connect stage 0 to stage 1 lines. However this would not apply for the opcode signal
	stage1p0 <= stage0p0;
	stage1p1 <= stage0p1;
	stage1p2 <= stage0p2;
	stage1p3 <= stage0p3;
	stage1p4 <= stage0p4;
	stage1p5 <= stage0p5;
	 
	
	--Outcoming to the rest of the system (by the time i wrote this i dont know where this leads to... jeje)
	--May 31 23:31:56 Guess What!, now I know!!!
	
	cpx <= stage1a0;
	cpy <= stage1a1;
	cpz <= stage1a2;
	
	
	dp0 <= stage2a3;
	dp1 <= stage2a4;
	
	-- Looking into the design the stage 1 to stage 2 are the sequences pipe stages that must be controlled in this particular HDL.
	--! Este proceso describe la manera en que se organizan las etapas de pipe.
	--! Todas las señales internas en las etapas de pipe, en el momento en que la entrada rst alcanza el nivel rstMasterValue, se colocan en '0'. N&oacute;tese que, salvo stageMopcode<=stageSRopcode, las señales que vienen desde la entrada hacia los multiplicadores en la etapa 0 y desde la salida de los multiplicadores desde la etapa0 hacia la etapa 1, no est&acute;n siendo descritas en este proceso, la explicaci&oacute;n de es simple: Los multiplicadores que se est&acute;n instanciado tienen registros a la entrada y la salida, permitiendo as&iacute;, registrar las entradas y registrar los productos o salidas de los  multiplicadores, hacia la etapa 1 o etapa de sumadores/restadores. 
	
	uf_seq: process (clk,rst)
	begin
		
		if rst=rstMasterValue then 
			stageMopcode	<= '0';
			stageSRopcode	<= '0';
			
			stage2a2 <= (others => '0');
			stage2p3 <= (others => '0');
			stage2p2 <= (others => '0');
			stage2a0 <= (others => '0');
		
		elsif clk'event and clk = '1' then 
		
			stage2a2 <= stage1a2;
			stage2p3 <= stage1p3;
			stage2p2 <= stage1p2;
			stage2a0 <= stage1a0;
			
			-- Opcode control sequence
			stageMopcode <= opcode;
			stageSRopcode <= stageMopcode;
					
		end if;
	end process uf_seq;
	
	--! Codigo generado para realizar test bench
	tbgen:
	if testbench_generation="YES" generate
		tbproc0:
		process
			variable buff : line;
			variable theend : time :=30835 ns;
			file mbuff : text open write_mode is "TRACE_multiplier_content.csv";
		begin
		write(buff,string'("#UF multipliers test benching"));
		writeline(mbuff, buff);
		write(buff,string'("#{Time} {m0result} {m1result} {m2result} {m3result} {m4result} {m5result}"));
		writeline(mbuff, buff);
		wait for 5 ns; 
		wait until rst=not(rstMasterValue);
		wait until clk='1';
		wait for tclk2+tclk4; --! Garantizar la estabilidad de los datos que se van a observar en la salida.
		displayRom:
		loop
			write (buff,string'("{"));			
			write (buff,now,unit =>ns); 
			write (buff,string'("}{"));
			hexwrite_0 (buff,stage1p0(31 downto 0));
			write (buff,string'("}{"));
			hexwrite_0 (buff,stage1p1(31 downto 0));
			write (buff,string'("}{"));
			hexwrite_0 (buff,stage1p2(31 downto 0));
			write (buff,string'("}{"));
			hexwrite_0 (buff,stage1p3(31 downto 0));
			write (buff,string'("}{"));
			hexwrite_0 (buff,stage1p4(31 downto 0));
			write (buff,string'("}{"));
			hexwrite_0 (buff,stage1p5(31 downto 0));
			write (buff,string'("}"));
			writeline(mbuff,buff);
			wait for tclk;
			if now>theend then
				wait;
			end if;
		end loop displayRom;
		end process tbproc0;
		tbproc1:
		process
			variable buff : line;
			variable theend : time :=30795 ns;
			file fbuff : text open write_mode is "TRACE_decoded_factors_content.csv";
		begin
			
			write(buff,string'("#UF factors decoded test benching"));
			writeline(fbuff, buff);
			write(buff,string'("#{Time} {m0f0,m0f1}{m1f0,m1f1}{m2f0,m2f1}{m3f0,m3f1}{m4f0,m4f1}{m5f0,m5f1}"));
			writeline(fbuff, buff);
			wait for 5 ns; 
			wait until rst=not(rstMasterValue);
			wait until clk='1';
			wait for tclk2+tclk4; --! Garantizar la estabilidad de los datos que se van a observar en la salida.
			displayRom:
			loop
				write (buff,string'(" { "));
				write (buff,now,unit =>ns);	
				write (buff,string'(" } "));			
				write (buff,string'(" { "));
				hexwrite_0 (buff,m0f0(17 downto 0));
				write (buff,string'(","));
				hexwrite_0 (buff,m0f1(17 downto 0));
				write (buff,string'(" } { "));
				hexwrite_0 (buff,m1f0(17 downto 0));
				write (buff,string'(","));
				hexwrite_0 (buff,m1f1(17 downto 0));
				write (buff,string'(" } { "));
				hexwrite_0 (buff,m2f0(17 downto 0));
				write (buff,string'(","));
				hexwrite_0 (buff,m2f1(17 downto 0));
				write (buff,string'(" } { "));
				hexwrite_0 (buff,m3f0(17 downto 0));
				write (buff,string'(","));
				hexwrite_0 (buff,m3f1(17 downto 0));
				write (buff,string'(" } { "));
				hexwrite_0 (buff,m4f0(17 downto 0));
				write (buff,string'(","));
			 	hexwrite_0 (buff,m4f1(17 downto 0));
				write (buff,string'(" } { "));
				hexwrite_0 (buff,m5f0(17 downto 0));
				write (buff,string'(","));
				hexwrite_0 (buff,m5f1(17 downto 0));
				write (buff,string'(" }"));				
				writeline(fbuff,buff);
				wait for tclk;
				if now>theend then
					wait;
				end if;
			end loop displayRom;			
		end process tbproc1;
		
		tbproc2: 
		process
			variable buff : line;
			variable theend : time :=30855 ns;
			file rbuff : text open write_mode is "TRACE_results_content.csv";
		begin
			
			write(buff,string'("#UF results test benching"));
			writeline(rbuff, buff);
			write(buff,string'("#{Time} {CPX,CPY,CPZ}{DP0,DP1}"));
			writeline(rbuff, buff);
			
			wait for 5 ns; 
			wait until rst=not(rstMasterValue);
			wait until clk='1';
			wait for tclk2+tclk4; --! Garantizar la estabilidad de los datos que se van a observar en la salida.
			displayRom:
			loop
				write (buff,string'(" { "));
				write (buff,now,unit =>ns);				
				write (buff,string'(" }{ "));
				hexwrite_0 (buff,stage1a0(31 downto 0));
				write (buff,string'(","));
				hexwrite_0 (buff,stage1a1(31 downto 0));
				write (buff,string'(","));
				hexwrite_0 (buff,stage1a2(31 downto 0));
				write (buff,string'(" }{ "));
				hexwrite_0 (buff,stage2a3(31 downto 0));
				write (buff,string'("}{"));
				hexwrite_0 (buff,stage2a4(31 downto 0));
				write (buff,string'(" }"));				
				writeline(rbuff,buff);
				wait for tclk;
				if now>theend then
					wait;
				end if;
			end loop displayRom;			
		end process tbproc2;	

	end generate tbgen;
	dontUseIeee:
	if use_std_logic_signed="NO" generate
		--! Adder 0, 16 bit carry lookahead low adder.
		a0low : adder
		generic map (16,carry_logic,"YES")	-- Carry Look Ahead Logic (More Gates Used, But Less Time)
										-- Yes instantiate Xor gates stage in the adder so we can substract on the opcode signal command.
		port map	(stage1p0(15 downto 0),stage1p1(15 downto 0),stageSRopcode,'0',stage1a0(15 downto 0),stage1_internalCarry(0));
		--Adder 0, 16 bit carry lookahead high adder.
		a0high : adder 
		generic map (16,carry_logic,"YES")	-- Carry Look Ahead Logic (More Gates Used, But Less Time)
										-- Yes instantiate Xor gates stage in the adder so we can substract on the opcode signal command.
		port map	(stage1p0(31 downto 16),stage1p1(31 downto 16),stageSRopcode,stage1_internalCarry(0),stage1a0(31 downto 16),open);
		--! Adder 1, 16 bit carry lookahead low adder. 
		a1low : adder 
		generic map (16,carry_logic,"YES")	-- Carry Look Ahead Logic (More Gates Used, But Less Time)
										-- Yes instantiate Xor gates stage in the adder so we can substract on the opcode signal command.
		port map	(stage1p2(15 downto 0),stage1p3(15 downto 0),'1','0',stage1a1(15 downto 0),stage1_internalCarry(1));
		--! Adder 1, 16 bit carry lookahead high adder.
		a1high : adder 
		generic map (16,carry_logic,"YES")	-- Carry Look Ahead Logic (More Gates Used, But Less Time)
										-- Yes instantiate Xor gates stage in the adder so we can substract on the opcode signal command.
		port map	(stage1p2(31 downto 16),stage1p3(31 downto 16),'1',stage1_internalCarry(1),stage1a1(31 downto 16),open);	
		--! Adder 2, 16 bit carry lookahead low adder. 
		a2low : adder 
		generic map (16,carry_logic,"YES")	-- Carry Look Ahead Logic (More Gates Used, But Less Time)
										-- Yes instantiate Xor gates stage in the adder so we can substract on the opcode signal command.
		port map	(stage1p4(15 downto 0),stage1p5(15 downto 0),stageSRopcode,'0',stage1a2(15 downto 0),stage1_internalCarry(2));
		--! Adder 2, 16 bit carry lookahead high adder.
		a2high : adder 
		generic map (16,carry_logic,"YES")	-- Carry Look Ahead Logic (More Gates Used, But Less Time)
										-- Yes instantiate Xor gates stage in the adder so we can substract on the opcode signal command.
		port map	(stage1p4(31 downto 16),stage1p5(31 downto 16),stageSRopcode,stage1_internalCarry(2),stage1a2(31 downto 16),open);
		-- Adder Instantiation (Stage 2)
		--! Adder 3, 16 bit carry lookahead low adder. 
		a3low : adder 
		generic map (16,carry_logic,"NO")		-- Carry Look Ahead Logic (More Gates Used, But Less Time)
										-- Dont instantiate Xor gates stage in the adder.
		port map	(stage2a0(15 downto 0),stage2p2(15 downto 0),'0','0',stage2a3(15 downto 0),stage2_internalCarry(0));
		--Adder 3, 16 bit carry lookahead high adder.
		a3high : adder 
		generic map (16,carry_logic,"NO")		-- Carry Look Ahead Logic (More Gates Used, But Less Time)
										-- Dont instantiate Xor gates stage in the adder.
		port map	(stage2a0(31 downto 16),stage2p2(31 downto 16),'0',stage2_internalCarry(0),stage2a3(31 downto 16),open);
		--! Adder 4, 16 bit carry lookahead low adder. 
		a4low : adder 
		generic map (16,carry_logic,"NO")		-- Carry Look Ahead Logic (More Gates Used, But Less Time)
										-- Dont instantiate Xor gates stage in the adder.
		port map	(stage2p3(15 downto 0),stage2a2(15 downto 0),'0','0',stage2a4(15 downto 0),stage2_internalCarry(1));
		--! Adder 4, 16 bit carry lookahead high adder.
		a4high : adder 
		generic map (16,carry_logic,"NO")		-- Carry Look Ahead Logic (More Gates Used, But Less Time)
										-- Dont instantiate Xor gates stage in the adder.
		port map	(stage2p3(31 downto 16),stage2a2(31 downto 16),'0',stage2_internalCarry(1),stage2a4(31 downto 16),open);
			
	end generate dontUseIeee;
	
	
	
end uf_arch;
