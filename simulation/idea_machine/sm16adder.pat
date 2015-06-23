--  File Name     :  sm16adder.pat					     --
--  Description   :  The test patterns of the synchronized modulo 2^16 adder --
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
in   a(15 downto 0) X;;
in   b(15 downto 0) X;;
in   en ;;
in   clr ;;
out  s(15 downto 0) X;;

begin
path_1  : 1 0  0000 0000  1 0  ?0000;
path_2  : 1 0  0000 0000  0 0  ?0000;
path_3  : 1 0  0000 00AB  1 0  ?00AB;
path_4  : 1 0  0000 00AB  0 0  ?00AB;
path_5  : 1 0  0000 CDAB  1 0  ?CDAB;
path_6  : 1 0  0000 CDAB  0 0  ?CDAB;
path_7  : 1 0  00AB 0000  1 0  ?00AB;
path_8  : 1 0  00AB 0000  0 0  ?00AB;
path_9  : 1 0  CDAB 0000  1 0  ?CDAB;
path_10 : 1 0  CDAB 0000  0 0  ?CDAB;
path_11 : 1 0  CDAB 8888  1 0  ?5633;
path_12 : 1 0  CDAB 8888  0 0  ?5633;
path_13 : 1 0  8888 FFFF  1 0  ?8887;
path_14 : 1 0  8888 FFFF  0 0  ?8887;
path_15 : 1 0  EEEE CCCC  1 0  ?BBBA;
path_16 : 1 0  EEEE CCCC  0 0  ?BBBA;
end; 
