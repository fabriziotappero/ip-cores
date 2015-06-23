#!/bin/sh
#
# Coder Program for SXP Processor
#
# Bob Hoffman
#
#
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {
    # Provoke name search
    catch {package require bogus-package-name}
    set packageNames [package names]

    switch $tcl_platform(platform) {
	windows {
	}
	default {
	    option add *Scrollbar.width 10
	}
    }
    
    # Check if Tix is available
    if {[lsearch -exact $packageNames Tix] != -1} {
	package require Tix
    }
    
}
#############################################################################
# Visual Tcl v1.51 Project
#

#################################
# VTCL LIBRARY PROCEDURES
#

if {![info exists vTcl(sourcing)]} {
proc Window {args} {
    global vTcl
    set cmd     [lindex $args 0]
    set name    [lindex $args 1]
    set newname [lindex $args 2]
    set rest    [lrange $args 3 end]
    if {$name == "" || $cmd == ""} { return }
    if {$newname == ""} { set newname $name }
    if {$name == "."} { wm withdraw $name; return }
    set exists [winfo exists $newname]
    switch $cmd {
        show {
            if {$exists} {
                wm deiconify $newname
            } elseif {[info procs vTclWindow$name] != ""} {
                eval "vTclWindow$name $newname $rest"
            }
            if {[wm state $newname] == "normal"} {
                vTcl:FireEvent $newname <<Show>>
            }
        }
        hide    {
            if {$exists} {
                wm withdraw $newname
                vTcl:FireEvent $newname <<Hide>>
                return}
        }
        iconify { if $exists {wm iconify $newname; return} }
        destroy { if $exists {destroy $newname; return} }
    }
}
}

