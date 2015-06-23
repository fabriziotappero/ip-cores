set mytest [file link stimulus.v]
set mytest [file rootname [file tail $mytest]]

coverage -setup -testname $mytest -dut tb_openMSP430.dut

run
quit

