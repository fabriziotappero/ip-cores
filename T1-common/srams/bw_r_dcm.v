// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: bw_r_dcm.v
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
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////

// The Four panels correspond to addr<10:9> decoded.

module bw_r_dcm(  /*AUTOARG*/
   // Outputs
   row_hit, rd_data0, rd_data1, rd_data2, rd_data3, so_0, so_1, 
   // Inputs
   cam_en, inv_mask0, inv_mask1, inv_mask2, inv_mask3, si_0, se_0, 
   si_1, se_1, sehold_0, sehold_1, rclk,  rd_en, rw_addr0, 
   rw_addr1, rw_addr2, rw_addr3, rst_l_0, rst_l_1, rst_warm_0, 
   rst_warm_1, wr_en, rst_tri_en_0, rst_tri_en_1, wr_data0, wr_data1, 
   wr_data2, wr_data3
   );

output	[31:0]	row_hit;

output [31:0]         rd_data0;               // From panel0 of dcm_panel.v
output [31:0]         rd_data1;               // From panel1 of dcm_panel.v
output [31:0]         rd_data2;               // From panel2 of dcm_panel.v
output [31:0]         rd_data3;               // From panel3 of dcm_panel.v

input   [3:0]         cam_en;

input [7:0]           inv_mask0;              // To panel0 of dcm_panel.v
input [7:0]           inv_mask1;              // To panel1 of dcm_panel.v
input [7:0]           inv_mask2;              // To panel2 of dcm_panel.v
input [7:0]           inv_mask3;              // To panel3 of dcm_panel.v

input		      si_0, se_0;
output		      so_0;
input		      si_1, se_1;
output		      so_1;
input		      sehold_0;
input		      sehold_1;

input                 rclk;                   // To panel0 of dcm_panel.v, ...

input  [3:0]          rd_en ;           // To panel0 of dcm_panel.v

input [5:0]           rw_addr0;      // To panel0 of dcm_panel.v
input [5:0]           rw_addr1;      // To panel1 of dcm_panel.v
input [5:0]           rw_addr2;      // To panel2 of dcm_panel.v
input [5:0]           rw_addr3;      // To panel3 of dcm_panel.v

input                 rst_l_0;                  // To panel0 of dcm_panel.v, ...
input                 rst_l_1;                  // To panel0 of dcm_panel.v, ...
input		      rst_warm_0;
input		      rst_warm_1;

input   [3:0]         wr_en;            // To panel0 of dcm_panel.v
input		      rst_tri_en_0; // used to disable writes during SCAN.
input		      rst_tri_en_1; // used to disable writes during SCAN.

input [32:0]          wr_data0;         // To panel0 of dcm_panel.v
input [32:0]          wr_data1;         // To panel1 of dcm_panel.v
input [32:0]          wr_data2;         // To panel2 of dcm_panel.v
input [32:0]          wr_data3;         // To panel3 of dcm_panel.v


wire	[31:0]	bank1_hit;
wire	[31:0]	bank0_hit;

/*	dcm_panel_pair	AUTO_TEMPLATE (

		   		  .bank_hit(bank0_hit[31:0]),
                                  .rd_data0(rd_data0[31:0]),
                                  .rd_data1(rd_data1[31:0]),
                                  // Inputs
                                  .cam_en(cam_en[1:0]),
                                  .inv_mask0(inv_mask0[7:0]),
                                  .inv_mask1(inv_mask1[7:0]),
                                  .rclk (rclk),
                                  .rd_en(rd_en[1:0]),
                                  .rst_l(rst_l_0),
                                  .rst_tri_en(rst_tri_en_0),
                                  .rst_warm(rst_warm_0),
                                  .rw_addr0(rw_addr0[5:0]),
                                  .rw_addr1(rw_addr1[5:0]),
                                  .sehold(sehold_0),
                                  .wr_data0(wr_data0[32:0]),
                                  .wr_data1(wr_data1[32:0]),
                                  .wr_en(wr_en[1:0]));

*/

      dcm_panel_pair	panel_pair0(
                                  .so   (),
                                  .si   (),
                                  .se   (se_0),
					/*AUTOINST*/
                                  // Outputs
                                  .bank_hit(bank0_hit[31:0]),    // Templated
                                  .rd_data0(rd_data0[31:0]),     // Templated
                                  .rd_data1(rd_data1[31:0]),     // Templated
                                  // Inputs
                                  .cam_en(cam_en[1:0]),          // Templated
                                  .inv_mask0(inv_mask0[7:0]),    // Templated
                                  .inv_mask1(inv_mask1[7:0]),    // Templated
                                  .rclk (rclk),                  // Templated
                                  .rd_en(rd_en[1:0]),            // Templated
                                  .rst_l(rst_l_0),               // Templated
                                  .rst_tri_en(rst_tri_en_0),     // Templated
                                  .rst_warm(rst_warm_0),         // Templated
                                  .rw_addr0(rw_addr0[5:0]),      // Templated
                                  .rw_addr1(rw_addr1[5:0]),      // Templated
                                  .sehold(sehold_0),             // Templated
                                  .wr_data0(wr_data0[32:0]),     // Templated
                                  .wr_data1(wr_data1[32:0]),     // Templated
                                  .wr_en(wr_en[1:0]));            // Templated
				
	assign	 row_hit =  bank1_hit | bank0_hit ;

