

rem -------------------- fcmp 

pg -q -r 0 -fcmp -p 0          -o fcmp/fcmp_pat0.hex

pg -q -r 0 -fcmp -p 1          -o fcmp/fcmp_pat1.hex

pg -q -r 0 -fcmp -p 2          -o fcmp/fcmp_pat2.hex

pg -q -r 0 -fcmp -n 199990 -ll -o fcmp/fcmp_lg.hex

pg -q -r 0 -fcmp -n 199990     -o fcmp/fcmp_sm.hex

