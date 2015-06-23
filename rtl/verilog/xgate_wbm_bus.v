////////////////////////////////////////////////////////////////////////////////
//
//  WISHBONE revB.2 compliant Xgate Coprocessor - Master Bus interface
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

module xgate_wbm_bus #(parameter ARST_LVL = 1'b0,    // asynchronous reset level
                       parameter DWIDTH   = 16,
                       parameter SINGLE_CYCLE = 1'b0)
  (
  // Wishbone Signals
  output      [DWIDTH-1:0] wbm_dat_o,     // databus output
  output                   wbm_we_o,      // write enable output
  output                   wbm_stb_o,     // stobe/core select signal
  output                   wbm_cyc_o,     // valid bus cycle output
  output            [ 1:0] wbm_sel_o,     // Select byte in word bus transaction
  output            [15:0] wbm_adr_o,     // Address bits
  input       [DWIDTH-1:0] wbm_dat_i,     // databus input
  input                    wbm_ack_i,     // bus cycle acknowledge input
  // XGATE Control Signals
  output      [DWIDTH-1:0] read_mem_data,    // Data from system memory
  output                   mem_req_ack,      // Memory bus transaction complete
  input                    risc_clk,         //
  input                    async_rst_b,      //
  input                    xge,              // XGATE Enabled
  input                    single_step,      // Pulse to trigger a single instruction execution in debug mode
  output                   ss_mem_ack,       // WISHBONE Bus has granted single step memory access
  input             [15:0] xgate_address,    // Address to system memory
  input                    mem_access,       //
  input                    write_mem_strb_l, // Strobe for writing low data byte
  input                    write_mem_strb_h, // Strobe for writing high data bye
  input       [DWIDTH-1:0] write_mem_data    // Data to system memory
  );


  // Wires and Registers
  wire   module_sel;       // This module is selected for bus transaction
  reg    ss_mem_req;       // Bus request for single step memory access

  //
  // Module body
  //

  // Latch Single Step Request and ask for memory access
  always @(posedge risc_clk or negedge async_rst_b)
    if ( !async_rst_b )
      ss_mem_req <= 1'b0;
    else
      ss_mem_req <= (single_step || ss_mem_req) && !wbm_ack_i && xge;

  assign ss_mem_ack = ss_mem_req && wbm_ack_i;


  assign wbm_dat_o = write_mem_data;
  assign read_mem_data = wbm_dat_i;
  assign wbm_adr_o = xgate_address;

  assign mem_req_ack = wbm_ack_i;

  assign wbm_we_o = write_mem_strb_h || write_mem_strb_l;

  assign wbm_sel_o = {write_mem_strb_h, write_mem_strb_l};

  assign wbm_cyc_o = xge && (mem_access || ss_mem_req);

  assign wbm_stb_o = xge && (mem_access || ss_mem_req);

endmodule  // xgate_wbm_bus
