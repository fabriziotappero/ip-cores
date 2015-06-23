module ring_arb
  (
   input        clk,
   input        reset,

   input [`NUM_PORTS-1:0] rarb_req,
   output reg [`NUM_PORTS-1:0] rarb_ack
   );
  integer                      i;
  reg [`NUM_PORTS-1:0]         nxt_rarb_ack;
  //reg [$clog2(`NUM_PORTS)-1:0] nxt_ack;

  function [`NUM_PORTS-1:0] nxt_grant;
    input [`NUM_PORTS-1:0] cur_grant;
    input [`NUM_PORTS-1:0] cur_req;
    reg [`NUM_PORTS-1:0]   msk_req;
    reg [`NUM_PORTS-1:0]   tmp_grant;
    begin
      msk_req = cur_req & ~((cur_grant - 1) | cur_grant);
      tmp_grant = msk_req & (~msk_req + 1);

      if (msk_req != 0)
        nxt_grant = tmp_grant;
      else
        nxt_grant = cur_req & (~cur_req + 1);
    end
  endfunction // if

  //assign nxt_rarb_ack = nxt_grant (rarb_ack, rarb_req);

  always @*
    begin
      nxt_rarb_ack = rarb_ack;

      if (rarb_req == 0)
        nxt_rarb_ack = 0;
      else if ((rarb_req & rarb_ack) == 0)
        begin
          nxt_rarb_ack = nxt_grant (rarb_ack, rarb_req);
/* -----\/----- EXCLUDED -----\/-----
          nxt_ack = 0;
          for (i=`NUM_PORTS; i>0; i=i-1)
            if (rarb_req[i-1])
              nxt_ack = i-1;
          nxt_rarb_ack = 1 << nxt_ack;
 -----/\----- EXCLUDED -----/\----- */
        end
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
        rarb_ack <= #1 0;
      else if ((rarb_req & rarb_ack) == 0)
        rarb_ack <= #1 nxt_rarb_ack;
    end
       

endmodule // ring_arb
