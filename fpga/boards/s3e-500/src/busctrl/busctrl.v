//
// busctrl.v -- bus controller
//


module busctrl(cpu_en, cpu_wr, cpu_size, cpu_addr,
               cpu_data_out, cpu_data_in, cpu_wt,
               ram_en, ram_wr, ram_size, ram_addr,
               ram_data_in, ram_data_out, ram_wt,
               rom_en, rom_wr, rom_size, rom_addr,
               rom_data_out, rom_wt,
               tmr0_en, tmr0_wr, tmr0_addr,
               tmr0_data_in, tmr0_data_out, tmr0_wt,
               tmr1_en, tmr1_wr, tmr1_addr,
               tmr1_data_in, tmr1_data_out, tmr1_wt,
               dsp_en, dsp_wr, dsp_addr,
               dsp_data_in, dsp_data_out, dsp_wt,
               kbd_en, kbd_wr, kbd_addr,
               kbd_data_in, kbd_data_out, kbd_wt,
               ser0_en, ser0_wr, ser0_addr,
               ser0_data_in, ser0_data_out, ser0_wt,
               ser1_en, ser1_wr, ser1_addr,
               ser1_data_in, ser1_data_out, ser1_wt,
               fms_en, fms_wr, fms_addr,
               fms_data_in, fms_data_out, fms_wt,
               bio_en, bio_wr, bio_addr,
               bio_data_in, bio_data_out, bio_wt);
    // cpu
    input cpu_en;
    input cpu_wr;
    input [1:0] cpu_size;
    input [31:0] cpu_addr;
    input [31:0] cpu_data_out;
    output [31:0] cpu_data_in;
    output cpu_wt;
    // ram
    output ram_en;
    output ram_wr;
    output [1:0] ram_size;
    output [25:0] ram_addr;
    output [31:0] ram_data_in;
    input [31:0] ram_data_out;
    input ram_wt;
    // rom
    output rom_en;
    output rom_wr;
    output [1:0] rom_size;
    output [23:0] rom_addr;
    input [31:0] rom_data_out;
    input rom_wt;
    // tmr0
    output tmr0_en;
    output tmr0_wr;
    output [3:2] tmr0_addr;
    output [31:0] tmr0_data_in;
    input [31:0] tmr0_data_out;
    input tmr0_wt;
    // tmr1
    output tmr1_en;
    output tmr1_wr;
    output [3:2] tmr1_addr;
    output [31:0] tmr1_data_in;
    input [31:0] tmr1_data_out;
    input tmr1_wt;
    // dsp
    output dsp_en;
    output dsp_wr;
    output [13:2] dsp_addr;
    output [15:0] dsp_data_in;
    input [15:0] dsp_data_out;
    input dsp_wt;
    // kbd
    output kbd_en;
    output kbd_wr;
    output kbd_addr;
    output [7:0] kbd_data_in;
    input [7:0] kbd_data_out;
    input kbd_wt;
    // ser0
    output ser0_en;
    output ser0_wr;
    output [3:2] ser0_addr;
    output [7:0] ser0_data_in;
    input [7:0] ser0_data_out;
    input ser0_wt;
    // ser1
    output ser1_en;
    output ser1_wr;
    output [3:2] ser1_addr;
    output [7:0] ser1_data_in;
    input [7:0] ser1_data_out;
    input ser1_wt;
    // fms
    output fms_en;
    output fms_wr;
    output [11:2] fms_addr;
    output [31:0] fms_data_in;
    input [31:0] fms_data_out;
    input fms_wt;
    // bio
    output bio_en;
    output bio_wr;
    output bio_addr;
    output [31:0] bio_data_in;
    input [31:0] bio_data_out;
    input bio_wt;

  wire i_o_en;

  //
  // address decoder
  //
  // RAM: architectural limit = 512 MB
  //      board limit         =  64 MB
  assign ram_en =
    (cpu_en == 1 && cpu_addr[31:29] == 3'b000
                 && cpu_addr[28:26] == 3'b000) ? 1 : 0;
  // ROM: architectural limit = 256 MB
  //      board limit         =  16 MB
  assign rom_en =
    (cpu_en == 1 && cpu_addr[31:28] == 4'b0010
                 && cpu_addr[27:24] == 4'b0000) ? 1 : 0;
  // I/O: architectural limit = 256 MB
  assign i_o_en =
    (cpu_en == 1 && cpu_addr[31:28] == 4'b0011) ? 1 : 0;
  assign tmr0_en =
    (i_o_en == 1 && cpu_addr[27:20] == 8'h00
                 && cpu_addr[19:12] == 8'h00) ? 1 : 0;
  assign tmr1_en =
    (i_o_en == 1 && cpu_addr[27:20] == 8'h00
                 && cpu_addr[19:12] == 8'h01) ? 1 : 0;
  assign dsp_en =
    (i_o_en == 1 && cpu_addr[27:20] == 8'h01) ? 1 : 0;
  assign kbd_en =
    (i_o_en == 1 && cpu_addr[27:20] == 8'h02) ? 1 : 0;
  assign ser0_en =
    (i_o_en == 1 && cpu_addr[27:20] == 8'h03
                 && cpu_addr[19:12] == 8'h00) ? 1 : 0;
  assign ser1_en =
    (i_o_en == 1 && cpu_addr[27:20] == 8'h03
                 && cpu_addr[19:12] == 8'h01) ? 1 : 0;
  assign fms_en =
    (i_o_en == 1 && cpu_addr[27:20] == 8'h05
                 && cpu_addr[19:12] == 8'h00) ? 1 : 0;
  assign bio_en =
    (i_o_en == 1 && cpu_addr[27:20] == 8'h10
                 && cpu_addr[19:12] == 8'h00) ? 1 : 0;

  // to cpu
  assign cpu_wt =
    (ram_en == 1) ? ram_wt :
    (rom_en == 1) ? rom_wt :
    (tmr0_en == 1) ? tmr0_wt :
    (tmr1_en == 1) ? tmr1_wt :
    (dsp_en == 1) ? dsp_wt :
    (kbd_en == 1) ? kbd_wt :
    (ser0_en == 1) ? ser0_wt :
    (ser1_en == 1) ? ser1_wt :
    (fms_en == 1) ? fms_wt :
    (bio_en == 1) ? bio_wt :
    1;
  assign cpu_data_in[31:0] =
    (ram_en == 1) ? ram_data_out[31:0] :
    (rom_en == 1) ? rom_data_out[31:0] :
    (tmr0_en == 1) ? tmr0_data_out[31:0] :
    (tmr1_en == 1) ? tmr1_data_out[31:0] :
    (dsp_en == 1) ? { 16'h0000, dsp_data_out[15:0] } :
    (kbd_en == 1) ? { 24'h000000, kbd_data_out[7:0] } :
    (ser0_en == 1) ? { 24'h000000, ser0_data_out[7:0] } :
    (ser1_en == 1) ? { 24'h000000, ser1_data_out[7:0] } :
    (fms_en == 1) ? fms_data_out[31:0] :
    (bio_en == 1) ? bio_data_out[31:0] :
    32'h00000000;

  // to ram
  assign ram_wr = cpu_wr;
  assign ram_size[1:0] = cpu_size[1:0];
  assign ram_addr[25:0] = cpu_addr[25:0];
  assign ram_data_in[31:0] = cpu_data_out[31:0];

  // to rom
  assign rom_wr = cpu_wr;
  assign rom_size[1:0] = cpu_size[1:0];
  assign rom_addr[23:0] = cpu_addr[23:0];

  // to tmr0
  assign tmr0_wr = cpu_wr;
  assign tmr0_addr[3:2] = cpu_addr[3:2];
  assign tmr0_data_in[31:0] = cpu_data_out[31:0];

  // to tmr1
  assign tmr1_wr = cpu_wr;
  assign tmr1_addr[3:2] = cpu_addr[3:2];
  assign tmr1_data_in[31:0] = cpu_data_out[31:0];

  // to dsp
  assign dsp_wr = cpu_wr;
  assign dsp_addr[13:2] = cpu_addr[13:2];
  assign dsp_data_in[15:0] = cpu_data_out[15:0];

  // to kbd
  assign kbd_wr = cpu_wr;
  assign kbd_addr = cpu_addr[2];
  assign kbd_data_in[7:0] = cpu_data_out[7:0];

  // to ser0
  assign ser0_wr = cpu_wr;
  assign ser0_addr[3:2] = cpu_addr[3:2];
  assign ser0_data_in[7:0] = cpu_data_out[7:0];

  // to ser1
  assign ser1_wr = cpu_wr;
  assign ser1_addr[3:2] = cpu_addr[3:2];
  assign ser1_data_in[7:0] = cpu_data_out[7:0];

  // to fms
  assign fms_wr = cpu_wr;
  assign fms_addr[11:2] = cpu_addr[11:2];
  assign fms_data_in[31:0] = cpu_data_out[31:0];

  // to bio
  assign bio_wr = cpu_wr;
  assign bio_addr = cpu_addr[2];
  assign bio_data_in[31:0] = cpu_data_out[31:0];

endmodule
