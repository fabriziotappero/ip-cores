#! /usr/bin/env wish
##-------------------------------------------------------------------------------
##                     Copyright 2014 Ken Campbell
##
##   Licensed under the Apache License, Version 2.0 (the "License");
##   you may not use this file except in compliance with the License.
##   You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
##   Unless required by applicable law or agreed to in writing, software
##   distributed under the License is distributed on an "AS IS" BASIS,
##   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##   See the License for the specific language governing permissions and
##   limitations under the License.
##-------------------------------------------------------------------------------
##-- $Author:  $ Ken Campbell
##--
##-- $Date:  $ June 26 2014
##--
##-- $Id:  $
##--
##-- $Source:  $
##--
##-- Description :
##--      This application takes a text file containing the definition of a Verilog
##           module, produces a file set for the SV Directed Test Bench.
##--
##------------------------------------------------------------------------------

## package requires
package require Iwidgets 4.0

## set the current version info
set version "Beta 1.0"
## put up a title on the main window boarder
wm title . "SV TB Gen $version"

## the location of the template by default
set template "./tb_mod_template.sv"

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
#set gbat [checkbutton $tsf.chb1 -text "Gen Build Script" -variable gbatv]
set cpakv 0
#set cpak [checkbutton $tsf.chb2 -text "Copy Package" -variable cpakv]
##$mo_sel insert end Work Recurse List
$mo_sel insert end "No mod" "Gen mod"
set p_view [iwidgets::feedback $tsf.fb1 -labeltext "Generation Status" -barheight 10]
set statsVar ""
##set stat_txt [label $tsf.lb1 -textvariable statsVar]
set stat_txt [label .lb1 -textvariable statsVar]

##   about button
button $tsf.bout1 -text "About" -command show_about

#pack $cpak -side left
#pack $gbat -side left
pack $mo_sel -side left
pack $load_but -side left -padx 20
pack $p_view -side left
pack $tsf.bout1 -side right
pack $tsf -fill x
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
    -itemslabel "SV Files" -selectionlabel "Selected SV File"]
set view_win [iwidgets::scrolledtext $wbot.rts -borderwidth 2 -wrap none]
pack $list_win -fill both -expand yes
pack $view_win -fill both -expand yes

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
    set def_lst  {}
    set lc 0

    set logic_lst {}
    set dut_modport {}
    set names_lst {}

    foreach l $pins {
        set is_mult [string first "," $l]
        set is_bv   [string first "\[" $l]
        set l [string trim $l "\;"]
        ##  if is a vector def
        #puts $l
        #puts "is_bv:  $is_bv"
        if {$is_bv > 0} {
            set is_cbv [string first "\]" $l]
            set bv_spec [string range $l $is_bv $is_cbv]
            set type [string range $l 0 $is_bv-1]
            set names [string range $l $is_cbv+1 end]
            set snames [split $names ","]
            foreach n $snames {
                ##set n [string trim $n "\;"]
                lappend names_lst [string trim $n]
                if {$type != "inout"} {
                    set tmp "logic "
                } else {
                    set tmp "wire "
                }
                append tmp $bv_spec " [string trim $n]\;"
                lappend logic_lst $tmp
                set tmp [string trim $type]
                append tmp " [string trim $n],"
                lappend dut_modport $tmp
                #puts "$type $bv_spec [string trim $n]\;"
            }
        } else {
            set sl [split $l ","]
            set frst [split [lindex $sl 0]]
            set type [string trim [lindex $frst 0]]
            set fname [string trim [lindex $frst end]]
            set sl [lrange $sl 1 end]
            lappend names_lst [string trim $fname]
            if {$type != "inout"} {
                set tmp "logic "
            } else {
                set tmp "wire "
            }
            #set tmp "logic "
            append tmp "$fname\;"
            lappend logic_lst $tmp
            set tmp $type
            append tmp " $fname,"
            lappend dut_modport $tmp
            foreach n $sl {
                lappend names_lst [string trim $n]
                if {$type != "inout"} {
                    set tmp "logic "
                } else {
                    set tmp "wire "
                }
                append tmp "[string trim $n]\;"
                lappend logic_lst $tmp
                set tmp $type
                append tmp " [string trim $n],"
                lappend dut_modport $tmp
            }
        }
    }

    lappend def_lst $logic_lst
    lappend def_lst $dut_modport
    lappend def_lst $names_lst

    return $def_lst
}
##  end pars_pindef

##--------------------------------------------------------------------------------
##  Write header to file passed
proc write_header { handle } {
    global version
    ##global scan_date
    set raw_date [clock scan now]
    set scan_date [clock format $raw_date -format "%d %b %Y %T"]

    ## so CVS will not modify selections, they have to be chopped up
    set auth "// \$Auth"
    append auth "or:  \$"

    puts $handle "///////////////////////////////////////////////////////////////////////////////"
    puts $handle "//             Copyright ///////////////////////////////////"
    puts $handle "//                        All Rights Reserved"
    puts $handle "///////////////////////////////////////////////////////////////////////////////"
    puts $handle "$auth"
    puts $handle "//"
    puts $handle "//"
    puts $handle "// Description :"
    puts $handle "//          This file was generated by SV TB Gen $version"
    puts $handle "//            on $scan_date"
    puts $handle "//////////////////////////////////////////////////////////////////////////////"
    puts $handle "// This software contains concepts confidential to ////////////////"
    puts $handle "// /////////. and is only made available within the terms of a written"
    puts $handle "// agreement."
    puts $handle "///////////////////////////////////////////////////////////////////////////////"
    puts $handle ""
  }

