//                              -*- Mode: Verilog -*-
// Filename        : oks8_power.v
// Description     : OKS8 Simple Timing Generator, IDLE/STOP & Interrupt control
// Author          : Jian Li
// Created On      : Sat Jan 07 09:09:49 2006
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

/*
 * Copyright (C) 2006 to Jian Li
 * Contact: kongzilee@yahoo.com.cn
 * 
 * This source file may be used and distributed without restriction
 * provided that this copyright statement is not removed from the file
 * and that any derivative works contain the original copyright notice
 * and the associated disclaimer.
 * 
 * THIS SOFTWARE IS PROVIDE "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
 * SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

`include "oks8_defines.v"

// =====================================================================
// OKS8_POWER
// This is used to generate the system and CPU clock.
// =====================================================================
module oks8_power (/*AUTOARG*/
  // Inputs
  clk_i, rst_i,
  int_i, dp_i,
  // Outputs
  s$_clk, p$_clk, s$_rst, s$_int);

// EXTERNAL CONTROL SIGNALS
input clk_i, rst_i;

// SYSTEM & CPU CLOCK SIGNALS
output s$_clk, p$_clk, s$_rst;

// INTERRUPTS
input int_i;
output s$_int;

// DECODER INTERFACE
input [1:0] dp_i;
reg idle, stop;

assign s$_clk = (stop) ? 1'b0 : clk_i;
assign p$_clk = (idle) ? 1'b0 : clk_i;
assign s$_rst = rst_i;
assign s$_int = int_i;

always @(posedge clk_i)
  if (rst_i || int_i) begin
	idle <= 0;
	stop <= 0;
  end else begin
	stop <= dp_i[1];
	idle <= dp_i[0];
  end

endmodule	// oks8_power
