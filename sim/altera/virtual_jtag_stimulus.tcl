##**************************************************************
## Module             : virtual_jtag_console.tcl
## Platform           : Windows xp sp2
## Author             : Bibo Yang  (ash_riple@hotmail.com)
## Organization       : www.opencores.org
## Revision           : 2.2 
## Date               : 2012/03/28
## Description        : Tcl/Tk GUI for the simulation stimulus
##**************************************************************

proc reset_fifo {{jtag_index_0 0}} {
	#device_lock -timeout 5
	#device_virtual_ir_shift -instance_index $jtag_index_0 -ir_value 2 -no_captured_ir_value 
	#device_virtual_dr_shift -instance_index $jtag_index_0  -length 32 -dr_value 00000000 -value_in_hex -no_captured_dr_value 
	#device_unlock
	global sim_started
	if {$sim_started==0} {
		global fifo_sim_act
		global fifo_sim_num
		global fifo_sim_len
		append fifo_sim_act (0,1,2,[format "%X" 2]),
		set    fifo_sim_num [expr $fifo_sim_num+1]
		set    fifo_sim_len [expr $fifo_sim_len+2]
		append fifo_sim_act (0,2,0,[format "%X" 32]),
		set    fifo_sim_num [expr $fifo_sim_num+1]
		set    fifo_sim_len [expr $fifo_sim_len+32]
	} else {
		force -freeze /up_monitor_tb/MON_LO/inst/u_virtual_jtag_adda_fifo/reset 1 -cancel 10ns
		run 20ns
	}
	return 0
}

proc query_usedw {{jtag_index_0 0}} {
	#global fifoUsedw
	#device_lock -timeout 5
	#device_virtual_ir_shift -instance_index $jtag_index_0 -ir_value 1 -no_captured_ir_value
	#set usedw [device_virtual_dr_shift -instance_index $jtag_index_0 -length 9 -value_in_hex]
	#device_unlock
	#	set tmp 0x
	#	append tmp $usedw
	#	set usedw [format "%i" $tmp]
	#set fifoUsedw $usedw
	global sim_started
	if {$sim_started==0} {
		global fifo_sim_act
		global fifo_sim_num
		global fifo_sim_len
		append fifo_sim_act (0,1,1,[format "%X" 2]),
		set    fifo_sim_num [expr $fifo_sim_num+1]
		set    fifo_sim_len [expr $fifo_sim_len+2]
		append fifo_sim_act (0,2,0,[format "%X" 9]),
		set    fifo_sim_num [expr $fifo_sim_num+1]
		set    fifo_sim_len [expr $fifo_sim_len+9]
	} else {
		global fifoUsedw
		set usedw [format "%i" 0x[examine /up_monitor_tb/MON_LO/inst/u_virtual_jtag_adda_fifo/usedw]]
		set fifoUsedw $usedw
	}
	return 0
}

proc read_fifo {{jtag_index_0 0}} {
	#device_lock -timeout 5
	#device_virtual_ir_shift -instance_index $jtag_index_0 -ir_value 1 -no_captured_ir_value
	#device_virtual_ir_shift -instance_index $jtag_index_0 -ir_value 3 -no_captured_ir_value
	#set fifo_data [device_virtual_dr_shift -instance_index $jtag_index_0 -length 82 -value_in_hex]
	#device_unlock
	global sim_started
	if {$sim_started==0} {
		global fifo_sim_act
		global fifo_sim_num
		global fifo_sim_len
		append fifo_sim_act (0,1,1,[format "%X" 2]),
		set    fifo_sim_num [expr $fifo_sim_num+1]
		set    fifo_sim_len [expr $fifo_sim_len+2]
		append fifo_sim_act (0,1,3,[format "%X" 2]),
		set    fifo_sim_num [expr $fifo_sim_num+1]
		set    fifo_sim_len [expr $fifo_sim_len+2]
		append fifo_sim_act (0,2,0,[format "%X" 82]),
		set    fifo_sim_num [expr $fifo_sim_num+1]
		set    fifo_sim_len [expr $fifo_sim_len+82]
		return 000000000000000000000
	} else {
		force -freeze /up_monitor_tb/MON_LO/inst/u_virtual_jtag_adda_fifo/rd_en 1 -cancel 10ns
		run 20ns
		#after 10
		set fifo_data [examine /up_monitor_tb/MON_LO/inst/u_virtual_jtag_adda_fifo/data_out]
		return $fifo_data
	}
}

