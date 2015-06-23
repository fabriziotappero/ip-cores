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
# File Name: openmsp430-minidebug.tcl
# 
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#------------------------------------------------------------------------------
# $Rev: 169 $
# $LastChangedBy: olivier.girard $
# $LastChangedDate: 2012-12-06 22:11:29 +0100 (Thu, 06 Dec 2012) $
#------------------------------------------------------------------------------

###############################################################################
#                                                                             #
#                            SOURCE LIBRARIES                                 #
#                                                                             #
###############################################################################

# Get library path
set current_file [info script]
if {[file type $current_file]=="link"} {
    set current_file [file readlink $current_file]
}
set lib_path [file dirname $current_file]/../lib/tcl-lib

# Source library
source $lib_path/dbg_functions.tcl
source $lib_path/dbg_utils.tcl
source $lib_path/combobox.tcl
package require combobox 2.3
catch {namespace import combobox::*}


###############################################################################
#                                                                             #
#                            GLOBAL VARIABLES                                 #
#                                                                             #
###############################################################################

global CpuNr

global omsp_conf
global omsp_info

global omsp_nr

global current_file_name
global connection_status
global cpu_status
global reg
global mem
global mem_sizes
global sr
global codeSelect
global binFileType
global binFileName
global pmemIHEX
global isPmemRead
global brkpt
global color

# Initialize to default values
set CpuNr                 0
set omsp_nr               1
set omsp_conf(interface)  uart_generic
#set omsp_nr               4
#set omsp_conf(interface)  i2c_usb-iss
set omsp_conf(device)     [lindex [utils::uart_port_list] end]
set omsp_conf(baudrate)   [lindex [GetAllowedSpeeds] 1]
set omsp_conf(0,cpuaddr)  50
set omsp_conf(1,cpuaddr)  51
set omsp_conf(2,cpuaddr)  52
set omsp_conf(3,cpuaddr)  53

# Color definitions
set color(PC)             "\#c1ffc1"
set color(Brk0_active)    "\#ba55d3"
set color(Brk0_disabled)  "\#dda0dd"
set color(Brk1_active)    "\#ff7256"
set color(Brk1_disabled)  "\#ffc1c1"
set color(Brk2_active)    "\#ffff30"
set color(Brk2_disabled)  "\#ffffe0"

# Initializations
set codeSelect        2
set binFileType       ""
set binFileName       ""
set pmemIHEX          ""
set mem_sizes         ""
set isPmemRead        0
set connection_status 0
set cpu_status    1
for {set i 0} {$i<3} {incr i} {
    set brkpt(addr_$i)  0x0000
    set brkpt(data_$i)  0x0000
    set brkpt(en_$i)    0
}
for {set i 0} {$i<16} {incr i} {
    set reg($i)         0x0000
    set mem(address_$i) [format "0x%04x" [expr 0x0200+$i*2]]
    set mem(data_$i)    0x0000
}
for {set i 0} {$i<3} {incr i} {
    set backup($i,current_file_name) ""
}


###############################################################################
#                                                                             #
#                                    FUNCTIONS                                #
#                                                                             #
###############################################################################

proc connect_openMSP430 {} {
    global connection_status
    global reg
    global mem
    global brkpt
    global mem_sizes
    global color
    global omsp_conf
    global omsp_info
    global omsp_nr
    global CpuNr

    set connection_sum 0
    for {set ii 0} {$ii < $omsp_nr} {incr ii} {
        set connection_ok  [GetDevice $ii]
        set connection_sum [expr $connection_sum + $connection_ok]
        if {$connection_ok==0} {
            set error_msg "Could not connect to Core $ii"
        }
    }
    if {$connection_sum==$omsp_nr} {
        set connection_status 1
    }

    if {$connection_status} {
        set mem_sizes [GetCPU_ID_SIZE $CpuNr]

        if {[lindex $mem_sizes 0]==-1 | [lindex $mem_sizes 1]==-1 | [lindex $mem_sizes 2]==-1} {
            .ctrl.connect.info.l1.con     configure -text "Connection problem" -fg red

        } else {
            # Update Core selection section
            regexp {(.+)_(.+)} $omsp_conf(interface) whole_match interface adapter
            set interface [string toupper $interface]
            if {$interface=="I2C"} {
                if {$omsp_nr>1} {
                    .menu.cpusel          configure -state normal
                    .menu.cpu0            configure -state normal
                    .menu.cpu1            configure -state normal
                }
                if {$omsp_nr>2} {.menu.cpu2 configure -state normal}
                if {$omsp_nr>3} {.menu.cpu3 configure -state normal}
            }

            # Disable connection section
            .ctrl.connect.serial.p1       configure -state disabled     
            .ctrl.connect.serial.p2       configure -state disabled
            .ctrl.connect.serial.connect  configure -state disabled

            if {$omsp_info($CpuNr,alias)==""} {
                .ctrl.connect.info.l1.con configure -text "Connected" -fg "\#00ae00"
            } else {
                .ctrl.connect.info.l1.con configure -text "Connected to $omsp_info($CpuNr,alias)" -fg "\#00ae00"
            }
            .ctrl.connect.info.l1.more    configure -state normal

            # Activate ELF file section
            .ctrl.load.ft.l               configure -state normal
            .ctrl.load.ft.file            configure -state normal
            .ctrl.load.ft.browse          configure -state normal
            .ctrl.load.fb.load            configure -state normal
            .ctrl.load.fb.open            configure -state normal
            .ctrl.load.fb.readpmem        configure -state normal
            .ctrl.load.info.t             configure -state normal
            .ctrl.load.info.l             configure -state normal

            # Activate CPU control section
            .ctrl.cpu.cpu.l1              configure -state normal
            .ctrl.cpu.cpu.reset           configure -state normal
            .ctrl.cpu.cpu.run             configure -state normal
            .ctrl.cpu.cpu.l2              configure -state normal
            .ctrl.cpu.cpu.l3              configure -state normal
            if {[IsHalted $CpuNr]} {
                .ctrl.cpu.cpu.step        configure -state normal
                .ctrl.cpu.cpu.run         configure -text "Run"
                .ctrl.cpu.cpu.l3          configure -text "Stopped" -fg "\#cdad00"
                set cpu_status 0
            } else {
                .ctrl.cpu.cpu.step        configure -state disabled
                .ctrl.cpu.cpu.run         configure -text "Stop"
                .ctrl.cpu.cpu.l3          configure -text "Running" -fg "\#00ae00"
                set cpu_status 1
            }

            # Activate CPU Breakpoints section
            .ctrl.cpu.brkpt.l1                configure -state normal
            for {set i 0} {$i<3} {incr i} {
                set brkpt(addr_$i)  [format "0x%04x" [expr 0x10000-[lindex $mem_sizes 0]]]
                .ctrl.cpu.brkpt.addr$i        configure -state normal
                .ctrl.cpu.brkpt.addr$i        configure -bg $color(Brk$i\_disabled)
                .ctrl.cpu.brkpt.addr$i        configure -readonlybackground $color(Brk$i\_active)
                .ctrl.cpu.brkpt.chk$i         configure -state normal
            }

            # Activate CPU status register section
            .ctrl.cpu.reg_stat.l1             configure -state normal
            .ctrl.cpu.reg_stat.v              configure -state normal
            .ctrl.cpu.reg_stat.scg1           configure -state normal
            .ctrl.cpu.reg_stat.oscoff         configure -state normal
            .ctrl.cpu.reg_stat.cpuoff         configure -state normal
            .ctrl.cpu.reg_stat.gie            configure -state normal
            .ctrl.cpu.reg_stat.n              configure -state normal
            .ctrl.cpu.reg_stat.z              configure -state normal
            .ctrl.cpu.reg_stat.c              configure -state normal

            # Activate CPU registers and memory section
            .ctrl.cpu.reg_mem.reg.title.e     configure -state normal
            .ctrl.cpu.reg_mem.mem.title.l     configure -state normal
            .ctrl.cpu.reg_mem.mem.title.e     configure -state normal
            .ctrl.cpu.reg_mem.reg.refresh     configure -state normal
            .ctrl.cpu.reg_mem.mem.refresh     configure -state normal
            for {set i 0} {$i<16} {incr i} {
                .ctrl.cpu.reg_mem.reg.f$i.l$i        configure -state normal
                .ctrl.cpu.reg_mem.reg.f$i.e$i        configure -state normal
                .ctrl.cpu.reg_mem.mem.f$i.addr_e$i   configure -state normal
                .ctrl.cpu.reg_mem.mem.f$i.data_e$i   configure -state normal
            }
            .ctrl.cpu.reg_mem.reg.f0.e0              configure -bg $color(PC)
            refreshReg
            refreshMem

            # Activate Load TCL script section
            .ctrl.tclscript.ft.l          configure -state normal
            .ctrl.tclscript.ft.file       configure -state normal
            .ctrl.tclscript.ft.browse     configure -state normal
            .ctrl.tclscript.fb.read       configure -state normal
            
            # Activate the code debugger section
            .code.rb.txt                  configure -state normal
            .code.rb.none                 configure -state normal
            .code.rb.asm                  configure -state normal
            .code.rb.mix                  configure -state normal

            # Initial context save for all CPUs
            saveContext 0
            saveContext 1
            saveContext 2
            saveContext 3
        }

    } else {
        for {set ii 0} {$ii < $omsp_nr} {incr ii} {
            set omsp_info($ii,connected) 0
        }
        .ctrl.connect.info.l1.con         configure -text $error_msg -fg red
    }
}

