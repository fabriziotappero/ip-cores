--  File Name     :  mul17.pat						--
--  Description   :  The test patterns of the 17-bit multiplier         --
--                   for the normal verification of the structural view -- 
--           	     with zero delay                                    --
--  Purpose       :  To be used by ASIMUT 				--
--  Date          :  Aug 23, 2001					--
--  Version       :  1.1						--
--  Author        :  Martadinata A.					--
--  Address       :  VLSI RG, Dept. of Electrical Engineering ITB       --
--                   Bandung, Indonesia					--
--  E-mail        :  marta@ic.vlsi.itb.ac.id				--

in   vdd;;
in   vss;;
in   a(16 downto 0);;
in   b(16 downto 0);;
out  sum(31 downto 0) X;;

begin
path_1  : 1 0  00000000000000000 00000000000000000  ?00000000; 
path_2  : 1 0  00000000000000001 00000000000000000  ?00000000; 
path_3  : 1 0  00000000000000001 00000000000000001  ?00000001;
path_4  : 1 0  00000000000000111 00000000000000010  ?0000000E;
path_5  : 1 0  00000000000001000 00000000000000100  ?00000020;
path_6  : 1 0  00000000011111111 00000000000000001  ?000000FF;
path_7  : 1 0  00111111111111111 00000000000000001  ?00007FFF;
path_8  : 1 0  00111111111111111 00000000000000010  ?0000FFFE;
path_9  : 1 0  11111111111111111 00000000000000001  ?0001FFFF;
path_10 : 1 0  11111111111111111 00000000011111111  ?01FDFF01;
path_11 : 1 0  10000000000000000 01111111111111111  ?FFFF0000;
path_12 : 1 0  10000000000000000 01000100010001000  ?88880000; 
end; 
