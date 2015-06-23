#! /usr/bin/env wish
##-------------------------------------------------------------------------------
##--                     Copyright 2014 Ken Campbell
##--                        All Rights Reserved
##----------------------------------------------------------------------------
## This file is an application that will generate some starting structure files.
## Output from this program is not covered by this license, you may apply your
## own copyright and license notices to generated files as you see fit.
##
##  Redistribution and use in source and binary forms, with or without
##  modification, are permitted provided that the following conditions are met:
##
##  1. Redistributions of source code must retain the above copyright notice,
##     this list of conditions and the following disclaimer.
##
##  2. Redistributions in binary form must reproduce the above copyright notice,
##     this list of conditions and the following disclaimer in the documentation
##     and/or other materials provided with the distribution.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
## LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
## INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
## CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
## POSSIBILITY OF SUCH DAMAGE.
##-------------------------------------------------------------------------------
##-- $Author:  $
##--
##-- Description :
##--   This application takes a text file containing the definition of a VHDL
##        entity, parses that entity and generates the VHDL Test Bench starting
##        file set.  It is a rewrite of the previous ttb_gen_gui to include
##        view of the file.
##     This version has been updated to handle any entity definition
##        as well as generating generics found on the target entity.
##--
##------------------------------------------------------------------------------

## package requires
package require Iwidgets 4.0

## set the current version info
set version "V 3.0"
## put up a title on the main window boarder
wm title . "TTB Gen  $version"

## the location of the template by default
set template "../vhdl/template_tb_bhv.vhd"

set use_list 0

##  Working Directory or vhdl directory
set workd [frame .wdf]
set ent_dir [iwidgets::entryfield $workd.cen1 -labeltext "Working Directory"]
button $workd.br0 -text "Browse" -command {fill_list}
pack $workd.br0 -side right
pack $ent_dir -fill x
pack $workd -fill x -pady 6

##  Output directory
set tlist [frame .lstf]
set odir [iwidgets::entryfield $tlist.ent1 -labeltext "Output Directory"]
set lbut [button $tlist.br1 -text "Browse" -command {browsed_from_set $odir $odir}]
pack $lbut -side right
pack $odir -fill x
pack $tlist -fill x

##  Template location
set tdirf [frame .tmpf]
set tdir [iwidgets::entryfield $tdirf.ent2 -width 60 -labeltext "Template Location"]
set tbut [button $tdirf.br2 -text "Browse" -command {browse_set_entry $tdir}]
pack $tbut -side right
pack $tdir -fill x
pack $tdirf -fill x -pady 6
$tdir delete 0 end
$tdir insert end $template
$tdir configure -state readonly

## type spec
set tsf [frame .tsfr]
set load_but [button $tsf.bt1 -text "Generate" -command ttb_gen]
set mo_sel [iwidgets::optionmenu $tsf.mode -labeltext "Mode"]
set gbatv 0
set gbat [checkbutton $tsf.chb1 -text "Gen Bat File" -variable gbatv]
set cpakv 0
set cpak [checkbutton $tsf.chb2 -text "Copy Package" -variable cpakv]
##$mo_sel insert end Work Recurse List
$mo_sel insert end "No bhv" "bhv"
set p_view [iwidgets::feedback $tsf.fb1 -labeltext "Generation Status" -barheight 10]
set statsVar ""
##set stat_txt [label $tsf.lb1 -textvariable statsVar]
set stat_txt [label .lb1 -textvariable statsVar]

pack $cpak -side left
pack $gbat -side left
pack $mo_sel -side left
pack $load_but -side left -padx 20
pack $p_view -side left
pack $tsf
pack $stat_txt -fill x

## create paned window
set win [iwidgets::panedwindow .pw -width 200 -height 300 ]
$win add top -margin 4 -minimum 100
$win add middle -margin 4 -minimum 100
$win configure -orient vertical
$win fraction 80 20
$win paneconfigure 1 -minimum 60
## create two locations for objects
set wtop [$win childsite 0]
set wbot [$win childsite 1]
pack $win -fill both -expand yes
## create two object boxes
set list_win [iwidgets::selectionbox $wtop.sb -margin 2 -itemscommand load_ent_file \
    -itemslabel "VHDL Files" -selectionlabel "Selected VHDL File"]
