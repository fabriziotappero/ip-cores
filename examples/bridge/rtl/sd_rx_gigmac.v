// mock-up of RX portion of gigabit ethernet MAC
// performs packet reception and creates internal
// packet codes, as well as checking CRC on incoming
// packets.

// incoming data is synchronous to "clk", which should
// be the GMII RX clock.  Output data is also synchronous
// to this clock, so needs to go through a sync FIFO.

// If output is not ready while receiving data,
// truncates the packet and makes it an error packet.

module sd_rx_gigmac
  (
   input        clk,
   input        reset,
   input        gmii_rx_dv,
   input [7:0]  gmii_rxd,

   output       rxg_srdy,
   input        rxg_drdy,
   output [1:0] rxg_code,
   output [7:0] rxg_data,

   input        cfg_check_crc
   );

  reg 		rxdv1, rxdv2;
  reg [7:0] 	rxd1, rxd2;
  reg [31:0]    pkt_crc;
  reg [3:0] 	valid_bits, nxt_valid_bits;
  reg [31:0]    nxt_pkt_crc;

  reg [6:0] 	state, nxt_state;
  reg 		ic_srdy;
  wire 		ic_drdy;
  reg [1:0] 	ic_code;
  reg [7:0] 	ic_data;
  wire [31:0]   crc;

  reg           crc_valid;
  reg           crc_clear;
  
  mac_crc32 crc_chk
    (
     .clear                             (crc_clear),
     .data                              (rxd2),
     .valid                             (crc_valid),

     /*AUTOINST*/
     // Outputs
     .crc                               (crc[31:0]),
     // Inputs
     .clk                               (clk));

  always @(posedge clk)
    begin
      if (reset)
	begin
	  rxd1  <= #1 0;
	  rxdv1 <= #1 0;
	  rxd2  <= #1 0;
	  rxdv2 <= #1 0;
          pkt_crc <= #1 0;
	end
      else
	begin
	  rxd1  <= #1 gmii_rxd;
	  rxdv1 <= #1 gmii_rx_dv;
	  rxd2  <= #1 rxd1;
	  rxdv2 <= #1 rxdv1;
          pkt_crc <= #1 nxt_pkt_crc;
	end
    end // always @ (posedge clk)

  localparam s_idle = 0, s_preamble = 1, s_sop = 2, s_payload = 3, s_trunc = 4, s_sink = 5, s_eop = 6;
  localparam ns_idle = 1, ns_preamble = 2, ns_sop = 4, ns_payload = 8, ns_trunc = 16, ns_sink = 32;

  always @*
    begin
      ic_srdy = 0;
      ic_code = `PCC_DATA;
      ic_data = 0;
      nxt_valid_bits = valid_bits;
      nxt_pkt_crc = pkt_crc;
      crc_valid = 0;
      crc_clear = 0;

      case (1'b1)
	state[s_idle] :
	  begin
            crc_clear = 1;
	    nxt_pkt_crc  = 0;
	    nxt_valid_bits = 0;
	    if (rxdv2 & (rxd2 == `GMII_SFD))
	      begin
		nxt_state = ns_sop;
	      end
	    else if (rxdv2)
	      begin
		nxt_state = ns_preamble;
	      end
	  end // case: state[s_idle]
	
	state[s_preamble]:
	  begin
	    if (!rxdv2)
	      nxt_state = ns_idle;
	    else if (rxd2 == `GMII_SFD)
	      nxt_state = ns_sop;
	  end

	state[s_sop] :
	  begin
	    if (!rxdv2)
	      begin
		nxt_state = ns_idle;
	      end
	    else if (!ic_drdy)
	      nxt_state = ns_sink;
	    else
	      begin
		ic_srdy = 1;
		ic_code = `PCC_SOP;
		ic_data = rxd2;
                crc_valid = 1;
                nxt_pkt_crc = { rxd2, pkt_crc[31:8] };
		nxt_state = ns_payload;
	      end
	  end // case: state[ns_payload]

	state[s_payload] :
	  begin
	    if (!ic_drdy)
	      nxt_state = ns_trunc;
	    else if (!rxdv1)
	      begin
		//nxt_state = ns_idle;
		ic_srdy = 0;
		ic_data = rxd2;
                crc_valid = 1;
                nxt_pkt_crc = { rxd2, pkt_crc[31:8] };
                nxt_state = 1 << s_eop;
	      end
	    else
	      begin
		ic_srdy = 1;
		ic_code = `PCC_DATA;
		ic_data = rxd2;
                crc_valid = 1;
                nxt_pkt_crc = { rxd2, pkt_crc[31:8] };
	      end // else: !if(!rxdv1)
	  end // case: state[ns_payload]


        state[s_eop] :
          begin
            ic_srdy =1;
            ic_data = pkt_crc[31:24];
            if ((pkt_crc == crc) | !cfg_check_crc)
              begin
                ic_code = `PCC_EOP;
              end
            else
              ic_code = `PCC_BADEOP;

            if (ic_drdy)
              nxt_state = 1 << s_idle;
          end
          
	state[s_trunc] :
	  begin
	    ic_srdy = 1;
	    ic_code = `PCC_BADEOP;
	    ic_data = 0;
	    if (ic_drdy)
	      nxt_state = ns_sink;
	  end

	state[s_sink] :
	  begin
	    if (!rxdv2)
	      nxt_state = ns_idle;
	  end

	default : nxt_state = ns_idle;
      endcase // case (1'b1)	
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
	begin
	  state <= #1 1;
	  /*AUTORESET*/
          // Beginning of autoreset for uninitialized flops
          pkt_crc <= 32'h0;
          valid_bits <= 4'h0;
          // End of automatics
	end
      else
	begin
	  pkt_crc  <= #1 nxt_pkt_crc;
	  state    <= #1 nxt_state;
	  valid_bits <= #1 nxt_valid_bits;
	end // else: !if(reset)
    end // always @ (posedge clk)

  sd_output #(8+2) out_hold
    (.clk (clk), .reset (reset),
     .ic_srdy (ic_srdy),
     .ic_drdy (ic_drdy),
     .ic_data ({ic_code,ic_data}),
     .p_srdy  (rxg_srdy),
     .p_drdy  (rxg_drdy),
     .p_data  ({rxg_code, rxg_data}));

endmodule // sd_rx_gigmac
