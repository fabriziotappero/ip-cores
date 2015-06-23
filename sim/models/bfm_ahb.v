//
//
//

`timescale 1ns / 100ps



module bfm_ahb(
                  output          hclk,
                  output          hresetn,
                  output  [31:0]  haddr,
                  output  [1:0]   htrans,
                  output          hwrite,
                  output  [2:0]   hsize,
                  output  [2:0]   hburst,
                  output  [3:0]   hprot,
                  output  [31:0]  hwdata,
                  output          hsel,
                  
                  input  [31:0]   hrdata,
                  output          hready_in,
                  input           hready_out,
                  input  [1:0]    hresp,
                  
                  input           bfm_clk,
                  input           bfm_reset
                );
                
  parameter LOG_LEVEL = 3;    

    
  // -----------------------------
  //  
  
  reg read_error;
  
  reg hready_out_wait_r;
  
  reg [31:0]  haddr_r;
  reg  [1:0]  htrans_r;
  reg         hwrite_r;
  reg  [2:0]  hsize_r;
  reg  [2:0]  hburst_r;
  reg  [3:0]  hprot_r;
  reg  [31:0] hwdata_r;
  reg         hsel_r;
  reg         hready_in_r;
  
  assign haddr  = haddr_r;
  assign htrans = htrans_r;
  assign hwrite = hwrite_r;
  assign hsize = hsize_r;
  assign hburst = hburst_r;
  assign hprot = hprot_r;
  assign hwdata = hwdata_r;
  assign hsel = hsel_r;
  assign hready_in = hready_in_r;
   
  
  // -----------------------------
  //  initialize the bus
  initial 
    begin
      read_error <= 0;
      bfm_ahb_default;  
    end  
    
    
  // -----------------------------
  //  addr_control_default
  task addr_control_default;
    begin
    haddr_r <= 32'hxxxxxxxx;
    htrans_r <= 2'bxx;
    hwrite_r <= 1'bx;
    hsize_r <= 3'bxxx;
    hburst_r <= 3'bxxx;
    hprot_r <= 4'bxxxx;
    end
  endtask

      
  // -----------------------------
  //  bfm_ahb_default
  task bfm_ahb_default;
    begin
    hready_out_wait_r <= 1'b0;
    
    addr_control_default();
    
    hwdata_r <= 32'hxxxxxxxx;
    hsel_r <= 1'b0;
    hready_in_r <= 1'b0;
    end
  endtask
  
  // -----------------------------
  //  bfm_ahb_write32
  task bfm_ahb_write32;
  
    input  [31:0] target_addr;
    input  [31:0] target_data;
  
    begin

      if(LOG_LEVEL >= 3)
        $display( "-+- bfm_ahb_write32: write 0x%x to 0x%x.", target_data, target_addr);
        
      @(posedge hclk);
      #1;
      
      haddr_r <= target_addr;
      hwdata_r <= target_data;
      htrans_r <= 2'b10;
      hwrite_r <= 1'b1;
      hsize_r <= 3'b010;
      hburst_r <= 3'b000;
      hprot_r <= 4'b0000;
      hsel_r <= 1'b1;
      hready_in_r <= 1'b1;
      
      @(negedge hclk);
      @(negedge hclk);

      hready_in_r = 1'b0;
      hsel_r <= 1'b0;
      
      addr_control_default();

      hready_out_wait_r <= 1'b1;
      wait(hready_out);
      hready_out_wait_r <= 1'b0;
     
      @(posedge hclk);
      bfm_ahb_default;
          
    end  
  endtask
  
  
  // -----------------------------
  //  bfm_ahb_read32
  task bfm_ahb_read32;
  
    input  [31:0] target_addr;
    input         check_data;
    input  [31:0] data_compare;
    
    reg    [31:0] read_data_r;
  
    begin

      @(posedge hclk);
      #1;
      
      haddr_r <= target_addr;
      htrans_r <= 2'b10;
      hwrite_r <= 1'b0;
      hsize_r <= 3'b010;
      hburst_r <= 3'b000;
      hprot_r <= 4'b0000;
      hsel_r <= 1'b1;
      hready_in_r <= 1'b1;
      
     @(negedge hclk);
     @(negedge hclk);
     
      hready_in_r = 1'b0;
      hsel_r <= 1'b0;
      
      addr_control_default();

      hready_out_wait_r <= 1'b1;
      wait(hready_out);
      hready_out_wait_r <= 1'b0;

      @(posedge hclk);
      read_data_r <= hrdata;
     
      @(posedge hclk);
      bfm_ahb_default;
      
      if(LOG_LEVEL >= 3)
        $display( "-+- bfm_ahb_read32:  read 0x%x from 0x%x.", read_data_r, target_addr);
        
      if( LOG_LEVEL >= 1 & check_data & (data_compare !== read_data_r) )
        begin
          read_error = 1'b1;
          $display( "-!- bfm_ahb_read32:  Data mismatch. Should be 0x%x.", data_compare);
        end  
        
    end  
  endtask
  
                              
  // -----------------------------
  //  bfm_ahb_write16
  task bfm_ahb_write16;
  
    input  [31:0] target_addr;
    input  [15:0] target_data;
    
    reg [15:0] target_data_lo;
    reg [15:0] target_data_hi;
  
    begin

      if(LOG_LEVEL >= 3)
        $display( "-+- bfm_ahb_write16: write 0x%x to 0x%x.", target_data, target_addr);
        
      @(posedge hclk);
      #1;
      
      haddr_r <= target_addr;
      
      target_data_lo = target_addr[1] ? 16'hxxxx : target_data; 
      target_data_hi = target_addr[1] ? target_data : 16'hxxxx;
      hwdata_r <= { target_data_hi, target_data_lo };
      
      htrans_r <= 2'b10;
      hwrite_r <= 1'b1;
      hsize_r <= 3'b001;
      hburst_r <= 3'b000;
      hprot_r <= 4'b0000;
      hsel_r <= 1'b1;
      hready_in_r <= 1'b1;
      
      @(negedge hclk);
      @(negedge hclk);
      
      hready_in_r = 1'b0;
      hsel_r <= 1'b0;
      
      addr_control_default();

      hready_out_wait_r <= 1'b1;
      wait(hready_out);
      hready_out_wait_r <= 1'b0;
     
      @(posedge hclk);
      bfm_ahb_default;
          
    end  
  endtask
  
                                
  // -----------------------------
  //  bfm_ahb_read16
  task bfm_ahb_read16;
  
    input  [31:0] target_addr;
    input         check_data;
    input  [15:0] data_compare;
    
    reg    [15:0] read_data_r;
  
    begin

      @(posedge hclk);
      #1;
      
      haddr_r <= target_addr;
      htrans_r <= 2'b10;
      hwrite_r <= 1'b0;
      hsize_r <= 3'b001;
      hburst_r <= 3'b000;
      hprot_r <= 4'b0000;
      hsel_r <= 1'b1;
      hready_in_r <= 1'b1;
      
     @(negedge hclk);
     @(negedge hclk);
     
      hready_in_r = 1'b0;
      hsel_r <= 1'b0;
      
      addr_control_default();

      hready_out_wait_r <= 1'b1;
      wait(hready_out);
      hready_out_wait_r <= 1'b0;
      
      @(posedge hclk);
      read_data_r <= target_addr[1] ? hrdata[31:16] : hrdata[15:0];
     
      @(posedge hclk);
      bfm_ahb_default;
      
      if(LOG_LEVEL >= 3)
        $display( "-+- bfm_ahb_read16:  read 0x%x from 0x%x.", read_data_r, target_addr);
        
      if( LOG_LEVEL >= 1 & check_data & (data_compare !== read_data_r) )
        begin
          read_error = 1'b1;
          $display( "-!- bfm_ahb_read32:  Data mismatch. Should be 0x%x.", data_compare);
        end  
        
    end  
  endtask
  
    // -----------------------------
  //  bfm_ahb_write8
  task bfm_ahb_write8;
  
    input  [31:0] target_addr;
    input  [7:0] target_data;
    
    reg  [7:0] target_data_0;
    reg  [7:0] target_data_1;
    reg  [7:0] target_data_2;
    reg  [7:0] target_data_3;
  
    begin

      if(LOG_LEVEL >= 3)
        $display( "-+- bfm_ahb_write8: write 0x%x to 0x%x.", target_data, target_addr);
        
      @(posedge hclk);
      #1;
      
      haddr_r <= target_addr;
      
      target_data_0 = (target_addr[1:0] == 2'b00) ? target_data : 8'hxxxx; 
      target_data_1 = (target_addr[1:0] == 2'b01) ? target_data : 8'hxxxx; 
      target_data_2 = (target_addr[1:0] == 2'b10) ? target_data : 8'hxxxx; 
      target_data_3 = (target_addr[1:0] == 2'b11) ? target_data : 8'hxxxx; 
      hwdata_r <= { target_data_3, target_data_2, target_data_1, target_data_0 };
      
      htrans_r <= 2'b10;
      hwrite_r <= 1'b1;
      hsize_r <= 3'b000;
      hburst_r <= 3'b000;
      hprot_r <= 4'b0000;
      hsel_r <= 1'b1;
      hready_in_r <= 1'b1;
      
      @(negedge hclk);
      @(negedge hclk);
      
      hready_in_r = 1'b0;
      hsel_r <= 1'b0;
      
      addr_control_default();

      hready_out_wait_r <= 1'b1;
      wait(hready_out);
      hready_out_wait_r <= 1'b0;
     
      @(posedge hclk);
      bfm_ahb_default;
          
    end  
  endtask
  
                                
  // -----------------------------
  //  bfm_ahb_read8
  task bfm_ahb_read8;
  
    input  [31:0] target_addr;
    input         check_data;
    input  [7:0] data_compare;
    
    reg    [7:0] read_data_r;
  
    begin

      @(posedge hclk);
      #1;
      
      haddr_r <= target_addr;
      htrans_r <= 2'b10;
      hwrite_r <= 1'b0;
      hsize_r <= 3'b000;
      hburst_r <= 3'b000;
      hprot_r <= 4'b0000;
      hsel_r <= 1'b1;
      hready_in_r <= 1'b1;
      
     @(negedge hclk);
     @(negedge hclk);
     
      hready_in_r = 1'b0;
      hsel_r <= 1'b0;
      
      addr_control_default();

      hready_out_wait_r <= 1'b1;
      wait(hready_out);
      hready_out_wait_r <= 1'b0;
      
      @(posedge hclk);
      case( target_addr[1:0] )
        2'b00:  read_data_r = hrdata[7:0];
        2'b01:  read_data_r = hrdata[15:8];
        2'b10:  read_data_r = hrdata[23:16];
        2'b11:  read_data_r = hrdata[31:24];
      endcase
     
      @(posedge hclk);
      bfm_ahb_default;
      
      if(LOG_LEVEL >= 3)
        $display( "-+- bfm_ahb_read8:  read 0x%x from 0x%x.", read_data_r, target_addr);
        
      if( LOG_LEVEL >= 1 & check_data & (data_compare !== read_data_r) )
        begin
          read_error = 1'b1;
          $display( "-!- bfm_ahb_read8:  Data mismatch. Should be 0x%x.", data_compare);
        end  
        
    end  
  endtask
  
  
  // -----------------------------
  //  outputs
    
  assign hclk     = bfm_clk;
  assign hresetn  = ~bfm_reset;
  
  
endmodule