set view_win [iwidgets::scrolledtext $wbot.rts -borderwidth 2 -wrap none]
pack $list_win -fill both -expand yes
pack $view_win -fill both -expand yes

set aboutb [button .abb1 -text "About" -command show_about]
pack $aboutb -anchor s
##  some tags for the view window
##$view_win tag configure highlite -background #a0b7ce
$view_win tag configure highlite -background grey80

###########################################################################
##  some debug and help procs
##    Message Error, terminate
proc msg_error { msg } {
  tk_messageBox -message $msg -type ok
  exit
}
###########################################################################
##  Message, continue
proc dbg_msg { msg } {
  tk_messageBox -message $msg -type ok
}
#########################################################################
##  browse and get directory
##    Using extfileselectiondialog get a directory and update the
##    field passed to it
proc browsed_from_set { src dest } {
    set wdir [$src get]
    if {$wdir == ""} {
        iwidgets::extfileselectiondialog .dsb -modality application -fileson false
    } else {
        iwidgets::extfileselectiondialog .dsb -modality application -fileson false \
        -directory $wdir
    }

  if {[.dsb activate]} {
      set dchoice [.dsb get]
      $dest configure -state normal
      $dest delete 0 end
      $dest insert 0 "$dchoice"
      $dest configure -state readonly
  }
  destroy .dsb
}
#########################################################################
##  browse and get file name
##    Using extfileselectiondialog get a directory and update the
##    field passed to it
proc browse_set_entry { dest } {
iwidgets::extfileselectiondialog .dsb -modality application

  if {[.dsb activate]} {
      set dchoice [.dsb get]
      $dest configure -state normal
      $dest delete 0 end
      $dest insert 0 "$dchoice"
      $dest configure -state readonly
  }
  destroy .dsb
}
##########################################################################
##  proc pars_pindef
proc pars_pindef { pins } {

    set pdef  {}

    foreach l $pins {
        set mps {}

        set pdirection ""
        set spin [split $l ":"]
        ## if multi pin def
        if {[string first "," [lindex $spin 0]] > 0} {
            set mpins [split [lindex $spin 0] ","]
            foreach p $mpins {
                lappend mps [string trim $p]
            }
        } else {
            set mps [string trim [lindex $spin 0]]
        }

     #puts $mps
        set ptype_str {}

        set pdirection_str [string trim [lindex $spin 1]]
        #puts $pdirection_str
        set p_valid 1
        ## parce out the direction, supporting only 3
        if {[string first "inout" $pdirection_str] == 0} {
            set pdirection "inout"
            set ptype_str [string trim [string range $pdirection_str 5 end]]
            #puts $ptype_str
        } elseif {[string first "in" $pdirection_str] == 0} {
            set pdirection "in"
            set ptype_str [string trim [string range $pdirection_str 2 end]]
            #puts $ptype_str
        } elseif {[string first "out" $pdirection_str] == 0} {
            set pdirection "out"
            set ptype_str [string trim [string range $pdirection_str 3 end]]
            #puts $ptype_str
        } elseif {$pdirection == ""} {
            set p_valid 0
	        set ptype_str {}
            #puts $l
            #dbg_msg "Unsuported Pin direction found. \n Suported are IN OUT and INOUT."
        }
	    ## check for and remove extra )'s
	    set len [string length $ptype_str]
	    #puts $len
	    set len [expr $len - 2]
	    #puts $len
	    set tb [string first "(" $ptype_str]
	    if {$tb >= 0} {
		    set tb [string first "))" $ptype_str]
		    if {$tb >= 0} {
			    set tmp_str [string range $ptype_str 0 $len]
			    set ptype_str $tmp_str
		    }
	    } else {
		    set tb [string first ")" $ptype_str]
		    if {$tb >= 0} {
			    set tmp_str [string range $ptype_str 0 $len]
			    set ptype_str $tmp_str
		    }
	    }
        ## if we have a valid pin def add one or more
        if {$p_valid == 1} {
            foreach p $mps {
                set def {}
                lappend def $p $pdirection $ptype_str
                lappend pdef $def
            }
        }
    }
    #puts $pdef
#    lappend pdef $pname $pdirection $ptype
    return $pdef
}
##  end pars_pindef

