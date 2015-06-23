--  File Name     :  fsub.pat					        --
--  Description   :  The test patterns of the full subtractor	        --
--                   for the normal verification of the behavioral &    --
--                   structural view with zero delay                    --
--  Purpose       :  To be used by ASIMUT 				--
--  Date          :  Aug 22, 2001					--
--  Version       :  1.1						--
--  Author        :  Martadinata A.					--
--  Address       :  VLSI RG, Dept. of Electrical Engineering ITB       --
--                   Bandung, Indonesia					--
--  E-mail        :  marta@ic.vlsi.itb.ac.id				--

in   vdd;;
in   vss;;
in   a;;
in   b;;
in   bin;;
out  d;;
out  bout;;

begin
path_1  : 1 0  0 0 0  ?0 ?0;
path_2  : 1 0  0 0 1  ?1 ?1;
path_3  : 1 0  0 1 0  ?1 ?1;
path_4  : 1 0  0 1 1  ?0 ?1;
path_5  : 1 0  1 0 0  ?1 ?0;
path_6  : 1 0  1 0 1  ?0 ?0;
path_7  : 1 0  1 1 0  ?0 ?0; 
path_8  : 1 0  1 1 1  ?1 ?1; 
end; 
