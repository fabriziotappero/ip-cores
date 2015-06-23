//----------------------------------------------------------------------------
// user_logic.v - module
//----------------------------------------------------------------------------
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//----------------------------------------------------------------------------
// Filename:          user_logic.v
// Version:           1.00.a
// Description:       User logic module.
// Date:              Thu Sep 20 01:01:07 2007 (by Create and Import Peripheral Wizard)
// Verilog Standard:  Verilog-2001
//----------------------------------------------------------------------------
// Naming Conventions:
//   active low signals:                    "*_n"
//   clock signals:                         "clk", "clk_div#", "clk_#x"
//   reset signals:                         "rst", "rst_n"
//   generics:                              "C_*"
//   user defined types:                    "*_TYPE"
//   state machine next state:              "*_ns"
//   state machine current state:           "*_cs"
//   combinatorial signals:                 "*_com"
//   pipelined or register delay signals:   "*_d#"
//   counter signals:                       "*cnt*"
//   clock enable signals:                  "*_ce"
//   internal version of output port:       "*_i"
//   device pins:                           "*_pin"
//   ports:                                 "- Names begin with Uppercase"
//   processes:                             "*_PROCESS"
//   component instantiations:              "<ENTITY_>I_<#|FUNC>"
//----------------------------------------------------------------------------

module user_logic
(
  // -- ADD USER PORTS BELOW THIS LINE ---------------
  // --USER ports added here 
  DQ_Wire_I,
  DQ_Wire_O,
  DQ_Wire_T,
  main_fifty_clock,
  // -- ADD USER PORTS ABOVE THIS LINE ---------------

  // -- DO NOT EDIT BELOW THIS LINE ------------------
  // -- Bus protocol ports, do not add to or delete 
  Bus2IP_Clk,                     // Bus to IP clock
  Bus2IP_Reset,                   // Bus to IP reset
  Bus2IP_Data,                    // Bus to IP data bus for user logic
  Bus2IP_BE,                      // Bus to IP byte enables for user logic
  Bus2IP_RdCE,                    // Bus to IP read chip enable for user logic
  Bus2IP_WrCE,                    // Bus to IP write chip enable for user logic
  IP2Bus_Data,                    // IP to Bus data bus for user logic
  IP2Bus_Ack,                     // IP to Bus acknowledgement
  IP2Bus_Retry,                   // IP to Bus retry response
  IP2Bus_Error,                   // IP to Bus error response
  IP2Bus_ToutSup                  // IP to Bus timeout suppress
  // -- DO NOT EDIT ABOVE THIS LINE ------------------
); // user_logic

// -- ADD USER PARAMETERS BELOW THIS LINE ------------
// --USER parameters added here 
// -- ADD USER PARAMETERS ABOVE THIS LINE ------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol parameters, do not add to or delete
parameter C_DWIDTH                       = 32;
parameter C_NUM_CE                       = 4;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

// -- ADD USER PORTS BELOW THIS LINE -----------------
// --USER ports added here 
// -- ADD USER PORTS ABOVE THIS LINE -----------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol ports, do not add to or delete
input DQ_Wire_I;
output DQ_Wire_O;
output DQ_Wire_T;
input main_fifty_clock;
input                                     Bus2IP_Clk;
input                                     Bus2IP_Reset;
input      [0 : C_DWIDTH-1]               Bus2IP_Data;
input      [0 : C_DWIDTH/8-1]             Bus2IP_BE;
input      [0 : C_NUM_CE-1]               Bus2IP_RdCE;
input      [0 : C_NUM_CE-1]               Bus2IP_WrCE;
output     [0 : C_DWIDTH-1]               IP2Bus_Data;
output                                    IP2Bus_Ack;
output                                    IP2Bus_Retry;
output                                    IP2Bus_Error;
output                                    IP2Bus_ToutSup;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

