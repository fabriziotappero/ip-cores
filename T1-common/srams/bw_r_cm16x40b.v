// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: bw_r_cm16x40b.v
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
// DUAL PORTED CAM RTL
// 16 entries X 40 bits/entry
// REad/Write ports can be accessed in PH1 only.
// CAM port can be accessed in PH2 only.
////////////////////////////////////////////////////////////////////////

module bw_r_cm16x40b( /*AUTOARG*/
   // Outputs
   dout, match, match_idx, so, 
   // Inputs
   adr_w, din, write_en, rst_tri_en, adr_r, read_en, lookup_en, key, 
   rclk, sehold, se, si, rst_l
   );

input   [15:0]  adr_w ; // set up to +ve edge
input   [39:0]  din;    // set up to +ve edge
input           write_en;       // +ve edge clk; write enable
input		rst_tri_en;
input   [15:0]  adr_r;  // set up to +ve edge
input           read_en;
output  [39:0]  dout;
input           lookup_en;      // set up to -ve edge
input   [39:8]  key;    // set up to -ve edge
output  [15:0]  match ;
output  [15:0]  match_idx ;
input   rclk ;
input   sehold, se, si, rst_l;
output  so ;

reg     [39:0]  mb_cam_data[15:0] ;

reg     [39:0]  dout;
reg     [39:8]  key_d1;
reg     lookup_en_d1 ;

reg     [39:0]  tmp_addr ;
reg     [39:0]  tmp_addr0 ;
reg     [39:0]  tmp_addr1 ;
reg     [39:0]  tmp_addr2 ;
reg     [39:0]  tmp_addr3 ;
reg     [39:0]  tmp_addr4 ;
reg     [39:0]  tmp_addr5 ;
reg     [39:0]  tmp_addr6 ;
reg     [39:0]  tmp_addr7 ;
reg     [39:0]  tmp_addr8 ;
reg     [39:0]  tmp_addr9 ;
reg     [39:0]  tmp_addr10 ;
reg     [39:0]  tmp_addr11 ;
reg     [39:0]  tmp_addr12 ;
reg     [39:0]  tmp_addr13 ;
reg     [39:0]  tmp_addr14 ;
reg     [39:0]  tmp_addr15 ;

reg     [15:0]  adr_w_d1 ;
reg     [15:0]  adr_r_d1 ;
reg             mb_wen_d1 ;     // registered write enable
reg             mb_ren_d1 ;     // registered read enable

reg     [39:0]  din_d1;

reg     [15:0]  match ;
reg     [15:0]  match_idx ;
reg     [15:0]  match_p ;
reg     [15:0]  match_idx_p ;

reg             so ;

reg             rst_l_d1;
reg             rst_tri_en_d1;


always  @(posedge rclk ) begin

	match <= match_p ;
        match_idx <= match_idx_p ;
	adr_w_d1 <= (sehold)? adr_w_d1: adr_w ;
        adr_r_d1 <= (sehold)? adr_r_d1: adr_r;
        din_d1 <= ( sehold)? din_d1: din ;
        mb_wen_d1 <= ( sehold)? mb_wen_d1: write_en ;
        mb_ren_d1 <= ( sehold)? mb_ren_d1 : read_en  ;

	rst_l_d1 <= rst_l ; // this is not a real flop
        rst_tri_en_d1 <= rst_tri_en ; // this is not a real flop


end


// CAM OPERATION