if {![info exists vTcl(sourcing)]} {
proc {vTcl:DefineAlias} {target alias widgetProc top_or_alias cmdalias} {
    global widget

    set widget($alias) $target
    set widget(rev,$target) $alias

    if {$cmdalias} {
        interp alias {} $alias {} $widgetProc $target
    }

    if {$top_or_alias != ""} {
        set widget($top_or_alias,$alias) $target

        if {$cmdalias} {
            interp alias {} $top_or_alias.$alias {} $widgetProc $target
        }
    }
}

proc {vTcl:DoCmdOption} {target cmd} {
    ## menus are considered toplevel windows
    set parent $target
    while {[winfo class $parent] == "Menu"} {
        set parent [winfo parent $parent]
    }

    regsub -all {\%widget} $cmd $target cmd
    regsub -all {\%top} $cmd [winfo toplevel $parent] cmd

    uplevel #0 [list eval $cmd]
}

proc {vTcl:FireEvent} {target event} {
    foreach bindtag [bindtags $target] {
        set tag_events [bind $bindtag]
        set stop_processing 0
        foreach tag_event $tag_events {
            if {$tag_event == $event} {
                set bind_code [bind $bindtag $tag_event]
                regsub -all %W $bind_code $target bind_code
                set result [catch {uplevel #0 $bind_code} errortext]
                if {$result == 3} {
                    # break exception, stop processing
                    set stop_processing 1
                } elseif {$result != 0} {
                    bgerror $errortext
                }
                break
            }
        }
        if {$stop_processing} {break}
    }
}

proc {vTcl:Toplevel:WidgetProc} {w args} {
    if {[llength $args] == 0} {
        return -code error "wrong # args: should be \"$w option ?arg arg ...?\""
    }

    ## The first argument is a switch, they must be doing a configure.
    if {[string index $args 0] == "-"} {
        set command configure

        ## There's only one argument, must be a cget.
        if {[llength $args] == 1} {
            set command cget
        }
    } else {
        set command [lindex $args 0]
        set args [lrange $args 1 end]
    }

    switch -- $command {
        "hide" -
        "Hide" {
            Window hide $w
        }

        "show" -
        "Show" {
            Window show $w
        }

        "ShowModal" {
            Window show $w
            raise $w
            grab $w
            tkwait window $w
            grab release $w
        }

        default {
            eval $w $command $args
        }
    }
}

proc {vTcl:WidgetProc} {w args} {
    if {[llength $args] == 0} {
        return -code error "wrong # args: should be \"$w option ?arg arg ...?\""
    }

    ## The first argument is a switch, they must be doing a configure.
    if {[string index $args 0] == "-"} {
        set command configure

        ## There's only one argument, must be a cget.
        if {[llength $args] == 1} {
            set command cget
        }
    } else {
        set command [lindex $args 0]
        set args [lrange $args 1 end]
    }

    eval $w $command $args
}

proc {vTcl:toplevel} {args} {
    uplevel #0 eval toplevel $args
    set target [lindex $args 0]
    namespace eval ::$target {}
}
}

if {[info exists vTcl(sourcing)]} {
proc vTcl:project:info {} {
    namespace eval ::widgets::.top32 {
        array set save {}
    }
    namespace eval ::widgets::.top32.fra34 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::.top32.men35 {
        array set save {-foreground 1 -menu 1 -padx 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::.top32.men35.m {
        array set save {-tearoff 1}
    }
    namespace eval ::widgets::.top32.men36 {
        array set save {-menu 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::.top32.men36.m {
        array set save {-tearoff 1}
    }
    namespace eval ::widgets::.top32.fra38 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::.top32.fra38.lab44 {
        array set save {-font 1 -height 1 -text 1 -width 1}
    }
    namespace eval ::widgets::.top32.fra38.lab45 {
        array set save {-font 1 -height 1 -text 1 -width 1}
    }
    namespace eval ::widgets::.top32.tix40 {
        array set save {-command 1 -height 1 -value 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes43 {
        array set save {-padx 1 -pady 1 -relief 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes47 {
        array set save {-padx 1 -pady 1 -relief 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.tix48 {
        array set save {-command 1 -height 1 -value 1 -width 1}
    }
    namespace eval ::widgets::.top32.tix32 {
        array set save {-height 1 -options 1 -value 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes36 {
        array set save {-padx 1 -pady 1 -relief 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.lab37 {
        array set save {-height 1 -text 1 -width 1}
    }
    namespace eval ::widgets::.top32.tix38 {
        array set save {-height 1 -label 1 -options 1 -value 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes39 {
        array set save {-padx 1 -pady 1 -relief 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes40 {
        array set save {-padx 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes50 {
        array set save {-padx 1 -pady 1 -relief 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes32 {
        array set save {-padx 1 -pady 1 -relief 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes33 {
        array set save {-padx 1 -pady 1 -relief 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes34 {
        array set save {-padx 1 -pady 1 -relief 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes35 {
        array set save {-padx 1 -pady 1 -relief 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes37 {
        array set save {-padx 1 -pady 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes38 {
        array set save {-padx 1 -pady 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes41 {
        array set save {-padx 1 -pady 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes42 {
        array set save {-padx 1 -pady 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes44 {
        array set save {-padx 1 -pady 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.tix45 {
        array set save {-height 1 -label 1 -options 1 -value 1 -width 1}
    }
    namespace eval ::widgets::.top32.tix46 {
        array set save {-height 1 -options 1 -value 1 -width 1}
    }
    namespace eval ::widgets::.top32.tix47 {
        array set save {-height 1 -options 1 -value 1 -width 1}
    }
    namespace eval ::widgets::.top32.tix49 {
        array set save {-height 1 -options 1 -value 1 -width 1}
    }
    namespace eval ::widgets::.top32.tix50 {
        array set save {-height 1 -options 1 -value 1 -width 1}
    }
    namespace eval ::widgets::.top32.fra37 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::.top32.fra37.tix35 {
        array set save {-borderwidth 1 -command 1 -height 1 -scrollbar 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes45 {
        array set save {-padx 1 -pady 1 -relief 1 -text 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.lab46 {
        array set save {-height 1 -text 1 -width 1}
    }
    namespace eval ::widgets::.top32.mes54 {
        array set save {-padx 1 -pady 1 -relief 1 -text 1 -width 1}
    }
    namespace eval ::widgets::.top32.fra55 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::.top32.fra55.but57 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::.top32.fra55.but58 {
        array set save {-text 1}
    }
    namespace eval ::widgets::.top32.fra55.but59 {
        array set save {-command 1 -height 1 -text 1 -width 1}
    }
    namespace eval ::widgets::.top32.fra55.but60 {
        array set save {-command 1 -text 1}
    }
    namespace eval ::widgets::.top32.fra55.but61 {
        array set save {-command 1 -height 1 -text 1 -width 1}
    }
    namespace eval ::widgets::.top32.fra55.but62 {
        array set save {-command 1 -height 1 -text 1 -width 1}
    }
    namespace eval ::widgets::.top32.fra55.but63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::.top32.fra55.che33 {
        array set save {-height 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::.top32.lab64 {
        array set save {-height 1 -text 1 -width 1}
    }
    namespace eval ::widgets::.top32.ent47 {
        array set save {-background 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top32.lab48 {
        array set save {-text 1}
    }
    namespace eval ::widgets::.top32.che32 {
        array set save {-height 1 -text 1 -variable 1 -width 1}
    }
    namespace eval ::widgets::.top33 {
        array set save {}
    }
    namespace eval ::widgets::.top33.fra35 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::.top33.fra35.mes36 {
        array set save {-padx 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::.top33.fra38 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::.top33.fra38.but39 {
        array set save {-command 1 -text 1}
    }
    namespace eval ::widgets::.top33.fra38.but40 {
        array set save {-command 1 -text 1}
    }
    namespace eval ::widgets::.top33.fra38.but41 {
        array set save {-command 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {}
    }
}
}
#################################
# USER DEFINED PROCEDURES
#
###########################################################
## Procedure:  codeClick

proc {codeClick} {f} {
global widget
global autoEdit
if {$autoEdit == 1} {
  codeEditSel $f
}
}
###########################################################
## Procedure:  codeDeleteSel

proc {codeDeleteSel} {f} {
set delList [$f curselection]
  set listLen [llength $delList]
  if { $listLen > 0} {
    $f delete $delList
  }
  set allLines [$f get 0 end]
  set numLines [llength $allLines]
  if {$numLines > 0} {
    if {$delList < $numLines} {
      $f selection set $delList
    } else {
      $f selection set [expr $delList - 1]
    }
  }
  codeEditSel $f
}
###########################################################
## Procedure:  codeEditSel

proc {codeEditSel} {f} {
global commentOnly
set selList [$f curselection]
  set listLen [llength $selList]
  if { $listLen > 0} {
    set line [$f get $selList]
    set linelist [split $line "_"]
    set word [join $linelist ""]
    set commentpos [string first "/" $word]
    if {$commentpos < 9} {
      if {$commentpos != -1} {
        set commentOnly 1
      } else {
        set commentOnly 0
      } 
    } else {
      set commentOnly 0
    } 
  }
  disectInst $word
}
###########################################################
## Procedure:  codeInsertAfter

proc {codeInsertAfter} {f word} {
global inst_op_hex
global comment
global modified
global commentOnly
  if {$commentOnly} {
    set op_text ""
  }  else {
    set op_text $inst_op_hex 
  }
  if {$comment != ""} {
  set fullinst [concat $op_text "//" $comment]
  } else {
    set fullinst $op_text
  } 
  set selList [$f curselection]
  set selList [expr $selList + 1]
  set listLen [llength $selList]
  set allLines [$f get 0 end]
  set numLines [llength $allLines]
  if { $listLen > 0} {
    $f insert $selList $fullinst
  } else {
    if {$numLines == 0} {
      $f insert end $fullinst
    }
  }
  set modified 1
  $f selection clear 0 end
  if {$numLines != 0} {
    $f selection set $selList
  } else {
    $f selection set 0 end
  }
}
###########################################################
## Procedure:  codeInsertBefore

proc {codeInsertBefore} {f word} {
global inst_op_hex
global comment
global modified
global commentOnly
  if {$commentOnly} {
    set op_text ""
  }  else {
    set op_text $inst_op_hex 
  }
  if {$comment != ""} {
  set fullinst [concat $op_text "//" $comment]
  } else {
    set fullinst $op_text
  } 
  set selList [$f curselection]
  set listLen [llength $selList]
  set allLines [$f get 0 end]
  set numLines [llength $allLines]
  if { $listLen > 0} {
    $f insert $selList $fullinst
  } else {
    if {$numLines == 0} {
      codeInsertAfter $f $word
    }
  }
  $f selection clear 0 end
  if {$listLen > 0} {
    $f selection set $selList
  } else {
    $f selection set end
  }
  set modified 1
}
###########################################################
## Procedure:  codescroll

proc {codescroll} {args} {
puts args=$args
}
###########################################################
## Procedure:  concatData

proc {concatData} {} {
global data0_op data1_op data2_op data3_op data4_op data_op_bin
  set data [concat $data0_op $data1_op $data2_op $data3_op $data4_op]
  set datalist [split $data " "]
  set data_op_bin [join $datalist ""]
}
###########################################################
## Procedure:  disectInst

proc {disectInst} {word} {
global inst_op dest_op source_op alu_op wb_op data_op_bin
global data0_op data1_op data2_op data3_op data4_op
global inst_op_hex
global comment
global commentOnly
  if {$commentOnly} {
    set comment [string range $word 3 end]
    set word 00000000
    set inst_op_hex 00000000
    set dest_op 00
    set source_op 000
    set alu_op 000
    set wb_op 0000
    set data0_op 0000
    set data1_op 0000
    set data2_op 0000
    set data3_op 0000
    set data4_op 0000
  } else {
    set start_comment [string first "//" $word]
    if {$start_comment == -1} {
      set comment ""
    } else {
      if {$start_comment>8} {
        set start_comment [expr $start_comment + 3]
        set comment [string range $word $start_comment end]
      } else {
        set comment [string range $word $start_comment end]
      }
    }
  set byte0 [toBin [string range $word 7 7]]
  set byte1 [toBin [string range $word 6 6]]
  set byte2 [toBin [string range $word 5 5]]
  set byte3 [toBin [string range $word 4 4]]
  set byte4 [toBin [string range $word 3 3]]
  set byte5 [toBin [string range $word 2 2]]
  set byte6 [toBin [string range $word 1 1]]
  set byte7 [toBin [string range $word 0 0]]
  set allbytes [concat $byte7 $byte6 $byte5 $byte4 $byte3 $byte2 $byte1 $byte0]
  set bytelist [split $allbytes " "]
  set inst_op [join $bytelist ""]
  set dest_op [string range $inst_op 0 1]
  set source_op [string range $inst_op 2 4]
  set alu_op [string range $inst_op 5 7]
  set wb_op [string range $inst_op 8 11]
  set data_op [string range $inst_op 12 31]
  set data0_op [string range $data_op 0 3]
  set data1_op [string range $data_op 4 7]
  set data2_op [string range $data_op 8 11]
  set data3_op [string range $data_op 12 15]
  set data4_op [string range $data_op 16 19]
  updateDestMenu $dest_op
  updateSourceMenu $source_op
  updateALUMenu $alu_op
  updateWBMenu $wb_op
  updateDataMenu TixOptionMenu6 $data0_op
  updateDataMenu TixOptionMenu7 $data1_op
  updateDataMenu TixOptionMenu8 $data2_op
  updateDataMenu TixOptionMenu9 $data3_op
  updateDataMenu TixOptionMenu10 $data4_op
  }
}
###########################################################
## Procedure:  newFile

proc {newFile} {f} {
global filepath
  global modified
  set datalist [$f get 0 end]
  set len [llength $datalist]
  $f delete 0 $len
}
###########################################################
## Procedure:  openFile

proc {openFile} {f} {
global filepath
  global modified
  set filepath [tk_getOpenFile]
  if {$filepath == ""} {
    return
  }
  set fileId [open $filepath r]
  $f delete 0 end
  foreach line [split [read $fileId] \n] {
    if {$line != ""} {
      $f insert end $line
    }
  }
  close $fileId
  set modified 0
}
###########################################################
## Procedure:  quit

proc {quit} {} {
global filepath
global quitNow
  global modified
  if {!$modified} {
    exit
  } else {
    uplevel #0 {Window show .top33}
  }
}
###########################################################
## Procedure:  saveAsFile

proc {saveAsFile} {f} {
global filepath
  global modified
  set filepath [tk_getSaveFile]
  if {$filepath == ""} {
    return
  }
  set datalist [$f get 0 end]
  set fileId [open $filepath w 0644]
  for {set i 0} {$i < [llength $datalist]} {incr i 1} {
    puts $fileId [lindex $datalist $i]
  }
  close $fileId
  set modified 0
}
###########################################################
## Procedure:  saveFile

proc {saveFile} {f} {
global filepath
  global modified
  if {[info exists filepath]} {
    if {![llength $filepath]} {
      set filepath [tk_getSaveFile]
      if {$filepath == ""} {
        return
      }
    }
  } else {
    set filepath [tk_getSaveFile]
    if {$filepath == ""} {
      return
    }
  }
  set datalist [$f get 0 end]
  set fileId [open $filepath w 0644]
  for {set i 0} {$i < [llength $datalist]} {incr i 1} {
    puts $fileId [lindex $datalist $i]
  }
  close $fileId
  set modified 0
}
###########################################################
## Procedure:  toBin

proc {toBin} {hexvalue} {
switch $hexvalue {
    0 {set binvalue 0000}
    1 {set binvalue 0001}
    2 {set binvalue 0010}
    3 {set binvalue 0011}
    4 {set binvalue 0100}
    5 {set binvalue 0101}
    6 {set binvalue 0110}
    7 {set binvalue 0111}
    8 {set binvalue 1000}
    9 {set binvalue 1001}
    a {set binvalue 1010}
    b {set binvalue 1011}
    c {set binvalue 1100}
    d {set binvalue 1101}
    e {set binvalue 1110}
    f {set binvalue 1111}
    default {set binvalue xxxx}
  }
  return $binvalue
}
###########################################################
## Procedure:  toHex

proc {toHex} {binvalue} {
switch $binvalue {
    0000 {set hexvalue 0}
    0001 {set hexvalue 1}
    0010 {set hexvalue 2}
    0011 {set hexvalue 3}
    0100 {set hexvalue 4}
    0101 {set hexvalue 5}
    0110 {set hexvalue 6}
    0111 {set hexvalue 7}
    1000 {set hexvalue 8}
    1001 {set hexvalue 9}
    1010 {set hexvalue a}
    1011 {set hexvalue b}
    1100 {set hexvalue c}
    1101 {set hexvalue d}
    1110 {set hexvalue e}
    1111 {set hexvalue f}
    default {set hexvalue x}
  }
  return $hexvalue
}
###########################################################
## Procedure:  updateALU

proc {updateALU} {args} {
global alu_op
  switch $args {
    PASS     {set alu_op 000}
    ADD      {set alu_op 001}
    SUB      {set alu_op 010}
    MULT     {set alu_op 011}
    AND_OR   {set alu_op 100}
    XOR_XNOR {set alu_op 101}
    PASS_SW  {set alu_op 111}
  }
  updateInst
}
###########################################################
## Procedure:  updateALUMenu

proc {updateALUMenu} {op_value} {
global alu_cmd_list alu_op_list alu_text alu_op
  set list_index [lsearch -exact $alu_op_list $op_value]
  set alu_value [lindex $alu_cmd_list $list_index]
  set alu_text $alu_value
  set alu_op $op_value
  TixOptionMenu4 -value $alu_value
  updateInst
}
###########################################################
## Procedure:  updateData

proc {updateData} {data_op args} {
switch $args {
    h0  {uplevel 1 set $data_op 0000}
    h1  {uplevel 1 set $data_op 0001} 
    h2  {uplevel 1 set $data_op 0010} 
    h3  {uplevel 1 set $data_op 0011} 
    h4  {uplevel 1 set $data_op 0100} 
    h5  {uplevel 1 set $data_op 0101} 
    h6  {uplevel 1 set $data_op 0110} 
    h7  {uplevel 1 set $data_op 0111} 
    h8  {uplevel 1 set $data_op 1000} 
    h9  {uplevel 1 set $data_op 1001} 
    ha  {uplevel 1 set $data_op 1010} 
    hb  {uplevel 1 set $data_op 1011} 
    hc  {uplevel 1 set $data_op 1100} 
    hd  {uplevel 1 set $data_op 1101} 
    he  {uplevel 1 set $data_op 1110} 
    hf  {uplevel 1 set $data_op 1111} 
  }
  updateInst
}
###########################################################
## Procedure:  updateDataMenu

proc {updateDataMenu} {data_menu op_value} {
switch $op_value {
    0000 {$data_menu -value h0}
    0001 {$data_menu -value h1}
    0010 {$data_menu -value h2}
    0011 {$data_menu -value h3}
    0100 {$data_menu -value h4}
    0101 {$data_menu -value h5}
    0110 {$data_menu -value h6}
    0111 {$data_menu -value h7}
    1000 {$data_menu -value h8}
    1001 {$data_menu -value h9}
    1010 {$data_menu -value ha}
    1011 {$data_menu -value hb}
    1100 {$data_menu -value hc}
    1101 {$data_menu -value hd}
    1110 {$data_menu -value he}
    1111 {$data_menu -value hf}
  }
  updateInst
}
###########################################################
## Procedure:  updateDest

proc {updateDest} {dest} {
global dest_text_list dest_op_list
  global dest_op
  set list_index [lsearch -exact $dest_text_list $dest]
  set dest_op [lindex $dest_op_list $list_index]
  updateHeaders
  updateInst
}
###########################################################
## Procedure:  updateDestMenu

proc {updateDestMenu} {op_value} {
global dest_text_list dest_op_list dest_text dest_op
  set list_index [lsearch -exact $dest_op_list $op_value]
  set dest_value [lindex $dest_text_list $list_index]
  set dest_text $dest_value
  set dest_op $op_value
  TixOptionMenu1 -value $dest_text
  updateInst
}
###########################################################
## Procedure:  updateHeaders

proc {updateHeaders} {} {
global dest_op source_op
  global data0_text data1_text data2_text data3_text data4_text
  set ops [concat $dest_op $source_op]
  set oplist [split $ops " "]
  set op [join $oplist ""]
  switch $op {
    00000 {set data0_text Rd ; set data1_text Rs1 ; set data2_text Rs2 ; set data3_text ---- ; set data4_text ---- }
    00001 {set data0_text Rd/Rs1 ; set data1_text Imm ; set data2_text Imm ; set data3_text Imm ; set data4_text Imm }
    00010 {set data0_text Rd ; set data1_text ---- ; set data2_text Rs2 ; set data3_text ---- ; set data4_text ---- }
    00011 {set data0_text Rd ; set data1_text Imm ; set data2_text Imm ; set data3_text Imm ; set data4_text Imm }
    00100 {set data0_text Rd ; set data1_text Rs1 ; set data2_text ---- ; set data3_text ---- ; set data4_text ---- }
    00101 {set data0_text Rd ; set data1_text ---- ; set data2_text Rs2 ; set data3_text ---- ; set data4_text ---- }
    00110 {set data0_text Rd ; set data1_text Imm ; set data2_text Imm ; set data3_text Imm ; set data4_text Imm }
    00111 {set data0_text Rd ; set data1_text ---- ; set data2_text ---- ; set data3_text ---- ; set data4_text ---- }
    01000 {set data0_text ---- ; set data1_text Rs1 ; set data2_text Rs2 ; set data3_text ---- ; set data4_text -LZC }
    01001 {set data0_text Rs1 ; set data1_text Imm ; set data2_text Imm ; set data3_text Imm ; set data4_text Imm }
    01010 {set data0_text ---- ; set data1_text ---- ; set data2_text Rs2 ; set data3_text ---- ; set data4_text -LZC }
    01011 {set data0_text ---- ; set data1_text Imm ; set data2_text Imm ; set data3_text Imm ; set data4_text Imm }
    01100 {set data0_text ---- ; set data1_text Rs1 ; set data2_text ---- ; set data3_text ---- ; set data4_text ---- }
    01101 {set data0_text ---- ; set data1_text ---- ; set data2_text Rs2 ; set data3_text ---- ; set data4_text -LZC }
    01110 {set data0_text ---- ; set data1_text Imm ; set data2_text Imm ; set data3_text Imm ; set data4_text Imm }
    01111 {set data0_text ---- ; set data1_text ---- ; set data2_text ---- ; set data3_text ---- ; set data4_text ---- }
    10000 {set data0_text ---- ; set data1_text Rs1 ; set data2_text Rs2 ; set data3_text ---- ; set data4_text ---- }
    10001 {set data0_text ---- ; set data1_text Imm ; set data2_text Imm ; set data3_text Imm ; set data4_text Imm }
    10010 {set data0_text ---- ; set data1_text ---- ; set data2_text Rs2 ; set data3_text ---- ; set data4_text ---- }
    10011 {set data0_text ---- ; set data1_text Imm ; set data2_text Imm ; set data3_text Imm ; set data4_text Imm }
    10100 {set data0_text ---- ; set data1_text Rs1 ; set data2_text ---- ; set data3_text ---- ; set data4_text ---- }
    10101 {set data0_text ---- ; set data1_text ---- ; set data2_text Rs2 ; set data3_text ---- ; set data4_text ---- }
    10110 {set data0_text ---- ; set data1_text Imm ; set data2_text Imm ; set data3_text Imm ; set data4_text Imm }
    10111 {set data0_text ---- ; set data1_text ---- ; set data2_text ---- ; set data3_text ---- ; set data4_text ---- }
    11000 {set data0_text ---- ; set data1_text Rs1 ; set data2_text Rs2 ; set data3_text ---- ; set data4_text ---- }
    11001 {set data0_text ---- ; set data1_text Imm ; set data2_text Imm ; set data3_text Imm ; set data4_text Imm }
    11010 {set data0_text ---- ; set data1_text ---- ; set data2_text Rs2 ; set data3_text ---- ; set data4_text ---- }
    11011 {set data0_text ---- ; set data1_text Imm ; set data2_text Imm ; set data3_text Imm ; set data4_text Imm }
    11100 {set data0_text ---- ; set data1_text Rs1 ; set data2_text ---- ; set data3_text ---- ; set data4_text ---- }
    11101 {set data0_text ---- ; set data1_text ---- ; set data2_text Rs2 ; set data3_text ---- ; set data4_text ---- }
    11110 {set data0_text ---- ; set data1_text Imm ; set data2_text Imm ; set data3_text Imm ; set data4_text Imm }
    11111 {set data0_text ---- ; set data1_text ---- ; set data2_text ---- ; set data3_text ---- ; set data4_text ---- }
    default {set data0_text ---- ; set data1_text ---- ; set data2_text ---- ; set data3_text ---- ; set data4_text ---- }
  }
}
###########################################################
## Procedure:  updateInst

proc {updateInst} {} {
global inst_op_hex inst_op_bin dest_op source_op alu_op wb_op data_op_bin
  concatData
  set insttext [concat $dest_op $source_op $alu_op $wb_op $data_op_bin]
  set instlist [split $insttext " "]
  set inst_op_bin [join $instlist ""]
  set byte0 [string range $inst_op_bin 28 31]
  set byte1 [string range $inst_op_bin 24 27]
  set byte2 [string range $inst_op_bin 20 23]
  set byte3 [string range $inst_op_bin 16 19]
  set byte4 [string range $inst_op_bin 12 15]
  set byte5 [string range $inst_op_bin  8 11]
  set byte6 [string range $inst_op_bin  4  7]
  set byte7 [string range $inst_op_bin  0  3]
  set hex0 [toHex $byte0]
  set hex1 [toHex $byte1]
  set hex2 [toHex $byte2]
  set hex3 [toHex $byte3]
  set hex4 [toHex $byte4]
  set hex5 [toHex $byte5]
  set hex6 [toHex $byte6]
  set hex7 [toHex $byte7]
  set wordlow [concat $hex3 $hex2 $hex1 $hex0]
  set wordllist [split $wordlow " "]
  set wordl [join $wordllist ""]
  set wordhigh [concat $hex7 $hex6 $hex5 $hex4]
  set wordhlist [split $wordhigh " "]
  set wordh [join $wordhlist ""]
  set wordlist [concat $wordh $wordl]
  set inst_op_hex [join $wordlist ""]
}
###########################################################
## Procedure:  updateSource

proc {updateSource} {args} {
global source_op
  switch $args {
    Reg_Reg {set source_op 000}
    Reg_Imm {set source_op 001}
    PC_Reg  {set source_op 010}
    PC_Imm  {set source_op 011}
    Reg_Ext  {set source_op 100}
    Ext_Reg  {set source_op 101}
    Ext_Imm  {set source_op 110}
    Ext_Ext  {set source_op 111}
  }
  updateHeaders
  updateInst
}
###########################################################
## Procedure:  updateSourceMenu

proc {updateSourceMenu} {op_value} {
global source_cmd_list source_op_list source_text source_op
  set list_index [lsearch -exact $source_op_list $op_value]
  set source_value [lindex $source_cmd_list $list_index]
  set source_text $source_value
  set source_op $op_value
  TixOptionMenu3 -value $source_value
  updateInst
}
###########################################################
## Procedure:  updateWB

proc {updateWB} {args} {
global wb_op
  switch $args {
    alu_out_a       {set wb_op 0000}
    alu_out_b       {set wb_op 0001} 
    memory          {set wb_op 0010} 
    extension       {set wb_op 0011} 
    alu_a_flag_z    {set wb_op 0100} 
    alu_a_flag_n    {set wb_op 0101} 
    alu_a_flag_v    {set wb_op 0110} 
    alu_a_flag_c    {set wb_op 0111} 
    alu_b_flag_z    {set wb_op 1000} 
    alu_b_flag_n    {set wb_op 1001} 
    alu_b_flag_v    {set wb_op 1010} 
    alu_b_flag_c    {set wb_op 1011} 
    ext_alu_flag_z  {set wb_op 1100} 
    ext_alu_flag_n  {set wb_op 1101} 
    ext_alu_flag_v  {set wb_op 1110} 
    ext_alu_flag_c  {set wb_op 1111} 
  }
  updateInst
}
###########################################################
## Procedure:  updateWBMenu

proc {updateWBMenu} {op_value} {
global wb_cmd_list wb_op_list wb_text wb_op
  set list_index [lsearch -exact $wb_op_list $op_value]
  set wb_value [lindex $wb_cmd_list $list_index]
  set wb_text $wb_value
  set wb_op $op_value
  TixOptionMenu5 -value $wb_value
  updateInst
}
###########################################################
## Procedure:  init
###########################################################
## Procedure:  main

proc {main} {argc argv} {
wm protocol .top32 WM_DELETE_WINDOW {exit}
uplevel #0 {set codeListBox [TixScrolledListBox4 subwidget listbox]}
uplevel #0 {$codeListBox configure -font Courier}
}

proc init {argc argv} {
puts "*********************************************************"
puts "initializing variables..."
puts "*********************************************************"

global dest_op source_op

global dest_cmd_list dest_text_list dest_op_list
global source_cmd_list source_text_list source_op_list
global alu_cmd_list alu_text_list alu_op_list
global wb_cmd_list wb_text_list wb_op_list

uplevel #0 {set autoEdit 1}
uplevel #0 {set modified 0}
uplevel #0 {set quitNow 0}

uplevel #0 {set dest_op 00}
uplevel #0 {set source_op 0000}
uplevel #0 {set alu_op 000}
uplevel #0 {set wb_op 0000}

uplevel #0 {set data0_op 0000}
uplevel #0 {set data1_op 0000}
uplevel #0 {set data2_op 0000}
uplevel #0 {set data3_op 0000}
uplevel #0 {set data4_op 0000}

uplevel #0 {set dest_cmd_list [list "Reg" "PC" "Mem" "Ext"]}
uplevel #0 {set dest_text_list [list "Reg" "PC" "Mem" "Ext"]}
uplevel #0 {set dest_op_list [list 00 01 10 11]}
 
uplevel #0 {set source_cmd_list [list "Reg_Reg" "Reg_Imm" "PC_Reg" "PC_Imm" "Reg_Ext" "Ext_Reg" "Ext_Imm" "Ext_Ext"]}
uplevel #0 {set source_text_list [list "Reg, Reg" "Reg, Imm" "PC, Reg" "PC, Imm" "Reg, Ext" "Ext, Reg" "Ext, Imm" "Ext, Ext"]}
uplevel #0 {set source_op_list [list 000 001 010 011 100 101 110 111]}
  
uplevel #0 {set alu_cmd_list [list "PASS" "ADD" "SUB" "MULT" "AND_OR" "XOR_XNOR" "PASS_SW"]}
uplevel #0 {set alu_text_list [list "PASS" "ADD" "SUB" "MULT" "AND/OR" "XOR/XNOR" "PASS_SW"]}
uplevel #0 {set alu_op_list [list 000 001 010 011 100 101 111]}

uplevel #0 {set wb_cmd_list [list "alu_out_a" "alu_out_b" "memory" "extension" "alu_a_flag_z" "alu_a_flag_n" "alu_a_flag_v" "alu_a_flag_c" "alu_b_flag_z" "alu_b_flag_n" "alu_b_flag_v" "alu_b_flag_c" "ext_alu_flag_z" "ext_alu_flag_n" "ext_alu_flag_v" "ext_alu_flag_c"]}
 
uplevel #0 {set wb_text_list [list "ALU output A" "ALU output B" "From Memory (Load)" "From Ext Interface" "ALU A Flag Z" "ALU A Flag N" "ALU A Flag V" "ALU A Flag C" "ALU B Flag Z" "ALU B Flag N" "ALU B Flag V" "ALU B Flag C" "EXT ALU Flag Z" "EXT ALU Flag N" "EXT ALU Flag V" "EXT ALU Flag C"]}
   
uplevel #0 {set wb_op_list [list 0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101 1110 1111]}
}

init $argc $argv

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base {container 0}} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    wm focusmodel $base passive
    wm geometry $base 1x1+0+0; update
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm withdraw $base
    wm title $base "vtcl.tcl"
    bindtags $base "$base Vtcl.tcl all"
    vTcl:FireEvent $base <<Create>>
    }
    ###################
    # SETTING GEOMETRY
    ###################

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top32 {base {container 0}} {
    if {$base == ""} {
        set base .top32
    }
    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }

    global widget
    vTcl:DefineAlias "$base" "Toplevel1" vTcl:Toplevel:WidgetProc "" 1
    vTcl:DefineAlias "$base.che32" "Checkbutton1" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.ent47" "Entry1" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.fra34" "Frame1" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.fra37" "Frame3" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.fra37.tix35" "TixScrolledListBox4" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.fra38" "Frame2" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.fra38.lab44" "Label1" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.fra38.lab45" "Label2" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.fra55" "Frame4" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.fra55.but57" "Button6" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.fra55.but58" "Button5" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.fra55.but59" "Button4" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.fra55.but60" "Button3" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.fra55.but61" "Button2" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.fra55.but62" "Button1" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.fra55.but63" "Button7" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.fra55.che33" "Checkbutton2" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.lab37" "Label3" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.lab46" "Label7" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.lab48" "Label9" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.lab64" "Label8" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.men35" "Menubutton1" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.men35.m" "Menu1" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.men36" "Menubutton2" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes32" "Message9" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes33" "Message10" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes34" "Message11" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes35" "Message12" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes36" "Message3" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes37" "Message13" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes38" "Message14" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes39" "Message4" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes40" "Message5" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes41" "Message15" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes42" "Message16" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes43" "Message1" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes44" "Message17" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes45" "Message18" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes47" "Message2" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes50" "Message8" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.mes54" "Message19" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.tix32" "TixOptionMenu4" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.tix38" "TixOptionMenu5" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.tix40" "TixOptionMenu1" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.tix45" "TixOptionMenu6" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.tix46" "TixOptionMenu7" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.tix47" "TixOptionMenu8" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.tix48" "TixOptionMenu3" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.tix49" "TixOptionMenu9" vTcl:WidgetProc "Toplevel1" 1
    vTcl:DefineAlias "$base.tix50" "TixOptionMenu10" vTcl:WidgetProc "Toplevel1" 1

    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    vTcl:toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm geometry $base 791x607+76+136; update
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "New Toplevel 1"
    vTcl:FireEvent $base <<Create>>
    }
    frame $base.fra34 \
        -borderwidth 1 -height 35 -relief raised -width 790 
    menubutton $base.men35 \
        -foreground #000000 -menu "$base.men35.m" -padx 4 -pady 3 -text File \
        -width 0 
    menu $base.men35.m \
        -tearoff 0 
    $base.men35.m add command \
        -accelerator {} -command {newFile $codeListBox} -image {} -label New 
    $base.men35.m add separator
    $base.men35.m add command \
        -accelerator {} -command {openFile $codeListBox} -image {} \
        -label Open 
    $base.men35.m add command \
        -accelerator {} -command {saveFile $codeListBox} -image {} \
        -label Save 
    $base.men35.m add command \
        -accelerator {} -command {saveAsFile $codeListBox} -image {} \
        -label {Save As...} 
    $base.men35.m add separator
    $base.men35.m add command \
        -accelerator {} -command {# TODO: Your menu handler here} -image {} \
        -label Preferences... 
    $base.men35.m add separator
    $base.men35.m add command \
        -accelerator {} -command quit -image {} -label Quit 
    menubutton $base.men36 \
        -menu "$base.men36.m" -padx 4 -pady 3 -text Edit 
    menu $base.men36.m \
        -tearoff 0 
    $base.men36.m add command \
        -accelerator {} -command {# TODO: Your menu handler here} -image {} \
        -label Undo 
    $base.men36.m add command \
        -accelerator {} -command {# TODO: Your menu handler here} -image {} \
        -label Redo 
    $base.men36.m add separator
    $base.men36.m add command \
        -accelerator {} -command {# TODO: Your menu handler here} -image {} \
        -label Cut 
    $base.men36.m add command \
        -accelerator {} -command {# TODO: Your menu handler here} -image {} \
        -label Copy 
    $base.men36.m add command \
        -accelerator {} -command {# TODO: Your menu handler here} -image {} \
        -label Paste 
    $base.men36.m add separator
    $base.men36.m add command \
        -accelerator {} -command {codeInsertBefore $codeListBox $inst_op_hex} \
        -image {} -label {Insert Before} 
    $base.men36.m add command \
        -accelerator {} -command {codeInsertAfter $codeListBox $inst_op_hex} \
        -image {} -label {Insert After} 
    $base.men36.m add command \
        -accelerator {} -command {codeDeleteSel $codeListBox} -image {} \
        -label Delete 
    frame $base.fra38 \
        -borderwidth 2 -height 110 -relief sunken -width 790 
    label $base.fra38.lab44 \
        -font {Helvetica 12 bold} -height 0 -text Dest -width 38 
    label $base.fra38.lab45 \
        -font {Helvetica 12 bold} -height 0 -text Source -width 48 
    tixOptionMenu $base.tix40 \
        -command updateDest -value Reg -height 25 -options {label.anchor e} \
        -width 72 
    $base.tix40 add command Reg \
        -label Reg 
    $base.tix40 add command PC \
        -label PC 
    $base.tix40 add command Mem \
        -label Mem 
    $base.tix40 add command Ext \
        -label Ext 
    message $base.mes43 \
        -padx 5 -pady 2 -relief sunken -text 00 -textvariable dest_op \
        -width 62 
    message $base.mes47 \
        -padx 5 -pady 2 -relief sunken -text 000 -textvariable source_op \
        -width 82 
    tixOptionMenu $base.tix48 \
        -command updateSource -value Reg_Reg -label { } -height 25 \
        -options {label.anchor e} -width 97 
    $base.tix48 add command Reg_Reg \
        -label {Reg, Reg} 
    $base.tix48 add command Reg_Imm \
        -label {Reg, Imm} 
    $base.tix48 add command PC_Reg \
        -label {PC, Reg} 
    $base.tix48 add command PC_Imm \
        -label {PC, Imm} 
    $base.tix48 add command Reg_Ext \
        -label {Reg, Ext} 
    $base.tix48 add command Ext_Reg \
        -label {Ext, Reg} 
    $base.tix48 add command Ext_Imm \
        -label {Ext, Imm} 
    $base.tix48 add command Ext_Ext \
        -label {Ext, Ext} 
    tixOptionMenu $base.tix32 \
        -command updateALU -value PASS -height 25 -options {label.anchor e} \
        -width 105 
    $base.tix32 add command PASS \
        -label PASS 
    $base.tix32 add command ADD \
        -label ADD 
    $base.tix32 add command SUB \
        -label SUB 
    $base.tix32 add command MULT \
        -label MULT 
    $base.tix32 add command AND_OR \
        -label AND/OR 
    $base.tix32 add command XOR_XNOR \
        -label XOR/XNOR 
    $base.tix32 add command PASS_SW \
        -label PASS_SW 
    message $base.mes36 \
        -padx 5 -pady 2 -relief sunken -text 000 -textvariable alu_op \
        -width 95 
    label $base.lab37 \
        -height 0 -text ALU -width 0 
    tixOptionMenu $base.tix38 \
        -command updateWB -value alu_out_a -height 25 \
        -options {label.anchor e} -width 152 
    $base.tix38 add command alu_out_a \
        -label {ALU Output A} 
    $base.tix38 add command alu_out_b \
        -label {ALU Output B} 
    $base.tix38 add command memory \
        -label {From Mem (Load)} 
    $base.tix38 add command extension \
        -label {From Ext Int} 
    $base.tix38 add separator sep1
    $base.tix38 add command alu_a_flag_z \
        -label {ALU A Flag Z} 
    $base.tix38 add command alu_a_flag_n \
        -label {ALU A Flag N} 
    $base.tix38 add command alu_a_flag_v \
        -label {ALU A Flag V} 
    $base.tix38 add command alu_a_flag_c \
        -label {ALU A Flag C} 
    $base.tix38 add separator sep2
    $base.tix38 add command alu_b_flag_z \
        -label {ALU B Flag Z} 
    $base.tix38 add command alu_b_flag_n \
        -label {ALU B Flag N} 
    $base.tix38 add command alu_b_flag_v \
        -label {ALU B Flag V} 
    $base.tix38 add command alu_b_flag_c \
        -label {ALU B Flag C} 
    $base.tix38 add separator sep3
    $base.tix38 add command ext_alu_flag_z \
        -label {EXT ALU Flag Z} 
    $base.tix38 add command ext_alu_flag_n \
        -label {EXT ALU Flag N} 
    $base.tix38 add command ext_alu_flag_v \
        -label {EXT ALU Flag V} 
    $base.tix38 add command ext_alu_flag_c \
        -label {EXT ALU Flag C} 
    message $base.mes39 \
        -padx 5 -pady 2 -relief sunken -text 0000 -textvariable wb_op \
        -width 142 
    message $base.mes40 \
        -padx 5 -pady 2 -text WB -width 70 
    message $base.mes50 \
        -padx 5 -pady 2 -relief sunken -text 0000 -textvariable data0_op \
        -width 52 
    message $base.mes32 \
        -padx 5 -pady 2 -relief sunken -text 0000 -textvariable data1_op \
        -width 52 
    message $base.mes33 \
        -padx 5 -pady 2 -relief sunken -text 0000 -textvariable data2_op \
        -width 52 
    message $base.mes34 \
        -padx 5 -pady 2 -relief sunken -text 0000 -textvariable data3_op \
        -width 52 
    message $base.mes35 \
        -padx 5 -pady 2 -relief sunken -text 0000 -textvariable data4_op \
        -width 52 
    message $base.mes37 \
        -padx 5 -pady 2 -text Rd -textvariable data0_text -width 70 
    message $base.mes38 \
        -padx 5 -pady 2 -text Rs1 -textvariable data1_text -width 70 
    message $base.mes41 \
        -padx 5 -pady 2 -text Rs2 -textvariable data2_text -width 70 
    message $base.mes42 \
        -padx 5 -pady 2 -text ---- -textvariable data3_text -width 70 
    message $base.mes44 \
        -padx 5 -pady 2 -text ---- -textvariable data4_text -width 70 
    tixOptionMenu $base.tix45 \
        -command {updateData data0_op} -value h0 -height 25 \
        -options {label.anchor e} -width 62 
    $base.tix45 add command h0 \
        -label 0x0 
    $base.tix45 add command h1 \
        -label 0x1 
    $base.tix45 add command h2 \
        -label 0x2 
    $base.tix45 add command h3 \
        -label 0x3 
    $base.tix45 add command h4 \
        -label 0x4 
    $base.tix45 add command h5 \
        -label 0x5 
    $base.tix45 add command h6 \
        -label 0x6 
    $base.tix45 add command h7 \
        -label 0x7 
    $base.tix45 add command h8 \
        -label 0x8 
    $base.tix45 add command h9 \
        -label 0x9 
    $base.tix45 add command ha \
        -label 0xa 
    $base.tix45 add command hb \
        -label 0xb 
    $base.tix45 add command hc \
        -label 0xc 
    $base.tix45 add command hd \
        -label 0xd 
    $base.tix45 add command he \
        -label 0xe 
    $base.tix45 add command hf \
        -label 0xf 
    tixOptionMenu $base.tix46 \
        -command {updateData data1_op} -value h0 -height 25 \
        -options {label.anchor e} -width 62 
    $base.tix46 add command h0 \
        -label 0x0 
    $base.tix46 add command h1 \
        -label 0x1 
    $base.tix46 add command h2 \
        -label 0x2 
    $base.tix46 add command h3 \
        -label 0x3 
    $base.tix46 add command h4 \
        -label 0x4 
    $base.tix46 add command h5 \
        -label 0x5 
    $base.tix46 add command h6 \
        -label 0x6 
    $base.tix46 add command h7 \
        -label 0x7 
    $base.tix46 add command h8 \
        -label 0x8 
    $base.tix46 add command h9 \
        -label 0x9 
    $base.tix46 add command ha \
        -label 0xa 
    $base.tix46 add command hb \
        -label 0xb 
    $base.tix46 add command hc \
        -label 0xc 
    $base.tix46 add command hd \
        -label 0xd 
    $base.tix46 add command he \
        -label 0xe 
    $base.tix46 add command hf \
        -label 0xf 
    tixOptionMenu $base.tix47 \
        -command {updateData data2_op} -value h0 -height 25 \
        -options {label.anchor e} -width 62 
    $base.tix47 add command h0 \
        -label 0x0 
    $base.tix47 add command h1 \
        -label 0x1 
    $base.tix47 add command h2 \
        -label 0x2 
    $base.tix47 add command h3 \
        -label 0x3 
    $base.tix47 add command h4 \
        -label 0x4 
    $base.tix47 add command h5 \
        -label 0x5 
    $base.tix47 add command h6 \
        -label 0x6 
    $base.tix47 add command h7 \
        -label 0x7 
    $base.tix47 add command h8 \
        -label 0x8 
    $base.tix47 add command h9 \
        -label 0x9 
    $base.tix47 add command ha \
        -label 0xa 
    $base.tix47 add command hb \
        -label 0xb 
    $base.tix47 add command hc \
        -label 0xc 
    $base.tix47 add command hd \
        -label 0xd 
    $base.tix47 add command he \
        -label 0xe 
    $base.tix47 add command hf \
        -label 0xf 
    tixOptionMenu $base.tix49 \
        -command {updateData data3_op} -value h0 -height 25 \
        -options {label.anchor e} -width 62 
    $base.tix49 add command h0 \
        -label 0x0 
    $base.tix49 add command h1 \
        -label 0x1 
    $base.tix49 add command h2 \
        -label 0x2 
    $base.tix49 add command h3 \
        -label 0x3 
    $base.tix49 add command h4 \
        -label 0x4 
    $base.tix49 add command h5 \
        -label 0x5 
    $base.tix49 add command h6 \
        -label 0x6 
    $base.tix49 add command h7 \
        -label 0x7 
    $base.tix49 add command h8 \
        -label 0x8 
    $base.tix49 add command h9 \
        -label 0x9 
    $base.tix49 add command ha \
        -label 0xa 
    $base.tix49 add command hb \
        -label 0xb 
    $base.tix49 add command hc \
        -label 0xc 
    $base.tix49 add command hd \
        -label 0xd 
    $base.tix49 add command he \
        -label 0xe 
    $base.tix49 add command hf \
        -label 0xf 
    tixOptionMenu $base.tix50 \
        -command {updateData data4_op} -value h0 -height 25 \
        -options {label.anchor e} -width 62 
    $base.tix50 add command h0 \
        -label 0x0 
    $base.tix50 add command h1 \
        -label 0x1 
    $base.tix50 add command h2 \
        -label 0x2 
    $base.tix50 add command h3 \
        -label 0x3 
    $base.tix50 add command h4 \
        -label 0x4 
    $base.tix50 add command h5 \
        -label 0x5 
    $base.tix50 add command h6 \
        -label 0x6 
    $base.tix50 add command h7 \
        -label 0x7 
    $base.tix50 add command h8 \
        -label 0x8 
    $base.tix50 add command h9 \
        -label 0x9 
    $base.tix50 add command ha \
        -label 0xa 
    $base.tix50 add command hb \
        -label 0xb 
    $base.tix50 add command hc \
        -label 0xc 
    $base.tix50 add command hd \
        -label 0xd 
    $base.tix50 add command he \
        -label 0xe 
    $base.tix50 add command hf \
        -label 0xf 
    frame $base.fra37 \
        -borderwidth 2 -height 395 -relief sunken -width 460 
    tixScrolledListBox $base.fra37.tix35 \
        -command {codeClick $codeListBox} -scrollbar auto -borderwidth 1 \
        -height 385 -width 447 
    bind $base.fra37.tix35 <FocusIn> {
        focus .top32.fra37.tix35.listbox
    }
    message $base.mes45 \
        -padx 5 -pady 2 -relief sunken -text 00000000 \
        -textvariable inst_op_hex -width 127 
    label $base.lab46 \
        -height 0 -text {Current Instruction:} -width 0 
    message $base.mes54 \
        -padx 5 -pady 2 -relief sunken -text message -width 167 
    frame $base.fra55 \
        -borderwidth 2 -height 275 -relief ridge -width 105 
    button $base.fra55.but57 \
        -text Paste -width 0 
    button $base.fra55.but58 \
        -text Copy 
    button $base.fra55.but59 \
        -command {codeEditSel $codeListBox} -height 26 -text Edit -width 90 
    button $base.fra55.but60 \
        -command {codeDeleteSel $codeListBox} -text Delete 
    button $base.fra55.but61 \
        -command {codeInsertAfter $codeListBox $inst_op_hex} -height 26 \
        -text {Insert After} -width 90 
    button $base.fra55.but62 \
        -command {codeInsertBefore $codeListBox $inst_op_hex} -height 26 \
        -text {Insert Before} -width 90 
    button $base.fra55.but63 \
        -text Cut 
    checkbutton $base.fra55.che33 \
        -height 0 -text {Auto Edit} -variable autoEdit 
    label $base.lab64 \
        -height 0 -text {About this command:} -width 0 
    entry $base.ent47 \
        -background white -textvariable comment -width 278 
    label $base.lab48 \
        -text Comment: 
    checkbutton $base.che32 \
        -height 0 -text {comment only} -variable commentOnly -width 0 
    ###################
    # SETTING GEOMETRY
    ###################
    place $base.fra34 \
        -x 0 -y 0 -width 790 -height 35 -anchor nw -bordermode ignore 
    place $base.men35 \
        -x 5 -y 5 -anchor nw 
    place $base.men36 \
        -x 45 -y 5 -anchor nw -bordermode ignore 
    place $base.fra38 \
        -x 0 -y 35 -width 790 -height 110 -anchor nw -bordermode ignore 
    place $base.fra38.lab44 \
        -x 25 -y 10 -width 38 -height 20 -anchor nw -bordermode ignore 
    place $base.fra38.lab45 \
        -x 110 -y 10 -width 48 -height 20 -anchor nw -bordermode ignore 
    place $base.tix40 \
        -x 5 -y 70 -width 72 -height 25 -anchor nw -bordermode ignore 
    place $base.mes43 \
        -x 14 -y 105 -width 62 -height 22 -anchor nw -bordermode ignore 
    place $base.mes47 \
        -x 90 -y 105 -width 82 -height 22 -anchor nw -bordermode ignore 
    place $base.tix48 \
        -x 75 -y 70 -width 97 -height 25 -anchor nw -bordermode ignore 
    place $base.tix32 \
        -x 180 -y 70 -width 105 -height 25 -anchor nw -bordermode ignore 
    place $base.mes36 \
        -x 188 -y 105 -width 95 -height 22 -anchor nw -bordermode ignore 
    place $base.lab37 \
        -x 220 -y 45 -width 30 -height 20 -anchor nw -bordermode ignore 
    place $base.tix38 \
        -x 290 -y 70 -width 152 -height 25 -anchor nw -bordermode ignore 
    place $base.mes39 \
        -x 300 -y 105 -width 142 -height 22 -anchor nw -bordermode ignore 
    place $base.mes40 \
        -x 350 -y 45 -width 33 -height 22 -anchor nw -bordermode ignore 
    place $base.mes50 \
        -x 458 -y 105 -width 52 -height 22 -anchor nw -bordermode ignore 
    place $base.mes32 \
        -x 518 -y 105 -width 52 -height 22 -anchor nw -bordermode ignore 
    place $base.mes33 \
        -x 578 -y 105 -width 52 -height 22 -anchor nw -bordermode ignore 
    place $base.mes34 \
        -x 638 -y 105 -width 52 -height 22 -anchor nw -bordermode ignore 
    place $base.mes35 \
        -x 698 -y 105 -width 52 -height 22 -anchor nw -bordermode ignore 
    place $base.mes37 \
        -x 460 -y 45 -anchor nw -bordermode ignore 
    place $base.mes38 \
        -x 525 -y 45 -anchor nw -bordermode ignore 
    place $base.mes41 \
        -x 580 -y 45 -anchor nw -bordermode ignore 
    place $base.mes42 \
        -x 645 -y 45 -anchor nw -bordermode ignore 
    place $base.mes44 \
        -x 705 -y 45 -anchor nw -bordermode ignore 
    place $base.tix45 \
        -x 450 -y 70 -width 62 -height 25 -anchor nw -bordermode ignore 
    place $base.tix46 \
        -x 510 -y 70 -width 62 -height 25 -anchor nw -bordermode ignore 
    place $base.tix47 \
        -x 570 -y 70 -width 62 -height 25 -anchor nw -bordermode ignore 
    place $base.tix49 \
        -x 630 -y 70 -width 62 -height 25 -anchor nw -bordermode ignore 
    place $base.tix50 \
        -x 690 -y 70 -width 62 -height 25 -anchor nw -bordermode ignore 
    place $base.fra37 \
        -x 305 -y 175 -width 460 -height 395 -anchor nw -bordermode ignore 
    place $base.fra37.tix35 \
        -x 5 -y 5 -width 447 -height 385 -anchor nw -bordermode ignore 
    place $base.mes45 \
        -x 165 -y 175 -width 127 -height 22 -anchor nw -bordermode ignore 
    place $base.lab46 \
        -x 15 -y 175 -anchor nw -bordermode ignore 
    place $base.mes54 \
        -x 15 -y 295 -width 167 -height 272 -anchor nw -bordermode ignore 
    place $base.fra55 \
        -x 190 -y 295 -width 105 -height 275 -anchor nw -bordermode ignore 
    place $base.fra55.but57 \
        -x 5 -y 65 -width 90 -anchor nw 
    place $base.fra55.but58 \
        -x 5 -y 35 -width 90 -anchor nw 
    place $base.fra55.but59 \
        -x 5 -y 215 -width 90 -height 26 -anchor nw 
    place $base.fra55.but60 \
        -x 5 -y 95 -width 90 -anchor nw 
    place $base.fra55.but61 \
        -x 5 -y 170 -width 90 -height 26 -anchor nw 
    place $base.fra55.but62 \
        -x 5 -y 140 -width 90 -height 26 -anchor nw 
    place $base.fra55.but63 \
        -x 5 -y 5 -width 90 -anchor nw 
    place $base.fra55.che33 \
        -x 10 -y 245 -anchor nw -bordermode ignore 
    place $base.lab64 \
        -x 20 -y 270 -anchor nw -bordermode ignore 
    place $base.ent47 \
        -x 15 -y 230 -width 278 -height 22 -anchor nw -bordermode ignore 
    place $base.lab48 \
        -x 15 -y 210 -anchor nw -bordermode ignore 
    place $base.che32 \
        -x 185 -y 250 -anchor nw -bordermode ignore 

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top33 {base {container 0}} {
    if {$base == ""} {
        set base .top33
    }
    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }

    global widget
    vTcl:DefineAlias "$base" "Toplevel2" vTcl:Toplevel:WidgetProc "" 1
    vTcl:DefineAlias "$base.fra35" "Frame5" vTcl:WidgetProc "Toplevel2" 1
    vTcl:DefineAlias "$base.fra35.mes36" "Message20" vTcl:WidgetProc "Toplevel2" 1
    vTcl:DefineAlias "$base.fra38" "Frame6" vTcl:WidgetProc "Toplevel2" 1
    vTcl:DefineAlias "$base.fra38.but39" "Button9" vTcl:WidgetProc "Toplevel2" 1
    vTcl:DefineAlias "$base.fra38.but40" "Button10" vTcl:WidgetProc "Toplevel2" 1
    vTcl:DefineAlias "$base.fra38.but41" "Button11" vTcl:WidgetProc "Toplevel2" 1

    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    vTcl:toplevel $base -class Toplevel
    wm withdraw $base
    wm focusmodel $base passive
    wm geometry $base 275x110+278+266; update
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "New Toplevel 2"
    vTcl:FireEvent $base <<Create>>
    }
    frame $base.fra35 \
        -borderwidth 2 -height 70 -relief groove -width 275 
    message $base.fra35.mes36 \
        -padx 5 -pady 2 \
        -text {You have made changes since the last save.  Do you wish to save?} \
        -width 226 
    frame $base.fra38 \
        -borderwidth 2 -height 50 -relief groove -width 275 
    button $base.fra38.but39 \
        -command {Window hide .top33 ; saveFile $codeListBox; ; quit} \
        -text Yes 
    button $base.fra38.but40 \
        -command {Window hide .top33 ; exit} -text No 
    button $base.fra38.but41 \
        -command {Window hide .top33} -text Cancel 
    ###################
    # SETTING GEOMETRY
    ###################
    place $base.fra35 \
        -x 0 -y 0 -width 275 -height 70 -anchor nw -bordermode ignore 
    place $base.fra35.mes36 \
        -x 25 -y 10 -width 226 -height 35 -anchor nw 
    place $base.fra38 \
        -x 0 -y 60 -width 275 -height 50 -anchor nw -bordermode ignore 
    place $base.fra38.but39 \
        -x 10 -y 10 -width 70 -anchor nw -bordermode ignore 
    place $base.fra38.but40 \
        -x 100 -y 10 -width 70 -anchor nw -bordermode ignore 
    place $base.fra38.but41 \
        -x 190 -y 10 -width 70 -anchor nw -bordermode ignore 

    vTcl:FireEvent $base <<Ready>>
}

Window show .
Window show .top32
Window show .top33

main $argc $argv


# $Id: coder.tcl,v 1.1 2001-10-26 21:35:04 bobh Exp $
# Program : coder.tcl
# Scope  : SXP code builder program
# Author : Bob Hoffman
# Function : GUI for creating ROM files for SXP Processors.
#
# $Log: not supported by cvs2svn $
#
