#!/usr/bin/wish
#------------------------------------------------------------------------------
# Copyright (C) 2001 Authors
#
# This source file may be used and distributed without restriction provided
# that this copyright statement is not removed from the file and that any
# derivative work contains the original copyright notice and the associated
# disclaimer.
#
# This source file is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
#
# This source is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
# License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this source; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
#------------------------------------------------------------------------------
# 
# File Name: server.tcl
# 
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#------------------------------------------------------------------------------
# $Rev: 198 $
# $LastChangedBy: olivier.girard $
# $LastChangedDate: 2014-10-07 21:30:05 +0200 (Tue, 07 Oct 2014) $
#------------------------------------------------------------------------------

global clients
global server

global CpuNr
set    CpuNr 0


###############################################################################
#                                                                             #
#                           START/STOP LOCAL SERVER                           #
#                                                                             #
###############################################################################

proc startServer { CpuNr } {
    global server

    if {![info exists server($CpuNr,socket)]} {
        putsLog "CORE $CpuNr: Open socket on port $server($CpuNr,port)... " 1
        if {[catch {socket -server "clientAccept $CpuNr" $server($CpuNr,port)} server($CpuNr,socket)]} {
            putsLog "failed"
            putsLog "CORE $CpuNr: ERROR: $server($CpuNr,socket)."
            unset server($CpuNr,socket)
            return 0
        }
        putsLog "done"
        putsLog "CORE $CpuNr: INFO: Waiting on TCP port $server($CpuNr,port)"
    } else {
        putsLog "CORE $CpuNr: Server is already up and running."
    }
    return 1
}

proc stopAllServers { } {
    global omsp_info
    global server
    global omsp_nr

    for { set CpuNr 0 } { $CpuNr < $omsp_nr } { incr CpuNr } {

	if {[info exists server($CpuNr,socket)]} {
	    set port [lindex [fconfigure $server($CpuNr,socket) -sockname] 2]
	    putsLog "CORE $CpuNr: Stop server (port $port)"
	    close $server($CpuNr,socket)
	    unset server($CpuNr,socket)
	}
	if {$omsp_info($CpuNr,connected)} {
	    ReleaseDevice $CpuNr 0xfffe
	}
    }
}

proc clientAccept {CpuNr sock addr port} {
    global clients

    putsLog "CORE $CpuNr: Accept client: $addr ($port)\n"

    set clients($CpuNr,addr,$sock) [list $addr $port]
    fconfigure $sock -buffering none
    fileevent  $sock readable [list receiveRSPpacket $CpuNr $sock]

    InitBreakUnits $CpuNr
}

