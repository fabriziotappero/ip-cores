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
// File        : Crc.sv
// Owner       : Rainer Kastl
// Description : CRC calculations using SD CRC polynoms
// Links       : 
// 

`ifndef CRC
`define CRC

typedef logic[6:0] aCrc7;
typedef logic[15:0] aCrc16;

function automatic aCrc7 calcCrc7(logic data[$]);
	aCrc7 crc = 0;

	for(int i = 0; i < data.size(); i++) begin
		if (((crc[6] & 1)) != data[i])
			 crc = (crc << 1) ^ 'b10001001;
		else
			 crc <<= 1;	
	end
	return crc;	
endfunction

function automatic aCrc16 calcCrc16(logic data[$]);
	aCrc16 crc = 0;

	for(int i = 0; i < data.size(); i++) begin
		if (((crc[15] & 1)) != data[i])
			 crc = (crc << 1) ^ 'b10001000000100001;
		else
			 crc <<= 1;	
	end
	return crc;	

endfunction

`endif

