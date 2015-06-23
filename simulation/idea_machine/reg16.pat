-- File Name   :  reg16.pat						-- 
-- Description :  The test patterns of the 16-bit register		--
--		  for the normal verification of the structural view	--	
--		  with zero delay					--
-- Purpose     :  To be used by ASIMUT					--
-- Date        :  Aug 22, 2001						--
-- Version     :  1.1							--
-- Author      :  Martadinata A.					--
-- Address     :  VLSI RG, Dept, of Electrical Engineering ITB,		--	
--		  Bandung, Indonesia					--
-- E-mail      :  marta@ic.vlsi.itb.ac.id				--	

in   vdd;;
in   vss;;
in   d(15 downto 0) X;;
in   en;;
in   clr;;
out  q(15 downto 0) X;;

begin
path_1  : 1 0  0000  1 0 ?0000;
path_2  : 1 0  1111  0 0 ?0000;
path_3  : 1 0  1111  1 0 ?1111;
path_4  : 1 0  0000  0 0 ?1111;
path_5  : 1 0  0000  1 0 ?0000;
path_6  : 1 0  0000  0 0 ?0000;
path_7  : 1 0  1111  1 0 ?1111;
path_8  : 1 0  1111  0 1 ?0000;
path_9  : 1 0  1111  1 1 ?0000;
path_10 : 1 0  1111  0 1 ?0000;
path_11 : 1 0  0000  1 1 ?0000;
path_12 : 1 0  1111  0 0 ?0000;
path_13 : 1 0  1111  1 0 ?1111;
path_14 : 1 0  0000  0 0 ?1111;
path_15 : 1 0  0000  1 0 ?0000;
path_16 : 1 0  1111  0 0 ?0000;
path_17 : 1 0  1111  1 0 ?1111;
path_18 : 1 0  1111  0 0 ?1111;
path_19 : 1 0  0000  1 0 ?0000;
path_20 : 1 0  0000  0 0 ?0000;
end; 