##########################################################################
##  proc pars_gendef
proc pars_gendef { gens } {

    set gdef  {}
    foreach l $gens {
        set mgs {}
        set sgen [split $l ":"]
        ## if multi gen def
        if {[string first "," [lindex $sgen 0]] > 0} {
            set mgens [split [lindex $sgen 0] ","]
            foreach p $mgens {
                lappend mgs [string trim $p]
            }
        } else {
            set mgs [string trim [lindex $sgen 0]]
        }
        #puts $mgs
        set gtype_str [string trim [lindex $sgen 1]]
        foreach p $mgs {
           set def {}
           lappend def $p $gtype_str
           lappend gdef $def
        }
    }
    #puts $gdef
    return $gdef
}
##  end pars_gendef

##--------------------------------------------------------------------------------
##  Write header to file passed
proc write_header { handle } {
    global version
    ##global scan_date
    set raw_date [clock scan now]
    set scan_date [clock format $raw_date -format "%d %b %Y %T"]

    ## so CVS will not modify selections, they have to be chopped up
    set auth "-- \$Auth"
    append auth "or:  \$"
    set cvs_date "-- \$dat"
    append cvs_date "e:  \$"
    set cvs_name "-- \$Nam"
    append cvs_name "e:  \$"
    set cvs_id "-- \$I"
    append cvs_id "d:  \$"
    set cvs_source "-- \$Sour"
    append cvs_source "ce:  \$"
    set cvs_log "-- \$Lo"
    append cvs_log "g:  \$"

    puts $handle "-------------------------------------------------------------------------------"
    puts $handle "--             Copyright -----------------------------------"
    puts $handle "--                        All Rights Reserved"
    puts $handle "-------------------------------------------------------------------------------"
    puts $handle "$auth"
    puts $handle "--"
    puts $handle "$cvs_date"
    puts $handle "--"
    puts $handle "$cvs_id"
    puts $handle "--"
    puts $handle "$cvs_source"
    puts $handle "--"
    puts $handle "-- Description :"
    puts $handle "--          This file was generated by TTB Gen Plus $version"
    puts $handle "--            on $scan_date"
    puts $handle "------------------------------------------------------------------------------"
    puts $handle "-- This software contains concepts confidential to ----------------"
    puts $handle "-- ---------. and is only made available within the terms of a written"
    puts $handle "-- agreement."
    puts $handle "-------------------------------------------------------------------------------"
    puts $handle "-- Revision History:"
    puts $handle "$cvs_log"
    puts $handle "--"
    puts $handle "-------------------------------------------------------------------------------"
    puts $handle ""
  }

##########################################################################
## write Library and use statements
proc write_lib_statements { handle } {
    puts $handle "library IEEE;"
    puts $handle "--library tb_pkg;"
    puts $handle "--possible users libs;"
    puts $handle "use IEEE.STD_LOGIC_1164.all;"
    puts $handle "use IEEE.STD_LOGIC_ARITH.all;"
    puts $handle "use std.textio.all;"
    puts $handle "use work.tb_pkg.all;"
    puts $handle "--possible users use statement;"
    puts $handle "--library synthworks;"
    puts $handle "--  use SynthWorks.RandomBasePkg.all; "
    puts $handle "--  use SynthWorks.RandomPkg.all;"
    puts $handle ""
}

#####################################################################
##  A directory has been selected now fill the list win with VHDL files
proc fill_list {} {
    global ent_dir odir
    global tlist_ent use_list list_win ts_ent statsVar
    global view_win mo_sel

    ## get the user selection
    browsed_from_set $ent_dir $ent_dir
    ## as a default make output dir = input dir
    set tmp_dir [$ent_dir get]
    $odir delete 0 end
    $odir insert end $tmp_dir
    $odir configure -state readonly

    ## clear the list window and selection
    $list_win clear items
    $list_win clear selection
    $view_win clear
    ## get the working directory
    set dir [$ent_dir get]
    ## get the list of VHDL files in working directory
    set ftype ".vhd*"
    set file_lst ""
    set file_lst [glob -directory $dir *$ftype]

##puts $file_lst

    ##  for each of the files in the file_lst
    foreach l $file_lst {
        ## creat string that is just the file name: no path
        set testt $l
        set nstart [string last "/" $l]
        incr nstart
        set name_str [string range $l $nstart end]
        ## insert item on list
        $list_win insert items 1 $name_str
    }
}

