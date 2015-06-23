setMode -bscan
setCable -p auto
identify
assignfile -p 4 -file implementation/download.bit
program -p 4
quit
