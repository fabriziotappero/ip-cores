//-------------------------------------------------------------------------
//
// File name    :  ldpc_vncluster.v
// Title        :
//              :
// Purpose      : A group of VN's and the associated RAM.  Clustering
//              : VN's around a RAM should reduce area in the ASIC
//              : implementation by using fewer, larger RAM's.  It should
//              : also ease placement by allowing placement of a number
//              : 
//
// ----------------------------------------------------------------------
// Revision History :
// ----------------------------------------------------------------------
//   Ver  :| Author   :| Mod. Date   :| Changes Made:
//   v1.0  | JTC      :| 2008/09/15  :|
// ----------------------------------------------------------------------
`timescale 1ns/10ps

module ldpc_vncluster #(
  parameter NUMVNS         = 3,
  parameter ENABLE_DISABLE = 1,
  parameter FOLDFACTOR     = 1,
  parameter LASTSHIFTWIDTH = 4,
  parameter LLRWIDTH       = 6
)(
  input clk,
  input rst,

  // LLR I/O
  input                       llr_access,
  input[7+FOLDFACTOR-1:0]     llr_addr,
  input                       llr_din_we,
  input[NUMVNS*LLRWIDTH-1:0]  llr_din,
  output[NUMVNS*LLRWIDTH-1:0] llr_dout,

  // message control
  input                   iteration,
  input                   first_half,
  input                   first_iteration,  // ignore upmsgs
  input                   we_vnmsg,
  input                   disable_vn,
  input[7+FOLDFACTOR-1:0] addr_vn,

  // message I/O
  input  wire[NUMVNS*LLRWIDTH-1:0] sh_cluster_msg,
  output wire[NUMVNS*LLRWIDTH-1:0] vn_cluster_msg
);

wire   zero;
assign zero = 0;

////////////////////////
// 2-d/1-d conversion //
////////////////////////
wire[LLRWIDTH-1:0] vn_msg[0:NUMVNS-1];
wire[LLRWIDTH-1:0] sh_msg[0:NUMVNS-1];
wire[LLRWIDTH-1:0] llr_din_2d[0:NUMVNS-1];
wire[LLRWIDTH-1:0] llr_dout_2d[0:NUMVNS-1];

generate
  genvar j;

  for( j=0; j<NUMVNS; j=j+1 )
  begin: convert1d2d
    assign vn_cluster_msg[LLRWIDTH*j+LLRWIDTH-1 -: LLRWIDTH] = vn_msg[j];
    assign sh_msg[j] = sh_cluster_msg[LLRWIDTH*j+LLRWIDTH-1 -: LLRWIDTH];
    
    assign llr_din_2d[j] = llr_din[LLRWIDTH*j+LLRWIDTH-1 -: LLRWIDTH];
    assign llr_dout[LLRWIDTH*j+LLRWIDTH-1 -: LLRWIDTH] = llr_dout_2d[j];
  end
endgenerate

//////////
// VN's //
//////////
wire                   llrram_we;
wire[7+FOLDFACTOR-1:0] vnram_wraddr;
wire[7+FOLDFACTOR-1:0] vnram_rdaddr;
wire[LLRWIDTH-1:0]     llrram_din[0:NUMVNS-1];
wire[LLRWIDTH-1:0]     llrram_dout[0:NUMVNS-1];

wire                 upmsg_we;
wire[2*LLRWIDTH+4:0] upmsg_din[0:NUMVNS-1];
wire[2*LLRWIDTH+4:0] upmsg_dout[0:NUMVNS-1];

wire upmsg_we_last;

generate
  genvar i;

  for( i=0; i<NUMVNS; i=i+1 )
  begin: varnodes
    // first
    if( i==0 )
    begin
      ldpc_vn #( .FOLDFACTOR(FOLDFACTOR),
                 .LLRWIDTH  (LLRWIDTH)
      ) ldpc_vn0i (
        .clk              (clk),
        .rst              (rst),
        .llr_access       (llr_access),
        .llr_addr         (llr_addr),
        .llr_din_we       (llr_din_we),
        .llr_din          (llr_din_2d[i]),
        .llr_dout         (llr_dout_2d[i]),
        .iteration        (iteration),
        .first_half       (first_half),
        .first_iteration  (first_iteration),
        .we_vnmsg         (we_vnmsg),
        .disable_vn(zero),
        .addr_vn          (addr_vn),
        .sh_msg           (sh_msg[i]),
        .vn_msg           (vn_msg[i]),
        .vnram_wraddr     (vnram_wraddr),
        .vnram_rdaddr     (vnram_rdaddr),
        .upmsg_we         (upmsg_we),
        .upmsg_din        (upmsg_din[i]),
        .upmsg_dout       (upmsg_dout[i])
      );
    end

    // last
    if( i==NUMVNS-1 )
    begin
      ldpc_vn #( .FOLDFACTOR(FOLDFACTOR),
                 .LLRWIDTH  (LLRWIDTH)
      ) ldpc_vnlasti (
        .clk              (clk),
        .rst              (rst),
        .llr_access       (llr_access),
        .llr_addr         (llr_addr),
        .llr_din_we       (llr_din_we),
        .llr_din          (llr_din_2d[i]),
        .llr_dout         (llr_dout_2d[i]),
        .iteration        (iteration),
        .first_half       (first_half),
        .first_iteration  (first_iteration),
        .we_vnmsg         (we_vnmsg),
        .disable_vn(disable_vn),
        .addr_vn          (addr_vn),
        .sh_msg           (sh_msg[i]),
        .vn_msg           (vn_msg[i]),
        .vnram_wraddr     (),
        .vnram_rdaddr     (),
        .upmsg_we         (upmsg_we_last),
        .upmsg_din        (upmsg_din[i]),
        .upmsg_dout       (upmsg_dout[i])
      );
    end

    if( (i!=0) && (i!=NUMVNS-1) )
    begin
      ldpc_vn #( .FOLDFACTOR(FOLDFACTOR),
                 .LLRWIDTH  (LLRWIDTH)
      ) ldpc_vni (
        .clk              (clk),
        .rst              (rst),
        .llr_access       (llr_access),
        .llr_addr         (llr_addr),
        .llr_din_we       (llr_din_we),
        .llr_din          (llr_din_2d[i]),
        .llr_dout         (llr_dout_2d[i]),
        .iteration        (iteration),
        .first_half       (first_half),
        .first_iteration  (first_iteration),
        .we_vnmsg         (we_vnmsg),
        .disable_vn(zero),
        .addr_vn          (addr_vn),
        .sh_msg           (sh_msg[i]),
        .vn_msg           (vn_msg[i]),
        .vnram_wraddr     (),
        .vnram_rdaddr     (),
        .upmsg_we         (),
        .upmsg_din        (upmsg_din[i]),
        .upmsg_dout       (upmsg_dout[i])
      );
    end
  end
endgenerate

// Combine RAM I/O's
wire[NUMVNS*(2*LLRWIDTH+5)-1:0] combined_din;
wire[NUMVNS*(2*LLRWIDTH+5)-1:0] combined_dout;

generate
  genvar k;

  for( k=0; k<NUMVNS; k=k+1 )
  begin: combine_all
    assign combined_din[k*(2*LLRWIDTH+5)+2*LLRWIDTH+4 -: 2*LLRWIDTH+5] = upmsg_din[k];
    assign upmsg_dout[k] = combined_dout[k*(2*LLRWIDTH+5)+2*LLRWIDTH+4 -: 2*LLRWIDTH+5];
  end
endgenerate

generate
  if( ENABLE_DISABLE )
  begin: split_rams
    ldpc_ram_behav #(
      .WIDTH    ((NUMVNS-1)*(2*LLRWIDTH+5)),
      .LOG2DEPTH(7+FOLDFACTOR)
    ) ldpc_vn_ram0i (
      .clk(clk),
      .we(upmsg_we),
      .din(combined_din[(NUMVNS-1)*(2*LLRWIDTH+5)-1 : 0]),
      .wraddr(vnram_wraddr),
      .rdaddr(vnram_rdaddr),
      .dout(combined_dout[(NUMVNS-1)*(2*LLRWIDTH+5)-1 : 0])
    );

    ldpc_ram_behav #(
      .WIDTH    (2*LLRWIDTH+5),
      .LOG2DEPTH(7+FOLDFACTOR)
    ) ldpc_vn_ramlasti (
      .clk(clk),
      .we(upmsg_we_last),
      .din(combined_din[NUMVNS*(2*LLRWIDTH+5)-1 -: 2*LLRWIDTH+5]),
      .wraddr(vnram_wraddr),
      .rdaddr(vnram_rdaddr),
      .dout(combined_dout[NUMVNS*(2*LLRWIDTH+5)-1 -: 2*LLRWIDTH+5])
    );
  end
  else
  begin: united_ram
    ldpc_ram_behav #(
      .WIDTH    (NUMVNS*(2*LLRWIDTH+5)),
      .LOG2DEPTH(7+FOLDFACTOR)
    ) ldpc_vn_rami (
      .clk   (clk),
      .we    (upmsg_we),
      .din   (combined_din),
      .wraddr(vnram_wraddr),
      .rdaddr(vnram_rdaddr),
      .dout  (combined_dout)
    );
  end
endgenerate

endmodule

