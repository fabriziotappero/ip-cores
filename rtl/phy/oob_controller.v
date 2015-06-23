//oob_controller.v
/*
Distributed under the MIT license.
Copyright (c) 2011 Dave McCoy (dave.mccoy@cospandesign.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/


`include "sata_defines.v"

module oob_controller (

input               rst,              //reset
input               clk,

input               platform_ready,   //the underlying physical platform is
output  reg         linkup,           //link is finished

output  reg         tx_comm_reset,     //send a init OOB signal
output  reg         tx_comm_wake,     //send a wake OOB signal

input               comm_init_detect, //detected an init
input               comm_wake_detect, //detected a wake on the rx lines

input       [31:0]  rx_din,
input       [3:0]   rx_isk,
input               rx_is_elec_idle,
input               rx_byte_is_aligned,

output  reg [31:0]  tx_dout,
output  reg         tx_isk,
output  reg         tx_set_elec_idle,
output      [3:0]   lax_state


);

//platform signals

//Parameters

//States
parameter           IDLE                    = 4'h0;
parameter           SEND_RESET              = 4'h1;
parameter           WAIT_FOR_INIT           = 4'h2;
parameter           WAIT_FOR_NO_INIT        = 4'h3;
parameter           WAIT_FOR_CONFIGURE_END  = 4'h4;
parameter           SEND_WAKE               = 4'h5;
parameter           WAIT_FOR_WAKE           = 4'h6;
parameter           WAIT_FOR_NO_WAKE        = 4'h7;
parameter           WAIT_FOR_ALIGN          = 4'h8;
parameter           SEND_ALIGN              = 4'h9;
parameter           DETECT_SYNC             = 4'hA;
parameter           READY                   = 4'hB;

//Registers/Wires
reg         [3:0]   state;
reg         [31:0]  timer;
reg         [1:0]   no_align_count;

//timer used to send 'INITs', WAKEs' and read them
wire                timeout;
wire                align_detected;
wire                sync_detected;

//Submodules
//Asynchronous Logic
assign              timeout         = (timer == 0);
assign              align_detected  = ((rx_isk > 0) && (rx_din == `PRIM_ALIGN) && rx_byte_is_aligned);
assign              sync_detected   = ((rx_isk > 0) && (rx_din == `PRIM_SYNC));
assign              lax_state       = state;

//Synchronous Logic
initial begin
  tx_set_elec_idle      <=  1;
end

always @ (posedge clk) begin
  if (rst) begin
    state               <=  IDLE;
    linkup              <=  0;
    timer               <=  0;
    tx_comm_reset       <=  1;
    tx_comm_wake        <=  0;
    tx_dout             <=  0;
    tx_isk              <=  0;
    tx_set_elec_idle    <=  1;
    no_align_count      <=  0;
  end
  else begin
    //to support strobes, continuously reset the following signals
    tx_comm_reset       <=  0;
    tx_comm_wake        <=  0;

    tx_isk              <=  0;


    //timer (when reache 0 timeout has occured)
    if (timer > 0) begin
      timer                 <=  timer - 1;
    end

    //main state machine, if this reaches ready an initialization sequence has completed
    case (state)
      IDLE: begin
        linkup              <=  0;
        tx_set_elec_idle    <=  1;
        if (platform_ready) begin
          $display ("oob_controller: send RESET");
          //the platform is ready
          //  PLL has locked onto a clock
          //  DCM has generated the correct clocks
          timer             <=  32'h000000A2;
          state             <=  SEND_RESET;
        end
      end
      SEND_RESET: begin
//XXX: In the groundhog COMM RESET was continuously issued for a long period of time
        //send the INIT sequence, this will initiate a communication with the
        //SATA hard drive, or reset it so that it can be initiated to state

        //strobe the comm init so that the platform will send an INIT OOB signal
        tx_comm_reset       <=  1;
        if (timeout) begin
          timer               <=  32'd`INITIALIZE_TIMEOUT;
          state               <=  WAIT_FOR_INIT;
          $display ("oob_controller: wait for INIT");
        end
      end
      WAIT_FOR_INIT: begin
        //wait for a response from the SATA harddrive, if the timeout occurs
        //go back to the SEND_RESET state
        if (comm_init_detect) begin
          //HD said 'sup' go to a wake
          timer             <=  0;
          state             <=  WAIT_FOR_NO_INIT;
          $display ("oob_controller: wait for INIT to go low");
        end
        if (timeout) begin
          $display ("oob_controller: timed out while waiting for INIT");
          state             <=  IDLE;
        end
      end
      WAIT_FOR_NO_INIT: begin
        //wait for the init signal to go low from the device
        if (!comm_init_detect) begin
          $display ("oob_controller: INIT deasserted");
          $display ("oob_controller: start configuration");
          state             <=  WAIT_FOR_CONFIGURE_END;
        end
      end
      WAIT_FOR_CONFIGURE_END: begin
          $display ("oob_controller: System is configured");
          state             <=  SEND_WAKE;
          timer             <=  32'h0000009B;
        //end
      end
      SEND_WAKE:  begin
//XXX: In the groundhog COMM WAKE was continuously send for a long period of time
        //Send the WAKE sequence to the hard drive to initiate a wakeup sequence
        tx_comm_wake        <=  1;
//XXX: Is this timeout correct?
        //880uS
        if (timeout) begin
          //timer               <=  32'd`INITIALIZE_TIMEOUT;
          timer               <=  32'h000203AD;
          state               <=  WAIT_FOR_WAKE;
        end
      end
      WAIT_FOR_WAKE:  begin
        //Wait for the device to send a COMM Wake
        if (comm_wake_detect) begin
          //Found a comm wake, now wait for the device to stop sending WAKE
          timer             <=  0;
          state             <=  WAIT_FOR_NO_WAKE;
          $display ("oob_controller: WAKE detected");
        end
        if (timeout) begin
          //Timeout occured before reading WAKE
          state             <=  IDLE;
          $display ("oob_controller: timed out while waiting for WAKE to be asserted");
        end
      end
      WAIT_FOR_NO_WAKE: begin
        if (!comm_wake_detect) begin
          //The device stopped sending comm wake
//XXX: Is this timeout correct?
          //880uS
          $display ("oob_controller: detected WAKE deasserted");
          $display ("oob_controller: Send Dialtone, wait for ALIGN");
//Going to add more timeout
          timer             <=  32'h203AD;
          state             <=  WAIT_FOR_ALIGN;
        end
      end
      WAIT_FOR_ALIGN: begin
        //transmit the 'dialtone' continuously
        //since we need to start sending actual data (not OOB signals, get out
        //  of tx idle)
        tx_set_elec_idle    <=  0;
        //a sequence of 0's and 1's
        tx_dout             <=  `DIALTONE;
        tx_isk              <=  0;
        if (align_detected) begin
          //we got something from the device!
          timer             <=  0;
          //now send an align from my side
          state             <=  SEND_ALIGN;
          no_align_count    <=  0;
          $display ("oob_controller: ALIGN detected");
          $display ("oob_controller: Send out my ALIGNs");
        end
        if (timeout) begin
          //didn't read an align in time :( reset
          $display ("oob_controller: timed out while waiting for AIGN");
          state             <=  IDLE;
        end
      end
      SEND_ALIGN: begin
        tx_dout             <=  `PRIM_ALIGN;
        tx_isk              <=  1;
        if (!align_detected) begin
          $display ("oob_controller: detected ALIGN deasserted");
//XXX: Groundhog detects the SYNC primitve before declaring linkup
          if (no_align_count == 3) begin
            $display ("oob_controller: ready");
            state           <=  READY;
          end
          else begin
            no_align_count  <=  no_align_count + 1;
          end
        end
      end
      DETECT_SYNC: begin
        if (sync_detected) begin
          state             <=  READY;
        end
      end
      READY:  begin
        linkup      <=  1;
        if (comm_init_detect) begin
          state             <=  IDLE;
        end
      end
      default: begin
        state       <=  IDLE;
      end
    endcase

  end
end

endmodule

