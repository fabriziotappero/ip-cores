
vlog +define+DEBUG "../../src/tb_top.v"

vsim -voptargs=+acc -l transcript.txt -t 1ps work.tb_top 

#do wave.do
