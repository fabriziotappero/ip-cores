module bw_r_irf_fpga1 (
   input [ 11:0]  current_cwp,
   input         rclk,
   input         reset_l,

   input         si,
   input         se,
   input         sehold,
   input         rst_tri_en,

   input  [ 1:0] ifu_exu_tid_s2,  // s stage thread
   input  [ 4:0] ifu_exu_rs1_s,  // source addresses
   input  [ 4:0] ifu_exu_rs2_s,
   input  [ 4:0] ifu_exu_rs3_s,
   input         ifu_exu_ren1_s,        // read enables for all 3 ports
   input         ifu_exu_ren2_s,
   input         ifu_exu_ren3_s,
   input         ecl_irf_wen_w,        // write enables for both write ports
   input         ecl_irf_wen_w2,
   input  [ 4:0] ecl_irf_rd_m,   // w destination
   input  [ 4:0] ecl_irf_rd_g,  // w2 destination
   input  [71:0] byp_irf_rd_data_w,// write data from w1
   input  [71:0] byp_irf_rd_data_w2,     // write data from w2
   input  [ 1:0] ecl_irf_tid_m,  // w stage thread
   input  [ 1:0] ecl_irf_tid_g, // w2 thread

   input  [ 2:0] rml_irf_old_lo_cwp_e,  // current window pointer for locals and odds
   input  [ 2:0] rml_irf_new_lo_cwp_e,  // target window pointer for locals and odds
   input  [ 2:1] rml_irf_old_e_cwp_e,  // current window pointer for evens
   input  [ 2:1] rml_irf_new_e_cwp_e,  // target window pointer for evens
   input         rml_irf_swap_even_e,
   input         rml_irf_swap_odd_e,
   input         rml_irf_swap_local_e,
   input         rml_irf_kill_restore_w,
   input  [ 1:0] rml_irf_cwpswap_tid_e,

   input  [ 1:0] rml_irf_old_agp, // alternate global pointer
   input  [ 1:0] rml_irf_new_agp, // alternate global pointer
   input         rml_irf_swap_global,
   input  [ 1:0] rml_irf_global_tid,
   
   output        so,
   output reg [71:0] irf_byp_rs1_data_d_l,
   output reg [71:0] irf_byp_rs2_data_d_l,
   output reg [71:0] irf_byp_rs3_data_d_l,
   output reg [31:0] irf_byp_rs3h_data_d_l
);

wire [71:0] dout0_0;
wire [71:0] dout0_1;
wire [71:0] dout0_2;
wire [71:0] dout0_3;
wire [71:0] dout1_0;
wire [71:0] dout1_1;
wire [71:0] dout1_2;
wire [71:0] dout1_3;
wire [71:0] dout2_0;
wire [71:0] dout2_1;
wire [71:0] dout2_2;
wire [71:0] dout2_3;
wire [71:0] dout3_0;
wire [71:0] dout3_1;
wire [71:0] dout3_2;
wire [71:0] dout3_3;

reg [1:0] ecl_irf_tid_m_d;  
reg [1:0] ecl_irf_tid_g_d;  
reg [4:0] ecl_irf_rd_m_d;
reg [4:0] ecl_irf_rd_g_d;