//----------------------------------------------------------------------------
// Implementation
//----------------------------------------------------------------------------

  // --USER nets declarations added here, as needed for user logic

  // Nets for user logic slave model s/w accessible register example
  reg        [0 : C_DWIDTH-1]               slv_reg0;
  reg        [0 : C_DWIDTH-1]               slv_reg1;
  reg        [0 : C_DWIDTH-1]               slv_reg2;
  reg        [0 : C_DWIDTH-1]               slv_reg3;
  wire       [0 : 3]                        slv_reg_write_select;
  wire       [0 : 3]                        slv_reg_read_select;
  reg        [0 : C_DWIDTH-1]               slv_ip2bus_data;
  wire                                      slv_read_ack;
  wire                                      slv_write_ack;
  integer                                   byte_index, bit_index;

  // --USER logic implementation added here
  
  reg DQ_Wire_Out = 0;
  reg DQ_Wire_HiZ = 0;
  
  assign DQ_Wire_O = DQ_Wire_Out;
  assign DQ_Wire_T = DQ_Wire_HiZ;
  
	reg primary_clock; 
	reg [6:0] primary_clock_divider;
	reg [2:0] onewire_opcode = 0;
	reg [2:0] onewire_inject_opcode = 0;
	reg [9:0] onewire_timer = 0;
	reg [2:0] onewire_seq_state = 0;
	reg onewire_received_bit = 0;
	
	reg [2:0] byte_opcode = 0;
	reg [2:0] byte_inject_opcode = 0;
	reg [7:0] write_byte = 0;
	reg [7:0] read_byte = 0;
	//wire [7:0] write_byte_rev = 0;
	//wire [7:0] read_byte_rev;
	reg [4:0] byte_counter = 0;
	
	/*assign write_byte_rev[7] = write_byte[0];
	assign write_byte_rev[6] = write_byte[1];
	assign write_byte_rev[5] = write_byte[2];
	assign write_byte_rev[4] = write_byte[3];
	assign write_byte_rev[3] = write_byte[4];
	assign write_byte_rev[2] = write_byte[5];
	assign write_byte_rev[1] = write_byte[6];
	assign write_byte_rev[0] = write_byte[7];
	
	assign read_byte_rev[7] = read_byte[0];
	assign read_byte_rev[6] = read_byte[1];
	assign read_byte_rev[5] = read_byte[2];
	assign read_byte_rev[4] = read_byte[3];
	assign read_byte_rev[3] = read_byte[4];
	assign read_byte_rev[2] = read_byte[5];
	assign read_byte_rev[1] = read_byte[6];
	assign read_byte_rev[0] = read_byte[7];*/
	
	reg read_shutdown_one = 0;
	reg onewire_presence_detected = 0;
	
	wire [0:31] onewire_status_register;
	assign onewire_status_register[0:30] = 0;
	assign onewire_status_register[31] = onewire_presence_detected;

  // ------------------------------------------------------
  // Example code to read/write user logic slave model s/w accessible registers
  // 
  // Note:
  // The example code presented here is to show you one way of reading/writing
  // software accessible registers implemented in the user logic slave model.
  // Each bit of the Bus2IP_WrCE/Bus2IP_RdCE signals is configured to correspond
  // to one software accessible register by the top level template. For example,
  // if you have four 32 bit software accessible registers in the user logic, you
  // are basically operating on the following memory mapped registers:
  // 
  //    Bus2IP_WrCE or   Memory Mapped
  //       Bus2IP_RdCE   Register
  //            "1000"   C_BASEADDR + 0x0
  //            "0100"   C_BASEADDR + 0x4
  //            "0010"   C_BASEADDR + 0x8
  //            "0001"   C_BASEADDR + 0xC
  // 
  // ------------------------------------------------------
  
  assign
    slv_reg_write_select = Bus2IP_WrCE[0:3],
    slv_reg_read_select  = Bus2IP_RdCE[0:3],
    slv_write_ack        = Bus2IP_WrCE[0] || Bus2IP_WrCE[1] || Bus2IP_WrCE[2] || Bus2IP_WrCE[3],
    slv_read_ack         = Bus2IP_RdCE[0] || Bus2IP_RdCE[1] || Bus2IP_RdCE[2] || Bus2IP_RdCE[3];

  // implement slave model register(s)
  always @( posedge Bus2IP_Clk )
    begin: SLAVE_REG_WRITE_PROC

      if ( Bus2IP_Reset == 1 )
        begin
          slv_reg0 <= 0;
          slv_reg1 <= 0;
          slv_reg2 <= 0;
          slv_reg3 <= 0;
        end
      else
        case ( slv_reg_write_select )
          4'b1000 :
            for ( byte_index = 0; byte_index <= (C_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg0[bit_index] <= Bus2IP_Data[bit_index];
          4'b0100 :
            for ( byte_index = 0; byte_index <= (C_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg1[bit_index] <= Bus2IP_Data[bit_index];
          4'b0010 :
            for ( byte_index = 0; byte_index <= (C_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg2[bit_index] <= Bus2IP_Data[bit_index];
          4'b0001 :
            for ( byte_index = 0; byte_index <= (C_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg3[bit_index] <= Bus2IP_Data[bit_index];
          default : ;
        endcase
		  
		  if (slv_reg3[31] == 1) begin
				if (byte_opcode == 0) begin
					byte_inject_opcode = slv_reg2[24:31];
					write_byte = slv_reg1[24:31];
				end
				
				if (byte_opcode != 0) begin
					byte_inject_opcode = 0;
					slv_reg3 <= 0;
				end
		  end

    end // SLAVE_REG_WRITE_PROC

  // implement slave model register read mux
  always @( slv_reg_read_select or slv_reg0 or slv_reg1 or slv_reg2 or slv_reg3 )
    begin: SLAVE_REG_READ_PROC

      case ( slv_reg_read_select )
        //4'b1000 : slv_ip2bus_data <= slv_reg0;
		  4'b1000 : slv_ip2bus_data <= read_byte;
		  //4'b1000 : slv_ip2bus_data <= read_byte_rev;
        4'b0100 : slv_ip2bus_data <= slv_reg1;
        4'b0010 : slv_ip2bus_data <= slv_reg2;
        //4'b0001 : slv_ip2bus_data <= slv_reg3;
		  4'b0001 : slv_ip2bus_data <= onewire_status_register;
        default : slv_ip2bus_data <= 0;
      endcase

    end // SLAVE_REG_READ_PROC
	
	always @(posedge main_fifty_clock) begin
		// 1 microsecond is our 50MHz clock divided by 50
		primary_clock_divider = primary_clock_divider + 1;
		if (primary_clock_divider >= 25) begin
			primary_clock_divider = 0;
			primary_clock = !primary_clock;
		end
	end
	
	reg primary_clock_div_by_two = 0;
	always @(posedge primary_clock) begin
		primary_clock_div_by_two = !primary_clock_div_by_two;
	end
	
	always @(posedge primary_clock_div_by_two) begin
		onewire_inject_opcode = 0;			// Reset this by default--as this clock is divided by two, the other loop will capture this easily
	
		if (byte_opcode == 0) begin
			byte_opcode = byte_inject_opcode;
			read_shutdown_one = 1;
			byte_counter = 0;
		end
		
		if (byte_opcode == 1) begin
			// Write a byte
			if (onewire_opcode == 0) begin		// Ready to inject?
				if (byte_counter < 8) begin
					if (write_byte[byte_counter] == 0) begin
					//if (write_byte_rev[byte_counter] == 0) begin
						onewire_inject_opcode = 1;
					end else begin
						onewire_inject_opcode = 2;
					end
					byte_counter = byte_counter + 1;
				end else begin
					byte_opcode = 0;
				end
			end
		end
		
		if (byte_opcode == 2) begin
			// Read a byte
			if (onewire_opcode == 0) begin		// Ready to inject?
				if (byte_counter < 9) begin
					if (byte_counter < 8) begin
						onewire_inject_opcode = 3;		// Read
					end
					if (read_shutdown_one == 0) begin
						read_byte[byte_counter - 1] = onewire_received_bit;
					end else begin
						read_shutdown_one = 0;
					end
					byte_counter = byte_counter + 1;
				end else begin
					byte_opcode = 0;
				end
			end
		end
		
		if (byte_opcode == 3) begin
			// Bus reset!!!
			if (onewire_opcode == 0) begin		// Ready to inject?
				onewire_inject_opcode = 4;			// Reset!
				byte_opcode = 0;
			end
		end
	end
	
	always @(posedge primary_clock) begin
		if (onewire_opcode == 0) begin
			onewire_opcode = onewire_inject_opcode;
			onewire_seq_state = 0;
			
			//DQ_Wire_HiZ = 1;			// HiZ
			//DQ_Wire_Out = 1;			// Pull it high
		end
	
		if (onewire_opcode == 1) begin
			// Write a zero--60uS of low, then 30uS of high should do the trick!
			if (onewire_seq_state == 2) begin
				onewire_timer = onewire_timer - 1;
				if (onewire_timer == 0) begin
					onewire_opcode = 0;
				end
			end
			if (onewire_seq_state == 1) begin
				onewire_timer = onewire_timer - 1;
				if (onewire_timer == 0) begin
					onewire_timer = 30;
					onewire_seq_state = 2;
					
					DQ_Wire_HiZ = 1;			// HiZ
					DQ_Wire_Out = 1;			// Pull it high
				end
			end
			if (onewire_seq_state == 0) begin
				onewire_timer = 60;
				onewire_seq_state = 1;
				
				DQ_Wire_HiZ = 0;			// Drive the output
				DQ_Wire_Out = 0;			// Pull it low
			end
		end
		
		if (onewire_opcode == 2) begin
			// Write a one--7uS of low, then 83uS of high should do the trick!
			if (onewire_seq_state == 2) begin
				onewire_timer = onewire_timer - 1;
				if (onewire_timer == 0) begin
					onewire_opcode = 0;
				end
			end
			if (onewire_seq_state == 1) begin
				onewire_timer = onewire_timer - 1;
				if (onewire_timer == 0) begin
					onewire_timer = 83;
					onewire_seq_state = 2;
					
					DQ_Wire_HiZ = 1;			// HiZ
					DQ_Wire_Out = 1;			// Pull it high
				end
			end
			if (onewire_seq_state == 0) begin
				onewire_timer = 7;
				onewire_seq_state = 1;
				
				DQ_Wire_HiZ = 0;			// Drive the output
				DQ_Wire_Out = 0;			// Pull it low
			end
		end
		
		if (onewire_opcode == 3) begin
			// Read a bit--2uS of low, then 10uS of high Z, then read, then wait 78uS should do it!
			if (onewire_seq_state == 3) begin
				onewire_timer = onewire_timer - 1;
				if (onewire_timer == 0) begin
					onewire_opcode = 0;
				end
			end
			if (onewire_seq_state == 2) begin
				onewire_timer = onewire_timer - 1;
				if (onewire_timer == 0) begin
					onewire_timer = 78;
					onewire_seq_state = 3;
					
					onewire_received_bit = DQ_Wire_I;
				end
			end
			if (onewire_seq_state == 1) begin
				onewire_timer = onewire_timer - 1;
				if (onewire_timer == 0) begin
					onewire_timer = 10;
					onewire_seq_state = 2;
					
					DQ_Wire_HiZ = 1;			// HiZ
					DQ_Wire_Out = 1;			// Pull it high
				end
			end
			if (onewire_seq_state == 0) begin
				onewire_timer = 2;
				onewire_seq_state = 1;
				
				DQ_Wire_HiZ = 0;			// Drive the output
				DQ_Wire_Out = 0;			// Pull it low
			end
		end
		
		if (onewire_opcode == 4) begin
			// Send bus reset--520uS of low, then 60uS of high Z, then read, then 480uS of high Z should do it!
			if (onewire_seq_state == 3) begin
				onewire_timer = onewire_timer - 1;
				if (onewire_timer == 0) begin
					onewire_opcode = 0;
				end
			end
			if (onewire_seq_state == 2) begin
				onewire_timer = onewire_timer - 1;
				if (onewire_timer == 0) begin
					onewire_timer = 480;
					onewire_seq_state = 3;
				
					onewire_presence_detected = !DQ_Wire_I;
				end
			end
			if (onewire_seq_state == 1) begin
				onewire_timer = onewire_timer - 1;
				if (onewire_timer == 0) begin
					onewire_timer = 60;
					onewire_seq_state = 2;
					
					DQ_Wire_HiZ = 1;			// HiZ
					DQ_Wire_Out = 1;			// Pull it high
				end
			end
			if (onewire_seq_state == 0) begin
				onewire_timer = 520;
				onewire_seq_state = 1;
				onewire_presence_detected = 0;
				
				DQ_Wire_HiZ = 0;			// Drive the output
				DQ_Wire_Out = 0;			// Pull it low
			end
		end
	end

  // ------------------------------------------------------------
  // Example code to drive IP to Bus signals
  // ------------------------------------------------------------

  assign IP2Bus_Data        = slv_ip2bus_data;
  assign IP2Bus_Ack         = slv_write_ack || slv_read_ack;
  assign IP2Bus_Error       = 0;
  assign IP2Bus_Retry       = 0;
  assign IP2Bus_ToutSup     = 0;

endmodule
