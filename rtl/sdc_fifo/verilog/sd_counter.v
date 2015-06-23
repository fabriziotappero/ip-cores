// module name
//`define CNT_MODULE_NAME sd_counter

// counter type = [BINARY, GRAY, LFSR]
//`define CNT_TYPE_BINARY
`define CNT_TYPE_GRAY
//`define CNT_TYPE_LFSR

// q as output
`define CNT_Q
// for gray type counter optional binary output
`define CNT_Q_BIN

// number of CNT bins
`define CNT_LENGTH 9

// clear
//`define CNT_CLEAR

// set
//`define CNT_SET
`define CNT_SET_VALUE `CNT_LENGTH'h9

// wrap around creates shorter cycle than maximum length
//`define CNT_WRAP
`define CNT_WRAP_VALUE `CNT_LENGTH'h9

// clock enable
`define CNT_CE

// q_next as an output
//`define CNT_QNEXT

// q=0 as an output
//`define CNT_Z

// q_next=0 as a registered output
//`define CNT_ZQ


`define LFSR_LENGTH `CNT_LENGTH

module sd_counter
  (
`ifdef CNT_TYPE_GRAY
    output reg [`CNT_LENGTH:1] q,
`ifdef CNT_Q_BIN
    output [`CNT_LENGTH:1]    q_bin,
`endif
`else
`ifdef CNT_Q
    output [`CNT_LENGTH:1]    q,
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
    output [`CNT_LENGTH:1] q_next,
`endif
`ifdef CNT_Z
    output z,
`endif
`ifdef CNT_ZQ
    output reg zq,
`endif
    input clk,
    input rst
   );
   
`ifdef CNT_SET
   parameter set_value = `CNT_SET_VALUE;
`endif
`ifdef CNT_WRAP
   parameter wrap_value = `CNT_WRAP_VALUE;
`endif

   // internal q reg
   reg [`CNT_LENGTH:1] qi;
   
`ifdef CNT_QNEXT
`else
   wire [`CNT_LENGTH:1] q_next;   
`endif
`ifdef CNT_REW
   wire [`CNT_LENGTH:1] q_next_fw;   
   wire [`CNT_LENGTH:1] q_next_rew;   
`endif

`ifdef CNT_REW
`else
   assign q_next =
`endif
`ifdef CNT_REW
     assign q_next_fw =
`endif
`ifdef CNT_CLEAR
       clear ? `CNT_LENGTH'd0 :
`endif
`ifdef CNT_SET
	 set ? set_value :
`endif
`ifdef CNT_WRAP
	   (qi == wrap_value) ? `CNT_LENGTH'd0 :
`endif
`ifdef CNT_TYPE_LFSR
	     {qi[8:1],~(q[`LFSR_LENGTH]^q[1])};
`else
   qi + `CNT_LENGTH'd1;
`endif
   
`ifdef CNT_REW
   assign q_next_rew =
`ifdef CNT_CLEAR
     clear ? `CNT_LENGTH'd0 :
`endif
`ifdef CNT_SET
       set ? set_value :
`endif
`ifdef CNT_WRAP
	 (qi == `CNT_LENGTH'd0) ? wrap_value :
`endif
`ifdef CNT_TYPE_LFSR
	   {~(q[1]^q[2]),qi[`CNT_LENGTH:2]};
`else
   qi - `CNT_LENGTH'd1;
`endif
`endif
   
`ifdef CNT_REW
   assign q_next = rew ? q_next_rew : q_next_fw;
`endif
   
   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= `CNT_LENGTH'd0;
     else
`ifdef CNT_CE
   if (cke)
`endif
     qi <= q_next;

`ifdef CNT_Q
`ifdef CNT_TYPE_GRAY
   always @ (posedge clk or posedge rst)
     if (rst)
       q <= `CNT_LENGTH'd0;
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
   assign z = (q == `CNT_LENGTH'd0);
`endif

`ifdef CNT_ZQ
   always @ (posedge clk or posedge rst)
     if (rst)
       zq <= 1'b1;
     else
`ifdef CNT_CE
       if (cke)
`endif
	 zq <= q_next == `CNT_LENGTH'd0;
`endif
endmodule
