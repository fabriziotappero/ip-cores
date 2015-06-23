--
-- ALU del procesador MIPS Segmentado
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

library ieee;
use ieee.STD_LOGIC_1164.all;

library work;
use work.records_pkg.all;
use work.segm_mips_const_pkg.all;

entity ALU is 
	generic (N: NATURAL);
	port(
		X	: in STD_LOGIC_VECTOR(N-1 downto 0);
		Y	: in STD_LOGIC_VECTOR(N-1 downto 0);
		ALU_IN	: in ALU_INPUT;
		R	: out STD_LOGIC_VECTOR(N-1 downto 0);
		FLAGS	: out ALU_FLAGS
	);
end;

architecture ALU_ARC of ALU is

-- Declaración de componentes
	component ALU_1BIT is 
		port(
			X	: in STD_LOGIC;
			Y	: in STD_LOGIC;
			LESS	: in STD_LOGIC;
			BINVERT : in STD_LOGIC;
			CIN	: in STD_LOGIC;
			OP1	: in STD_LOGIC;
			OP0	: in STD_LOGIC;
			RES	: out STD_LOGIC;
			COUT	: out STD_LOGIC;
			SET	: out STD_LOGIC
		);
	end component ALU_1BIT;

-- Declaración de señales

	signal LESS_AUX : STD_LOGIC; 
	signal COUT_AUX : STD_LOGIC_VECTOR(N-1 downto 0);
	signal R_AUX	: STD_LOGIC_VECTOR(N-1 downto 0);

begin
	
	BEGIN_ALU1B:
		ALU_1BIT port map (
				X	=> X(0),
				Y	=> Y(0),
				LESS	=> LESS_AUX,
				BINVERT => ALU_IN.Op2,
				CIN	=> ALU_IN.Op2,
				OP1	=> ALU_IN.Op1,
				OP0	=> ALU_IN.Op0,					
				RES	=> R_AUX(0),
				COUT	=> COUT_AUX(0)
		);
								
	GEN_ALU:
		for i in 1 to N-2 generate
			NEXT_ALU1B:
				ALU_1BIT port map (
					X	=> X(i),
					Y	=> Y(i),
					LESS	=> '0',
					BINVERT => ALU_IN.Op2,
					CIN	=> COUT_AUX(i-1),
					OP1	=> ALU_IN.Op1,
					OP0	=> ALU_IN.Op0,
					RES	=> R_AUX(i),
					COUT	=> COUT_AUX(i)
				);
		end generate;

	LAST_ALU1B:
		ALU_1BIT port map (
			X	=> X(N-1),
			Y	=> Y(N-1),
			LESS	=> '0',
			BINVERT => ALU_IN.Op2,
			CIN	=> COUT_AUX(N-2),
			OP1	=> ALU_IN.Op1,
			OP0	=> ALU_IN.Op0,
			RES	=> R_AUX(N-1),
			COUT	=> COUT_AUX(N-1),
			SET	=> LESS_AUX
		);
			
	FLAGS.Carry <= COUT_AUX(N-1);
	FLAGS.Overflow <= COUT_AUX(N-1) xor COUT_AUX(N-2) ;
	FLAGS.Negative <= '1' when R_AUX(N-1)='1' else '0';
	FLAGS.Zero <= '1' when R_AUX= ZERO32b else '0';

	ALU_RES:
		process(ALU_IN.Op3,R_AUX,Y)
		begin
			if  ALU_IN.Op3='1' then
				R <= Y( ((N/2)-1) downto 0) & ZERO16b;
			else
				R <= R_AUX;
			end if;
		end process;

end ALU_ARC;
