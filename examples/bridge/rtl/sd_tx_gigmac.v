// mock-up of RX portion of gigabit ethernet MAC
// performs packet reception and creates internal
// packet codes, as well as checking CRC on incoming
// packets.

// If output is not ready while receiving data,
// truncates the packet and makes it an error packet.

module sd_tx_gigmac
  (
   input        clk,
   input        reset,
   output reg        gmii_tx_en,
   output reg [7:0]  gmii_txd,

   input       txg_srdy,
   output      txg_drdy,
   input [1:0] txg_code,
   input [7:0] txg_data
   );

  wire 	       ip_srdy;
  reg 	       ip_drdy;
  wire [1:0]   ip_code;
  wire [7:0]   ip_data;
  reg [3:0]    count, nxt_count;

  reg [7:0]    nxt_gmii_txd;
  reg 	       nxt_gmii_tx_en;
  reg [5:0]    state, nxt_state;

  wire [31:0]  crc;
  reg          clear;
  reg          crc_valid;
  
  localparam s_idle = 0, s_preamble = 1, s_payload = 2, s_ipg = 3, s_badcrc = 4, s_goodcrc = 5;
  localparam ns_idle = 1, ns_preamble = 2, ns_payload = 4, ns_ipg = 8;

  sd_input #(8+2) in_hold
    (
     // Outputs
     .c_drdy				(txg_drdy),
     .ip_srdy				(ip_srdy),
     .ip_data				({ip_code,ip_data}),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .c_srdy				(txg_srdy),
     .c_data				({txg_code,txg_data}),
     .ip_drdy				(ip_drdy));

  mac_crc32 crcgen
    (
     .data                              (ip_data[7:0]),
     .valid                             (crc_valid),
     /*AUTOINST*/
     // Outputs
     .crc                               (crc[31:0]),
     // Inputs
     .clk                               (clk),
     .clear                             (clear));

  always @*
    begin
      ip_drdy = 0;
      nxt_count = count;
      nxt_gmii_tx_en = 0;
      nxt_gmii_txd = gmii_txd;
      clear = 0;
      crc_valid = 0;

      case (1'b1)
	state[s_idle] :
	  begin
	    if (ip_srdy & (ip_code == `PCC_SOP))
	      begin
		nxt_gmii_tx_en = 1;
		nxt_gmii_txd = `GMII_PRE;
		nxt_count = 1;
		nxt_state = ns_preamble;
                clear = 1;
	      end
	    else
	      begin
		ip_drdy = 1;
	      end // else: !if(ip_srdy & (ip_code == `PCC_SOP))
	  end // case: state[s_idle]

	state[s_preamble] :
	  begin
	    nxt_count = count + 1;
	    nxt_gmii_tx_en = 1;
	    if (count == 6)
              begin
	        nxt_gmii_txd = `GMII_SFD;
	        nxt_state = ns_payload;
              end
	    else
	      nxt_gmii_txd = `GMII_PRE;
	  end // case: state[s_preamble]

	state[s_payload] :
	  begin
	    ip_drdy = 1;
	    nxt_gmii_tx_en = 1;
            nxt_gmii_txd = ip_data;
            crc_valid = 1;
            
	    if (!ip_srdy | ((ip_code == `PCC_EOP) | (ip_code == `PCC_BADEOP)))
	      begin
		nxt_count = 0;
                if (ip_code == `PCC_EOP)
                  nxt_state = 1 << s_goodcrc;
                else
		  nxt_state = 1 << s_badcrc;
	      end
	  end // case: state[s_payload]

        state[s_goodcrc] :
          begin
            nxt_count = count + 1;
            nxt_gmii_tx_en = 1;
            case (count)
              0 : nxt_gmii_txd = crc[7:0];
              1 : nxt_gmii_txd = crc[15:8];
              2 : nxt_gmii_txd = crc[23:16];
              3 : nxt_gmii_txd = crc[31:24];
            endcase // case (count)
            
            if (count == 3)
              begin
                nxt_state = 1 << s_ipg;
              end
          end

        state[s_badcrc] :
          begin
           nxt_count = count + 1;
            nxt_gmii_tx_en = 1;
            nxt_gmii_txd   = 8'h0;
            
            if (count == 3)
              begin
                nxt_state = 1 << s_ipg;
              end
          end

	state[s_ipg] :
	  begin
	    nxt_gmii_tx_en = 0;
	    ip_drdy = 0;
	    nxt_count = count + 1;
	    if (count == 11)
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
          count <= 4'h0;
          gmii_tx_en <= 1'h0;
          gmii_txd <= 8'h0;
          // End of automatics
	end
      else
	begin
	  state <= #1 nxt_state;
	  count <= #1 nxt_count;
	  gmii_tx_en <= #1 nxt_gmii_tx_en;
	  gmii_txd   <= #1 nxt_gmii_txd;
	end // else: !if(reset)
    end // always @ (posedge clk)

endmodule // sd_rx_gigmac
// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/closure" "../../../rtl/verilog/memory" "../../../rtl/verilog/forks")
// End:  
