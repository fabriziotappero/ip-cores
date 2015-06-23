# == Synopsis
# 	 Modelsim simulation configuration file.
#
# == Usage
#	 Loads automatically with 'icon.bat'.
#
# == Autor
#   Mathias Hörtnagl <mathias.hoertnagl[AT]student.uibk.ac.at>
#
# == Copyright
#   Copyright (C) 2011  Mathias Hörtnagl
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

# reference: http://wiki.tcl.tk/15598
proc binfmt1 {k {cnt 8}} {
    if {![string is integer $k]} {error "argument is not an integer"}
    #Compute minimum number of bits necessary
    #This is the integer ceiling of the log of the number to the base 2.
    if {$k == 0} {set bits 1} else {set bits [expr int(ceil((log(abs($k)))/(log(2))))]}
    if {$bits > $cnt} {set cnt $bits}
    #Now compute binary representation
    for {set i [expr $cnt -1]} {$i > -1} {incr i -1} {
        append s [expr ($k >> $i) & 1]
    }
    return $s
 }


proc vga {} {
   variable line ""
   variable elem ""
   variable char ""

   for {set y 0} {$y < 37} {incr y} {
      for {set x 0} {$x < 100} {incr x} {
         set char " "
         set elem [string range [binfmt1 [examine -radix unsigned -value /tb_icon/disp/video_ram/mem([expr $y*100+$x])] 16] 8 15]   
         switch $elem {
				00100000 {set char "."}
				00100001 {set char "!"}
				00100010 {set char "\""}
				00100011 {set char "#"}
				00100100 {set char "\$"}
				00100101 {set char "%"}
				00100110 {set char "&"}
				00100111 {set char "'"}
				00101000 {set char "("}
				00101001 {set char ")"}
				00101010 {set char "*"}
				00101011 {set char "+"}
				00101100 {set char ","}
				00101101 {set char "-"}
				00101110 {set char "."}
				00101111 {set char "/"}
				00110000 {set char "0"}
				00110001 {set char "1"}
				00110010 {set char "2"}
				00110011 {set char "3"}
				00110100 {set char "4"}
				00110101 {set char "5"}
				00110110 {set char "6"}
				00110111 {set char "7"}
				00111000 {set char "8"}
				00111001 {set char "9"}
				00111010 {set char ":"}
				00111011 {set char ";"}
				00111100 {set char "<"}
				00111101 {set char "="}
				00111110 {set char ">"}
				00111111 {set char "?"}
				01000000 {set char "@"}
				01000001 {set char "A"}
				01000010 {set char "B"}
				01000011 {set char "C"}
				01000100 {set char "D"}
				01000101 {set char "E"}
				01000110 {set char "F"}
				01000111 {set char "G"}
				01001000 {set char "H"}
				01001001 {set char "I"}
				01001010 {set char "J"}
				01001011 {set char "K"}
				01001100 {set char "L"}
				01001101 {set char "M"}
				01001110 {set char "N"}
				01001111 {set char "O"}
				01010000 {set char "P"}
				01010001 {set char "Q"}
				01010010 {set char "R"}
				01010011 {set char "S"}
				01010100 {set char "T"}
				01010101 {set char "U"}
				01010110 {set char "V"}
				01010111 {set char "W"}
				01011000 {set char "X"}
				01011001 {set char "Y"}
				01011010 {set char "Z"}
				01011011 {set char "\["}
				01011100 {set char "\\"}
				01011101 {set char "\]"}
				01011110 {set char "^"}
				01011111 {set char "_"}
				01100000 {set char "`"}
				01100001 {set char "a"}
				01100010 {set char "b"}
				01100011 {set char "c"}
				01100100 {set char "d"}
				01100101 {set char "e"}
				01100110 {set char "f"}
				01100111 {set char "g"}
				01101000 {set char "h"}
				01101001 {set char "i"}
				01101010 {set char "j"}
				01101011 {set char "k"}
				01101100 {set char "l"}
				01101101 {set char "m"}
				01101110 {set char "n"}
				01101111 {set char "o"}
				01110000 {set char "p"}
				01110001 {set char "q"}
				01110010 {set char "r"}
				01110011 {set char "s"}
				01110100 {set char "t"}
				01110101 {set char "u"}
				01110110 {set char "v"}
				01110111 {set char "w"}
				01111000 {set char "x"}
				01111001 {set char "y"}
				01111010 {set char "z"}
				01111011 {set char "{"}
				01111100 {set char "|"}
				01111101 {set char "}"}
				01111110 {set char "~"}
				01111111 {set char ""}
            default  {set char "."}
         } 
         set line [concat $line$char]      
      }
      echo $line
      set line ""
   }
}

delete wave *

