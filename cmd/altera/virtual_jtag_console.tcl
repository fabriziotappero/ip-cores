##**************************************************************
## Module             : virtual_jtag_console.tcl
## Platform           : Windows xp sp2
## Author             : Bibo Yang  (ash_riple@hotmail.com)
## Organization       : www.opencores.org
## Revision           : 2.5
## Date               : 2014/02/08
## Description        : Tcl/Tk GUI for the up_monitor
##**************************************************************

proc reset_fifo {{jtag_index_0 0}} {
  global test_cable
  global test_device
  open_device -hardware_name $test_cable -device_name $test_device
	device_lock -timeout 5
	device_virtual_ir_shift -instance_index $jtag_index_0 -ir_value 2 -no_captured_ir_value 
	device_virtual_dr_shift -instance_index $jtag_index_0  -length 32 -dr_value 00000000 -value_in_hex -no_captured_dr_value 
	device_unlock
  close_device
	return 0
}

proc query_usedw {{jtag_index_0 0}} {
  global test_cable
  global test_device
  open_device -hardware_name $test_cable -device_name $test_device
	global fifoUsedw
	device_lock -timeout 5
	device_virtual_ir_shift -instance_index $jtag_index_0 -ir_value 1 -no_captured_ir_value
	set usedw [device_virtual_dr_shift -instance_index $jtag_index_0 -length 9 -value_in_hex]
	device_unlock
		set tmp 0x
		append tmp $usedw
		set usedw [format "%i" $tmp]
	set fifoUsedw $usedw
  close_device
	return $usedw
}

proc read_fifo {{jtag_index_0 0}} {
  global test_cable
  global test_device
  open_device -hardware_name $test_cable -device_name $test_device
	device_lock -timeout 5
	device_virtual_ir_shift -instance_index $jtag_index_0 -ir_value 1 -no_captured_ir_value
	device_virtual_ir_shift -instance_index $jtag_index_0 -ir_value 3 -no_captured_ir_value
	set fifo_data [device_virtual_dr_shift -instance_index $jtag_index_0 -length 98 -value_in_hex]
	device_unlock
  close_device
	return $fifo_data
}

proc config_addr {{jtag_index_1 1} {mask 0100000000} {mask_id 1}} {
  global test_cable
  global test_device
  open_device -hardware_name $test_cable -device_name $test_device
	global log
	set mask_leng [string length $mask]
	if {$mask_leng!=10} {
		$log insert end "\nError: Wrong address mask length @$mask_id: [expr $mask_leng-2]. Expects: 8.\n"
                set addr_mask 0000000000
	} else {
		device_lock -timeout 5
		device_virtual_ir_shift -instance_index $jtag_index_1 -ir_value 1 -no_captured_ir_value
		set addr_mask [device_virtual_dr_shift -instance_index $jtag_index_1 -dr_value $mask -length 40 -value_in_hex]
		device_unlock
	}
  close_device
        return $addr_mask
}

proc config_trig {{jtag_index_2 2} {trig 00000000000000} {pnum 000}} {
  global test_cable
  global test_device
  open_device -hardware_name $test_cable -device_name $test_device
	global log
	set trig_leng [string length $trig]
	if {$trig_leng!=18} {
		$log insert end "\nError: Wrong trigger condition length: [expr $trig_leng-2]. Expects: 8+8.\n"
	} else {
		device_lock -timeout 5
		device_virtual_ir_shift -instance_index $jtag_index_2 -ir_value 1 -no_captured_ir_value
		set addr_trig [device_virtual_dr_shift -instance_index $jtag_index_2 -dr_value $trig -length 72 -value_in_hex]
		device_unlock
	}
	if {[format "%d" 0x$pnum]>=511} {
		$log insert end "\nError: Wrong trigger pre-capture value: [format "%d" 0x$pnum]. Expects: 0~510.\n"
	} else {
		device_lock -timeout 5
		device_virtual_ir_shift -instance_index $jtag_index_2 -ir_value 2 -no_captured_ir_value
		set pnum_trig [device_virtual_dr_shift -instance_index $jtag_index_2 -dr_value $pnum -length 10 -value_in_hex]
		device_unlock
	}
  close_device
	return $addr_trig
} 

