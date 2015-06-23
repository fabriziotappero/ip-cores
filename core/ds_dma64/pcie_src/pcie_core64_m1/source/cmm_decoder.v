
//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : V5-Block Plus for PCI Express
// File       : cmm_decoder.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------

module cmm_decoder (
                raddr,
                rmem32,
                rmem64,
                rio,
                rcheck_bus_id,
                rcheck_dev_id,
                rcheck_fun_id,

                rhit,
                bar_hit,
                cmmt_rbar_hit_lat2_n,

                command,
                bar0_reg,
                bar1_reg,
                bar2_reg,
                bar3_reg,
                bar4_reg,
                bar5_reg,
                xrom_reg,
                pme_pmcsr,

                bus_num,
                device_num,
                function_num,

                phantom_functions_supported,
                phantom_functions_enabled,

                cfg,
                rst,
                clk
                );

  parameter Tcq = 1;

  input  [63:0] raddr;
  input         rmem32;
  input         rmem64;
  input         rio;
  input         rcheck_bus_id;
  input         rcheck_dev_id;
  input         rcheck_fun_id;
  output        rhit;
  output [6:0]  bar_hit;
  output        cmmt_rbar_hit_lat2_n;
  input  [15:0] command;
  input  [31:0] bar0_reg;
  input  [31:0] bar1_reg;
  input  [31:0] bar2_reg;
  input  [31:0] bar3_reg;
  input  [31:0] bar4_reg;
  input  [31:0] bar5_reg;
  input  [31:0] xrom_reg;
  input  [15:0] pme_pmcsr;
  input   [7:0] bus_num;
  input   [4:0] device_num;
  input   [2:0] function_num;
  input [671:0] cfg;
  input         rst;
  input         clk;
  input   [1:0] phantom_functions_supported;
  input         phantom_functions_enabled;

  reg        rhit;
  reg [6:0]  bar_hit;
  reg        cmmt_rbar_hit_lat2_n;

wire allow_mem;
wire allow_io;
wire bar01_64;
wire bar12_64;
wire bar23_64;
wire bar34_64;
wire bar45_64;

assign allow_mem = command[1] & !pme_pmcsr[1] & !pme_pmcsr[0]; 
assign allow_io = command[0] & !pme_pmcsr[1] & !pme_pmcsr[0]; 

// 64 bit programmability built into bar registers

