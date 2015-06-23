module clk_gen_logic #(
		     parameter SYNC_RST = 0
		     ) 
                     (
                     input  wire       nrst,
		     input  wire       clk,
		     input wire[11:0]  bsel,
		     input wire[3:0]   bscale,
		     input wire        change_cfg, 
		     input wire        rxen,
		     input wire        txen,
		     input  wire       clr_tx_cnt,
		     output wire       rx_clk_en,
		     output wire       tx_clk_en
                     );
		
reg[11:0]  rx_cnt_current;		
reg[11:0]  rx_cnt_next;		
		
reg       rx_clk_en_current;
wire      rx_clk_en_next;		
wire      rx_cnt_exp;		


reg[11:0]  tx_cnt_current;		
reg[11:0]  tx_cnt_next;		
reg        tx_clk_en_current;
reg        tx_clk_en_next;		
wire       tx_cnt_exp;



		
assign rx_clk_en_next =  rx_cnt_exp & rxen; 
assign rx_cnt_exp = ~(|rx_cnt_current);

assign tx_cnt_exp = ~(|tx_cnt_current);

always@*
 begin
  // Latch avoidance
  rx_cnt_next = rx_cnt_current;
  tx_cnt_next = tx_cnt_current;
  tx_clk_en_next = tx_clk_en_current;
  // Latch avoidance

  // RX
  if(change_cfg | rx_cnt_exp) rx_cnt_next = bsel;
  else if(rxen) rx_cnt_next = rx_cnt_current - 12'b1; // Decrement

  // TX
  if(change_cfg | tx_cnt_exp | clr_tx_cnt) tx_cnt_next = bsel;
  else if(txen) tx_cnt_next = tx_cnt_current - 12'b1; // Decrement

  // TX clock enable FF
  case(tx_clk_en_current)
   1'b0    : if(!(|tx_cnt_next) || !(|bsel) || (change_cfg && !(|bsel))) tx_clk_en_next = 1'b1;
   1'b1    : if(|bsel) tx_clk_en_next = 1'b0;
   default : tx_clk_en_next = 1'b0;
  endcase

 end // always@*

 always @(posedge clk or negedge nrst)
   begin: sh_seq
      if (!nrst)		// Reset 
      begin
       rx_cnt_current       <= {12{1'b0}};
       rx_clk_en_current    <= 1'b0;
       
       tx_cnt_current       <= {12{1'b0}};
       tx_clk_en_current    <= 1'b0;
         
      end
      else 		// Clock 
      begin
       rx_cnt_current    <= rx_cnt_next;
       rx_clk_en_current <= rx_clk_en_next;
       
       tx_cnt_current    <= tx_cnt_next;
       tx_clk_en_current <= tx_clk_en_next;
       
      end
   end // sh_seq


assign rx_clk_en = rx_clk_en_current;
assign tx_clk_en = tx_clk_en_current;
		
endmodule // clk_gen_logic			
		
		