proc open_jtag_device {{test_cable "USB-Blaster [USB-0]"} {test_device "@2: EP2SGX90 (0x020E30DD)"}} {
  open_device -hardware_name $test_cable -device_name $test_device
	# Retrieve device id code.
	device_lock -timeout 5
	device_ir_shift -ir_value 6 -no_captured_ir_value
	set idcode "0x[device_dr_shift -length 32 -value_in_hex]"
	device_unlock
  close_device
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
        global test_cable
        global test_device
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
	for {set i 1} {$i<=8} {set i [expr $i+2]} {
		if {[set address_span$i]==""} {
			set address_span$i fffffffc
	}
        }
	for {set i 2} {$i<=8} {set i [expr $i+2]} {
		if {[set address_span$i]==""} {
			set address_span$i 00000000
	}
	}
	for {set i 9} {$i<=16} {incr i} {
		if {[set address_span$i]==""} {
			set address_span$i ffffffff
	}
        }
}

proc initTrigConfig {} {
	global triggerAddr
	global triggerData
	global triggerPnum
	if {[set triggerAddr]==""} {
		set triggerAddr 00000000
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
	global log
	if {[expr $trig_wren+$trig_rden]==2} {
		$log insert end "\nWarning: @WR & @RD, unreachable trigger condition.\n"
	}
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
		set ad_cptr                      [string range $fifoContent  9 16]
		set da_cptr                      [string range $fifoContent 17 24]
		if $ok_trig {
			$log insert end "@@@@@@@@@@@@@@@@@@@@\n"
		}
		if $wr_cptr {
			$log insert end "wr 0x$ad_cptr 0x$da_cptr @$tm_cptr\n"
		} else {
			$log insert end "rd 0x$ad_cptr 0x$da_cptr @$tm_cptr\n"
		}
	}
	query_usedw 0
}

proc clear_log {} {
	global log
	$log delete insert end
}

proc quit {} {
	global exit_console
	destroy .mainframe
        destroy .
	set exit_console 1
}

# set the QuartusII special Tk command
init_tk
set exit_console 0

# set the main window
wm withdraw .
toplevel .mainframe
wm title .mainframe "www.OpenCores.org: uP Transaction Monitor"
pack propagate .mainframe true

# set the www.OpenCores.org logo
frame .mainframe.fig -bg white
pack .mainframe.fig -expand true -fill both
image create photo logo -format gif -file "../common/OpenCores.gif"
label .mainframe.fig.logo -image logo -bg white
pack .mainframe.fig.logo

# set the JTAG utility
frame .mainframe.jtag -relief groove -borderwidth 5
pack .mainframe.jtag
button .mainframe.jtag.scan -text {Scan JTAG Chain} -command {scan_chain}
button .mainframe.jtag.select -text {Select JTAG Device :} -command {select_device $cableNum $deviceNum}
button .mainframe.jtag.deselect -text {DeSelect JTAG Device} -command {close_jtag_device}
label .mainframe.jtag.cable -text {Cable @}
label .mainframe.jtag.devic -text {Device @}
entry .mainframe.jtag.cable_num -textvariable cableNum -width 5
entry .mainframe.jtag.devic_num -textvariable deviceNum -width 5
pack .mainframe.jtag.scan .mainframe.jtag.select \
     .mainframe.jtag.cable .mainframe.jtag.cable_num \
     .mainframe.jtag.devic .mainframe.jtag.devic_num \
     .mainframe.jtag.deselect \
     -side left -ipadx 0

