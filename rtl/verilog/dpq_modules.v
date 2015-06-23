
/*****************************************************************************/
// Id ..........dpq_modules.v                                                 //
// Author.......Ran Minerbi                                                   //
//                                                                            //
//   Unit Description   :                                                     //
//     dpq module make sure that any frame reside                             //
//  in the iba will be sent to Xbar as soon as                                //
//  it is ready to be sent.                                                   //
//  Iba notify dpq when frame transmission is done.                           //
//                                                                            //
/*****************************************************************************/
module Qp(reset,clk,transmit_done , Din,start_adr,T_q,adr_valid);

   input  reset,clk,transmit_done;
   input  [31:0] Din;
   output [15:0] start_adr;
   output [7:0]  T_q;
   output adr_valid;

   reg adr_valid ;
   reg [31:0] prev_input;
   reg div_2_clk, div_4_clk;
   reg write_fifo , read_fifo , TxFifoClear ;
   reg  update_prev_input;
   reg [1:0] state;
   wire            TxBufferFull;
   wire            TxBufferAlmostFull;
   wire            TxBufferAlmostEmpty;
   wire            TxBufferEmpty;
   wire [31:0] queue_out;
   wire [4:0] txfifo_cnt;

   assign start_adr = queue_out[23:8];
   assign T_q = queue_out[7:0];

       eth_fifo #(
           .DATA_WIDTH(32),
           .DEPTH(32),
           .CNT_WIDTH(5))
 qp_fifo (
         .clk            (clk),
         .reset          (reset),
         // Inputs
         .data_in        (Din),
         .write          (write_fifo),
         .read           (read_fifo),
         .clear          (TxFifoClear),
         // Outputs
         .data_out       (queue_out),
         .full           (TxBufferFull),
         .almost_full    (TxBufferAlmostFull),
         .almost_empty   (TxBufferAlmostEmpty),
         .empty          (TxBufferEmpty),
         .cnt            (txfifo_cnt)
        );

    initial begin
       div_2_clk=0;
       div_4_clk=0;
       read_fifo =0;
       adr_valid=0;
       prev_input =0;
        write_fifo=0;
        update_prev_input = 0;
        state = 0;
    end

 always @ (posedge clk or posedge reset )
   begin
       if (reset)
           begin
         //    Dout <= 0;
            end
           else
            begin
               div_2_clk  <= div_2_clk^clk;

               if (|(Din & 32'h0000000f))       // T_Q defined in FDB
               begin
                  prev_input <= Din;
                  update_prev_input =1;
                  write_fifo <= |(prev_input^Din);
               end

                 /*   if (read_fifo==1)
                   begin
                     read_fifo=0;
                     adr_valid=1;
                    end     */
            end
   end

   always @ (posedge div_2_clk or posedge reset )
   begin
       if (reset)
           begin
          //   Dout <= 0;
            end
           else
            begin
               div_4_clk <= div_4_clk^div_2_clk;

            end
   end

 /*   always @ (posedge clk)
    begin
       if (read_fifo==1)
           begin
            read_fifo=0;
           end
     else  if (txfifo_cnt > 1 && transmit_done==1)   //  txfifo_cnt > 1 cause when read from queue its size is at least 1
           begin
               read_fifo=1;      // only for single cycle need - set back to 0 in line ...never - bug
               adr_valid=0;
           end
           else  if (txfifo_cnt > 0)
                   begin
                     adr_valid=1;
                     //read_fifo=0;

                    end

      end
     always @ (negedge transmit_done)
      begin
         read_fifo=0;
        // adr_valid=0;   //this what shitting
      end   */

   /*
     state :
     0: Empty
     1: Valid
     2: Invalid_Queue_not_Empty
     3:Invalid_queue_empty

   */

    always @(posedge clk)
     begin

       case (state)   // state [2]

        2'h0 :            //Empty
            begin
              adr_valid=0;
              TxFifoClear = 0;
              if (txfifo_cnt > 0)
                  begin
                    state = 1;
                  end
            end
       2'h1:              //Valid
            begin
             adr_valid=1;
             read_fifo = 0;
             if (transmit_done == 1 && txfifo_cnt > 1)
               begin
                   state = 2;
               end
              if (transmit_done == 1 && txfifo_cnt == 1)
               begin
                 state = 3;
               end
            end

        2'h2:
            begin
              adr_valid = 0;
              read_fifo = 1;
              if (transmit_done == 0)
                  begin
                   state = 1;
                   end
            end
        2'h3:
            begin
              TxFifoClear = 1;
              adr_valid = 0;
              if (txfifo_cnt == 0)
                  begin
                    state = 0;
                   end

            end

       endcase

     end   //always

endmodule



/*

   transmit_done+ txfifo_cnt > 1
                 ||
                \/
              read_fifo  (one_cycle)
                 ||
                \/
               addr_valid
*/
