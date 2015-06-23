`include "versatile_counter_defines.v"
`define LFSR_LENGTH cnt_length
`include "lfsr_polynom.v"
`let CNT_INDEX=CNT_LENGTH-1
`ifndef CNT_MODULE_NAME
`define CNT_MODULE_NAME vcnt
`endif
module `CNT_MODULE_NAME
  (
`ifdef CNT_TYPE_GRAY
    output reg [cnt_length:1] q,
 `ifdef CNT_Q_BIN
    output [cnt_length:1]    q_bin,
 `endif
`else   
 `ifdef CNT_Q
    output [cnt_length:1]    q,
 `endif
`endif
`ifdef CNT_CLEAR
    input clear,
`endif 
`ifdef CNT_SET
    input set,
`endif
`ifdef CNT_REW
    input rew,
`endif
`ifdef CNT_CE
    input cke,
`endif
`ifdef CNT_QNEXT
    output [cnt_length:1] q_next,
`endif
`ifdef CNT_Z
    output z,
`endif
`ifdef CNT_ZQ
    output reg zq,
`endif
`ifdef CNT_LEVEL1
    output reg level1,
`endif
`ifdef CNT_LEVEL2
    output reg level2,
`endif
    input clk,
    input rst
   );
   
   parameter cnt_length = `CNT_LENGTH;
   parameter cnt_reset_value = `CNT_RESET_VALUE;
`ifdef CNT_SET
   parameter set_value = cnt_length'd`CNT_SET_VALUE;
`endif
`ifdef CNT_WRAP
   parameter wrap_value = cnt_length'd`CNT_WRAP_VALUE;
`endif
`ifdef CNT_LEVEL1
    parameter level1_value = cnt_length'd`CNT_LEVEL1_VALUE;
`endif
`ifdef CNT_LEVEL2
    parameter level2_value = cnt_length'd`CNT_LEVEL2_VALUE;
`endif

   // internal q reg
   reg [cnt_length:1] qi;
   
`ifndef CNT_QNEXT
   wire [cnt_length:1] q_next;   
`endif
`ifdef CNT_REW
   wire [cnt_length:1] q_next_fw;   
   wire [cnt_length:1] q_next_rew;   
`endif

`ifndef CNT_REW   
   assign q_next =
`else
     assign q_next_fw =
`endif	       
`ifdef CNT_CLEAR
       clear ? cnt_length'd0 :
`endif
`ifdef CNT_SET		  
	 set ? set_value :
`endif
`ifdef CNT_WRAP
	   (qi == wrap_value) ? cnt_length'd0 :
`endif
`ifdef CNT_TYPE_LFSR
	     {qi[`CNT_INDEX:1],~(`LFSR_FB)};
`else
   qi + cnt_length'd1;
`endif
   
`ifdef CNT_REW
   assign q_next_rew =
 `ifdef CNT_CLEAR
     clear ? cnt_length'd0 :
 `endif
 `ifdef CNT_SET		  
       set ? set_value :
 `endif
 `ifdef CNT_WRAP
	 (qi == cnt_length'd0) ? wrap_value :
 `endif
 `ifdef CNT_TYPE_LFSR
	   {~(`LFSR_FB_REW),qi[cnt_length:2]};
 `else
   qi - cnt_length'd1;
 `endif
`endif   
   
`ifdef CNT_REW
   assign q_next = rew ? q_next_rew : q_next_fw;
`endif
   
   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= cnt_length'd0;
     else
`ifdef CNT_CE
   if (cke)
`endif
     qi <= q_next;

`ifdef CNT_Q
 `ifdef CNT_TYPE_GRAY
   always @ (posedge clk or posedge rst)
     if (rst)
       q <= `CNT_RESET_VALUE;
     else
  `ifdef CNT_CE
       if (cke)
  `endif
	 q <= (q_next>>1) ^ q_next;
  `ifdef CNT_Q_BIN
   assign q_bin = qi;
  `endif
 `else
   assign q = q_next;
 `endif
`endif
   
`ifdef CNT_Z
   assign z = (q == cnt_length'd0);
`endif

`ifdef CNT_ZQ
   always @ (posedge clk or posedge rst)
     if (rst)
       zq <= 1'b1;
     else
 `ifdef CNT_CE
       if (cke)
 `endif
	 zq <= q_next == cnt_length'd0;
`endif

`ifdef CNT_LEVEL1
    always @ (posedge clk or posedge rst)
        if (rst)
            level1 <= 1'b0;
        else
 `ifdef CNT_CE
        if (cke)
 `endif
            if (q_next == level1_value)
                level1 <= 1'b1;
            else if (q == level1_value & rew)
                level1 <= 1'b0;
`endif

`ifdef CNT_LEVEL2
    always @ (posedge clk or posedge rst)
        if (rst)
            level2 <= 1'b0;
        else
 `ifdef CNT_CE
        if (cke)
 `endif
            if (q_next == level2_value)
                level2 <= 1'b1;
            else if (q == level2_value & rew)
                level2 <= 1'b0;
`endif

endmodule
