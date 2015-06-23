// ============================================================================
//	FF_PS2kbd.v - PS2 compatibla keyboard interface
//
//	2005.2010  Robert Finch
//	robfinch<remove>@FPGAfield.ca
//
//
//  This source code is available for evaluation and validation purposes
//  only. This copyright statement and disclaimer must remain present in
//  the file.
//
//
//	NO WARRANTY.
//  THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
//  EXPRESS OR IMPLIED. The user must assume the entire risk of using the
//  Work.
//
//  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
//  INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
//  THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.
//
//  IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
//  IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
//  REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
//  LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
//  AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
//  LOSSES RELATING TO SUCH UNAUTHORIZED USE.
//
//
//	PS2 compatible keyboard / mouse interface
//
//		This core provides a raw interface to the a PS2
//	keyboard or mouse. The interface is raw in the sense
//	that it doesn't do any scan code processing, it
//	just supplies it to the system. The core uses a
//	WISHBONE compatible bus interface.
//		Both transmit and recieve are
//	supported. It is possible to build the core without
//	the transmitter to reduce the size of the core; however
//	then it would not be possible to control the leds on
//	the keyboard. (The transmitter is required for a mouse
//	interface).
//		There is a 5us debounce circuit on the incoming
//	clock.
//		The transmitter does not have a watchdog timer, so
//	it may cause the keyboard to stop responding if there
//	was a problem with the transmit. It relys on the system
//	to reset the transmitter after 30ms or so of no
//	reponse. Resetting the transmitter should allow the
//	keyboard to respond again.
//	Note: keyboard clock must be at least three times slower
//	than the clk_i input to work reliably.
//	A typical keyboard clock is <30kHz so this should be ok
//	for most systems.
//	* There must be pullup resistors on the keyboard clock
//	and data lines, and the keyboard clock and data lines
//	are assumed to be open collector.
//		To read the keyboard, wait for bit 7 of the status
//	register to be set, then read the transmit / recieve
//	register. Reading the transmit / recieve register clears
//	the keyboard reciever, and allows the next character to
//	be recieved.
//
//	Reg
//	0	keyboard transmit/receive register
//	1	status reg.		itk xxxx p
//		i = interrupt status
//		t = transmit complete
//		k = transmit acknowledge receipt (from keyboard)
//		p = parity error
//		A write to the status register clears the transmitter
//		state
//
//
//
//	Webpack 9.1i xc3s1000-4ft256	
//	LUTs / slices / MHz
//	 block rams
//	multiplier
//
// ============================================================================
//	A good source of info:
//	http://panda.stb_i.ndsu.nodak.edu/~achapwes/PICmicro/PS2/ps2.htm
//	http://www.beyondlogic.org/keyboard/keybrd.htm
//
//	From the keyboard
//	1 start bit
//	8 data bits
//	1 parity bit
//	1 stop bit
//
// 	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|WISHBONE Datasheet
//	|WISHBONE SoC Architecture Specification, Revision B.3
//	|
//	|Description:						Specifications:
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|General Description:				PS2 keyboard / mouse interface
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Supported Cycles:					SLAVE,READ/WRITE
//	|									SLAVE,BLOCK READ/WRITE
//	|									SLAVE,RMW
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Data port, size:					8 bit
//	|Data port, granularity:			8 bit
//	|Data port, maximum operand size:	8 bit
//	|Data transfer ordering:			Undefined
//	|Data transfer sequencing:			Undefined
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Clock frequency constraints:		none
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Supported signal list and			Signal Name		WISHBONE equiv.
//	|cross reference to equivalent		ack_o			ACK_O
//	|WISHBONE signals					adr_i			ADR_I()
//	|									clk_i			CLK_I
//	|                                   cyc_i           CYC_I
//	|									dat_i(7:0)		DAT_I()
//	|									dat_o(7:0)		DAT_O()
//	|									stb_i			STB_I
//	|									we_i			WE_I
//	|
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Special requirements:
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//	Note to self:
//	117LUTs / 66 slices / 95MHz
//	57LUTs / 32 slices / 107MHz - no transmitter
//==================================================================

`define KBD_TX		// include transmitter

`define S_KBDRX_WAIT_CLK		0
`define S_KBDRX_CHK_CLK_LOW		1
`define S_KBDRX_CAPTURE_BIT		2

