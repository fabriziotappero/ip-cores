
initial
begin
   reg_cs  = 0;
   reg_be  = 4'h0;
end

task cpu_read;
  input  [2:0] block_id; 
  input  [15:0] address;
  output [31:0] read_data;
  begin 
      @(posedge app_clk);
      if(block_id == 1) reg_id  = `ADDR_SPACE_MAC;
      if(block_id == 2) reg_id  = `ADDR_SPACE_SPI;
      if(block_id == 3) reg_id  = `ADDR_SPACE_UART;
      if(block_id == 4) reg_id  = `ADDR_SPACE_RAM;
      reg_cs = 1;
      reg_wr = 0;
      reg_be = 4'hF;
      reg_addr = address;
      @(posedge reg_ack);
       #1 read_data = reg_rdata;
      @(posedge app_clk);
          reg_cs  = 0;
      //$display ("Config-Read: Id: %h Addr = %h, Data = %h", block_id,address, read_data);
  end
endtask

task cpu_write;
  input  [2:0] block_id; // 1/2/3 --> mac/spi/uart 
  input  [15:0] address;
  input  [31:0] write_data;
  begin 
      $display ("Config-Write: Id: %h Addr = %h, Cfg. Data = %h", block_id,address, write_data);
      @(posedge app_clk);
      if(block_id == 1) reg_id  = `ADDR_SPACE_MAC;
      if(block_id == 2) reg_id  = `ADDR_SPACE_SPI;
      if(block_id == 3) reg_id  = `ADDR_SPACE_UART;
      reg_cs = 1;
      reg_wr = 1;
      reg_be = 4'hF;
      reg_addr = address;
      reg_wdata = write_data;
      @(posedge reg_ack);
      @(posedge app_clk);
      reg_cs  = 0;
      reg_wr = 0;
  end
endtask

