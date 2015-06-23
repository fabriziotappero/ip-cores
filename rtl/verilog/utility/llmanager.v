//----------------------------------------------------------------------
//  Linked List Manager
//
//----------------------------------------------------------------------
//  Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

module llmanager
  (/*AUTOARG*/
  // Outputs
  par_drdy, parr_srdy, parr_page, lnp_drdy, rlp_drdy, rlpr_srdy,
  rlpr_data, drf_drdy, refup_drdy, pgmem_wr_en, pgmem_wr_addr,
  pgmem_wr_data, pgmem_rd_addr, pgmem_rd_en, ref_wr_en, ref_wr_addr,
  ref_wr_data, ref_rd_addr, ref_rd_en, free_count,
  // Inputs
  clk, reset, par_srdy, parr_drdy, lnp_srdy, lnp_pnp, rlp_srdy,
  rlp_rd_page, rlpr_drdy, drf_srdy, drf_page_list, refup_srdy,
  refup_page, refup_count, pgmem_rd_data, ref_rd_data
  );

  parameter lpsz = 8;    // link list page size, in bits
  parameter lpdsz = lpsz+1;  // link page data size, must be at least size of address
  parameter pages = 256; // number of pages
  //parameter sidsz = 2; // source ID size, in bits
  parameter sources = 4; // number of sources
  parameter sinks = 4;    // number of sinks
  parameter sksz = 2;     // number of sink address bits
  parameter maxref = 7;   // maximum reference count, disable with maxref = 0
  parameter refsz  = 3;   // size of reference count bits

  input clk;
  input reset;

  // page allocation request i/f
  input [sources-1:0] par_srdy;
  output [sources-1:0] par_drdy;

  // page allocation request reply i/f
  output [sources-1:0] parr_srdy;
  input [sources-1:0] parr_drdy;
  output [lpsz-1:0]   parr_page;

  // link to next page i/f
  input [sources-1:0]  lnp_srdy;
  output [sources-1:0] lnp_drdy;
  input [sources*(lpsz+lpdsz)-1:0] lnp_pnp;

  // read link page i/f
  input [sinks-1:0]      rlp_srdy;
  output [sinks-1:0]     rlp_drdy;
  input [sinks*lpsz-1:0] rlp_rd_page;

  // read link page reply i/f
  output [sinks-1:0]     rlpr_srdy;
  input [sinks-1:0]      rlpr_drdy;
  output [lpdsz-1:0]     rlpr_data;

  // page dereference interface
  input [sinks-1:0]   drf_srdy;
  output [sinks-1:0]  drf_drdy;
  input [sinks*lpsz*2-1:0] drf_page_list;

  // reference count update interface
  input                  refup_srdy;
  output                 refup_drdy;
  input [lpsz-1:0]       refup_page;
  input [refsz-1:0]      refup_count;

  // link memory interface
  output                 pgmem_wr_en;
  output [lpsz-1:0]      pgmem_wr_addr;
  output [lpdsz-1:0]     pgmem_wr_data;
  output [lpsz-1:0]      pgmem_rd_addr;
  output                 pgmem_rd_en;
  input [lpdsz-1:0]      pgmem_rd_data;

  // reference count memory interface
  output                 ref_wr_en;
  output [lpsz-1:0]      ref_wr_addr;
  output [refsz-1:0]     ref_wr_data;
  output [lpsz-1:0]      ref_rd_addr;
  output                 ref_rd_en;
  input [refsz-1:0]      ref_rd_data;
  

  output [lpsz:0]        free_count;

  reg [lpsz-1:0]       r_free_head_ptr, free_tail_ptr;
  wire [lpsz-1:0]      free_head_ptr;

  reg                  pmstate;
  integer              i;
  wire [sources-1:0]   req_src_id;
  reg [sources-1:0]    iparr_src_id;
  wire                 req_srdy;

  wire reclaim_srdy;
  reg  reclaim_drdy;
  wire [lpsz-1:0] reclaim_start_page, reclaim_end_page;

  reg [lpdsz-1:0]  pgmem_wr_data;
  reg             pgmem_wr_en;
  reg [lpsz-1:0]  pgmem_wr_addr;
  reg [lpsz-1:0]  pgmem_rd_addr;
  reg             pgmem_rd_en;

  reg             init;
  reg [lpsz:0]    init_count;
  reg [lpsz:0]    free_count;
  wire            free_empty;
  reg             req_drdy;

  wire            irlp_srdy;
  reg             irlp_drdy;
  wire [lpsz-1:0] irlp_rd_page;
  wire [sinks-1:0] irlp_grant;

  reg             irlpr_srdy;
  wire            irlpr_drdy;
  reg [sinks-1:0] irlpr_grant, nxt_irlpr_grant;
  reg              load_head_ptr, nxt_load_head_ptr;
  reg              load_lp_data, nxt_load_lp_data;

  wire            ilnp_srdy;
  reg             ilnp_drdy;
  wire [lpsz-1:0] ilnp_page;
  wire [lpdsz-1:0] ilnp_nxt_page;

  wire dsbuf_srdy, dsbuf_drdy;
  wire [sources-1:0] dsbuf_source;
  wire [lpsz-1:0]    dsbuf_data;
  wire               iparr_drdy;

  assign free_empty = (free_head_ptr == free_tail_ptr);
  assign free_head_ptr = (load_head_ptr) ? pgmem_rd_data : r_free_head_ptr;

  sd_rrmux #(.mode(0), .fast_arb(1), 
             .width(1), .inputs(sources)) req_mux
    (
     .clk         (clk),
     .reset       (reset),

     .c_srdy      (par_srdy),
     .c_drdy      (par_drdy),
     .c_data      ({sources{1'b0}}),
     .c_rearb     (1'b1),

     .p_srdy      (req_srdy),
     .p_drdy      (req_drdy),
     .p_data      (),
     .p_grant     (req_src_id)
     );

  sd_rrmux #(.mode(0), .fast_arb(1), 
             .width(lpsz+lpdsz), .inputs(sources)) lnp_mux
    (
     .clk         (clk),
     .reset       (reset),

     .c_srdy      (lnp_srdy),
     .c_drdy      (lnp_drdy),
     .c_data      (lnp_pnp),
     .c_rearb     (1'b1),

     .p_srdy      (ilnp_srdy),
     .p_drdy      (ilnp_drdy),
     .p_data      ({ilnp_page,ilnp_nxt_page}),
     .p_grant     ()
     );

  sd_rrmux #(.mode(0), .fast_arb(1), 
             .width(lpsz), .inputs(sources)) rlp_mux
    (
     .clk         (clk),
     .reset       (reset),

     .c_srdy      (rlp_srdy),
     .c_drdy      (rlp_drdy),
     .c_data      (rlp_rd_page),
     .c_rearb     (1'b1),

     .p_srdy      (irlp_srdy),
     .p_drdy      (irlp_drdy),
     .p_data      (irlp_rd_page),
     .p_grant     (irlp_grant)
     );

  always @(posedge clk)
    begin
      if (reset)
        begin
          init <= 1;
          init_count <= 0;
          r_free_head_ptr <= 0;
          free_tail_ptr <= pages - 1;
          free_count <= pages;
          load_head_ptr <= 0;
          load_lp_data <= 0;
          irlpr_grant <= 0;
          iparr_src_id <= 0;
        end
      else
        begin
          load_head_ptr <= nxt_load_head_ptr;
          load_lp_data  <= nxt_load_lp_data;
          irlpr_grant <= nxt_irlpr_grant;

          if (init)
            begin
              init_count <= init_count + 1;
              if (init_count == (pages-1))
                init <= 0;
            end
          else
            begin
              if (load_head_ptr)
                r_free_head_ptr <= pgmem_rd_data;

              if (req_drdy)
                iparr_src_id    <= req_src_id;

              if (reclaim_srdy & reclaim_drdy)
                free_tail_ptr <= reclaim_end_page;

              if (pgmem_rd_en & !pgmem_wr_en)
                free_count <= free_count - 1;
              else if (pgmem_wr_en & !pgmem_rd_en)
                free_count <= free_count + 1;
            end
        end // else: !if(reset)
    end // always @ (posedge clk)

  always @*
    begin
      pgmem_wr_data = 0;
      pgmem_wr_en = 0;
      pgmem_wr_addr = 0;
      pgmem_rd_addr = 0;
      pgmem_rd_en = 0;
      ilnp_drdy = 0;
      nxt_load_head_ptr = 0;
      nxt_load_lp_data = 0;
      nxt_irlpr_grant = irlpr_grant;
      irlp_drdy = 0;
      req_drdy = 0;

      if (init)
        begin
          pgmem_wr_en = 1;
          pgmem_wr_addr = init_count;
          pgmem_wr_data[lpsz-1:0] = init_count + 1;
          pgmem_wr_data[lpdsz-1:lpsz] = 0;
          reclaim_drdy = 0;
        end
      else
        begin
          reclaim_drdy = 1;
          // load_lp check is to predict flow control on next cycle,
          // prevents back-to-pack Read Link Page requests
          if (irlp_srdy & irlpr_drdy & !load_lp_data)
            begin
              pgmem_rd_en = 1;
              pgmem_rd_addr = irlp_rd_page;
              nxt_load_lp_data = 1;
              nxt_irlpr_grant = irlp_grant;
              irlp_drdy = 1;
            end
          else if (req_srdy & (iparr_drdy & dsbuf_drdy) & !free_empty)
            begin
              pgmem_rd_en = 1;
              pgmem_rd_addr = free_head_ptr;
              nxt_load_head_ptr = 1;
              req_drdy = 1;
            end

          if (reclaim_srdy)
            begin
              pgmem_wr_en = 1;
              pgmem_wr_addr = free_tail_ptr;
              pgmem_wr_data = reclaim_start_page;
            end
          else if (ilnp_srdy)
            begin
              ilnp_drdy = 1;
              pgmem_wr_en = 1;
              pgmem_wr_addr = ilnp_page;
              pgmem_wr_data = ilnp_nxt_page;
           end
       end
    end

  sd_input #(.width(lpsz+sources)) lp_disp_buf
    (.clk (clk), .reset (reset),
     .c_srdy (load_head_ptr),
     .c_drdy (iparr_drdy),
     .c_data ({iparr_src_id,r_free_head_ptr}),
     .ip_srdy (dsbuf_srdy),
     .ip_drdy (dsbuf_drdy),
     .ip_data ({dsbuf_source,dsbuf_data}));

  sd_mirror #(.mirror(sources), .width(lpsz)) lp_dispatch
    (.clk   (clk),
     .reset (reset),
     
     .c_srdy (dsbuf_srdy),
     .c_drdy (dsbuf_drdy),
     .c_data (dsbuf_data),
     .c_dst_vld (dsbuf_source),

     .p_srdy (parr_srdy),
     .p_drdy (parr_drdy),
     .p_data (parr_page)
     );

  // output reflector for read link page interface
  sd_mirror #(.mirror(sinks), .width(lpdsz)) read_link_return
    (.clk   (clk),
     .reset (reset),
     
     .c_srdy (load_lp_data),
     .c_drdy (irlpr_drdy),
     .c_data (pgmem_rd_data),
     .c_dst_vld (irlpr_grant),

     .p_srdy (rlpr_srdy),
     .p_drdy (rlpr_drdy),
     .p_data (rlpr_data)
     );

  generate if (maxref == 0)
    begin : no_ref_count
  sd_rrmux #(.mode(0), .fast_arb(1), 
             .width(lpsz*2), .inputs(sinks)) reclaim_mux
    (
     .clk         (clk),
     .reset       (reset),

     .c_srdy      (drf_srdy),
     .c_drdy      (drf_drdy),
     .c_data      (drf_page_list),
     .c_rearb     (1'b1),

     .p_srdy      (reclaim_srdy),
     .p_drdy      (reclaim_drdy),
     .p_data      ({reclaim_start_page,reclaim_end_page}),
     .p_grant     ()
     );
    end // block: no_ref_count
  else
    begin : enable_ref_count
      wire drq_srdy, drq_drdy;
      wire [lpsz-1:0] drq_start_page, drq_end_page;

      sd_rrmux #(.mode(0), .fast_arb(1), 
                 .width(lpsz*2), .inputs(sinks)) reclaim_mux
        (
         .clk         (clk),
         .reset       (reset),
         
         .c_srdy      (drf_srdy),
         .c_drdy      (drf_drdy),
         .c_data      (drf_page_list),
         .c_rearb     (1'b1),

         .p_srdy      (drq_srdy),
         .p_drdy      (drq_drdy),
         .p_data      ({drq_start_page,drq_end_page}),
         .p_grant     ()
         );

      llmanager_refcount #(/*AUTOINSTPARAM*/
                           // Parameters
                           .lpsz                (lpsz),
                           .refsz               (refsz)) llref
        (/*AUTOINST*/
         // Outputs
         .drq_drdy                      (drq_drdy),
         .reclaim_srdy                  (reclaim_srdy),
         .reclaim_start_page            (reclaim_start_page[(lpsz)-1:0]),
         .reclaim_end_page              (reclaim_end_page[(lpsz)-1:0]),
         .refup_drdy                    (refup_drdy),
         .ref_wr_en                     (ref_wr_en),
         .ref_wr_addr                   (ref_wr_addr[(lpsz)-1:0]),
         .ref_wr_data                   (ref_wr_data[(refsz)-1:0]),
         .ref_rd_addr                   (ref_rd_addr[(lpsz)-1:0]),
         .ref_rd_en                     (ref_rd_en),
         // Inputs
         .clk                           (clk),
         .reset                         (reset),
         .drq_srdy                      (drq_srdy),
         .drq_start_page                (drq_start_page[(lpsz)-1:0]),
         .drq_end_page                  (drq_end_page[(lpsz)-1:0]),
         .reclaim_drdy                  (reclaim_drdy),
         .refup_srdy                    (refup_srdy),
         .refup_page                    (refup_page[(lpsz)-1:0]),
         .refup_count                   (refup_count[(refsz)-1:0]),
         .ref_rd_data                   (ref_rd_data[(refsz)-1:0]));
    end
  endgenerate

endmodule // llmanager
