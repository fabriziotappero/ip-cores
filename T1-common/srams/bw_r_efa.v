// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: bw_r_efa.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
// 
// The above named program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
// 
// ========== Copyright Header End ============================================
//****************************************************************
//
//      Module:         bw_r_efa
//
//      Description:   RTL model for EFA (EFuse Array)
//
//****************************************************************
`include "sys.h"

module bw_r_efa (
	vpp,
	pi_efa_prog_en, 
	sbc_efa_read_en,
	sbc_efa_word_addr,	
	sbc_efa_bit_addr,
	sbc_efa_margin0_rd,
	sbc_efa_margin1_rd,
	efa_sbc_data,
 	pwr_ok,
	por_n,
        sbc_efa_sup_det_rd,
	sbc_efa_power_down,
	so,
	si,
	se,
	vddo,
	clk
);


input            vpp;			// VPP input from I/O

output  [31:0]   efa_sbc_data;		// Data from e-fuse array to SBC
input            pi_efa_prog_en; 	// e-fuse array program enable
input            sbc_efa_read_en; 	// e-fuse array read enable
input	[5:0]    sbc_efa_word_addr;	// e-fuse array word addr
input   [4:0]    sbc_efa_bit_addr;	// e-fuse array bit addr
input            sbc_efa_margin0_rd; 	// e-fuse array margin0 read
input            sbc_efa_margin1_rd;	// e-fuse array margin1 read

input		 pwr_ok;		// power_ok reset
input		 por_n;			// por_n reset
input		 sbc_efa_sup_det_rd;	// e-fuse array supply detect read
input		 sbc_efa_power_down;	// e-fuse power down signal from SBC

output           so;		// Scan ports
input            si;
input		 se;
input 		 vddo;
input            clk; 			// cpu clk

/*--------------------------------------------------------------------------*/

//** Parameters and define **//
parameter MAXFILENAME=200;
//parameter 	EFA_READ_LAT = 5670 ; // 7 system cycles (150Mhz) - 1/4(sys clk); about 45ns
				     // 840 ticks = 1 system cycle
parameter 	EFA_READ_LAT = 45000 ; //  about 45ns (timescale is 1 ps)
/* The access time has been specified to be 45ns for a worst case read */

//** Wire and Reg declarations **//

reg [MAXFILENAME*8-1:0]  efuse_data_filename;
reg [31:0] efuse_array[0:63],efuse_row,efa_read_data;	//EFUSE ARRAY
integer file_get_status,i;
reg [31:0] fpInVec;
wire [31:0] efa_sbc_data;
wire	l1clk;		
wire   	lvl_det_l;           // level detect ok
wire    vddc_ok_l;           // vddc ok
wire    vddo_ok_l;           // vddo ok
wire    vpp_ok_l;            // vpp ok
reg     efuse_rd_progress;
reg	efuse_enable_write_check;

/*--------------------------------------------------------------------------*/

// Process data file
 
// synopsys translate_off
initial 
begin
  efuse_enable_write_check = 1;
  // Get Efuse data file from plusarg.
  if ($value$plusargs("efuse_data_file=%s", efuse_data_filename))
    begin
      // Read Efuse data file if present 
      $display("INFO: efuse data file is being read--filename=%0s", 
      			efuse_data_filename);
      $readmemh(efuse_data_filename, efuse_array);
      $display("INFO: completed reading efuse data file");
    end
  else 
    begin 
      //if file not present, initialize efuse_array with default value
      $display("INFO: Using default efuse data for the efuse array");
      for (i=0;i<=63;i=i+1) begin
	efuse_array[i] = 32'b0;
      end
    end
end   

// Process power down signal
assign l1clk   = clk & ~sbc_efa_power_down;

// Scan logic not in RTL 
assign so = se ? si : 1'bx;

//assign supply detect signals to valid values (circuit cannot be impl in model)
assign vddc_ok_l = 1'b0;
assign vddo_ok_l = 1'b0;
assign vpp_ok_l  = 1'b0;
assign lvl_det_l = 1'b0;


always @(posedge l1clk) begin
  // Write operation , one bit at a time
  if ((pi_efa_prog_en === 1'b1) && (pwr_ok === 1'b1) && (por_n === 1'b1))  begin
    efuse_row = efuse_array[sbc_efa_word_addr];
    efuse_row[sbc_efa_bit_addr] = 1'b1;
    efuse_array[sbc_efa_word_addr] <= efuse_row;
  end
end


// efa_read_data is from the VPP_CORE which is reset to 0 in ckt when read is de-asserted
// However in RTL it is reset to X because I want to simulate the wait time where
// efa_read_data is indeed X till the latency period
// margin reads are not modelled in the RTL
always @(posedge l1clk) begin
  // Read operation  , 32 bits at a time
  if ((sbc_efa_read_en) & ~efuse_rd_progress)  begin
   // About 45ns
   efa_read_data[31:0] <= #EFA_READ_LAT efuse_array[sbc_efa_word_addr];
   efuse_rd_progress = 1'b1;
  end
  if (~(sbc_efa_read_en))  begin
    efuse_rd_progress = 1'b0;
  end
  if (~efuse_rd_progress) begin
    efa_read_data[31:0] <= 32'bx;
  end
end
// synopsys translate_on

// In ckt, when sbc_efa_read_en is low, output remains the same.

assign efa_sbc_data[31:0] = por_n ? ((pwr_ok & sbc_efa_read_en) ? (sbc_efa_sup_det_rd ?
				{28'bx,~lvl_det_l,~vddc_ok_l,~vddo_ok_l,~vpp_ok_l}
				: efa_read_data[31:0] ) : efa_sbc_data[31:0]) : 32'b0;


endmodule