wire wen0_0=(ecl_irf_tid_m_d==2'b00) && ecl_irf_wen_w && (ecl_irf_rd_m_d!=0) & ~rst_tri_en;
wire wen0_1=(ecl_irf_tid_g_d==2'b00) && ecl_irf_wen_w2 && (ecl_irf_rd_g_d!=0) & ~rst_tri_en;
wire wen1_0=(ecl_irf_tid_m_d==2'b01) && ecl_irf_wen_w && (ecl_irf_rd_m_d!=0) & ~rst_tri_en;
wire wen1_1=(ecl_irf_tid_g_d==2'b01) && ecl_irf_wen_w2 && (ecl_irf_rd_g_d!=0) & ~rst_tri_en;
wire wen2_0=(ecl_irf_tid_m_d==2'b10) && ecl_irf_wen_w && (ecl_irf_rd_m_d!=0) & ~rst_tri_en;
wire wen2_1=(ecl_irf_tid_g_d==2'b10) && ecl_irf_wen_w2 && (ecl_irf_rd_g_d!=0) & ~rst_tri_en;
wire wen3_0=(ecl_irf_tid_m_d==2'b11) && ecl_irf_wen_w && (ecl_irf_rd_m_d!=0) & ~rst_tri_en;
wire wen3_1=(ecl_irf_tid_g_d==2'b11) && ecl_irf_wen_w2 && (ecl_irf_rd_g_d!=0) & ~rst_tri_en;


reg [2:0] wr0_window; 
reg [2:0] wr1_window; 
reg [2:0] rd0_window; 
reg [2:0] rd1_window; 
reg [2:0] rd2_window;  

reg [2:0] current_global[3:0];
reg [2:0] current_window[3:0];
reg [2:0] current_read[3:0];
reg [2:0] current_write[3:0];
reg [2:0] current_write_d[3:0];

reg [1:0] cwpswap_tid_d;
reg [2:0] new_lo_cwp_d;
reg [2:0] old_lo_cwp_d;
reg       swap_local_d;

reg [1:0] cwpswap_tid_d1;
reg [2:0] new_lo_cwp_d1;
reg [2:0] old_lo_cwp_d1;
reg       swap_local_d1;

reg [1:0] cwpswap_tid_d2;
reg [2:0] new_lo_cwp_d2;
reg [2:0] old_lo_cwp_d2;
reg       swap_local_d2;

reg [1:0] ifu_exu_tid_s2_d;

integer i;

always @(posedge rclk or negedge reset_l)
   if(~reset_l)
      begin
         current_global[0]<=3'd3;
         current_global[1]<=3'd3;
         current_global[2]<=3'd3;
         current_global[3]<=3'd3;
         current_window[0]<=0;
         current_window[1]<=0;
         current_window[2]<=0;
         current_window[3]<=0;
         current_write[0]<=0;
         current_write[1]<=0;
         current_write[2]<=0;
         current_write[3]<=0;
         current_read[0]<=0;
         current_read[1]<=0;
         current_read[2]<=0;
         current_read[3]<=0;
         swap_local_d<=0;
         swap_local_d1<=0;
      end
   else
      begin
         // !!! Maybe we should flop that on negedge also
         if(ifu_exu_ren1_s || ifu_exu_ren2_s || ifu_exu_ren3_s)
            ifu_exu_tid_s2_d<=ifu_exu_tid_s2;
         
         ecl_irf_tid_m_d<=ecl_irf_tid_m;  
         ecl_irf_tid_g_d<=ecl_irf_tid_g;  
         ecl_irf_rd_m_d<=ecl_irf_rd_m;
         ecl_irf_rd_g_d<=ecl_irf_rd_g;
         
         swap_local_d<=rml_irf_swap_local_e & ~rst_tri_en;
         cwpswap_tid_d<=rml_irf_cwpswap_tid_e;
         new_lo_cwp_d<=rml_irf_new_lo_cwp_e;
         old_lo_cwp_d<=rml_irf_old_lo_cwp_e;
         
         swap_local_d1<=swap_local_d;
         cwpswap_tid_d1<=cwpswap_tid_d;
         new_lo_cwp_d1<=new_lo_cwp_d;
         old_lo_cwp_d1<=old_lo_cwp_d;
         
         swap_local_d2<=swap_local_d1;
         cwpswap_tid_d2<=cwpswap_tid_d1;
         new_lo_cwp_d2<=new_lo_cwp_d1;
         old_lo_cwp_d2<=old_lo_cwp_d1;

         if(rml_irf_swap_global & ~rst_tri_en)
            current_global[rml_irf_global_tid]<={1'b0,rml_irf_new_agp};
         
         /*if(swap_local_d)
            begin
               current_write[cwpswap_tid_d]<=new_lo_cwp_d;
               current_read[cwpswap_tid_d]<=new_lo_cwp_d;
            end
         else
            if(swap_local_d2 && (new_lo_cwp_d2[0]!=exu_ifu_oddwin_s[cwpswap_tid_d2]))
               begin
                  current_write[cwpswap_tid_d2]<=old_lo_cwp_d2;
                  current_read[cwpswap_tid_d2]<=old_lo_cwp_d2;
               end*/
               
         
         /*   
         if(rml_irf_swap_local_e)
           current_write[rml_irf_cwpswap_tid_e]<=rml_irf_old_lo_cwp_e;
         else
            if(swap_local_d)
               current_write[cwpswap_tid_d]<=new_lo_cwp_d;
            
         for(i=0;i<4;i=i+1)
            current_write_d[i]<=current_write[i];
            
         if(rml_irf_swap_local_e)
            current_read[cwpswap_tid_d1]<=rml_irf_old_lo_cwp_e;
         else
            if(swap_local_d1)
               current_read[cwpswap_tid_d1]<=new_lo_cwp_d1;
         */
      end  

/*
always @( * )
   begin
      wr0_window<=ecl_irf_rd_m_d[4:3]==2'b0 ? current_global[ecl_irf_tid_m_d]:(rml_irf_swap_local_e  && (ecl_irf_tid_m_d==rml_irf_cwpswap_tid_e) ? rml_irf_old_lo_cwp_e:current_write[ecl_irf_tid_m_d]);
      wr1_window<=ecl_irf_rd_g_d[4:3]==2'b0 ? current_global[ecl_irf_tid_g_d]:(rml_irf_swap_local_e  && (ecl_irf_tid_g_d==rml_irf_cwpswap_tid_e) ? rml_irf_old_lo_cwp_e:current_write[ecl_irf_tid_g_d]);
      rd0_window<=ifu_exu_rs1_s[4:3]==2'b0 ? current_global[ifu_exu_tid_s2]:(rml_irf_swap_local_e  && (ifu_exu_tid_s2==rml_irf_cwpswap_tid_e) ? rml_irf_old_lo_cwp_e:current_read[ifu_exu_tid_s2]);
      rd1_window<=ifu_exu_rs2_s[4:3]==2'b0 ? current_global[ifu_exu_tid_s2]:(rml_irf_swap_local_e  && (ifu_exu_tid_s2==rml_irf_cwpswap_tid_e) ? rml_irf_old_lo_cwp_e:current_read[ifu_exu_tid_s2]);
      rd2_window<=ifu_exu_rs3_s[4:3]==2'b0 ? current_global[ifu_exu_tid_s2]:(rml_irf_swap_local_e  && (ifu_exu_tid_s2==rml_irf_cwpswap_tid_e) ? rml_irf_old_lo_cwp_e:current_read[ifu_exu_tid_s2]);
   end
*/

reg [2:0] wr0_cwp;
reg [2:0] wr1_cwp;
reg [2:0] rd_cwp;

always @( * )
   case(ecl_irf_tid_m_d)
      2'b00:wr0_cwp<=current_cwp[2:0];
      2'b01:wr0_cwp<=current_cwp[5:3];
      2'b10:wr0_cwp<=current_cwp[8:6];
      2'b11:wr0_cwp<=current_cwp[11:9];
   endcase
      
always @( * )
   case(ecl_irf_tid_g_d)
      2'b00:wr1_cwp<=current_cwp[2:0];
      2'b01:wr1_cwp<=current_cwp[5:3];
      2'b10:wr1_cwp<=current_cwp[8:6];
      2'b11:wr1_cwp<=current_cwp[11:9];
   endcase
      
always @( * )
   case(ifu_exu_tid_s2)
      2'b00:rd_cwp<=current_cwp[2:0];
      2'b01:rd_cwp<=current_cwp[5:3];
      2'b10:rd_cwp<=current_cwp[8:6];
      2'b11:rd_cwp<=current_cwp[11:9];
   endcase
      
always @( * )
   begin
      wr0_window<=ecl_irf_rd_m_d[4:3]==2'b0 ? current_global[ecl_irf_tid_m_d]:wr0_cwp;
      wr1_window<=ecl_irf_rd_g_d[4:3]==2'b0 ? current_global[ecl_irf_tid_g_d]:wr1_cwp;
      rd0_window<=ifu_exu_rs1_s[4:3]==2'b0 ? current_global[ifu_exu_tid_s2]:rd_cwp;
      rd1_window<=ifu_exu_rs2_s[4:3]==2'b0 ? current_global[ifu_exu_tid_s2]:rd_cwp;
      rd2_window<=ifu_exu_rs3_s[4:3]==2'b0 ? current_global[ifu_exu_tid_s2]:rd_cwp;
   end

wire [4:0] wraddr0_swapoe=(!wr0_window[0] && ecl_irf_rd_m_d[3]) ? {~ecl_irf_rd_m_d[4],ecl_irf_rd_m_d[3:0]}:ecl_irf_rd_m_d;
wire [4:0] wraddr1_swapoe=(!wr1_window[0] && ecl_irf_rd_g_d[3]) ? {~ecl_irf_rd_g_d[4],ecl_irf_rd_g_d[3:0]}:ecl_irf_rd_g_d;
wire [4:0] rdaddr0_swapoe=(!rd0_window[0] && ifu_exu_rs1_s[3]) ? {~ifu_exu_rs1_s[4],ifu_exu_rs1_s[3:0]}:ifu_exu_rs1_s;
wire [4:0] rdaddr1_swapoe=(!rd1_window[0] && ifu_exu_rs2_s[3]) ? {~ifu_exu_rs2_s[4],ifu_exu_rs2_s[3:0]}:ifu_exu_rs2_s;
wire [4:0] rdaddr2_swapoe=(!rd2_window[0] && ifu_exu_rs3_s[3]) ? {~ifu_exu_rs3_s[4],ifu_exu_rs3_s[3:0]}:ifu_exu_rs3_s;

wire [6:0] wraddr0_wa={2'b0,wraddr0_swapoe}+{wr0_window,4'b0};
wire [6:0] wraddr1_wa={2'b0,wraddr1_swapoe}+{wr1_window,4'b0};
wire [6:0] rdaddr0_wa={2'b0,rdaddr0_swapoe}+{rd0_window,4'b0};
wire [6:0] rdaddr1_wa={2'b0,rdaddr1_swapoe}+{rd1_window,4'b0};
wire [6:0] rdaddr2_wa={2'b0,rdaddr2_swapoe}+{rd2_window,4'b0};

wire [7:0] wraddr0={1'b0,wraddr0_wa}+(ecl_irf_rd_m_d[4:3]!=2'b0 ? 8'd64:8'd0);
wire [7:0] wraddr1={1'b0,wraddr1_wa}+(ecl_irf_rd_g_d[4:3]!=2'b0 ? 8'd64:8'd0);
wire [7:0] rdaddr0={1'b0,rdaddr0_wa}+(ifu_exu_rs1_s[4:3]!=2'b0 ? 8'd64:8'd0);
wire [7:0] rdaddr1={1'b0,rdaddr1_wa}+(ifu_exu_rs2_s[4:3]!=2'b0 ? 8'd64:8'd0);
wire [7:0] rdaddr2={1'b0,rdaddr2_wa}+(ifu_exu_rs3_s[4:3]!=2'b0 ? 8'd64:8'd0);

regfile_1w_4r regfile_thr0(
   .clk(rclk),
   
   .din(wen0_1 ? byp_irf_rd_data_w2:byp_irf_rd_data_w),
   .wraddr(wen0_1 ? wraddr1:wraddr0),
   .wren(wen0_0 || wen0_1),
   .rdaddr0(rdaddr0),
   .rdaddr1(rdaddr1),
   .rdaddr2(rdaddr2),
   .rdaddr3({rdaddr2[7:1],1'b1}),
   .rd0(ifu_exu_ren1_s && (ifu_exu_tid_s2==2'b00)),
   .rd1(ifu_exu_ren2_s && (ifu_exu_tid_s2==2'b00)),
   .rd2(ifu_exu_ren3_s && (ifu_exu_tid_s2==2'b00)),
   .rd3(ifu_exu_ren3_s && (ifu_exu_tid_s2==2'b00)),

   .dout0(dout0_0),
   .dout1(dout0_1),
   .dout2(dout0_2),
   .dout3(dout0_3)
);

regfile_1w_4r regfile_thr1(
   .clk(rclk),
   
   .din(wen1_1 ? byp_irf_rd_data_w2:byp_irf_rd_data_w),
   .wraddr(wen1_1 ? wraddr1:wraddr0),
   .wren(wen1_0 || wen1_1),
   .rdaddr0(rdaddr0),
   .rdaddr1(rdaddr1),
   .rdaddr2(rdaddr2),
   .rdaddr3({rdaddr2[7:1],1'b1}),
   .rd0(ifu_exu_ren1_s && (ifu_exu_tid_s2==2'b01)),
   .rd1(ifu_exu_ren2_s && (ifu_exu_tid_s2==2'b01)),
   .rd2(ifu_exu_ren3_s && (ifu_exu_tid_s2==2'b01)),
   .rd3(ifu_exu_ren3_s && (ifu_exu_tid_s2==2'b01)),

   .dout0(dout1_0),
   .dout1(dout1_1),
   .dout2(dout1_2),
   .dout3(dout1_3)
);

regfile_1w_4r regfile_thr2(
   .clk(rclk),
   
   .din(wen2_1 ? byp_irf_rd_data_w2:byp_irf_rd_data_w),
   .wraddr(wen2_1 ? wraddr1:wraddr0),
   .wren(wen2_0 || wen2_1),
   .rdaddr0(rdaddr0),
   .rdaddr1(rdaddr1),
   .rdaddr2(rdaddr2),
   .rdaddr3({rdaddr2[7:1],1'b1}),
   .rd0(ifu_exu_ren1_s && (ifu_exu_tid_s2==2'b10)),
   .rd1(ifu_exu_ren2_s && (ifu_exu_tid_s2==2'b10)),
   .rd2(ifu_exu_ren3_s && (ifu_exu_tid_s2==2'b10)),
   .rd3(ifu_exu_ren3_s && (ifu_exu_tid_s2==2'b10)),

   .dout0(dout2_0),
   .dout1(dout2_1),
   .dout2(dout2_2),
   .dout3(dout2_3)
);

regfile_1w_4r regfile_thr3(
   .clk(rclk),
   
   .din(wen3_1 ? byp_irf_rd_data_w2:byp_irf_rd_data_w),
   .wraddr(wen3_1 ? wraddr1:wraddr0),
   .wren(wen3_0 || wen3_1),
   .rdaddr0(rdaddr0),
   .rdaddr1(rdaddr1),
   .rdaddr2(rdaddr2),
   .rdaddr3({rdaddr2[7:1],1'b1}),
   .rd0(ifu_exu_ren1_s && (ifu_exu_tid_s2==2'b11)),
   .rd1(ifu_exu_ren2_s && (ifu_exu_tid_s2==2'b11)),
   .rd2(ifu_exu_ren3_s && (ifu_exu_tid_s2==2'b11)),
   .rd3(ifu_exu_ren3_s && (ifu_exu_tid_s2==2'b11)),

   .dout0(dout3_0),
   .dout1(dout3_1),
   .dout2(dout3_2),
   .dout3(dout3_3)
);

always @( * )
   case(ifu_exu_tid_s2_d)
      2'b00:
         begin
            irf_byp_rs1_data_d_l<=~dout0_0;
            irf_byp_rs2_data_d_l<=~dout0_1;
            irf_byp_rs3_data_d_l<=~dout0_2;
            irf_byp_rs3h_data_d_l<=~dout0_3[31:0];
         end
      2'b01:
         begin
            irf_byp_rs1_data_d_l<=~dout1_0;
            irf_byp_rs2_data_d_l<=~dout1_1;
            irf_byp_rs3_data_d_l<=~dout1_2;
            irf_byp_rs3h_data_d_l<=~dout1_3[31:0];
         end
      2'b10:
         begin
            irf_byp_rs1_data_d_l<=~dout2_0;
            irf_byp_rs2_data_d_l<=~dout2_1;
            irf_byp_rs3_data_d_l<=~dout2_2;
            irf_byp_rs3h_data_d_l<=~dout2_3[31:0];
         end
      2'b11:
         begin
            irf_byp_rs1_data_d_l<=~dout3_0;
            irf_byp_rs2_data_d_l<=~dout3_1;
            irf_byp_rs3_data_d_l<=~dout3_2;
            irf_byp_rs3h_data_d_l<=~dout3_3[31:0];
         end
   endcase

endmodule
