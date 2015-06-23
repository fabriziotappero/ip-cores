//Legal Notice: (C)2013 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module altera_sdram_partner_module (
                                     // inputs:
                                      clk,
                                      zs_addr,
                                      zs_ba,
                                      zs_cas_n,
                                      zs_cke,
                                      zs_cs_n,
                                      zs_dqm,
                                      zs_ras_n,
                                      zs_we_n,

                                     // outputs:
                                      zs_dq
                                   )
;

  parameter INIT_FILE = "altera_sdram_partner_module.dat";


  inout   [ 31: 0] zs_dq;
  input            clk;
  input   [ 12: 0] zs_addr;
  input   [  1: 0] zs_ba;
  input            zs_cas_n;
  input            zs_cke;
  input            zs_cs_n;
  input   [  3: 0] zs_dqm;
  input            zs_ras_n;
  input            zs_we_n;

  wire    [ 23: 0] CODE;
  wire    [ 12: 0] a;
  wire    [  9: 0] addr_col;
  reg     [ 14: 0] addr_crb;
  wire    [  1: 0] ba;
  wire             cas_n;
  wire             cke;
  wire    [  2: 0] cmd_code;
  wire             cs_n;
  wire    [  3: 0] dqm;
  wire    [  2: 0] index;
  reg     [  2: 0] latency;
  wire    [  3: 0] mask;
  reg     [ 31: 0] mem_array [33554431: 0];
  wire    [ 31: 0] mem_bytes;
  wire             ras_n;
  reg     [ 24: 0] rd_addr_pipe_0;
  reg     [ 24: 0] rd_addr_pipe_1;
  reg     [ 24: 0] rd_addr_pipe_2;
  reg     [  3: 0] rd_mask_pipe_0;
  reg     [  3: 0] rd_mask_pipe_1;
  reg     [  3: 0] rd_mask_pipe_2;
  reg     [  2: 0] rd_valid_pipe;
  wire    [ 24: 0] rdaddress;
  wire    [ 24: 0] read_addr;
  reg     [ 24: 0] read_address;
  wire    [ 31: 0] read_data;
  wire    [  3: 0] read_mask;
  wire    [ 31: 0] read_temp;
  wire             read_valid;
  wire    [ 31: 0] rmw_temp;
  wire    [ 24: 0] test_addr;
  wire    [ 23: 0] txt_code;
  wire             we_n;
  wire             wren;
  wire    [ 31: 0] zs_dq;
initial
  begin
    $write("\n");
    $write("************************************************************\n");
    $write("This testbench includes an SOPC Builder Generated Altera model:\n");
    $write("'altera_sdram_partner_module.v', to simulate accesses to SDRAM.\n");
    $write("Initial contents are loaded from the file: 'altera_sdram_partner_module.dat'.\n");
    $write("************************************************************\n");
  end
  always @(rdaddress)
    begin
      read_address = rdaddress;
    end


initial
    $readmemh(INIT_FILE, mem_array);
  always @(posedge clk)
    begin
      // Write data
      if (wren)
          mem_array[test_addr] <= rmw_temp;
    end


  assign read_data = mem_array[read_address];
  assign rdaddress = (CODE == 24'h205752) ? test_addr : read_addr;
  assign wren = CODE == 24'h205752;
  assign cke = zs_cke;
  assign cs_n = zs_cs_n;
  assign ras_n = zs_ras_n;
  assign cas_n = zs_cas_n;
  assign we_n = zs_we_n;
  assign dqm = zs_dqm;
  assign ba = zs_ba;
  assign a = zs_addr;
  assign cmd_code = {ras_n, cas_n, we_n};
  assign CODE = (&cs_n) ? 24'h494e48 : txt_code;
  assign addr_col = a[9 : 0];
  assign test_addr = {addr_crb, addr_col};
  assign mem_bytes = read_data;
  assign rmw_temp[7 : 0] = dqm[0] ? mem_bytes[7 : 0] : zs_dq[7 : 0];
  assign rmw_temp[15 : 8] = dqm[1] ? mem_bytes[15 : 8] : zs_dq[15 : 8];
  assign rmw_temp[23 : 16] = dqm[2] ? mem_bytes[23 : 16] : zs_dq[23 : 16];
  assign rmw_temp[31 : 24] = dqm[3] ? mem_bytes[31 : 24] : zs_dq[31 : 24];
  // Handle Input.
  always @(posedge clk)
    begin
      // No Activity of Clock Disabled
      if (cke)
        begin
          // LMR: Get CAS_Latency.
          if (CODE == 24'h4c4d52)
              latency <= a[6 : 4];
          // ACT: Get Row/Bank Address.
          if (CODE == 24'h414354)
              addr_crb <= {ba[1], a, ba[0]};
          rd_valid_pipe[2] <= rd_valid_pipe[1];
          rd_valid_pipe[1] <= rd_valid_pipe[0];
          rd_valid_pipe[0] <= CODE == 24'h205244;
          rd_addr_pipe_2 <= rd_addr_pipe_1;
          rd_addr_pipe_1 <= rd_addr_pipe_0;
          rd_addr_pipe_0 <= test_addr;
          rd_mask_pipe_2 <= rd_mask_pipe_1;
          rd_mask_pipe_1 <= rd_mask_pipe_0;
          rd_mask_pipe_0 <= dqm;
        end
    end


  assign read_temp[7 : 0] = mask[0] ? 8'bz : read_data[7 : 0];
  assign read_temp[15 : 8] = mask[1] ? 8'bz : read_data[15 : 8];
  assign read_temp[23 : 16] = mask[2] ? 8'bz : read_data[23 : 16];
  assign read_temp[31 : 24] = mask[3] ? 8'bz : read_data[31 : 24];
  //use index to select which pipeline stage drives addr
  assign read_addr = (index == 0)? rd_addr_pipe_0 :
    (index == 1)? rd_addr_pipe_1 :
    rd_addr_pipe_2;

  //use index to select which pipeline stage drives mask
  assign read_mask = (index == 0)? rd_mask_pipe_0 :
    (index == 1)? rd_mask_pipe_1 :
    rd_mask_pipe_2;

  //use index to select which pipeline stage drives valid
  assign read_valid = (index == 0)? rd_valid_pipe[0] :
    (index == 1)? rd_valid_pipe[1] :
    rd_valid_pipe[2];

  assign index = latency - 1'b1;
  assign mask = read_mask;
  assign zs_dq = read_valid ? read_temp : {32{1'bz}};

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  assign txt_code = (cmd_code == 3'h0)? 24'h4c4d52 :
    (cmd_code == 3'h1)? 24'h415246 :
    (cmd_code == 3'h2)? 24'h505245 :
    (cmd_code == 3'h3)? 24'h414354 :
    (cmd_code == 3'h4)? 24'h205752 :
    (cmd_code == 3'h5)? 24'h205244 :
    (cmd_code == 3'h6)? 24'h425354 :
    (cmd_code == 3'h7)? 24'h4e4f50 :
    24'h424144;


//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule

