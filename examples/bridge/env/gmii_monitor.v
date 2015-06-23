module gmii_monitor
  (/*AUTOARG*/
  // Inputs
  clk, gmii_tx_en, gmii_txd
  );
  
  input             clk;
  input             gmii_tx_en;
  input [7:0]       gmii_txd;

  parameter 	     depth = 2048;
  
  reg [7:0] 	     rxbuf [0:depth-1];
  integer 	     rxptr;
  event 	     pkt_rcvd;
  integer            state,rxpkt_num;
  integer            err_cnt;
  integer            i;
  
  parameter          st_idle = 4, st_norm = 0, st_pre = 1;
  
  initial
    begin
      rxptr = 0;
      state = st_idle;
      rxpkt_num = 0;
      err_cnt = 0;
    end
      
  always @(posedge clk)
    begin
      case (state)
        st_idle :
          begin
            if (gmii_tx_en)
              begin
                if (gmii_txd == `GMII_SFD)
                  state = st_norm;
                else
                  state = st_pre;
              end
          end

        st_pre :
          begin
            if (gmii_txd == `GMII_SFD)
              state = st_norm;
            else if (!gmii_tx_en)
              begin
                $display ("%t: ERROR %m: Detected packet with no SFD", $time);
                state = st_idle;
              end
          end
        
        st_norm :
          begin
            if (gmii_tx_en)
	      begin
	        rxbuf[rxptr  ] <= #1 gmii_txd;
                rxptr = rxptr + 1;
              end
            else
              begin
                ->pkt_rcvd;
                state = st_idle;
              end
          end // case: st_norm
      endcase
    end // always @ (posedge clk)

  always @(pkt_rcvd)
    begin
      #2;
      rxpkt_num = rxpkt_num + 1;
      //pid = {rxbuf[rxptr-2], rxbuf[rxptr-1]};
      
      $display ("%t: INFO    : %m: Received packet %0d length %0d", $time,rxpkt_num,rxptr);

      for (i=0; i<rxptr; i=i+1)
	begin
	  if (i % 16 == 0) $write ("%x: ", i[15:0]);
	  $write ("%x ", rxbuf[i]);
	  if (i % 16 == 7) $write ("| ");
	  if (i % 16 == 15) $write ("\n");
	end
      if (i % 16 != 0) $write ("\n");
      rxptr = 0;
    end
  
endmodule // it_monitor