proc config_addr {{jtag_index_1 1} {mask 0100000000} {mask_id 1}} {
	global log
	set mask_leng [string length $mask]
	if {$mask_leng!=10} {
		$log insert end "\nError: Wrong address mask length @$mask_id: [expr $mask_leng-2]. Expects: 8.\n"

	} else {
		#device_lock -timeout 5
		#device_virtual_ir_shift -instance_index $jtag_index_1 -ir_value 1 -no_captured_ir_value
		#set addr_mask [device_virtual_dr_shift -instance_index $jtag_index_1 -dr_value $mask -length 40 -value_in_hex]
		#device_unlock
		global addr_sim_act
		global addr_sim_num
		global addr_sim_len
		append addr_sim_act (0,1,1,[format "%X" 2]),
		set    addr_sim_num [expr $addr_sim_num+1]
		set    addr_sim_len [expr $addr_sim_len+2]
		append addr_sim_act (0,2,$mask,[format "%X" 40]),
		set    addr_sim_num [expr $addr_sim_num+1]
		set    addr_sim_len [expr $addr_sim_len+40]
		return 0
	}
}

proc config_trig {{jtag_index_2 2} {trig 00000000000000} {pnum 000}} {
	global log
	set trig_leng [string length $trig]
	if {$trig_leng!=14} {
		$log insert end "\nError: Wrong trigger condition length: [expr $trig_leng-2]. Expects: 4+8.\n"
	} else {
		#device_lock -timeout 5
		#device_virtual_ir_shift -instance_index $jtag_index_2 -ir_value 1 -no_captured_ir_value
		#set addr_trig [device_virtual_dr_shift -instance_index $jtag_index_2 -dr_value $trig -length 56 -value_in_hex]
		#device_virtual_ir_shift -instance_index $jtag_index_2 -ir_value 2 -no_captured_ir_value
		#set addr_trig [device_virtual_dr_shift -instance_index $jtag_index_2 -dr_value $pnum -length 10 -value_in_hex]
		#device_unlock
		global trig_sim_act
		global trig_sim_num
		global trig_sim_len
		append trig_sim_act (0,1,1,[format "%X" 2]),
		set    trig_sim_num [expr $trig_sim_num+1]
		set    trig_sim_len [expr $trig_sim_len+2]
		append trig_sim_act (0,2,$trig,[format "%X" 56]),
		set    trig_sim_num [expr $trig_sim_num+1]
		set    trig_sim_len [expr $trig_sim_len+56]
		append trig_sim_act (0,1,2,[format "%X" 2]),
		set    trig_sim_num [expr $trig_sim_num+1]
		set    trig_sim_len [expr $trig_sim_len+2]
		append trig_sim_act (0,2,$pnum,[format "%X" 10]),
		set    trig_sim_num [expr $trig_sim_num+1]
		set    trig_sim_len [expr $trig_sim_len+10]
		return 0
	}
} 

proc open_jtag_device {{test_cable "USB-Blaster [USB-0]"} {test_device "@2: EP2SGX90 (0x020E30DD)"}} {
	open_device -hardware_name $test_cable -device_name $test_device
	# Retrieve device id code.
	device_lock -timeout 5
	device_ir_shift -ir_value 6 -no_captured_ir_value
	set idcode "0x[device_dr_shift -length 32 -value_in_hex]"
	device_unlock
	return $idcode
}

proc close_jtag_device {} {
	close_device
}

