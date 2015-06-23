--  File Name     :  comp1.pat						 --
--  Description   :  The test patterns of the special comparator 	 --
--		     resulting a 17-bit integer 2^16 or the lower 17-bit --
--		     integers for the normal verification of 		 --
--		     the behavioral & structural view with zero delay    --
--  Purpose       :  To be used by ASIMUT				 --
--  Date          :  Aug 21, 2001					 --
--  Version       :  1.1						 --
--  Author        :  Martadinata A.					 --
--  Address       :  VLSI RG, Dept. of Electrical Engineering		 --
--                   ITB, Bandung, Indonesia				 --
--  E-mail	  :  marta@ic.vlsi.itb.ac.id				 --

in   vdd;;
in   vss;;
in   kin(15 downto 0);;
out  kout1(16 downto 0);;

begin
path_1  : 1 0   0000000000000000 ?10000000000000000;
path_2  : 1 0   0000000000000001 ?00000000000000001; 
path_3  : 1 0   0000000000111111 ?00000000000111111;
path_4  : 1 0   1111100000111111 ?01111100000111111;
path_5  : 1 0   0000011111000000 ?00000011111000000;
path_6  : 1 0   0000000000000000 ?10000000000000000;  
end; 