/*      dcm_panel_pair  AUTO_TEMPLATE (

                                  .bank_hit(bank1_hit[31:0]),
                                  .rd_data0(rd_data2[31:0]),
                                  .rd_data1(rd_data3[31:0]),
                                  // Inputs
                                  .cam_en(cam_en[3:2]),
                                  .inv_mask0(inv_mask2[7:0]),
                                  .inv_mask1(inv_mask3[7:0]),
                                  .rclk (rclk),
                                  .rd_en(rd_en[3:2]),
                                  .rst_l(rst_l_1),
                                  .rst_tri_en(rst_tri_en_1),
                                  .rst_warm(rst_warm_1),
                                  .rw_addr0(rw_addr2[5:0]),
                                  .rw_addr1(rw_addr3[5:0]),
                                  .sehold(sehold_1),
                                  .wr_data0(wr_data2[32:0]),
                                  .wr_data1(wr_data3[32:0]),
                                  .wr_en(wr_en[3:2]));

*/

      dcm_panel_pair    panel_pair1(
                                  .so   (),
                                  .si   (),
                                  .se   (se_1),
                                        /*AUTOINST*/
                                    // Outputs
                                    .bank_hit(bank1_hit[31:0]),  // Templated
                                    .rd_data0(rd_data2[31:0]),   // Templated
                                    .rd_data1(rd_data3[31:0]),   // Templated
                                    // Inputs
                                    .cam_en(cam_en[3:2]),        // Templated
                                    .inv_mask0(inv_mask2[7:0]),  // Templated
                                    .inv_mask1(inv_mask3[7:0]),  // Templated
                                    .rclk(rclk),                 // Templated
                                    .rd_en(rd_en[3:2]),          // Templated
                                    .rst_l(rst_l_1),             // Templated
                                    .rst_tri_en(rst_tri_en_1),   // Templated
                                    .rst_warm(rst_warm_1),       // Templated
                                    .rw_addr0(rw_addr2[5:0]),    // Templated
                                    .rw_addr1(rw_addr3[5:0]),    // Templated
                                    .sehold(sehold_1),           // Templated
                                    .wr_data0(wr_data2[32:0]),   // Templated
                                    .wr_data1(wr_data3[32:0]),   // Templated
                                    .wr_en(wr_en[3:2]));          // Templated


endmodule



module dcm_panel_pair(  /*AUTOARG*/
   // Outputs
   so, bank_hit, rd_data0, rd_data1, 
   // Inputs
   cam_en, inv_mask0, inv_mask1, rclk, rd_en, rst_l, rst_tri_en, 
   rst_warm, rw_addr0, rw_addr1, sehold, wr_data0, wr_data1, wr_en, 
   si, se
   );

input [1:0]             cam_en;                 
input [7:0]             inv_mask0;              
input [7:0]             inv_mask1;              
input                   rclk;                   
input [1:0]             rd_en;                  
input                   rst_l;                
input                   rst_tri_en;           
input                   rst_warm;             
input [5:0]             rw_addr0;               
input [5:0]             rw_addr1;               
input                   sehold;               
input [32:0]            wr_data0;               
input [32:0]            wr_data1;               
input [1:0]             wr_en;                  
input			si,se ;

output			so;
output [31:0]           bank_hit;              
output [31:0]           rd_data0;               
output [31:0]           rd_data1;               

wire	[31:0]	lkup_hit0, lkup_hit1;
reg	rst_warm_d;


