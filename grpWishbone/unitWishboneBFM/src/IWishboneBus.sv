// SDHC-SC-Core
// Secure Digital High Capacity Self Configuring Core
// 
// (C) Copyright 2010, Rainer Kastl
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the <organization> nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// File        : IWishboneBus.sv
// Owner       : Rainer Kastl
// Description : Wishbone bus
// Links       : Wishbone Spec R.3B
// 

`ifndef IWISHBONEBUS
`define IWISHBONEBUS

interface IWishboneBus;

		logic 						 ERR_I;
		logic 												 RTY_I;
		logic 												 CLK_I = 1;
		logic RST_I = 1;
		logic 												 ACK_I;
		logic [`cWishboneWidth-1 : 0] 						 DAT_I;

		logic 												 CYC_O;
		logic [6:4] 						 ADR_O;
		logic [`cWishboneWidth-1 : 0] 						 DAT_O;
		logic [`cWishboneWidth/`cWishboneWidth-1 : 0] SEL_O;
		logic 												 STB_O;
		logic [`cWishboneWidth-1 : 0] 						 TGA_O;
		logic [`cWishboneWidth-1 : 0]						 TGC_O;
		logic 												 TGD_O;
		logic 												 WE_O;
		logic 												 LOCK_O;
		aCTI												 CTI_O;
		logic [1 : 0] 										 BTE_O;

		// Masters view of the interface
		clocking cbMaster @(posedge CLK_I);
			input ERR_I, RTY_I, ACK_I, DAT_I;
			output CYC_O, ADR_O, DAT_O, SEL_O, STB_O, TGA_O, TGC_O, TGD_O, WE_O, LOCK_O, CTI_O, RST_I;
		endclocking
		modport Master (
			input CLK_I, clocking cbMaster
		);

		// Slaves view of the interface
		modport Slave (
			input CLK_I, RST_I, CYC_O, ADR_O, DAT_O, SEL_O, STB_O, TGA_O, TGC_O, TGD_O, WE_O, LOCK_O, CTI_O,
			output ERR_I, RTY_I, ACK_I, DAT_I
		);

endinterface;

`endif

