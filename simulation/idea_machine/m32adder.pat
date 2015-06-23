--  File Name     :  m32adder.pat					--
--  Description   :  The test patterns of the modulo 2^32 adder		--
--                   for the normal verification of the structural view --
--                   with zero delay                                    --
--  Purpose       :  To be used by ASIMUT 				--
--  Date          :  Aug 21, 2001					--
--  Version       :  1.1						--
--  Author        :  Martadinata A.					--
--  Address       :  VLSI RG, Dept. of Electrical Engineering ITB       --
--                   Bandung, Indonesia					--
--  E-mail        :  marta@ic.vlsi.itb.ac.id				--

in   vdd;;
in   vss;;
in   a(31 downto 0) X;;
in   b(31 downto 0) X;;
out  sum(31 downto 0) X;;

begin
path_1  : 1 0  00000000 00000000  ?00000000;
path_2  : 1 0  00000000 00AB00AB  ?00AB00AB;
path_3  : 1 0  00000000 CDABCDAB  ?CDABCDAB;
path_4  : 1 0  0000ABAB 00000000  ?0000ABAB;
path_5  : 1 0  CDABCDAB 00000000  ?CDABCDAB;
path_6  : 1 0  CDABCDAB 88888888  ?56345633;
path_7  : 1 0  88888888 FFFFFFFF  ?88888887;
path_8  : 1 0  EEEEEEEE CCCCCCCC  ?BBBBBBBA;
end; 