always  @(posedge rclk)
begin
	rst_warm_d <= ( sehold)? rst_warm_d : rst_warm;
end

/*      dcm_panel       AUTO_TEMPLATE (
                   .lkup_hit            (lkup_hit@[31:0]),
                   .rd_data            (rd_data@[31:0]),
                   .rd_en          (rd_en[@]),
                   .wr_en          (wr_en[@]),
                   .cam_en              (cam_en[@]),
                   .wr_data             (wr_data@[32:0]),
                   .rw_addr             (rw_addr@[5:0]),
                   .rst_l               (rst_l),
                   .rst_warm               (rst_warm_d),
                   .rst_tri_en               (rst_tri_en),
                   .sehold               (sehold),
                   .inv_mask            (inv_mask@[7:0]));
*/

        dcm_panel       panel0(.si(),
			       .so(),
			       .se(se),
				/*AUTOINST*/
                               // Outputs
                               .lkup_hit(lkup_hit0[31:0]),       // Templated
                               .rd_data (rd_data0[31:0]),        // Templated
                               // Inputs
                               .rd_en   (rd_en[0]),              // Templated
                               .wr_en   (wr_en[0]),              // Templated
                               .cam_en  (cam_en[0]),             // Templated
                               .wr_data (wr_data0[32:0]),        // Templated
                               .rw_addr (rw_addr0[5:0]),         // Templated
                               .inv_mask(inv_mask0[7:0]),        // Templated
                               .rst_l   (rst_l),                 // Templated
                               .rclk    (rclk),
                               .rst_warm(rst_warm_d),            // Templated
                               .rst_tri_en(rst_tri_en),          // Templated
                               .sehold  (sehold));                // Templated

        assign   bank_hit      =    lkup_hit0 | lkup_hit1 ;

        dcm_panel       panel1(.si(),
                               .so(),
                               .se(se),
				/*AUTOINST*/
                               // Outputs
                               .lkup_hit(lkup_hit1[31:0]),       // Templated
                               .rd_data (rd_data1[31:0]),        // Templated
                               // Inputs
                               .rd_en   (rd_en[1]),              // Templated
                               .wr_en   (wr_en[1]),              // Templated
                               .cam_en  (cam_en[1]),             // Templated
                               .wr_data (wr_data1[32:0]),        // Templated
                               .rw_addr (rw_addr1[5:0]),         // Templated
                               .inv_mask(inv_mask1[7:0]),        // Templated
                               .rst_l   (rst_l),                 // Templated
                               .rclk    (rclk),
                               .rst_warm(rst_warm_d),            // Templated
                               .rst_tri_en(rst_tri_en),          // Templated
                               .sehold  (sehold));                // Templated


endmodule


////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
// A directory panel is 32 bits wide and 64 entries deep.
// The lkup_hit combines the match lines for an even and odd entry pair
// and hence is only 32 bits wide.
////////////////////////////////////////////////////////////////////////


module dcm_panel(  /*AUTOARG*/
   // Outputs
   lkup_hit, rd_data, so, 
   // Inputs
   rd_en, wr_en, cam_en, wr_data, rw_addr, inv_mask, rst_l, rclk, 
   rst_warm, si, se, rst_tri_en, sehold
   );


// Read inputs
input		rd_en;
input		wr_en;
input		cam_en;
input	[32:0]	wr_data; // { addr<39:10>, addr<8>, parity, valid  }


// shared inputs 
input	[5:0]	rw_addr; // even entries will have wr_data<0> == 0
input	[7:0]	inv_mask;


output	[31:0]	lkup_hit;
output	[31:0]	rd_data; // { addr<39:10>, parity, valid } 

input		rst_l;
input		rclk;
input		rst_warm;

input		si, se;
output		so;
input		rst_tri_en;
input		sehold;


reg	[29:0]	addr_array[63:0]	;
reg	[63:0]	valid	;
reg	[63:0]	parity	;
reg	[29:0]	temp_addr0 ;
reg	[29:0]	temp_addr1 ;
reg	[31:0]	rd_data;
reg	[31:0]	lkup_hit;
reg	[63:0]	cam_hit;


reg	[63:0]	reset_valid;
reg	[63:0]	valid_bit;

reg             rd_en_d, wr_en_d;
reg             cam_en_d ;
reg     [7:0]   inval_mask_d;
reg     [5:0]   rw_addr_d;
//reg	wr_en_off_d1;
reg	rst_tri_en_d1;


