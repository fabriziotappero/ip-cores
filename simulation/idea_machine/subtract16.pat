--  File Name     :  subtract16.pat					--
--  Description   :  The test patterns of the subtractor 16-bit         --
--                   for the normal verification of the structural view --
--  Purpose       :  To be used by ASIMUT 				--
--  Date          :  Aug 22, 2001					--
--  Version       :  1.1						--
--  Author        :  Martadinata A.					--
--  Address       :  VLSI RG, Dept. of Electrical Engineering ITB       --
--                   Bandung, Indonesia					--
--  E-mail        :  marta@ic.vlsi.itb.ac.id				--

in   vdd;;
in   vss;;
in   a(15 downto 0) X;;
in   b(15 downto 0) X;;
out  s(15 downto 0) X;;

begin
-- for a >= b
path_1  : 1 0  0000 0000  ?0000;
path_2  : 1 0  0009 0006  ?0003;
path_3  : 1 0  000A 0006  ?0004;
path_4  : 1 0  6666 5555  ?1111;
path_5  : 1 0  6666 55FF  ?1067;
path_6  : 1 0  FFFF 1234  ?EDCB;
path_7  : 1 0  6555 5DDD  ?0778; 
path_8  : 1 0  6688 2323  ?4365; 
path_9  : 1 0  AABB 99FF  ?10BC; 
path_10 : 1 0  AA00 0001  ?A9FF;  

--  for a < b
path_11 : 1 0  0005 0006  ?FFFF;
path_12 : 1 0  0005 0007  ?FFFE;
path_13 : 1 0  0005 0008  ?FFFD;
path_14 : 1 0  0005 0009  ?FFFC;
path_15 : 1 0  0005 0009  ?FFFC;
path_16 : 1 0  1234 1236  ?FFFE;
path_17 : 1 0  AAAA BB78  ?EF32;
path_18 : 1 0  8877 FFFF  ?8878;
path_19 : 1 0  EEFF FFFF  ?EF00;
path_20 : 1 0  FAFA FFFF  ?FAFB;
end; 
