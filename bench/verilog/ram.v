////////////////////////////////////////////////////////////////////////////////
//
//  WISHBONE revB.2 compliant Xgate Coprocessor - test bench ram
//
//  Author: Bob Hayes
//          rehayes@opencores.org
//
//  Downloaded from: http://www.opencores.org/projects/xgate.....
//
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009, Robert Hayes
//
// This source file is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Supplemental terms.
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Neither the name of the <organization> nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY Robert Hayes ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL Robert Hayes BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////////////
// 45678901234567890123456789012345678901234567890123456789012345678901234567890


module ram #(parameter AWIDTH = 16,          // Address Bus width
             parameter DWIDTH = 16)          // Data bus width
  (
  // Wishbone Slave Signals
  output    [DWIDTH-1:0] ram_out,       // databus output

  input     [AWIDTH-1:0] address,       // lower address bits
  input     [DWIDTH-1:0] ram_in,        // databus input
  input                  we,            // write enable input
  input                  ce,            // Chip Enable
  input                  stb,           // stobe/core select signal
  input  [DWIDTH/8 -1:0] sel            // Select byte in word bus transaction
  );

  // Name Address Locations
  parameter XGATE_XGMCTL   = 16'h0000;

  //
  // wires && regs
  //
  reg       [  7:0] ram_8 [65535:0];    // Testbench memory for holding XGATE test code


  // Write memory interface to RAM
  always @(posedge stb)
    begin
      if (ce && sel[0] && !sel[1] && we)
        ram_8[address] <= ram_in[7:0];
      if (ce && sel[1] && !sel[0] && we)
        ram_8[address] <= ram_in[7:0];
      if (ce && sel[1] && sel[0] && we)
        begin
          ram_8[address]   <= ram_in[15:8];
          ram_8[address+1] <= ram_in[ 7:0];
        end
    end

  // BIGENDIAN
  assign ram_out = {DWIDTH{ce}} & {ram_8[address], ram_8[address+1]};


  task dump_ram;
    input [AWIDTH-1:0] start_address;
    reg   [AWIDTH-1:0] dump_address;
    integer i, j;
    begin
        $display("Dumping RAM - Starting Address #%h", start_address);

        dump_address = start_address;
        while (dump_address <= start_address + 16'h0080)
          begin
            $write("Address = %h", dump_address);
            for (i = 0; i < 16; i = i + 1)
              begin
                $write(" %h", ram_8[dump_address]);
                dump_address = dump_address + 1;
              end
            $write("\n");
          end

    end
  endtask



endmodule  // ram