proc startServerGUI { } {
    global omsp_conf
    global omsp_info
    global omsp_nr
    global breakSelect

    # Connect to all devices
    set connection_status 0
    set connection_sum    0
    for { set CpuNr 0 } { $CpuNr < $omsp_nr } { incr CpuNr } {
        set connection_ok  [GetDevice $CpuNr]
        set connection_sum [expr $connection_sum + $connection_ok]
        if {$connection_ok==0} {
            set error_nr "$CpuNr"
        }
    }
    if {$connection_sum==$omsp_nr} {
        set connection_status 1
    }

    if {!$connection_status} {
	.info.cpu.con   configure -text "Connection problem" -fg red
	putsLog ""
	putsLog "ERROR: Could not connect to Core $error_nr"
	putsLog ""
	putsLog "         -----------------------------------------------------------------------"
	putsLog "       !!!! Please consider the following options:                            !!!!"
	putsLog "       !!!!                                                                   !!!!"
	putsLog "       !!!!      - make sure \"$omsp_conf(device)\" is the right device."
	putsLog "       !!!!      - check permissions of the \"$omsp_conf(device)\" device (run as root if necessary)."
	putsLog "       !!!!      - check the physical connection to the board.                !!!!"
	putsLog "       !!!!      - adjust the serial connection baudrate.                     !!!!"
	putsLog "       !!!!      - for UART, don't forget to reset the serial debug interface !!!!"
	putsLog "       !!!!        between each attempt.                                      !!!!"
	putsLog "       !!!!      - for I2C, make sure $omsp_conf($error_nr,cpuaddr) the is the right address.            !!!!"
	putsLog "         -----------------------------------------------------------------------"
	putsLog ""
	return 0
    }

    if {$breakSelect==1} {
	if {$omsp_info(0,hw_break)==0} {
	    .info.cpu.con   configure -text "No Hardware breakpoint unit detected" -fg red
	    putsLog ""
	    putsLog "ERROR: Could not detect any Hardware Breakpoint Unit"
	    putsLog "       Consider switching to the Software Breakpoint configuration"
	    putsLog ""
	    return 0
	}
    }

    if {$omsp_info(0,alias)==""} {
        .info.cpu.con   configure -text "Connected" -fg "\#00ae00"
    } else {
        .info.cpu.con   configure -text "Connected to $omsp_info(0,alias)" -fg "\#00ae00"
    }

    # Display info
    putsLog "INFO: Sucessfully connected with the openMSP430 target."
    set sizes [GetCPU_ID_SIZE 0]
    if {$omsp_info(0,asic)} {
        putsLog "INFO: CPU Version              - $omsp_info(0,cpu_ver) / ASIC"
    } else {
        putsLog "INFO: CPU Version              - $omsp_info(0,cpu_ver) / FPGA"
    }
    putsLog "INFO: User Version             - $omsp_info(0,user_ver)"
    if {$omsp_info(0,cpu_ver)==1} {
        putsLog "INFO: Hardware Multiplier      - --"
    } elseif {$omsp_info(0,mpy)} {
        putsLog "INFO: Hardware Multiplier      - Yes"
    } else {
        putsLog "INFO: Hardware Multiplier      - No"
    }
    putsLog "INFO: Program Memory Size      - $omsp_info(0,pmem_size) B"
    putsLog "INFO: Data Memory Size         - $omsp_info(0,dmem_size) B"
    putsLog "INFO: Peripheral Address Space - $omsp_info(0,per_size) B"
    putsLog "INFO: $omsp_info(0,hw_break) Hardware Break/Watch-point unit(s) detected"
    putsLog ""

    # Activate Load TCL script section
    .tclscript.ft.l          configure -state normal
    .tclscript.ft.file       configure -state normal
    .tclscript.ft.browse     configure -state normal
    .tclscript.fb.read       configure -state normal

    # Activate extra cpu info button
    .info.cpu.more           configure -state normal

    for { set CpuNr 0 } { $CpuNr < $omsp_nr } { incr CpuNr } {

	# Reset & Stop CPU
	ExecutePOR_Halt $CpuNr

	# Start server for GDB
	if {![startServer $CpuNr]} {
	    .info.server.con configure -text "Connection problem" -fg red
	    return 0
	}
    }

    .info.server.con     configure -text "Running" -fg "\#00ae00"

    # Disable gui entries
    .connect.cfg.if.config1.adapter.p1       configure -state disabled
    .connect.cfg.if.config2.adapter.p2       configure -state disabled
    .connect.cfg.if.config1.serial_port.p1   configure -state disabled
    .connect.cfg.if.config2.serial_port.p2   configure -state disabled
    .connect.start.comp_mode                 configure -state disabled
    .connect.cfg.ad.server_port.p0           configure -state disabled
    .connect.cfg.ad.server_port.p1           configure -state disabled
    .connect.cfg.ad.server_port.p2           configure -state disabled
    .connect.cfg.ad.server_port.p3           configure -state disabled
    .connect.cfg.ad.i2c_addr.s0              configure -state disabled
    .connect.cfg.ad.i2c_addr.s1              configure -state disabled
    .connect.cfg.ad.i2c_addr.s2              configure -state disabled
    .connect.cfg.ad.i2c_addr.s3              configure -state disabled
    .connect.cfg.ad.i2c_nr.s                 configure -state disabled

    .connect.cfg.ad.i2c_nr.f.soft.b          configure -state disabled
    .connect.cfg.ad.i2c_nr.f.soft.r          configure -state disabled
    .connect.cfg.ad.i2c_nr.f.hard.r          configure -state disabled
    if {[winfo exists .omsp_sft_brk]} {
	.omsp_sft_brk.map.b.share            configure -state disabled
	.omsp_sft_brk.map.b.dedic            configure -state disabled
	.omsp_sft_brk.map.r.core_nr.l0       configure -state disabled
	.omsp_sft_brk.map.r.pmem0.p0         configure -state disabled
	.omsp_sft_brk.map.r.core_nr.l1       configure -state disabled
	.omsp_sft_brk.map.r.pmem0.p1         configure -state disabled
	.omsp_sft_brk.map.r.pmem1.p1         configure -state disabled
	.omsp_sft_brk.map.r.core_nr.l2       configure -state disabled
	.omsp_sft_brk.map.r.pmem0.p2         configure -state disabled
	.omsp_sft_brk.map.r.pmem1.p2         configure -state disabled
	.omsp_sft_brk.map.r.pmem2.p2         configure -state disabled
	.omsp_sft_brk.map.r.core_nr.l3       configure -state disabled
	.omsp_sft_brk.map.r.pmem0.p3         configure -state disabled
	.omsp_sft_brk.map.r.pmem1.p3         configure -state disabled
	.omsp_sft_brk.map.r.pmem2.p3         configure -state disabled
	.omsp_sft_brk.map.r.pmem3.p3         configure -state disabled
    }
}