proc scan_chain {} {
	global log
	$log insert end "JTAG Chain Scanning report:\n"
	$log insert end "****************************************\n"
	set blaster_cables [get_hardware_names]
	set cable_num 0
	foreach blaster_cable $blaster_cables {
		incr cable_num
		$log insert end "@$cable_num: $blaster_cable\n"
	}
	$log insert end "\n****************************************\n"
	global device_list
	set device_list ""
	foreach blaster_cable $blaster_cables {
		$log insert end "$blaster_cable:\n"
		lappend device_list $blaster_cable
		if [catch {get_device_names -hardware_name $blaster_cable} error_msg] {
			$log insert end $error_msg
			lappend device_list $error_msg
		} else {
			foreach test_device [get_device_names -hardware_name $blaster_cable] {
				$log insert end "$test_device\n"
			}
			lappend device_list [get_device_names -hardware_name $blaster_cable]
		}
	}
}

proc select_device {{cableNum 1} {deviceNum 1}} {
	global log
	global device_list
	$log insert end "\n****************************************\n"
	set test_cable [lindex $device_list [expr 2*$cableNum-2]]
	$log insert end "Selected Cable : $test_cable\n"
	set test_device [lindex [lindex $device_list [expr 2*$cableNum-1]] [expr $deviceNum-1]]
	$log insert end "Selected Device: $test_device\n"
	set jtagIdCode [open_jtag_device $test_cable $test_device]
	$log insert end "Device ID code : $jtagIdCode\n"
	reset_fifo 0
	query_usedw 0
}

proc updateAddrConfig {} {
	global address_span1
	global address_span2
	global address_span3
	global address_span4
	global address_span5
	global address_span6
	global address_span7
	global address_span8
	global address_span9
	global address_span10
	global address_span11
	global address_span12
	global address_span13
	global address_span14
	global address_span15
	global address_span16
	global address_span_en1
	global address_span_en2
	global address_span_en3
	global address_span_en4
	global address_span_en5
	global address_span_en6
	global address_span_en7
	global address_span_en8
	global address_span_en9
	global address_span_en10
	global address_span_en11
	global address_span_en12
	global address_span_en13
	global address_span_en14
	global address_span_en15
	global address_span_en16
	global addr_wren
	global addr_rden
	for {set i 1} {$i<=16} {incr i} {
		set    mask [format "%1X" [expr $i-1]]
		append mask [format "%1X" [expr $addr_wren*8+$addr_rden*4+[set address_span_en$i]]]
		append mask [set address_span$i]
		config_addr 1 $mask $i
	}
}

proc initAddrConfig {} {
	global log
	global address_span1
	global address_span2
	global address_span3
	global address_span4
	global address_span5
	global address_span6
	global address_span7
	global address_span8
	global address_span9
	global address_span10
	global address_span11
	global address_span12
	global address_span13
	global address_span14
	global address_span15
	global address_span16
	for {set i 1} {$i<=8} {incr i} {
		if {[set address_span$i]==""} {
			set address_span$i ffff0000
		}
	}
	for {set i 9} {$i<=16} {incr i} {
		if {[set address_span$i]==""} {
			set address_span$i 00000000
		}
	}
}

proc initTrigConfig {} {
	global triggerAddr
	global triggerData
	global triggerPnum
	if {[set triggerAddr]==""} {
		set triggerAddr ffff
	}
	if {[set triggerData]==""} {
		set triggerData a5a5a5a5
	}
	if {[set triggerPnum]==""} {
		set triggerPnum 0
	}
}

proc updateTrigger {{trigCmd 0}} {
	global triggerAddr
	global triggerData
	global triggerPnum
	global trig_wren
	global trig_rden
	global trig_aden
	global trig_daen
	set    triggerValue [format "%1X" [expr $trig_aden*8+$trig_daen*4+0]]
	append triggerValue [format "%1X" [expr $trig_wren*8+$trig_rden*4+$trigCmd]]
	append triggerValue $triggerAddr
	append triggerValue $triggerData
	config_trig 2 $triggerValue [format "%03X" $triggerPnum]
}