wire	[7:0]	inval_mask;
integer	i,j;

always  @(posedge rclk)
begin
        rd_en_d <= (sehold)? rd_en_d: rd_en ;
        wr_en_d <= (sehold)? wr_en_d: wr_en;
        rw_addr_d <= (sehold)? rw_addr_d : rw_addr  ;
        cam_en_d <= ( sehold)? cam_en_d: cam_en ;
        inval_mask_d <= ( sehold)? inval_mask_d : inv_mask ;

	rst_tri_en_d1 <= rst_tri_en ; // this is a dummy flop only used as a trigger
end



//--------\/-------------
// VALID flop logic
//--------\/-------------
always  @(posedge rclk) begin
		valid_bit <= valid;
end
	

reg	cam_out;


// CAM OPERATION and reset_valid generation
// the following always block ensures that lkup_hit will be 
// a ph1 signal.

always	@( /*AUTOSENSE*/ /*memory or*/ cam_en_d or inval_mask_d or rst_tri_en or
           rst_tri_en_d1 or valid_bit or wr_data or rst_warm or rst_l)

 begin


		cam_out = cam_en_d & ~(rst_tri_en | rst_tri_en_d1)  ;



		cam_hit[0] = ( wr_data[32:3] == addr_array[0] )  &
                                 cam_out &   ~wr_data[2] & valid_bit[0]  ;
                reset_valid[0] = (cam_hit[0] & inval_mask_d[0]) ;
                cam_hit[1] = ( wr_data[32:3] == addr_array[1] )  &
                                  cam_out &  wr_data[2]  & valid_bit[1];
                reset_valid[1] = (cam_hit[1] & inval_mask_d[0]) ;

		lkup_hit[0] = ( cam_hit[0]  |  cam_hit[1] ) ;

	

		cam_hit[2] = ( wr_data[32:3] == addr_array[2] )  &
                                   cam_out & ~wr_data[2] & valid_bit[2]  ;
                reset_valid[2] = (cam_hit[2] & inval_mask_d[0]) ;
                cam_hit[3] = ( wr_data[32:3] == addr_array[3] )  &
                                   cam_out & wr_data[2]  & valid_bit[3];
                reset_valid[3] = (cam_hit[3] & inval_mask_d[0]) ;

		lkup_hit[1] = ( cam_hit[2]  |  cam_hit[3] );

	

		cam_hit[4] = ( wr_data[32:3] == addr_array[4] )  &
                                   cam_out & ~wr_data[2] & valid_bit[4]  ;
                reset_valid[4] = (cam_hit[4] & inval_mask_d[0]) ;
                cam_hit[5] = ( wr_data[32:3] == addr_array[5] )  &
                                   cam_out & wr_data[2]  & valid_bit[5];
                reset_valid[5] = (cam_hit[5] & inval_mask_d[0]) ;

		lkup_hit[2] = ( cam_hit[4]  |  cam_hit[5] );

	

		cam_hit[6] = ( wr_data[32:3] == addr_array[6] )  &
                                   cam_out & ~wr_data[2] & valid_bit[6]  ;
                reset_valid[6] = (cam_hit[6] & inval_mask_d[0]) ;
                cam_hit[7] = ( wr_data[32:3] == addr_array[7] )  &
                                   cam_out & wr_data[2]  & valid_bit[7];
                reset_valid[7] = (cam_hit[7] & inval_mask_d[0]) ;

		lkup_hit[3] = ( cam_hit[6]  |  cam_hit[7] );

	

		cam_hit[8] = ( wr_data[32:3] == addr_array[8] )  &
                                   cam_out & ~wr_data[2] & valid_bit[8]  ;
                reset_valid[8] = (cam_hit[8] & inval_mask_d[1]) ;
                cam_hit[9] = ( wr_data[32:3] == addr_array[9] )  &
                                   cam_out & wr_data[2]  & valid_bit[9];
                reset_valid[9] = (cam_hit[9] & inval_mask_d[1]) ;

		lkup_hit[4] = ( cam_hit[8]  |  cam_hit[9] );

	

		cam_hit[10] = ( wr_data[32:3] == addr_array[10] )  &
                                   cam_out & ~wr_data[2] & valid_bit[10]  ;
                reset_valid[10] = (cam_hit[10] & inval_mask_d[1]) ;
                cam_hit[11] = ( wr_data[32:3] == addr_array[11] )  &
                                   cam_out & wr_data[2]  & valid_bit[11];
                reset_valid[11] = (cam_hit[11] & inval_mask_d[1]) ;

		lkup_hit[5] = ( cam_hit[10]  |  cam_hit[11] );

	

		cam_hit[12] = ( wr_data[32:3] == addr_array[12] )  &
                                   cam_out & ~wr_data[2] & valid_bit[12]  ;
                reset_valid[12] = (cam_hit[12] & inval_mask_d[1]) ;
                cam_hit[13] = ( wr_data[32:3] == addr_array[13] )  &
                                   cam_out & wr_data[2]  & valid_bit[13];
                reset_valid[13] = (cam_hit[13] & inval_mask_d[1]) ;

		lkup_hit[6] = ( cam_hit[12]  |  cam_hit[13] );

	

		cam_hit[14] = ( wr_data[32:3] == addr_array[14] )  &
                                  cam_out &  ~wr_data[2] & valid_bit[14]  ;
                reset_valid[14] = (cam_hit[14] & inval_mask_d[1]) ;
                cam_hit[15] = ( wr_data[32:3] == addr_array[15] )  &
                                  cam_out &  wr_data[2]  & valid_bit[15];
                reset_valid[15] = (cam_hit[15] & inval_mask_d[1]) ;

		lkup_hit[7] = ( cam_hit[14]  |  cam_hit[15] );

	

		cam_hit[16] = ( wr_data[32:3] == addr_array[16] )  &
                                 cam_out &   ~wr_data[2] & valid_bit[16]  ;
                reset_valid[16] = (cam_hit[16] & inval_mask_d[2]) ;
                cam_hit[17] = ( wr_data[32:3] == addr_array[17] )  &
                                  cam_out &  wr_data[2]  & valid_bit[17];
                reset_valid[17] = (cam_hit[17] & inval_mask_d[2]) ;

		lkup_hit[8] = ( cam_hit[16]  |  cam_hit[17] );

	

		cam_hit[18] = ( wr_data[32:3] == addr_array[18] )  &
                                  cam_out &  ~wr_data[2] & valid_bit[18]  ;
                reset_valid[18] = (cam_hit[18] & inval_mask_d[2]) ;
                cam_hit[19] = ( wr_data[32:3] == addr_array[19] )  &
                                  cam_out &  wr_data[2]  & valid_bit[19];
                reset_valid[19] = (cam_hit[19] & inval_mask_d[2]) ;

		lkup_hit[9] = ( cam_hit[18]  |  cam_hit[19] );

	

		cam_hit[20] = ( wr_data[32:3] == addr_array[20] )  &
                                 cam_out &   ~wr_data[2] & valid_bit[20]  ;
                reset_valid[20] = (cam_hit[20] & inval_mask_d[2]) ;
                cam_hit[21] = ( wr_data[32:3] == addr_array[21] )  &
                                 cam_out &   wr_data[2]  & valid_bit[21];
                reset_valid[21] = (cam_hit[21] & inval_mask_d[2]) ;

		lkup_hit[10] = ( cam_hit[20]  |  cam_hit[21] );

	

		cam_hit[22] = ( wr_data[32:3] == addr_array[22] )  &
                                  cam_out &  ~wr_data[2] & valid_bit[22]  ;
                reset_valid[22] = (cam_hit[22] & inval_mask_d[2]) ;
                cam_hit[23] = ( wr_data[32:3] == addr_array[23] )  &
                                  cam_out &  wr_data[2]  & valid_bit[23];
                reset_valid[23] = (cam_hit[23] & inval_mask_d[2]) ;

		lkup_hit[11] = ( cam_hit[22]  |  cam_hit[23] );

	

		cam_hit[24] = ( wr_data[32:3] == addr_array[24] )  &
                                cam_out &    ~wr_data[2] & valid_bit[24]  ;
                reset_valid[24] = (cam_hit[24] & inval_mask_d[3]) ;
                cam_hit[25] = ( wr_data[32:3] == addr_array[25] )  &
                                cam_out &    wr_data[2]  & valid_bit[25];
                reset_valid[25] = (cam_hit[25] & inval_mask_d[3]) ;

		lkup_hit[12] = ( cam_hit[24]  |  cam_hit[25] );

	

		cam_hit[26] = ( wr_data[32:3] == addr_array[26] )  &
                                cam_out &    ~wr_data[2] & valid_bit[26]  ;
                reset_valid[26] = (cam_hit[26] & inval_mask_d[3]) ;
                cam_hit[27] = ( wr_data[32:3] == addr_array[27] )  &
                                cam_out &    wr_data[2]  & valid_bit[27];
                reset_valid[27] = (cam_hit[27] & inval_mask_d[3]) ;

		lkup_hit[13] = ( cam_hit[26]  |  cam_hit[27] );

	

		cam_hit[28] = ( wr_data[32:3] == addr_array[28] )  &
                                cam_out &    ~wr_data[2] & valid_bit[28]  ;
                reset_valid[28] = (cam_hit[28] & inval_mask_d[3]) ;
                cam_hit[29] = ( wr_data[32:3] == addr_array[29] )  &
                                cam_out &    wr_data[2]  & valid_bit[29];
                reset_valid[29] = (cam_hit[29] & inval_mask_d[3]) ;

		lkup_hit[14] = ( cam_hit[28]  |  cam_hit[29] );

	

		cam_hit[30] = ( wr_data[32:3] == addr_array[30] )  &
                                 cam_out &   ~wr_data[2] & valid_bit[30]  ;
                reset_valid[30] = (cam_hit[30] & inval_mask_d[3]) ;
                cam_hit[31] = ( wr_data[32:3] == addr_array[31] )  &
                                 cam_out &   wr_data[2]  & valid_bit[31];
                reset_valid[31] = (cam_hit[31] & inval_mask_d[3]) ;

		lkup_hit[15] = ( cam_hit[30]  |  cam_hit[31] );

	

		cam_hit[32] = ( wr_data[32:3] == addr_array[32] )  &
                              cam_out &      ~wr_data[2] & valid_bit[32]  ;
                reset_valid[32] = (cam_hit[32] & inval_mask_d[4]) ;
                cam_hit[33] = ( wr_data[32:3] == addr_array[33] )  &
                              cam_out &      wr_data[2]  & valid_bit[33];
                reset_valid[33] = (cam_hit[33] & inval_mask_d[4]) ;

		lkup_hit[16] = ( cam_hit[32]  |  cam_hit[33] );

	

		cam_hit[34] = ( wr_data[32:3] == addr_array[34] )  &
                               cam_out &     ~wr_data[2] & valid_bit[34]  ;
                reset_valid[34] = (cam_hit[34] & inval_mask_d[4]) ;
                cam_hit[35] = ( wr_data[32:3] == addr_array[35] )  &
                                cam_out &    wr_data[2]  & valid_bit[35];
                reset_valid[35] = (cam_hit[35] & inval_mask_d[4]) ;

		lkup_hit[17] = ( cam_hit[34]  |  cam_hit[35] );

	

		cam_hit[36] = ( wr_data[32:3] == addr_array[36] )  &
                                cam_out &    ~wr_data[2] & valid_bit[36]  ;
                reset_valid[36] = (cam_hit[36] & inval_mask_d[4]) ;
                cam_hit[37] = ( wr_data[32:3] == addr_array[37] )  &
                                cam_out &    wr_data[2]  & valid_bit[37];
                reset_valid[37] = (cam_hit[37] & inval_mask_d[4]) ;

		lkup_hit[18] = ( cam_hit[36]  |  cam_hit[37] );

	

		cam_hit[38] = ( wr_data[32:3] == addr_array[38] )  &
                               cam_out &     ~wr_data[2] & valid_bit[38]  ;
                reset_valid[38] = (cam_hit[38] & inval_mask_d[4]) ;
                cam_hit[39] = ( wr_data[32:3] == addr_array[39] )  &
                               cam_out &     wr_data[2]  & valid_bit[39];
                reset_valid[39] = (cam_hit[39] & inval_mask_d[4]) ;

		lkup_hit[19] = ( cam_hit[38]  |  cam_hit[39] );

	

		cam_hit[40] = ( wr_data[32:3] == addr_array[40] )  &
                               cam_out &     ~wr_data[2] & valid_bit[40]  ;
                reset_valid[40] = (cam_hit[40] & inval_mask_d[5]) ;
                cam_hit[41] = ( wr_data[32:3] == addr_array[41] )  &
                               cam_out &     wr_data[2]  & valid_bit[41];
                reset_valid[41] = (cam_hit[41] & inval_mask_d[5]) ;

		lkup_hit[20] = ( cam_hit[40]  |  cam_hit[41] );

	

		cam_hit[42] = ( wr_data[32:3] == addr_array[42] )  &
                              cam_out &      ~wr_data[2] & valid_bit[42]  ;
                reset_valid[42] = (cam_hit[42] & inval_mask_d[5]) ;
                cam_hit[43] = ( wr_data[32:3] == addr_array[43] )  &
                              cam_out &      wr_data[2]  & valid_bit[43];
                reset_valid[43] = (cam_hit[43] & inval_mask_d[5]) ;

		lkup_hit[21] = ( cam_hit[42]  |  cam_hit[43] );

	

		cam_hit[44] = ( wr_data[32:3] == addr_array[44] )  &
                              cam_out &      ~wr_data[2] & valid_bit[44]  ;
                reset_valid[44] = (cam_hit[44] & inval_mask_d[5]) ;
                cam_hit[45] = ( wr_data[32:3] == addr_array[45] )  &
                              cam_out &      wr_data[2]  & valid_bit[45];
                reset_valid[45] = (cam_hit[45] & inval_mask_d[5]) ;

		lkup_hit[22] = ( cam_hit[44]  |  cam_hit[45] );

	

		cam_hit[46] = ( wr_data[32:3] == addr_array[46] )  &
                             cam_out & ~wr_data[2] & valid_bit[46]  ;
                reset_valid[46] = (cam_hit[46] & inval_mask_d[5]) ;
                cam_hit[47] = ( wr_data[32:3] == addr_array[47] )  &
                             cam_out & wr_data[2]  & valid_bit[47];
                reset_valid[47] = (cam_hit[47] & inval_mask_d[5]) ;

		lkup_hit[23] = ( cam_hit[46]  |  cam_hit[47] );

	

		cam_hit[48] = ( wr_data[32:3] == addr_array[48] )  &
                           cam_out &  ~wr_data[2] & valid_bit[48]  ;
                reset_valid[48] = (cam_hit[48] & inval_mask_d[6]) ;
                cam_hit[49] = ( wr_data[32:3] == addr_array[49] )  &
                           cam_out &  wr_data[2]  & valid_bit[49];
                reset_valid[49] = (cam_hit[49] & inval_mask_d[6]) ;

		lkup_hit[24] = ( cam_hit[48]  |  cam_hit[49] );

	

		cam_hit[50] = ( wr_data[32:3] == addr_array[50] )  &
                           cam_out &  ~wr_data[2] & valid_bit[50]  ;
                reset_valid[50] = (cam_hit[50] & inval_mask_d[6]) ;
                cam_hit[51] = ( wr_data[32:3] == addr_array[51] )  &
                           cam_out &  wr_data[2]  & valid_bit[51];
                reset_valid[51] = (cam_hit[51] & inval_mask_d[6]) ;

		lkup_hit[25] = ( cam_hit[50]  |  cam_hit[51] );

	

		cam_hit[52] = ( wr_data[32:3] == addr_array[52] )  &
                            cam_out &  ~wr_data[2] & valid_bit[52]  ;
                reset_valid[52] = (cam_hit[52] & inval_mask_d[6]) ;
                cam_hit[53] = ( wr_data[32:3] == addr_array[53] )  &
                             cam_out &  wr_data[2]  & valid_bit[53];
                reset_valid[53] = (cam_hit[53] & inval_mask_d[6]) ;

		lkup_hit[26] = ( cam_hit[52]  |  cam_hit[53] );

	

		cam_hit[54] = ( wr_data[32:3] == addr_array[54] )  &
                             cam_out & ~wr_data[2] & valid_bit[54]  ;
                reset_valid[54] = (cam_hit[54] & inval_mask_d[6]) ;
                cam_hit[55] = ( wr_data[32:3] == addr_array[55] )  &
                             cam_out &  wr_data[2]  & valid_bit[55];
                reset_valid[55] = (cam_hit[55] & inval_mask_d[6]) ;

		lkup_hit[27] = ( cam_hit[54]  |  cam_hit[55] );

	

		cam_hit[56] = ( wr_data[32:3] == addr_array[56] )  &
                         cam_out & ~wr_data[2] & valid_bit[56]  ;
                reset_valid[56] = (cam_hit[56] & inval_mask_d[7]) ;
                cam_hit[57] = ( wr_data[32:3] == addr_array[57] )  &
                         cam_out &  wr_data[2]  & valid_bit[57];
                reset_valid[57] = (cam_hit[57] & inval_mask_d[7]) ;

		lkup_hit[28] = ( cam_hit[56]  |  cam_hit[57] );

	

		cam_hit[58] = ( wr_data[32:3] == addr_array[58] )  &
                         cam_out & ~wr_data[2] & valid_bit[58]  ;
                reset_valid[58] = (cam_hit[58] & inval_mask_d[7]) ;
                cam_hit[59] = ( wr_data[32:3] == addr_array[59] )  &
                         cam_out &  wr_data[2]  & valid_bit[59];
                reset_valid[59] = (cam_hit[59] & inval_mask_d[7]) ;

		lkup_hit[29] = ( cam_hit[58]  |  cam_hit[59] );

	

		cam_hit[60] = ( wr_data[32:3] == addr_array[60] )  &
                         cam_out & ~wr_data[2] & valid_bit[60]  ;
                reset_valid[60] = (cam_hit[60] & inval_mask_d[7]) ;
                cam_hit[61] = ( wr_data[32:3] == addr_array[61] )  &
                         cam_out &  wr_data[2]  & valid_bit[61];
                reset_valid[61] = (cam_hit[61] & inval_mask_d[7]) ;

		lkup_hit[30] = ( cam_hit[60]  |  cam_hit[61] );

	

		cam_hit[62] = ( wr_data[32:3] == addr_array[62] )  &
                        cam_out & ~wr_data[2] & valid_bit[62]  ;
                reset_valid[62] = (cam_hit[62] & inval_mask_d[7]) ;
                cam_hit[63] = ( wr_data[32:3] == addr_array[63] )  &
                        cam_out & wr_data[2]  & valid_bit[63];
                reset_valid[63] = (cam_hit[63] & inval_mask_d[7]) ;

		lkup_hit[31] = ( cam_hit[62]  |  cam_hit[63] );

		if( !rst_l | (rst_warm & ~(rst_tri_en | rst_tri_en_d1)) )  begin
			valid = 64'b0;
		end
	
	  	else if(cam_out) begin
			valid = valid_bit & ~reset_valid;
		end

		// else valid = valid ( implicit latch )


