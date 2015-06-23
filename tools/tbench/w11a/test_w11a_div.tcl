# $Id: test_w11a_div.tcl 683 2015-05-17 21:54:35Z mueller $
#
# Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2014-07-27   575   1.0.2  drop tout value from asmwait, reply on asmwait_tout
# 2014-07-20   570   1.0.2  add rw11::div_show_test; test late div quit cases
# 2014-07-12   569   1.0.1  move sxt16/32 to rutil
# 2014-07-11   568   1.0    Initial version
# 2014-06-29   566   0.1    First draft
#
# Test div instruction
#

namespace eval rw11 {

  #
  # div_simh: calculate expected division result as pdp11 simh does it -------
  #
  # this pdp11 div emulation adopted from pdp11_cpu.c  (git head 2014-06-09)
  proc div_simh {ddi dri} {
    set src2 $dri
    set src  $ddi
    set qd   [expr ($ddi>>16) & 0xffff];     # w11a  default for V=1 bailouts
    set rd   [expr $ddi & 0xffff];           # "
    set n    [expr {($ddi<0) ^ ($dri<0)}];   # "
    set z    0;                              # "

    # quit if divident larger than possible 16 bit signed products
    if {$src > 1073774591 || $src < -1073741823} {
      return [list $qd $rd $n $z 1 0]
    }
    # quit if divisor zero
    if {$src2 == 0} {
      return [list $qd $rd $n $z 1 1]
    }

    if {$src2 & 0x8000} {
      set src2 [expr $src2 | ~ 077777]
    }
    if {$src  & 0x80000000} {
      set src  [expr $src  | ~ 017777777777]
    }

    # Tcl "/" uses 'round down' sematics, while C (and PDP11) 'round to 0'
    #   ddi dri   Tcl         C/C++ 
    #    34   5   q= 6 r= 4   q= 6 r= 4
    #    34  -5   q= 7 r=-1   q=-6 r= 4
    #   -34   5   q=-7 r= 1   q=-6 r=-4
    #   -34  -5   q= 6 r=-4   q= 6 r=-4
    #   Tcl --> r same sign as divisor
    #   C   --> r same sign as divident
    #   so add correction step to always get C/C++/PDP11 divide semantics
    #
    set q  [expr $src / $src2]
    set r  [expr ($src - ($src2 * $q))]

    if {$r!=0 && (($src<0) ^ ($r<0))} {    # divident and remainder diff sign 
      set r [expr $r - $src2]
      set q [expr $q + (($q<0)?1:-1)]
    }

    if {($q > 32767) || ($q < -32768)} {
      return [list $qd $rd $n $z 1 0]
    }

    set n [expr {$q < 0}]
    set z [expr {$q == 0}]
    return [list $q $r $n $z 0 0]
  }

  #
  # div_testd3: test division ddh,ddl,,dr + expected result ------------------
  #
  proc div_testd3 {cpu symName ddh ddl dr q r n z v c} {
    upvar 1 $symName sym
    set nzvc [expr {($n<<3) | ($z<<2) | ($v<<1) | $c}]
    set dr16 [expr {$dr & 0xffff}]
    set  q16 [expr {$q  & 0xffff}]
    set  r16 [expr {$r  & 0xffff}]

    # use rw11::div_show_test to enable generation of divtst files
    if {[info exists rw11::div_show_test] && $rw11::div_show_test} {
      set ddi [expr (($ddh&0xffff)<<16) + ($ddl&0xffff)]
      set ddi [rutil::sxt32 $ddi]
      set dri [rutil::sxt16 $dr16]
      set qi  [rutil::sxt16 $q16]
      set ri  [rutil::sxt16 $r16]
      puts [format "%06o %06o %06o : %d%d%d%d %06o %06o # %11d/%6d:%6d,%6d" \
                   $ddh $ddl $dr16 $n $z $v $c $q16 $r16 $ddi $dri $qi $ri ]
    }

    rw11::asmrun  $cpu sym [list r0 $ddh r1 $ddl r2 $dr16]
    rw11::asmwait $cpu sym 

    if {!$v && !$c} {           # test q and r only when V=0 C=0 expected
      lappend treglist r0 $q16 r1 $r16
    }
    lappend treglist r3 $nzvc

    set errcnt [rw11::asmtreg $cpu $treglist]

    if {$errcnt} {
      puts [format \
            "div FAIL: dd=%06o,%06o dr=%06o exp: q=%06o r=%06o nzvc=%d%d%d%d" \
            $ddh $ddl $dr16 $q16 $r16 $n $z $v $c]
    }
    return $errcnt
  }

