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
// File        : Logger.sv
// Owner       : Rainer Kastl
// Description : Logging facility for verification
// Links       : 
// 

`ifndef LOGGER_SV
`define LOGGER_SV

class Logger;

	local static int errors = 0;
	local static int warnings = 0;

	function new();
	endfunction

	function void note(string msg);
		$write("Note at %t: ", $time);
		$display(msg);
	endfunction

	function void warning(string msg);
		$write("Warning at %t: ", $time);
		$display(msg);
		warnings++;
	endfunction

	function void error(string msg);
		$write("Error at %t: ", $time);
		$display(msg);
		errors++;
	endfunction

	function void terminate();
		$display("Simulation %0sED", (errors) ? "FAIL" : "PASS");
		if (errors > 0) begin
			$display("%d errors.", errors);
		end

		if (warnings > 0) begin
			$display("%d warnings.", warnings);
		end
	endfunction

endclass

`endif
  
