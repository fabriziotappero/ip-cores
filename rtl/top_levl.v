/*******************************************************************************************/
/**                                                                                       **/
/** ORIGINAL COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED **/
/** COPYRIGHT (C) 2012, SERGEY BELYASHOV                                                  **/
/**                                                                                       **/
/** Y80e processor test bench                                         Rev 0.0  06/18/2012 **/
/**                                                                                       **/
/*******************************************************************************************/
`timescale 1ns / 10ps                                      /* set time scale               */
`include "version.v"                                       /* select version               */
`include "hierarchy.v"                                     /* include sources              */

module top_levl;

  wire        DMA_ACK;                                     /* dma acknowledge              */
  wire        HALT_TRAN;                                   /* halt transaction             */
  wire        IACK_TRAN;                                   /* int ack transaction          */
  wire        IO_READ;                                     /* i/o read/write status        */
  wire        IO_STROBE;                                   /* i/o strobe                   */
  wire        IO_TRAN;                                     /* i/o transaction              */
  wire        IVEC_RD;                                     /* int vector read strobe       */
  wire        MEM_RD;                                      /* mem read strobe              */
  wire        MEM_TRAN;                                    /* mem transaction              */
  wire        MEM_WR;                                      /* mem write strobe             */
  wire        RETI_TRAN;                                   /* reti transaction             */
  wire        T1;                                          /* first clock of transaction   */
  wire  [7:0] IO_DATA_OUT;                                 /* i/o data output bus          */
  wire  [7:0] MEM_DATA_OUT;                                /* mem data output bus          */
  wire [15:0] IO_ADDR;                                     /* i/o address bus              */
  wire [15:0] MEM_ADDR;                                    /* mem address bus              */

  reg         CLEARB;                                      /* master (test) reset          */
  reg         CLKC;                                        /* clock                        */
  reg         DMA_REQ;                                     /* dma request                  */
  reg         INT_REQ;                                     /* interrupt request            */
  reg         NMI_REQ;                                     /* non-maskable interrupt req   */
  reg         RESETB;                                      /* internal (user) reset        */
  reg         WAIT_REQ;                                    /* wait request                 */
  reg   [7:0] IO_DATA_IN;                                  /* i/o data input bus           */
  reg   [7:0] IVEC_DATA_IN;                                /* vector input bus             */
  reg   [7:0] MEM_DATA_IN;                                 /* mem data input bus           */

  /*****************************************************************************************/
  /*                                                                                       */
  /* testbench internal variables                                                          */
  /*                                                                                       */
  /*****************************************************************************************/
  reg         CLR_INT;                                     /* deassert interrupt           */
  reg         CLR_NMI;                                     /* deassert nmi                 */
  reg         DISABLE_BREQ;                                /* bus req generator control    */
  reg         DISABLE_INT;                                 /* interrupt generator control  */
  reg         DISABLE_WAIT;                                /* wait generator control       */
  reg         INT_TYPE;                                    /* int type during bus req      */
  reg         PAT_DONE;                                    /* pattern done flag            */
  reg         TRIG_INT;                                    /* assert interrupt             */
  reg         TRIG_NMI;                                    /* assert nmi                   */
  reg   [3:0] PAT_CNT;                                     /* counter to track patterns    */
  reg  [15:0] CMP_ERR_L;                                   /* error counter                */

  reg         wait_dly;                                    /* wait request state machine   */
  reg   [5:0] breq_mach;                                   /* bus request state machine    */

  reg         TREF0, TREF1, TREF2, TREF3, TREF4;           /* timing generator             */ 
  reg         TREF5, TREF6, TREF7, TREF8, TREF9;

  /*****************************************************************************************/
  /*                                                                                       */
  /* read memory and write data compare memory                                             */
  /*                                                                                       */
  /*****************************************************************************************/
  reg   [7:0] rdmem [0:65535];
  reg   [7:0] wrmem [0:65535];

  wire  [7:0] wr_data = (MEM_TRAN) ? wrmem[MEM_ADDR] :
                        (IO_TRAN)  ? wrmem[IO_ADDR]  : 8'hxx;

  wire  [7:0] rd_data   = rdmem[MEM_ADDR];
  wire  [7:0] iord_data = rdmem[IO_ADDR];

  always @ (posedge TREF6) begin
    IO_DATA_IN   = (IO_TRAN && IO_READ && IO_STROBE && !WAIT_REQ) ? iord_data : 8'hxx;
    MEM_DATA_IN  = (MEM_TRAN && MEM_RD && !WAIT_REQ) ? rd_data : 8'hxx;
    end

  always @ (posedge TREF6) begin
    IVEC_DATA_IN = (IACK_TRAN && IVEC_RD && !WAIT_REQ) ? rd_data : 8'hxx;
    end

  always @ (posedge TREF0) begin
    IO_DATA_IN   = 8'hxx;
    MEM_DATA_IN  = 8'hxx;
    IVEC_DATA_IN = 8'hxx;
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* instantiate the design                                                                */
  /*                                                                                       */
  /*****************************************************************************************/
  y80_top Y80 ( .dma_ack(DMA_ACK), .halt_tran(HALT_TRAN), .iack_tran(IACK_TRAN),
                .io_addr_out(IO_ADDR), .io_data_out(IO_DATA_OUT), .io_read(IO_READ),
                .io_strobe(IO_STROBE), .io_tran(IO_TRAN), .ivec_rd(IVEC_RD),
                .mem_addr_out(MEM_ADDR), .mem_data_out(MEM_DATA_OUT), .mem_rd(MEM_RD),
                .mem_tran(MEM_TRAN), .mem_wr(MEM_WR), .reti_tran(RETI_TRAN), .t1(T1),
                .clearb(CLEARB), .clkc(CLKC), .dma_req(DMA_REQ), .int_req(INT_REQ),
                .io_data_in(IO_DATA_IN), .ivec_data_in(IVEC_DATA_IN),
                .mem_data_in(MEM_DATA_IN), .nmi_req(NMI_REQ), .resetb(RESETB),
                .wait_req(WAIT_REQ) );

  /*****************************************************************************************/
  /*                                                                                       */
  /* timing generator                                                                      */
  /*                                                                                       */
  /*****************************************************************************************/
  initial begin
    TREF0 = 1;
    CLKC  = 1;
    end

  always begin
    #10 TREF0 <= 1'b0;
        TREF1 <= 1'b1;
    #10 TREF1 <= 1'b0;
        TREF2 <= 1'b1;
    #10 TREF2 <= 1'b0;
        TREF3 <= 1'b1;
    #10 TREF3 <= 1'b0;
        TREF4 <= 1'b1;
    #10 TREF4 <= 1'b0;
        TREF5 <= 1'b1;
    #10 TREF5 <= 1'b0;
        TREF6 <= 1'b1;
    #10 TREF6 <= 1'b0;
        TREF7 <= 1'b1;
    #10 TREF7 <= 1'b0;
        TREF8 <= 1'b1;
    #10 TREF8 <= 1'b0;
        TREF9 <= 1'b1;
    #10 TREF9 <= 1'b0;
        TREF0 <= 1'b1;
    end

  always @ (posedge TREF3) CLKC = 0;
  always @ (posedge TREF8) CLKC = 1;

  /*****************************************************************************************/
  /*                                                                                       */
  /* initialize input signals                                                              */
  /*                                                                                       */
  /*****************************************************************************************/
  initial begin
    CLEARB    = 1;
    DMA_REQ   = 0;
    INT_REQ   = 0;
    NMI_REQ   = 0;
    RESETB    = 1;
    WAIT_REQ  = 0;
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* initialize testbench variables                                                        */
  /*                                                                                       */
  /*****************************************************************************************/
  initial begin
    breq_mach    = 6'b000000;
    CMP_ERR_L    = 16'h0000;
    CLR_INT      = 0;
    CLR_NMI      = 0;
    DISABLE_BREQ = 1;
    DISABLE_INT  = 1;
    DISABLE_WAIT = 1;
    INT_TYPE     = 0;
    PAT_DONE     = 0;
    TRIG_INT     = 0;
    TRIG_NMI     = 0;
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* reset and clear task                                                                  */
  /*                                                                                       */
  /*****************************************************************************************/
  task resettask;
    begin
      wait(TREF6);
      RESETB   = 0;
      wait(TREF0);
      wait(TREF6);
      wait(TREF0);
      wait(TREF6);
      RESETB   = 1;
      CLR_INT  = 1;
      CLR_NMI  = 1;
      wait(TREF0);
      PAT_DONE = 0;
      end
    endtask    

  task cleartask;
    begin
      wait(TREF6);
      CLEARB   = 0;
      RESETB   = 0;
      wait(TREF0);
      wait(TREF6);
      wait(TREF0);
      wait(TREF6);
      CLEARB   = 1;
      RESETB   = 1;
      CLR_INT  = 1;
      CLR_NMI  = 1;
      wait(TREF0);
      PAT_DONE = 0;
      end
    endtask    

  /*****************************************************************************************/
  /*                                                                                       */
  /* error log                                                                             */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (posedge TREF4) begin
    if (MEM_WR)                CMP_ERR_L = CMP_ERR_L + (MEM_DATA_OUT != wr_data);
    if (!IO_READ && IO_STROBE) CMP_ERR_L = CMP_ERR_L + (IO_DATA_OUT  != wr_data);
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* end-of-pattern detect                                                                 */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (posedge TREF4) begin
    PAT_DONE  = (MEM_ADDR[15:0] == 16'h00c3);
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* interrupt/nmi request generator                                                       */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (posedge TREF4) begin
    TRIG_INT = !((MEM_ADDR[15:13] == 3'b110) && (MEM_ADDR[8:0] == 9'h0ff)) ||
                 DISABLE_INT || |breq_mach;
    TRIG_NMI = !((MEM_ADDR[15:13] == 3'b110) && (MEM_ADDR[8:0] == 9'h1ff)) ||
                 DISABLE_INT || |breq_mach;
    CLR_INT  = (MEM_ADDR[15:13] == 3'b111);
    CLR_NMI  = (MEM_ADDR[15:13] == 3'b111);
    if (T1) INT_TYPE = MEM_ADDR[8];
    end

  always @ (negedge TRIG_NMI) begin
    NMI_REQ = 1;
    end

  always @ (posedge CLR_NMI) begin
    NMI_REQ = 0;
    end

  always @ (negedge TRIG_INT) begin
    INT_REQ = 1;
    end

  always @ (posedge CLR_INT) begin
    wait(TREF0);
    wait(TREF4);
    wait(TREF0);
    wait(TREF4);
    INT_REQ = 0;
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* interrupt request generator (during Halt)                                             */
  /*                                                                                       */
  /*****************************************************************************************/
  integer j;

  always @ (posedge HALT_TRAN) begin
    for (j=0; j < 10; j=j+1) begin
      wait (TREF6);
      wait (TREF0);
      end
    wait (TREF6);
    INT_REQ = HALT_TRAN && !INT_TYPE;
    NMI_REQ = HALT_TRAN &&  INT_TYPE;
    wait (TREF0);
    for (j=0; j < 12; j=j+1) begin
      wait (TREF6);
      wait (TREF0);
      end
    INT_REQ = 0;
    NMI_REQ = 0;
    wait (TREF6);
    wait (TREF0);
    wait (TREF6);
    NMI_REQ = HALT_TRAN &&  INT_TYPE;
    wait (TREF0);
    wait (TREF6);
    wait (TREF0);
    NMI_REQ = 0;
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* wait request generator                                                                */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (posedge CLKC) begin
    wait_dly <= T1;
    end

  always @ (posedge TREF6) WAIT_REQ = !DISABLE_WAIT && (T1 || wait_dly);
  always @ (posedge TREF9) WAIT_REQ = 1'b0;

  /*****************************************************************************************/
  /*                                                                                       */
  /* bus request generator                                                                 */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (posedge CLKC) begin
    breq_mach <= (DISABLE_BREQ) ? 6'b000000 :
                 (T1)           ? 6'b000001 : {breq_mach[4:0], wait_dly};
    end

  always @ (posedge TREF6) DMA_REQ = !DISABLE_BREQ &&
                                     (T1 || |breq_mach[2:0] || (HALT_TRAN && |breq_mach));

  /*****************************************************************************************/
  /*                                                                                       */
  /* run the test patterns                                                                 */
  /*                                                                                       */
  /*****************************************************************************************/
  initial begin
    $readmemh("setup_hl.vm", rdmem);
    cleartask;
    wait (PAT_DONE);

    DISABLE_INT = 0;                                       /* interrupt generator on       */

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h1;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("int_ops.vm",  rdmem);
    $readmemh("int_opsd.vm", wrmem);
    wait (PAT_DONE);

    DISABLE_INT  = 1;                                      /* interrupt generator off      */

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h2;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("alu_ops.vm", rdmem);
    $readmemh("alu_opsd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h3;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("dat_mov.vm", rdmem);
    $readmemh("dat_movd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h4;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("bit_ops.vm", rdmem);
    $readmemh("bit_opsd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h5;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("jmp_ops.vm", rdmem);
    $readmemh("jmp_opsd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h6;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("io_ops.vm", rdmem);
    $readmemh("io_opsd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h7;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("180_ops.vm", rdmem);
    $readmemh("180_opsd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h8;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("ez8_ops.vm", rdmem);
    $readmemh("ez8_opsd.vm", wrmem);
    wait (PAT_DONE);

    DISABLE_INT  = 0;                                      /* interrupt generator on       */
    DISABLE_WAIT = 0;                                      /* wait generator on            */

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h1;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("int_ops.vm", rdmem);
    $readmemh("int_opsd.vm", wrmem);
    wait (PAT_DONE);

    DISABLE_INT  = 1;                                      /* interrupt generator off      */

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h2;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("alu_ops.vm", rdmem);
    $readmemh("alu_opsd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h3;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("dat_mov.vm", rdmem);
    $readmemh("dat_movd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h4;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("bit_ops.vm", rdmem);
    $readmemh("bit_opsd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h5;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("jmp_ops.vm", rdmem);
    $readmemh("jmp_opsd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h6;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("io_ops.vm", rdmem);
    $readmemh("io_opsd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h7;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("180_ops.vm", rdmem);
    $readmemh("180_opsd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h8;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("ez8_ops.vm", rdmem);
    $readmemh("ez8_opsd.vm", wrmem);
    wait (PAT_DONE);

    DISABLE_INT  = 0;                                      /* interrupt generator on       */
    DISABLE_BREQ = 0;                                      /* bus req generator on         */
    DISABLE_WAIT = 1;                                      /* wait generator off           */

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h1;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("int_ops.vm", rdmem);
    $readmemh("int_opss.vm", wrmem);
    wait (PAT_DONE);

    DISABLE_INT  = 1;                                      /* interrupt generator off      */

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h2;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("alu_ops.vm", rdmem);
    $readmemh("alu_opsd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h3;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("dat_mov.vm", rdmem);
    $readmemh("dat_movd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h4;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("bit_ops.vm", rdmem);
    $readmemh("bit_opsd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h5;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("jmp_ops.vm", rdmem);
    $readmemh("jmp_opsd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h6;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("io_ops.vm", rdmem);
    $readmemh("io_opsd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h7;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("180_ops.vm", rdmem);
    $readmemh("180_opsd.vm", wrmem);
    wait (PAT_DONE);

    resettask;
    CMP_ERR_L = 16'h0000;
    PAT_CNT   = 5'h8;
    $readmemh("blank_xx.vm", rdmem);
    $readmemh("blank_xx.vm", wrmem);
    $readmemh("ez8_ops.vm", rdmem);
    $readmemh("ez8_opsd.vm", wrmem);
    wait (PAT_DONE);

    $stop;
    end

  endmodule

















