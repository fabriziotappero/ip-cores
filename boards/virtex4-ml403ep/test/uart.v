module uart_ctrl(wr, trx_req, trx_ack, trx,
                 clr, clk);
  // Entrades
  input [6:0] wr;
  input trx_req;
  input clr, clk;

  // Sortides
  output reg trx_ack, trx;

  // Registres
  reg [7:0] et, etrx;
  reg [6:0] data_wr;

  // Algorisme de transmissi�
  always @(negedge clk)
    if (clr)
      begin
        et <= 8'd00;
        etrx <= 8'd00;
        trx <= 1'b1;
        trx_ack <= 1'b0;
      end
    else
      case (et)
        8'd00: if (trx_req) et <= 8'd05;
        8'd05: 
          if (~trx_req)
            begin et <= 8'd00; etrx <= 8'd00; end
          else
          case (etrx)
            8'd00: begin data_wr <= wr; trx <= 1'b1; etrx <= 8'd05; end
            8'd05: begin trx <= 1'b0; etrx <= 8'd10; end // Start bit
            8'd10: begin trx <= data_wr[0]; etrx <= 8'd15; end
            8'd15: begin trx <= data_wr[1]; etrx <= 8'd20; end
            8'd20: begin trx <= data_wr[2]; etrx <= 8'd25; end
            8'd25: begin trx <= data_wr[3]; etrx <= 8'd30; end
            8'd30: begin trx <= data_wr[4]; etrx <= 8'd35; end
            8'd35: begin trx <= data_wr[5]; etrx <= 8'd40; end
            8'd40: begin trx <= data_wr[6]; etrx <= 8'd45; end
            8'd45: begin trx <= 1'b0; etrx <= 8'd50; end
            8'd50: begin trx_ack <= 1'b1; trx <= 1'b1; etrx <= 8'd00; et <= 8'd10; end
          endcase
        8'd10: if (~trx_req) begin trx_ack <= 1'b0; et <= 8'd00; end
      endcase

endmodule