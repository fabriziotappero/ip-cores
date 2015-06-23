# SDHC-SC-Core
# Secure Digital High Capacity Self Configuring Core
# 
# (C) Copyright 2010, Rainer Kastl
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# File        : sim.tcl
# Owner       : Rainer Kastl
# Description : Script for simulation
# Links       : 
# 


proc compileWithPsl {fname grp en psl} {
	upvar $psl mpsl

	if [info exists mpsl($en)] {
		set pslfile "../../../grp$grp/unit$en/src/$mpsl($en).psl"
		if [file isfile $pslfile] {
			vcom $fname -pslfile $pslfile
		} else {
			echo "pslfile $pslfile not found"
			vcom $fname
		}
	} else {
		vcom $fname
	}
};

proc compileUnit {grp en arch tpsl} {
	upvar $tpsl psl
	set prefix ../../../grp$grp/unit$en/src
	if [file isfile $prefix/$en-e.vhdl] {
		compileWithPsl "$prefix/$en-e.vhdl" $grp $en psl
		if [file isfile $prefix/$en-$arch-a.vhdl] {
			vcom "$prefix/$en-$arch-a.vhdl"
		}
	} elseif [file isfile $prefix/$en-$arch-ea.vhdl] {
		compileWithPsl "$prefix/$en-$arch-ea.vhdl" $grp $en psl
	} else {
		echo "Unit $grp $en $arch not found!"
	}
};


proc compileTb {grp en arch} {
	set prefix ../../../grp$grp/unit$en/src
		if [file isfile $prefix/tb$en-e.vhdl] {
			vcom "$prefix/tb$en-e.vhdl"
			if [file isfile $prefix/tb$en-$arch-a.vhdl] {
				vcom "$prefix/tb$en-$arch-a.vhdl"
			}
		} elseif [file isfile $prefix/tb$en-$arch-ea.vhdl] {
			vcom "$prefix/tb$en-$arch-ea.vhdl"
		} else {
			echo "Testbench $grp $en $arch not found!"
		}
};

vlib work
vmap work work

if [info exists libs] {
	foreach {lib} $libs {
		vmap $lib ../../../lib$lib/sim/$lib
	}
}

if [info exists pkgs] {
	foreach {grp pkg} $pkgs {
		set fname ../../../grp$grp/pkg$pkg/src/$pkg-p.vhdl
			if [file isfile $fname] {
				vcom "$fname"
			} else {
				echo "Pkg $grp $pkg not found!"
			}
	}
}

if [info exists units] {
	foreach {grp en arch} $units {
		compileUnit $grp $en $arch psl
	}
}



if [info exists tbunits] {
	foreach {grp en arch} $tbunits {
		if ![info exists psl] {
			array set psl [list]
		}
		compileUnit $grp $en $arch psl
	}
}

if [info exists tb] {
	foreach {grp en arch} $tb {
		compileTb $grp $en $arch

		set top tb$en
	}
}

if [info exists svtb] {
	foreach {grp unit} $svtb {
		set fname ../../../grp$grp/unit$unit/src/tb$unit.sv
		if [file isfile $fname] {
			vlog $fname
		} else {
			echo "Svunit $grp $unit not found! ($fname)"
		}
	}
}

if [info exists svunits] {
	foreach {grp unit} $svunits {
		set fname ../../../grp$grp/unit$unit/src/$unit.sv
		if [file isfile $fname] {
			if [info exists sysvlogparams] {
				vlog $fname $sysvlogparams
			} else {
				vlog $arg
			}
		} else {
			echo "Svunit $grp $unit not found! ($fname)"
		}
	}
}

if ([info exists top]) {
	if ([info exists vsimargs]) {
		vsim $vsimargs $top
	} else {
		vsim $top
	}

	if [file isfile wave.do] {
		do wave.do
	}

	if [info exists simtime] {
		run $simtime
	} else {
		run -all
	}
}