proc startTrigger {} {
	global trig_wren
	global trig_rden
	global trig_aden
	global trig_daen
	set trigEnable [expr $trig_wren+$trig_rden+$trig_aden+$trig_daen]
	if {$trigEnable>0} {
		updateTrigger 2
		reset_fifo 0
		query_usedw 0
		updateTrigger 3
	} else {
		updateTrigger 0
	}
}

proc reset_fifo_ptr {} {
	reset_fifo 0
	query_usedw 0
}

proc query_fifo_usedw {} {
	query_usedw 0
}

proc read_fifo_content {} {
	global log
	global fifoUsedw
	$log insert end "\n****************************************\n"
	for {set i 0} {$i<$fifoUsedw} {incr i} {
		set fifoContent [read_fifo 0]
		set ok_trig [expr [format "%d" 0x[string index $fifoContent 0]]/2]
		set wr_cptr [expr [format "%d" 0x[string index $fifoContent 0]]%2]
		set tm_cptr [format "%d"       0x[string range $fifoContent  1  8]]
		set ad_cptr                      [string range $fifoContent  9 12]
		set da_cptr                      [string range $fifoContent 13 20]
		if $ok_trig {
			$log insert end "@@@@@@@@@@@@@@@@@@@@\n"
		}
		if $wr_cptr {
			$log insert end "wr $ad_cptr $da_cptr @$tm_cptr\n"
		} else {
			$log insert end "rd $ad_cptr $da_cptr @$tm_cptr\n"
		}
	}
	query_usedw 0
}

proc reset_stimulus {} {
	global fifo_sim_act
	global fifo_sim_num
	global fifo_sim_len
	global addr_sim_act
	global addr_sim_num
	global addr_sim_len
	global trig_sim_act
	global trig_sim_num
	global trig_sim_len
	set fifo_sim_act \"(
	set fifo_sim_num 0
	set fifo_sim_len 0
	set addr_sim_act \"(
	set addr_sim_num 0
	set addr_sim_len 0
	set trig_sim_act \"(
	set trig_sim_num 0
	set trig_sim_len 0
}

proc generate_stimulus {} {
	global log
	global fifo_sim_act
	global fifo_sim_num
	global fifo_sim_len
	global addr_sim_act
	global addr_sim_num
	global addr_sim_len
	global trig_sim_act
	global trig_sim_num
	global trig_sim_len
	append fifo_sim_act (1,1,1,2))\"
	set    fifo_sim_num [expr $fifo_sim_num+1]
	set    fifo_sim_len [expr $fifo_sim_len+2]
	append addr_sim_act (1,1,1,2))\"
	set    addr_sim_num [expr $addr_sim_num+1]
	set    addr_sim_len [expr $addr_sim_len+2]
	append trig_sim_act (1,1,1,2))\"
	set    trig_sim_num [expr $trig_sim_num+1]
	set    trig_sim_len [expr $trig_sim_len+2]
	$log delete 1.0 end
	$log insert end "`define USE_SIM_STIMULUS\n\n"
	$log insert end "`define FIFO_SLD_SIM_ACTION $fifo_sim_act\n"
	$log insert end "`define FIFO_SLD_SIM_N_SCAN $fifo_sim_num\n"
	$log insert end "`define FIFO_SLD_SIM_T_LENG $fifo_sim_len\n\n"
	$log insert end "`define ADDR_SLD_SIM_ACTION $addr_sim_act\n"
	$log insert end "`define ADDR_SLD_SIM_N_SCAN $addr_sim_num\n"
	$log insert end "`define ADDR_SLD_SIM_T_LENG $addr_sim_len\n\n"
	$log insert end "`define TRIG_SLD_SIM_ACTION $trig_sim_act\n"
	$log insert end "`define TRIG_SLD_SIM_N_SCAN $trig_sim_num\n"
	$log insert end "`define TRIG_SLD_SIM_T_LENG $trig_sim_len\n\n"

	set fileId [open ../../rtl/altera/jtag_sim_define.h w]
	puts $fileId [$log get 1.0 end]
	close $fileId
}

