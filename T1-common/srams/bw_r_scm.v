// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: bw_r_scm.v
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
////////////////////////////////////////////////////////////////////////
/*
//	Description:	Store Buffer of Load/Store Unit (CAM Side)
//		 - Physically divided into CAM and DATA RAMs.
//                              - CAM RAM has a single cam port and a single
//                              port for read/writes. The cam port is for loads,
//                              write for stores, read for test/diagnostic purposes.
//                              rd or write can be simultaneous with cam. can rd and cam
//                              a single entry simultaneously. cannot write and cam
//                              the same entry.
//                              - DATA RAM read occurs for a load raw match in the
//                              stb CAM RAM. DATA RAM write occurs a store. Both
//                              actions are architecturally guaranteed to be
//                              mutex.
//                              - Write occurs simultaneously to both arrays.
//                              - Reads are not necessarily simultaneous and are
//                              controlled by individual read signals.
//                              - Certain bits are maintained outside the array
//                              in the stb's control section, such as the valid
//                              bits.                	
//
*/

////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////

//FPGA_SYN enables all FPGA related modifications
`ifdef FPGA_SYN 
`define FPGA_SYN_SCM
`endif

module bw_r_scm (/*AUTOARG*/
   // Outputs
   stb_rdata_ramc, stb_ld_full_raw, stb_ld_partial_raw, 
   stb_cam_hit_ptr, stb_cam_hit, stb_cam_mhit, 
   // Inputs
   stb_cam_data, stb_alt_wr_data, stb_camwr_data, stb_alt_wsel, 
   stb_cam_vld, stb_cam_cm_tid, stb_cam_sqsh_msk, stb_cam_rw_ptr, 
   stb_cam_wptr_vld, stb_cam_rptr_vld, stb_cam_rw_tid, 
   stb_quad_ld_cam, rclk, rst_tri_en
   ) ;	

parameter NUMENTRIES = 32 ;				// number of entries in stb

input	[44:15]		stb_cam_data ;	  // data for compare; disjoint msb
input	[44:15]		stb_alt_wr_data ;	  // data for compare; disjoint msb
input	[14:0]		stb_camwr_data ;  // data for compare/write; common lsb
input			stb_alt_wsel ;
input			stb_cam_vld ;	  // cam is required.
input	[1:0]		stb_cam_cm_tid ;  // thread id for cam operation.
input	[7:0]		stb_cam_sqsh_msk; // mask for squashing cam results.

input 	[2:0]		stb_cam_rw_ptr ;  // wr pointer for single port.
input 	     		stb_cam_wptr_vld ;// write pointer vld
input 	     		stb_cam_rptr_vld ;// write pointer vld
input	[1:0]		stb_cam_rw_tid ;  // thread id for rw.
input 			stb_quad_ld_cam ; // quad-ld cam.

input			rclk ;		  // clock

//input			scan_ena ;	  // no longer required !
//input	[7:0]		adj ;

input			rst_tri_en ;

output	[44:0]		stb_rdata_ramc ;  // rd data from CAM RAM.
// raw output is muxed on a thread basis.
output	[7:0]		stb_ld_full_raw ; // ld with full raw.
output	[7:0]		stb_ld_partial_raw ; // ld with partial raw.
output	[2:0]		stb_cam_hit_ptr ;
output			stb_cam_hit ;	  // any hit in stb
output			stb_cam_mhit ;	  // multiple hits in stb	


/*UTOREG*/
// Beginning of automatic regs (for this module's undeclared outputs)
// End of automatics
reg [44:0]		stb_rdata_ramc ;
reg [31:0]		rw_wdline ;
reg [44:0]		stb_ramc [NUMENTRIES-1:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */;
reg [44:0]		ramc_entry ;
reg [36:0]		cam_tag ;
reg [31:0]		ptag_hit ;
reg [7:0]		cam_bmask ;
reg [31:0]		byte_match ;
reg [31:0]		byte_overlap ;
reg [31:0]		ld_full_raw ;
reg [31:0]		ld_partial_raw ;
reg [44:15]		alt_wr_data ;
wire [44:15]		pipe_wr_data ;
reg [14:0]		camwr_data ;
reg			wptr_vld ; 
reg			rptr_vld_tmp ; 
reg [1:0]	  	cam_tid ;
reg [1:0]	  	cam_vld ;
reg			alt_wsel ;

wire		rptr_vld ; 
wire 		ldq ;
wire	[7:0]	sqsh_msk ;
wire 	[7:0]	ld_full_raw_mx ;
wire    [7:0]	ld_partial_raw_mx ;
wire	[7:0]	ptag_hit_mx ;
wire	[7:0]	byte_overlap_mx ;
wire	[7:0]	byte_match_mx ;
wire	[7:0]	cam_hit ;
wire	[44:0]	wdata_ramc ;
wire	[44:0]	cam_data ;
wire	[44:15] wr_data ;
`ifdef FPGA_SYN_SCM
reg	[4:0]	stb_addr;
`endif

   
integer	i,j,k,l ;


wire	scan_ena ;
assign	scan_ena = 1'b0 ;

//=========================================================================================
//	generate wordlines
//=========================================================================================

assign	sqsh_msk[7:0]	= stb_cam_sqsh_msk[7:0]; 

// cam_vld and cam_tid_tmp are set-up a phase earlier. 
// Comment out - Now setup to posedge.
/*always @(negedge clk)
	begin
		cam_tid_tmp[1:0]	<= stb_cam_cm_tid[1:0] ;
		cam_vld_tmp		<= stb_cam_vld ;
	end */

`ifdef FPGA_SYN_SCM
`else
// Wordlines need to be generated locally 
always @ (posedge rclk)
        begin
                for (i=0;i<32;i=i+1)
                        begin
                        if ({stb_cam_rw_tid[1:0],stb_cam_rw_ptr[2:0]} == i)
                                rw_wdline[i]  <= 1'b1;
                        else
                                rw_wdline[i]  <= 1'b0;
                        end
        end
`endif

