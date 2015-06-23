# $Id: util.tcl 683 2015-05-17 21:54:35Z mueller $
#
# Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# This program is free software; you may redistribute and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 2, or at your option any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for complete details.
#
#  Revision History:
# Date         Rev Version  Comment
# 2015-05-17   683   1.3.4  setup_sys: add TM11
# 2015-05-15   682   1.3.3  BUGFIX: setup_cpu: fix cpu reset (now -stop -creset)
# 2015-05-08   675   1.3.2  w11a start/stop/suspend overhaul
# 2015-03-28   660   1.3.1  add setup_cntl
# 2015-03-21   659   1.3    setup_sys: add RPRM (later renamed to RHRP)
# 2015-01-09   632   1.2.3  setup_sys: use rlc set; setup_sys: add RL11
# 2014-07-26   575   1.2.2  run_pdpcp: add tout argument
# 2014-06-27   565   1.2.1  temporarily hide RL11
# 2014-06-08   561   1.2    setup_sys: add RL11
# 2014-03-07   553   1.1.3  move definitions to defs.tcl
# 2013-05-09   517   1.1.2  add setup_(tt|lp|pp|ostr) device setup procs
# 2013-04-26   510   1.1.1  split, asm* and tbench* into separate files
# 2013-04-01   501   1.1    add regdsc's and asm* procs
# 2013-02-02   380   1.0    Initial version
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {
  #
  # setup register descriptions for rw11 -------------------------------------
  #
  # rlink stat usage for rw11
  regdsc STAT   {cmderr 7} {cmdmerr 6} {cpususp 5} {cpugo 4} \
                {attn 3} {rbtout 2} {rbnak 1} {rberr 0}

  # check cmderr and rb(tout|nak|err) 
  variable STAT_DEFMASK [regbld rw11::STAT cmderr rbtout rbnak rberr]

  #
  # setup_cpu: create w11 cpu system -----------------------------------------
  # 
  proc setup_cpu {} {
    rlc set baseaddr 16
    rlc set basedata  8
    rlc set basestat  2
    rlink::setup;               # basic rlink defs
    rw11 rlw rls w11a 1;        # create 1 w11a cpu
    cpu0 cp -stop -creset;      # stop and reset CPU
    return ""
  }

  #
  # setup_sys: create full system --------------------------------------------
  # 
  proc setup_sys {} {
    if {[info commands rlw] eq ""} {
      setup_cpu
    }
    cpu0 add dl11
    cpu0 add dl11 -base 0176500 -lam 2
    cpu0 add rk11
    cpu0 add rl11
    cpu0 add rhrp
    cpu0 add tm11
    cpu0 add lp11
    cpu0 add pc11
    rlw start
    return ""
  }

  #
  # setup_tt: setup terminals ------------------------------------------------
  # 
  proc setup_tt {{cpu "cpu0"} {optlist {}}} {
    # process and check options
    array set optref { ndl 2 dlrlim 0 ndz 0 to7bit 0 app 0 nbck 1}
    rutil::optlist2arr opt optref $optlist

    # check option values
    if {$opt(ndl) < 1 || $opt(ndl) > 2} {
      error "ndl option must be 1 or 2"
    }
    if {$opt(ndz) != 0} {
      error "ndz option must be 0 (till dz11 support is added)"
    }

    # setup attach url options
    set urlopt "?crlf"
    if {$opt(app) != 0} {
      append urlopt ";app"
    }
    if {$opt(nbck) != 0} {
      append urlopt ";bck=$opt(nbck)"
    }

    # setup list if DL11 controllers
    set dllist {}
    lappend dllist "tta" "8000"
    if {$opt(ndl) == 2} {
      lappend dllist "ttb" "8001"
    }

    # handle DL11 controllers
    foreach {cntl port} $dllist {
      set unit "${cntl}0"
      ${cpu}${unit} att "tcp:?port=${port}"
      ${cpu}${unit} set log "tirri_${unit}.log${urlopt}"
      if {$opt(dlrlim) != 0} {
        ${cpu}${cntl} set rxrlim 7
      }
      if {$opt(to7bit) != 0} {
        ${cpu}${unit} set to7bit 1
      }
    }
    return ""
  }

  #
  # setup_ostr: setup Ostream device (currently lp or pp) --------------------
  # 
  proc setup_ostr {cpu unit optlist} {
    # process and check options
    array set optref { app 0 nbck 1}
    rutil::optlist2arr opt optref $optlist

    # setup attach url options
    set urloptlist {}
    if {$opt(app) != 0} {
      append urloptlist "app"
    }
    if {$opt(nbck) != 0} {
      append urloptlist "bck=$opt(nbck)"
    }
    set urlopt ""
    if {[llength $urloptlist] > 0} {
      append urlopt "?"
      append urlopt [join $urloptlist ";"]
    }

    # handle unit
    ${cpu}${unit} att "tirri_${unit}.dat${urlopt}"
    return ""
  }

  #
  # setup_lp: setup printer --------------------------------------------------
  # 
  proc setup_lp {{cpu "cpu0"} {optlist {}}} {
    # process and check options
    array set optref { nlp 1 app 0 nbck 1}
    rutil::optlist2arr opt optref $optlist
    if {$opt(nlp) != 0} {
      setup_ostr $cpu "lpa0" [list app $opt(app) nbck $opt(nbck)]
    }
  }
  #
  # setup_pp: setup paper puncher --------------------------------------------
  # 
  proc setup_pp {{cpu "cpu0"} {optlist {}}} {
    # process and check options
    array set optref { npc 1 app 0 nbck 1}
    rutil::optlist2arr opt optref $optlist
    if {$opt(npc) != 0} {
      setup_ostr $cpu "pp" [list app $opt(app) nbck $opt(nbck)]
    }
  }

  #
  # run_pdpcp: execute pdpcp type command file -------------------------------
  #
  proc run_pdpcp {fname {tout 10.} {cpu "cpu0"}} {
    rlc errcnt -clear
    set code [exec ticonv_pdpcp --tout=$tout $cpu $fname]
    eval $code
    set errcnt [rlc errcnt]
    if { $errcnt } {
      puts [format "run_pdpcp: FAIL after %d errors" $errcnt]
    }
    return $errcnt
  }

  #
  # setup_cntl: setup a controller (used for I/O test benches) ---------------
  #
  proc setup_cntl {cpu ctype cname} {
    if {![rlw get started]} {   # start rlw, if needed
      rlw start
      rls server -stop
    }

    set ccmd ${cpu}${cname};    # build controller command
    if {[info commands $ccmd] eq ""} { # create controller, if needed
      $cpu add $ctype
    }
    if {![$ccmd get started]} { # start it, if needed
      $ccmd start
    }
    return ""
  }

}
