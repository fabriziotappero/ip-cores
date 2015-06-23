#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

    package require Tk
    switch $tcl_platform(platform) {
	windows {
            option add *Button.padY 0
	}
	default {
            option add *Scrollbar.width 10
            option add *Scrollbar.highlightThickness 0
            option add *Scrollbar.elementBorderWidth 2
            option add *Scrollbar.borderWidth 2
	}
    }
    
}

#############################################################################
# Visual Tcl v1.60 Project
#


#################################
# VTCL LIBRARY PROCEDURES
#

if {![info exists vTcl(sourcing)]} {
#############################################################################
## Library Procedure:  Window

proc ::Window {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global vTcl
    foreach {cmd name newname} [lrange $args 0 2] {}
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
            if {[winfo exists $newname] && [wm state $newname] == "normal"} {
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
#############################################################################
## Library Procedure:  vTcl:DefineAlias

proc ::vTcl:DefineAlias {target alias widgetProc top_or_alias cmdalias} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

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
#############################################################################
## Library Procedure:  vTcl:DoCmdOption

proc ::vTcl:DoCmdOption {target cmd} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## menus are considered toplevel windows
    set parent $target
    while {[winfo class $parent] == "Menu"} {
        set parent [winfo parent $parent]
    }

    regsub -all {\%widget} $cmd $target cmd
    regsub -all {\%top} $cmd [winfo toplevel $parent] cmd

    uplevel #0 [list eval $cmd]
}
#############################################################################
## Library Procedure:  vTcl:FireEvent

proc ::vTcl:FireEvent {target event {params {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## The window may have disappeared
    if {![winfo exists $target]} return
    ## Process each binding tag, looking for the event
    foreach bindtag [bindtags $target] {
        set tag_events [bind $bindtag]
        set stop_processing 0
        foreach tag_event $tag_events {
            if {$tag_event == $event} {
                set bind_code [bind $bindtag $tag_event]
                foreach rep "\{%W $target\} $params" {
                    regsub -all [lindex $rep 0] $bind_code [lindex $rep 1] bind_code
                }
                set result [catch {uplevel #0 $bind_code} errortext]
                if {$result == 3} {
                    ## break exception, stop processing
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
#############################################################################
## Library Procedure:  vTcl:Toplevel:WidgetProc

proc ::vTcl:Toplevel:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }
    set command [lindex $args 0]
    set args [lrange $args 1 end]
    switch -- [string tolower $command] {
        "setvar" {
            foreach {varname value} $args {}
            if {$value == ""} {
                return [set ::${w}::${varname}]
            } else {
                return [set ::${w}::${varname} $value]
            }
        }
        "hide" - "show" {
            Window [string tolower $command] $w
        }
        "showmodal" {
            ## modal dialog ends when window is destroyed
            Window show $w; raise $w
            grab $w; tkwait window $w; grab release $w
        }
        "startmodal" {
            ## ends when endmodal called
            Window show $w; raise $w
            set ::${w}::_modal 1
            grab $w; tkwait variable ::${w}::_modal; grab release $w
        }
        "endmodal" {
            ## ends modal dialog started with startmodal, argument is var name
            set ::${w}::_modal 0
            Window hide $w
        }
        default {
            uplevel $w $command $args
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:WidgetProc

proc ::vTcl:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }

    set command [lindex $args 0]
    set args [lrange $args 1 end]
    uplevel $w $command $args
}
#############################################################################
## Library Procedure:  vTcl:toplevel

proc ::vTcl:toplevel {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    uplevel #0 eval toplevel $args
    set target [lindex $args 0]
    namespace eval ::$target {set _modal 0}
}
}


if {[info exists vTcl(sourcing)]} {

proc vTcl:project:info {} {
    set base .top60
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.m78 {
        array set save {-tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1 -menu 1}
        }
    }
    set site_3_0 $base.m78
    namespace eval ::widgets::$site_3_0.men79 {
        array set save {-tearoff 1}
        namespace eval subOptions {
            array set save {-accelerator 1 -command 1 -label 1 -menu 1}
        }
    }
    namespace eval ::widgets::$base.cpd86 {
        array set save {-borderwidth 1}
    }
    set site_3_0 $base.cpd86
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.01
    namespace eval ::widgets::$site_4_0.fra82 {
        array set save {-borderwidth 1 -height 1}
    }
    namespace eval ::widgets::$site_4_0.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd88
    namespace eval ::widgets::$site_5_0.01 {
        array set save {-command 1 -orient 1}
    }
    namespace eval ::widgets::$site_5_0.02 {
        array set save {-command 1}
    }
    namespace eval ::widgets::$site_5_0.03 {
        array set save {-font 1 -height 1 -width 1 -xscrollcommand 1 -yscrollcommand 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-borderwidth 1 -text 1}
    }
    namespace eval ::widgets::$base.but65 {
        array set save {-command 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$base.lab61 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    set site_3_0 $base.lab61
    namespace eval ::widgets::$site_3_0.but62 {
        array set save {-command 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.men63 {
        array set save {-menu 1 -padx 1 -pady 1 -relief 1 -text 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_3_0.men63.m {
        array set save {-tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$site_3_0.but74 {
        array set save {-_tooltip 1 -command 1 -compound 1 -default 1 -foreground 1 -height 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.che62 {
        array set save {-disabledforeground 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.but63 {
        array set save {-_tooltip 1 -command 1 -text 1}
    }
    namespace eval ::widgets::$base.lab67 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    set site_3_0 $base.lab67
    namespace eval ::widgets::$site_3_0.men68 {
        array set save {-menu 1 -padx 1 -pady 1 -relief 1 -text 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_3_0.men68.m {
        array set save {-tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$site_3_0.but69 {
        array set save {-command 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.che70 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.but61 {
        array set save {-_tooltip 1 -command 1 -text 1}
    }
    namespace eval ::widgets::$base.lab71 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    set site_3_0 $base.lab71
    namespace eval ::widgets::$site_3_0.men72 {
        array set save {-menu 1 -padx 1 -pady 1 -relief 1 -text 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_3_0.men72.m {
        array set save {-tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-command 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.che75 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.but60 {
        array set save {-_tooltip 1 -command 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_3_0 $base.cpd77
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-anchor 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-cursor 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.cpd78 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_3_0 $base.cpd78
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-anchor 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-cursor 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.cpd79 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_3_0 $base.cpd79
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-anchor 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-cursor 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.cpd80 {
        array set save {-borderwidth 1 -height 1}
    }
    set site_3_0 $base.cpd80
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-anchor 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-cursor 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.cpd60 {
        array set save {-_tooltip 1 -command 1 -text 1}
    }
    namespace eval ::widgets::$base.but60 {
        array set save {-_tooltip 1 -command 1 -text 1}
    }
    namespace eval ::widgets::$base.but61 {
        array set save {-_tooltip 1 -command 1 -text 1}
    }
    namespace eval ::widgets::$base.but62 {
        array set save {-_tooltip 1 -command 1 -text 1}
    }
    namespace eval ::widgets::$base.but64 {
        array set save {-command 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            _act:log
            lls
            docmd
            runsyn
            runflow
            runpr
            runsim
            simbuild
            simclean
            synclean
            prclean
        }
        set compounds {
        }
        set projectType single
    }
}
}

#################################
# USER DEFINED PROCEDURES
#
#############################################################################
## Procedure:  main

proc ::main {argc argv} {
global grproject project_name synbatch prbatch simprog simmenu
global simbatch syntool synmenu prmenu prtool prbatch
global board tech device

set grproject [lindex $argv 0]
set tech [lindex $argv 1]
set device [lindex $argv 2]
set board [lindex $argv 3]

set project_name $grproject

set synbatch 0
set syntool "synplify"
set synmenu "Synplify"
set prbatch 0
set simprog "vsim"
set simmenu "Modelsim"
set simbatch 0
set prbatch 0
set prmenu "None"
set prtool "none"
}
#############################################################################
## Procedure:  _act:log

proc ::_act:log {} {
global widget

  global input run_next_cmd
  if [eof $input] {
    catch [close $input]
    set run_next_cmd 1
  } else {
    gets $input line
    Text2 insert end $line\n
    Text2 see end
  }
}
#############################################################################
## Procedure:  lls

proc ::lls {} {
global widget

global input run_next_cmd

    variable command "ls -l"
    if [catch {open "|$command "} input] {
      Text2 insert end "Can't find the executable.\n"
    } else {
      set run_next_cmd 0
      fileevent $input readable {_act:log}
      Text2 insert end $command\n
      vwait run_next_cmd
    }
}
#############################################################################
## Procedure:  docmd

proc ::docmd {cmd} {
global widget

global input run_next_cmd

    variable command $cmd
    if [catch {open "|$command "} input] {
      Text2 insert end "Can't find the executable.\n"
    } else {
      set run_next_cmd 0
      fileevent $input readable {_act:log}
      Text2 insert end $command\n
      vwait run_next_cmd
    }
}
#############################################################################
## Procedure:  runsyn

proc ::runsyn {} {
global widget grproject syntool synbatch

  if {$synbatch == "0"} {
    docmd "make $syntool-launch"
  } else {
    docmd "make $syntool-map"
  }
}
#############################################################################
## Procedure:  runflow

proc ::runflow {} {
global widget grproject syntool synbatch prtool

  switch $syntool {
    "synplify" {
      switch $prtool {
        "none" {docmd "make synplify"}
        "designer" {docmd "fpgaax"}
        "quartus" {docmd "make fpgaq"}
        "ise" {docmd "make fpgasynp"}
      }
    }
    "xst" {
      switch $prtool {
        "none" {docmd "make xst"}
        "ise" {docmd "make fpgaxst"}
        default {}
      }
    }
    default {}
  }
}
#############################################################################
## Procedure:  runpr

proc ::runpr {} {
global widget grproject syntool prbatch prtool

if {$prbatch == "0"} {
  switch $prtool {
    "actel" { docmd "make actel-launch"}
    "quartus" {
      if {$syntool == "synplify"} {docmd "make quartus-launch-synp"}
      if {$syntool == "quartus"} {docmd "make quartus-launch"}
     }
    "ise" {
      if {$syntool == "synplify"} {docmd "make ise-launch-synp"}
      if {$syntool == "xst"} {docmd "make ise-launch"}
    }
  }
}

if {$prbatch != "0"} {
  switch $prtool {
    "actel" { docmd "make actel"}
    "quartus" {
      if {$syntool == "synplify"} {docmd "make quartus-synp"}
      if {$syntool == "quartus"} {docmd "make quartus-route"}
    }
    "ise" {
      if {$syntool == "synplify"} {docmd "make ise-synp"}
      if {$syntool == "xst"} {docmd "make ise"}
    }
  }
}
}
#############################################################################
## Procedure:  runsim

proc ::runsim {} {
global widget grproject simprog simbatch

  if {$simbatch == "0"} {
    docmd "make $simprog-launch"
  } else {
    docmd "make $simprog-run"
  }
}
#############################################################################
## Procedure:  simbuild

proc ::simbuild {} {
global widget grproject simprog simbatch

docmd "make $simprog"
}
#############################################################################
## Procedure:  simclean

proc ::simclean {} {
global widget grproject simprog simbatch

docmd "make $simprog-clean"
}
#############################################################################
## Procedure:  synclean

proc ::synclean {} {
global widget grproject syntool synbatch

  docmd "make $syntool-clean"
}
#############################################################################
## Procedure:  prclean

proc ::prclean {} {
global widget grproject prtool synbatch

  docmd "make $prtool-clean"
}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {
global input run_next_cmd grproject

set run_next_cmd 1
}

init $argc $argv

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    wm focusmodel $top passive
    wm geometry $top 1x1+0+0; update
    wm maxsize $top 1265 994
    wm minsize $top 1 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm withdraw $top
    wm title $top "vtcl.tcl"
    bindtags $top "$top Vtcl.tcl all"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    ###################
    # SETTING GEOMETRY
    ###################

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top60 {base} {
    if {$base == ""} {
        set base .top60
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m78" -highlightcolor black 
    wm focusmodel $top passive
    wm geometry $top 609x477+358+121; update
    wm maxsize $top 1009 738
    wm minsize $top 1 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm deiconify $top
    wm title $top "GRLIB Implementation Tool"
    vTcl:DefineAlias "$top" "Toplevel1" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    menu $top.m78 \
        -tearoff 1 
    $top.m78 add cascade \
        -menu "$top.m78.men79" -command {} -label File 
    set site_3_0 $top.m78
    menu $site_3_0.men79 \
        -tearoff 0 
    $site_3_0.men79 add command \
        -accelerator Ctrl-Q -command exit -label Quit 
    frame $top.cpd86 \
        -borderwidth 2 
    vTcl:DefineAlias "$top.cpd86" "Frame3" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.cpd86
    frame $site_3_0.01 \
        -borderwidth 2 -relief groove -height 98 -width 125 
    vTcl:DefineAlias "$site_3_0.01" "Frame4" vTcl:WidgetProc "Toplevel1" 1
    set site_4_0 $site_3_0.01
    frame $site_4_0.fra82 \
        -borderwidth 2 -height 10 
    vTcl:DefineAlias "$site_4_0.fra82" "Frame5" vTcl:WidgetProc "Toplevel1" 1
    frame $site_4_0.cpd88 \
        -height 219 -width 584 
    vTcl:DefineAlias "$site_4_0.cpd88" "Frame7" vTcl:WidgetProc "Toplevel1" 1
    set site_5_0 $site_4_0.cpd88
    scrollbar $site_5_0.01 \
        -command "$site_5_0.03 xview" -orient horizontal 
    vTcl:DefineAlias "$site_5_0.01" "Scrollbar3" vTcl:WidgetProc "Toplevel1" 1
    scrollbar $site_5_0.02 \
        -command "$site_5_0.03 yview" 
    vTcl:DefineAlias "$site_5_0.02" "Scrollbar4" vTcl:WidgetProc "Toplevel1" 1
    text $site_5_0.03 \
        -font {Courier -12} -height 14 -width 80 \
        -xscrollcommand "$site_5_0.01 set" -yscrollcommand "$site_5_0.02 set" 
    vTcl:DefineAlias "$site_5_0.03" "Text2" vTcl:WidgetProc "Toplevel1" 1
    grid $site_5_0.01 \
        -in $site_5_0 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew 
    grid $site_5_0.02 \
        -in $site_5_0 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns 
    grid $site_5_0.03 \
        -in $site_5_0 -column 0 -row 0 -columnspan 1 -rowspan 1 -sticky nesw 
    pack $site_4_0.fra82 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    place $site_4_0.cpd88 \
        -in $site_4_0 -x 9 -y 14 -width 584 -height 219 -anchor nw \
        -bordermode inside 
    label $site_3_0.02 \
        -borderwidth 1 -text Console 
    vTcl:DefineAlias "$site_3_0.02" "Label3" vTcl:WidgetProc "Toplevel1" 1
    pack $site_3_0.01 \
        -in $site_3_0 -anchor center -expand 1 -fill both -padx 5 -pady 5 \
        -side top 
    place $site_3_0.02 \
        -in $site_3_0 -x 15 -y 0 -anchor nw -bordermode ignore 
    button $top.but65 \
        -command exit -foreground #ff0000 -text Quit 
    vTcl:DefineAlias "$top.but65" "Button3" vTcl:WidgetProc "Toplevel1" 1
    labelframe $top.lab61 \
        -foreground black -text Simulation -highlightcolor black 
    vTcl:DefineAlias "$top.lab61" "Labelframe1" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.lab61
    button $site_3_0.but62 \
        -command runsim -foreground #0000ff -text Run 
    vTcl:DefineAlias "$site_3_0.but62" "Button5" vTcl:WidgetProc "Toplevel1" 1
    menubutton $site_3_0.men63 \
        -menu "$site_3_0.men63.m" -padx 5 -pady 4 -relief raised \
        -text Modelsim -textvariable simmenu 
    vTcl:DefineAlias "$site_3_0.men63" "Menubutton1" vTcl:WidgetProc "Toplevel1" 1
    menu $site_3_0.men63.m \
        -tearoff 0 
    $site_3_0.men63.m add command \
        \
        -command {global simprog simmenu
set simprog "vsim"
set simmenu "Modelsim"} \
        -label Modelsim 
    $site_3_0.men63.m add command \
        \
        -command {global simprog simmenu
set simprog "ncsim"
set simmenu "Ncsim"} \
        -label Ncsim 
    $site_3_0.men63.m add command \
        \
        -command {global simprog simmenu
set simprog "ghdl"
set simmenu "GHDL"} \
        -label GHDL 
    $site_3_0.men63.m add command \
        \
        -command {global simprog simmenu
set simprog "libero"
set simmenu "Libero"} \
        -label Libero 
    $site_3_0.men63.m add command \
        \
        -command {global simprog simmenu
set simprog "riviera"
set simmenu "Riviera"} \
        -label Riviera 
    $site_3_0.men63.m add command \
        \
        -command {global simprog simmenu
set simprog "avhdl"
set simmenu "Active-HDL GUI"} \
        -label {Active-HDL GUI} 
    $site_3_0.men63.m add command \
        \
        -command {global simprog simmenu
set simprog "vsimsa"
set simmenu "Active-HDL batch"} \
        -label {Active-HDL batch} 
    $site_3_0.men63.m add command \
        \
        -command {# TODO: Your menu handler hereglobal simprog simmenu
set simprog "sonata"
set simmenu "Sonata"} \
        -label Sonata 
    button $site_3_0.but74 \
        -command simbuild -compound none -default disabled \
        -foreground #009900 -height 26 -text Build 
    vTcl:DefineAlias "$site_3_0.but74" "Button8" vTcl:WidgetProc "Toplevel1" 1
    bindtags $site_3_0.but74 "$site_3_0.but74 Button $top all _vTclBalloon"
    bind $site_3_0.but74 <<SetBalloon>> {
        set ::vTcl::balloon::%W {compile grlib and local design}
    }
    checkbutton $site_3_0.che62 \
        -disabledforeground #a3a3a3 -text Batch -variable simbatch 
    vTcl:DefineAlias "$site_3_0.che62" "Checkbutton1" vTcl:WidgetProc "Toplevel1" 1
    button $site_3_0.but63 \
        -command simclean -text Clean 
    vTcl:DefineAlias "$site_3_0.but63" "Button9" vTcl:WidgetProc "Toplevel1" 1
    bindtags $site_3_0.but63 "$site_3_0.but63 Button $top all _vTclBalloon"
    bind $site_3_0.but63 <<SetBalloon>> {
        set ::vTcl::balloon::%W {remove generated files for selected tool}
    }
    place $site_3_0.but62 \
        -in $site_3_0 -x 125 -y 20 -width 49 -height 26 -anchor nw \
        -bordermode ignore 
    place $site_3_0.men63 \
        -in $site_3_0 -x 10 -y 20 -width 101 -height 26 -anchor nw \
        -bordermode ignore 
    place $site_3_0.but74 \
        -in $site_3_0 -x 331 -y 20 -width 50 -height 26 -anchor nw \
        -bordermode ignore 
    place $site_3_0.che62 \
        -in $site_3_0 -x 189 -y 22 -width 61 -height 22 -anchor nw \
        -bordermode ignore 
    place $site_3_0.but63 \
        -in $site_3_0 -x 261 -y 20 -width 58 -height 26 -anchor nw \
        -bordermode ignore 
    labelframe $top.lab67 \
        -foreground black -text {Place & route} -highlightcolor black 
    vTcl:DefineAlias "$top.lab67" "Labelframe2" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.lab67
    menubutton $site_3_0.men68 \
        -menu "$site_3_0.men68.m" -padx 5 -pady 4 -relief raised -text None \
        -textvariable prmenu 
    vTcl:DefineAlias "$site_3_0.men68" "Menubutton3" vTcl:WidgetProc "Toplevel1" 1
    menu $site_3_0.men68.m \
        -tearoff 0 
    $site_3_0.men68.m add command \
        -command {global prmenu prtool
set prmenu "None"
set prtool "none"} \
        -label None 
    $site_3_0.men68.m add command \
        \
        -command {global prmenu prtool
set prmenu "Actel Designer"
set prtool "actel"} \
        -label {Actel Designer} 
    $site_3_0.men68.m add command \
        \
        -command {global prmenu prtool
set prmenu "Quartus"
set prtool "quartus"} \
        -label Quartus 
    $site_3_0.men68.m add command \
        \
        -command {global prmenu prtool
set prmenu "Xilinx ISE"
set prtool "ise"} \
        -label {Xilinx ISE} 
    button $site_3_0.but69 \
        -command runpr -foreground #0000ff -text Run 
    vTcl:DefineAlias "$site_3_0.but69" "Button6" vTcl:WidgetProc "Toplevel1" 1
    checkbutton $site_3_0.che70 \
        -text Batch -variable prbatch 
    vTcl:DefineAlias "$site_3_0.che70" "Checkbutton2" vTcl:WidgetProc "Toplevel1" 1
    button $site_3_0.but61 \
        -command prclean -text Clean 
    vTcl:DefineAlias "$site_3_0.but61" "Button2" vTcl:WidgetProc "Toplevel1" 1
    bindtags $site_3_0.but61 "$site_3_0.but61 Button $top all _vTclBalloon"
    bind $site_3_0.but61 <<SetBalloon>> {
        set ::vTcl::balloon::%W {remove generated files for selected tool}
    }
    place $site_3_0.men68 \
        -in $site_3_0 -x 10 -y 20 -width 101 -height 26 -anchor nw \
        -bordermode ignore 
    place $site_3_0.but69 \
        -in $site_3_0 -x 125 -y 20 -width 49 -height 26 -anchor nw \
        -bordermode ignore 
    place $site_3_0.che70 \
        -in $site_3_0 -x 185 -y 20 -width 61 -height 22 -anchor nw \
        -bordermode ignore 
    place $site_3_0.but61 \
        -in $site_3_0 -x 261 -y 20 -width 58 -height 26 -anchor nw \
        -bordermode ignore 
    labelframe $top.lab71 \
        -foreground black -text Synthesis -highlightcolor black 
    vTcl:DefineAlias "$top.lab71" "Labelframe3" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.lab71
    menubutton $site_3_0.men72 \
        -menu "$site_3_0.men72.m" -padx 5 -pady 4 -relief raised \
        -text Synplify -textvariable synmenu 
    vTcl:DefineAlias "$site_3_0.men72" "Menubutton2" vTcl:WidgetProc "Toplevel1" 1
    menu $site_3_0.men72.m \
        -tearoff 0 
    $site_3_0.men72.m add command \
        \
        -command {global synmenu syntool
set synmenu "Synplify"
set syntool "synplify"} \
        -label Synplify 
    $site_3_0.men72.m add command \
        \
        -command {global synmenu syntool
set synmenu "Quartus"
set syntool "quartus"} \
        -label Quartus 
    $site_3_0.men72.m add command \
        \
        -command {global synmenu syntool
set synmenu "Xilinx ISE"
set syntool "xst"} \
        -label {Xilinx ISE} 
    $site_3_0.men72.m add command \
        \
        -command {global synmenu syntool
set synmenu "Precision"
set syntool "precision"} \
        -label Precision 
    $site_3_0.men72.m add command \
        \
        -command {global synmenu syntool
set synmenu "Libero"
set syntool "libero"} \
        -label Libero 
    button $site_3_0.but73 \
        -command runsyn -foreground #0000ff -text Run 
    vTcl:DefineAlias "$site_3_0.but73" "Button7" vTcl:WidgetProc "Toplevel1" 1
    checkbutton $site_3_0.che75 \
        -text Batch -variable synbatch 
    vTcl:DefineAlias "$site_3_0.che75" "Checkbutton3" vTcl:WidgetProc "Toplevel1" 1
    button $site_3_0.but60 \
        -command synclean -text Clean 
    vTcl:DefineAlias "$site_3_0.but60" "Button1" vTcl:WidgetProc "Toplevel1" 1
    bindtags $site_3_0.but60 "$site_3_0.but60 Button $top all _vTclBalloon"
    bind $site_3_0.but60 <<SetBalloon>> {
        set ::vTcl::balloon::%W {remove generated files for selected tool}
    }
    place $site_3_0.men72 \
        -in $site_3_0 -x 10 -y 20 -width 101 -height 26 -anchor nw \
        -bordermode ignore 
    place $site_3_0.but73 \
        -in $site_3_0 -x 125 -y 20 -width 49 -height 26 -anchor nw \
        -bordermode ignore 
    place $site_3_0.che75 \
        -in $site_3_0 -x 187 -y 21 -width 61 -height 22 -anchor nw \
        -bordermode ignore 
    place $site_3_0.but60 \
        -in $site_3_0 -x 261 -y 20 -width 58 -height 26 -anchor nw \
        -bordermode ignore 
    frame $top.cpd77 \
        -borderwidth 1 -height 30 
    vTcl:DefineAlias "$top.cpd77" "Frame6" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.cpd77
    label $site_3_0.01 \
        -anchor w -text Tech: 
    vTcl:DefineAlias "$site_3_0.01" "Label2" vTcl:WidgetProc "Toplevel1" 1
    entry $site_3_0.02 \
        -cursor {} -state readonly -textvariable tech 
    vTcl:DefineAlias "$site_3_0.02" "Entry2" vTcl:WidgetProc "Toplevel1" 1
    pack $site_3_0.01 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 2 -pady 2 \
        -side left 
    pack $site_3_0.02 \
        -in $site_3_0 -anchor center -expand 1 -fill x -padx 2 -pady 2 \
        -side right 
    frame $top.cpd78 \
        -borderwidth 1 -height 30 
    vTcl:DefineAlias "$top.cpd78" "Frame8" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.cpd78
    label $site_3_0.01 \
        -anchor w -text Device: 
    vTcl:DefineAlias "$site_3_0.01" "Label4" vTcl:WidgetProc "Toplevel1" 1
    entry $site_3_0.02 \
        -cursor {} -state readonly -textvariable device 
    vTcl:DefineAlias "$site_3_0.02" "Entry3" vTcl:WidgetProc "Toplevel1" 1
    pack $site_3_0.01 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 2 -pady 2 \
        -side left 
    pack $site_3_0.02 \
        -in $site_3_0 -anchor center -expand 1 -fill x -padx 2 -pady 2 \
        -side right 
    frame $top.cpd79 \
        -borderwidth 1 -height 30 
    vTcl:DefineAlias "$top.cpd79" "Frame9" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.cpd79
    label $site_3_0.01 \
        -anchor w -text Board: 
    vTcl:DefineAlias "$site_3_0.01" "Label6" vTcl:WidgetProc "Toplevel1" 1
    entry $site_3_0.02 \
        -cursor {} -state readonly -textvariable board 
    vTcl:DefineAlias "$site_3_0.02" "Entry4" vTcl:WidgetProc "Toplevel1" 1
    pack $site_3_0.01 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 2 -pady 2 \
        -side left 
    pack $site_3_0.02 \
        -in $site_3_0 -anchor center -expand 1 -fill x -padx 2 -pady 2 \
        -side right 
    frame $top.cpd80 \
        -borderwidth 1 -height 30 
    vTcl:DefineAlias "$top.cpd80" "Frame10" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.cpd80
    label $site_3_0.01 \
        -anchor w -text Project: 
    vTcl:DefineAlias "$site_3_0.01" "Label5" vTcl:WidgetProc "Toplevel1" 1
    entry $site_3_0.02 \
        -cursor {} -state readonly -textvariable project_name 
    vTcl:DefineAlias "$site_3_0.02" "Entry1" vTcl:WidgetProc "Toplevel1" 1
    pack $site_3_0.01 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 2 -pady 2 \
        -side left 
    pack $site_3_0.02 \
        -in $site_3_0 -anchor center -expand 1 -fill x -padx 2 -pady 2 \
        -side right 
    button $top.cpd60 \
        -command {docmd "make xconfig"} -text xconfig 
    vTcl:DefineAlias "$top.cpd60" "Button4" vTcl:WidgetProc "Toplevel1" 1
    bindtags $top.cpd60 "$top.cpd60 Button $top all _vTclBalloon"
    bind $top.cpd60 <<SetBalloon>> {
        set ::vTcl::balloon::%W {run grlib/leon3 configuration tool}
    }
    button $top.but60 \
        -command {docmd "make ise-prog-prom"} -text {prog prom} 
    vTcl:DefineAlias "$top.but60" "buildvermod" vTcl:WidgetProc "Toplevel1" 1
    bindtags $top.but60 "$top.but60 Button $top all _vTclBalloon"
    bind $top.but60 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Program FPGA prom}
    }
    button $top.but61 \
        -command {docmd "make clean"} -text {clean all} 
    vTcl:DefineAlias "$top.but61" "Button10" vTcl:WidgetProc "Toplevel1" 1
    bindtags $top.but61 "$top.but61 Button $top all _vTclBalloon"
    bind $top.but61 <<SetBalloon>> {
        set ::vTcl::balloon::%W {remove all generated files except compile scripts}
    }
    button $top.but62 \
        -command {docmd "make distclean"} -text distclean 
    vTcl:DefineAlias "$top.but62" "Button11" vTcl:WidgetProc "Toplevel1" 1
    bindtags $top.but62 "$top.but62 Button $top all _vTclBalloon"
    bind $top.but62 <<SetBalloon>> {
        set ::vTcl::balloon::%W {remove all generated file}
    }
    button $top.but64 \
        -command {docmd "make scripts"} -text scripts 
    vTcl:DefineAlias "$top.but64" "Button12" vTcl:WidgetProc "Toplevel1" 1
    ###################
    # SETTING GEOMETRY
    ###################
    place $top.cpd86 \
        -in $top -x 0 -y 220 -width 612 -height 254 -anchor nw \
        -bordermode inside 
    place $top.but65 \
        -in $top -x 528 -y 60 -width 66 -height 26 -anchor nw \
        -bordermode ignore 
    place $top.lab61 \
        -in $top -x 20 -y 10 -width 396 -height 56 -anchor nw \
        -bordermode ignore 
    place $top.lab67 \
        -in $top -x 20 -y 150 -width 336 -height 56 -anchor nw \
        -bordermode ignore 
    place $top.lab71 \
        -in $top -x 20 -y 80 -width 336 -height 56 -anchor nw \
        -bordermode ignore 
    place $top.cpd77 \
        -in $top -x 404 -y 133 -width 197 -height 28 -anchor nw \
        -bordermode ignore 
    place $top.cpd78 \
        -in $top -x 392 -y 161 -width 209 -height 28 -anchor nw \
        -bordermode ignore 
    place $top.cpd79 \
        -in $top -x 398 -y 189 -width 203 -height 28 -anchor nw \
        -bordermode ignore 
    place $top.cpd80 \
        -in $top -x 391 -y 105 -width 210 -height 28 -anchor nw \
        -bordermode ignore 
    place $top.cpd60 \
        -in $top -x 528 -y 10 -width 66 -height 26 -anchor nw \
        -bordermode ignore 
    place $top.but60 \
        -in $top -x 450 -y 10 -width 79 -height 26 -anchor nw \
        -bordermode ignore 
    place $top.but61 \
        -in $top -x 450 -y 35 -width 79 -height 26 -anchor nw \
        -bordermode ignore 
    place $top.but62 \
        -in $top -x 450 -y 60 -width 79 -height 26 -anchor nw \
        -bordermode ignore 
    place $top.but64 \
        -in $top -x 528 -y 35 -width 66 -height 26 -anchor nw \
        -bordermode ignore 

    vTcl:FireEvent $base <<Ready>>
}

#############################################################################
## Binding tag:  _TopLevel

bind "_TopLevel" <<Create>> {
    if {![info exists _topcount]} {set _topcount 0}; incr _topcount
}
bind "_TopLevel" <<DeleteWindow>> {
    if {[set ::%W::_modal]} {
                vTcl:Toplevel:WidgetProc %W endmodal
            } else {
                destroy %W; if {$_topcount == 0} {exit}
            }
}
bind "_TopLevel" <Destroy> {
    if {[winfo toplevel %W] == "%W"} {incr _topcount -1}
}
#############################################################################
## Binding tag:  _vTclBalloon


if {![info exists vTcl(sourcing)]} {
bind "_vTclBalloon" <<KillBalloon>> {
    namespace eval ::vTcl::balloon {
        after cancel $id
        if {[winfo exists .vTcl.balloon]} {
            destroy .vTcl.balloon
        }
        set set 0
    }
}
bind "_vTclBalloon" <<vTclBalloon>> {
    if {$::vTcl::balloon::first != 1} {break}

    namespace eval ::vTcl::balloon {
        set first 2
        if {![winfo exists .vTcl]} {
            toplevel .vTcl; wm withdraw .vTcl
        }
        if {![winfo exists .vTcl.balloon]} {
            toplevel .vTcl.balloon -bg black
        }
        wm overrideredirect .vTcl.balloon 1
        label .vTcl.balloon.l  -text ${%W} -relief flat  -bg #ffffaa -fg black -padx 2 -pady 0 -anchor w
        pack .vTcl.balloon.l -side left -padx 1 -pady 1
        wm geometry  .vTcl.balloon  +[expr {[winfo rootx %W]+[winfo width %W]/2}]+[expr {[winfo rooty %W]+[winfo height %W]+4}]
        set set 1
    }
}
bind "_vTclBalloon" <Button> {
    namespace eval ::vTcl::balloon {
        set first 0
    }
    vTcl:FireEvent %W <<KillBalloon>>
}
bind "_vTclBalloon" <Enter> {
    namespace eval ::vTcl::balloon {
        ## self defining balloon?
        if {![info exists %W]} {
            vTcl:FireEvent %W <<SetBalloon>>
        }
        set set 0
        set first 1
        set id [after 500 {vTcl:FireEvent %W <<vTclBalloon>>}]
    }
}
bind "_vTclBalloon" <Leave> {
    namespace eval ::vTcl::balloon {
        set first 0
    }
    vTcl:FireEvent %W <<KillBalloon>>
}
bind "_vTclBalloon" <Motion> {
    namespace eval ::vTcl::balloon {
        if {!$set} {
            after cancel $id
            set id [after 500 {vTcl:FireEvent %W <<vTclBalloon>>}]
        }
    }
}
}

Window show .
Window show .top60

main $argc $argv
