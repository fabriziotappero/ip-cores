setMode -bs
setCable -port auto
Identify
setAttribute -position 2 -attr devicePartName -value "xcf04s"
setAttribute -position 2 -attr configFileName -value "digilent-xc3s1600e_0.mcs"
setAttribute -position 3 -attr devicePartName -value "xcf04s"
setAttribute -position 3 -attr configFileName -value "digilent-xc3s1600e_1.mcs"
Program -p 2 3 -e -v 
quit
