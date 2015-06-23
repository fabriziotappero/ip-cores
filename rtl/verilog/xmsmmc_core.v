// Copyright 2004-2005 Openchip
// http://www.openchip.org


`include "mmc_boot_defines.v"

module xmsmmc_core(

  // CCLK From FPGA
  cclk,
  // Done From FPGA, indicates success
  done,
  // Init From FPGA (start of config and ERROR)
  init,
  
  //
  // MMC Card I/O  
  // CS is not used tie up, pull up or leave open (not used)
  // DAT is directly connected to FPGA DIN(D0)
  
  // CMD Pin
  mmc_cmd,
  // CLK Pin
  mmc_clk,

  // Output enable control
  dis,

  // Error goes high if config error, or no MMC card inserted         
  error
  );


// global clock input, is divided to provide 400KHz and 20MHz Clocks    
input  cclk;

input  init;      // Pulse to start config
input  done;      //

// error/status out, goes high on error
output error;

// MMC Card I/O tristate when reset active and after config done/error
inout  mmc_cmd;
output mmc_clk;

//
input dis;


// command data to MMC card
wire cmd_data_out;

// "Transfer Mode" switch MMC clock to direct CCLK!
wire mode_transfer;

//

// CMD1 Response Start Bit
// if not Low, then no Card detected, error !
wire cmd1_resp_start_bit;
// CMD1 Response Busy Bit
// if Low then busy, loop until goes high
wire cmd1_resp_busy_bit;




//
// ASYNC reset we do not yet have clock!
//

//wire int_reset;
//assign int_reset = !init & !done;

wire config_request;
assign config_request = !init & !done;



/*
reg int_reset;

always @(posedge cclk or posedge config_request)
  if (config_request)
    int_reset <= 1'b1;
  else
    int_reset <= 1'b0;
*/

wire int_reset;
assign int_reset = config_request;


// ---------------------------------------------------------------------------
// Clock Prescaler
// ---------------------------------------------------------------------------

wire clk_mmc;
 
mmc_boot_prescaler_16_1 precaler_i (
        .rst    (               int_reset       ),
	.sys_clk(		cclk		), 
	.mmc_clk(		clk_mmc		), 
	.mode_transfer(		mode_transfer	)
	);



// command bit counter
reg [7:0] counter_command_bits;

always @(negedge clk_mmc or posedge int_reset)
  if (int_reset)
    counter_command_bits <= 8'b00000000;
  else
    counter_command_bits <= counter_command_bits + 8'b00000001;

// ------------------------------------------------------------------
//
// ------------------------------------------------------------------

// command sequencer state machine
reg [3:0] cmd_state;
reg [3:0] cmd_state_next;

wire cmd_done;
assign cmd_done = counter_command_bits == 8'b11111111;

// CMD1 response Start (must be low if card is responding
assign cmd1_resp_start_bit = counter_command_bits[7:0] == 8'b00110101;
// CMD1 response Busy bit (must be high if card is ready)
assign cmd1_resp_busy_bit = counter_command_bits[7:0] == 8'b00111101;

//
// COMMAND State machine
//
always @(posedge clk_mmc or posedge int_reset)
  if (int_reset)
    cmd_state <= `CMD_INIT;
  else 
    cmd_state <= cmd_state_next;

// R1 48 bits
// 00xx xxxx Sxxx xxxx ... xxx1
// R2 136 bits !!
// 00xx ... xxx1
// R3 48 bit
// 00xx ... xxx1

always @(cmd_state, done, cmd_done, init, mmc_cmd, cmd1_resp_start_bit, cmd1_resp_busy_bit)
  begin
    cmd_state_next = cmd_state;

    case (cmd_state) // synopsys full_case parallel_case
	 
	 `CMD_INIT: // send 80+ clocks, then send CMD0
	   begin
	     if (cmd_done & init) cmd_state_next = `CMD0;
	   end

	 `CMD0: // No response command, go send CMD1
	   begin
	     if (cmd_done) cmd_state_next = `CMD1;
	   end

	 `CMD1: // send CMD1, loop until response bit31 is high
	   begin
	     // Response start detected ?
		// if not no card and go error
	     if ( (cmd1_resp_start_bit==1'b1) & (mmc_cmd==1'b1) ) 
		  cmd_state_next = `CMD_CONFIG_ERROR;
          	// if not busy advance to next
		// we can jump to next command as we are in the middle
		// of response time, so the next command will not
		// start before the last response has been read
	     if ( (cmd1_resp_busy_bit==1'b1) & (mmc_cmd==1'b1) ) 
		  cmd_state_next = `CMD1_IDLE;
	   end

	 `CMD1_IDLE: // just some clocks spacing
	   begin
	     if (cmd_done) cmd_state_next = `CMD2;
	   end

	 `CMD2: // send CMD2	R2
	   begin
	     if (cmd_done) cmd_state_next = `CMD3;
	   end

	 `CMD3: // send CMD3	R1
	   begin
	     if (cmd_done) cmd_state_next = `CMD7;
	   end

	 `CMD7: // send CMD7	R1
	   begin
	     if (cmd_done) cmd_state_next = `CMD11;
	   end

	 `CMD11: // send CMD11 R1
	   begin
	     if (cmd_done) cmd_state_next = `CMD_TRANSFER;
	   end
	 
	 //
	 // Commands are sent, CMD is held high
	 // MMC Card content is streamed out on DAT pin
	 //
	 `CMD_TRANSFER: 
	   begin
	     if (done)
            cmd_state_next = `CMD_CONFIG_DONE;

	     if (!init)
            cmd_state_next = `CMD_CONFIG_ERROR;
	   end
	 
	 // Config done succesfully!
	 `CMD_CONFIG_DONE:
	   begin
	     
	   end

	 // Some error has occoured
	 `CMD_CONFIG_ERROR:
	   begin

	   end

    endcase
  end

//
// transfer mode, select high speed clock
//
assign mode_transfer = cmd_state == `CMD_TRANSFER;


// ------------------------------------------------------------------
//
// Just emulating a memory to select CMD Data output
//
// ------------------------------------------------------------------

wire cmd_bits;
// 
mmc_cmd_select mmc_cmd_select_i (
	.cmd(		cmd_state		), 
	.bit(		counter_command_bits	), 
	.cmd_active(	cmd_bits		),
	.data(		cmd_data_out		)
    );


// ------------------------------------------------------------------
//
// ------------------------------------------------------------------

assign mmc_cmd = (!dis & cmd_bits) ? cmd_data_out : 1'bz;
assign mmc_clk = !dis ? (int_reset ? 1'b0 : clk_mmc) : 1'bz;

// signal ERROR (active high)
assign error = cmd_state == `CMD_CONFIG_ERROR;


endmodule


