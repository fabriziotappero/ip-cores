--  File Name     :  out_trans.pat					     --
--  Description   :  The test patterns of the output transformation 	     --
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

-- for multiplier --
in   x1(15 downto 0) X;;
in   z1(15 downto 0) X;;
-- for adder	  --
in   x3(15 downto 0) X;;
in   z2(15 downto 0) X;;
-- for adder      --
in   x2(15 downto 0) X;;
in   z3(15 downto 0) X;;
-- for multiplier --
in   x4(15 downto 0) X;;
in   z4(15 downto 0) X;;

in   en;;
in   reset;;

-- multiplier output --
out  y1(15 downto 0) X;;
-- adder output      --
out  y2(15 downto 0) X;;
-- adder output      --
out  y3(15 downto 0) X;;
-- multiplier output --
out  y4(15 downto 0) X;;

begin
path_1  : 1 0  0000 0000  0000 0000  0000 0000  0000 0000 1 0  ?****  ?****  ?****  ?****;
path_2  : 1 0  0000 0000  0000 0000  0000 0000  0000 0000 0 0  ?****  ?****  ?****  ?****;
path_3  : 1 0  0001 0000  0000 00AB  0000 00AB  0001 0000 1 0  ?****  ?****  ?****  ?****; 
path_4  : 1 0  0001 0000  0000 00AB  0000 00AB  0001 0000 0 0  ?****  ?****  ?****  ?****;
path_5  : 1 0  0001 0001  0000 CDAB  0000 CDAB  0001 0001 1 0  ?****  ?****  ?****  ?****;
path_6  : 1 0  0001 0001  0000 CDAB  0000 CDAB  0001 0001 0 0  ?****  ?****  ?****  ?****;
path_7  : 1 0  0111 0010  00AB 0000  00AB 0000  0111 0010 1 0  ?****  ?****  ?****  ?****;
path_8  : 1 0  0111 0010  00AB 0000  00AB 0000  0111 0010 0 0  ?****  ?****  ?****  ?****;
path_9  : 1 0  0AAA 0010  CDAB 0000  CDAB 0000  0AAA 0010 1 0  ?****  ?****  ?****  ?****;
path_10 : 1 0  0AAA 0010  CDAB 0000  CDAB 0000  0AAA 0010 0 0  ?****  ?****  ?****  ?****;
path_11 : 1 0  789A AAAA  CDAB 8888  CDAB 8888  789A AAAA 1 0  ?****  ?****  ?****  ?****;
path_12 : 1 0  789A AAAA  CDAB 8888  CAAB 8888  789A 789A 0 0  ?****  ?****  ?****  ?****;
path_13 : 1 0  2345 1000  8888 FFFF  8888 FFFF  2345 1000 1 0  ?****  ?****  ?****  ?****;
path_14 : 1 0  2345 1000  8888 FFFF  8888 FFFF  2345 1000 0 0  ?****  ?****  ?****  ?****;
path_15 : 1 0  FFFF 0001  EEEE CCCC  EEEE CCCC  FFFF 0001 1 0  ?****  ?****  ?****  ?****;
path_16 : 1 0  FFFF 0001  EEEE CCCC  EEEE CCCC  FFFF 0001 0 0  ?****  ?****  ?****  ?****;
path_17 : 1 0  0000 1111  ABCD 4444  ABCD 4444  0000 1111 1 0  ?****  ?****  ?****  ?****;
path_18 : 1 0  0000 1111  ABCD 4444  ABCD 4444  0000 1111 0 0  ?****  ?****  ?****  ?****;
path_19 : 1 0  0010 ABCD  0A0A FCFC  0A0A FCFC  0010 ABCD 1 0  ?****  ?****  ?****  ?****;
path_20 : 1 0  0010 ABCD  0A0A FCFC  0A0A FCFC  0010 ABCD 0 0  ?****  ?****  ?****  ?****;

end; 