######################################################################
##  load the vhdl file that has just been selected from list_win
proc load_ent_file {} {
    global ent_dir list_win view_win statsVar

    ## update selection with selected item
    $list_win selectitem
    set sel_dx [$list_win curselection]
    if {$sel_dx == ""} {
        return
    }
    ## recover the selected item
    set ln [$list_win get]
    ##  Get the working directory
    #puts $ln
    set lp [$ent_dir get]
    ##  append the file name
    append lp "/" $ln
    ## if the file does not exist  return
    set fexist [file exist $lp]
    if {$fexist == 0} {
        return
    }
    set ent_file [open $lp r]
    ## clear the view_win
    $view_win clear
    set file_list {}
    ## load file to memory
    while {![eof $ent_file]} {
        ##  Get a line
        set rline [gets $ent_file]
        lappend file_list $rline
    }
    close $ent_file
    ## put file in text window and highlite the entity part
    set ent_found 0
    set in_ent 0
    set statsVar ""
    foreach l $file_list {
        if {$in_ent == 0} {
            set ent_def [string first entity $l]
            set ent_is [string first is $l]
            if {$ent_def >= 0 && $ent_is >= 0} {
                set ent_name [lindex $l 1]
                set statsVar "Entity $ent_name found"
                set ent_found 1
                set in_ent 1
                $view_win insert end "$l\n" highlite
            } else {
                $view_win insert end "$l\n"
        }
    } else {
            set ent_def [string first "end $ent_name" $l]
            set ent2_def [string first "end\;" $l]
            if {$ent_def >= 0 || $ent2_def >= 0} {
                set end_name [lindex $l 1]
                set end_found 1
                set in_ent 0
                $view_win insert end "$l\n" highlite
            } elseif {[string first "end entity $ent_name" $l] >= 0} {
                set end_name [lindex $l 1]
                set end_found 1
                set in_ent 0
                $view_win insert end "$l\n" highlite
        } else {
                $view_win insert end "$l\n" highlite
        }
    }
    }
    if {$ent_found == 0} {
        set statsVar "No Entity found!!"
    }
    ##$view_win import $lp
    ##$view_win yview moveto 1
    ##puts $lp
}

