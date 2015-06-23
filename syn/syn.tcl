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
# File        : syn.tcl
# Owner       : Rainer Kastl
# Description : Synthesis script for Quartus
# Links       : 
# 

if [info exists pkgs] {
	foreach {grp pkg} $pkgs {
		set fname ../../../grp$grp/pkg$pkg/src/$pkg-p.vhdl
		if [file isfile $fname] {
			set_global_assignment -name VHDL_FILE "$fname"
		} else {
			post_message -type error "Pkg $grp $pkg not found!"
		}
	}
}

if [info exists units] {
	foreach {grp en arch} $units {
		set prefix ../../../grp$grp/unit$en/src
		if [file isfile $prefix/$en-e.vhdl] {
			set_global_assignment -name VHDL_FILE "$prefix/$en-e.vhdl"
			if [file isfile $prefix/$en-$arch-a.vhdl] {
				set_global_assignment -name VHDL_FILE "$prefix/$en-$arch-a.vhdl"
			}
		} elseif [file isfile $prefix/$en-$arch-ea.vhdl] {
			set_global_assignment -name VHDL_FILE "$prefix/$en-$arch-ea.vhdl"
		} else {
			post_message -type error "Unit $grp $en $arch not found!"
		}
	}
}