###############################################################################
#                                                                             #
#                        RECEIVE / SEND RSP PACKETS                           #
#                                                                             #
###############################################################################

proc receiveRSPpacket {CpuNr sock} {

    # Get client info
    set ip   [lindex [fconfigure $sock -peername] 0]
    set port [lindex [fconfigure $sock -peername] 2]

    # Check if a new packet arrives
    set rx_packet 0
    set rsp_cmd [getDebugChar $CpuNr $sock]
    set rsp_sum ""
    if {[string eq $rsp_cmd "\$"]} {
        set rx_packet 1
        set rsp_cmd ""
    } else {
        binary scan $rsp_cmd H* rsp_cmd
        if {$rsp_cmd=="03"} {
            putsVerbose "--> BREAK"
            HaltCPU $CpuNr
        }
    }
    # Receive packet
    while {$rx_packet} {
        set char [getDebugChar $CpuNr $sock]
        if {$char==-1} {
            set    rx_packet 0
        } elseif {[string eq $char "\#"]} {
            set    rx_packet 0
            set    rsp_sum   [getDebugChar $CpuNr $sock]
            append rsp_sum   [getDebugChar $CpuNr $sock]
 
            # Re-calculate the checksum
            set    tmp_sum   [RSPcheckSum  $rsp_cmd]

            # Acknowledge and analyse the packet
            if {[string eq $rsp_sum $tmp_sum]} {
                putDebugChar $sock "+"

                # Remove escape characters
                set rsp_cmd [removeEscapeChar $rsp_cmd]
                putsVerbose "CORE $CpuNr: + w $rsp_cmd"

                # Parse packet and send back the answer
                set rsp_answer [rspParse $CpuNr $sock $rsp_cmd]
                if {$rsp_answer != "-1"} {
                    sendRSPpacket $CpuNr $sock $rsp_answer
                }
            } else {
                putDebugChar $sock "-"
            }
        } else {
            append rsp_cmd $char
        }
    }
}


proc sendRSPpacket {CpuNr sock rsp_cmd} {

    # Set escape characters
    set rsp_cmd [setEscapeChar $rsp_cmd]

    # Calculate checksum
    set rsp_sum [RSPcheckSum  $rsp_cmd]

    # Format the packet
    set rsp_packet "\$$rsp_cmd\#$rsp_sum"

    # Send the packet until the "+" aknowledge is received
    set send_ok 0
    while {!$send_ok} {
        putDebugChar $sock "$rsp_packet"
        set char [getDebugChar $CpuNr $sock]

        putsVerbose "CORE $CpuNr: $char r $rsp_cmd"

        if {$char==-1} {
            set    send_ok 1
        } elseif {[string eq $char "+"]} {
            set    send_ok 1
        }
    }
}


###############################################################################
#                                                                             #
#                   CHECKSUM / ESCAPE CHAR / RX / TX FUNCTIONS                #
#                                                                             #
###############################################################################

proc RSPcheckSum {rsp_cmd} {

    set    rsp_sum   0
    for {set i 0} {$i<[string length $rsp_cmd]} {incr i} {
        scan [string index $rsp_cmd $i] "%c" char_val
        set rsp_sum [expr $rsp_sum+$char_val]
    }
    set rsp_sum [format %02x [expr $rsp_sum%256]]

    return $rsp_sum
}

proc removeEscapeChar {rsp_cmd} {

    # Replace all '\}0x03' characters with '#'
    regsub -all "\}[binary format H* 03]" $rsp_cmd "\#" rsp_cmd

    # Replace all '\}0x04' characters with '$'
    regsub -all "\}[binary format H* 04]" $rsp_cmd "\$" rsp_cmd

    # Replace all '\}\]' characters with '\}'
    regsub -all "\}\]" $rsp_cmd "\}" rsp_cmd

    return "$rsp_cmd"
}

proc setEscapeChar {rsp_cmd} {

    # Escape all '\}' characters with '\}\]'
    regsub -all "\}" $rsp_cmd "\}\]" rsp_cmd

    # Escape all '$' characters with '\}0x04'
    regsub -all "\\$" $rsp_cmd "\}[binary format H* 04]" rsp_cmd

    # Escape all '#' characters with '\}0x03'
    regsub -all "\#" $rsp_cmd "\}[binary format H* 03]" rsp_cmd

    return "$rsp_cmd"
}


proc getDebugChar {CpuNr sock} {
    global clients

    # Get client info
    set ip   [lindex [fconfigure $sock -peername] 0]
    set port [lindex [fconfigure $sock -peername] 2]

    if {[eof $sock] || [catch {set char [read $sock 1]}]} {
        # end of file or abnormal connection drop
        close $sock
        putsLog "CORE $CpuNr: Connection closed: $ip ($port)\n"
        unset clients($CpuNr,addr,$sock)
        return -1
    } else {
        return $char
    }
}


