--  File Name     :  halfadder.pat					--
--  Description   :  The test patterns of the half adder		--
--                   for the normal verification of the behavioral view --
--  Date          :  Aug 21, 2001					--
--  Version       :  1.1						--
--  Author        :  Martadinata A.					--
--                   VLSI RG, Dept. of Electrical Engineering ITB       --
--                   Bandung, Indonesia					--

in   vdd;;
in   vss;;
in   a;;
in   b;;
out  sout;;
out  cout;;

begin
path_1  : 1 0   0 0   ?0 ?0;
path_2  : 1 0   0 1   ?1 ?0;
path_3  : 1 0   1 0   ?1 ?0;
path_4  : 1 0   1 1   ?0 ?1;
end; 
