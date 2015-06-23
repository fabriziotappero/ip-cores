//-------------------------------------------------------------------------
//
// File name    :  ldp_top.v
// Title        :
//              :
// Purpose      : Top-level of LDPC decoder, structural verilog only
//
// ----------------------------------------------------------------------
// Revision History :
// ----------------------------------------------------------------------
//   Ver  :| Author   :| Mod. Date   :| Changes Made:
//   v1.0  | JTC      :| 2008/07/02  :|
// ----------------------------------------------------------------------
`timescale 1ns/10ps

module ldp_top #(
  parameter FOLDFACTOR     = 4,
  parameter LOG2FOLDFACTOR = 2,
  parameter NUMINSTANCES   = 360,
  parameter LLRWIDTH       = 6
)(
  input clk,
  input rst,

  // LLR I/O
  input                             llr_access,
  input[7+FOLDFACTOR-1:0]           llr_addr,
  input                             llr_din_we,
  input[NUMINSTANCES*LLRWIDTH-1:0]  llr_din,
  output[NUMINSTANCES*LLRWIDTH-1:0] llr_dout,

  // start command, completion indicator
  input      start,
  input[4:0] mode,
  input[5:0] iter_limit,
  output     done
);

////////////////
// PARAMETERS //
////////////////
localparam NUMVNS       = 3;
localparam LASTSHIFTDIST = (FOLDFACTOR==1) ? 11 :
                           (FOLDFACTOR==2) ? 5  :
                           (FOLDFACTOR==3) ? 3  :
                           /* 4 */           2;
localparam LASTSHIFTWIDTH  = (FOLDFACTOR==1) ? 4 :
                             (FOLDFACTOR==2) ? 3 :
                             (FOLDFACTOR==3) ? 2 :
                             /* 4 */           2;

//////////////////////
// INTERNAL SIGNALS //
//////////////////////
wire   zero;
assign zero = 0;

// iocontrol common control outputs
wire iteration;
wire first_iteration;
wire disable_vn;
wire disable_cn;

// iocontrol VN controls
wire                   we_vnmsg;
wire[7+FOLDFACTOR-1:0] addr_vn;

// iocontrol shuffler controls
wire                     first_half;
wire[1:0]                shift0;
wire[2:0]                shift1;
wire[LASTSHIFTWIDTH-1:0] shift2;

// iocontrol CN controls
wire                   cn_we;
wire                   cn_rd;
wire[7+FOLDFACTOR-1:0] addr_cn;

// iocontrol ROM
wire[12:0]                   romaddr;
wire[8+5+LASTSHIFTWIDTH-1:0] romdata;

////////////////////
// Control module //
////////////////////
ldpc_iocontrol #(
  .FOLDFACTOR(FOLDFACTOR),
  .LASTSHIFTWIDTH(LASTSHIFTWIDTH),
  .NUMINSTANCES(NUMINSTANCES)
)
ldpc_iocontroli(
  .clk              (clk),
  .rst              (rst),
  
  .start            (start),
  .mode             (mode),
  .iter_limit       (iter_limit),
  .done             (done),
  
  .iteration        (iteration),
  .first_iteration  (first_iteration),
  .disable_vn       (disable_vn),
  .disable_cn       (disable_cn),
  
  .we_vnmsg         (we_vnmsg),
  .addr_vn          (addr_vn),
  .addr_vn_lo       (),
  
  .first_half       (first_half),
  .shift0           (shift0),
  .shift1           (shift1),
  .shift2           (shift2),

  .cn_we            (cn_we),
  .cn_rd            (cn_rd),
  .addr_cn          (addr_cn),
  .addr_cn_lo       (),

  .romaddr          (romaddr),
  .romdata          (romdata)
);

// asynchronous ROM, attached to control module
ldpc_edgetable ldpc_edgetable_i(
  .clk     ( clk ),
  .rst     ( rst ),
  .romaddr ( romaddr ),
  .romdata ( romdata )
);

////////////////////////
// 2-d/1-d conversion //
////////////////////////
wire[NUMINSTANCES*LLRWIDTH-1:0] cn_concat;
wire[LLRWIDTH-1:0] cn_msg[0:NUMINSTANCES-1];
wire[NUMINSTANCES*LLRWIDTH-1:0] sh_concat;
wire[LLRWIDTH-1:0] sh_msg[0:NUMINSTANCES-1];


generate
  genvar j;

  for( j=0; j<NUMINSTANCES; j=j+1 )
  begin: convert1d2d
    assign cn_concat[LLRWIDTH*j+LLRWIDTH-1 -: LLRWIDTH] = cn_msg[j];
    assign sh_msg[j] = sh_concat[LLRWIDTH*j+LLRWIDTH-1 -: LLRWIDTH];
  end
endgenerate

wire[NUMVNS*LLRWIDTH-1:0]       vn_cluster_msg[0:NUMINSTANCES/NUMVNS-1];
wire[NUMINSTANCES*LLRWIDTH-1:0] vn_concat;
wire[NUMVNS*LLRWIDTH-1:0]       sh_cluster_msg[0:NUMINSTANCES/NUMVNS-1];

wire[NUMVNS*LLRWIDTH-1:0] llr_din_2d[0:NUMINSTANCES/NUMVNS-1];
wire[NUMVNS*LLRWIDTH-1:0] llr_dout_2d[0:NUMINSTANCES/NUMVNS-1];

generate
  genvar m;

  for( m=0; m<NUMINSTANCES/NUMVNS; m=m+1 )
  begin: convert1d2d2
    assign vn_concat[NUMVNS*LLRWIDTH*m+NUMVNS*LLRWIDTH-1 -: NUMVNS*LLRWIDTH] = vn_cluster_msg[m];
    assign sh_cluster_msg[m] = sh_concat[NUMVNS*LLRWIDTH*m+NUMVNS*LLRWIDTH-1 -: NUMVNS*LLRWIDTH];

    assign llr_din_2d[m] = llr_din[NUMVNS*LLRWIDTH*m+NUMVNS*LLRWIDTH-1 -: NUMVNS*LLRWIDTH];
    assign llr_dout[NUMVNS*LLRWIDTH*m+NUMVNS*LLRWIDTH-1 -: NUMVNS*LLRWIDTH] = llr_dout_2d[m];
  end
endgenerate

//////////
// VN's //
//////////
generate
  genvar i;

  for( i=0; i<NUMINSTANCES/NUMVNS; i=i+1 )
  begin: varnodes
    // first
    if( i==0 )
    begin
      ldpc_vncluster #(
        .NUMVNS         (NUMVNS),
        .ENABLE_DISABLE (0),
        .FOLDFACTOR     (FOLDFACTOR),
        .LASTSHIFTWIDTH (LASTSHIFTWIDTH),
        .LLRWIDTH       (LLRWIDTH)
      ) ldpc_vncluster_firsti(
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
        .disable_vn       (zero),
        .addr_vn          (addr_vn),
        .sh_cluster_msg     (sh_cluster_msg[i]),
        .vn_cluster_msg     (vn_cluster_msg[i])
      );
    end

    // last
    if( i==NUMINSTANCES/NUMVNS-1 )
    begin
      ldpc_vncluster #(
        .NUMVNS         (NUMVNS),
        .ENABLE_DISABLE (1),
        .FOLDFACTOR     (FOLDFACTOR),
        .LASTSHIFTWIDTH (LASTSHIFTWIDTH),
        .LLRWIDTH       (LLRWIDTH)
      ) ldpc_vncluster_lasti(
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
        .disable_vn       (disable_vn),
        .addr_vn          (addr_vn),
        .sh_cluster_msg   (sh_cluster_msg[i]),
        .vn_cluster_msg   (vn_cluster_msg[i])
      );
    end

    if( (i!=0) && (i!=NUMINSTANCES/NUMVNS-1) )
    begin
      ldpc_vncluster #(
        .NUMVNS         (NUMVNS),
        .ENABLE_DISABLE (0),
        .FOLDFACTOR     (FOLDFACTOR),
        .LASTSHIFTWIDTH (LASTSHIFTWIDTH),
        .LLRWIDTH       (LLRWIDTH)
      ) ldpc_vnclusteri(
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
        .disable_vn       (zero),
        .addr_vn          (addr_vn),
        .sh_cluster_msg   (sh_cluster_msg[i]),
        .vn_cluster_msg   (vn_cluster_msg[i])
      );
    end
  end
endgenerate

//////////////
// SHUFFLER //
//////////////
ldpc_shuffle #( .FOLDFACTOR(FOLDFACTOR),
                .NUMINSTANCES(NUMINSTANCES),
                .LLRWIDTH(LLRWIDTH),
                .LASTSHIFTWIDTH(LASTSHIFTWIDTH),
                .LASTSHIFTDIST(LASTSHIFTDIST)
 ) ldpc_shufflei(
  .clk          (clk),
  .rst          (rst),
  .first_half   (first_half),
  .shift0       (shift0),
  .shift1       (shift1),
  .shift2       (shift2),
  .vn_concat    (vn_concat),
  .cn_concat    (cn_concat),
  .sh_concat    (sh_concat)
);

//////////
// CN's //
//////////
wire                         dnmsg_we;
wire                         dnmsg_we_gated;
wire[7+FOLDFACTOR-1:0]       dnmsg_wraddr[0:NUMINSTANCES-1];
wire[7+FOLDFACTOR-1:0]       dnmsg_rdaddr[0:NUMINSTANCES-1];
wire[17+4*(LLRWIDTH-1)+31:0] dnmsg_din[0:NUMINSTANCES-1];
wire[17+4*(LLRWIDTH-1)+31:0] dnmsg_dout[0:NUMINSTANCES-1];

// first
ldpc_cn #( .FOLDFACTOR(FOLDFACTOR),
           .LLRWIDTH(LLRWIDTH)
) ldpc_cn0i(
  .clk              (clk),
  .rst              (rst),
  .llr_access       (llr_access),
  .llr_addr         (llr_addr),
  .llr_din_we       (llr_din_we),
  .iteration        (iteration),
  .first_half       (first_half),
  .first_iteration  (first_iteration),
  .cn_we            (cn_we),
  .cn_rd            (cn_rd),
  .disable_cn       (disable_cn),
  .addr_cn          (addr_cn),
  .sh_msg           (sh_msg[0]),
  .cn_msg           (cn_msg[0]),
  .dnmsg_we         (dnmsg_we_gated),
  .dnmsg_wraddr     (dnmsg_wraddr[0]),
  .dnmsg_rdaddr     (dnmsg_rdaddr[0]),
  .dnmsg_din        (dnmsg_din[0]),
  .dnmsg_dout       (dnmsg_dout[0])
);

ldpc_ram_behav #(
  .WIDTH    (17+4*(LLRWIDTH-1)+32),
  .LOG2DEPTH(7+FOLDFACTOR)
) ldpc_cnholder_0i (
  .clk(clk),
  .we(dnmsg_we_gated),
  .din(dnmsg_din[0]),
  .wraddr(dnmsg_wraddr[0]),
  .rdaddr(dnmsg_rdaddr[0]),
  .dout(dnmsg_dout[0])
);

// second - same as entire array, but is the source of the signal "we"
  ldpc_cn #( .FOLDFACTOR(FOLDFACTOR),
             .LLRWIDTH(LLRWIDTH)
  ) ldpc_cn1i(
    .clk              (clk),
    .rst              (rst),
    .llr_access       (llr_access),
    .llr_addr         (llr_addr),
    .llr_din_we       (llr_din_we),
    .iteration        (iteration),
    .first_half       (first_half),
    .first_iteration  (first_iteration),
    .cn_we            (cn_we),
    .cn_rd            (cn_rd),
    .disable_cn       (zero),
    .addr_cn          (addr_cn),
    .sh_msg           (sh_msg[1]),
    .cn_msg           (cn_msg[1]),
    .dnmsg_we         (dnmsg_we),
    .dnmsg_wraddr     (dnmsg_wraddr[1]),
    .dnmsg_rdaddr     (dnmsg_rdaddr[1]),
    .dnmsg_din        (dnmsg_din[1]),
    .dnmsg_dout       (dnmsg_dout[1])
);

  ldpc_ram_behav #(
    .WIDTH    (17+4*(LLRWIDTH-1)+32),
    .LOG2DEPTH(7+FOLDFACTOR)
  ) ldpc_cnholder_1i (
    .clk(clk),
    .we(dnmsg_we),
    .din(dnmsg_din[1]),
    .wraddr(dnmsg_wraddr[1]),
    .rdaddr(dnmsg_rdaddr[1]),
    .dout(dnmsg_dout[1])
  );

generate
  genvar k;

  for( k=2; k<NUMINSTANCES; k=k+1 )
  begin: checknodes
    ldpc_cn #( .FOLDFACTOR(FOLDFACTOR),
               .LLRWIDTH(LLRWIDTH)
    ) ldpc_cni(
      .clk              (clk),
      .rst              (rst),
      .llr_access       (llr_access),
      .llr_addr         (llr_addr),
      .llr_din_we       (llr_din_we),
      .iteration        (iteration),
      .first_half       (first_half),
      .first_iteration  (first_iteration),
      .cn_we            (cn_we),
      .cn_rd            (cn_rd),
      .disable_cn       (zero),
      .addr_cn          (addr_cn),
      .sh_msg           (sh_msg[k]),
      .cn_msg           (cn_msg[k]),
      .dnmsg_we         (),
      .dnmsg_wraddr     (dnmsg_wraddr[k]),
      .dnmsg_rdaddr     (dnmsg_rdaddr[k]),
      .dnmsg_din        (dnmsg_din[k]),
      .dnmsg_dout       (dnmsg_dout[k])
  );

    ldpc_ram_behav #(
      .WIDTH    (17+4*(LLRWIDTH-1)+32),
      .LOG2DEPTH(7+FOLDFACTOR)
    ) ldpc_cnholder_i (
      .clk(clk),
      .we(dnmsg_we),
      .din(dnmsg_din[k]),
      .wraddr(dnmsg_wraddr[k]),
      .rdaddr(dnmsg_rdaddr[k]),
      .dout(dnmsg_dout[k])
    );
  end
endgenerate

endmodule