#########################################################################
proc ttb_gen {} {
    global mo_sel template ent_dir list_win odir p_view tdir
    global cpakv gbatv

    set template [$tdir get]

    $p_view configure -steps 7
    $p_view reset
    ## recover the selected item
    set ln [$list_win get]
    ##  Get the working directory
    #puts $ln
    set lp [$ent_dir get]
    ##  append the file name
    append lp "/" $ln

    set path_text $lp
    set destin_text [$odir get]
    set infile [open $path_text r]
    set file_list list

    set tmpcnt 0

##################################################################
##  Read in the file and strip comments as we do
    while {![eof $infile]} {
        ##  Get a line
        set rline [gets $infile]
        ## get rid of white space
        set rline [string trim $rline]
        ##  Find comment if there
        set cindex [string first -- $rline]
        ## if a comment was found at the start of the line
        if {$cindex == 0 || $rline == ""} {
            set rline [string range $rline 0 [expr $cindex - 1]]
            ##dbg_msg $rline
            if {[llength $rline] > 0} {
                lappend file_list [string tolower $rline]
            }
        ## else was not found so put line in list
        } else {
            if {$cindex > 0} {
                #  get rid of trailing comments and trim off spaces
                set rline [string trim [string range $rline 0 $cindex-1]]
                ##puts $rline
            }
            lappend file_list [string tolower $rline]
        }
        incr tmpcnt
    }
    $p_view step
    ## collect the library statements
    foreach l $file_list {
        set libpos [string first library $l]
        if {$libpos >= 0} {
            lappend libs_list $l
        }
    }
    ## collect the use statements
    foreach l $file_list {
        set usepos [string first use $l]
        if {$usepos >= 0} {
            lappend use_list $l
        }
    }
    ## check for the entity def
    set ent_found 0
    foreach l $file_list {
        set ent_def [string first entity $l]
        if {$ent_def >= 0} {
            set ent_name [lindex $l 1]
            break
        }
    }
    ## if no ent  die
    if {$ent_def < 0} {
        dbg_msg "An entity definition was not found in the file provided."
        ##  exit
    }
    $p_view step
    ## check for end entity
    foreach l $file_list {
        lappend ent_list $l
        set end_def [string first end $l]
        if {$end_def >= 0} {
            set end_ent [string first "end $ent_name" $l]
            if {$end_ent >= 0} {
                break
            }
            set end_ent [string first "end\;" $l]
            if {$end_ent >= 0} {
                break
            }
            set end_ent [string first "end entity $ent_name" $l]
            if {$end_ent >= 0} {
                break
            }
        }
    }
    ## if no end die
    if {$end_def < 0} {
        dbg_msg "no end statement found for this entity"
        ##  exit
    }

    ####
    ## collect the generic if there is one.
    set generic_list {}
    set generic_found 0
    foreach l $ent_list {
        if {$generic_found == 0} {
            set gfound [string first generic $l]
            if {$gfound >= 0} {
                set generic_found 1
                set line_test [split $l "("]
                if {[llength $line_test] > 1} {
                    set generic_list [lindex $line_test 1]
                }
            }
        } elseif {[string first ");" $l]} {
            set line_test [split $l ")"]
            if {[llength $line_test] > 1} {
                append generic_list [lindex $line_test 0]
            }
            break
        } else {
            append generic_list $l
        }
    }
    ## split into a list
    if {$generic_found == 1} {
        set generic_list [split $generic_list ";"]
    }
    ##puts $generic_list
    set gen_lst [pars_gendef $generic_list]

    set port_found 0
    ####################################################################
    ##  a few checks have been done, and non-relevant stuff stripped off.
    ##  now create an arrry of just the pin names and related info
    set port_list {}
    foreach l $ent_list {
        ## look for the port statement
        #  get rid of comments and trim off spaces
        ##set cs [split $l "--"]
        ##set l [string trim [lindex $cs 0]]
        if {$port_found == 0} {
            set pfound [string first port $l]
            ## found one now check if there is a pin def in the same line
            if {$pfound >= 0} {
                set port_found 1
                set efound [string first : $l]
                if {$efound >= 0} {
                    set line_test [split $l "("]
                    if {[llength $line_test] > 1} {
                        ## first port so set
                        set port_list [lindex $line_test 1]
                    }
                }
            }
        } else {
            append port_list $l
        }
    }
    ##puts $port_list
    set port_list [split $port_list ";"]
    ##puts $port_list
    ##  Change the port list into a pin info list
    set split_pin [pars_pindef $port_list]

    # dbg_msg $split_pin
    ## calculate the longest pin name in characters
    set name_length 0
    foreach l $split_pin {
        set temp_length [string length [lindex $l 0]]
        if {$temp_length > $name_length} {
            set name_length $temp_length
        }
    }
    #dbg_msg $name_length
    ##  Make the name length one bigger
    incr name_length

    $p_view step
#########################################################################
## Generate the test bench entity.
    ##  Create the file name
    set file_type "_tb_ent.vhd"
    set ent_file_name $destin_text
    append ent_file_name "/" $ent_name $file_type
    #  dbg_msg $ent_file_name
    ## Create the tb entity name
    set tb_ent_name $ent_name
    set tb_sufix "_tb"
    append tb_ent_name $tb_sufix

    ## open and write the header
    set ent_file [open $ent_file_name w+]
    write_header $ent_file

    ## write out Library and use statements
    write_lib_statements $ent_file

    puts $ent_file "entity $tb_ent_name is"
    puts $ent_file "   generic ("
    puts $ent_file "            stimulus_file: in string"
    puts $ent_file "           )\;"
    puts $ent_file "   port ("

    ##-----------------------------------------
    #  for each pin in the list output the TB ent pin
    set plist_size [llength $split_pin]
    #dbg_msg $plist_size
    set i 1
    foreach l $split_pin {
        set pdirection [lindex $l 1]
        #  puts $pdirection
        ## switch on the source pin direction
        switch -exact $pdirection {
            "in" {set tb_ptype "buffer"}
            "out" {set tb_ptype "in"}
            "inout" {set tb_ptype "inout"}
            default {
                msg_error "Should have not got here .. pin direction in entity creation!!"
            }
        }
        ## creat some formats for appending
        set new_pname [format "         %-${name_length}s" [lindex $l 0]]
        set new_ptype [format ": %-8s" $tb_ptype]
        if {$i != $plist_size} {
            append new_pname $new_ptype [lindex $l 2] ";"
        } else {
            append new_pname $new_ptype [lindex $l 2]
        }
        puts $ent_file $new_pname
        incr i
    }

    puts $ent_file "        )\;"
    puts $ent_file "end $tb_ent_name;"
    close $ent_file

    $p_view step
##################################################################
##  Generate the top level test bench entity
    ##  Create the file name
    set file_type "_ttb_ent.vhd"
    set ent_file_name $destin_text
    append ent_file_name "/" $ent_name $file_type
    # dbg_msg $ent_file_name
    ## Create the tb entity name
    set ttb_ent_name $ent_name
    set ttb_sufix "_ttb"
    append ttb_ent_name $ttb_sufix

    ## open and write the header
    set ttb_ent_file [open $ent_file_name w+]
    write_header $ttb_ent_file

    puts $ttb_ent_file "library IEEE;"
    puts $ttb_ent_file "--library dut_lib;"
    puts $ttb_ent_file "use IEEE.STD_LOGIC_1164.all;"
    puts $ttb_ent_file "--use dut_lib.all;"
    puts $ttb_ent_file ""
    puts $ttb_ent_file "entity $ttb_ent_name is"
    puts $ttb_ent_file "  generic ("
    puts $ttb_ent_file "           stimulus_file: string := \"stm/stimulus_file.stm\""
    puts $ttb_ent_file "          )\;"
    puts $ttb_ent_file "end $ttb_ent_name\;"

    close $ttb_ent_file

    $p_view step
#################################################################
## Generate the top level structure
    ##  Create the file name
    set file_type "_ttb_str.vhd"
    set str_file_name $destin_text
    append str_file_name "/" $ent_name $file_type
    # dbg_msg $ent_file_name
    ## Create the tb entity name
    set ttb_ent_name $ent_name
    set ttb_sufix "_ttb"
    append ttb_ent_name $ttb_sufix

    ## open and write the header
    set ttb_str_file [open $str_file_name w+]
    write_header $ttb_str_file

    puts $ttb_str_file ""
    puts $ttb_str_file "architecture struct of $ttb_ent_name is"
    puts $ttb_str_file ""
    puts $ttb_str_file "component $ent_name"
    ## if there is generic parts to entity
    if {$generic_found == 1} {
        set len [llength $gen_lst]
        set cnt 0
        puts $ttb_str_file "--  generic ("
        foreach g $gen_lst {
            incr cnt
            set gline "--           "
            append gline [lindex $g 0] " : " [lindex $g 1]
            if {$cnt != $len} {
                append gline "\;"
            }
            puts $ttb_str_file $gline
        }
        puts $ttb_str_file "--          )\;"
    }

    puts $ttb_str_file "  port ("
    ## put out the dut component def
    ###################################################
    #  for each pin in the list output the TB ent pin
    set i 1
    foreach l $split_pin {
        ## creat some formats for appending
        set new_pname [format "        %-${name_length}s" [lindex $l 0]]
        set new_ptype [format ": %-8s" [lindex $l 1]]
        if {$i != $plist_size} {
            append new_pname $new_ptype [lindex $l 2] ";"
        } else {
            append new_pname $new_ptype [lindex $l 2]
        }
        puts $ttb_str_file $new_pname
        incr i
    }
    puts $ttb_str_file "       )\;"
    puts $ttb_str_file "end component\;"

    puts $ttb_str_file ""
    puts $ttb_str_file "component $tb_ent_name"
    puts $ttb_str_file "  generic ("
    puts $ttb_str_file "           stimulus_file: in string"
    puts $ttb_str_file "          )\;"
    puts $ttb_str_file "  port ("
    ## put out the tb component def
    ####################################################
    #  for each pin in the list output the TB ent pin
    set i 1
    foreach l $split_pin {
        set pdirection [lindex $l 1]
#  dbg_msg $pdirection
        ## switch on the source pin direction
        switch -exact $pdirection {
            "in" {set tb_ptype "buffer"}
            "out" {set tb_ptype "in"}
            "inout" {set tb_ptype "inout"}
            default {
                msg_error "Should have not got here .. pin direction in entity creation!!"
            }
        }
        ## creat some formats for appending
        set new_pname [format "        %-${name_length}s" [lindex $l 0]]
        set new_ptype [format ": %-8s" $tb_ptype]
        if {$i != $plist_size} {
            append new_pname $new_ptype [lindex $l 2] ";"
        } else {
            append new_pname $new_ptype [lindex $l 2]
        }
        puts $ttb_str_file $new_pname
        incr i
    }
    puts $ttb_str_file "       )\;"
    puts $ttb_str_file "end component\;"
    puts $ttb_str_file ""

    puts $ttb_str_file "--for all: $ent_name    use entity dut_lib.$ent_name\(str)\;"
    puts $ttb_str_file "for all: $tb_ent_name    use entity work.$tb_ent_name\(bhv)\;"

    puts $ttb_str_file ""
    #####################################################
    #  for each pin in the list output the TB ent pin
    #     generate a signal name
    foreach l $split_pin {
        ## creat some formats for appending
        set new_pname [format "  signal temp_%-${name_length}s" [lindex $l 0]]
        append new_pname ": " [lindex $l 2] ";"
        puts $ttb_str_file $new_pname
    }

    puts $ttb_str_file ""
    puts $ttb_str_file "begin"
    puts $ttb_str_file ""
    puts $ttb_str_file "dut: $ent_name"
    ## if there is generic parts to entity
    if {$generic_found == 1} {
        set len [llength $gen_lst]
        set cnt 0
        puts $ttb_str_file "--  generic map("
        foreach g $gen_lst {
            incr cnt
            set gline "--           "
            append gline [lindex $g 0] " => "
            puts $ttb_str_file $gline
        }
        puts $ttb_str_file "--          )"
        dbg_msg "A generic map was generated for\nthe DUT, but commented out \
        \nThe user will have to complete\nthis section of the code in the\n \
        ttb_str file."
    }

    puts $ttb_str_file "  port map("
    ##-----------------------------------------
    #  for each pin in the list output the TB ent pin
    #     Generate port map for DUT
    set i 1
    foreach l $split_pin {
        ## creat some formats for appending
        set new_pname [format "           %-${name_length}s" [lindex $l 0]]
        if {$i != $plist_size} {
            append new_pname "=>  temp_" [lindex $l 0] ","
        } else {
            append new_pname "=>  temp_" [lindex $l 0]
        }
        puts $ttb_str_file $new_pname
        incr i
    }

    puts $ttb_str_file "          )\;"
    puts $ttb_str_file ""
    puts $ttb_str_file "tb: $tb_ent_name"
    puts $ttb_str_file "  generic map("
    puts $ttb_str_file "               stimulus_file => stimulus_file"
    puts $ttb_str_file "             )"
    puts $ttb_str_file "  port map("
    ##-----------------------------------------
    #  for each pin in the list output the TB ent pin
    #     Generate port map for DUT
    set i 1
    foreach l $split_pin {
        ## creat some formats for appending
        set new_pname [format "           %-${name_length}s" [lindex $l 0]]
        if {$i != $plist_size} {
            append new_pname "=>  temp_" [lindex $l 0] ","
        } else {
            append new_pname "=>  temp_" [lindex $l 0]
        }
        puts $ttb_str_file $new_pname
        incr i
    }

    puts $ttb_str_file "          )\;"
    puts $ttb_str_file ""
    puts $ttb_str_file "end struct\;"
    close $ttb_str_file

    ######################################################################
    ##  Now generate the bhv file from template

    if {[$mo_sel get] == "bhv"} {

        $p_view step
        set infile [open "$template"  r]

        while {![eof $infile]} {
            ##  Get a line
            set rline [gets $infile]
            lappend temp_file_list $rline
        }
        close $infile

        ## strip off the header
        set end_header 0
        foreach l $temp_file_list {
            set comment [string first -- $l]
            if {$comment < 0} {
                set end_header 1
            }
            ## if we found the end of the header
            if {$end_header == 1} {
                lappend template_list $l
            }
        }

        ## split the file into two peices, to the point of input initialization
        set i 1
        foreach l $template_list {
            ## check for parsing point
            set mid_point [string first parse_tb1 $l]
            if {$mid_point >= 0} {
                break
            }

            if {$i > 2} {
                lappend top_half $l
            }
            incr i
        }

        set found 0
        foreach l $template_list {
            if {$found == 1} {
                lappend bottom_half $l
            }
            ## check for parsing point
            set mid_point [string first parse_tb1 $l]
            if {$mid_point >= 0} {
            set found 1
            }
        }

        ##  Create the file name
        set file_type "_tb_bhv.vhd"
        set bhv_file_name $destin_text
        append bhv_file_name "/" $ent_name $file_type
        # dbg_msg $ent_file_name

        ## open and write the header
        set bhv_file [open $bhv_file_name w+]
        write_header $bhv_file

        puts $bhv_file ""
        puts $bhv_file "architecture bhv of $tb_ent_name is"
        puts $bhv_file ""
        foreach l $top_half {
            puts $bhv_file $l
        }

        puts $bhv_file ""
        ## now generate and write out input initialization
        foreach l $split_pin {
            set temp_def [lindex $l 1]
            set input_def [string first in $temp_def]
            if {$input_def >= 0} {
                set vector [string first vector $l]
                set init_def [format "    %-${name_length}s" [lindex $l 0]]
                if {$vector >= 0} {
                    append init_def "<=  (others => '0')\;"
                } else {
                    append init_def "<=  '0'\;"
                }
                puts $bhv_file $init_def
            }
        }
        puts $bhv_file ""
        ## now write out the bottem half and termination
        foreach l $bottom_half {
            puts $bhv_file $l
        }

        close $bhv_file
    }
    ## generate the
    if {$gbatv == 1} {
        set fn $destin_text
	append fn "\\build_tb.bat"
        set batf [open $fn w+]

        puts $batf "ECHO OFF"
        puts $batf ""
        puts $batf "vlib work"
        puts $batf "vcom -quiet tb_pkg_header.vhd tb_pkg_body.vhd"
        set str {}
        append str "vcom -2008 -quiet " $ent_name "_tb_ent.vhd " $ent_name "_tb_bhv.vhd"
        puts $batf $str
        set str {}
        append str "vcom -quiet " $ent_name "_ttb_ent.vhd " $ent_name "_ttb_str.vhd"
        puts $batf $str
        puts $batf ""

        close $batf
    }

    ## put out a terminating message for the user
    dbg_msg "Test bench files were generated in directory:\n $destin_text"
    $p_view step

    if {$cpakv == 1} {
##        set avail [file exists "../vhdl/tb_pkg_header.vhd"]
        set avail [file exists "../vhdl/tb_pkg_header.vhd"]
        if {$avail < 1} {
            dbg_msg "The package files are not located in the\n expected location. \nThey were not copied."
        }

        set dest $destin_text
        append dest "/tb_pkg_header.vhd"
        if {[file exists $dest] == 0} {
            file copy "../vhdl/tb_pkg_header.vhd" $dest
        }
        set dest $destin_text
        append dest "/tb_pkg_body.vhd"
        if {[file exists $dest] == 0} {
            file copy "../vhdl/tb_pkg_body.vhd" $dest
        }
    }
}
  ## end ttb_gen

##  show copy right and liability statement.
proc show_about {} {
    global version
    dbg_msg "ttb_gen Aplication version  $version\n
Copyright 2014 Ken Campbell\n
All Rights Reserved\n
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS\n
AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED\n
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED\n
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A\n
PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL\n
THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY\n
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR\n
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,\n
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF\n
USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)\n
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER\n
IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING\n
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE\n
USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE\n
POSSIBILITY OF SUCH DAMAGE."
}

## enable pop up console for debug
bind . <F12> {catch {console show}}
##catch {console show}
##-------------------------------------------------------------------------------
##-- Revision History:
##-- $Log: not supported by cvs2svn $
##--
##-- Jul 23 2011
##--     Fix trailing inline comments error.
##--     version now 2.02
##----------------------------------------------------------------------------
