#####################################################################
####                                                             ####
####  SASM Hex to Verilog converter.                             ####
####                                                             ####
####  This file is part of the oks8 cores project                ####
####  http://www.opencores.org/cvsweb.shtml/oks8/                ####
####                                                             ####
#### Copyright (C) 2006 Jian Li                                  ####
####                    kongzilee@yahoo.com.cn                   ####
####                                                             ####
#### This source file may be used and distributed without        ####
#### restriction provided that this copyright statement is not   ####
#### removed from the file and that any derivative work contains ####
#### the original copyright notice and the associated disclaimer.####
####                                                             ####
####     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ####
#### EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ####
#### TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ####
#### FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ####
#### OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ####
#### INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ####
#### (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ####
#### GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ####
#### BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ####
#### LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ####
#### (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ####
#### OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ####
#### POSSIBILITY OF SUCH DAMAGE.                                 ####
####                                                             ####
#####################################################################

puts stderr "****************************************************"
puts stderr "***         SASM Hex to Verilog converter.       ***"
puts stderr "*** Usage: tclsh83 hex2rom.tcl \[*\].hex > \[*\].rom ***"
puts stderr "****************************************************"

# Open the source file to converter
set chan [open [lindex $argv 0]]
set LineNumber 0
set state 1

# Get the lines
while {[gets $chan line] >= 0} {
  # Only check the even lines
  if {[expr $LineNumber % 2] == 0} {
	if {[string first ":" $line 0] != 0} {
	  puts stderr "$LineNumber: The first char is not \[:\] >> \[$line\]"
	  break
	}
	set slen [string length $line]
	# Check the end line
	if {[string first "00" $line 1] == 1} {
	  if {$slen == 11} {
		set state 0;
	  } else {
		puts stderr "$LineNumber: Bad end line >> \[$line\]"
	  }
	  break
	}
	# Get the position where the code begin
	set hexcode [string range $line 3 6]
	if {[string is xdigit -strict $hexcode] == 0} {
	  puts stderr "$LineNumber: Bad Hex Format >> \[$hexcode\]"
	  break
	}
	puts "@$hexcode"
	# Get the hexcode and write to the ROM file
	set c 9
	incr slen -11
	while {$slen > 0} {
	  set hexcode [string range $line $c [incr c]]
	  if {[string is xdigit -strict $hexcode] == 1} {
		puts $hexcode
		incr c
	  } else {
		puts stderr "$LineNumber: Bad Hex Format >> \[$hexcode\]"
		set state 2
		break
	  }
	  incr slen -2
	}
	if {$state == 2} {
	  break;
	}
  }
  incr LineNumber
}

# Finish
if {$state == 0} {
  puts stderr "Finish !!!"
} else {
  puts stderr "Finish with Error(s) !!!"
}

close $chan
