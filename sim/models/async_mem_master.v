// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 1ns/10ps


module async_mem_master
  #(
    parameter log_level = 3,
    parameter ce_setup  = 10,
    parameter op_hold   = 15,
    parameter dw        = 32,
    parameter aw        = 32
  ) 
  (
    inout   [(dw-1):0]  mem_d,
    output  [(aw-1):0]  mem_a,
    output              mem_oe_n,
    output  [3:0]       mem_bls_n,
    output              mem_we_n,
    output              mem_cs_n,
    
    input               tb_clk,
    input               tb_rst
  );
  


  // --------------------------------------------------------------------
  //  async_mem_default_state
  reg  [(dw-1):0] mem_d_r;
  reg  [(aw-1):0] mem_a_r;
  reg             mem_oe_n_r;
  reg  [3:0]      mem_bls_n_r;
  reg             mem_we_n_r;
  reg             mem_cs_n_r;
  reg             tb_oe_r;
  
  task async_mem_default_state;
    begin
      mem_d_r     = 'bx;
      mem_a_r     = 'bx;
      mem_oe_n_r  = 1'b1;
      mem_bls_n_r = 4'b1111;
      mem_we_n_r  = 1'b1;
      tb_oe_r     = 1'b0;
    end  
  endtask
  
                
  // --------------------------------------------------------------------
  //  
  initial
    begin
      async_mem_default_state();
      mem_cs_n_r  = 1'b1;
    end

    
  // --------------------------------------------------------------------
  //  async_mem_3x_write
  task async_mem_3x_write;
    input [(dw-1):0]  address;
    input [(dw-1):0]  data1;
    input [(dw-1):0]  data2;
    input [(dw-1):0]  data3;
    input [3:0]       byte_lane_select;
      begin
      
        if( log_level > 2 )
          $display( "###- async_mem_3x_write: @ 0x%h at time %t. ", address, $time );
      
        @(posedge tb_clk);
      
        mem_cs_n_r  = 1'b0;
        repeat(ce_setup) @(posedge tb_clk);
        
        mem_d_r = data1;
        mem_a_r = address;
        mem_oe_n_r  = 1'b1;
        mem_bls_n_r = byte_lane_select;
        mem_we_n_r  = 1'b0;
        tb_oe_r     = 1'b1;
        
        repeat(op_hold) @(posedge tb_clk);
        mem_we_n_r  = 1'b1;
        
        
        repeat(ce_setup) @(posedge tb_clk);
        mem_d_r = data2;
        mem_a_r = address + 4;
        mem_we_n_r  = 1'b0;
        repeat(op_hold) @(posedge tb_clk);
        mem_we_n_r  = 1'b1;
        
        repeat(ce_setup) @(posedge tb_clk);
        mem_d_r = data3;
        mem_a_r = address + 8;
        mem_we_n_r  = 1'b0;
        repeat(op_hold) @(posedge tb_clk);
        mem_we_n_r  = 1'b1;
        
        @(posedge tb_clk);
        
        async_mem_default_state();

        mem_cs_n_r  = 1'b1;
        
      end    
  endtask
  
    
  // --------------------------------------------------------------------
  //  async_mem_write
  task async_mem_write;
    input [(dw-1):0]  address;
    input [(dw-1):0]  data;
    input [3:0]       byte_lane_select;
      begin
      
        if( log_level > 2 )
          $display( "###- async_mem_write: 0x%h @ 0x%h at time %t. ", data, address, $time );
      
        @(posedge tb_clk);
      
        mem_cs_n_r  = 1'b0;
        repeat(ce_setup) @(posedge tb_clk);
        
        mem_d_r = data;
        mem_a_r = address;
        mem_oe_n_r  = 1'b1;
        mem_bls_n_r = byte_lane_select;
        mem_we_n_r  = 1'b0;
        tb_oe_r     = 1'b1;
        repeat(op_hold) @(posedge tb_clk);
        
        async_mem_default_state();

        mem_cs_n_r  = 1'b1;
        
      end    
  endtask
  
    
  // --------------------------------------------------------------------
  //  async_mem_cmp
  task async_mem_cmp;
    input [(dw-1):0]  address;
    input [(dw-1):0]  data;
    input [3:0]       byte_lane_select;
      begin
      
        if( log_level > 2 )
          $display( "###- async_mem_cmp: 0x%h @ 0x%h at time %t. ", data, address, $time );
      
        @(posedge tb_clk);
      
        mem_cs_n_r  = 1'b0;
        mem_we_n_r  = 1'b1;
        mem_oe_n_r  = 1'b0;
        tb_oe_r     = 1'b0;
        mem_a_r = address;
        mem_bls_n_r = byte_lane_select;
        repeat(ce_setup) @(posedge tb_clk);
        
        
        if( ( mem_d !== data ) & (log_level > 0) )
          $display( "!!!- Data compare error at time %t. Received %h, expected %h at address %h", $time, mem_d, data, address);        

        repeat(op_hold) @(posedge tb_clk);
        
        async_mem_default_state();

        mem_cs_n_r  = 1'b1;
        
      end    
  endtask
  
    
  // --------------------------------------------------------------------
  //  async_mem_3x_cmp
  task async_mem_3x_cmp;
    input [(dw-1):0]  address;
    input [(dw-1):0]  data1;
    input [(dw-1):0]  data2;
    input [(dw-1):0]  data3;
    input [3:0]       byte_lane_select;
      begin
      
        if( log_level > 2 )
          $display( "###- async_mem_3x_cmp: @ 0x%h at time %t. ", address, $time );
      
        @(posedge tb_clk);
      
        mem_cs_n_r  = 1'b0;
        mem_we_n_r  = 1'b1;
        mem_oe_n_r  = 1'b0;
        tb_oe_r     = 1'b0;
        mem_a_r = address;
        mem_bls_n_r = byte_lane_select;
        repeat(ce_setup) @(posedge tb_clk);
        
        
        if( ( mem_d !== data1 ) & (log_level > 0) )
          $display( "!!!- Data compare error at time %t. Received %h, expected %h at address %h", $time, mem_d, data1, address);        

        repeat(op_hold) @(posedge tb_clk);
        
        mem_a_r = address + 4;
        repeat(ce_setup) @(posedge tb_clk);
        
        
        if( ( mem_d !== data2 ) & (log_level > 0) )
          $display( "!!!- Data compare error at time %t. Received %h, expected %h at address %h", $time, mem_d, data2, address + 4);        

        repeat(op_hold) @(posedge tb_clk);
        
        mem_a_r = address + 8;
        repeat(ce_setup) @(posedge tb_clk);
        
        
        if( ( mem_d !== data3 ) & (log_level > 0) )
          $display( "!!!- Data compare error at time %t. Received %h, expected %h at address %h", $time, mem_d, data3, address + 8);        

        repeat(op_hold) @(posedge tb_clk);
        
        async_mem_default_state();

        mem_cs_n_r  = 1'b1;
        
      end    
  endtask
  
    
  // --------------------------------------------------------------------
  //  outputs
  assign mem_d = tb_oe_r ? mem_d_r : 'bz;
  
  assign mem_a      = mem_a_r;
  assign mem_oe_n   = mem_oe_n_r;
  assign mem_bls_n  = mem_bls_n_r;
  assign mem_we_n   = mem_we_n_r;
  assign mem_cs_n   = mem_cs_n_r;

endmodule


