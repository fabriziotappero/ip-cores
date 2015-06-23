#!/usr/bin/wish

############################################
# On-chip Logic Analyzer GUI               #
#                                          #
# File:   logan.tcl                        #
# Author: Kristoffer Carlsson              #
############################################


# Sets the flag ready when any data is ready to be read from variable data
proc get_data {fd} {

    global data ready

    if [eof $fd] {
        catch {close $fd}
        return
    }
    set data [read $fd]
    set ready 1
}

# Calculates the RSP checksum
proc calc_checksum {data} {
    set sum 0
    for {set k 0} {$k < [string length $data]} {incr k} {
        binary scan [string index $data $k] c dd
        set sum [expr $dd + $sum]
    }
    set sum [expr $sum % 256]
    return [format %.2x $sum]
}

# Hex encodes a string
proc str2hex {str} {
    for {set k 0} {$k < [string length $str]} {incr k} {
        binary scan [string index $str $k] c dd
        append hex [format %.2x $dd ]
    }
    return $hex
}

# Decodes a hex encoded string
proc hex2str {hex} {
    for {set k 1} {$k < [string length $hex]} {incr k 2} {
        scan "0x[string range $hex $k [expr $k+1]]" %x byte
        append str [format %c $byte]
    }
    return $str
}

# Converts the integer <x> to a string with <bits> number of bits
proc toBin {x  bits} {
    set bitstr ""
    for {set i 0} {$i < $bits} {incr i} {
        set bitstr "[expr ($x >> $i)&1]$bitstr"
    }
    return $bitstr
}

# Converts a string of bits to string with the hexadecimal value
proc binToHex {bitstr} {
    global nibbleToHex

    set hexstr ""

    set len [string length $bitstr]

    if {[expr $len % 4 != 0]} {
	# zero pad so that the bitstr is a multiple of 4. Needed for nibbleToHex
	for {set i 0} {$i < [expr 4-($len % 4)]} {incr i} {
	    set bitstr "0$bitstr"
	}
    }

    for {set i 0} {$i < [string length $bitstr]} {incr i 4} {
        set bits [string range $bitstr $i [expr $i+3]]
        set hex $nibbleToHex($bits)
        append hexstr $hex
    }
    return $hexstr
}