#####################################################################
##  A directory has been selected now fill the list win with *V files
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
    set ftype ".*v"
    set file_lst ""
    set file_lst [glob -directory $dir *$ftype]

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
            set ent_def [string first module $l]
            if {$ent_def >= 0} {
                set ent_name [lindex $l 1]
                set statsVar "Module:  $ent_name found"
                set ent_found 1
                set in_ent 1
                $view_win insert end "$l\n" highlite
            } else {
                $view_win insert end "$l\n"
        }
    } else {
        set ent_def [string first "endmodule" $l]
        if {$ent_def >= 0} {
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
        set statsVar "No Module found!!"
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
    set file_list {}


##################################################################
##  Read in the file and strip comments as we do
    while {![eof $infile]} {
        ##  Get a line
        set rline [gets $infile]
        #puts $rline
        ## get rid of white space
        set rline [string trim $rline]
        ##  Find comment if there
        set cindex [string first "//" $rline]
        ## if a comment was found at the start of the line
        if {$cindex == 0 || $rline == ""} {
            continue
        ## else was not found so put line in list
        } elseif {$cindex > 0} {
            #  get rid of trailing comments and trim off spaces
            set rline [string trim [string range $rline 0 $cindex-1]]
            lappend file_list $rline
        } else {
            lappend file_list $rline
        }
    }
    close $infile

    $p_view step
    ## check for the module def
    set mod_name ""
    foreach l $file_list {
        set mod_def [string first module $l]
        if {$mod_def >= 0} {
            set ml [split $l]
            set mod_name [lindex $l 1]
            break
        }
    }

    #puts "Module name is: $mod_name"
    ## if no ent  die
    if {$mod_def < 0} {
        dbg_msg "A module definition was not found in the file provided."
        return
        ##  exit
    }
    $p_view step
    set mod_list {}
    ## check for end module
    foreach l $file_list {
        lappend mod_list $l
        set end_def [string first endmodule $l]
        if {$end_def >= 0} {
            break
        }
    }
    ## if no end die
    if {$end_def < 0} {
        dbg_msg "no endmodule statement found for this module"
        return
        ##  exit
    }
    ####
    ## collect the parameters if there are.
    set parameter_list {}
    set p_found 0
    foreach l $mod_list {
        set p_found [string first "parameter" $l]
        if {$p_found >= 0} {
            lappend $parameter_list $l
        }
    }

    #foreach l $mod_list {
    #    puts $l
    #}
    ####################################################################
    ##  a few checks have been done, and non-relevant stuff stripped off.
    ##  now create an arrry of just the pin names and related info
    set port_lst {}
    set lc 0
    foreach l $mod_list {
        ## make lines that are continued, one line.
        set cont [string first "\;" $l]
        if {$cont < 0 && $lc == 0} {
            set tmp $l
            set lc 1
            continue
        } elseif {$cont < 0 && $lc == 1} {
            append tmp $l
            continue
        } elseif {$lc == 1} {
            append tmp $l
            set lc 0
            set l $tmp
        }

        ## look for the port statements
        set inp [string first "input" $l]
        if {$inp >= 0} {
            lappend port_lst $l
        }
        set onp [string first "output" $l]
        if {$onp >= 0} {
            lappend port_lst $l
        }
        set ionp [string first "inout" $l]
        if {$ionp >= 0} {
            lappend port_lst $l
        }
    }

    #foreach p $port_lst {
    #    puts $p
    #}
    ##  Change the port list into a pin info list
    set io_pins [pars_pindef $port_lst]

    set log_lst [lindex $io_pins 0]
    set mod_lst [lindex $io_pins 1]
    set name_lst [lindex $io_pins 2]

    #foreach r $log_lst {
    #    puts $r
    #}
    #foreach r $mod_lst {
    #    puts $r
    #}
    #foreach r $name_lst {
    #    puts $r
    #}


    # dbg_msg $split_pin
    ## calculate the longest pin name in characters
    set name_length 0
    foreach l $name_lst {
        set temp_length [string length $l]
        if {$temp_length > $name_length} {
            set name_length $temp_length
        }
    }
    #dbg_msg $name_length
    ##  Make the name length one bigger
    incr name_length

    $p_view step
#########################################################################
## Generate the tb top.
    set tfn $destin_text
    append tfn "/tb_top.sv"
    set tfh [open $tfn w]

    write_header $tfh
    puts $tfh "`include \"../sv/tb_prg.sv\""
    puts $tfh ""
    puts $tfh "module tb_top \(\)\;"
    puts $tfh ""
    puts $tfh "  string STM_FILE = \"../stm/stimulus_file.stm\"\;"
    puts $tfh "  string tmp_fn"
    puts $tfh ""
    puts $tfh "  //  Handle plus args"
    puts $tfh "  initial begin : file_select"
    puts $tfh "    if\(\$value\$plusargs\(\"STM_FILE=%s\", tmp_fn\)\) begin"
    puts $tfh "      stm_file = tmp_fn\;"
    puts $tfh "    end"
    puts $tfh "  end"
    puts $tfh ""
    puts $tfh "  dut_if theif\(\)\;"
    puts $tfh ""
    puts $tfh "  $mod_name u1 \("

    set llen [llength $name_lst]
    set idx 1
    foreach n $name_lst {
        set ln $n
        set len [string length $ln]
        while {$len < $name_length} {
            append ln " "
            set len [string length $ln]
        }
        if {$idx < $llen} {
            puts $tfh "    .$ln \(theif.$n\),"
        } else {
            puts $tfh "    .$ln \(theif.$n\)"
        }
        incr idx
    }

    puts $tfh "  \)\;"
    puts $tfh ""
    puts $tfh "  tb_mod prg_inst\(theif\)\;"
    puts $tfh ""
    puts $tfh "endmodule"

    close $tfh
############################################################################
##  generate the interface file.
    set ifn $destin_text
    append ifn "/dut_if.sv"
    set ifh [open $ifn w]

    write_header $ifh
    puts $ifh "interface dut_if\(\)\;"
    puts $ifh ""
    foreach l $log_lst {
        puts $ifh "  $l"
    }

    puts $ifh ""
    puts $ifh "  modport dut_conn\("
    set llen [llength $mod_lst]
    set idx 1
    foreach p $mod_lst {
        if {$idx < $llen} {
            puts $ifh "    $p"
        } else {
            puts $ifh "    [string trim $p ","]"
        }
        incr idx
    }
    puts $ifh "  \)\;"
    puts $ifh ""
    puts $ifh "  modport tb_conn\("
    set idx 1
    foreach p $mod_lst {
        set in [string first "input" $p]
        set out [string first "output" $p]
        if {$in >= 0} {
            set type "output  "
        } elseif {$out >= 0} {
            set type "input   "
        } else {
            set type "inout   "
        }

        set sp [split $p]
        if {$idx < $llen} {
            puts $ifh "    $type [lindex $sp end]"
        } else {
            puts $ifh "    $type [string trim [lindex $sp end] ","]"
        }
        incr idx
    }
    puts $ifh "  \)\;"
    puts $ifh ""
    puts $ifh "endinterface"
    close $ifh

##########################################################################
##   generate the tb_prg  file from template.
    set prg_gen [$mo_sel get]
    if {$prg_gen == "No mod"} {
		    return
		}
    set tpl_fh [open $template r]
    set tpl_lst {}
    set hfound 0
    while {![eof $tpl_fh]} {
        set rline [gets $tpl_fh]
        if {$hfound == 0} {
            set head [string first ">>header" $rline]
            if {$head == 0} {
                set hfound 1
            }
        } else {
            lappend tpl_lst $rline
        }
    }

    #foreach l $tpl_lst {
    #    puts  $l
    #}

    set pfn $destin_text
    append pfn "/tb_mod.sv"
    set pfh [open $pfn w]

    set idx 0
    foreach l $tpl_lst {
        set ent_pt [string first ">>insert sigs" $l]
        if {$ent_pt == 0} {
            set tpl_lst [lreplace $tpl_lst $idx $idx]
            foreach l $log_lst {
                set tpl_lst [linsert $tpl_lst $idx "  $l"]
                incr $idx
            }
            break
        }
        incr idx
    }

    set idx 0
    foreach l $tpl_lst {
        set ent_pt [string first ">>drive sigs" $l]
        if {$ent_pt == 0} {
            set tpl_lst [lreplace $tpl_lst $idx $idx]
            set midx 0
            foreach l $name_lst {
                set dir [lindex $mod_lst $midx]
                #puts $dir
                set idir [string first "input" $dir]
                if {$idir >= 0} {
                    set tmp "  assign tif."
                    append tmp "$l = $l\;"
                    set tpl_lst [linsert $tpl_lst $idx $tmp]
                } else {
                    set tmp "  assign $l"
                    append tmp " = tif.$l\;"
                    set tpl_lst [linsert $tpl_lst $idx $tmp]
                }
                incr idx
                incr midx
            }
            break
        }
        incr idx
    }

    write_header $pfh
    #foreach l $tpl_lst {
    #    puts $pfh $l
    #}

    close $pfh
}
## end ttb_gen
#################################################
##  show  about message
proc show_about {} {
    global version
		
		set msg "Copyright 2014 Ken Campbell\n
Version $version\n
Licensed under the Apache License, Version 2.0 (the \"License\"); You may not use this file except in compliance with the License. You may obtain a copy of the License at\n
http://www.apache.org/licenses/LICENSE-2.0\n
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License."

    dbg_msg $msg
}

## enable pop up console for debug
bind . <F12> {catch {console show}}