end

	
////////////////////////////////////////////////////////////
// READ/WRITE  OPERATION
// Phase 1 RD
////////////////////////////////////////////////////////////

always @(negedge rclk) begin

	if(rd_en_d & ~rst_tri_en) begin
		rd_data = {     addr_array[rw_addr_d],
                                parity[rw_addr_d] ,
                                valid_bit[rw_addr_d]
                         };
`ifdef  INNO_MUXEX
`else
`ifdef DEFINE_0IN
`else
                if(wr_en_d) begin
		`ifdef MODELSIM		
                   $display("L2_DIR_ERR"," rd/wr conflict");
		`else
                   $error("L2_DIR_ERR"," rd/wr conflict");
		`endif		
                end
`endif
`endif

        end // of if rd_en_d

  // WR
`ifdef DEFINE_0IN
`else
        if(wr_en_d & ~rst_tri_en ) begin
                // ---- \/ modelling write though behaviour \/-------
                rd_data = {     wr_data[32:3],
                                wr_data[1] ,
                                wr_data[0]
                         };

                parity[rw_addr_d]  =  wr_data[1] ;
                valid[rw_addr_d]  =  wr_data[0] ;
                addr_array[rw_addr_d] =  wr_data[32:3] ;

`ifdef  INNO_MUXEX
`else
                if(cam_en_d) begin
		`ifdef MODELSIM
                   $display("L2_DIR_ERR"," cam/wr conflict");
		`else
                   $error("L2_DIR_ERR"," cam/wr conflict");
		`endif
                end
`endif

        end
`endif


	//if( !rst_l | (rst_warm & ~rst_tri_en) ) valid = 64'b0;
	//else  valid = valid & ~reset_valid;

end




`ifdef DEFINE_0IN
always  @(posedge rclk)
begin
        if(!rst_l) begin        // rst_l all valid bits
                valid_bit = 64'b0 ;
        end else if(~rd_en_d & wr_en_d) begin
                addr_array[rw_addr_d] =  wr_data[32:3] ;
                parity[rw_addr_d]  =  wr_data[1] ;
                valid_bit[rw_addr_d]  =  wr_data[0] ;
        end
end
`endif





	
endmodule
