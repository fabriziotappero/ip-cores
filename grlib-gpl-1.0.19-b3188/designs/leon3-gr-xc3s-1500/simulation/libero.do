cd ..
do libs.do
project open testbench.mpf
project compileoutofdate
vsim testbench
do wave.do
