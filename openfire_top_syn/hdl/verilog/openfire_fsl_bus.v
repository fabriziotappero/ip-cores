/*

MODULE: openfire_fsl_bus

DESCRIPTION: This is a one-way Fast Simplex Link (FSL) bus implementation.
See MicroBlaze documentation for detailed information.  This implementation
is 32-bits wide, uses an active high reset, and has a FIFO depth of 1.

When creating an OpenFire system using the EDK, this module is not needed.

AUTHOR: 
Stephen Douglas Craven
Configurable Computing Lab
Virginia Tech
scraven@vt.edu

REVISION HISTORY:
Revision 0.2, 8/10/2005 SDC
Initial release

COPYRIGHT:
Copyright (c) 2005 Stephen Douglas Craven

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.

*/

module openfire_fsl_bus (
	clock, reset,
	fsl_s_data, fsl_s_control, fsl_s_exists, fsl_m_full,
	fsl_m_data, fsl_m_control, fsl_m_write, fsl_s_read);

input		clock;
input		reset;

input	[31:0]	fsl_m_data;
input		fsl_m_control;
input		fsl_m_write;
input		fsl_s_read;

output	[31:0]	fsl_s_data;
output		fsl_s_control;
output		fsl_m_full;
output		fsl_s_exists;

reg		fsl_m_full;
reg		fsl_s_exists;

reg	[32:0]	fsl_data; // includes control bit

assign	fsl_s_data = fsl_data[31:0];
assign	fsl_s_control = fsl_data[32];

always@(posedge clock)
begin
	if (reset)
		begin
			fsl_data	<= 0;
			fsl_m_full	<= 0;
			fsl_s_exists	<= 0;
		end
	else
		begin
			if (fsl_m_write)
				begin
					fsl_m_full	<= 1;
					fsl_s_exists	<= 1;
					fsl_data	<= {fsl_m_control, fsl_m_data};
				end
			if (fsl_s_read)
				begin
					fsl_s_exists		<= 0;
					fsl_m_full		<= 0;
				end
		end
end

endmodule
			
					
					