proc quit_console {} {
	global exit_console
	destroy .console
	set exit_console 1
}

proc back_sim {} {
	global exit_console
	#destroy .console
	set exit_console 1
}

proc start_sim {} {
	do sim.do
}

proc pause_sim {} {
	vsim_break
}

# initialize
set exit_console 0
reset_stimulus
destroy .console

# set the main window
toplevel .console
wm title .console "www.OpenCores.org: uP Transaction Monitor: Simulation Console"
pack propagate .console true

# set the www.OpenCores.org logo
frame .console.fig -bg white
pack .console.fig -expand true -fill both
image create photo logo -format gif -file "../../cmd/common/OpenCores.gif"
label .console.fig.logo -image logo -bg white
pack .console.fig.logo

# set the inclusive address entries
frame .console.f1 -relief groove -borderwidth 5
pack .console.f1
label .console.f1.incl_addr -text {Inclusive Addr:}
entry .console.f1.address_span1 -textvariable address_span1 -width 8
entry .console.f1.address_span2 -textvariable address_span2 -width 8
entry .console.f1.address_span3 -textvariable address_span3 -width 8
entry .console.f1.address_span4 -textvariable address_span4 -width 8
entry .console.f1.address_span5 -textvariable address_span5 -width 8
entry .console.f1.address_span6 -textvariable address_span6 -width 8
entry .console.f1.address_span7 -textvariable address_span7 -width 8
entry .console.f1.address_span8 -textvariable address_span8 -width 8
checkbutton .console.f1.address_span_en1 -variable address_span_en1
checkbutton .console.f1.address_span_en2 -variable address_span_en2
checkbutton .console.f1.address_span_en3 -variable address_span_en3
checkbutton .console.f1.address_span_en4 -variable address_span_en4
checkbutton .console.f1.address_span_en5 -variable address_span_en5
checkbutton .console.f1.address_span_en6 -variable address_span_en6
checkbutton .console.f1.address_span_en7 -variable address_span_en7
checkbutton .console.f1.address_span_en8 -variable address_span_en8
pack .console.f1.incl_addr \
     .console.f1.address_span_en1 .console.f1.address_span1 \
     .console.f1.address_span_en2 .console.f1.address_span2 \
     .console.f1.address_span_en3 .console.f1.address_span3 \
     .console.f1.address_span_en4 .console.f1.address_span4 \
     .console.f1.address_span_en5 .console.f1.address_span5 \
     .console.f1.address_span_en6 .console.f1.address_span6 \
     .console.f1.address_span_en7 .console.f1.address_span7 \
     .console.f1.address_span_en8 .console.f1.address_span8 \
     -side left -ipadx 0

# set the exclusive address entries
frame .console.f2 -relief groove -borderwidth 5
pack .console.f2
label .console.f2.excl_addr -text {Exclusive Addr:}
entry .console.f2.address_span9  -textvariable address_span9  -width 8
entry .console.f2.address_span10 -textvariable address_span10 -width 8
entry .console.f2.address_span11 -textvariable address_span11 -width 8
entry .console.f2.address_span12 -textvariable address_span12 -width 8
entry .console.f2.address_span13 -textvariable address_span13 -width 8
entry .console.f2.address_span14 -textvariable address_span14 -width 8
entry .console.f2.address_span15 -textvariable address_span15 -width 8
entry .console.f2.address_span16 -textvariable address_span16 -width 8
checkbutton .console.f2.address_span_en9  -variable address_span_en9
checkbutton .console.f2.address_span_en10 -variable address_span_en10
checkbutton .console.f2.address_span_en11 -variable address_span_en11
checkbutton .console.f2.address_span_en12 -variable address_span_en12
checkbutton .console.f2.address_span_en13 -variable address_span_en13
checkbutton .console.f2.address_span_en14 -variable address_span_en14
checkbutton .console.f2.address_span_en15 -variable address_span_en15
checkbutton .console.f2.address_span_en16 -variable address_span_en16
pack .console.f2.excl_addr \
     .console.f2.address_span_en9  .console.f2.address_span9  \
     .console.f2.address_span_en10 .console.f2.address_span10 \
     .console.f2.address_span_en11 .console.f2.address_span11 \
     .console.f2.address_span_en12 .console.f2.address_span12 \
     .console.f2.address_span_en13 .console.f2.address_span13 \
     .console.f2.address_span_en14 .console.f2.address_span14 \
     .console.f2.address_span_en15 .console.f2.address_span15 \
     .console.f2.address_span_en16 .console.f2.address_span16 \
     -side left -ipadx 0
