setMode -bs
setCable -port auto
Identify
setAttribute -position 1 -attr configFileName -value "digilent-xc3s1600e.bit"
Program -p 1 -e -v
quit
