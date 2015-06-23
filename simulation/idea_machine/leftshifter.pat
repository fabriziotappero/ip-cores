--  File Name     :  leftshifter.pat					     --
--  Description   :  The test patterns of the left shifter                   --
--                   for the normal verification of the structural view      --
--                   with zero delay                                         --
--  Purpose       :  To be used by ASIMUT 				     --
--  Date          :  Aug 22, 2001					     --
--  Version       :  1.1						     --
--  Author        :  Martadinata A.					     --
--  Address       :  VLSI RG, Dept. of Electrical Engineering ITB            --
--                   Bandung, Indonesia					     --
--  E-mail        :  marta@ic.vlsi.itb.ac.id				     --

in   vdd;;
in   vss;;
in   p(16 downto 0);;
in   q(15 downto 0);;
out  r0(31 downto 0) X;;
out  r1(31 downto 0) X;;
out  r2(31 downto 0) X;;
out  r3(31 downto 0) X;;
out  r4(31 downto 0) X;;
out  r5(31 downto 0) X;;
out  r6(31 downto 0) X;;
out  r7(31 downto 0) X;;
out  r8(31 downto 0) X;;
out  r9(31 downto 0) X;;
out  r10(31 downto 0) X;;
out  r11(31 downto 0) X;;
out  r12(31 downto 0) X;;
out  r13(31 downto 0) X;;
out  r14(31 downto 0) X;;
out  r15(31 downto 0) X;;
out  r16(31 downto 0) X;;

begin
path_1  : 1 0  01010101010101010  1000000011111110 ?******** ?******** ?******** ?******** ?********
						   ?******** ?******** ?******** ?******** ?********
						   ?******** ?******** ?******** ?******** ?********
						   ?******** ?********;
path_1  : 1 0  01010101010101010  1000100001000000 ?******** ?******** ?******** ?******** ?********
						   ?******** ?******** ?******** ?******** ?********
 						   ?******** ?******** ?******** ?******** ?********
   						   ?******** ?********; 
end; 
