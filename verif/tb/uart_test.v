task uart_test;

reg [1:0] data_bit        ;
reg	  stop_bits       ; // 0: 1 stop bit; 1: 2 stop bit;
reg	  parity_en       ; // parity enable
reg	  even_odd_parity ; // 0: odd parity; 1: even parity

reg [15:0] timeout       ;// wait time limit

reg [15:0] rx_nu;
reg [15:0] tx_nu;
reg [7:0] read_data;
reg [31:0] read_word;
reg [7:0] write_data;
reg       flag;
reg 	fifo_enable      ;	// fifo mode disable
integer i,j;
begin
tb_uart.uart_init;

data_bit         = 2'b11;
stop_bits         = 1'b1;
parity_en         = 1'b0;
even_odd_parity   = 1'b1;
timeout           = 500;
fifo_enable       = 0;

  tb_top.tb_uart.control_setup (data_bit, stop_bits, parity_en, even_odd_parity, timeout, fifo_enable);



   $write ("\n(%t)Received Character:\n",$time);
   flag = 0;
   while(flag == 0)
   begin
        tb_top.tb_uart.read_char(read_data,flag);
        //$write ("%c",read_data);
   end


   tb_top.reg_write(16'h0000,32'h11223344);
   tb_top.reg_write(16'h0004,32'h55667788);


   tb_top.reg_read(16'h0000,read_word);
   tb_top.reg_read(16'h0004,read_word);

   #100
   tb_top.tb_uart.report_status(rx_nu, tx_nu);

end
endtask


