// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 10ps/1ps


module tb_top();

  // --------------------------------------------------------------------
  // system wires
  wire  clk_250;
  
  wire tb_clk = clk_250;
  
  wire tb_rst;
  

  // --------------------------------------------------------------------
  // clock & reset

  parameter CLK_PERIOD = 400; // use 250MHZ for main clk
  
  tb_clk #( .CLK_PERIOD(400) ) i_clk_250   ( clk_250 );

  tb_reset #( .ASSERT_TIME(CLK_PERIOD*10) ) i_tb_rst( tb_rst );

  initial
    begin
      $display("\n^^^---------------------------------");
      #(CLK_PERIOD/3);
      i_tb_rst.assert_reset();
    end


  // dut
  // --------------------------------------------------------------------
  wire          ugb_adc_rd_en;
  
  wire          fifo_full;
  wire          fifo_empty;
  reg   [12:0]  fifo_wr_data;
  wire  [12:0]  fifo_rd_data;
  wire          fifo_wr_en = ~tb_rst & ~fifo_full;
  wire          fifo_rd_en = ~tb_rst & ugb_adc_rd_en & ~fifo_empty;
  
  wire  [12:0]  ugb_adc_bus = fifo_rd_data;
  wire  [7:0]   ugb_out;
    
  unbuffered_gear_box
    i_unbuffered_gear_box
    (
    .adc_bus(ugb_adc_bus),
    .adc_rd_en(ugb_adc_rd_en),

    .out(ugb_out),

    .gb_en(~fifo_empty),
    .clk_250(clk_250),
    .sys_reset(tb_rst)
    );  

sync_fifo 
  i_sync_fifo
  (
    .fifo_wr_data(fifo_wr_data),
    .fifo_rd_data(fifo_rd_data),
    .fifo_wr_en(fifo_wr_en),
    .fifo_rd_en(fifo_rd_en),
    
    .fifo_full(fifo_full),
    .fifo_empty(fifo_empty),
    
    .fifo_clock(clk_250),
    .fifo_reset(tb_rst)
  );
  

  // --------------------------------------------------------------------
  // dut
  

  // --------------------------------------------------------------------
  // sim modles
  
//  tb_log log();


  always @( posedge clk_250 )
    if( tb_rst )
      fifo_wr_data <= 0;
    else if( fifo_wr_en )
      fifo_wr_data <= fifo_wr_data + 1;     
      
  reg [103:0] ugb_out_r;

  always @( posedge clk_250 )
    ugb_out_r <= {ugb_out, ugb_out_r[103:8]};
        

  wire [12:0] dbg_ugb_shift[7:0];
  
  assign dbg_ugb_shift[0] = ugb_out_r[12:0];
  assign dbg_ugb_shift[1] = ugb_out_r[25:13];
  assign dbg_ugb_shift[2] = ugb_out_r[38:26];
  assign dbg_ugb_shift[3] = ugb_out_r[51:39];
  assign dbg_ugb_shift[4] = ugb_out_r[64:52];
  assign dbg_ugb_shift[5] = ugb_out_r[77:65];
  assign dbg_ugb_shift[6] = ugb_out_r[90:78];
  assign dbg_ugb_shift[7] = ugb_out_r[103:91];

  wire [7:0] dbg_ugb_out[12:0];

  assign dbg_ugb_out[0]  = ugb_out_r[7:0];
  assign dbg_ugb_out[1]  = ugb_out_r[15:8];
  assign dbg_ugb_out[2]  = ugb_out_r[23:16];
  assign dbg_ugb_out[3]  = ugb_out_r[31:24];
  assign dbg_ugb_out[4]  = ugb_out_r[39:32];
  assign dbg_ugb_out[5]  = ugb_out_r[47:40];
  assign dbg_ugb_out[6]  = ugb_out_r[55:48];
  assign dbg_ugb_out[7]  = ugb_out_r[63:56];
  assign dbg_ugb_out[8]  = ugb_out_r[71:64];
  assign dbg_ugb_out[9]  = ugb_out_r[79:72];
  assign dbg_ugb_out[10] = ugb_out_r[87:80];
  assign dbg_ugb_out[11] = ugb_out_r[95:88];
  assign dbg_ugb_out[12] = ugb_out_r[103:96];
  
  reg [12:0] dbg_ugb_pixels_out_r[7:0];
  integer   j;
  
  always @( posedge clk_250 )
    if( i_unbuffered_gear_box.gear_select == 0 )
      for( j = 0; j < 8; j = j + 1 )
        dbg_ugb_pixels_out_r[j] <= dbg_ugb_shift[j];
    
    
  // sim modles
  // --------------------------------------------------------------------


  // --------------------------------------------------------------------
  // waveform signals
  wire [3:0] gear = i_unbuffered_gear_box.gear_select;
  wire bank_sel = i_unbuffered_gear_box.adc_bus_bank_select;
  wire [12:0] adc_bus_in = ugb_adc_bus;
  wire [7:0] gear_box_out = ugb_out;
  wire adc_bus_rd_en = ugb_adc_rd_en;


  // --------------------------------------------------------------------
  // test
  the_test test( tb_clk, tb_rst );

  initial
    begin

      wait( ~tb_rst );

      repeat(2) @(posedge tb_clk);

      test.run_the_test();

      $display("\n^^^---------------------------------");
      $display("^^^ %15.t | Testbench done.\n", $time);
      $display("\n^^^---------------------------------");
      
//      log.log_fail_count();
      $display("\n^^^---------------------------------");

`ifdef DEBUG
      $stop();
`else
      $finish();
`endif      

    end

endmodule

