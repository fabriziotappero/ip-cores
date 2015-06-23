////////////////////////////////////////////////////////////////////////////////
//
//  XGATE Coprocessor - XGATE interrupt encoder
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


module xgate_irq_encode #(parameter MAX_CHANNEL = 127)    // Max XGATE Interrupt Channel Number
(
  output reg          [ 6:0] int_req,     // Encoded interrupt request to RISC
  output     [MAX_CHANNEL:1] xgif,        // Interrupt outputs to Host

  input      [MAX_CHANNEL:1] chan_req_i,  // XGATE Interrupt requests from peropherials
  input      [MAX_CHANNEL:1] chan_bypass, // XGATE Interrupt bypass
  input      [MAX_CHANNEL:1] xgif_status  // Interrupt outputs from RISC core
);

  integer i;  // Loop Counter for array index
  wire [MAX_CHANNEL:1] chan_ena_gate;  // Ouptut of channel enable gating

  // Pass non-bypassed interrupt inputs to XGATE RISC
  assign chan_ena_gate = ~chan_bypass & chan_req_i;

  // Set int_reg to the index of the index of the lowest chan_req_i input that is active
  always @(chan_ena_gate)
    begin
      int_req = 0;
        for (i = MAX_CHANNEL; i >= 1; i = i - 1)
          if (chan_ena_gate[i] == 1'b1)
            int_req = i;
    end

  // XGATE output interrupt mux
  assign xgif = (chan_bypass & chan_req_i) | (~chan_bypass & xgif_status);


endmodule  // xgate_irq_encode



