task uart_test1;

reg [1:0] data_bit        ;
reg	  stop_bits       ; // 0: 1 stop bit; 1: 2 stop bit;
reg	  stick_parity    ; // 1: force even parity
reg	  parity_en       ; // parity enable
reg	  even_odd_parity ; // 0: odd parity; 1: even parity

reg [7:0] data;
reg [15:0] divisor        ;	// divided by n * 16
reg [15:0] timeout        ;// wait time limit

reg [15:0] rx_nu;
reg [15:0] tx_nu;
reg [7:0] write_data [0:39];
reg 	fifo_enable       ;	// fifo mode disable
integer i,j;
begin
   data_bit           = 2'b11;
   stop_bits          = 0; // 0: 1 stop bit; 1: 2 stop bit;
   stick_parity       = 0; // 1: force even parity
   parity_en          = 1; // parity enable
   even_odd_parity    = 1; // 0: odd parity; 1: even parity
   divisor            = 3;	// divided by n * 16
   timeout            = 500;// wait time limit
   fifo_enable        = 0;	// fifo mode disable

   tb_uart.uart_init;
   tb_top.cpu_write('h3,8'h0,{27'h0,2'b10,1'b1,1'b1,1'b1});  
   
   
   for (i=0; i<40; i=i+1)
   	write_data[i] = $random;
   
   
     tb_top.tb_uart.control_setup (data_bit, stop_bits, parity_en, even_odd_parity, stick_parity, timeout, divisor, fifo_enable);
   
   
      fork
      begin
         for (i=0; i<40; i=i+1)
         begin
           $display ("\n... Writing char %d ...", write_data[i]);
            tb_top.tb_uart.write_char (write_data[i]);
         end
      end
   
      begin
         for (j=0; j<40; j=j+1)
         begin
           tb_top.tb_uart.read_char_chk(write_data[j]);
         end
      end
      join
   
      #100
      tb_top.tb_uart.report_status(rx_nu, tx_nu);
   
end
endtask