  #
  # div_testd2: test division dd,dr + expected result ------------------------
  #
  proc div_testd2 {cpu symName dd dr q r n z v c} {
    upvar 1 $symName sym
    set ddh [expr {($dd>>16) & 0xffff}]
    set ddl [expr { $dd      & 0xffff}]
    return [div_testd3 $cpu sym $ddh $ddl $dr $q $r $n $z $v $c]
  }

  #
  # div_testdqr: test division, give divisor, quotient and remainder ---------
  #
  proc div_testdqr {cpu symName dri qi ri} {
    upvar 1 $symName sym
    set dri [rutil::sxt16 $dri]
    set qi  [rutil::sxt16 $qi]
    set ri  [rutil::sxt16 $ri]
    set ddi [expr {$dri*$qi + $ri}]

    set simhres [div_simh $ddi $dri]
    set q  [lindex $simhres 0]
    set r  [lindex $simhres 1]
    set n  [lindex $simhres 2]
    set z  [lindex $simhres 3]
    set v  [lindex $simhres 4]
    set c  [lindex $simhres 5]

    return [div_testd2 $cpu sym $ddi $dri $q $r $n $z $v $c]
  }
}

# ----------------------------------------------------------------------------
rlc log "test_div: test div instruction"

$cpu ldasm -lst lst -sym sym {
        . = 1000
stack:
start:  div     r2,r0
        mov     @#177776,r3
        bic     #177760,r3
        halt
stop:
}

rlc log "  test basics (via testd2)"
#                               dd   dr      q      r   n z v c     
rlc log "    dr>0"
rw11::div_testd2  $cpu sym       0    3      0      0   0 1 0 0
rw11::div_testd2  $cpu sym       1    3      0      1   0 1 0 0
rw11::div_testd2  $cpu sym       2    3      0      2   0 1 0 0
rw11::div_testd2  $cpu sym       3    3      1      0   0 0 0 0
rw11::div_testd2  $cpu sym       4    3      1      1   0 0 0 0
rw11::div_testd2  $cpu sym      -1    3      0     -1   0 1 0 0
rw11::div_testd2  $cpu sym      -2    3      0     -2   0 1 0 0
rw11::div_testd2  $cpu sym      -3    3     -1      0   1 0 0 0
rw11::div_testd2  $cpu sym      -4    3     -1     -1   1 0 0 0
rlc log "    dr<0"
rw11::div_testd2  $cpu sym       0   -3      0      0   0 1 0 0
rw11::div_testd2  $cpu sym       1   -3      0      1   0 1 0 0
rw11::div_testd2  $cpu sym       2   -3      0      2   0 1 0 0
rw11::div_testd2  $cpu sym       3   -3     -1      0   1 0 0 0
rw11::div_testd2  $cpu sym       4   -3     -1      1   1 0 0 0
rw11::div_testd2  $cpu sym      -1   -3      0     -1   0 1 0 0
rw11::div_testd2  $cpu sym      -2   -3      0     -2   0 1 0 0
rw11::div_testd2  $cpu sym      -3   -3      1      0   0 0 0 0
rw11::div_testd2  $cpu sym      -4   -3      1     -1   0 0 0 0
rlc log "    dr==0"
rw11::div_testd2  $cpu sym       0    0      0      0   0 1 1 1
rw11::div_testd2  $cpu sym       1    0      0      0   0 1 1 1
rw11::div_testd2  $cpu sym      -1    0      0      0   0 1 1 1

rlc log "  test 4 quadrant  basics (via testd2)"
#                               dd   dr      q      r   n z v c     
rw11::div_testd2  $cpu sym      34    5      6      4   0 0 0 0
rw11::div_testd2  $cpu sym      34   -5     -6      4   1 0 0 0
rw11::div_testd2  $cpu sym     -34    5     -6     -4   1 0 0 0
rw11::div_testd2  $cpu sym     -34   -5      6     -4   0 0 0 0

rlc log "  test 4 quadrant basics (via testdqr)"
#                                dr       q      r
rw11::div_testdqr $cpu sym        5       6      4;
rw11::div_testdqr $cpu sym       -5      -6      4;
rw11::div_testdqr $cpu sym        5      -6     -4;
rw11::div_testdqr $cpu sym       -5       6     -4;

rlc log "  test q=100000 boundary cases (q = max neg value)"
rlc log "    case dd>0, dr<0 -- factor 21846"
#                                dr       q      r
rw11::div_testdqr $cpu sym   -21846 0100000      0;      #      BAD-R4
rw11::div_testdqr $cpu sym   -21846 0100000      1;      #      BAD-R4
rw11::div_testdqr $cpu sym   -21846 0100000  21844;      #      BAD-R4
rw11::div_testdqr $cpu sym   -21846 0100000  21845;      #      BAD-R4
rw11::div_testdqr $cpu sym   -21846 0100000  21846;      # v=1
rw11::div_testdqr $cpu sym   -21846 0100000  21847;      # v=1

