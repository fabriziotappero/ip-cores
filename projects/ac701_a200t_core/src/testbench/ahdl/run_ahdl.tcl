#
# AHDL regression script.
#


# ROOT/TC folders, etc:
#
set ROOT   [pwd]

set FAIL_MSG "TEST finished with ERR"
set PASS_MSG "TEST finished successfully"

set glbl_log "src/testbench/log/global_tc_summary.log"
		 	
cd $dsn		

set    glbl_log_file [open $glbl_log w]
puts  $glbl_log_file "Global AMBPEX5_WISHBONE TC log:"
close $glbl_log_file

#
# Procedure:
#
proc set_and_run {} {
	 set StdArithNoWarnings   1
	 set NumericStdNoWarnings 1
	 set BreakOnAssertion     2

	run -all

	quit -sim
}

proc parse_log { filename tc_name } {
	set err_cnt 0
	set openfile [open $filename r]
	set ret 0
	while {[gets $openfile buffer] >= 0} {
 
		set ret [string first $::PASS_MSG $buffer  1]
		#echo $ret
		if { $ret>0 } {
			incr err_cnt
		}
		
	}
	if {$err_cnt>0} {return "$tc_name PASSED"} else {return "$tc_name FAILED"}
	close $openfile
}
	   
proc run_test { tc_name tc_id tc_time } {
 set log_name  "src/testbench/log/console_"
 set log_name $log_name$tc_name.log
 
 #set log_test  "src\\testbench\\log\\file_"
 #set log_test $log_test$tc_name.log		   
 
 
	transcript to $log_name
	asim -noglitch -noglitchmsg +notimingchecks +no_tchk_msg -relax glbl -ieee_nowarn -O5 -L secureip -g test_id=$tc_id +access +r +m+$tc_name stend_ambpex5_wishbone stend_ambpex5_wishbone
	#asim -ieee_nowarn -g test_id=$tc_id -g test_log=$log_test   +access +r +m+$tc_name stend_sp605_wishbone stend_sp605_wishbone
	run $tc_time	
	endsim;		
	
	set    glog_file [open $::glbl_log a]
	puts  $glog_file [parse_log $log_name $tc_name ]
	close $glog_file
	
}
	   
#
# Main BODY:
#

#
# 
cd $dsn

#
#
onerror {resume}
		
#run_test "test_dsc_incorrect"  0  "300 us"
#run_test "test_read_4kB"  	   1  "300 us"
run_test "test_adm_read_8kb"   2  "350 us"

exit