`ifdef DEFINE_0IN
always  @( negedge rclk         ) begin
`else
always  @( negedge rclk or rst_l) begin
`endif
        lookup_en_d1 = lookup_en ;
        key_d1 = key;
	
	if(~rst_l) begin
		match_idx_p = 16'b0;
		match_p = 16'b0;
	end

        else if  (lookup_en_d1 ) begin

		tmp_addr0 = mb_cam_data[0];
                match_p[0] =  ( tmp_addr0[39:8] == key_d1[39:8] ) ;
                match_idx_p[0] = ( tmp_addr0[17:8] == key_d1[17:8] ) ;

                tmp_addr1 = mb_cam_data[1];
                match_p[1] =  ( tmp_addr1[39:8] == key_d1[39:8] ) ;
                match_idx_p[1] = ( tmp_addr1[17:8] == key_d1[17:8] ) ;

                tmp_addr2 = mb_cam_data[2];
                match_p[2] =  ( tmp_addr2[39:8] == key_d1[39:8] ) ;
                match_idx_p[2] = ( tmp_addr2[17:8] == key_d1[17:8] ) ;

                tmp_addr3 = mb_cam_data[3];
                match_p[3] =  ( tmp_addr3[39:8] == key_d1[39:8] ) ;
                match_idx_p[3] = ( tmp_addr3[17:8] == key_d1[17:8] ) ;

                tmp_addr4 = mb_cam_data[4];
                match_p[4] =  ( tmp_addr4[39:8] == key_d1[39:8] ) ;
                match_idx_p[4] = ( tmp_addr4[17:8] == key_d1[17:8] ) ;

                tmp_addr5 = mb_cam_data[5];
                match_p[5] =  ( tmp_addr5[39:8] == key_d1[39:8] ) ;
                match_idx_p[5] = ( tmp_addr5[17:8] == key_d1[17:8] ) ;

                tmp_addr6 = mb_cam_data[6];
                match_p[6] =  ( tmp_addr6[39:8] == key_d1[39:8] ) ;
                match_idx_p[6] = ( tmp_addr6[17:8] == key_d1[17:8] ) ;

                 tmp_addr7 = mb_cam_data[7];
                match_p[7] =  ( tmp_addr7[39:8] == key_d1[39:8] ) ;
                match_idx_p[7] = ( tmp_addr7[17:8] == key_d1[17:8] ) ;

                tmp_addr8 = mb_cam_data[8];
                match_p[8] =  ( tmp_addr8[39:8] == key_d1[39:8] ) ;
                match_idx_p[8] = ( tmp_addr8[17:8] == key_d1[17:8] ) ;

                tmp_addr9 = mb_cam_data[9];
                match_p[9] =  ( tmp_addr9[39:8] == key_d1[39:8] ) ;
                match_idx_p[9] = ( tmp_addr9[17:8] == key_d1[17:8] ) ;

                tmp_addr10 = mb_cam_data[10];
                match_p[10] =  ( tmp_addr10[39:8] == key_d1[39:8] ) ;
                match_idx_p[10] = ( tmp_addr10[17:8] == key_d1[17:8] ) ;

                tmp_addr11 = mb_cam_data[11];
                match_p[11] =  ( tmp_addr11[39:8] == key_d1[39:8] ) ;
                match_idx_p[11] = ( tmp_addr11[17:8] == key_d1[17:8] ) ;

                tmp_addr12 = mb_cam_data[12];
                match_p[12] =  ( tmp_addr12[39:8] == key_d1[39:8] ) ;
                match_idx_p[12] = ( tmp_addr12[17:8] == key_d1[17:8] ) ;

                tmp_addr13 = mb_cam_data[13];
                match_p[13] =  ( tmp_addr13[39:8] == key_d1[39:8] ) ;
                match_idx_p[13] = ( tmp_addr13[17:8] == key_d1[17:8] ) ;

                tmp_addr14 = mb_cam_data[14];
                match_p[14] =  ( tmp_addr14[39:8] == key_d1[39:8] ) ;
                match_idx_p[14] = ( tmp_addr14[17:8] == key_d1[17:8] ) ;

                tmp_addr15 = mb_cam_data[15];
                match_p[15] =  ( tmp_addr15[39:8] == key_d1[39:8] ) ;
                match_idx_p[15] = ( tmp_addr15[17:8] == key_d1[17:8] ) ;

  
	end

        else begin
                match_p = 16'b0;
                match_idx_p = 16'b0;
        end

end

// READ AND WRITE HAPPEN in Phase 1.

// rst_tri_en_d1 & rst_l_d1 are part of the
// list because we want to enter the following
// always block under the following condition:
// - adr_w_d1 , din_d1 , mb_wen_d1 remain the same across the
// rising edge of the clock
// - rst_tri_en or rst_l change across the rising edge of the
// clock from high to low.

always  @(adr_w_d1 or din_d1 or mb_wen_d1  or rst_tri_en_d1 or rst_l_d1 ) begin
  begin
    if (mb_wen_d1  & ~rst_tri_en & rst_l ) begin
        case(adr_w_d1 )
          16'b0000_0000_0000_0000: ;  // do nothing
          16'b0000_0000_0000_0001: mb_cam_data[0] = din_d1 ;
          16'b0000_0000_0000_0010: mb_cam_data[1] = din_d1 ;
          16'b0000_0000_0000_0100: mb_cam_data[2] = din_d1 ;
          16'b0000_0000_0000_1000: mb_cam_data[3] = din_d1 ;
          16'b0000_0000_0001_0000: mb_cam_data[4] = din_d1;
          16'b0000_0000_0010_0000: mb_cam_data[5] = din_d1 ;
          16'b0000_0000_0100_0000: mb_cam_data[6] = din_d1 ;
          16'b0000_0000_1000_0000: mb_cam_data[7] = din_d1 ;
          16'b0000_0001_0000_0000: mb_cam_data[8] = din_d1 ;
          16'b0000_0010_0000_0000: mb_cam_data[9] = din_d1 ;
          16'b0000_0100_0000_0000: mb_cam_data[10] = din_d1 ;
          16'b0000_1000_0000_0000: mb_cam_data[11] = din_d1 ;
          16'b0001_0000_0000_0000: mb_cam_data[12] = din_d1 ;
          16'b0010_0000_0000_0000: mb_cam_data[13] = din_d1 ;
          16'b0100_0000_0000_0000: mb_cam_data[14] = din_d1 ;
          16'b1000_0000_0000_0000: mb_cam_data[15] = din_d1 ;
          //16'b1111_1111_1111_1111:
            //    begin
             //           mb_cam_data[15] = din_d1 ;
              //          mb_cam_data[14] = din_d1 ;
               //         mb_cam_data[13] = din_d1 ;
                //        mb_cam_data[12] = din_d1 ;
                 //       mb_cam_data[11] = din_d1 ;
                  //      mb_cam_data[10] = din_d1 ;
                   //     mb_cam_data[9] = din_d1 ;
                    //    mb_cam_data[8] = din_d1 ;
                    //    mb_cam_data[7] = din_d1 ;
                    //    mb_cam_data[6] = din_d1 ;
                    //    mb_cam_data[5] = din_d1 ;
                    //    mb_cam_data[4] = din_d1 ;
                    //    mb_cam_data[3] = din_d1 ;
                    //    mb_cam_data[2] = din_d1 ;
                    //    mb_cam_data[1] = din_d1 ;
                    //    mb_cam_data[0] = din_d1 ;
               // end
          default:
     		// 0in <fire -message "FATAL ERROR: incorrect write wordline"
`ifdef DEFINE_0IN
             ;