rlc log "    case dd<0, dr>0 -- factor 21846"
rw11::div_testdqr $cpu sym    21846 0100000       0;     #      BAD-R4
rw11::div_testdqr $cpu sym    21846 0100000      -1;     #      BAD-R4
rw11::div_testdqr $cpu sym    21846 0100000  -21844;     #      BAD-R4
rw11::div_testdqr $cpu sym    21846 0100000  -21845;     #      BAD-R4
rw11::div_testdqr $cpu sym    21846 0100000  -21846;     # v=1
rw11::div_testdqr $cpu sym    21846 0100000  -21847;     # v=1

rlc log "    case dd>0, dr<0 -- factor 21847"
rw11::div_testdqr $cpu sym   -21847 0100000       0;     #      BAD-R4
rw11::div_testdqr $cpu sym   -21847 0100000       1;     #      BAD-R4
rw11::div_testdqr $cpu sym   -21847 0100000   21845;     #      BAD-R4
rw11::div_testdqr $cpu sym   -21847 0100000   21846;     #      BAD-R4
rw11::div_testdqr $cpu sym   -21847 0100000   21847;     # v=1
rw11::div_testdqr $cpu sym   -21847 0100000   21848;     # v=1

rlc log "    case dd<0, dr>0 -- factor 21847"
rw11::div_testdqr $cpu sym    21847 0100000       0;     #      BAD-R4
rw11::div_testdqr $cpu sym    21847 0100000      -1;     #      BAD-R4
rw11::div_testdqr $cpu sym    21847 0100000  -21845;     #      BAD-R4
rw11::div_testdqr $cpu sym    21847 0100000  -21846;     #      BAD-R4
rw11::div_testdqr $cpu sym    21847 0100000  -21847;     # v=1
rw11::div_testdqr $cpu sym    21847 0100000  -21848;     # v=1

