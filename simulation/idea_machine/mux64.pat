--  File Name     :  mux64.pat						--
--  Description   :  The test patterns of the 64-bit 2-to-1 multiplexer --
--                   for the normal verification of the behavioral &    --
--                   structural view with zero delay                    --
--  Purpose       :  To be used by ASIMUT				--
--  Date          :  Aug 21, 2001					--
--  Version       :  1.1						--
--  Author        :  Martadinata A.					--
--  Address       :  VLSI RG, Dept. of Electrical Engineering		--
--                   ITB, Bandung, Indonesia				--
--  E-mail	  :  marta@ic.vlsi.itb.ac.id				--

in   vdd;;
in   vss;;
in   a(63 downto 0) X;;
in   b(63 downto 0) X;;
in   sel;;
out  c(63 downto 0) X ;;

begin
path_1  : 1 0   0000000000000000 0000000000000000 0 ?0000000000000000;
path_2  : 1 0   12AB12AB12AB12AB 34CD34CD34CD34CD 0 ?12AB12AB12AB12AB;
path_3  : 1 0   12AB12AB12AB12AB 34CD34CD34CD34CD 1 ?34CD34CD34CD34CD;
path_4  : 1 0   5678567856785678 ABCDABCDABCDABCD 0 ?5678567856785678;
path_5  : 1 0   5678567856785678 ABCDABCDABCDABCD 1 ?ABCDABCDABCDABCD; 
end; 