# set the inclusive address entries
frame .mainframe.f1 -relief groove -borderwidth 5
pack .mainframe.f1
label .mainframe.f1.incl_addr -text {Inclusive Addr:}
entry .mainframe.f1.address_span1 -textvariable address_span1 -width 8
entry .mainframe.f1.address_span2 -textvariable address_span2 -width 8
entry .mainframe.f1.address_span3 -textvariable address_span3 -width 8
entry .mainframe.f1.address_span4 -textvariable address_span4 -width 8
entry .mainframe.f1.address_span5 -textvariable address_span5 -width 8
entry .mainframe.f1.address_span6 -textvariable address_span6 -width 8
entry .mainframe.f1.address_span7 -textvariable address_span7 -width 8
entry .mainframe.f1.address_span8 -textvariable address_span8 -width 8
checkbutton .mainframe.f1.address_span_en1 -variable address_span_en1
checkbutton .mainframe.f1.address_span_en2 -variable address_span_en2
checkbutton .mainframe.f1.address_span_en3 -variable address_span_en3
checkbutton .mainframe.f1.address_span_en4 -variable address_span_en4
checkbutton .mainframe.f1.address_span_en5 -variable address_span_en5
checkbutton .mainframe.f1.address_span_en6 -variable address_span_en6
checkbutton .mainframe.f1.address_span_en7 -variable address_span_en7
checkbutton .mainframe.f1.address_span_en8 -variable address_span_en8
label .mainframe.f1.address_span_text1 -text {H:}
label .mainframe.f1.address_span_text2 -text {L:}
label .mainframe.f1.address_span_text3 -text {H:}
label .mainframe.f1.address_span_text4 -text {L:}
label .mainframe.f1.address_span_text5 -text {H:}
label .mainframe.f1.address_span_text6 -text {L:}
label .mainframe.f1.address_span_text7 -text {H:}
label .mainframe.f1.address_span_text8 -text {L:}
pack .mainframe.f1.incl_addr \
     .mainframe.f1.address_span_en1 .mainframe.f1.address_span_text1 .mainframe.f1.address_span1 .mainframe.f1.address_span_text2 .mainframe.f1.address_span2 \
     .mainframe.f1.address_span_en3 .mainframe.f1.address_span_text3 .mainframe.f1.address_span3 .mainframe.f1.address_span_text4 .mainframe.f1.address_span4 \
     .mainframe.f1.address_span_en5 .mainframe.f1.address_span_text5 .mainframe.f1.address_span5 .mainframe.f1.address_span_text6 .mainframe.f1.address_span6 \
     .mainframe.f1.address_span_en7 .mainframe.f1.address_span_text7 .mainframe.f1.address_span7 .mainframe.f1.address_span_text8 .mainframe.f1.address_span8 \
     -side left -ipadx 0

# set the exclusive address entries
frame .mainframe.f2 -relief groove -borderwidth 5
pack .mainframe.f2
label .mainframe.f2.excl_addr -text {Exclusive Addr:}
entry .mainframe.f2.address_span9  -textvariable address_span9  -width 8
entry .mainframe.f2.address_span10 -textvariable address_span10 -width 8
entry .mainframe.f2.address_span11 -textvariable address_span11 -width 8
entry .mainframe.f2.address_span12 -textvariable address_span12 -width 8
entry .mainframe.f2.address_span13 -textvariable address_span13 -width 8
entry .mainframe.f2.address_span14 -textvariable address_span14 -width 8
entry .mainframe.f2.address_span15 -textvariable address_span15 -width 8
entry .mainframe.f2.address_span16 -textvariable address_span16 -width 8
checkbutton .mainframe.f2.address_span_en9  -variable address_span_en9
checkbutton .mainframe.f2.address_span_en10 -variable address_span_en10
checkbutton .mainframe.f2.address_span_en11 -variable address_span_en11
checkbutton .mainframe.f2.address_span_en12 -variable address_span_en12
checkbutton .mainframe.f2.address_span_en13 -variable address_span_en13
checkbutton .mainframe.f2.address_span_en14 -variable address_span_en14
checkbutton .mainframe.f2.address_span_en15 -variable address_span_en15
checkbutton .mainframe.f2.address_span_en16 -variable address_span_en16
label .mainframe.f2.address_span_text1 -text {H:}
label .mainframe.f2.address_span_text2 -text {L:}
label .mainframe.f2.address_span_text3 -text {H:}
label .mainframe.f2.address_span_text4 -text {L:}
label .mainframe.f2.address_span_text5 -text {H:}
label .mainframe.f2.address_span_text6 -text {L:}
label .mainframe.f2.address_span_text7 -text {H:}
label .mainframe.f2.address_span_text8 -text {L:}
pack .mainframe.f2.excl_addr \
     .mainframe.f2.address_span_en9  .mainframe.f2.address_span_text1 .mainframe.f2.address_span9  .mainframe.f2.address_span_text2 .mainframe.f2.address_span10 \
     .mainframe.f2.address_span_en11 .mainframe.f2.address_span_text3 .mainframe.f2.address_span11 .mainframe.f2.address_span_text4 .mainframe.f2.address_span12 \
     .mainframe.f2.address_span_en13 .mainframe.f2.address_span_text5 .mainframe.f2.address_span13 .mainframe.f2.address_span_text6 .mainframe.f2.address_span14 \
     .mainframe.f2.address_span_en15 .mainframe.f2.address_span_text7 .mainframe.f2.address_span15 .mainframe.f2.address_span_text8 .mainframe.f2.address_span16 \
     -side left -ipadx 0