proc displayMore  { } {

    global omsp_info
    global CpuNr

    # Destroy windows if already existing
    if {[lsearch -exact [winfo children .] .omsp_extra_info]!=-1} {
        destroy .omsp_extra_info
    }

    # Create master window
    toplevel     .omsp_extra_info
    wm title     .omsp_extra_info "openMSP430 extra info"
    wm geometry  .omsp_extra_info +380+200
    wm resizable .omsp_extra_info 0 0

    # Title
    set title "openMSP430"
    if {$omsp_info($CpuNr,alias)!=""} {
        set title $omsp_info($CpuNr,alias)
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
    .omsp_extra_info.extra.text insert end [format "CPU Version                : %5s\n" $omsp_info($CpuNr,cpu_ver)]
    .omsp_extra_info.extra.text insert end [format "User Version               : %5s\n" $omsp_info($CpuNr,user_ver)]
    if {$omsp_info($CpuNr,cpu_ver)==1} {
    .omsp_extra_info.extra.text insert end [format "Implementation             : %5s\n" --]
    } elseif {$omsp_info($CpuNr,asic)==0} {
    .omsp_extra_info.extra.text insert end [format "Implementation             : %5s\n" FPGA]
    } elseif {$omsp_info($CpuNr,asic)==1} {
    .omsp_extra_info.extra.text insert end [format "Implementation             : %5s\n" ASIC]
    }
    if {$omsp_info($CpuNr,mpy)==1} {
    .omsp_extra_info.extra.text insert end [format "Hardware Multiplier support: %5s\n" Yes]
    } elseif {$omsp_info($CpuNr,mpy)==0} {
    .omsp_extra_info.extra.text insert end [format "Hardware Multiplier support: %5s\n" No]
    } else {
    .omsp_extra_info.extra.text insert end [format "Hardware Multiplier support: %5s\n" --]
    }
    .omsp_extra_info.extra.text insert end [format "Program memory size        : %5s B\n" $omsp_info($CpuNr,pmem_size)]
    .omsp_extra_info.extra.text insert end [format "Data memory size           : %5s B\n" $omsp_info($CpuNr,dmem_size)]
    .omsp_extra_info.extra.text insert end [format "Peripheral address space   : %5s B\n" $omsp_info($CpuNr,per_size)]
    if {$omsp_info($CpuNr,alias)==""} {
    .omsp_extra_info.extra.text insert end [format "Alias                      : %5s\n\n\n" None]
    } else {
    .omsp_extra_info.extra.text insert end [format "Alias                      : %5s\n\n\n" $omsp_info($CpuNr,alias)]
    }

    .omsp_extra_info.extra.text insert end         "Extra Info\n\n" bold

    if {$omsp_info($CpuNr,alias)!=""} {

        set aliasEXTRA  [lsort -increasing [array names omsp_info -glob "$CpuNr,extra,*"]]
        if {[llength $aliasEXTRA]} {

            foreach currentEXTRA $aliasEXTRA {
                regexp {^.+,.+,(.+)$} $currentEXTRA whole_match extraATTR
                .omsp_extra_info.extra.text insert end     [format "%-15s: %s\n" $extraATTR  $omsp_info($currentEXTRA)]
            }
            .omsp_extra_info.extra.text insert end         "\n\n"
        }
    } else {
        .omsp_extra_info.extra.text insert end  "No alias found in 'omsp_alias.xml' file"
    }
}

proc highlightLine { line tagNameNew tagNameOld type } { 
    .code.text tag remove $tagNameOld 1.0     end
    .code.text tag remove $tagNameNew 1.0     end

    switch -exact -- $type {
        "0"     {.code.text tag add    $tagNameNew $line.0 $line.4}
        "1"     {.code.text tag add    $tagNameNew $line.2 $line.4}
        "2"     {.code.text tag add    $tagNameNew $line.3 $line.4}
        default {.code.text tag add    $tagNameNew $line.4 [expr $line+1].0}
    }
}

proc highlightCode   { } {
    global codeSelect
    global reg
    global brkpt
    global color

    if {$codeSelect!=1} {
        
        # Update PC
        regsub {0x} $reg(0) {} pc_val
        set code_match [.code.text search "$pc_val:" 1.0 end]
        set code_line 1
        regexp {(\d+).(\d+)} $code_match whole_match code_line code_column
        highlightLine $code_line highlightPC highlightPC 3
        .code.text see    $code_line.0

        # Some pre-processing
        set brkType(0) 0
        if {$brkpt(addr_0)==$brkpt(addr_1)} {
            set brkType(1) 1
        } else {
            set brkType(1) 0
        }
        if {$brkType(1)==1} {
            if {$brkpt(addr_1)==$brkpt(addr_2)} {
                set brkType(2) 2
            } else {
                set brkType(2) 0
            }
        } else {
            if {$brkpt(addr_0)==$brkpt(addr_2)} {
                set brkType(2) 1
            } else {
                if {$brkpt(addr_1)==$brkpt(addr_2)} {
                    set brkType(2) 1
                } else {
                    set brkType(2) 0
                }
            }
        }

        # Update Breakpoints if required
        for {set i 0} {$i<3} {incr i} {
            regsub {0x} $brkpt(addr_$i) {} brkpt_val
            set code_match [.code.text search "$brkpt_val:" 1.0 end]
            set code_line 1
            regexp {(\d+).(\d+)} $code_match whole_match code_line code_column
            if {$brkpt(en_$i)==1} {
                highlightLine $code_line "highlightBRK${i}_ACT" "highlightBRK${i}_DIS" $brkType($i)
            } else {
                highlightLine $code_line "highlightBRK${i}_DIS" "highlightBRK${i}_ACT" $brkType($i)
            }
        }

     }
}

proc waitForFile {fileName} {

    # Wait until file is present on the filesystem
    set timeout 1000
    for {set i 0} {$i <= $timeout} {incr i} {
        after 50
        if {[file exists $fileName]} {
            return 1
        }
    }
    return 0
}

proc updateCodeView {} {
    global codeSelect
    global reg
    global binFileType
    global binFileName
    global pmemIHEX
    global brkpt
    global isPmemRead

    if {($binFileName!="") | ($isPmemRead==1)} {

        if {$isPmemRead==1} {

            set currentFileType ihex
            set currentFileName "[expr [clock clicks]  ^ 0xffffffff].ihex"

            set fileId [open $currentFileName "w"]
            puts -nonewline $fileId $pmemIHEX
            close $fileId
            if {![waitForFile $currentFileName]} {
                .ctrl.load.info.l configure -text "Timeout: error writing temprary IHEX file" -fg red
                return 0
            }

        } else {
            set currentFileType $binFileType
            set currentFileName $binFileName
        }

        set temp_elf_file  "[clock clicks].elf"
        set temp_ihex_file "[clock clicks].ihex"
        if {[catch {exec msp430-objcopy -I $currentFileType -O elf32-msp430 $currentFileName $temp_elf_file} debug_info]} {
            .ctrl.load.info.l configure -text "$debug_info" -fg red
            return 0
        }
        if {![waitForFile $temp_elf_file]} {
            .ctrl.load.info.l configure -text "Timeout: ELF file conversion problem with \"msp430-objcopy\" executable" -fg red
            return 0
        }
        if {[string eq $currentFileType "ihex"]} {
            set dumpOpt "-D"
        } else {
            set dumpOpt "-d"
        }

        if {$codeSelect==1} {

            clearBreakpoints
            for {set i 0} {$i<3} {incr i} {
                set brkpt(en_$i) 0
                .ctrl.cpu.brkpt.chk$i  configure -state disable
                updateBreakpoint $i
            }
            if {[catch {exec msp430-objcopy -I $currentFileType -O ihex $temp_elf_file $temp_ihex_file} debug_info]} {
                .ctrl.load.info.l configure -text "$debug_info" -fg red
                return 0
            }
            if {![waitForFile  $temp_ihex_file]} {
                .ctrl.load.info.l configure -text "Timeout: IHEX file conversion problem with \"msp430-objcopy\" executable" -fg red
                return 0
            }
            set fp [open $temp_ihex_file r]
            set debug_info [read $fp]
            close $fp
        
            file delete $temp_ihex_file

        } elseif {$codeSelect==2} {
            for {set i 0} {$i<3} {incr i} {
                .ctrl.cpu.brkpt.chk$i  configure -state normal
            }
            if {[catch {exec msp430-objdump $dumpOpt $temp_elf_file} debug_info]} {
                .ctrl.load.info.l configure -text "$debug_info" -fg red
                return 0
            }
        } elseif {$codeSelect==3} {
            for {set i 0} {$i<3} {incr i} {
                .ctrl.cpu.brkpt.chk$i  configure -state normal
            }
            if {[catch {exec msp430-objdump $dumpOpt\S $temp_elf_file} debug_info]} {
                .ctrl.load.info.l configure -text "$debug_info" -fg red
                return 0
            }
        }
        file delete $temp_elf_file
        if {$isPmemRead==1} {
            file delet $currentFileName
        }

        .code.text configure -state normal
        .code.text delete 1.0 end
        .code.text insert end $debug_info
        highlightCode
        .code.text configure -state disabled
        return 1
    }
}

proc bin2ihex {startAddr binData } {

    set full_line_size       16
    set full_line_nr         [expr [llength $binData] / $full_line_size]
    set last_line_size       [expr [llength $binData] -($full_line_size*$full_line_nr)]
    set line_nr              $full_line_nr
    if {$last_line_size!=0} {incr line_nr}

    set ihex ""

    for {set ii 0} {$ii<$line_nr} {incr ii} {

        set line_size $full_line_size
        if {$ii==$full_line_nr} {
            set line_size $last_line_size
        }

        set currentAddr [expr $startAddr+($full_line_size*$ii)]
        set chksum $line_size
        set chksum [expr $chksum+($currentAddr/256)+($currentAddr&255)]
        append ihex ":"
        append ihex [format "%02x" $line_size]
        append ihex [format "%04x" $currentAddr]
        append ihex "00"
        for {set jj 0} {$jj<$line_size} {incr jj} {
            set byte [lindex $binData [expr ($full_line_size*$ii)+$jj]]
            set chksum [expr $chksum + $byte]
            append ihex [format "%02x" $byte]
        }
        append ihex [format "%02x\n" [expr 255 & (0x100 - $chksum)]]
    }
    append ihex ":00000001FF\n"
    set ihex [string toupper $ihex]
    return $ihex
}

proc readPmem {} {

    global CpuNr
    global pmemIHEX
    global mem_sizes
    global isPmemRead
   
    # Get program memory start address
    set startAddr [format "0x%04x" [expr 0x10000-[lindex $mem_sizes 0]]]

    # Retrieve the program memory content
    clearBreakpoints
    set binData [ReadMemQuick8 $CpuNr $startAddr [lindex $mem_sizes 0]]
    setBreakpoints
    .ctrl.load.info.l configure -text "Program memory successfully read" -fg "\#00ae00"

    # Update buttons
    .ctrl.load.fb.load     configure  -fg "\#000000" -activeforeground "\#000000"
    .ctrl.load.fb.open     configure  -fg "\#000000" -activeforeground "\#000000"
    .ctrl.load.fb.readpmem configure  -fg "\#909000" -activeforeground "\#909000"
    update

    # Convert the binary content into Intel-HEX format
    set pmemIHEX [bin2ihex $startAddr $binData]
    
    # Update debugger view
    set isPmemRead 1
    updateCodeView

}

proc loadProgram {load} {
    global current_file_name
    global cpu_status
    global reg
    global mem
    global mem_sizes
    global binFileType
    global binFileName
    global brkpt
    global CpuNr
    global isPmemRead
    global pmemIHEX
    global backup

    # Check if the file exists
    #----------------------------------------
    if {![file exists $current_file_name]} {
        .ctrl.load.info.l configure -text "Specified file doesn't exists: \"$current_file_name\"" -fg red
        return 0
    }

    # Eventually initialite other CPU path
    for {set i 0} {$i<4} {incr i} {
        if {$backup($i,current_file_name)==""} {
            set backup($i,current_file_name) "[file dirname $current_file_name]/"
        }
    }

    # Detect the file format depending on the file extention
    #--------------------------------------------------------
    set binFileType [file extension $current_file_name]
    set binFileType [string tolower $binFileType]
    regsub {\.} $binFileType {} binFileType

    if {![string eq $binFileType "ihex"] & ![string eq $binFileType "hex"] & ![string eq $binFileType "elf"]} {
        .ctrl.load.info.l configure -text "[string toupper $binFileType] file format not supported\"" -fg red
        return 0
    } 

    if {[string eq $binFileType "hex"]} {
        set binFileType "ihex"
    }
    if {[string eq $binFileType "elf"]} {
        set binFileType "elf32-msp430"
    }


    # Create and read debug informations
    #----------------------------------------
    set  binFileName $current_file_name
    set isPmemRead 0
    updateCodeView

    # Update buttons
    if {$load} {
        .ctrl.load.fb.load     configure  -fg "\#909000" -activeforeground "\#909000"
        .ctrl.load.fb.open     configure  -fg "\#000000" -activeforeground "\#000000"
    } else {
        .ctrl.load.fb.load     configure  -fg "\#000000" -activeforeground "\#000000"
        .ctrl.load.fb.open     configure  -fg "\#909000" -activeforeground "\#909000"
    }
    .ctrl.load.fb.readpmem     configure  -fg "\#000000" -activeforeground "\#000000"
    update

    # Create and read binary executable file
    #----------------------------------------

    # Generate binary file
    set bin_file "[clock clicks].bin"
    if {[catch {exec msp430-objcopy -I $binFileType -O binary $binFileName $bin_file} errMsg]} {
        .ctrl.load.info.l configure -text "$errMsg" -fg red
        return 0
    }
 
    # Wait until bin file is present on the filesystem
    if {![waitForFile $bin_file]} {
        .ctrl.load.info.l configure -text "Timeout: ELF to BIN file conversion problem with \"msp430-objcopy\" executable" -fg red
        return 0
    }

    # Read file
    set fp [open $bin_file r]
    fconfigure $fp -translation binary
    binary scan [read $fp] H* hex_data yop
    close $fp

    # Cleanup
    file delete $bin_file

    # Get program size
    set hex_size  [string length $hex_data]
    set byte_size [expr $hex_size/2]
    set word_size [expr $byte_size/2]

    # Make sure ELF program size is the same as the available program memory
    if {[lindex $mem_sizes 0] != [expr $hex_size/2]} {
        .ctrl.load.info.l configure -text "ERROR: ELF program size ([expr $hex_size/2] B) is different than the available program memory ([lindex $mem_sizes 0] B)" -fg red
        return 0
    }

    # Format data
    for {set i 0} {$i < $hex_size} {set i [expr $i+4]} {
        set hex_msb "[string index $hex_data [expr $i+2]][string index $hex_data [expr $i+3]]"
        set hex_lsb "[string index $hex_data [expr $i+0]][string index $hex_data [expr $i+1]]"
        lappend DataArray "0x$hex_msb$hex_lsb"
    }

    # Load program to openmsp430 target
    #-----------------------------------

    # Get program memory start address
    set StartAddr [format "0x%04x" [expr 0x10000-$byte_size]]

    # Clear active breakpoints
    clearBreakpoints

    if {$load==1} {

        # Reset & Stop CPU
        ExecutePOR_Halt $CpuNr

        # Load Program Memory
        .ctrl.load.info.l configure -text "Load..." -fg "\#cdad00"
        update
        WriteMemQuick $CpuNr $StartAddr $DataArray
    }

    # Verify program memory of the openmsp430 target
    #------------------------------------------------

    # Check Data
    .ctrl.load.info.l configure -text "Verify..." -fg "\#cdad00"
    update
    if {[VerifyMem $CpuNr $StartAddr $DataArray 1]} {
        if {$load==1} {
            .ctrl.load.info.l configure -text "Binary file successfully loaded" -fg "\#00ae00"
        } else {
            .ctrl.load.info.l configure -text "Binary file successfully opened" -fg "\#00ae00"
            setBreakpoints
        }
        set pmemIHEX ""
   } else {
        if {$load==1} {
            .ctrl.load.info.l configure -text "ERROR while loading the firmware " -fg red
        } else {
            .ctrl.load.info.l configure -text "ERROR: Specified binary file doesn't match the program memory content" -fg red
            setBreakpoints
        }
    }
    update

    if {$load==1} {
        # Re-initialize breakpoints
        for {set i 0} {$i<3} {incr i} {
            .ctrl.cpu.brkpt.addr$i  configure -state normal
            set brkpt(en_$i)    0
        }

        # Reset & Stop CPU
        ExecutePOR_Halt $CpuNr
        .ctrl.cpu.cpu.step  configure -state normal
        .ctrl.cpu.cpu.run   configure -text "Run"
        .ctrl.cpu.cpu.l3    configure -text "Stopped" -fg "\#cdad00"
        set cpu_status 0
    }
    refreshReg
    refreshMem
}

proc runCPU {} {
    global cpu_status
    global reg
    global mem
    global CpuNr

    if {$cpu_status} {
        HaltCPU $CpuNr
        .ctrl.cpu.cpu.step  configure -state normal
        .ctrl.cpu.cpu.run   configure -text "Run"
        .ctrl.cpu.cpu.l3    configure -text "Stopped" -fg "\#cdad00"
        set cpu_status 0
    } else {
        clearBreakpoints
        StepCPU $CpuNr
        setBreakpoints
        ReleaseCPU $CpuNr
        .ctrl.cpu.cpu.step  configure -state disabled
        .ctrl.cpu.cpu.run   configure -text "Stop"
        .ctrl.cpu.cpu.l3    configure -text "Running" -fg "\#00ae00"
        set cpu_status 1
    }
    refreshReg
    refreshMem
}

proc resetCPU {} {
    global cpu_status
    global reg
    global mem
    global CpuNr

    if {$cpu_status} {
        ExecutePOR $CpuNr
    } else {
        ExecutePOR_Halt $CpuNr
    }
    refreshReg
    refreshMem
}

proc singleStepCPU {} {
    global cpu_status
    global reg
    global mem
    global CpuNr

    if {$cpu_status==0} {
        clearBreakpoints
        StepCPU $CpuNr
        setBreakpoints
    }
    refreshReg
    refreshMem
}

proc statRegUpdate {} {
    global cpu_status
    global reg
    global mem
    global sr

    set tmp_reg [expr ($sr(v)      * 0x0100) |  \
                      ($sr(scg1)   * 0x0080) |  \
                      ($sr(oscoff) * 0x0020) |  \
                      ($sr(cpuoff) * 0x0010) |  \
                      ($sr(gie)    * 0x0008) |  \
                      ($sr(n)      * 0x0004) |  \
                      ($sr(z)      * 0x0002) |  \
                      ($sr(c)      * 0x0001)]

    set reg(2) [format "0x%04x" $tmp_reg]

    write2Reg 2
}


proc refreshReg {} {
    global reg
    global mem
    global sr
    global CpuNr

    # Read register values
    set new_vals [ReadRegAll $CpuNr]
    for {set i 0} {$i<16} {incr i} {
        set reg($i) [lindex $new_vals $i]
    }
    set sr(c)      [expr $reg(2) & 0x0001]
    set sr(z)      [expr $reg(2) & 0x0002]
    set sr(n)      [expr $reg(2) & 0x0004]
    set sr(gie)    [expr $reg(2) & 0x0008]
    set sr(cpuoff) [expr $reg(2) & 0x0010]
    set sr(oscoff) [expr $reg(2) & 0x0020]
    set sr(scg1)   [expr $reg(2) & 0x0080]
    set sr(v)      [expr $reg(2) & 0x0100]

    # Update highlighted line in the code view
    highlightCode
}

proc write2Reg {reg_num} {
    global reg
    global mem
    global CpuNr

    WriteReg $CpuNr $reg_num $reg($reg_num)
    refreshReg
    refreshMem
}

proc refreshMem {} {
    global reg
    global mem
    global CpuNr

    for {set i 0} {$i<16} {incr i} {
        # Check if address lay in 16 or 8 bit space
        if {[expr $mem(address_$i)]>=[expr 0x100]} {
            set Format 0
        } else {
            set Format 1
        }

        # Read data
        set mem(data_$i) [ReadMem $CpuNr $Format $mem(address_$i)]
    }
}

proc write2Mem {mem_num} {
    global reg
    global mem
    global CpuNr

    # Check if address lay in 16 or 8 bit space
    if {[expr $mem(address_$mem_num)]>=[expr 0x100]} {
        set Format 0
    } else {
        set Format 1
    }

    WriteMem $CpuNr $Format $mem(address_$mem_num) $mem(data_$mem_num)
    refreshReg
    refreshMem
}

proc updateBreakpoint {brkpt_num} {
    global brkpt
    global mem_sizes
    global CpuNr

    # Set the breakpoint
    if {$brkpt(en_$brkpt_num)==1} {
            
        # Make sure the specified address is an opcode
        regsub {0x} $brkpt(addr_$brkpt_num) {} brkpt_val
        set code_match [.code.text search "$brkpt_val:" 1.0 end]
        if {![string length $code_match]} {
            .ctrl.cpu.brkpt.addr$brkpt_num    configure -state normal
            set brkpt(en_$brkpt_num) 0

        } else {
            set brkpt(data_$brkpt_num) [ReadMem $CpuNr 0 $brkpt(addr_$brkpt_num)]
            
            # Only set a breakpoint if there is not already one there :-P
            if {$brkpt(data_$brkpt_num)=="0x4343"} {
                .ctrl.cpu.brkpt.addr$brkpt_num    configure -state normal
                set brkpt(en_$brkpt_num) 0
            } else {
                .ctrl.cpu.brkpt.addr$brkpt_num    configure -state readonly
                WriteMem $CpuNr 0 $brkpt(addr_$brkpt_num) 0x4343
            }
        }

    # Clear the breakpoint
    } else {
        .ctrl.cpu.brkpt.addr$brkpt_num    configure -state normal
        set opcode [ReadMem $CpuNr 0 $brkpt(addr_$brkpt_num)]
        if {$opcode=="0x4343"} {
            WriteMem $CpuNr 0 $brkpt(addr_$brkpt_num) $brkpt(data_$brkpt_num)
        }
    }

    highlightCode
}

proc clearBreakpoints {} {
    global connection_status
    global brkpt
    global mem_sizes
    global CpuNr

    if {$connection_status} {
        for {set i 0} {$i<3} {incr i} {
            if {$brkpt(en_$i)==1} {
                WriteMem $CpuNr 0 $brkpt(addr_$i) $brkpt(data_$i)
            }
        }
    }
}

proc setBreakpoints {} {
    global brkpt
    global mem_sizes
    global CpuNr

    for {set i 0} {$i<3} {incr i} {
        if {$brkpt(en_$i)==1} {
            set brkpt(data_$i) [ReadMem $CpuNr 0 $brkpt(addr_$i)]
            WriteMem $CpuNr 0 $brkpt(addr_$i) 0x4343
        }
    }
}

proc selectCPU {CpuNr_next} {

    global CpuNr

    # Read current font
    set font [.menu.cpu1 cget -font]
    set family      [font actual $font -family];
    set size        [font actual $font -size];
    set slant       [font actual $font -slant];
    set underline   [font actual $font -underline];
    set overstrike  [font actual $font -overstrike];

    # Create normal font
    set font_normal "-family \"$family\" -size $size -weight normal -slant $slant -underline $underline -overstrike $overstrike"

    # Create bold font
    set font_bold   "-family \"$family\" -size $size -weight bold   -slant $slant -underline $underline -overstrike $overstrike"

    if {$CpuNr_next==0} {
        .menu.cpu0     configure -relief sunken  -font $font_bold   -fg "\#00ae00" -activeforeground "\#00ae00"
        .menu.cpu1     configure -relief raised  -font $font_normal -fg "\#000000" -activeforeground "\#000000"
        .menu.cpu2     configure -relief raised  -font $font_normal -fg "\#000000" -activeforeground "\#000000"
        .menu.cpu3     configure -relief raised  -font $font_normal -fg "\#000000" -activeforeground "\#000000"

    } elseif {$CpuNr_next==1} {
        .menu.cpu0     configure -relief raised  -font $font_normal -fg "\#000000" -activeforeground "\#000000"
        .menu.cpu1     configure -relief sunken  -font $font_bold   -fg "\#00ae00" -activeforeground "\#00ae00"
        .menu.cpu2     configure -relief raised  -font $font_normal -fg "\#000000" -activeforeground "\#000000"
        .menu.cpu3     configure -relief raised  -font $font_normal -fg "\#000000" -activeforeground "\#000000"

    } elseif {$CpuNr_next==2} {
        .menu.cpu0     configure -relief raised  -font $font_normal -fg "\#000000" -activeforeground "\#000000"
        .menu.cpu1     configure -relief raised  -font $font_normal -fg "\#000000" -activeforeground "\#000000"
        .menu.cpu2     configure -relief sunken  -font $font_bold   -fg "\#00ae00" -activeforeground "\#00ae00"
        .menu.cpu3     configure -relief raised  -font $font_normal -fg "\#000000" -activeforeground "\#000000"

    } else { 
        .menu.cpu0     configure -relief raised  -font $font_normal -fg "\#000000" -activeforeground "\#000000"
        .menu.cpu1     configure -relief raised  -font $font_normal -fg "\#000000" -activeforeground "\#000000"
        .menu.cpu2     configure -relief raised  -font $font_normal -fg "\#000000" -activeforeground "\#000000"
        .menu.cpu3     configure -relief sunken  -font $font_bold   -fg "\#00ae00" -activeforeground "\#00ae00"
    }

    saveContext    $CpuNr
    set CpuNr      $CpuNr_next
    restoreContext $CpuNr

    return 1
}

proc advancedConfiguration {} {

    global omsp_info
    global omsp_conf
    global omsp_nr

    # Initialize temp variables
    global temp_nrcore
    global temp_if
    global temp_adapt
    global temp_addr
    regexp {(.+)_(.+)} $omsp_conf(interface) whole_match temp_if temp_adapt
    set temp_if      [string toupper $temp_if]
    set temp_adapt   [string toupper $temp_adapt]
    set temp_nrcore  $omsp_nr
    set temp_addr(0) $omsp_conf(0,cpuaddr)
    set temp_addr(1) $omsp_conf(1,cpuaddr)
    set temp_addr(2) $omsp_conf(2,cpuaddr)
    set temp_addr(3) $omsp_conf(3,cpuaddr)

    # Destroy windows if already existing
    if {[lsearch -exact [winfo children .] .omsp_adapt_config]!=-1} {
        destroy .omsp_adapt_config
    }

    # Create master window
    toplevel     .omsp_adapt_config
    wm title     .omsp_adapt_config "Advanced configuration"
    wm geometry  .omsp_adapt_config +380+200
    wm resizable .omsp_adapt_config 0 0

    # Title
    label  .omsp_adapt_config.title  -text "Advanced configuration"   -anchor center -fg "\#ae0000" -font {-weight bold -size 16}
    pack   .omsp_adapt_config.title  -side top -padx {20 20} -pady {20 10}

    # Create the main configuration area
    frame    .omsp_adapt_config.main  -bd 2
    pack     .omsp_adapt_config.main  -side top  -padx 10      -pady 10

    # Create the ok/cancel area
    frame    .omsp_adapt_config.ok    -bd 2
    pack     .omsp_adapt_config.ok    -side top  -padx 10      -pady 10


    # Create the Adapter Menu
    frame    .omsp_adapt_config.main.adapter     -bd 2 -relief ridge
    pack     .omsp_adapt_config.main.adapter     -side left  -padx 10      -pady 10 -fill both

    # Create the I2C Menu
    frame    .omsp_adapt_config.main.i2c           -bd 2 -relief ridge
    pack     .omsp_adapt_config.main.i2c           -side right -padx 10      -pady 10  -fill both


    # Adapter stuff
    label    .omsp_adapt_config.main.adapter.title    -text "Adapter configuration"   -anchor center -fg "\#000000" -font {-weight bold -size 12}
    pack     .omsp_adapt_config.main.adapter.title    -side top -padx 10 -pady 10
    frame    .omsp_adapt_config.main.adapter.ser
    pack     .omsp_adapt_config.main.adapter.ser      -side top  -padx 10      -pady 10

    label    .omsp_adapt_config.main.adapter.ser.l    -text "Serial Debug Interface:" -anchor center
    pack     .omsp_adapt_config.main.adapter.ser.l    -side left
    combobox .omsp_adapt_config.main.adapter.ser.p    -textvariable temp_if -editable false -width 10 -command {updateAdvancedConfiguration}
    eval     .omsp_adapt_config.main.adapter.ser.p    list insert end [list "UART" "I2C"]
    pack     .omsp_adapt_config.main.adapter.ser.p    -side right -padx 5

    frame    .omsp_adapt_config.main.adapter.ada
    pack     .omsp_adapt_config.main.adapter.ada -side top  -padx 10      -pady 10  -fill x

    label    .omsp_adapt_config.main.adapter.ada.l    -text "Adapter selection:" -anchor w
    pack     .omsp_adapt_config.main.adapter.ada.l    -side left
    combobox .omsp_adapt_config.main.adapter.ada.p    -textvariable temp_adapt -editable false -width 10
    eval     .omsp_adapt_config.main.adapter.ada.p    list insert end [list "GENERIC"]
    pack     .omsp_adapt_config.main.adapter.ada.p    -side right -padx 5


    # I2C stuff
    label    .omsp_adapt_config.main.i2c.title         -text "I2C configuration"   -anchor center -fg "\#000000" -font {-weight bold -size 12}
    pack     .omsp_adapt_config.main.i2c.title         -side top -padx 10 -pady 10
    frame    .omsp_adapt_config.main.i2c.cpunr
    pack     .omsp_adapt_config.main.i2c.cpunr        -side top  -padx 10      -pady 10  -fill x
    label    .omsp_adapt_config.main.i2c.cpunr.l      -text "Number of cores:" -anchor w
    pack     .omsp_adapt_config.main.i2c.cpunr.l      -side left -padx 5
    spinbox  .omsp_adapt_config.main.i2c.cpunr.s      -from 1 -to 4 -textvariable temp_nrcore -state readonly -width 4 -command {updateAdvancedConfiguration}
    pack     .omsp_adapt_config.main.i2c.cpunr.s      -side right -padx 5

    frame    .omsp_adapt_config.main.i2c.cpu0
    pack     .omsp_adapt_config.main.i2c.cpu0         -side top  -padx 10      -pady 10  -fill x
    label    .omsp_adapt_config.main.i2c.cpu0.l       -text "I2C Address (Core 0):" -anchor w
    pack     .omsp_adapt_config.main.i2c.cpu0.l       -side left -padx 5
    spinbox  .omsp_adapt_config.main.i2c.cpu0.s       -from 8 -to 119 -textvariable temp_addr(0) -width 4
    pack     .omsp_adapt_config.main.i2c.cpu0.s       -side right -padx 5

    frame    .omsp_adapt_config.main.i2c.cpu1
    pack     .omsp_adapt_config.main.i2c.cpu1         -side top  -padx 10      -pady 10  -fill x
    label    .omsp_adapt_config.main.i2c.cpu1.l       -text "I2C Address (Core 1):" -anchor w
    pack     .omsp_adapt_config.main.i2c.cpu1.l       -side left -padx 5
    spinbox  .omsp_adapt_config.main.i2c.cpu1.s       -from 8 -to 119 -textvariable temp_addr(1) -width 4
    pack     .omsp_adapt_config.main.i2c.cpu1.s       -side right -padx 5

    frame    .omsp_adapt_config.main.i2c.cpu2
    pack     .omsp_adapt_config.main.i2c.cpu2         -side top  -padx 10      -pady 10  -fill x
    label    .omsp_adapt_config.main.i2c.cpu2.l       -text "I2C Address (Core 2):" -anchor w
    pack     .omsp_adapt_config.main.i2c.cpu2.l       -side left -padx 5
    spinbox  .omsp_adapt_config.main.i2c.cpu2.s       -from 8 -to 119 -textvariable temp_addr(2) -width 4
    pack     .omsp_adapt_config.main.i2c.cpu2.s       -side right -padx 5

    frame    .omsp_adapt_config.main.i2c.cpu3
    pack     .omsp_adapt_config.main.i2c.cpu3         -side top  -padx 10      -pady 10  -fill x
    label    .omsp_adapt_config.main.i2c.cpu3.l       -text "I2C Address (Core 3):" -anchor w
    pack     .omsp_adapt_config.main.i2c.cpu3.l       -side left -padx 5
    spinbox  .omsp_adapt_config.main.i2c.cpu3.s       -from 8 -to 119 -textvariable temp_addr(3) -width 4
    pack     .omsp_adapt_config.main.i2c.cpu3.s       -side right -padx 5


    # Create OK/Cancel button
    button .omsp_adapt_config.ok.okay   -text "OK"     -command {set omsp_conf(interface) [string tolower "${temp_if}_${temp_adapt}"]
                                                                 set omsp_nr              $temp_nrcore; 
                                                                 set omsp_conf(0,cpuaddr) $temp_addr(0); 
                                                                 set omsp_conf(1,cpuaddr) $temp_addr(1);
                                                                 set omsp_conf(2,cpuaddr) $temp_addr(2);
                                                                 set omsp_conf(3,cpuaddr) $temp_addr(3);
                                                                 .ctrl.connect.serial.p2 configure -editable  1;
                                                                 eval .ctrl.connect.serial.p2 list delete 0 end;
                                                                 eval .ctrl.connect.serial.p2 list insert   end [lindex [GetAllowedSpeeds] 2];
                                                                 set omsp_conf(baudrate) [lindex [GetAllowedSpeeds] 1];
                                                                 .ctrl.connect.serial.p2 configure -editable  [lindex [GetAllowedSpeeds] 0];
                                                                 destroy .omsp_adapt_config}
    pack   .omsp_adapt_config.ok.okay   -side bottom   -side left  -expand true -fill x -padx 5 -pady 10
    button .omsp_adapt_config.ok.cancel -text "CANCEL" -command {destroy .omsp_adapt_config}
    pack   .omsp_adapt_config.ok.cancel -side bottom   -side right -expand true -fill x -padx 5 -pady 10

    updateAdvancedConfiguration
}

proc updateAdvancedConfiguration {{w ""} {sel ""}} {

    global temp_if
    global temp_adapt
    global temp_nrcore
    global connection_status

    if {$connection_status} {
        .omsp_adapt_config.main.adapter.ser.p configure -state disabled
        .omsp_adapt_config.main.adapter.ada.p configure -state disabled
        .omsp_adapt_config.main.i2c.cpunr.s   configure -state disabled
        .omsp_adapt_config.main.i2c.cpu0.s    configure -state disabled
        .omsp_adapt_config.main.i2c.cpu1.s    configure -state disabled
        .omsp_adapt_config.main.i2c.cpu2.s    configure -state disabled
        .omsp_adapt_config.main.i2c.cpu3.s    configure -state disabled

    } else {
        if {$sel=="UART"} {
            eval .omsp_adapt_config.main.adapter.ada.p  list delete 0 end
            eval .omsp_adapt_config.main.adapter.ada.p  list insert   end [list "GENERIC"]
            set temp_adapt "GENERIC"

        } elseif {$sel=="I2C"} {

            eval .omsp_adapt_config.main.adapter.ada.p  list delete 0 end
            eval .omsp_adapt_config.main.adapter.ada.p  list insert   end [list "USB-ISS"]
            set temp_adapt "USB-ISS"

        }

        if {$temp_if=="UART"} {

            .omsp_adapt_config.main.i2c.cpunr.s configure -state disabled
            .omsp_adapt_config.main.i2c.cpu0.s  configure -state disabled
            .omsp_adapt_config.main.i2c.cpu1.s  configure -state disabled
            .omsp_adapt_config.main.i2c.cpu2.s  configure -state disabled
            .omsp_adapt_config.main.i2c.cpu3.s  configure -state disabled

        } elseif {$temp_if=="I2C"} {

            .omsp_adapt_config.main.i2c.cpunr.s configure -state normal
#           .omsp_adapt_config.main.i2c.cpunr.s configure -state normal
            .omsp_adapt_config.main.i2c.cpu0.s  configure -state normal

            if {$temp_nrcore < 2} {.omsp_adapt_config.main.i2c.cpu1.s configure -state disabled
            } else                {.omsp_adapt_config.main.i2c.cpu1.s configure -state normal}
        
            if {$temp_nrcore < 3} {.omsp_adapt_config.main.i2c.cpu2.s configure -state disabled
            } else                {.omsp_adapt_config.main.i2c.cpu2.s configure -state normal}
        
            if {$temp_nrcore < 4} {.omsp_adapt_config.main.i2c.cpu3.s configure -state disabled
            } else                {.omsp_adapt_config.main.i2c.cpu3.s configure -state normal}
 

        }
    }
}

proc saveContext {CpuNr} {

    global current_file_name   
    global brkpt
    global mem
    global mem_sizes
    global codeSelect
    global isPmemRead
    global binFileType
    global binFileName
    global pmemIHEX

    global backup

    set backup($CpuNr,current_file_name) $current_file_name

    set backup($CpuNr,load_color)        [.ctrl.load.fb.load     cget  -fg]
    set backup($CpuNr,open_color)        [.ctrl.load.fb.open     cget  -fg]
    set backup($CpuNr,readpmem_color)    [.ctrl.load.fb.readpmem cget  -fg]

    set backup($CpuNr,info_text)         [.ctrl.load.info.l      cget -text]
    set backup($CpuNr,info_color)        [.ctrl.load.info.l      cget -fg]

    for {set i 0} {$i<3} {incr i} {
        set backup($CpuNr,brkpt_addr_$i)     $brkpt(addr_$i)
        set backup($CpuNr,brkpt_en_$i)       $brkpt(en_$i)
        set backup($CpuNr,brkpt_readonly_$i) [.ctrl.cpu.brkpt.addr$i cget -state]
    }

    for {set i 0} {$i<16} {incr i} {
        set backup($CpuNr,mem_addr_$i)   $mem(address_$i)
    }
    set backup($CpuNr,mem_sizes)         $mem_sizes

    set backup($CpuNr,codeSelect)        $codeSelect
    set backup($CpuNr,isPmemRead)        $isPmemRead
    set backup($CpuNr,binFileType)       $binFileType
    set backup($CpuNr,binFileName)       $binFileName
    set backup($CpuNr,pmemIHEX)          $pmemIHEX

    return 1
}

proc restoreContext {CpuNr} {

    global current_file_name   
    global brkpt
    global mem
    global mem_sizes
    global codeSelect
    global isPmemRead
    global binFileType
    global binFileName
    global pmemIHEX
    global cpu_status
    global connection_status

    global backup

    set pmemIHEX    $backup($CpuNr,pmemIHEX)
    set binFileName $backup($CpuNr,binFileName)
    set binFileType $backup($CpuNr,binFileType)
    set isPmemRead  $backup($CpuNr,isPmemRead)
    set codeSelect  $backup($CpuNr,codeSelect)
    
    for {set i 0} {$i<16} {incr i} {
        set mem(address_$i) $backup($CpuNr,mem_addr_$i)
    }
    set mem_sizes $backup($CpuNr,mem_sizes)

    for {set i 0} {$i<3} {incr i} {
        set brkpt(addr_$i) $backup($CpuNr,brkpt_addr_$i)
        set brkpt(en_$i)   $backup($CpuNr,brkpt_en_$i)
        .ctrl.cpu.brkpt.addr$i configure -state $backup($CpuNr,brkpt_readonly_$i)
    }

    .ctrl.load.info.l      configure -text $backup($CpuNr,info_text)
    .ctrl.load.info.l      configure -fg   $backup($CpuNr,info_color)

    .ctrl.load.fb.load     configure -fg   $backup($CpuNr,load_color)     -activeforeground $backup($CpuNr,load_color)
    .ctrl.load.fb.open     configure -fg   $backup($CpuNr,open_color)     -activeforeground $backup($CpuNr,open_color)
    .ctrl.load.fb.readpmem configure -fg   $backup($CpuNr,readpmem_color) -activeforeground $backup($CpuNr,readpmem_color)

    set current_file_name  $backup($CpuNr,current_file_name)

    update

    if {$connection_status} {
        if {[IsHalted $CpuNr]} {
            .ctrl.cpu.cpu.step  configure -state normal
            .ctrl.cpu.cpu.run   configure -text "Run"
            .ctrl.cpu.cpu.l3    configure -text "Stopped" -fg "\#cdad00"
            set cpu_status 0
        } else {
            .ctrl.cpu.cpu.step  configure -state disabled
            .ctrl.cpu.cpu.run   configure -text "Stop"
            .ctrl.cpu.cpu.l3    configure -text "Running" -fg "\#00ae00"
            set cpu_status 1
        }
        refreshReg
        refreshMem
        .code.text configure -state normal
        .code.text delete 1.0 end
        .code.text configure -state disabled
        updateCodeView
    }

 return 1
}

###############################################################################
#                                                                             #
#                           CREATE GRAPHICAL INTERFACE                        #
#                                                                             #
###############################################################################

####################################
#   CREATE & PLACE MAIN WIDGETS    #
####################################

wm title    . "openMSP430 mini debugger"
wm iconname . "openMSP430 mini debugger"

# Create the Main Menu
frame  .menu
pack   .menu                  -side top    -padx 10       -pady 10       -fill x

# Create the CPU Control field
frame  .ctrl
pack   .ctrl                  -side left   -padx {5 0}    -pady 10       -fill both

# Create the Code text field
frame  .code
pack   .code                  -side right  -padx 5        -pady 10       -fill both  -expand true
frame  .code.rb
pack   .code.rb               -side bottom -padx 10       -pady 10       -fill both

# Create the connection frame
frame  .ctrl.connect          -bd 2        -relief ridge  ;# solid
pack   .ctrl.connect          -side top    -padx 10       -pady 0        -fill x

# Create the Serial Menu
frame  .ctrl.connect.serial
pack   .ctrl.connect.serial   -side top    -padx 10       -pady {10 0}   -fill x

# Create the memory size
frame  .ctrl.connect.info
pack   .ctrl.connect.info     -side top    -padx 10       -pady {10 10}  -fill x

# Create the Load executable field
frame  .ctrl.load             -bd 2        -relief ridge  ;# solid
pack   .ctrl.load             -side top    -padx 10       -pady {10 10}  -fill x

# Create the cpu field
frame  .ctrl.cpu              -bd 2        -relief ridge  ;# solid
pack   .ctrl.cpu              -side top    -padx 10       -pady {0 10}   -fill x

# Create the cpu control field
frame  .ctrl.cpu.cpu
pack   .ctrl.cpu.cpu          -side top    -padx 10       -pady {20 10}  -fill x

# Create the breakpoint control field
frame  .ctrl.cpu.brkpt
pack   .ctrl.cpu.brkpt        -side top    -padx 10       -pady {10 20}  -fill x

# Create the cpu status field
frame  .ctrl.cpu.reg_stat
pack   .ctrl.cpu.reg_stat     -side top    -padx 10       -pady {10 10}  -fill x

# Create the cpu registers/memory fields
frame  .ctrl.cpu.reg_mem
pack   .ctrl.cpu.reg_mem      -side top    -padx 10       -pady {5 10}   -fill x
frame  .ctrl.cpu.reg_mem.reg
pack   .ctrl.cpu.reg_mem.reg  -side left   -padx {10 30}                 -fill x
frame  .ctrl.cpu.reg_mem.mem
pack   .ctrl.cpu.reg_mem.mem  -side left   -padx {30 10}                 -fill x

# Create the TCL script field
frame  .ctrl.tclscript        -bd 2 -relief ridge         ;# solid
pack   .ctrl.tclscript        -side top    -padx 10       -pady {0 20}   -fill x


####################################
#  CREATE THE CPU CONTROL SECTION  #
####################################

# Exit button
button .menu.exit      -text "Exit" -command {clearBreakpoints; exit 0}
pack   .menu.exit      -side left

# CPU selection buttons
label  .menu.cpusel    -text "oMSP core Selection:" -anchor w -state disabled
pack   .menu.cpusel    -side left -padx "100 0"
button .menu.cpu0      -text "Core 0" -command {selectCPU 0}  -state disabled
pack   .menu.cpu0      -side left -padx 10
button .menu.cpu1      -text "Core 1" -command {selectCPU 1}  -state disabled
pack   .menu.cpu1      -side left -padx 10
button .menu.cpu2      -text "Core 2" -command {selectCPU 2}  -state disabled
pack   .menu.cpu2      -side left -padx 10
button .menu.cpu3      -text "Core 3" -command {selectCPU 3}  -state disabled
pack   .menu.cpu3      -side left -padx 10

# openMSP430 label
label  .menu.omsp      -text "openMSP430 mini debugger" -anchor center -fg "\#6a5acd" -font {-weight bold -size 16}
pack   .menu.omsp      -side right -padx 20 

# Serial Port fields
label    .ctrl.connect.serial.l1    -text "Device Port:"  -anchor w
pack     .ctrl.connect.serial.l1    -side left
combobox .ctrl.connect.serial.p1    -textvariable omsp_conf(device)   -width 15 -editable true
eval     .ctrl.connect.serial.p1    list insert end [utils::uart_port_list]
pack     .ctrl.connect.serial.p1    -side left -padx 5

label    .ctrl.connect.serial.l2    -text "  Speed:" -anchor w
pack     .ctrl.connect.serial.l2    -side left
combobox .ctrl.connect.serial.p2    -textvariable omsp_conf(baudrate) -width 14 -editable [lindex [GetAllowedSpeeds] 0]
eval     .ctrl.connect.serial.p2    list insert end [lindex [GetAllowedSpeeds] 2]
pack     .ctrl.connect.serial.p2    -side left -padx 5

button   .ctrl.connect.serial.connect -text "Connect" -width 9 -command {connect_openMSP430}
pack     .ctrl.connect.serial.connect -side right -padx 5

button   .ctrl.connect.serial.extra -text "Advanced..." -width 10 -command {advancedConfiguration}
pack     .ctrl.connect.serial.extra -side left -padx 10

# CPU status & info
frame    .ctrl.connect.info.l1
pack     .ctrl.connect.info.l1      -side top    -padx 0      -pady {0 0} -fill x

label    .ctrl.connect.info.l1.cpu  -text "CPU Info:"       -anchor w
pack     .ctrl.connect.info.l1.cpu  -side left -padx "0 10"
label    .ctrl.connect.info.l1.con  -text "Disconnected"    -anchor w -fg Red
pack     .ctrl.connect.info.l1.con  -side left
button   .ctrl.connect.info.l1.more -text "More..."         -width 9 -command {displayMore} -state disabled
pack     .ctrl.connect.info.l1.more -side right -padx 5


# Load ELF file fields
frame  .ctrl.load.ft
pack   .ctrl.load.ft        -side top -fill x -padx "10 0" -pady "10 0"
label  .ctrl.load.ft.l      -text "ELF file:"  -state disabled
pack   .ctrl.load.ft.l      -side left -padx "0 10"
entry  .ctrl.load.ft.file   -width 58 -relief sunken -textvariable current_file_name -state disabled
pack   .ctrl.load.ft.file   -side left -padx 10
button .ctrl.load.ft.browse -text "Browse" -width 9 -state disabled -command {set current_file_name [tk_getOpenFile -filetypes {{{ELF/Intel-Hex Files} {.elf .ihex .hex}} {{All Files} *}}]}
pack   .ctrl.load.ft.browse -side right -padx {5 15}
frame  .ctrl.load.fb
pack   .ctrl.load.fb          -side top -fill x -padx "10 0" -pady "5 5"
button .ctrl.load.fb.load     -text "Load ELF File !"       -state disabled -command {loadProgram 1}
pack   .ctrl.load.fb.load     -side left -padx 5 -fill x
button .ctrl.load.fb.open     -text "Open ELF File !"       -state disabled -command {loadProgram 0}
pack   .ctrl.load.fb.open     -side left -padx 5 -fill x
button .ctrl.load.fb.readpmem -text "Read Program Memory !" -state disabled -command {readPmem}
pack   .ctrl.load.fb.readpmem -side left -padx 5 -fill x
frame  .ctrl.load.info
pack   .ctrl.load.info        -side top -fill x -padx "10 0" -pady "5 10"
label  .ctrl.load.info.t      -text "Firmware info:" -anchor w       -state disabled
pack   .ctrl.load.info.t      -side left -padx "0 10"
label  .ctrl.load.info.l      -text "No info available" -anchor w -fg Red   -state disabled
pack   .ctrl.load.info.l      -side left

# CPU Control
label  .ctrl.cpu.cpu.l1     -text "CPU Control:" -anchor w  -state disabled
pack   .ctrl.cpu.cpu.l1     -side left
button .ctrl.cpu.cpu.reset  -text "Reset" -state disabled -command {resetCPU}
pack   .ctrl.cpu.cpu.reset  -side left -padx 5 -fill x
button .ctrl.cpu.cpu.run    -text "Stop"  -state disabled -command {runCPU}
pack   .ctrl.cpu.cpu.run    -side left -padx 5 -fill x
button .ctrl.cpu.cpu.step   -text "Step"  -state disabled -command {singleStepCPU}
pack   .ctrl.cpu.cpu.step   -side left -padx 5 -fill x
label  .ctrl.cpu.cpu.l2     -text "CPU Status:" -anchor w  -state disabled
pack   .ctrl.cpu.cpu.l2     -side left -padx "40 0"
label  .ctrl.cpu.cpu.l3     -text "--" -anchor w  -state disabled
pack   .ctrl.cpu.cpu.l3     -side left

# Breakpoints
label       .ctrl.cpu.brkpt.l1       -text "CPU Breakpoints:"    -anchor w  -state disabled
pack        .ctrl.cpu.brkpt.l1       -side left
entry       .ctrl.cpu.brkpt.addr0    -textvariable brkpt(addr_0) -relief sunken -state disabled  -width 10
pack        .ctrl.cpu.brkpt.addr0    -side left -padx "20 0"
bind        .ctrl.cpu.brkpt.addr0    <Return> "highlightCode"
checkbutton .ctrl.cpu.brkpt.chk0     -variable brkpt(en_0)       -state disabled -command "updateBreakpoint 0" -text "Enable"
pack        .ctrl.cpu.brkpt.chk0     -side left -padx "0"
entry       .ctrl.cpu.brkpt.addr1    -textvariable brkpt(addr_1) -relief sunken -state disabled  -width 10
pack        .ctrl.cpu.brkpt.addr1    -side left -padx "20 0"
bind        .ctrl.cpu.brkpt.addr1    <Return> "highlightCode"
checkbutton .ctrl.cpu.brkpt.chk1     -variable brkpt(en_1)       -state disabled -command "updateBreakpoint 1" -text "Enable"
pack        .ctrl.cpu.brkpt.chk1     -side left -padx "0"
entry       .ctrl.cpu.brkpt.addr2    -textvariable brkpt(addr_2) -relief sunken -state disabled  -width 10
pack        .ctrl.cpu.brkpt.addr2    -side left -padx "20 0"
bind        .ctrl.cpu.brkpt.addr2    <Return> "highlightCode"
checkbutton .ctrl.cpu.brkpt.chk2     -variable brkpt(en_2)       -state disabled -command "updateBreakpoint 2" -text "Enable"
pack        .ctrl.cpu.brkpt.chk2     -side left -padx "0"


# CPU Status register
label       .ctrl.cpu.reg_stat.l1     -text "Status register (r2/sr):" -anchor w -state disabled
pack        .ctrl.cpu.reg_stat.l1     -side left
checkbutton .ctrl.cpu.reg_stat.v      -variable sr(v)      -state disabled -command "statRegUpdate" -text "V"
pack        .ctrl.cpu.reg_stat.v      -side left -padx "0"
checkbutton .ctrl.cpu.reg_stat.scg1   -variable sr(scg1)   -state disabled -command "statRegUpdate" -text "SCG1"
pack        .ctrl.cpu.reg_stat.scg1   -side left -padx "0"
checkbutton .ctrl.cpu.reg_stat.oscoff -variable sr(oscoff) -state disabled -command "statRegUpdate" -text "OSCOFF"
pack        .ctrl.cpu.reg_stat.oscoff -side left -padx "0"
checkbutton .ctrl.cpu.reg_stat.cpuoff -variable sr(cpuoff) -state disabled -command "statRegUpdate" -text "CPUOFF"
pack        .ctrl.cpu.reg_stat.cpuoff -side left -padx "0"
checkbutton .ctrl.cpu.reg_stat.gie    -variable sr(gie)    -state disabled -command "statRegUpdate" -text "GIE"
pack        .ctrl.cpu.reg_stat.gie    -side left -padx "0"
checkbutton .ctrl.cpu.reg_stat.n      -variable sr(n)      -state disabled -command "statRegUpdate" -text "N"
pack        .ctrl.cpu.reg_stat.n      -side left -padx "0"
checkbutton .ctrl.cpu.reg_stat.z      -variable sr(z)      -state disabled -command "statRegUpdate" -text "Z"
pack        .ctrl.cpu.reg_stat.z      -side left -padx "0"
checkbutton .ctrl.cpu.reg_stat.c      -variable sr(c)      -state disabled -command "statRegUpdate" -text "C"
pack        .ctrl.cpu.reg_stat.c      -side left -padx "0"

# CPU Registers
frame  .ctrl.cpu.reg_mem.reg.title
pack   .ctrl.cpu.reg_mem.reg.title           -side top
label  .ctrl.cpu.reg_mem.reg.title.l         -text " " -width 8 -anchor w
pack   .ctrl.cpu.reg_mem.reg.title.l         -side left
label  .ctrl.cpu.reg_mem.reg.title.e         -text "Registers" -anchor w  -state disabled
pack   .ctrl.cpu.reg_mem.reg.title.e         -side left
for {set i 0} {$i<16} {incr i} {
    switch $i {
        {0}     {set reg_label "r0 (pc):"}
        {1}     {set reg_label "r1 (sp):"}
        {2}     {set reg_label "r2 (sr):"}
        default {set reg_label "r$i:"}
    }
    frame  .ctrl.cpu.reg_mem.reg.f$i
    pack   .ctrl.cpu.reg_mem.reg.f$i           -side top
    label  .ctrl.cpu.reg_mem.reg.f$i.l$i       -text $reg_label -width 8 -anchor w  -state disabled
    pack   .ctrl.cpu.reg_mem.reg.f$i.l$i       -side left
    entry  .ctrl.cpu.reg_mem.reg.f$i.e$i       -textvariable reg($i) -relief sunken -state disabled
    pack   .ctrl.cpu.reg_mem.reg.f$i.e$i       -side left
    bind   .ctrl.cpu.reg_mem.reg.f$i.e$i       <Return> "write2Reg $i"
}
button .ctrl.cpu.reg_mem.reg.refresh           -text "Refresh Registers"  -state disabled -command {refreshReg}
pack   .ctrl.cpu.reg_mem.reg.refresh           -side top -padx 5 -pady 10 -fill x -expand true


# CPU Memory
frame  .ctrl.cpu.reg_mem.mem.title
pack   .ctrl.cpu.reg_mem.mem.title             -side top
label  .ctrl.cpu.reg_mem.mem.title.l           -text "      Address      " -anchor w -width 20  -state disabled
pack   .ctrl.cpu.reg_mem.mem.title.l           -side left -fill x -expand true
label  .ctrl.cpu.reg_mem.mem.title.e           -text "        Data       " -anchor w -width 20  -state disabled
pack   .ctrl.cpu.reg_mem.mem.title.e           -side left -fill x -expand true
for {set i 0} {$i<16} {incr i} {
    frame  .ctrl.cpu.reg_mem.mem.f$i
    pack   .ctrl.cpu.reg_mem.mem.f$i           -side top

    entry  .ctrl.cpu.reg_mem.mem.f$i.addr_e$i  -textvariable mem(address_$i) -relief sunken -state disabled  -width 20
    pack   .ctrl.cpu.reg_mem.mem.f$i.addr_e$i  -side left
    bind   .ctrl.cpu.reg_mem.mem.f$i.addr_e$i  <Return> "refreshMem"
    entry  .ctrl.cpu.reg_mem.mem.f$i.data_e$i  -textvariable mem(data_$i)    -relief sunken -state disabled  -width 20
    pack   .ctrl.cpu.reg_mem.mem.f$i.data_e$i  -side left
    bind   .ctrl.cpu.reg_mem.mem.f$i.data_e$i  <Return> "write2Mem $i"
}
button .ctrl.cpu.reg_mem.mem.refresh -text "Refresh Memory"     -state disabled -command {refreshMem}
pack   .ctrl.cpu.reg_mem.mem.refresh -side top -padx 5 -pady 10 -fill x -expand true


# Load TCL script fields
frame  .ctrl.tclscript.ft
pack   .ctrl.tclscript.ft        -side top -padx {10 10} -pady {10 5} -fill x
label  .ctrl.tclscript.ft.l      -text "TCL script:" -state disabled
pack   .ctrl.tclscript.ft.l      -side left -padx "0 10"
entry  .ctrl.tclscript.ft.file   -width 58 -relief sunken -textvariable tcl_file_name -state disabled
pack   .ctrl.tclscript.ft.file   -side left -padx 10
button .ctrl.tclscript.ft.browse -text "Browse" -width 9 -state disabled -command {set tcl_file_name [tk_getOpenFile -filetypes {{{TCL Files} {.tcl}} {{All Files} *}}]}
pack   .ctrl.tclscript.ft.browse -side right -padx 5 
frame  .ctrl.tclscript.fb
pack   .ctrl.tclscript.fb        -side top -fill x
button .ctrl.tclscript.fb.read   -text "Source TCL script !" -state disabled -command {if {[file exists $tcl_file_name]} {source $tcl_file_name}}
pack   .ctrl.tclscript.fb.read   -side left -padx 15 -pady {0 10} -fill x


####################################
#  CREATE THE CODE SECTION         #
####################################

label       .code.rb.txt  -text "Code View:" -anchor w     -state disabled
pack        .code.rb.txt  -side left
radiobutton .code.rb.none -value "1" -text "IHEX"          -state disabled -variable codeSelect  -command {updateCodeView}
pack        .code.rb.none -side left
radiobutton .code.rb.asm  -value "2" -text "Assembler"     -state disabled -variable codeSelect  -command {updateCodeView}
pack        .code.rb.asm  -side left
radiobutton .code.rb.mix  -value "3" -text "C & Assembler" -state disabled -variable codeSelect  -command {updateCodeView}
pack        .code.rb.mix  -side left


scrollbar .code.xscroll -orient horizontal -command {.code.text xview}
pack      .code.xscroll -side bottom -fill both

scrollbar .code.yscroll -orient vertical   -command {.code.text yview}
pack      .code.yscroll -side right  -fill both

text      .code.text    -width 80 -borderwidth 2  -state disabled  -wrap none -setgrid true -font TkFixedFont \
                        -xscrollcommand {.code.xscroll set} -yscrollcommand {.code.yscroll set}
pack      .code.text    -side left   -fill both -expand true

.code.text tag config highlightPC       -background $color(PC)
.code.text tag config highlightBRK0_ACT -background $color(Brk0_active)
.code.text tag config highlightBRK0_DIS -background $color(Brk0_disabled)
.code.text tag config highlightBRK1_ACT -background $color(Brk1_active)
.code.text tag config highlightBRK1_DIS -background $color(Brk1_disabled)
.code.text tag config highlightBRK2_ACT -background $color(Brk2_active)
.code.text tag config highlightBRK2_DIS -background $color(Brk2_disabled)


#######################################
#  PERIODICALLY CHECK THE CPU STATUS  #
#######################################
selectCPU 0

while 1 {

    # Wait 1 second
    set ::refresh_flag 0
    after 1000 set ::refresh_flag 1
    vwait refresh_flag

    # Check CPU status
    if {$connection_status} {
        if {$cpu_status} {
            if {[IsHalted $CpuNr]} {
                .ctrl.cpu.cpu.step  configure -state normal
                .ctrl.cpu.cpu.run   configure -text "Run"
                .ctrl.cpu.cpu.l3    configure -text "Stopped" -fg "\#cdad00"
                set cpu_status 0
                refreshReg
                refreshMem
            }
        }
    }
}