add wave -noupdate -color Gold -label CI -childformat {{/tb_icon/ci.ins -radix hexadecimal} {/tb_icon/ci.dat -radix hexadecimal}} -expand -subitemconfig {/tb_icon/ci.clk {-color #ffffd7d70000 -height 15} /tb_icon/ci.rst {-color #ffffd7d70000 -height 15} /tb_icon/ci.hld {-color #ffffd7d70000 -height 15} /tb_icon/ci.irq {-color #ffffd7d70000 -height 15} /tb_icon/ci.ins {-color #ffffd7d70000 -height 15 -radix hexadecimal} /tb_icon/ci.dat {-color #ffffd7d70000 -height 15 -radix hexadecimal}} /tb_icon/ci
add wave -noupdate -color Khaki -label CO -radix hexadecimal -childformat {{/tb_icon/co.iadr -radix hexadecimal} {/tb_icon/co.dadr -radix hexadecimal} {/tb_icon/co.dat -radix hexadecimal} {/tb_icon/co.cp0op -radix hexadecimal} {/tb_icon/co.cp0reg -radix hexadecimal} {/tb_icon/co.a -radix hexadecimal} {/tb_icon/co.b -radix hexadecimal}} -subitemconfig {/tb_icon/co.iadr {-color #f0f0e6e68c8c -height 15 -radix hexadecimal} /tb_icon/co.dadr {-color #f0f0e6e68c8c -height 15 -radix hexadecimal} /tb_icon/co.we {-color #f0f0e6e68c8c -height 15} /tb_icon/co.sel {-color #f0f0e6e68c8c -height 15} /tb_icon/co.dat {-color #f0f0e6e68c8c -height 15 -radix hexadecimal} /tb_icon/co.op {-color #f0f0e6e68c8c -height 15} /tb_icon/co.alu {-color #f0f0e6e68c8c -height 15} /tb_icon/co.rimm {-color #f0f0e6e68c8c -height 15} /tb_icon/co.cp0op {-color #f0f0e6e68c8c -height 15 -radix hexadecimal} /tb_icon/co.cp0reg {-color #f0f0e6e68c8c -height 15 -radix hexadecimal} /tb_icon/co.a {-color #f0f0e6e68c8c -height 15 -radix hexadecimal} /tb_icon/co.b {-color #f0f0e6e68c8c -height 15 -radix hexadecimal}} /tb_icon/co
add wave -noupdate -divider -height 30 <NULL>
add wave -noupdate -radix hexadecimal /tb_icon/cpu0/fe/v
add wave -noupdate -radix hexadecimal -childformat {{/tb_icon/cpu0/de/v.ec -radix hexadecimal} {/tb_icon/cpu0/de/v.mc -radix hexadecimal} {/tb_icon/cpu0/de/v.wc -radix hexadecimal} {/tb_icon/cpu0/de/v.i -radix hexadecimal}} -subitemconfig {/tb_icon/cpu0/de/v.ec {-height 15 -radix hexadecimal} /tb_icon/cpu0/de/v.mc {-height 15 -radix hexadecimal} /tb_icon/cpu0/de/v.wc {-height 15 -radix hexadecimal} /tb_icon/cpu0/de/v.i {-height 15 -radix hexadecimal}} /tb_icon/cpu0/de/v
add wave -noupdate -radix hexadecimal -childformat {{/tb_icon/cpu0/ex/v.cor -radix hexadecimal} {/tb_icon/cpu0/ex/v.mc -radix hexadecimal} {/tb_icon/cpu0/ex/v.wc -radix hexadecimal} {/tb_icon/cpu0/ex/v.rd -radix unsigned} {/tb_icon/cpu0/ex/v.f -radix hexadecimal} {/tb_icon/cpu0/ex/v.str -radix hexadecimal} {/tb_icon/cpu0/ex/v.res -radix hexadecimal}} -subitemconfig {/tb_icon/cpu0/ex/v.cor {-height 15 -radix hexadecimal} /tb_icon/cpu0/ex/v.mc {-height 15 -radix hexadecimal} /tb_icon/cpu0/ex/v.wc {-height 15 -radix hexadecimal} /tb_icon/cpu0/ex/v.rd {-height 15 -radix unsigned} /tb_icon/cpu0/ex/v.f {-height 15 -radix hexadecimal} /tb_icon/cpu0/ex/v.str {-height 15 -radix hexadecimal} /tb_icon/cpu0/ex/v.res {-height 15 -radix hexadecimal}} /tb_icon/cpu0/ex/v
add wave -noupdate -radix hexadecimal -childformat {{/tb_icon/cpu0/me/v.wc -radix hexadecimal} {/tb_icon/cpu0/me/v.rd -radix hexadecimal} {/tb_icon/cpu0/me/v.res -radix hexadecimal}} -subitemconfig {/tb_icon/cpu0/me/v.wc {-height 15 -radix hexadecimal} /tb_icon/cpu0/me/v.rd {-height 15 -radix hexadecimal} /tb_icon/cpu0/me/v.res {-height 15 -radix hexadecimal}} /tb_icon/cpu0/me/v
add wave -noupdate -childformat {{/tb_icon/cpu0/cp.epc -radix hexadecimal}} -expand -subitemconfig {/tb_icon/cpu0/cp.sr -expand /tb_icon/cpu0/cp.epc {-height 15 -radix hexadecimal}} /tb_icon/cpu0/cp
#add wave -noupdate /tb_icon/cpu0/ccp
add wave -noupdate -divider -height 30 {CPU MASTER}
add wave -noupdate -radix hexadecimal -childformat {{/tb_icon/uut1/r.s -radix hexadecimal} {/tb_icon/uut1/r.i -radix hexadecimal} {/tb_icon/uut1/r.d -radix hexadecimal}} -subitemconfig {/tb_icon/uut1/r.s {-height 15 -radix hexadecimal} /tb_icon/uut1/r.i {-height 15 -radix hexadecimal} /tb_icon/uut1/r.d {-height 15 -radix hexadecimal}} /tb_icon/uut1/r
add wave -noupdate -color {Steel Blue} -label MI -childformat {{/tb_icon/mi.dat -radix hexadecimal}} -subitemconfig {/tb_icon/mi.clk {-color #46468282b4b4 -height 15} /tb_icon/mi.rst {-color #46468282b4b4 -height 15} /tb_icon/mi.dat {-color #46468282b4b4 -height 15 -radix hexadecimal} /tb_icon/mi.ack {-color #46468282b4b4 -height 15}} /tb_icon/mi
add wave -noupdate -color {Light Steel Blue} -label MO -radix hexadecimal -childformat {{/tb_icon/mo.dat -radix hexadecimal} {/tb_icon/mo.adr -radix hexadecimal}} -subitemconfig {/tb_icon/mo.dat {-color #b0b0c4c4dede -height 15 -radix hexadecimal} /tb_icon/mo.sel {-color #b0b0c4c4dede -height 15} /tb_icon/mo.adr {-color #b0b0c4c4dede -height 15 -radix hexadecimal} /tb_icon/mo.cyc {-color #b0b0c4c4dede -height 15} /tb_icon/mo.stb {-color #b0b0c4c4dede -height 15} /tb_icon/mo.we {-color #b0b0c4c4dede -height 15}} /tb_icon/mo
add wave -noupdate -divider -height 30 {MEMORY SLAVE}
add wave -noupdate -color {Lime Green} -label SI -radix hexadecimal -childformat {{/tb_icon/brami.dat -radix hexadecimal} {/tb_icon/brami.adr -radix hexadecimal -childformat {{/tb_icon/brami.adr(31) -radix hexadecimal} {/tb_icon/brami.adr(30) -radix hexadecimal} {/tb_icon/brami.adr(29) -radix hexadecimal} {/tb_icon/brami.adr(28) -radix hexadecimal} {/tb_icon/brami.adr(27) -radix hexadecimal} {/tb_icon/brami.adr(26) -radix hexadecimal} {/tb_icon/brami.adr(25) -radix hexadecimal} {/tb_icon/brami.adr(24) -radix hexadecimal} {/tb_icon/brami.adr(23) -radix hexadecimal} {/tb_icon/brami.adr(22) -radix hexadecimal} {/tb_icon/brami.adr(21) -radix hexadecimal} {/tb_icon/brami.adr(20) -radix hexadecimal} {/tb_icon/brami.adr(19) -radix hexadecimal} {/tb_icon/brami.adr(18) -radix hexadecimal} {/tb_icon/brami.adr(17) -radix hexadecimal} {/tb_icon/brami.adr(16) -radix hexadecimal} {/tb_icon/brami.adr(15) -radix hexadecimal} {/tb_icon/brami.adr(14) -radix hexadecimal} {/tb_icon/brami.adr(13) -radix hexadecimal} {/tb_icon/brami.adr(12) -radix hexadecimal} {/tb_icon/brami.adr(11) -radix hexadecimal} {/tb_icon/brami.adr(10) -radix hexadecimal} {/tb_icon/brami.adr(9) -radix hexadecimal} {/tb_icon/brami.adr(8) -radix hexadecimal} {/tb_icon/brami.adr(7) -radix hexadecimal} {/tb_icon/brami.adr(6) -radix hexadecimal} {/tb_icon/brami.adr(5) -radix hexadecimal} {/tb_icon/brami.adr(4) -radix hexadecimal} {/tb_icon/brami.adr(3) -radix hexadecimal} {/tb_icon/brami.adr(2) -radix hexadecimal} {/tb_icon/brami.adr(1) -radix hexadecimal} {/tb_icon/brami.adr(0) -radix hexadecimal}}}} -subitemconfig {/tb_icon/brami.clk {-color #3232cdcd3232 -height 15} /tb_icon/brami.rst {-color #3232cdcd3232 -height 15} /tb_icon/brami.dat {-color #3232cdcd3232 -height 15 -radix hexadecimal} /tb_icon/brami.sel {-color #3232cdcd3232 -height 15} /tb_icon/brami.sel(3) {-color #3232cdcd3232} /tb_icon/brami.sel(2) {-color #3232cdcd3232} /tb_icon/brami.sel(1) {-color #3232cdcd3232} /tb_icon/brami.sel(0) {-color #3232cdcd3232} /tb_icon/brami.adr {-color #3232cdcd3232 -height 15 -radix hexadecimal -childformat {{/tb_icon/brami.adr(31) -radix hexadecimal} {/tb_icon/brami.adr(30) -radix hexadecimal} {/tb_icon/brami.adr(29) -radix hexadecimal} {/tb_icon/brami.adr(28) -radix hexadecimal} {/tb_icon/brami.adr(27) -radix hexadecimal} {/tb_icon/brami.adr(26) -radix hexadecimal} {/tb_icon/brami.adr(25) -radix hexadecimal} {/tb_icon/brami.adr(24) -radix hexadecimal} {/tb_icon/brami.adr(23) -radix hexadecimal} {/tb_icon/brami.adr(22) -radix hexadecimal} {/tb_icon/brami.adr(21) -radix hexadecimal} {/tb_icon/brami.adr(20) -radix hexadecimal} {/tb_icon/brami.adr(19) -radix hexadecimal} {/tb_icon/brami.adr(18) -radix hexadecimal} {/tb_icon/brami.adr(17) -radix hexadecimal} {/tb_icon/brami.adr(16) -radix hexadecimal} {/tb_icon/brami.adr(15) -radix hexadecimal} {/tb_icon/brami.adr(14) -radix hexadecimal} {/tb_icon/brami.adr(13) -radix hexadecimal} {/tb_icon/brami.adr(12) -radix hexadecimal} {/tb_icon/brami.adr(11) -radix hexadecimal} {/tb_icon/brami.adr(10) -radix hexadecimal} {/tb_icon/brami.adr(9) -radix hexadecimal} {/tb_icon/brami.adr(8) -radix hexadecimal} {/tb_icon/brami.adr(7) -radix hexadecimal} {/tb_icon/brami.adr(6) -radix hexadecimal} {/tb_icon/brami.adr(5) -radix hexadecimal} {/tb_icon/brami.adr(4) -radix hexadecimal} {/tb_icon/brami.adr(3) -radix hexadecimal} {/tb_icon/brami.adr(2) -radix hexadecimal} {/tb_icon/brami.adr(1) -radix hexadecimal} {/tb_icon/brami.adr(0) -radix hexadecimal}}} /tb_icon/brami.adr(31) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(30) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(29) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(28) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(27) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(26) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(25) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(24) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(23) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(22) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(21) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(20) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(19) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(18) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(17) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(16) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(15) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(14) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(13) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(12) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(11) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(10) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(9) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(8) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(7) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(6) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(5) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(4) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(3) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(2) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(1) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.adr(0) {-color #3232cdcd3232 -radix hexadecimal} /tb_icon/brami.cyc {-color #3232cdcd3232 -height 15} /tb_icon/brami.stb {-color #3232cdcd3232 -height 15} /tb_icon/brami.we {-color #3232cdcd3232 -height 15}} /tb_icon/brami
add wave -noupdate -color {Green Yellow} -label SO -radix hexadecimal -childformat {{/tb_icon/bramo.dat -radix hexadecimal}} -subitemconfig {/tb_icon/bramo.dat {-color #adadffff2f2f -height 15 -radix hexadecimal} /tb_icon/bramo.ack {-color #adadffff2f2f -height 15}} /tb_icon/bramo
add wave -noupdate -divider -height 30 PIT
add wave -noupdate /tb_icon/pit0/s
add wave -noupdate -radix unsigned /tb_icon/pit0/n

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {55 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 1
configure wave -timelineunits ns
update
WaveRestoreZoom {26 ns} {166 ns}

# Add memory tabs to the UI
#add mem /tb_icon/cpu0/gp/gpr -a decimal -d hexadecimal -wo 1
#add mem /tb_icon/mem0/mem(3) -a hexadecimal -d hexadecimal -wo 1
#add mem /tb_icon/mem0/mem(2) -a hexadecimal -d hexadecimal -wo 1
#add mem /tb_icon/mem0/mem(1) -a hexadecimal -d hexadecimal -wo 1
#add mem /tb_icon/mem0/mem(0) -a hexadecimal -d hexadecimal -wo 1
