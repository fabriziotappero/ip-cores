/*******************************************************************************************/
/**                                                                                       **/
/** ORIGINAL COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED **/
/** COPYRIGHT (C) 2012, SERGEY BELYASHOV                                                  **/
/**                                                                                       **/
/** processor top level                                               Rev 0.0  06/13/2012 **/
/**                                                                                       **/
/*******************************************************************************************/
module y80_top (dma_ack, halt_tran, iack_tran, io_addr_out, io_data_out, io_read, io_strobe,
                io_tran, ivec_rd, mem_addr_out, mem_data_out, mem_rd, mem_tran, mem_wr,
                reti_tran, t1, clearb, clkc, dma_req, int_req, io_data_in, ivec_data_in,
                mem_data_in, nmi_req, resetb, wait_req);

  input         clearb;        /* master (test) reset                                      */
  input         clkc;          /* main cpu clock                                           */
  input         dma_req;       /* dma request                                              */
  input         int_req;       /* interrupt request                                        */
  input         nmi_req;       /* nmi request                                              */
  input         resetb;        /* internal (user) reset                                    */
  input         wait_req;      /* wait request                                             */
  input   [7:0] io_data_in;    /* i/o input data bus                                       */
  input   [7:0] ivec_data_in;  /* interrupt vector bus                                     */
  input   [7:0] mem_data_in;   /* memory input bus                                         */
  output        dma_ack;       /* dma acknowledge                                          */
  output        halt_tran;     /* halt transaction                                         */
  output        iack_tran;     /* interrupt acknowledge transaction                        */
  output        io_read;       /* i/o read enable                                          */
  output        io_tran;       /* i/o transaction                                          */
  output        io_strobe;     /* i/o data strobe                                          */
  output        ivec_rd;       /* interrupt vector enable                                  */
  output        mem_rd;        /* memory read enable                                       */
  output        mem_tran;      /* memory transaction                                       */
  output        mem_wr;        /* memory write enable                                      */
  output        reti_tran;     /* return from interrupt transaction                        */
  output        t1;            /* first clock of transaction                               */
  output  [7:0] io_data_out;   /* i/o output data bus                                      */
  output  [7:0] mem_data_out;  /* memory output data bus                                   */
  output [15:0] io_addr_out;   /* i/o address bus                                          */
  output [15:0] mem_addr_out;  /* memory address bus                                       */

  /*****************************************************************************************/
  /*                                                                                       */
  /* signal declarations                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  wire          burst_done;                                /* burst/mlt done               */
  wire          cflg_en;                                   /* carry flag control           */
  wire          carry_bit;                                 /* carry flag                   */
  wire          dma_ack;                                   /* dma acknowledge              */
  wire          dmar_reg;                                  /* latched dma request          */
  wire          ex_af_pls;                                 /* exchange af,af'              */
  wire          ex_bank_pls;                               /* exchange register bank       */
  wire          ex_dehl_inst;                              /* exchange de,hl               */
  wire          ftch_tran;                                 /* inst fetch transaction       */
  wire          halt_nxt, halt_tran;                       /* halt transaction             */
  wire          iack_tran;                                 /* int ack transaction          */
  wire          if_frst;                                   /* first clock if ifetch        */
  wire          inta_frst;                                 /* first clock of intack        */
  wire          intr_reg;                                  /* latched interrupt request    */
  wire          io_read;                                   /* i/o read enable              */
  wire          io_tran;                                   /* i/o transaction              */
  wire          io_strobe;                                 /* i/o data strobe              */
  wire          ivec_rd;                                   /* interrupt vector enable      */
  wire          ld_ctrl;                                   /* load control register        */
  wire          ld_dmaa;                                   /* load dma request             */
  wire          ld_inst;                                   /* load instruction register    */
  wire          ld_inta;                                   /* sample latched int           */
  wire          ld_page;                                   /* load page register           */
  wire          ld_wait;                                   /* sample wait input            */
  wire          mem_rd;                                    /* memory read enable           */
  wire          mem_tran;                                  /* memory transaction           */
  wire          mem_wr;                                    /* memory write enable          */
  wire          output_inh;                                /* disable cpu outputs          */
  wire          par_bit;                                   /* parity flag                  */
  wire          rd_brst;                                   /* burst read                   */
  wire          rd_frst;                                   /* first clock of read          */
  wire          rd_nxt;                                    /* read trans next              */
  wire          reti_nxt, reti_tran;                       /* reti transaction             */
  wire          rreg_en;                                   /* update refresh register      */
  wire          sflg_en;                                   /* sign flag control            */
  wire          sign_bit;                                  /* sign flag                    */
  wire          tflg_reg;                                  /* temporary flag               */
  wire          t1;                                        /* first clock of transaction   */
  wire          vector_int;                                /* int vector enable            */
  wire          wait_st;                                   /* wait state identifier        */
  wire          wr_brst;                                   /* burst write                  */
  wire          wr_frst;                                   /* first clock of write         */
  wire          xhlt_reg;                                  /* halt exit                    */
  wire          zero_bit;                                  /* zero flag                    */
  wire          zflg_en;                                   /* zero flag control            */
  wire    [3:0] page_sel;                                  /* inst decode page control     */
  wire    [3:0] page_reg;                                  /* instruction decode "page"    */
  wire    [7:0] inst_reg;                                  /* instruction register         */
  wire    [7:0] data_in;                                   /* read data bus                */
  wire    [7:0] dout_io_reg, dout_mem_reg;                 /* write data bus               */
  wire   [15:0] addr_reg_in;                               /* processor logical address    */
  wire    [7:0] io_data_out;                               /* i/o output data bus          */
  wire    [7:0] mem_data_out;                              /* memory output data bus       */
  wire   [15:0] io_addr_out;                               /* i/o address bus              */
  wire   [15:0] mem_addr_out;                              /* memory address bus           */
  wire  [`ADCTL_IDX:0] add_sel;                            /* address output mux control   */
  wire   [`ALUA_IDX:0] alua_sel;                           /* alu input a mux control      */
  wire   [`ALUB_IDX:0] alub_sel;                           /* alu input b mux control      */
  wire  [`ALUOP_IDX:0] aluop_sel;                          /* alu operation control        */
  wire     [`DI_IDX:0] di_ctl;                             /* data input control           */
  wire     [`DO_IDX:0] do_ctl;                             /* data output control          */
  wire   [`HFLG_IDX:0] hflg_ctl;                           /* half-carry flag control      */
  wire    [`IEF_IDX:0] ief_ctl;                            /* interrupt enable control     */
  wire    [`IMD_IDX:0] imd_ctl;                            /* interrupt mode control       */
  wire   [`NFLG_IDX:0] nflg_ctl;                           /* negate flag control          */
  wire  [`PCCTL_IDX:0] pc_sel;                             /* pc source control            */
  wire   [`PFLG_IDX:0] pflg_ctl;                           /* parity/overflow flag control */
  wire  [`STATE_IDX:0] state_nxt, state_reg;               /* machine state                */
  wire   [`TFLG_IDX:0] tflg_ctl;                           /* temp flag control            */
  wire  [`TTYPE_IDX:0] tran_sel;                           /* transaction type             */
  wire   [`WREG_IDX:0] wr_addr;                            /* register write address bus   */

  /*****************************************************************************************/
  /*                                                                                       */
  /* interface module                                                                      */
  /*                                                                                       */
  /*****************************************************************************************/
  extint   EXTINT   ( .data_in(data_in), .dma_ack(dma_ack), .ftch_tran(ftch_tran),
                      .halt_tran(halt_tran), .iack_tran(iack_tran),
                      .io_addr_out(io_addr_out), .io_data_out(io_data_out),
                      .io_read(io_read), .io_strobe(io_strobe), .io_tran(io_tran),
                      .ivec_rd(ivec_rd), .mem_addr_out(mem_addr_out),
                      .mem_data_out(mem_data_out), .mem_rd(mem_rd), .mem_tran(mem_tran),
                      .mem_wr(mem_wr), .reti_tran(reti_tran), .t1(t1),
                      .addr_reg_in(addr_reg_in), .clkc(clkc), .dmar_reg(dmar_reg),
                      .dout_io_reg(dout_io_reg), .dout_mem_reg(dout_mem_reg),
                      .halt_nxt(halt_nxt), .if_frst(if_frst), .inta_frst(inta_frst),
                      .io_data_in(io_data_in), .ivec_data_in(ivec_data_in),
                      .ld_dmaa(ld_dmaa), .ld_wait(ld_wait), .mem_data_in(mem_data_in),
                      .output_inh(output_inh), .rd_frst(rd_frst), .rd_nxt(rd_nxt),
                      .resetb(resetb), .reti_nxt(reti_nxt), .tran_sel(tran_sel), 
                      .wr_frst(wr_frst) );

  /*****************************************************************************************/
  /*                                                                                       */
  /* state machine module                                                                  */
  /*                                                                                       */
  /*****************************************************************************************/
  machine  MACHINE  ( .ld_ctrl(ld_ctrl), .state_reg(state_reg), .wait_st(wait_st),
                      .clkc(clkc), .dmar_reg(dmar_reg), .intr_reg(intr_reg),
                      .ld_inta(ld_inta), .ld_wait(ld_wait), .resetb(resetb),
                      .state_nxt(state_nxt), .wait_req(wait_req) );

  /*****************************************************************************************/
  /*                                                                                       */
  /* control module                                                                        */
  /*                                                                                       */
  /*****************************************************************************************/
  control CONTROL   ( .add_sel(add_sel), .alua_sel(alua_sel), .alub_sel(alub_sel),
                      .aluop_sel(aluop_sel), .cflg_en(cflg_en), .di_ctl(di_ctl),
                      .do_ctl(do_ctl), .ex_af_pls(ex_af_pls), .ex_bank_pls(ex_bank_pls),
                      .ex_dehl_inst(ex_dehl_inst), .halt_nxt(halt_nxt), .hflg_ctl(hflg_ctl),
                      .ief_ctl(ief_ctl), .if_frst(if_frst), .inta_frst(inta_frst),
                      .imd_ctl(imd_ctl), .ld_dmaa(ld_dmaa), .ld_inst(ld_inst),
                      .ld_inta(ld_inta), .ld_page(ld_page), .ld_wait(ld_wait),
                      .nflg_ctl(nflg_ctl), .output_inh(output_inh), .page_sel(page_sel),
                      .pc_sel(pc_sel), .pflg_ctl(pflg_ctl), .rd_frst(rd_frst),
                      .rd_nxt(rd_nxt), .reti_nxt(reti_nxt), .rreg_en(rreg_en), .sflg_en(sflg_en),
                      .state_nxt(state_nxt), .tflg_ctl(tflg_ctl), .tran_sel(tran_sel),
                      .wr_addr(wr_addr), .wr_frst(wr_frst), .zflg_en(zflg_en),
                      .carry_bit(carry_bit), .dmar_reg(dmar_reg), .inst_reg(inst_reg),
                      .intr_reg(intr_reg), .page_reg(page_reg), .par_bit(par_bit),
                      .sign_bit(sign_bit), .state_reg(state_reg), .tflg_reg(tflg_reg),
                      .vector_int(vector_int), .xhlt_reg(xhlt_reg), .zero_bit(zero_bit),
                      .int_req(int_req) );

  /*****************************************************************************************/
  /*                                                                                       */
  /* data path module                                                                      */
  /*                                                                                       */
  /*****************************************************************************************/
  datapath DATAPATH ( .addr_reg_in(addr_reg_in), .carry_bit(carry_bit), .dmar_reg(dmar_reg),
                      .dout_io_reg(dout_io_reg), .dout_mem_reg(dout_mem_reg),
                      .inst_reg(inst_reg), .intr_reg(intr_reg), .page_reg(page_reg),
                      .par_bit(par_bit), .sign_bit(sign_bit), .tflg_reg(tflg_reg),
                      .vector_int(vector_int), .xhlt_reg(xhlt_reg), .zero_bit(zero_bit),
                      .add_sel(add_sel), .alua_sel(alua_sel), .alub_sel(alub_sel),
                      .aluop_sel(aluop_sel), .clearb(clearb), .clkc(clkc), .cflg_en(cflg_en),
                      .data_in(data_in), .di_ctl(di_ctl), .dma_req(dma_req), .do_ctl(do_ctl),
                      .ex_af_pls(ex_af_pls), .ex_bank_pls(ex_bank_pls),
                      .ex_dehl_inst(ex_dehl_inst), .hflg_ctl(hflg_ctl), .ief_ctl(ief_ctl),
                      .imd_ctl(imd_ctl), .int_req(int_req), .ivec_rd(ivec_rd),
                      .ld_ctrl(ld_ctrl), .ld_inst(ld_inst), .ld_page(ld_page),
                      .nflg_ctl(nflg_ctl), .nmi_req(nmi_req), .page_sel(page_sel),
                      .pc_sel(pc_sel), .pflg_ctl(pflg_ctl), .resetb(resetb), .rreg_en(rreg_en),
                      .sflg_en(sflg_en), .tflg_ctl(tflg_ctl), .wait_st(wait_st),
                      .wr_addr(wr_addr), .zflg_en(zflg_en) );

  endmodule