module FF_PS2kbd(
	// WISHBONE/SoC bus interface 
	input rst_i,
	input clk_i,	// system clock
	input cyc_i,
	input stb_i,	// core select (active high)
	output ack_o,	// bus transfer acknowledged
	input we_i,	// I/O write taking place (active high)
	input [43:0] adr_i,	// address
	input [15:0] dat_i,	// data in
	output reg [15:0] dat_o,	// data out
	output vol_o,	// volatile register selected
	//-------------
	output irq,	// interrupt request (active high)
	inout tri kclk,	// keyboard clock from keyboard
	inout tri kd	// keyboard data
);
parameter pClkFreq = 28636360;
parameter p5us = pClkFreq / 200000;		// number of clocks for 5us
parameter p100us = pClkFreq / 10000;	// number of clocks for 100us

reg [11:0] os;	// one shot
wire os_5us_done = os==p5us;
wire os_100us_done = os==p100us;
reg [10:0] q;	// receive register
reg tc;			// transmit complete indicator
reg [1:0] s_rx;	// keyboard receive state
reg [1:0] kq;
reg [1:0] kqc;
wire kqcne;			// negative edge on kqc
wire kqcpe;			// positive edge on kqc
assign irq = ~q[0];
reg kack;			// keyboard acknowledge bit
`ifdef KBD_TX
reg [16:0] tx_state;	// transmitter states
reg klow;		// force clock line low
reg [10:0] t;	// transmit register
wire rx_inh = ~tc;	// inhibit receive while transmit occuring
reg [3:0] bitcnt;
wire shift_done = bitcnt==0;
reg tx_oe;			// transmitter output enable / shift enable
`else
wire rx_inh = 0;
`endif

wire cs = cyc_i && stb_i && (adr_i[43:8]==36'hFFF_FFDC_00);
assign vol_o = cs;
assign ack_o = cs;

// register read path
always @(adr_i or q or tc or kack or cs) begin
	if (cs)
	case(adr_i[1:0])
	2'd0:	dat_o <= q[8:1];
	2'd2:	dat_o <= {~q[0],tc,~kack,4'b0,~^q[9:1]};
	default:	dat_o <= 16'd0;
	endcase
	else
		dat_o <= 16'h0000;
end

// Prohibit keyboard device from further transmits until
// this character has been processed.
// Holding the clock line low does this.
assign kclk = irq ? 1'b0 : 1'bz;
`ifdef KBD_TX
// Force clock and data low during transmits
assign kclk = klow ? 1'b0 : 1'bz;
assign kd = tx_oe & ~t[0] ? 1'b0 : 1'bz;
`endif

// stabilize clock and data
always @(posedge clk_i) begin
	kq <= {kq[0],kd};
	kqc <= {kqc[0],kclk};
end

edge_det ed0 (.rst(rst_i), .clk(clk_i), .ce(1'b1), .i(kqc[1]), .pe(kqcpe), .ne(kqcne) );


// The debounce one-shot and 100us timer	
always @(posedge clk_i)
	if (rst_i)
		os <= 0;
	else begin
		if ((s_rx==`S_KBDRX_WAIT_CLK && kqcne && ~rx_inh)||
			(s_rx==`S_KBDRX_CHK_CLK_LOW && rx_inh)
`ifdef KBD_TX
			||tx_state[0]||tx_state[2]||tx_state[5]||tx_state[7]||tx_state[9]||tx_state[11]||tx_state[14]
`endif
			)
			os <= 0;
		else
			os <= os + 1;
	end


// Receive state machine
always @(posedge clk_i) begin
	if (rst_i) begin
		q <= 11'h7FF;
		s_rx <= `S_KBDRX_WAIT_CLK;
	end
	else begin

		// clear rx on read
		if (ack_o & ~we_i & ~adr_i[0])
			q <= 11'h7FF;

		// Receive state machine
		case (s_rx)	// synopsys full_case parallel_case
		// negedge on kclk ?
		// then set debounce one-shot
		`S_KBDRX_WAIT_CLK:
			if (kqcne && ~rx_inh)
				s_rx <= `S_KBDRX_CHK_CLK_LOW;

		// wait 5us
		// check if clock low
		`S_KBDRX_CHK_CLK_LOW:
			if (rx_inh)
				s_rx <= `S_KBDRX_WAIT_CLK;
			else if (os_5us_done) begin
				// clock low ?
				if (~kqc[1])
					s_rx <= `S_KBDRX_CAPTURE_BIT;
				else
					s_rx <= `S_KBDRX_WAIT_CLK;	// no - spurious
			end

		// capture keyboard bit
		// keyboard transmits LSB first
		`S_KBDRX_CAPTURE_BIT:
			begin
			q <= {kq,q[10:1]};
			s_rx <= `S_KBDRX_WAIT_CLK;
			end

		default:
			s_rx <= `S_KBDRX_WAIT_CLK;
		endcase
	end
end


`ifdef KBD_TX

// Transmit state machine
// a shift register / ring counter is used
reg adv_tx_state;			// advance transmitter state
reg start_tx;				// start the transmitter
reg clear_tx;				// clear the transmit state
always @(posedge clk_i)
	if (rst_i)
		tx_state <= 0;
	else begin
		if (clear_tx)
			tx_state <= 0;
		else if (start_tx)
			tx_state[0] <= 1;
		else if (adv_tx_state) begin
			tx_state[6:0] <= {tx_state[5:0],1'b0};
			tx_state[7] <= (tx_state[8] && !shift_done) || tx_state[6];
			tx_state[8] <= tx_state[7];
			tx_state[9] <= tx_state[8] && shift_done;
			tx_state[16:10] <= tx_state[15:9];
		end
	end


// detect when to advance the transmit state
always @(tx_state or kqcne or kqcpe or kqc or os_100us_done or os_5us_done)
	case (1'b1)		// synopsys parallel_case
	tx_state[0]:	adv_tx_state <= 1;
	tx_state[1]:	adv_tx_state <= os_100us_done;
	tx_state[2]:	adv_tx_state <= 1;
	tx_state[3]:	adv_tx_state <= os_5us_done;
	tx_state[4]:	adv_tx_state <= 1;
	tx_state[5]:	adv_tx_state <= kqcne;
	tx_state[6]:	adv_tx_state <= os_5us_done;
	tx_state[7]:	adv_tx_state <= kqcpe;
	tx_state[8]:	adv_tx_state <= os_5us_done;
	tx_state[9]:	adv_tx_state <= kqcpe;
	tx_state[10]:	adv_tx_state <= os_5us_done;
	tx_state[11]:	adv_tx_state <= kqcne;
	tx_state[12]:	adv_tx_state <= os_5us_done;
	tx_state[13]:	adv_tx_state <= 1;
	tx_state[14]:	adv_tx_state <= kqcpe;
	tx_state[15]:	adv_tx_state <= os_5us_done;
	default:		adv_tx_state <= 0;
	endcase

wire load_tx = ack_o & we_i & ~adr_i[1];
wire shift_tx = (tx_state[7] & kqcpe)|tx_state[4];

// It can take up to 20ms for the keyboard to accept data
// from the host.
always @(posedge clk_i) begin
	if (rst_i) begin
		klow <= 0;
		tc <= 1;
		start_tx <= 0;
		tx_oe <= 0;
	end
	else begin

		clear_tx <= 0;
		start_tx <= 0;

		// write to keyboard register triggers whole thing
		if (load_tx) begin
			start_tx <= 1;
			tc <= 0;
		end
		// write to status register clears transmit state
		else if (ack_o & we_i & adr_i[1]) begin
			tc <= 1;
			tx_oe <= 0;
			klow <= 1'b0;
			clear_tx <= 1;
		end
		else begin

			case (1'b1)	// synopsys parallel_case

			tx_state[0]:	klow <= 1'b1;	// First step: pull the clock low
			tx_state[1]:	;				// wait 100 us (hold clock low)
			tx_state[2]:	tx_oe <= 1;		// bring data low / enable shift
			tx_state[3]:	;	// wait 5us
			// at this point the clock should go high
			// and shift out the start bit
			tx_state[4]:	klow <= 0;		// release clock line
			tx_state[5]:	;				// wait for clock to go low
			tx_state[6]:	;				// wait 5us
			// state7, 8 shift the data out
			tx_state[7]:	;				// wait for clock to go high
			tx_state[8]:	;				// wait 5us, go back to state 7
			tx_state[9]:	tx_oe <= 0;		// wait for clock to go high // disable transmit output / shift
			tx_state[10]:	;				// wait 5us
			tx_state[11]:	;				// wait for clock to go low
			tx_state[12]:	;				// wait 5us
			tx_state[13]:	kack <= kq[1];	// capture the ack_o bit from the keyboard
			tx_state[14]:	;				// wait for clock to go high
			tx_state[15]:	;				// wait 5us
			tx_state[16]:
				begin
					tc <= 1;		// transmit is now complete
					clear_tx <= 1;
				end

			default:	;

			endcase
		end
	end
end


// transmitter shift register
always @(posedge clk_i)
	if (rst_i)
		t <= 11'd0;
	else begin
		if (load_tx)
			t <= {~(^dat_i),dat_i,2'b0};
		else if (shift_tx)
			t <= {1'b1,t[10:1]};
	end


// transmitter bit counter
always @(posedge clk_i)
	if (rst_i)
		bitcnt <= 4'd0;
	else begin
		if (load_tx)
			bitcnt <= 4'd11;
		else if (shift_tx)
			bitcnt <= bitcnt - 4'd1;
	end

`endif

endmodule