proc putDebugChar {sock char} {
    puts -nonewline $sock $char
}

###############################################################################
#                                                                             #
#                          GUI: DISPLAY EXTRA INFO                            #
#                                                                             #
###############################################################################

proc displayMore  { } {

    global omsp_info

    # Destroy windows if already existing
    if {[lsearch -exact [winfo children .] .omsp_extra_info]!=-1} {
        destroy .omsp_extra_info
    }

    # Create master window
    toplevel    .omsp_extra_info
    wm title    .omsp_extra_info "openMSP430 extra info"
    wm geometry .omsp_extra_info +380+200
    wm resizable .omsp_extra_info 0 0

    # Title
    set title "openMSP430"
    if {$omsp_info(0,alias)!=""} {
        set title $omsp_info(0,alias)
    }
    label  .omsp_extra_info.title  -text "$title"   -anchor center -fg "\#00ae00" -font {-weight bold -size 16}
    pack   .omsp_extra_info.title  -side top -padx {20 20} -pady {20 10}

    # Add extra info
    frame     .omsp_extra_info.extra
    pack      .omsp_extra_info.extra         -side top  -padx 10  -pady {10 10}
    scrollbar .omsp_extra_info.extra.yscroll -orient vertical   -command {.omsp_extra_info.extra.text yview}
    pack      .omsp_extra_info.extra.yscroll -side right -fill both
    text      .omsp_extra_info.extra.text    -wrap word -height 20 -font TkFixedFont -yscrollcommand {.omsp_extra_info.extra.yscroll set}
    pack      .omsp_extra_info.extra.text    -side right 

    # Create OK button
    button .omsp_extra_info.okay -text "OK" -font {-weight bold}  -command {destroy .omsp_extra_info}
    pack   .omsp_extra_info.okay -side bottom -expand true -fill x -padx 5 -pady {0 10}
    

    # Fill the text widget will configuration info
    .omsp_extra_info.extra.text tag configure bold -font {-family TkFixedFont -weight bold}
    .omsp_extra_info.extra.text insert end         "Configuration\n\n" bold
    .omsp_extra_info.extra.text insert end [format "CPU Version                : %5s\n" $omsp_info(0,cpu_ver)]
    .omsp_extra_info.extra.text insert end [format "User Version               : %5s\n" $omsp_info(0,user_ver)]
    if {$omsp_info(0,cpu_ver)==1} {
    .omsp_extra_info.extra.text insert end [format "Implementation             : %5s\n" --]
    } elseif {$omsp_info(0,asic)==0} {
    .omsp_extra_info.extra.text insert end [format "Implementation             : %5s\n" FPGA]
    } elseif {$omsp_info(0,asic)==1} {
    .omsp_extra_info.extra.text insert end [format "Implementation             : %5s\n" ASIC]
    }
    if {$omsp_info(0,mpy)==1} {
    .omsp_extra_info.extra.text insert end [format "Hardware Multiplier support: %5s\n" Yes]
    } elseif {$omsp_info(0,mpy)==0} {
    .omsp_extra_info.extra.text insert end [format "Hardware Multiplier support: %5s\n" No]
    } else {
    .omsp_extra_info.extra.text insert end [format "Hardware Multiplier support: %5s\n" --]
    }
    .omsp_extra_info.extra.text insert end [format "Program memory size        : %5s B\n" $omsp_info(0,pmem_size)]
    .omsp_extra_info.extra.text insert end [format "Data memory size           : %5s B\n" $omsp_info(0,dmem_size)]
    .omsp_extra_info.extra.text insert end [format "Peripheral address space   : %5s B\n" $omsp_info(0,per_size)]
    if {$omsp_info(0,alias)==""} {
    .omsp_extra_info.extra.text insert end [format "Alias                      : %5s\n\n\n" None]
    } else {
    .omsp_extra_info.extra.text insert end [format "Alias                      : %5s\n\n\n" $omsp_info(0,alias)]
    }

    .omsp_extra_info.extra.text insert end         "Extra Info\n\n" bold

    if {$omsp_info(0,alias)!=""} {

        set aliasEXTRA  [lsort -increasing [array names omsp_info -glob "extra,*"]]
        if {[llength $aliasEXTRA]} {

            foreach currentEXTRA $aliasEXTRA {
                regexp {^.+,.+,(.+)$} $currentEXTRA whole_match extraATTR
                .omsp_extra_info.extra.text insert end     [format "%-15s: %s\n" $extraATTR  $omsp_info(0,$currentEXTRA)]
            }
            .omsp_extra_info.extra.text insert end         "\n\n"
        }
    } else {
        .omsp_extra_info.extra.text insert end  "No alias found in 'omsp_alias.xml' file"
    }
}