`else
`ifdef  INNO_MUXEX
             ;
`else
		`ifdef MODELSIM
            $display("PH2_CAM2_ERROR"," incorrect write wordline %h ", adr_w_d1);
		`else
            $error("PH2_CAM2_ERROR"," incorrect write wordline %h ", adr_w_d1);
		`endif
`endif
`endif

        endcase
      end
  end

end



// rst_l_d1 has purely been added so that we enter the always
// block when the wordline/wr_en does not change across clk cycles
// but the rst_l does.
// Notice rst_l_d1 is not used in any of the "if" statements.
// Notice that the renable is qualified with rclk to take
// care that we do not read from the array if rst_l goes high
// during the negative phase of rclk.
//

always  @( /*memory or*/ adr_r_d1 or adr_w_d1
          or mb_ren_d1 or mb_wen_d1 or rst_l_d1 or rst_l or rst_tri_en_d1) begin
  if(~rst_l ) begin
        dout = 40'b0 ;
   end
  else if (mb_ren_d1 & rclk & rst_tri_en ) begin
                dout = 40'hff_ffff_ffff ;
  end
  else if (mb_ren_d1 & rclk & ~rst_tri_en) begin
    if ((mb_wen_d1) && (adr_r_d1 == adr_w_d1) && (adr_r_d1) )
      begin
             dout = 40'bx ;

`ifdef DEFINE_0IN
`else
`ifdef  INNO_MUXEX
`else
		`ifdef MODELSIM
	         $display("PH1_CAM2_ERROR"," read write conflict %h ", adr_r_d1);	
		`else
             $error("PH1_CAM2_ERROR"," read write conflict %h ", adr_r_d1);
   		`endif
`endif
`endif
      end
    else
      begin
        case(adr_r_d1)
          // match sense amp ckt behavior when no read wl is selected
          16'b0000_0000_0000_0000: dout = 40'hff_ffff_ffff ;
          16'b0000_0000_0000_0001: dout = mb_cam_data[0] ;
          16'b0000_0000_0000_0010: dout = mb_cam_data[1] ;
          16'b0000_0000_0000_0100: dout = mb_cam_data[2] ;
          16'b0000_0000_0000_1000: dout = mb_cam_data[3] ;
          16'b0000_0000_0001_0000: dout = mb_cam_data[4] ;
          16'b0000_0000_0010_0000: dout = mb_cam_data[5] ;
          16'b0000_0000_0100_0000: dout = mb_cam_data[6] ;
          16'b0000_0000_1000_0000: dout = mb_cam_data[7] ;
          16'b0000_0001_0000_0000: dout = mb_cam_data[8] ;
          16'b0000_0010_0000_0000: dout = mb_cam_data[9] ;
          16'b0000_0100_0000_0000: dout = mb_cam_data[10] ;
          16'b0000_1000_0000_0000: dout = mb_cam_data[11] ;
          16'b0001_0000_0000_0000: dout = mb_cam_data[12] ;
          16'b0010_0000_0000_0000: dout = mb_cam_data[13] ;
          16'b0100_0000_0000_0000: dout = mb_cam_data[14] ;
          16'b1000_0000_0000_0000: dout = mb_cam_data[15] ;
          default:
             // 0in <fire -message "FATAL ERROR: incorrect read wordline"
`ifdef DEFINE_0IN
             ;
`else
`ifdef  INNO_MUXEX
             ;
`else
		`ifdef MODELSIM
             $display("PH1_CAM2_ERROR"," incorrect read wordline %h ", adr_r_d1);
		`else
             $error("PH1_CAM2_ERROR"," incorrect read wordline %h ", adr_r_d1);
		`endif
`endif
`endif

        endcase
      end

        end // of else if
end
endmodule



