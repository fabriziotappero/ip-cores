////////////////////////////////////////////////////////////////////////////////
//
//  Computer Operating Properly - Control registers
//
//  Author: Bob Hayes
//          rehayes@opencores.org
//
//  Downloaded from: http://www.opencores.org/projects/cop.....
//
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009, Robert Hayes
//
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
////////////////////////////////////////////////////////////////////////////////
// 45678901234567890123456789012345678901234567890123456789012345678901234567890

module cop_regs #(parameter ARST_LVL = 1'b0,      // asynchronous reset level
                  parameter INIT_ENA = 1'b1,      // COP Enabled after reset
                  parameter SERV_WD_0 = 16'h5555, // First Service Word
		  parameter SERV_WD_1 = 16'haaaa, // Second Service Word
                  parameter COUNT_SIZE = 16,
                  parameter DWIDTH = 16)
  (
  output reg [COUNT_SIZE-1:0] timeout_value,// COP timout Value
  output reg           [ 1:0] cop_irq_en,   // COP IRQ Enable/Value
  output reg                  debug_ena,    // Enable COP in system debug mode
  output reg                  stop_ena,     // Enable COP in system stop mode
  output reg                  wait_ena,     // Enable COP in system wait mode
  output reg                  cop_ena,      // Enable COP Timout Counter
  output reg                  cwp,          // COP write protect
  output reg                  clck,         // COP lock
  output reg                  reload_count, // COP System service complete
  output reg                  clear_event,  // Reset the COP event register
  input                       bus_clk,      // Control register bus clock
  input                       async_rst_b,  // Async reset signal
  input                       sync_reset,   // Syncronous reset signal
  input                       cop_flag,     // COP Rollover Flag
  input          [DWIDTH-1:0] write_bus,    // Write Data Bus
  input                [ 4:0] write_regs    // Write Register strobes
  );


  // registers
  reg         service_cop; // Service register to reload COP Timeout Counter

  // Wires
  wire [15:0] write_data; // Data bus mux for 8 or 16 bit module bus

  //
  // module body
  //
  
  assign write_data = (DWIDTH == 8) ? {write_bus[7:0], write_bus[7:0]} : write_bus;
  
  
  // generate wishbone write registers
  always @(posedge bus_clk or negedge async_rst_b)
    if (!async_rst_b)
      begin
	timeout_value <= {COUNT_SIZE{1'b1}};
        cop_irq_en    <= 2'b00;
        debug_ena     <= 1'b0;
        stop_ena      <= 1'b0;
        wait_ena      <= 1'b0;
        cop_ena       <= INIT_ENA;
        cwp           <= 1'b0;
	clck          <= 1'b0;
	reload_count  <= 1'b0;
	service_cop   <= 0;
       end
    else if (sync_reset)
      begin
	timeout_value <= {COUNT_SIZE{1'b1}};
        cop_irq_en    <= 2'b00;
        debug_ena     <= 1'b0;
        stop_ena      <= 1'b0;
        wait_ena      <= 1'b0;
        cop_ena       <= INIT_ENA;
        cwp           <= 1'b0;
	clck          <= 1'b0;
	reload_count  <= 1'b0;
	service_cop   <= 0;
      end
    else
      case (write_regs) // synopsys parallel_case
         5'b00011 :  // Word Write
           begin
             clear_event <= write_data[8];
             cop_irq_en  <= write_data[7:6];
             debug_ena   <= (!cop_ena || !write_data[2]) ? write_data[5] : debug_ena;
             stop_ena    <= (!cop_ena || !write_data[2]) ? write_data[4] : stop_ena;
             wait_ena    <= (!cop_ena || !write_data[2]) ? write_data[3] : wait_ena;
             cop_ena     <= cwp  ? cop_ena : write_data[2];
             cwp         <= clck ? cwp : write_data[1];
             clck        <= clck || write_data[0];
           end
         5'b00001 :  // Low Byte Write
           begin
             cop_irq_en  <= write_data[7:6];
             debug_ena   <= (!cop_ena || !write_data[2]) ? write_data[5] : debug_ena;
             stop_ena    <= (!cop_ena || !write_data[2]) ? write_data[4] : stop_ena;
             wait_ena    <= (!cop_ena || !write_data[2]) ? write_data[3] : wait_ena;
             cop_ena     <= cwp ? cop_ena : write_data[2];
             cwp         <= clck ? cwp : write_data[1];
             clck        <= clck || write_data[0];
           end
         5'b00010 :  // High Byte Write
           begin
             clear_event  <= write_data[0];
           end

	 5'b01100 : timeout_value        <= cop_ena ? timeout_value : write_data;
         5'b00100 : timeout_value[ 7:0]  <= cop_ena ? timeout_value[ 7:0] : write_data[7:0];
         5'b01000 : timeout_value[15:8]  <= cop_ena ? timeout_value[15:8] : write_data[7:0];
	 
         5'b10000 :
	   begin
	     service_cop  <= (write_data == SERV_WD_0);
	     reload_count <= service_cop && (write_data == SERV_WD_1);
	   end
         default:
	   begin
	     reload_count <= 1'b0;
	     clear_event  <= 1'b0;
	   end
      endcase


endmodule  // cop_regs