initAddrConfig

# set the address configuration buttons
frame .mainframe.addr_cnfg -relief groove -borderwidth 5
pack .mainframe.addr_cnfg
checkbutton .mainframe.addr_cnfg.wren -text {WR} -variable addr_wren
checkbutton .mainframe.addr_cnfg.rden -text {RD} -variable addr_rden
button .mainframe.addr_cnfg.config -text {Apply Address Filter} -command {updateAddrConfig}
pack .mainframe.addr_cnfg.wren .mainframe.addr_cnfg.rden .mainframe.addr_cnfg.config \
     -side left -ipadx 0

# set the transaction trigger controls
frame .mainframe.trig -relief groove -borderwidth 5
pack .mainframe.trig
button .mainframe.trig.starttrig -text {Apply Trigger Condition} -command {startTrigger}
entry .mainframe.trig.trigvalue_addr -textvar triggerAddr -width 8
entry .mainframe.trig.trigvalue_data -textvar triggerData -width 8
checkbutton .mainframe.trig.trigaddr -text {@Addr:} -variable trig_aden
checkbutton .mainframe.trig.trigdata -text {@Data:} -variable trig_daen
checkbutton .mainframe.trig.wren -text {@WR} -variable trig_wren
checkbutton .mainframe.trig.rden -text {@RD} -variable trig_rden
label .mainframe.trig.pnum -text {Pre-Capture:}
entry .mainframe.trig.trigvalue_pnum -textvar triggerPnum -width 4
pack .mainframe.trig.pnum .mainframe.trig.trigvalue_pnum \
     .mainframe.trig.wren .mainframe.trig.rden \
     .mainframe.trig.trigaddr .mainframe.trig.trigvalue_addr \
     .mainframe.trig.trigdata .mainframe.trig.trigvalue_data \
     .mainframe.trig.starttrig \
     -side left -ipadx 0
initTrigConfig

# set the control buttons
frame .mainframe.fifo -relief groove -borderwidth 5
pack .mainframe.fifo
button .mainframe.fifo.reset -text {Reset FIFO} -command {reset_fifo_ptr}
button .mainframe.fifo.loop -text {Query Used Word} -command {query_fifo_usedw}
label .mainframe.fifo.usedw  -textvariable fifoUsedw -relief sunken -width 4
button .mainframe.fifo.read	-text {Read FIFO} -command {read_fifo_content}
button .mainframe.fifo.clear -text {Clear Log} -command {clear_log}
button .mainframe.fifo.quit -text {Quit} -command {quit}
pack .mainframe.fifo.reset .mainframe.fifo.loop .mainframe.fifo.usedw .mainframe.fifo.read .mainframe.fifo.clear .mainframe.fifo.quit \
     -side left -ipadx 0

# set the log window
frame .mainframe.log -relief groove -borderwidth 5
set log [text .mainframe.log.text -width 80 -height 25 \
	-borderwidth 2 -relief sunken -setgrid true \
	-yscrollcommand {.mainframe.log.scroll set}]
scrollbar .mainframe.log.scroll -command {.mainframe.log.text yview}
pack .mainframe.log.scroll -side right -fill y
pack .mainframe.log.text -side left -fill both -expand true
pack .mainframe.log -side top -fill both -expand true

# make the program wait for exit signal
vwait exit_console

