
// #################################################################
// Module: spi tasks
//
// Description : All ST and ATMEL commands are made into tasks
// #################################################################

event      spi_error_detected;
reg  [1:0] spi_chip_no;

integer spi_err_cnt;

task spi_init;
begin
   spi_err_cnt = 0;
   spi_chip_no = 0;
end 
endtask 


always @spi_error_detected
begin
  //`TB_GLBL.test_err;
	spi_err_cnt = spi_err_cnt + 1;
end

// Write One Byte
task spi_write_byte;
    input [7:0] datain;
    reg  [31:0] read_data;
    begin

      @(posedge tb_top.xtal_clk) 
      tb_top.reg_write('h4,{datain,24'h0});
      tb_top.reg_write('h0,{1'b1,6'h0,
                                spi_chip_no[1:0],
                                2'b0,    // Write Operatopm
                                2'b0,    // Single Transfer
                                6'h10,    // sck clock period
                                5'h2,    // cs setup/hold period
                                8'h40 }); // cs bit information
      
     tb_top.reg_read('h0,read_data);
     while(read_data[31]) begin
        @(posedge tb_top.xtal_clk) ;
        tb_top.reg_read('h0,read_data);
      end 
    end
endtask

//***** ST : Write Enable task ******//
task spi_write_dword;
    input [31:0] cmd;
    input [7:0]  cs_byte;
    reg   [31:0] read_data;
    begin
      @(posedge tb_top.xtal_clk) 
      tb_top.reg_write('h4,{cmd});
      tb_top.reg_write('h0,{1'b1,6'h0,
                                spi_chip_no[1:0],
                                2'b0,    // Write Operatopm
                                2'h3,    // 4 Transfer
                                6'h10,    // sck clock period
                                5'h2,    // cs setup/hold period
                                cs_byte[7:0] }); // cs bit information
      
     tb_top.reg_read('h0,read_data);
     while(read_data[31]) begin
        @(posedge tb_top.xtal_clk) ;
        tb_top.reg_read('h0,read_data);
      end 
    end
endtask


//***** ST : Write Enable task ******//
task spi_read_dword;
    output [31:0] dataout;
    input  [7:0]  cs_byte;
    reg    [31:0] read_data;
    begin

      @(posedge tb_top.xtal_clk) 
      tb_top.reg_write('h0,{1'b1,6'h0,
                                spi_chip_no[1:0],
                                2'b1,    // Read Operatopm
                                2'h3,    // 4 Transfer
                                6'h10,    // sck clock period
                                5'h2,    // cs setup/hold period
                                cs_byte[7:0] }); // cs bit information
      
     tb_top.reg_read('h0,read_data);

     while(read_data[31]) begin
        @(posedge tb_top.xtal_clk) ;
        tb_top.reg_read('h0,read_data);
     end 

     tb_top.reg_read('h8,dataout);

    end
endtask



task spi_sector_errase;
    input [23:0] address;
    reg   [31:0] read_data;
    begin

      @(posedge tb_top.xtal_clk) ;
      tb_top.reg_write('h4,{8'hD8,address[23:0]});
      tb_top.reg_write('h0,{1'b1,6'h0,
                                spi_chip_no[1:0],
                                2'b0,    // Write Operatopm
                                2'h3,    // 4 Transfer
                                6'h10,    // sck clock period
                                5'h2,    // cs setup/hold period
                                8'h1 }); // cs bit information
      
     tb_top.reg_read('h0,read_data);

      $display("%t : %m : Sending Sector Errase for Address : %x",$time,address);
      

     tb_top.reg_read('h0,read_data);
     while(read_data[31]) begin
        @(posedge tb_top.xtal_clk) ;
        tb_top.reg_read('h0,read_data);
     end 
   end
endtask


task spi_page_write;
    input [23:0] address;
    reg [7:0] i;
    reg [31:0] write_data;
    begin

      spi_write_dword({8'h02,address[23:0]},8'h0);

      for(i = 0; i < 252 ; i = i + 4) begin
         write_data [31:24]  = i;
         write_data [23:16]  = i+1;
         write_data [15:8]   = i+2;
         write_data [7:0]    = i+3;
         spi_write_dword(write_data,8'h0);
         $display("%m : Writing Data-%d : %x",i,write_data);
      end
     
      // Writting last 4 byte with de-selecting the chip select 
         write_data [31:24]  = i;
         write_data [23:16]  = i+1;
         write_data [15:8]   = i+2;
         write_data [7:0]    = i+3;
      spi_write_dword(write_data,8'h1);
      $display("%m : Writing Data-%d : %x",i,write_data);

    end
endtask


task spi_page_read_verify;
    input [23:0] address;
    reg   [31:0] read_data;
    reg [7:0] i;
    reg [31:0] exp_data;
    begin

      spi_write_dword({8'h03,address[23:0]},8'h0);

      for(i = 0; i < 252 ; i = i + 4) begin
         exp_data [31:24]  = i;
         exp_data [23:16]  = i+1;
         exp_data [15:8]   = i+2;
         exp_data [7:0]    = i+3;
         spi_read_dword(read_data,8'h0);
         if(read_data != exp_data) begin
            -> spi_error_detected;
            $display("%m : ERROR : Data:%d-> Exp : %x Rxd : %x",i,exp_data,read_data);
         end else begin
            $display("%m : STATUS :  Data:%d Matched : %x ",i,read_data);
         end

      end
     
      // Reading last 4 byte with de-selecting the chip select 
         exp_data [31:24]  = i;
         exp_data [23:16]  = i+1;
         exp_data [15:8]   = i+2;
         exp_data [7:0]    = i+3;

         spi_read_dword(read_data,8'h0);
         if(read_data != exp_data) begin
            -> spi_error_detected;
            $display("%m : ERROR : Data:%d-> Exp : %x Rxd : %x",i,exp_data,read_data);
         end else begin
            $display("%m : STATUS :  Data:%d Matched : %x ",i,read_data);
         end

    end
endtask




task spi_op_over;
    reg [31:0] read_data;
    begin
     tb_top.reg_read('h0,read_data);
      while(read_data[31]) begin
        @(posedge tb_top.xtal_clk) ;
        tb_top.reg_read('h0,read_data);
      end 
      #100;
    end
endtask

task spi_wait_busy;
    reg [31:0] read_data;
    reg        exit_flag;
    integer    pretime;
    begin

    read_data = 1;
    pretime = $time;

     
  exit_flag = 1;
   while(exit_flag == 1) begin 

    tb_top.reg_write('h4,{8'h05,24'h0});
    tb_top.reg_write('h0,{1'b1,6'h0,
                                spi_chip_no[1:0],
                                2'b0,    // Write Operation
                                2'b0,    // 1 Transfer
                                6'h10,    // sck clock period
                                5'h2,    // cs setup/hold period
                                8'h0 }); // cs bit information


        tb_top.reg_read('h0,read_data);
        while(read_data[31]) begin
          @(posedge tb_top.xtal_clk) ;
          tb_top.reg_read('h0,read_data);
        end 

     // Send Status Request Cmd


      tb_top.reg_write('h0,{1'b1,6'h0,
                                spi_chip_no[1:0],
                                2'b1,    // Read Operation
                                2'b0,    // 1 Transfer
                                6'h10,    // sck clock period
                                5'h2,    // cs setup/hold period
                                8'h40 }); // cs bit information

        
        tb_top.reg_read('h0,read_data);
        while(read_data[31]) begin
          @(posedge tb_top.xtal_clk) ;
          tb_top.reg_read('h0,read_data);
        end 
      
        tb_top.reg_read('h8,read_data);
        exit_flag = read_data[24];
        $display("Total time Elapsed: %0t(us): %m : Checking the SPI RDStatus : %x",($time - pretime)/1000000 ,read_data);
      repeat (1000) @ (posedge tb_top.xtal_clk) ;
     end
  end
endtask



task spi_tb_status;
begin

   $display("#############################");
   $display("   Test Statistic            ");
   if(spi_err_cnt >0) begin 
      $display("TEST STATUS : FAILED ");
      $display("TOTAL ERROR COUNT : %d ",spi_err_cnt);
   end else begin
      $display("TEST STATUS : PASSED ");
   end
   $display("#############################");
end
endtask