assign pipe_wr_data[44:15] = stb_cam_data[44:15];

always @(posedge rclk)
	begin
		alt_wr_data[44:15] <= stb_alt_wr_data[44:15];
		camwr_data[14:0] <= stb_camwr_data[14:0];
		wptr_vld 	<= stb_cam_wptr_vld ;
		rptr_vld_tmp 	<= stb_cam_rptr_vld ;
		cam_tid[1:0]	<= stb_cam_cm_tid[1:0] ;
		//cam_tid[1:0]	<= cam_tid_tmp[1:0] ;
 		//ldq 		<=  stb_quad_ld_cam ; Bug 2870
		alt_wsel 	<= stb_alt_wsel ;
`ifdef FPGA_SYN_SCM
                stb_addr	<= {stb_cam_rw_tid[1:0],stb_cam_rw_ptr[2:0]};
`endif
	end

assign 	ldq =  stb_quad_ld_cam ;
assign  rptr_vld = rptr_vld_tmp | rst_tri_en ;

//=========================================================================================
//	write or read to/from memory
//=========================================================================================

// For blk-st, select out-of-pipe.
assign	wr_data[44:15] = alt_wsel ? 
                alt_wr_data[44:15] : pipe_wr_data[44:15] ;	

assign	wdata_ramc[44:0] = {wr_data[44:15],camwr_data[14:0]};

// Write
always @ (negedge rclk)
	begin
`ifdef FPGA_SYN_SCM
	if(wptr_vld) begin
		if(~rst_tri_en) begin
			stb_ramc[stb_addr] <= wdata_ramc[44:0];
			stb_rdata_ramc[44:0] <=  wdata_ramc[44:0];
                end else begin
			stb_rdata_ramc[44:0] <=  stb_ramc[stb_addr];
		end
	end
`else
		for (j=0;j<NUMENTRIES;j=j+1)
			begin
			if (rw_wdline[j] & wptr_vld)
				begin
				if (~rst_tri_en)
					begin
					stb_ramc[j] <=  wdata_ramc[44:0];
					// write data is write-thru
					stb_rdata_ramc[44:0] <=  wdata_ramc[44:0];
					end
				else
					begin
					// INNO - default rd if wr squashed by scan_ena.
					stb_rdata_ramc[44:0] <=  stb_ramc[j];
					end
				end
			end
`endif
// Read
`ifdef FPGA_SYN_SCM
		if(rptr_vld & ~scan_ena) begin
			if (rptr_vld & wptr_vld & ~rst_tri_en) begin
				stb_rdata_ramc[44:0] <=  wdata_ramc[44:0];
			end
			else begin
				stb_rdata_ramc[44:0] <=  stb_ramc[stb_addr];
			end
		end
`else
		for (k=0;k<NUMENTRIES;k=k+1)
			begin
			if (rw_wdline[k] & rptr_vld & ~scan_ena)
				begin
				if (rptr_vld & wptr_vld & ~rst_tri_en) // INNO - write-thru
                                        stb_rdata_ramc[44:0] <=  wdata_ramc[44:0];
                                else
                                        stb_rdata_ramc[44:0] <=  stb_ramc[k];
				end
			end
`endif
	end

//=========================================================================================
//	CAM contents of CAM RAM
//=========================================================================================

// - Generate full/partial raw for incoming load.
// - Output signals need to be qualified with per entry
// vlds before causing any subsequent event, the read of
// the DATA RAM specifically.
// - full_raw & vld will cause rd of DATA RAM.
// - partial_raw & vld will cause ld to follow corresponding
// st on way out to xbar.
// - logic to generate partial and full raws may be done outside
// but that would require an additional signal per entry to
// be output.

// Mapping of cam/write data
// 
//	| 	40-3=37b(pa)	| 1b(stquad) 	|	8b(bytemask)	| <- use
//	|	45:9		| 8		|	7:0		| <- input port
//				**^ stquad rm'ed

