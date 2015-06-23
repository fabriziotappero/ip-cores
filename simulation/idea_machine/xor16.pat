--  File Name     :  xor16.pat					             --
--  Description   :  The test patterns of the 16-bit xor                     --
--                   for the normal verification of the structural view      --
--                   with zero delay                                         --
--  Purpose       :  To be used by ASIMUT 				     --
--  Date          :  Aug 23, 2001					     --
--  Version       :  1.1						     --
--  Author        :  Martadinata A.					     --
--  Address       :  VLSI RG, Dept. of Electrical Engineering ITB            --
--                   Bandung, Indonesia					     --
--  E-mail        :  marta@ic.vlsi.itb.ac.id				     --

in   vdd;;
in   vss;;
in   a(15 downto 0) X;;
in   b(15 downto 0) X;;
out  q(15 downto 0) X;;

begin
path_1  : 1 0  0000 0000  ?0000;
path_3  : 1 0  0000 00AB  ?00AB;
path_5  : 1 0  0000 CDAB  ?CDAB;
path_7  : 1 0  00AB 0000  ?00AB;
path_9  : 1 0  CDAB 0000  ?CDAB;
path_11 : 1 0  CDAB 8888  ?4523;
path_13 : 1 0  8888 FFFF  ?7777;
path_15 : 1 0  EEEE CCCC  ?2222;
end; 
