--  File Name     :  comp2.pat						      --
--  Description   :  The test patterns of the special comparator 	      --
--		     resulting an integer 2^16 or an integer 0 on 16-bit data --
--		     for the normal verification of 		              --
--		     the behavioral & structural view with zero delay         --
--  Purpose       :  To be used by ASIMUT				      --
--  Date          :  Aug 22, 2001					      --
--  Version       :  1.1						      --
--  Author        :  Martadinata A.					      --
--  Address       :  VLSI RG, Dept. of Electrical Engineering		      --
--                   ITB, Bandung, Indonesia				      --
--  E-mail	  :  marta@ic.vlsi.itb.ac.id				      --

in   vdd;;
in   vss;;
in   p(15 downto 0) X;;
in   q(15 downto 0) X;;
out  kout2(15 downto 0) X;;

begin
path_1  : 1 0   0000 0000  ?0001;
path_2  : 1 0   2222 2222  ?0001;
path_3  : 1 0   CCCC CCCC  ?0001;
path_4  : 1 0   DDDD DDDD  ?0001;
path_5  : 1 0   EEEE EEEE  ?0001;
path_6  : 1 0   FFFF FFFF  ?0001;
path_7  : 1 0   3333 6666  ?0001;
path_8  : 1 0   3333 5678  ?0001;
path_9  : 1 0   1234 1235  ?0001;
path_10 : 1 0   0000 0001  ?0001;
path_11 : 1 0   0001 0010  ?0001;
path_12 : 1 0   CCCC 2222  ?0000;
path_13 : 1 0   FF3A 1110  ?0000;
path_14 : 1 0   2220 1100  ?0000;
path_15 : 1 0   3345 0000  ?0000;
path_16 : 1 0   FFFF 0000  ?0000;
end; 