# Parses the data from the RSP packet
proc parse_packet {data format} {

    set output ""

    if {$data == "-"} {
	return "-";
    }
    while {[regexp -nocase -all {\$([A-Za-z0-9]*)\#([A-Za-z0-9]{2})(.*)} $data -> val check data] == 1} {
        if {[calc_checksum $val] == $check}  {
	    append output $val

        } else {
	    return "-1"
        }
    }
    return $output
}

# Reads any memory address from GRMON
proc read_mem {addr len s} {
    
    global data ready

    set cmd "m$addr,$len"
    rsp_cmd $cmd $s

   while {1} {
       vwait ready
       set ready 0
       if {$data == "+"} {
	   continue
       } elseif {$data == "-"} {
	   puts "Checksum error in receiver. Resending .. "
	   rsp_cmd $rspcmd $s
       } else {
	   set val [parse_packet $data "int"]

	   if {$val == -1} {
	       puts "Checksum error"
	       puts $s "-"
	   } else {
	       puts $s "+"
	       return [format %u "0x$val"]
	       break
	   }
       }
   }
}

# Sends any GRMON command
proc remote_cmd {cmd s} {

    global data ready

    set rspcmd "qRcmd," 
    append rspcmd [str2hex $cmd] 
    rsp_cmd $rspcmd $s

    while {1} {
        vwait ready
        set ready 0 
	if {$data == "+"} {
	    continue
	} elseif {$data == "-"} {
	    puts "Checksum error in receiver. Resending .. "
	    rsp_cmd $rspcmd $s 
	} else {
	    # packet received
	    set val [parse_packet $data "int"]
	    if {$val == -1} {
		puts "Checksum error"
		puts $s "-"
	    } else {
		if {$val == "OK"} {
		    puts $s "+"
		    break
		} else {
		    puts $s "+"
		}
	    }
	}
    }
}

# Gets the logan base address
proc read_addr {s} {

    global data ready

    set addr "-1"

    set rspcmd "qRcmd," 
    append rspcmd [str2hex "la"] 
    rsp_cmd $rspcmd $s

    while {1} {
        vwait ready
        set ready 0	
	if {$data == "+"} {
	    continue
	} elseif {$data == "-"} {
	    puts "Checksum error in receiver. Resending .. "
	    rsp_cmd $rspcmd $s 
	} else {
	    # packet received
	    set val [parse_packet $data "int"]
	    if {$val == -1} {
		puts "Checksum error"
		puts $s "-"
	    } else {
		set output [hex2str $val]
		if { [regexp -nocase -all {[ |\t]*(0x[0-9A-Za-z]+)} $output -> match] == 1 } {
		    set addr $match
		}
		if {$val == "OK"} {
		    puts $s "+"
		    break
		} else {
		    puts $s "+"
		}
	    }
	}
    }
    return $addr
}

# Send a GDB RSP command
proc rsp_cmd {cmd s} {
    append rspcmd "\$" $cmd "#"  [calc_checksum $cmd]
    puts $s $rspcmd
    flush $s
}


# Reads status word
proc read_status {addr} {
    global s usereg usequal armed trigged dbits depth trigl
   
    set status [read_mem "$addr" 4 $s]

    set usereg  [expr ($status & 0x80000000) ? "yes" : "no" ]
    set usequal [expr ($status & 0x40000000) ? "yes" : "no" ]
    set armed   [expr ($status & 0x20000000) ? "yes" : "no" ]
    set trigged [expr ($status & 0x10000000) ? "yes" : "no" ]
    set dbits   [expr ($status & 0x0ff00000) >> 20]
    set depth   [expr (($status & 0x000fffc0) >> 6)+1]
    set trigl   [expr ($status & 0x0000003f)]
}

# Reads the LOGAN setup file
proc read_config {filename} { 

    global dbits 

    set fd [open $filename r]

    set bits 0

    while {[gets $fd line] >= 0} {
        if {[regexp -nocase -all {^[ |\t]*([^ |\t]+)[ |\t]+([0-9]+)}  $line -> name size] == 1} {
            lappend signals $name $size
            set bits [expr $bits+$size]
            if {$bits == $dbits} {
                break
            }
        }
    }
    return $signals
}


# Send the patterns/masks to GRMON
proc download_conf {trigl siglist mcarr eqarr} {

    global s
    upvar $mcarr mc
    upvar $eqarr eq

    for {set tl 0} {$tl < $trigl} {incr tl} {
        upvar #0  "pm.$tl" pm
        set i 1
        set totpat ""
        set totmask ""
        foreach {pat mask} $pm {
            set size [lindex $siglist $i]
            append totpat [toBin $pat $size]
            append totmask [toBin $mask $size]
            incr i 2
        }
        set cmdstr "la pm $tl 0x[binToHex $totpat] 0x[binToHex $totmask]"
        remote_cmd $cmdstr $s
        set cmdstr "la trigctrl $tl $mc($tl) [expr $eq($tl) == "yes" ? 1:0]"
	remote_cmd $cmdstr $s
    }
}

# Load configuration from file
proc load_conf { } {

    global s sigs trigl cur_tl dbits mc eq tcount dcount qualbit qualval
    
    set file [tk_getOpenFile]
    if {$file == ""} { return }
    set fd [open $file "r"]

    set tl [gets $fd]
    set db [gets $fd]

    if {$tl != $trigl || $db != $dbits} {
	tk_messageBox -message \
	    "Configuration file does not match current hardware.\nConfiguration not loaded."\
	    -type ok -icon error
        return
    }

    set bits 0
    while {[gets $fd line] >= 0} {
        if {[regexp -nocase -all {^[ |\t]*([^ |\t]+)[ |\t]+([0-9]+)}  $line -> name size] == 1} {
            lappend sigs $name $size
            set bits [expr $bits+$size]
            if {$bits == $dbits} {
                break
            }
        }
    }
    if {$bits != $dbits} {
	tk_messageBox -message "Signal sizes don't match dbits" -type ok -icon error
        return
    }

    set tcount [gets $fd]
    set dcount [gets $fd]
    set qualbit [gets $fd]
    set qualval [gets $fd]

    remote_cmd "la count $tcount" $s
    remote_cmd "la div $dcount" $s
    remote_cmd "la qual $qualbit $qualval" $s
    
    for {set i 0} {$i < $tl} {incr i} {
        upvar pm.$i pm
        set pm [split [gets $fd] " "]
    }

    array set mc [split [gets $fd] " "]
    array set eq [split [gets $fd] " "]

    download_conf $trigl $sigs mc eq

    updatePMentry pm.$cur_tl $cur_tl
    .t.tl.mc.entry delete 0 end
    .t.tl.eq.entry delete 0 end
    .t.tl.mc.entry insert 0 $mc($cur_tl)
    .t.tl.eq.entry insert 0 $eq($cur_tl)

    close $fd
}

# Save configuration to file
proc save_conf { } {
    global sigs trigl dbits mc eq tcount dcount qualbit qualval

    set file [tk_getSaveFile]
    if {$file == ""} { return }
    set fd [open $file "w+"]    
    set nr [expr [llength $sigs]/2]

    puts $fd "$trigl\n$dbits"

    foreach {sig size} $sigs {
        puts $fd "$sig\t$size"
    }

    puts $fd "$tcount\n$dcount\n$qualbit\n$qualval"

    for {set i 0} {$i < $trigl} {incr i} {
        upvar pm.$i pm
        puts $fd $pm
    }
    puts $fd [array get mc]
    puts $fd [array get eq]

    flush $fd
    close $fd
}


# Updates the pattern and mask entry
proc updatePMentry {pml sel} {

    upvar #0 $pml pm

    .t.tl.pm.cfg.pattern delete 0 end
    .t.tl.pm.cfg.mask delete 0 end
    set i [.t.tl.pm.slist.list curselection]
    if {$i == ""} {
        .t.tl.pm.slist.list selection set $sel
        set i $sel
    }
    set i [expr 2*$i]
    .t.tl.pm.cfg.pattern insert 0 [lindex $pm $i]
    .t.tl.pm.cfg.mask insert 0 [lindex $pm [expr 1 + $i]]
}

# Saves the pattern and mask entry
proc savePMentry {pml sel} {

    upvar $pml pm

    set i [.t.tl.pm.slist.list curselection]
    if {$i == ""} {
        .t.tl.pm.slist.list selection set $sel
        set i $sel
    }
    set i [expr 2*$i]
    
    set pm [lreplace $pm $i $i [.t.tl.pm.cfg.pattern get]]
    set pm [lreplace $pm [expr $i+1] [expr $i+1] [.t.tl.pm.cfg.mask get]]

}

# Called by trace when changing tl, saves and updates the entry boxes
proc changeTL {var index op} {
    upvar $var newtl
    global cur_tl selsig
    global pm.$cur_tl mc eq
    savePMentry pm.$cur_tl $selsig
    set mc($cur_tl) [.t.tl.mc.entry get]
    set eq($cur_tl) [.t.tl.eq.entry get]
    set cur_tl $newtl
    .t.tl.mc.entry delete 0 end
    .t.tl.mc.entry insert 0 $mc($cur_tl)
    .t.tl.eq.entry delete 0 end
    .t.tl.eq.entry insert 0 $eq($cur_tl)
    updatePMentry pm.$cur_tl $cur_tl
} 

proc OptionMenu {name label width var init l} {
    global $var
    frame $name
    label $name.label -text $label -width $width -anchor w
    pack $name.label -side left
    set optname [eval tk_optionMenu $name.menu $var $init]
    pack $name.menu -side right
    $optname delete 0
    set j [llength $l]
    for {set i 0} {$i < $j} {incr i} {
        set e [lindex $l $i]
        $optname insert $i radiobutton -label $e -variable $var 
    }
    return $name
}


proc SettingEntry {name label width command args} {
    frame $name
    label $name.label -text $label -width $width -anchor w
    eval {entry $name.entry -relief sunken} $args
    pack $name.label -side left
    pack $name.entry -side right -fill x -expand true
    bind $name.entry <Return> $command
    return $name.entry
}

proc StatusMessage {name label value width args} {
    frame $name
    label $name.label -text $label -width $width -anchor w
    eval {label $name.val -text $value -width 6} $args -anchor w
    pack $name.label -side left
    pack $name.val -side right 
    return $name
}



#########################################################
# Main code starts here                                 #
#########################################################

# init 

if { [catch {set s [socket localhost 2222]}] != 0 } {
    puts "\nError connecting to localhost : 2222\nPut GRMON in GDB mode.\n"
    exit
} else {
    fconfigure $s -blocking 0 -buffering none
    fileevent $s readable {get_data $s}
    set conn 1
}

set data 0
set ready 0
set cur_tl 0
set selsig 0

for {set i 0} {$i < 16} {incr i} {
    set index [toBin $i 4]
    set nibbleToHex($index) [format %.1x $i]
}    

vwait ready

set addr [read_addr $s]

if {$addr == "-1"} {
    puts "\n No logic analyzer found! Exiting ...\n"
    exit
}

set tcount_addr [format %x [expr $addr + 0x0C]] 
set dcount_addr [format %x [expr $addr + 0x10]] 
set qual_addr   [format %x [expr $addr + 0x14]] 
set addr [format %x $addr]

read_status $addr

set tcount [read_mem $tcount_addr 4 $s]
set dcount [read_mem $dcount_addr 4 $s]
set qual   [read_mem $qual_addr 4 $s]

set qualbit [expr $qual & 0xFF]
set qualval [expr ($qual & 256)>>8]

set sigs [read_config "setup.logan"]

# set up the pattern/mask, mc and eq lists
for {set i 0} {$i < $trigl} {incr i} {
    set mc($i) 0
    set eq($i) "yes"
    lappend tl $i
    for {set j 0} {$j < [llength $sigs]} {incr j} {
        lappend pm.$i 0
    }
}

# Create widgets and configure bindings

# top level frame and menubar
wm title . "Logic Analyzer GUI - connected"
frame .menubar 
pack .menubar -fill x

menubutton .menubar.file -text File -menu .menubar.file.m
pack .menubar.file -side left

set m [menu .menubar.file.m]
$m add command -label "Load conf" -command {load_conf}
$m add command -label "Save conf" -command {save_conf}
$m add command -label "Detach" -command {
    if {$conn == 1} {
        rsp_cmd "D" $s
        vwait ready
        puts $s "+"
        close $s
        set conn 0
        wm title . "Logic Analyzer GUI - disconnected"
    }
}
$m add command -label "Reconnect" -command {
    if {$conn == 0} {
        set s [socket localhost 2222]
        fconfigure $s -blocking 0 -buffering none
        fileevent $s readable {get_data $s}
        set conn 1
        wm title . "Logic Analyzer GUI - connected"
    }
}
$m add command -label "Exit" -command {
    if {$conn == 1} {
	rsp_cmd "D" $s
	vwait ready
	puts $s "+"
    }
    exit
}


frame .t -width 800 -height 450


# .t.tl frame contains all trigger level specific config
frame .t.tl -relief ridge -bd 1 -width 500 -height 450
pack .t.tl  -side left -padx 15 -pady 15 -ipadx 5 -ipady 5

OptionMenu .t.tl.trigl "Config for trigl level: " 25 new_tl 0 $tl
trace variable new_tl w changeTL 

pack .t.tl.trigl -pady 10

# .t.tl.pm contains the signal listbox and p/m entry
frame .t.tl.pm
pack .t.tl.pm 

set sl [frame .t.tl.pm.slist]
listbox $sl.list -yscrollcommand {$sl.scroll set} -setgrid true -background white
$sl.list selection set 0
scrollbar $sl.scroll -orient vertical -command {$sl.list yview}
pack $sl.scroll -side right -fill y
pack $sl.list -side left
pack $sl -padx 10 -pady 10 -side left

foreach {signal size} $sigs {
    $sl.list insert end  "$signal ($size bits)"
    
}

bind $sl.list <ButtonRelease-1> {updatePMentry pm.$cur_tl $selsig}
bind $sl.list <ButtonPress-1> {savePMentry pm.$cur_tl $selsig}
bind $sl.list <Key-Tab> {   
    set newsig [$sl.list curselection]
    if {$newsig != ""} {
	set selsig $newsig
    }
}
bind $sl.list <Leave> {
    set newsig [$sl.list curselection]
    if {$newsig != ""} {
	set selsig $newsig
    }
}

# cfg frame contains the p/m entry boxes
set cfg [frame .t.tl.pm.cfg]
label $cfg.plab -text "Pattern:" -width 8 -anchor w
entry $cfg.pattern 
$cfg.pattern insert 0 0
label $cfg.mlab -text "Mask:" -width 8 -anchor w
entry $cfg.mask 
$cfg.mask insert 0 0

pack $cfg -side right -pady 10 -anchor nw
pack $cfg.plab $cfg.pattern $cfg.mlab $cfg.mask -padx 10 -anchor w

SettingEntry .t.tl.mc "Match counter: " 15 {} 
SettingEntry .t.tl.eq "Trig on equal: " 15 {} 
.t.tl.mc.entry insert 0 0
.t.tl.eq.entry insert 0 "yes"
bind .t.tl.eq.entry <ButtonPress-1> {
    if {[.t.tl.eq.entry get] == "yes"} {
        set new "no"
    } else {
        set new "yes"
    }
    .t.tl.eq.entry del 0 end
    .t.tl.eq.entry insert 0 $new
}

pack .t.tl.mc .t.tl.eq -side top -padx 10 -pady 10

button .t.tl.down -text "Download conf" -command {
    savePMentry pm.$cur_tl $selsig 
    set mc($cur_tl) [.t.tl.mc.entry get]
    set eq($cur_tl) [.t.tl.eq.entry get]
    download_conf $trigl $sigs mc eq
}
pack .t.tl.down -padx 10 -pady 20

# status & settings
frame .t.s -width 200 -height 450

button .t.s.stat -text "Update status" -command {read_status $addr}
set d [frame .t.s.statd -relief ridge -bd 1]

StatusMessage $d.width "Width: "  $dbits 15 -textvar dbits
StatusMessage $d.depth "Depth: "  $depth 15 -textvar depth
StatusMessage $d.trigl "Trigl: "  $trigl 15 -textvar trigl
StatusMessage $d.usereg "Usereg: "  $usereg 15 -textvar usereg
StatusMessage $d.usequal "Qualifier: "  $usereg 15 -textvar usequal
StatusMessage $d.armed "Armed: "  $armed 15 -textvar armed
StatusMessage $d.trigged "Trigged: "  $trigged 15 -textvar trigged

pack .t.s.stat 
pack $d.width $d.depth $d.trigl $d.usereg $d.usequal $d.armed $d.trigged -anchor w
pack .t.s.statd -padx 10 -pady 10 -expand 1 -fill x

set d [frame .t.s.setd -relief ridge -bd 1]

SettingEntry $d.tcount "Trig count: " 15 {remote_cmd "la count [$d.tcount.entry get]" $s} -textvar tcount
SettingEntry $d.dcount "Sample divisor: " 15 {remote_cmd "la div [$d.dcount.entry get]" $s} -textvar dcount
SettingEntry $d.qb "Qualifier bit: " 15 {remote_cmd "la qual [$d.qb.entry get] [$d.qv.entry get]" $s} -textvar qualbit
SettingEntry $d.qv "Qualifier val: " 15 {remote_cmd "la qual [$d.qb.entry get] [$d.qv.entry get]" $s} -textvar qualval

pack $d.tcount $d.dcount $d.qb $d.qv
pack .t.s.setd -padx 10 -pady 10 -expand 1 -fill x

set b [frame .t.s.b]
pack $b -padx 10 -pady 10

button $b.arm -text Arm -width 15  -command {remote_cmd "la arm" $s} 
button $b.reset -text Reset -width 15 -command {remote_cmd "la reset" $s} 
button $b.dump -text Dump -width 15 -command {remote_cmd "la dump" $s} 
button $b.wave -text GTKWave -width 15 -command {exec "gtkwave" "log.vcd"}

grid $b.arm $b.reset 
grid $b.dump $b.wave 

SettingEntry .t.s.cmd "GRMON command: " 17 {remote_cmd [.t.s.cmd.entry get] $s} -bg white 
pack .t.s.cmd 

pack .t.s -side right -padx 15 -pady 15 -expand 1 -fill x

pack .t -expand 1 -fill both