reg [14:0] stb_camwr_data_d;
reg        ldq_d;
reg        stb_cam_vld_d;
reg        scan_ena_d;
reg [44:0]		stb_ramc_d [NUMENTRIES-1:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */;

always @(posedge rclk)
   begin
      stb_camwr_data_d[14:0]<=stb_camwr_data[14:0];
      ldq_d<=ldq;
      stb_cam_vld_d<=stb_cam_vld;
      scan_ena_d<=scan_ena;
		for (l=0;l<NUMENTRIES;l=l+1)
         stb_ramc_d[l]<=stb_ramc[l];
   end

assign	cam_data[44:0] = {stb_cam_data[44:15],stb_camwr_data_d[14:0]}; 

always @( * )
		for (l=0;l<NUMENTRIES;l=l+1)
         begin
				ramc_entry[44:0] = stb_ramc_d[l] ;
				
				cam_tag[36:0] = ramc_entry[44:8] ;
				cam_bmask[7:0] = ramc_entry[7:0] ;
            ptag_hit[l] = (cam_tag[36:1] == cam_data[44:9]) & 
						(((cam_tag[0] == cam_data[8]) & ~ldq_d) | ldq_d) & stb_cam_vld_d & ~scan_ena_d ;
				byte_match[l] = |(cam_bmask[7:0] & cam_data[7:0]) & stb_cam_vld_d & ~scan_ena_d ;
				// Simplification :
				byte_overlap[l] = |(~cam_bmask[7:0] & cam_data[7:0]) & stb_cam_vld_d & ~scan_ena_d ;
         end


// Mux the raw signals down to 8b quantities. Squash mask comes mid-way thru cycle.


assign	byte_overlap_mx[7:0] =
	(cam_tid[1:0] == 2'b00) ? byte_overlap[7:0] :
		(cam_tid[1:0] == 2'b01) ? byte_overlap[15:8] :
			(cam_tid[1:0] == 2'b10) ? byte_overlap[23:16] :
				(cam_tid[1:0] == 2'b11) ? byte_overlap[31:24] : 8'bxxxx_xxxx ;

assign	byte_match_mx[7:0] =
	(cam_tid[1:0] == 2'b00) ? byte_match[7:0] :
		(cam_tid[1:0] == 2'b01) ? byte_match[15:8] :
			(cam_tid[1:0] == 2'b10) ? byte_match[23:16] :
				(cam_tid[1:0] == 2'b11) ? byte_match[31:24] : 8'bxxxx_xxxx ;

assign	ptag_hit_mx[7:0] =
	(cam_tid[1:0] == 2'b00) ? ptag_hit[7:0] :
		(cam_tid[1:0] == 2'b01) ? ptag_hit[15:8] :
			(cam_tid[1:0] == 2'b10) ? ptag_hit[23:16] :
				(cam_tid[1:0] == 2'b11) ? ptag_hit[31:24] : 8'bxxxx_xxxx ;

assign	stb_ld_full_raw[7:0] =  
	ptag_hit_mx[7:0] & byte_match_mx[7:0] & ~byte_overlap_mx[7:0] & ~sqsh_msk[7:0] ;
assign	stb_ld_partial_raw[7:0] =  
	ptag_hit_mx[7:0] & byte_match_mx[7:0] &  byte_overlap_mx[7:0] & ~sqsh_msk[7:0] ;

assign	cam_hit[7:0] = 
	ptag_hit_mx[7:0] & byte_match_mx[7:0] & ~sqsh_msk[7:0] ;
assign	stb_cam_hit = |(cam_hit[7:0]);

// The stb data is meant to be read for single hit full raw case. It may actually be read
// for full raw, partial raw or multiple hit case but the read output will be ignored for
// partial and multiple hit case. Multiple hits will not cause a hazard as the ptr is first
// encoded and then decoded to form the wdline for the stb-data
// Use cam_hit result to void false hits.
assign	stb_cam_hit_ptr[0] 	=  cam_hit[1] | cam_hit[3] | cam_hit[5] | cam_hit[7] ;
assign	stb_cam_hit_ptr[1] 	=  cam_hit[2] | cam_hit[3] | cam_hit[6] | cam_hit[7] ;
assign	stb_cam_hit_ptr[2] 	=  cam_hit[4] | cam_hit[5] | cam_hit[6] | cam_hit[7] ;

//Generating multiple hits
assign  stb_cam_mhit            =  (cam_hit[0]  & cam_hit[1]) | (cam_hit[2] & cam_hit[3])  |
                                   (cam_hit[4]  & cam_hit[5]) | (cam_hit[6] & cam_hit[7])  |
                                   ((cam_hit[0] | cam_hit[1]) & (cam_hit[2] | cam_hit[3])) |
                                   ((cam_hit[4] | cam_hit[5]) & (cam_hit[6] | cam_hit[7])) |
                                   ((|cam_hit[3:0]) & (|cam_hit[7:4]));

//--------------------------------------------------------------
// Error Checking.
//--------------------------------------------------------------

// 1. simultaneous rd/wr on single port - terminate 
// 2. simultaneous cam and wr - terminate
// * PUT OUTSIDE OF SRAM RTL, AS RST NOT AVAILABLE. *

endmodule
