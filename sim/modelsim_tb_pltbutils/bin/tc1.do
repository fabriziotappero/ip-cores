# tc1.do
# ModelSim do script for compiling and running simulation  

set vsim_arg ""
if {$argc >= 1} {
  set vsim_arg $1
}

do comp.do  
vsim -l ../log/tc1.log $vsim_arg tb_pltbutils
#do log.do
do ../bin/wave.do
run 1 ms

    