assign bar01_64 = (bar0_reg[2:0] == 3'b100); 
assign bar12_64 = (bar1_reg[2:0] == 3'b100); 
assign bar23_64 = (bar2_reg[2:0] == 3'b100); 
assign bar34_64 = (bar3_reg[2:0] == 3'b100); 
assign bar45_64 = (bar4_reg[2:0] == 3'b100); 

// 32 bits bar hits

wire bar0_32_hit; 
wire bar1_32_hit; 
wire bar2_32_hit; 
wire bar3_32_hit; 
wire bar4_32_hit; 
wire bar5_32_hit; 
wire bar6_32_hit; 
reg  bar0_32_hit_nc; 
reg  bar1_32_hit_nc; 
reg  bar2_32_hit_nc; 
reg  bar3_32_hit_nc; 
reg  bar4_32_hit_nc; 
reg  bar5_32_hit_nc; 
reg  bar6_32_hit_nc; 
reg  bar0_eq_raddr;
reg  bar1_eq_raddr;
reg  bar2_eq_raddr;
reg  bar3_eq_raddr;
reg  bar4_eq_raddr;
reg  bar5_eq_raddr;
reg  bar6_eq_raddr;

always @(posedge clk or posedge rst) begin
   if (rst) begin
      bar0_eq_raddr  <= #Tcq 0;
      bar1_eq_raddr  <= #Tcq 0;
      bar2_eq_raddr  <= #Tcq 0;
      bar3_eq_raddr  <= #Tcq 0;
      bar4_eq_raddr  <= #Tcq 0;
      bar5_eq_raddr  <= #Tcq 0;
      bar6_eq_raddr  <= #Tcq 0;
      bar0_32_hit_nc <= #Tcq  0;  
      bar1_32_hit_nc <= #Tcq  0;  
      bar2_32_hit_nc <= #Tcq  0;  
      bar3_32_hit_nc <= #Tcq  0;  
      bar4_32_hit_nc <= #Tcq  0;  
      bar5_32_hit_nc <= #Tcq  0;  
      bar6_32_hit_nc <= #Tcq  0;  
   end
   else begin
      bar0_eq_raddr <= #Tcq ((raddr[63:36] & cfg[95:68])   == bar0_reg[31:4]);
      bar1_eq_raddr <= #Tcq ((raddr[63:36] & cfg[127:100]) == bar1_reg[31:4]);
      bar2_eq_raddr <= #Tcq ((raddr[63:36] & cfg[159:132]) == bar2_reg[31:4]);
      bar3_eq_raddr <= #Tcq ((raddr[63:36] & cfg[191:164]) == bar3_reg[31:4]);
      bar4_eq_raddr <= #Tcq ((raddr[63:36] & cfg[223:196]) == bar4_reg[31:4]);
      bar5_eq_raddr <= #Tcq ((raddr[63:36] & cfg[255:228]) == bar5_reg[31:4]);
      bar6_eq_raddr <= #Tcq ((raddr[63:43] & cfg[351:331]) == xrom_reg[31:11]);
      bar0_32_hit_nc <= #Tcq  ((rmem32 & allow_mem & !cfg[64]) | (rio & allow_io & cfg[64])) & (|cfg[95:64]) &
                            (!bar01_64 | (bar01_64 && (bar1_reg == 0))); 

      bar1_32_hit_nc <= #Tcq  ((rmem32 & allow_mem & !cfg[96]) | (rio & allow_io & cfg[96])) & (|cfg[127:96]) & 
                            (!bar12_64 | (bar12_64 && (bar2_reg == 0))) & (!bar01_64);

      bar2_32_hit_nc <= #Tcq  ((rmem32 & allow_mem & !cfg[128]) | (rio & allow_io & cfg[128])) & (|cfg[159:128]) & 
                            (!bar23_64 | (bar23_64 && (bar3_reg == 0))) & (!bar12_64);

      bar3_32_hit_nc <= #Tcq  ((rmem32 & allow_mem & !cfg[160]) | (rio & allow_io & cfg[160])) & (|cfg[191:160]) & 
                            (!bar34_64 | (bar34_64 && (bar4_reg == 0))) & (!bar23_64);

      bar4_32_hit_nc <= #Tcq  ((rmem32 & allow_mem & !cfg[192]) | (rio & allow_io & cfg[192])) & (|cfg[224:192]) & 
                            (!bar45_64 | (bar45_64 && (bar5_reg == 0))) & (!bar34_64);

      bar5_32_hit_nc <= #Tcq  (((rmem32 & allow_mem & !cfg[224]) | (rio & allow_io & cfg[224])) & (|cfg[255:224]) & 
                            !bar45_64); 

      bar6_32_hit_nc <= #Tcq   (rmem32 & xrom_reg[0] & allow_mem) & |cfg[351:327];
   end
end

assign  bar0_32_hit = bar0_32_hit_nc & bar0_eq_raddr;
assign  bar1_32_hit = bar1_32_hit_nc & bar1_eq_raddr;
assign  bar2_32_hit = bar2_32_hit_nc & bar2_eq_raddr;
assign  bar3_32_hit = bar3_32_hit_nc & bar3_eq_raddr;
assign  bar4_32_hit = bar4_32_hit_nc & bar4_eq_raddr;
assign  bar5_32_hit = bar5_32_hit_nc & bar5_eq_raddr;
assign  bar6_32_hit = bar6_32_hit_nc & bar6_eq_raddr;


// 64 bit bar hits

reg   bar01_64_hit_low; 
reg   bar12_64_hit_low; 
reg   bar23_64_hit_low; 
reg   bar34_64_hit_low; 
reg   bar45_64_hit_low; 

reg   bar01_64_hit_high; 
reg   bar12_64_hit_high; 
reg   bar23_64_hit_high; 
reg   bar34_64_hit_high; 
reg   bar45_64_hit_high; 


wire  bar01_64_hit; 
wire  bar12_64_hit; 
wire  bar23_64_hit; 
wire  bar34_64_hit; 
wire  bar45_64_hit; 

assign  bar01_64_hit = bar01_64_hit_low &&  bar01_64_hit_high; 
assign  bar12_64_hit = bar12_64_hit_low &&  bar12_64_hit_high; 
assign  bar23_64_hit = bar23_64_hit_low &&  bar23_64_hit_high; 
assign  bar34_64_hit = bar34_64_hit_low &&  bar34_64_hit_high; 
assign  bar45_64_hit = bar45_64_hit_low &&  bar45_64_hit_high; 

always @(posedge clk or posedge rst) begin
   if (rst) begin
      bar01_64_hit_low  <= #Tcq  0; 
      bar01_64_hit_high <= #Tcq  0; 
      bar12_64_hit_low  <= #Tcq  0; 
      bar12_64_hit_high <= #Tcq  0; 
      bar23_64_hit_low  <= #Tcq  0; 
      bar23_64_hit_high <= #Tcq  0; 
      bar34_64_hit_low  <= #Tcq  0; 
      bar34_64_hit_high <= #Tcq  0; 
      bar45_64_hit_low  <= #Tcq  0; 
      bar45_64_hit_high <= #Tcq  0; 
   end
   else begin
      bar01_64_hit_low  <= #Tcq  (rmem64 & allow_mem) & ((raddr[63:32] & cfg[127:96]) == bar1_reg[31:0]) & |cfg[127:96]; 
      bar01_64_hit_high <= #Tcq  ((raddr[31:4] & cfg[95:68]) == bar0_reg[31:4]) &  bar01_64 & |cfg[95:64]; 

      bar12_64_hit_low  <= #Tcq  (rmem64 & allow_mem) & ((raddr[63:32] & cfg[159:128]) == bar2_reg[31:0]) & |cfg[159:128]; 
      bar12_64_hit_high <= #Tcq  ((raddr[31:4] & cfg[127:100]) == bar1_reg[31:4]) &  bar12_64 & |cfg[127:96]; 

      bar23_64_hit_low  <= #Tcq  (rmem64 & allow_mem) & ((raddr[63:32] & cfg[191:160]) == bar3_reg[31:0]) & |cfg[191:160];
      bar23_64_hit_high <= #Tcq  ((raddr[31:4] & cfg[159:132]) == bar2_reg[31:4]) &  bar23_64 & |cfg[159:128]; 

      bar34_64_hit_low  <= #Tcq  (rmem64 & allow_mem) & ((raddr[63:32] & cfg[223:192]) == bar4_reg[31:0]) & |cfg[223:192];
      bar34_64_hit_high <= #Tcq  ((raddr[31:4] & cfg[191:164]) == bar3_reg[31:4]) &  bar34_64 & |cfg[191:160]; 

      bar45_64_hit_low  <= #Tcq  (rmem64 & allow_mem) & ((raddr[63:32] & cfg[255:224]) == bar5_reg[31:0]) & |cfg[255:224];
      bar45_64_hit_high <= #Tcq  ((raddr[31:4] & cfg[223:196]) == bar4_reg[31:4]) &  bar45_64 & |cfg[223:192]; 
   end
end

// bdf hit

reg bdf_hit;
reg bdf_check;
reg phantom_function_check;

always @* begin
   casex ({phantom_functions_enabled, phantom_functions_supported})
   3'b0xx : phantom_function_check = (function_num[2:0] == raddr[50:48]);
   3'b100 : phantom_function_check = (function_num[2:0] == raddr[50:48]);
   3'b101 : phantom_function_check = (function_num[1:0] == raddr[49:48]);
   3'b110 : phantom_function_check = (function_num[0]   == raddr[48]);
   3'b111 : phantom_function_check = 1;
   default: phantom_function_check = (function_num[2:0] == raddr[50:48]);
   endcase
end

always @(posedge clk or posedge rst)
begin
   if (rst) begin 
       bdf_hit   <= #Tcq  0; 
       bdf_check <= #Tcq  0; 
   end else begin
       bdf_hit <= #Tcq  ({bus_num,device_num} == raddr[63:51]) && phantom_function_check;
       bdf_check <= #Tcq  rcheck_bus_id | rcheck_dev_id | rcheck_fun_id; 
   end
end


always@(posedge clk or posedge rst) 
begin
   if (rst) begin
      rhit <= #Tcq  0;
   end
   else begin
      rhit <= #Tcq  (bdf_hit && bdf_check) | bar01_64_hit | bar12_64_hit | 
                 bar23_64_hit | bar34_64_hit | bar45_64_hit |
                 bar0_32_hit | bar1_32_hit | bar2_32_hit | bar3_32_hit | 
                 bar4_32_hit | bar5_32_hit | bar6_32_hit;
   end
end

always@(posedge clk or posedge rst) 
begin
   if (rst) begin
      bar_hit[6:0] <= #Tcq 6'b000000;
      cmmt_rbar_hit_lat2_n <= #Tcq 0;
   end
   else begin
      bar_hit[0] <= #Tcq bar0_32_hit | bar01_64_hit;
      bar_hit[1] <= #Tcq bar1_32_hit | bar12_64_hit | bar01_64_hit;
      bar_hit[2] <= #Tcq bar2_32_hit | bar23_64_hit | bar12_64_hit;
      bar_hit[3] <= #Tcq bar3_32_hit | bar34_64_hit | bar23_64_hit;
      bar_hit[4] <= #Tcq bar4_32_hit | bar45_64_hit | bar34_64_hit;
      bar_hit[5] <= #Tcq bar5_32_hit | bar45_64_hit;
      bar_hit[6] <= #Tcq bar6_32_hit ;
      cmmt_rbar_hit_lat2_n <= #Tcq 0;
   end
end

endmodule