#
#
rlc log "  test q=077777 boundary cases (q = max pos value)"
rlc log "    case dd>0, dr>0 -- factor 21846"
rw11::div_testdqr $cpu sym    21846 0077777       0;     #
rw11::div_testdqr $cpu sym    21846 0077777       1;     #
rw11::div_testdqr $cpu sym    21846 0077777   21844;     #
rw11::div_testdqr $cpu sym    21846 0077777   21845;     #
rw11::div_testdqr $cpu sym    21846 0077777   21846;     # v=1
rw11::div_testdqr $cpu sym    21846 0077777   21847;     # v=1
rlc log "    case dd<0, dr<0 -- factor 21846"
rw11::div_testdqr $cpu sym   -21846 0077777       0;     #
rw11::div_testdqr $cpu sym   -21846 0077777      -1;     #
rw11::div_testdqr $cpu sym   -21846 0077777  -21844;     #
rw11::div_testdqr $cpu sym   -21846 0077777  -21845;     #
rw11::div_testdqr $cpu sym   -21846 0077777  -21846;     # v=1
rw11::div_testdqr $cpu sym   -21846 0077777  -21847;     # v=1
rlc log "    case dd>0, dr>0 -- factor 21847"
rw11::div_testdqr $cpu sym    21847 0077777       0;     #
rw11::div_testdqr $cpu sym    21847 0077777       1;     #
rw11::div_testdqr $cpu sym    21847 0077777   21845;     #
rw11::div_testdqr $cpu sym    21847 0077777   21846;     #
rw11::div_testdqr $cpu sym    21847 0077777   21847;     # v=1
rw11::div_testdqr $cpu sym    21847 0077777   21848;     # v=1
rlc log "    case dd<0, dr<0 -- factor 21847"
rw11::div_testdqr $cpu sym   -21847 0077777       0;     #
rw11::div_testdqr $cpu sym   -21847 0077777      -1;     #
rw11::div_testdqr $cpu sym   -21847 0077777  -21845;     #
rw11::div_testdqr $cpu sym   -21847 0077777  -21846;     #
rw11::div_testdqr $cpu sym   -21847 0077777  -21846;     # v=1
rw11::div_testdqr $cpu sym   -21847 0077777  -21847;     # v=1
#
#
rlc log "  test dr=100000 boundary cases (dr = max neg value)"
rlc log "    case dd<0, q>0"
rw11::div_testdqr $cpu sym  0100000       1       0;     #
rw11::div_testdqr $cpu sym  0100000       1      -1;     #
rw11::div_testdqr $cpu sym  0100000       1  -32767;     #
rw11::div_testdqr $cpu sym  0100000       2       0;     #      BAD-R4
rw11::div_testdqr $cpu sym  0100000       2      -1;     #
rw11::div_testdqr $cpu sym  0100000       2  -32767;     #
rw11::div_testdqr $cpu sym  0100000       3       0;     #
rw11::div_testdqr $cpu sym  0100000       3      -1;     #
rw11::div_testdqr $cpu sym  0100000       3  -32767;     #
rw11::div_testdqr $cpu sym  0100000       4       0;     #      BAD-R4
rw11::div_testdqr $cpu sym  0100000       4      -1;     #
rw11::div_testdqr $cpu sym  0100000       4  -32767;     #
rw11::div_testdqr $cpu sym  0100000       6       0;     #      BAD-R4
rw11::div_testdqr $cpu sym  0100000   32762       0;     #      BAD-R4
rw11::div_testdqr $cpu sym  0100000   32764       0;     #      BAD-R4
rw11::div_testdqr $cpu sym  0100000   32765       0;     #
rw11::div_testdqr $cpu sym  0100000   32766       0;     #      BAD-R4
rw11::div_testdqr $cpu sym  0100000   32766      -1;     #
rw11::div_testdqr $cpu sym  0100000   32766  -32767;     #
rw11::div_testdqr $cpu sym  0100000   32767       0;     #
rw11::div_testdqr $cpu sym  0100000   32767      -1;     #
rw11::div_testdqr $cpu sym  0100000   32767  -32767;     #
rlc log "    case dd>0, q<0"
rw11::div_testdqr $cpu sym  0100000      -1       0;     #
rw11::div_testdqr $cpu sym  0100000      -1       1;     #
rw11::div_testdqr $cpu sym  0100000      -1   32767;     #
rw11::div_testdqr $cpu sym  0100000      -2       0;     #
rw11::div_testdqr $cpu sym  0100000      -2       1;     #
rw11::div_testdqr $cpu sym  0100000      -2   32767;     #
rw11::div_testdqr $cpu sym  0100000  -32767       0;     #
rw11::div_testdqr $cpu sym  0100000  -32767       1;     #
rw11::div_testdqr $cpu sym  0100000  -32767   32767;     #
rw11::div_testdqr $cpu sym  0100000  -32768       0;     #      BAD-R4
rw11::div_testdqr $cpu sym  0100000  -32768       1;     #      BAD-R4
rw11::div_testdqr $cpu sym  0100000  -32768   32767;     #      BAD-R4
#
#
rlc log "  test dr=077777 boundary cases (dr = max pos value)"
rlc log "    case dd>0, q>0"
rw11::div_testdqr $cpu sym   077777       1       0;     #
rw11::div_testdqr $cpu sym   077777       1       1;     #
rw11::div_testdqr $cpu sym   077777       1   32766;     #
rw11::div_testdqr $cpu sym   077777       2       0;     #
rw11::div_testdqr $cpu sym   077777       2       1;     #
rw11::div_testdqr $cpu sym   077777       2   32766;     #
rw11::div_testdqr $cpu sym   077777   32766       0;     #
rw11::div_testdqr $cpu sym   077777   32766       1;     #
rw11::div_testdqr $cpu sym   077777   32766   32766;     #
rw11::div_testdqr $cpu sym   077777   32767       0;     #
rw11::div_testdqr $cpu sym   077777   32767       1;     #
rw11::div_testdqr $cpu sym   077777   32767   32766;     #
rlc log "    case dd<0, q<0"
rw11::div_testdqr $cpu sym   077777      -1       0;     #
rw11::div_testdqr $cpu sym   077777      -1      -1;     #
rw11::div_testdqr $cpu sym   077777      -1  -32766;     #
rw11::div_testdqr $cpu sym   077777      -2       0;     #
rw11::div_testdqr $cpu sym   077777      -2      -1;     #
rw11::div_testdqr $cpu sym   077777      -2  -32766;     #
rw11::div_testdqr $cpu sym   077777  -32767       0;     #
rw11::div_testdqr $cpu sym   077777  -32767      -1;     #
rw11::div_testdqr $cpu sym   077777  -32767  -32766;     #
rw11::div_testdqr $cpu sym   077777  -32768       0;     #      BAD-R4
rw11::div_testdqr $cpu sym   077777  -32768      -1;     #      BAD-R4
rw11::div_testdqr $cpu sym   077777  -32768  -32766;     #      BAD-R4
#
#
rlc log "  test dd max cases"
rlc log "    case dd>0 dr<0 near  nmax*nmax+nmax-1 = +1073774591"
rw11::div_testdqr $cpu sym   -32768  -32768      -1;     #
rw11::div_testdqr $cpu sym   -32768  -32768       0;     #      BAD-R4
rw11::div_testdqr $cpu sym   -32768  -32768       1;     #      BAD-R4
rw11::div_testdqr $cpu sym   -32768  -32768   32766;     #      BAD-R4
rw11::div_testdqr $cpu sym   -32768  -32768   32767;     # c.c  BAD-R4
rw11::div_testdqr $cpu sym   -32768  -32768   32768;     # v=1
rw11::div_testdqr $cpu sym   -32768  -32768   32769;     # v=1
rlc log "    case dd>0 dr>0 near  pmax*pmax+pmax-1 = +1073709055"
rw11::div_testdqr $cpu sym    32767   32767      -1;     #
rw11::div_testdqr $cpu sym    32767   32767       0;     #
rw11::div_testdqr $cpu sym    32767   32767       1;     #
rw11::div_testdqr $cpu sym    32767   32767   32765;     #
rw11::div_testdqr $cpu sym    32767   32767   32766;     # c.c
rw11::div_testdqr $cpu sym    32767   32767   32767;     # v=1
rw11::div_testdqr $cpu sym    32767   32767   32768;     # v=1
rlc log "    case dd<0 dr>0 near  nmax*pmax+pmax-1 = -1073741822"
rw11::div_testdqr $cpu sym    32767  -32768       1;     #
rw11::div_testdqr $cpu sym    32767  -32768       0;     #      BAD-R4
rw11::div_testdqr $cpu sym    32767  -32768      -1;     #      BAD-R4
rw11::div_testdqr $cpu sym    32767  -32768  -32765;     #      BAD-R4
rw11::div_testdqr $cpu sym    32767  -32768  -32766;     # c.c  BAD-R4
rw11::div_testdqr $cpu sym    32767  -32768  -32767;     # v=1
rw11::div_testdqr $cpu sym    32767  -32768  -32768;     # v=1
rlc log "    case dd<0 dr<0 near  pmax*nmax+nmax-1 = -1073741823"
rw11::div_testdqr $cpu sym   -32768   32767       1;     #
rw11::div_testdqr $cpu sym   -32768   32767       0;     #
rw11::div_testdqr $cpu sym   -32768   32767      -1;     #
rw11::div_testdqr $cpu sym   -32768   32767  -32766;     #
rw11::div_testdqr $cpu sym   -32768   32767  -32767;     # c.c
rw11::div_testdqr $cpu sym   -32768   32767  -32768;     # v=1
rw11::div_testdqr $cpu sym   -32768   32767  -32769;     # v=1
#
#
rlc log "  test late div quit cases in 2 quadrant algorithm"
#                                 dd   dr      q      r   n z v c     
rw11::div_testd2 $cpu sym    -32767    -1  32767      0   0 0 0 0;     #
rw11::div_testd2 $cpu sym    -32768    -1      0      0   0 0 1 0;     #
rw11::div_testd2 $cpu sym    -32769    -1      0      0   0 0 1 0;     #
#
rw11::div_testd2 $cpu sym    -65534    -2  32767      0   0 0 0 0;     #
rw11::div_testd2 $cpu sym    -65535    -2  32767     -1   0 0 0 0;     #
rw11::div_testd2 $cpu sym    -65536    -2      0      0   0 0 1 0;     #
rw11::div_testd2 $cpu sym    -65537    -2      0      0   0 0 1 0;     #
#
#
rlc log "  test big divident overflow cases"
#                                 dd   dr      q      r   n z v c     
rw11::div_testd2 $cpu sym 0x7fffffff    1      0      0   0 0 1 0;     #
rw11::div_testd2 $cpu sym 0x7fffffff    2      0      0   0 0 1 0;     #
rw11::div_testd2 $cpu sym 0x7fffffff   -1      0      0   1 0 1 0;     #
rw11::div_testd2 $cpu sym 0x7fffffff   -2      0      0   1 0 1 0;     #
rw11::div_testd2 $cpu sym 0x80000000    1      0      0   1 0 1 0;     #
rw11::div_testd2 $cpu sym 0x80000000    2      0      0   1 0 1 0;     #
rw11::div_testd2 $cpu sym 0x80000000   -1      0      0   0 0 1 0;     #
rw11::div_testd2 $cpu sym 0x80000000   -2      0      0   0 0 1 0;     #