initAddrConfig

# set the address configuration buttons
frame .console.addr_cnfg -relief groove -borderwidth 5
pack .console.addr_cnfg
checkbutton .console.addr_cnfg.wren -text {WR} -variable addr_wren
checkbutton .console.addr_cnfg.rden -text {RD} -variable addr_rden
button .console.addr_cnfg.config -text {Apply Address Filter} -command {updateAddrConfig}
pack .console.addr_cnfg.wren .console.addr_cnfg.rden .console.addr_cnfg.config \
     -side left -ipadx 0

# set the transaction trigger controls
frame .console.trig -relief groove -borderwidth 5
pack .console.trig
button .console.trig.starttrig -text {Apply Trigger Condition} -command {startTrigger}
entry .console.trig.trigvalue_addr -textvar triggerAddr -width 4
entry .console.trig.trigvalue_data -textvar triggerData -width 8
checkbutton .console.trig.trigaddr -text {@Addr:} -variable trig_aden
checkbutton .console.trig.trigdata -text {@Data:} -variable trig_daen
checkbutton .console.trig.wren -text {@WR} -variable trig_wren
checkbutton .console.trig.rden -text {@RD} -variable trig_rden
label .console.trig.pnum -text {Pre-Capture:}
entry .console.trig.trigvalue_pnum -textvar triggerPnum -width 4
pack .console.trig.pnum .console.trig.trigvalue_pnum \
     .console.trig.wren .console.trig.rden \
     .console.trig.trigaddr .console.trig.trigvalue_addr \
     .console.trig.trigdata .console.trig.trigvalue_data \
     .console.trig.starttrig \
     -side left -ipadx 0
initTrigConfig

# set the control buttons
frame .console.fifo -relief groove -borderwidth 5
pack .console.fifo
button .console.fifo.reset -text {Reset FIFO} -command {reset_fifo_ptr}
button .console.fifo.loop -text {Query Used Word} -command {query_fifo_usedw}
label .console.fifo.usedw  -textvariable fifoUsedw -relief sunken -width 4
button .console.fifo.read	-text {Read FIFO} -command {read_fifo_content}
pack .console.fifo.reset .console.fifo.loop .console.fifo.usedw .console.fifo.read \
     -side left -ipadx 0

# set the control buttons
frame .console.sim -relief groove -borderwidth 5
pack .console.sim
button .console.sim.reset -text {Reset Stimulus} -command {reset_stimulus}
button .console.sim.generate -text {Generate Stimulus} -command {generate_stimulus}
button .console.sim.start -text {Start Simulation} -command {start_sim}
button .console.sim.pause -text {Pause Simulation} -command {pause_sim}
button .console.sim.back -text {Back to Simulation} -command {back_sim}
button .console.sim.quit -text {Quit} -command {quit_console}
pack .console.sim.reset .console.sim.generate .console.sim.back .console.sim.quit \
     -side left -ipadx 0

# set the log window
frame .console.log -relief groove -borderwidth 5
set log [text .console.log.text -width 80 -height 25 \
	-borderwidth 2 -relief sunken -setgrid true \
	-yscrollcommand {.console.log.scroll set}]
scrollbar .console.log.scroll -command {.console.log.text yview}
pack .console.log.scroll -side right -fill y
pack .console.log.text -side left -fill both -expand true
pack .console.log -side top -fill both -expand true

# make the program wait for exit signal
vwait exit_console

