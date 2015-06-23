
`timescale  1ns/1ps

module uart_agent (
	test_clk,
	sin,
	dsr_n,
	cts_n,
	dcd_n,

	sout,
	dtr_n,
	rts_n,
	out1_n,
	out2_n);

input	test_clk;
output	sin;
output	dsr_n;
output	cts_n;
output	dcd_n;

input	sout;
input	dtr_n;
input	rts_n;
input	out1_n;
input	out2_n;

event	uart_read_done, uart_write_done;
event	error_detected,uart_parity_error, uart_stop_error1, uart_stop_error2;
event 	uart_timeout_error;
event	abort;

reg [15:0] rx_count;
reg [15:0] tx_count;
reg [15:0] par_err_count;
reg [15:0] stop_err1_cnt;
reg [15:0] stop_err2_cnt;
reg [15:0] timeout_err_cnt;
reg [15:0] err_cnt;

reg 	   sin, read, write;
reg	   dcd_n;
reg	   dsr_n, cts_n;
wire	   test_rx_clk;
reg	   test_tx_clk;
reg	   stop_err_check;

integer timeout_count;
integer data_bit_number;
reg [2:0] clk_count;

reg      error_ind; // 1 indicate error

initial 
begin
	sin = 1'b1;
	dsr_n = 1'b1;
	cts_n = 1'b1;
	dcd_n = 1'b1;
 	test_tx_clk = 0;
	clk_count = 0;
	stop_err_check = 0;
  error_ind = 0;
end

always @(posedge test_clk)
begin
	if (clk_count == 3'h0)
		test_tx_clk = ~test_tx_clk;
	
	clk_count = clk_count + 1;	
end
assign test_rx_clk = ~test_tx_clk;

always @(posedge test_clk)
begin
	timeout_count = timeout_count + 1;
	if (timeout_count == (control_setup.maxtime * 16))
		-> abort;
end

always @uart_read_done
	rx_count = rx_count + 1;

always @uart_write_done
	tx_count = tx_count + 1;

always @uart_parity_error begin
  error_ind = 1;
	par_err_count = par_err_count + 1;
end

always @uart_stop_error1 begin
  error_ind = 1;
	stop_err1_cnt = stop_err1_cnt + 1;
end

always @uart_stop_error2 begin
  error_ind = 1;
	stop_err2_cnt = stop_err2_cnt + 1;
end

always @uart_timeout_error begin
  error_ind = 1;
	timeout_err_cnt = timeout_err_cnt + 1;
end


always @error_detected begin
  error_ind = 1;
	err_cnt = err_cnt + 1;
end


////////////////////////////////////////////////////////////////////////////////
task uart_init;
begin
  read = 0;
  write = 0;
	tx_count = 0;
	rx_count = 0;
  stop_err_check = 0;
  par_err_count = 0;
  stop_err1_cnt = 0;
  stop_err2_cnt = 0;
  timeout_err_cnt = 0;
  err_cnt = 0;

end 
endtask 


////////////////////////////////////////////////////////////////////////////////
task read_char_chk;
input 	expected_data;

integer i;
reg	[7:0] expected_data;
reg 	[7:0] data;
reg	parity;

begin
	data <= 8'h0;
	parity <= 1;
	timeout_count = 0;

fork	
   begin : loop_1
        @(abort)
         $display (">>>>>  Exceed time limit, uart no responce.\n");
         ->uart_timeout_error;
         disable loop_2;
   end

   begin : loop_2

// start cycle
	@(negedge sout) 
	 disable loop_1;
	 read <= 1;

// data cycle
	@(posedge test_rx_clk);
	 for (i = 0; i < data_bit_number; i = i + 1)
	  begin
	    @(posedge test_rx_clk)
	    data[i] <=  sout;
	    parity <= parity ^ sout;
	  end		

// parity cycle
	if(control_setup.parity_en)
	begin
          @(posedge test_rx_clk);
	  if ((control_setup.even_odd_parity && (sout == parity)) ||
	     (!control_setup.even_odd_parity && (sout != parity)))
	     begin
		$display (">>>>>  Parity Error");	
 		-> error_detected;
		-> uart_parity_error;
	     end
	end

// stop cycle 1
        @(posedge test_rx_clk);	
	  if (!sout)
	     begin
		$display (">>>>>  Stop signal 1 Error");	
 		-> error_detected;
		-> uart_stop_error1;
	     end

// stop cycle 2
	if (control_setup.stop_bit_number)
	begin
	      @(posedge test_rx_clk);	// stop cycle 2
		if (!sout)
		  begin
		    $display (">>>>>  Stop signal 2 Error");	
 		    -> error_detected;
		    -> uart_stop_error2;
		  end
	end

/* 	Who Cares
// the stop bits transmitted is one and a half if it is 5-bit
	if (data_bit_number == 5)
	begin
	      	@(posedge test_rx_clk);	// stop cycle for 5-bit/per char
		if (!sout)
		  begin
		    $display (">>>>>  Stop signal 2 Error (5-Bit)");	
 		    -> error_detected;
		    -> uart_stop_error2;
		  end
	end
	else
*/

// wait another half cycle for tx_done signal
		@(negedge test_rx_clk);
	read <= 0;
	-> uart_read_done;

	if (expected_data != data)
	begin
		$display ("Error! Data return is %h, expecting %h", data, expected_data);
		-> error_detected;
	end
	else
		$display ("(%m) Data match  %h", expected_data);

	$display ("... Read Data from UART done cnt :%d...",rx_count +1);
   end
join

end

endtask

////////////////////////////////////////////////////////////////////////////////
task read_char;
output [7:0]	rxd_data;
output          timeout; // 1-> timeout
integer i;
reg	[7:0] rxd_data;
reg 	[7:0] data;
reg	parity;

begin
	data <= 8'h0;
	parity <= 1;
	timeout_count = 0;
	timeout = 0;

fork	
   begin : loop_1
        @(abort)
         //$display (">>>>>  Exceed time limit, uart no responce.\n");
         //->uart_timeout_error;
	  timeout = 1;
         disable loop_2;
   end

   begin : loop_2

// start cycle
	@(negedge sout) 
	 disable loop_1;
	 read <= 1;

// data cycle
	@(posedge test_rx_clk);
	 for (i = 0; i < data_bit_number; i = i + 1)
	  begin
	    @(posedge test_rx_clk)
	    data[i] <=  sout;
	    parity <= parity ^ sout;
	  end		

// parity cycle
	if(control_setup.parity_en)
	begin
          @(posedge test_rx_clk);
	  if ((control_setup.even_odd_parity && (sout == parity)) ||
	     (!control_setup.even_odd_parity && (sout != parity)))
	     begin
		$display (">>>>>  Parity Error");	
 		-> error_detected;
		-> uart_parity_error;
	     end
	end

// stop cycle 1
        @(posedge test_rx_clk);	
	  if (!sout)
	     begin
		$display (">>>>>  Stop signal 1 Error");	
 		-> error_detected;
		-> uart_stop_error1;
	     end

// stop cycle 2
	if (control_setup.stop_bit_number)
	begin
	      @(posedge test_rx_clk);	// stop cycle 2
		if (!sout)
		  begin
		    $display (">>>>>  Stop signal 2 Error");	
 		    -> error_detected;
		    -> uart_stop_error2;
		  end
	end

// wait another half cycle for tx_done signal
		@(negedge test_rx_clk);
	read <= 0;
	-> uart_read_done;

//        $display ("(%m) Received Data  %c", data);
//	$display ("... Read Data from UART done cnt :%d...",rx_count +1);
        $write ("%c",data);
	rxd_data = data;
   end
join

end

endtask

////////////////////////////////////////////////////////////////////////////////
task write_char;
input [7:0] data;

integer i;
reg parity;	// 0: odd parity, 1: even parity

begin
	parity <=  #1 1;

// start cycle
	@(posedge test_tx_clk)
	 begin
		sin <= #1 0;
		write <= #1 1;
	 end

// data cycle
	begin
	   for (i = 0; i < data_bit_number; i = i + 1)
	   begin
		@(posedge test_tx_clk)
		    sin <= #1 data[i];
		parity <= parity ^ data[i];
	   end
	end

// parity cycle
	if (control_setup.parity_en)
	begin
		@(posedge test_tx_clk)
			sin <= #1 
				control_setup.even_odd_parity ? !parity : parity;
	end

// stop cycle 1
	@(posedge test_tx_clk)
		sin <= #1 stop_err_check ? 0 : 1;

// stop cycle 2
	@(posedge test_tx_clk);
		sin <= #1 1;
	if (data_bit_number == 5)
		@(negedge test_tx_clk);
	else if (control_setup.stop_bit_number)
		@(posedge test_tx_clk);

	write <= #1 0;
	// $display ("... Write data %h to UART done cnt : %d ...\n", data,tx_count+1);
        $write ("%c",data);
	-> uart_write_done;
end
endtask


////////////////////////////////////////////////////////////////////////////////
task control_setup;
input	  [1:0] data_bit_set;	
input		stop_bit_number;
input		parity_en;
input		even_odd_parity;
input	 [15:0] maxtime;
input		fifo_enable;

begin
	data_bit_number = data_bit_set + 5;
end
endtask


////////////////////////////////////////////////////////////////////////////////
task report_status;
output 	[15:0] rx_nu;
output 	[15:0] tx_nu;
begin
	$display ("-------------------- Reporting Configuration --------------------");
	$display ("	Data bit number setting is : %0d", data_bit_number);
	$display ("	Stop bit number setting is : %0d", control_setup.stop_bit_number + 1);
	if (control_setup.parity_en) 
	$display ("	Parity is enable");
	else
	$display ("	Parity is disable");
	
	if (control_setup.even_odd_parity)
	$display ("	Even parity setting");
	else	
	$display ("	Odd parity setting");

	if (control_setup.fifo_enable)
	$display ("	FIFO mode is enable");
	else	
	$display ("	FIFO mode is disable");

	$display ("-----------------------------------------------------------------");

	$display ("-------------------- Reporting Status --------------------\n");
	$display ("	Number of character received is : %d", rx_count);
	$display ("	Number of character sent     is : %d", tx_count);
	$display ("	Number of parity error rxd   is : %d", par_err_count);
	$display ("	Number of stop1  error rxd   is : %d", stop_err1_cnt);
	$display ("	Number of stop2  error rxd   is : %d", stop_err2_cnt);
	$display ("	Number of timeout error      is : %d", timeout_err_cnt);
	$display ("	Number of error              is : %d", err_cnt);
	$display ("-----------------------------------------------------------------");

	rx_nu = rx_count;
	tx_nu = tx_count;
end
endtask


////////////////////////////////////////////////////////////////////////////////
endmodule
