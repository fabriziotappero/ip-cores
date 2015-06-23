#####################################################################
####                                                             ####
####  SASM Lst to Verilog converter.                             ####
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
puts stderr "***         SASM Lst to Verilog converter.       ***"
puts stderr "*** Usage: tclsh83 lst2rom.tcl \[*\].lst > \[*\].rom ***"
puts stderr "****************************************************"

# Open the source file to converter
set chan [open [lindex $argv 0]]

# Find the first line to begin
while {[gets $chan line] >= 0} {
  if {[string first "0000 " $line 7] > 0} {
	break
  }
}

# Let's do it !
while {[gets $chan line] >= 0} {
  # Check the lines that we want
  if {[regexp -all {[0-9]} [string index $line 4]]} {
    # Check the ".org" or ".ORG" directives
    if {[string first ".org " $line 25] > 0 || [string first ".ORG " $line 25] > 0} {
	puts "@[string range $line 30 33]"
    } else {
	# Check this line to get hexcode
	set c 14
	while {$c < 14+12} {
	  set hexcode [string range $line $c [incr c]]
	  if {[string is xdigit -strict $hexcode] == 1} {
		puts $hexcode
		incr c 2
	  } else {
		break
	  }
	}
    }
  }
}

# Finish
puts stderr "Finish !!!"
close $chan
