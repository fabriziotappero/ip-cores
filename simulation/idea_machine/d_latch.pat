-- File Name   :  d_latch.pat						-- 
-- Description :  The test patterns of the D Latch			--
--		  for the normal verification of the structural view	--	
--		  with zero delay					--
-- Purpose     :  To be used by ASIMUT					--
-- Date        :  Aug 21, 2001						--
-- Version     :  1.1							--
-- Author      :  Martadinata A.					--
-- Address     :  VLSI RG, Dept, of Electrical Engineering ITB,		--	
--		  Bandung, Indonesia					--
-- E-mail      :  marta@ic.vlsi.itb.ac.id				--	

in   vdd;;
in   vss;;
in   d;;
in   ck;;
in   clr;;
out  q;;

begin
path_1  : 1 0  0  1 0 ?0;
path_2  : 1 0  1  0 0 ?0;
path_3  : 1 0  1  1 0 ?1;
path_4  : 1 0  0  0 0 ?1;
path_5  : 1 0  0  1 0 ?0;
path_6  : 1 0  0  0 0 ?0;
path_7  : 1 0  1  1 0 ?1;
path_8  : 1 0  1  0 1 ?0;
path_9  : 1 0  1  1 1 ?0;
path_10 : 1 0  1  0 1 ?0;
path_11 : 1 0  0  1 1 ?0;
path_12 : 1 0  1  0 0 ?0;
path_13 : 1 0  1  1 0 ?1;
path_14 : 1 0  0  0 0 ?1;
path_15 : 1 0  0  1 0 ?0;
path_16 : 1 0  1  0 0 ?0;
path_17 : 1 0  1  1 0 ?1;
path_18 : 1 0  1  0 0 ?1;
path_19 : 1 0  0  1 0 ?0;
path_20 : 1 0  0  0 0 ?0;
end; 
