--The modulo 2^16+1 multiplier
in   vdd;;
in   vss;;
in   in1(15 downto 0) X;;
in   in2(15 downto 0) X;;
in   en;;
in   clr;;
out  mulout(15 downto 0) X;;

begin
path_1  : 1 0  0000  0000  1 0  ?****;
path_2  : 1 0  0000  0000  0 0  ?****;
path_3  : 1 0  0001  0000  1 0  ?****; 
path_4  : 1 0  0001  0000  0 0  ?****;
path_5  : 1 0  0001  0001  1 0  ?****;
path_6  : 1 0  0001  0001  0 0  ?****;
path_7  : 1 0  0111  0010  1 0  ?****;
path_8  : 1 0  0111  0010  0 0  ?****;
path_9  : 1 0  0AAA  0010  1 0  ?****;
path_10 : 1 0  0AAA  0010  0 0  ?****;
path_11 : 1 0  789A  AAAA  1 0  ?****;
path_12 : 1 0  789A  AAAA  0 0  ?****;
path_13 : 1 0  2345  1000  1 0  ?****;
path_14 : 1 0  2345  1000  0 0  ?****;
path_15 : 1 0  FFFF  0001  1 0  ?****;
path_16 : 1 0  FFFF  0001  0 0  ?****;
path_17 : 1 0  0000  1111  1 0  ?****;
path_18 : 1 0  0000  1111  0 0  ?****;
path_19 : 1 0  0010  ABCD  1 0  ?****;
path_20 : 1 0  0010  ABCD  1 0  ?****;


end; 
