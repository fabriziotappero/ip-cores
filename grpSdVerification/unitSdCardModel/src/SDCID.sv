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
// File        : SDCID.sv
// Owner       : Rainer Kastl
// Description : SD Register CID
// Links       : 
// 

`ifndef SDCID
`define SDCID

typedef logic[7:0] manufacturer_id_t;
typedef logic[15:0] app_id_t;
typedef logic[39:0] pname_t;
typedef logic[7:0] prev_t;
typedef logic[31:0] pserialnumber_t;
typedef logic[11:0] manufacturing_date_t;
typedef logic[127:1] cidreg_t; // 1 reserved to endbit

class SDCID;
	local rand manufacturer_id_t mid;
	local rand app_id_t appid;
	local rand pname_t name;
	local rand prev_t rev;
	local rand pserialnumber_t serialnumber;
	local rand manufacturing_date_t date;

	function new();
	endfunction

	function automatic aCrc7 getCrc(cidreg_t cid);
		logic data[$];
		
		for (int i = 127; i >= 8; i--) begin
			data.push_back(cid[i]);
		end
		return calcCrc7(data);
	endfunction

	function automatic cidreg_t get();
		cidreg_t temp = 0;
		temp[127:120] = mid;
		temp[119:104] = appid;
		temp[103:64] = name;
		temp[63:56] = rev;
		temp[55:24] = serialnumber;
		temp[23:20] = 0; // reserved
		temp[19:8] = date;
		temp[7:1] = getCrc(temp); // CRC7
		return temp;
	endfunction

endclass

`endif

