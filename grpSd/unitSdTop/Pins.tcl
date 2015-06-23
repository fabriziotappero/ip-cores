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
# File        : Pins.tcl
# Owner       : Rainer Kastl
# Description : Pin & Location Assignments
# Links       : 
# 

# Signal Pin Pullup
set pins {
	iClk A12 0
	inResetAsync Y20 1
	ioCmd  A8 1
	ioData[0] A9 1
	ioData[1] D6 1
	ioData[2] C14 1
	ioData[3] B8 1
	oSclk B9 0
	oIcs307Sclk C10 0
	oIcs307Data C9 0
	oIcs307Strobe E9 0
	oLedBank[0] Y6 0
	oLedBank[1] W5 0
	oLedBank[2] Y5 0
	oLedBank[3] Y7 0
	oLedBank[4] V8 0
	oLedBank[5] W8 0
	oLedBank[6] Y9 0
	oLedBank[7] W7 0
	oDigitAdr[3] Y3 0
	oDigitAdr[2] Y4 0
	oDigitAdr[1] W4 0
	oTx B5 0
}

# Set according to pins
source ../../../syn/pins.tcl

set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED WITH WEAK PULL-UP"

# #set_location_assignment PIN_B20 -to AVRAD[0]
# #set_location_assignment PIN_A20 -to AVRAD[1]
# #set_location_assignment PIN_B19 -to AVRAD[2]
# #set_location_assignment PIN_A19 -to AVRAD[3]
# #set_location_assignment PIN_B18 -to AVRAD[4]
# #set_location_assignment PIN_A18 -to AVRAD[5]
# #set_location_assignment PIN_B17 -to AVRAD[6]
# #set_location_assignment PIN_A17 -to AVRAD[7]
# #set_location_assignment PIN_A11 -to AVRADR[8]
# #set_location_assignment PIN_A13 -to AVRADR[9]
# #set_location_assignment PIN_B13 -to AVRADR[10]
# #set_location_assignment PIN_A14 -to AVRADR[11]
# #set_location_assignment PIN_B14 -to AVRADR[12]
# #set_location_assignment PIN_A15 -to AVRADR[13]
# #set_location_assignment PIN_B15 -to AVRADR[14]
# #set_location_assignment PIN_A16 -to AVRADR[15]
# #set_location_assignment PIN_B16 -to AVRALE
# #set_location_assignment PIN_E15 -to AVRIRQ
# #set_location_assignment PIN_B11 -to AVRRD
# #set_location_assignment PIN_A10 -to AVRWR
# #set_location_assignment PIN_C21 -to BCLK
# #set_location_assignment PIN_D22 -to DIN
# #set_location_assignment PIN_E22 -to DOUT
# #set_location_assignment PIN_D21 -to LRCIN
# #set_location_assignment PIN_E21 -to LRCOUT
# #set_location_assignment PIN_E19 -to MCLK
# set_location_assignment PIN_A12 -to iClk
# #set_location_assignment PIN_AB11 -to iClk
# #set_location_assignment PIN_C22 -to CS
# set_location_assignment PIN_AB5 -to inKey1
# set_location_assignment PIN_AA5 -to inKey2
# set_location_assignment PIN_AB4 -to inKey3
# set_location_assignment PIN_AA4 -to inKey4
# set_location_assignment PIN_AB3 -to inKey5
# set_location_assignment PIN_AA3 -to inKey6
# set_location_assignment PIN_Y6 -to oSeg0
# set_location_assignment PIN_W5 -to oSeg1
# set_location_assignment PIN_Y5 -to oSeg2
# set_location_assignment PIN_Y7 -to oSeg3
# set_location_assignment PIN_V8 -to oSeg4
# set_location_assignment PIN_W8 -to oSeg5
# set_location_assignment PIN_Y9 -to oSeg6
# set_location_assignment PIN_W7 -to oSeg7
# set_location_assignment PIN_W4 -to oDIGIT_ADR_A
# set_location_assignment PIN_Y4 -to oDIGIT_ADR_B
# set_location_assignment PIN_Y3 -to oDIGIT_ADR_C
# #set_location_assignment PIN_B4 -to Txd232
# set_location_assignment PIN_Y20 -to inResetAsync
# #set_location_assignment PIN_D5 -to Ps2Clk1
# #set_location_assignment PIN_E7 -to Ps2Clk2
# #set_location_assignment PIN_D4 -to Ps2Dat1
# #set_location_assignment PIN_C4 -to Ps2Dat2
# #set_location_assignment PIN_A4 -to Rxd232
# #set_location_assignment PIN_W14 -to VgaBl0
# #set_location_assignment PIN_Y14 -to VgaBl1
# #set_location_assignment PIN_Y16 -to VgaGr0
# #set_location_assignment PIN_W15 -to VgaGr1
# #set_location_assignment PIN_V14 -to VgaHsync
# #set_location_assignment PIN_Y17 -to VgaRd0
# #set_location_assignment PIN_W16 -to VgaRd1
# #set_location_assignment PIN_AA6 -to VgaVsync
# #set_location_assignment PIN_C19 -to SCLK
# #set_location_assignment PIN_C20 -to SDIN
# #set_location_assignment PIN_AB7 -to mcoll_pad_i
# #set_location_assignment PIN_AA7 -to mcrs_pad_i
# #set_location_assignment PIN_W12 -to mrx_clk_pad_i
# #set_location_assignment PIN_AA14 -to mrxd_pad_i[0]
# #set_location_assignment PIN_AB15 -to mrxd_pad_i[1]
# #set_location_assignment PIN_AA15 -to mrxd_pad_i[2]
# #set_location_assignment PIN_AB16 -to mrxd_pad_i[3]
# #set_location_assignment PIN_AB13 -to mrxdv_pad_i
# #set_location_assignment PIN_AA13 -to mrxerr_pad_i
# #set_location_assignment PIN_V12 -to mtx_clk_pad_i
# #set_location_assignment PIN_AB9 -to mtxd_pad_o[0]
# #set_location_assignment PIN_AA9 -to mtxd_pad_o[1]
# #set_location_assignment PIN_AB8 -to mtxd_pad_o[2]
# #set_location_assignment PIN_AA8 -to mtxd_pad_o[3]
# #set_location_assignment PIN_AB12 -to mtxen_pad_o
# #set_location_assignment PIN_AB14 -to mtxerr_pad_o
# #set_location_assignment PIN_AB6 -to ETH_Reset_o
# #set_location_assignment PIN_AB17 -to md_io
# #set_location_assignment PIN_AA16 -to mdc_o
#
# set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to inKey1
# set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to inKey2
# set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to inKey3
# set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to inKey4
# set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to inKey5
# set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to inKey6
# set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to
