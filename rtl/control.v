/*******************************************************************************************/
/**                                                                                       **/
/** ORIGINAL COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED **/
/** COPYRIGHT (C) 2012, SERGEY BELYASHOV                                                  **/
/**                                                                                       **/
/** control module                                                   Rev  0.0  06/18/2012 **/
/**                                                                                       **/
/*******************************************************************************************/
module control (add_sel, alua_sel, alub_sel, aluop_sel, cflg_en, di_ctl, do_ctl, ex_af_pls,
                ex_bank_pls, ex_dehl_inst, halt_nxt, hflg_ctl, ief_ctl, if_frst, inta_frst,
                imd_ctl, ld_dmaa, ld_inst, ld_inta, ld_page, ld_wait, nflg_ctl, output_inh,
                page_sel, pc_sel, pflg_ctl, rd_frst, rd_nxt, reti_nxt, rreg_en, sflg_en, state_nxt,
                tflg_ctl, tran_sel, wr_addr, wr_frst, zflg_en, carry_bit, dmar_reg, inst_reg,
                intr_reg, page_reg, par_bit, sign_bit, state_reg, tflg_reg, vector_int,
                xhlt_reg, zero_bit, int_req);

  input         carry_bit;     /* carry flag                                               */
  input         dmar_reg;      /* latched dma request                                      */
  input         intr_reg;      /* latched interrupt request                                */
  input         int_req;       /* interrupt request (for SLP)                              */
  input         par_bit;       /* parity flag                                              */
  input         sign_bit;      /* sign flag                                                */
  input         tflg_reg;      /* temporary flag                                           */
  input         vector_int;    /* int vector enable                                        */
  input         xhlt_reg;      /* halt exit                                                */
  input         zero_bit;      /* zero flag                                                */
  input   [3:0] page_reg;      /* instruction decode "page"                                */
  input   [7:0] inst_reg;      /* instruction register                                     */
  input   [`STATE_IDX:0] state_reg;     /* current processor state                         */
  output        cflg_en;       /* carry flag control                                       */
  output        ex_af_pls;     /* exchange af,af'                                          */
  output        ex_bank_pls;   /* exchange register bank                                   */
  output        ex_dehl_inst;  /* exchange de,hl                                           */
  output        halt_nxt;      /* halt cycle next                                          */
  output        if_frst;       /* ifetch first cycle                                       */
  output        inta_frst;     /* intack first cycle                                       */
  output        ld_dmaa;       /* load dma request                                         */
  output        ld_inst;       /* load instruction register                                */
  output        ld_inta;       /* load interrupt request                                   */
  output        ld_page;       /* load page register                                       */
  output        ld_wait;       /* load wait request                                        */
  output        output_inh;    /* disable cpu outputs                                      */
  output        rd_frst;       /* read first cycle                                         */
  output        rd_nxt;        /* read cycle identifier                                    */
  output        reti_nxt;      /* reti identifier                                          */
  output        rreg_en;       /* update refresh register                                  */
  output        sflg_en;       /* sign flag control                                        */
  output        wr_frst;       /* write first cycle                                        */
  output        zflg_en;       /* zero flag control                                        */
  output  [3:0] page_sel;      /* instruction decode "page" control                        */
  output [`ADCTL_IDX:0] add_sel;     /* address output mux control                         */
  output  [`ALUA_IDX:0] alua_sel;    /* alu input a mux control                            */
  output  [`ALUB_IDX:0] alub_sel;    /* alu input b mux control                            */
  output [`ALUOP_IDX:0] aluop_sel;   /* alu operation control                              */
  output    [`DI_IDX:0] di_ctl;      /* data input control                                 */
  output    [`DO_IDX:0] do_ctl;      /* data output control                                */
  output  [`HFLG_IDX:0] hflg_ctl;    /* half-carry flag control                            */
  output   [`IEF_IDX:0] ief_ctl;     /* interrupt enable control                           */
  output   [`IMD_IDX:0] imd_ctl;     /* interrupt mode control                             */
  output  [`NFLG_IDX:0] nflg_ctl;    /* negate flag control                                */
  output [`PCCTL_IDX:0] pc_sel;      /* program counter source control                     */
  output  [`PFLG_IDX:0] pflg_ctl;    /* parity/overflow flag control                       */
  output [`STATE_IDX:0] state_nxt;   /* next processor state                               */
  output  [`TFLG_IDX:0] tflg_ctl;    /* temp flag control                                  */
  output [`TTYPE_IDX:0] tran_sel;    /* transaction type select                            */
  output  [`WREG_IDX:0] wr_addr;     /* register write address bus                         */

  /*****************************************************************************************/
  /*                                                                                       */
  /* signal declarations                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  reg           cflg_en;                                   /* carry flag control           */
  reg           ex_af_pls;                                 /* exchange af,af'              */
  reg           ex_bank_pls;                               /* exchange register bank       */
  reg           ex_dehl_inst;                              /* exchange de,hl               */
  reg           halt_nxt;                                  /* halt transaction             */
  reg           if_frst;                                   /* first clock if ifetch        */
  reg           inta_frst;                                 /* first clock of intack        */
  reg           ld_inst;                                   /* load instruction register    */
  reg           ld_inta;                                   /* sample latched int           */
  reg           ld_dmaa;                                   /* sample latched dma           */
  reg           ld_page;                                   /* load page register           */
  reg           ld_wait;                                   /* sample wait input            */
  reg           output_inh;                                /* disable cpu outputs          */
  reg           rd_frst;                                   /* first clock of read          */
  reg           rd_nxt;                                    /* read trans next              */
  reg           reti_nxt;                                  /* reti trans next              */
`ifdef RREG_EMU
  reg           rreg_en;                                   /* update refresh register      */
`endif
  reg           sflg_en;                                   /* sign flag control            */
  reg           wr_frst;                                   /* first clock of write         */
  reg           zflg_en;                                   /* zero flag control            */
  reg     [3:0] page_sel;                                  /* inst decode page control     */
  reg   [`ADCTL_IDX:0] add_sel;                            /* address output mux control   */
  reg    [`ALUA_IDX:0] alua_sel;                           /* alu input a mux control      */
  reg    [`ALUB_IDX:0] alub_sel;                           /* alu input b mux control      */
  reg   [`ALUOP_IDX:0] aluop_sel;                          /* alu operation control        */
  reg      [`DI_IDX:0] di_ctl;                             /* data input control           */
  reg      [`DO_IDX:0] do_ctl;                             /* data output control          */
  reg    [`HFLG_IDX:0] hflg_ctl;                           /* half-carry flag control      */
  reg     [`IEF_IDX:0] ief_ctl;                            /* interrupt enable control     */
  reg     [`IMD_IDX:0] imd_ctl;                            /* interrupt mode control       */
  reg    [`NFLG_IDX:0] nflg_ctl;                           /* negate flag control          */
  reg   [`PCCTL_IDX:0] pc_sel;                             /* pc source control            */
  reg    [`PFLG_IDX:0] pflg_ctl;                           /* parity/overflow flag control */
  reg   [`STATE_IDX:0] state_nxt;                          /* machine state                */
  reg    [`TFLG_IDX:0] tflg_ctl;                           /* temp flag control            */
  reg   [`TTYPE_IDX:0] tran_sel;                           /* transaction type             */
  reg    [`WREG_IDX:0] wr_addr;                            /* register write address bus   */
  
  /*****************************************************************************************/
  /*                                                                                       */
  /* refresh register control                                                              */
  /*                                                                                       */
  /*****************************************************************************************/
`ifdef RREG_EMU
  always @ (inst_reg or page_reg or state_reg or dmar_reg) begin
    casex (state_reg) //sysnopsys parallel_case
      `IF1B,
      `IF2B,
      `IF3B:                rreg_en = 1'b1;
      `WR1B,
      `WR2B: begin
        casex ({page_reg, inst_reg}) //sysnopsys parallel_case
          12'b1xxx10111001,
          12'b1xxx10110001,
          12'b1xxx10111010,
          12'b1xxx10110010,
          12'b1xxx10111000,
          12'b1xxx10110000,
          12'b1xxx10111011,
          12'b1xxx10110011,
          12'b0001xxxxxxxx: rreg_en = 1'b1;
          default:          rreg_en = 1'b0;
        endcase
      end
      default:              rreg_en = 1'b0;
    endcase
  end
`endif

  /*****************************************************************************************/
  /*                                                                                       */
  /* exchange instruction control                                                          */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg)
      `IF1B: begin
        case ({page_reg, inst_reg})
          12'b000000001000: ex_af_pls = 1'b1;
          default:          ex_af_pls = 1'b0;
          endcase
        end
      default:              ex_af_pls = 1'b0;
      endcase
    end

  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg)
      `IF1B: begin
        case ({page_reg, inst_reg})
          12'b000011011001: ex_bank_pls = 1'b1;
          default:          ex_bank_pls = 1'b0;
          endcase
        end
      default:              ex_bank_pls = 1'b0;
      endcase
    end

  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg)
      `DEC1: begin
        case (inst_reg)
          8'b11101011:      ex_dehl_inst = 1'b1;
          default:          ex_dehl_inst = 1'b0;
          endcase
        end
      default:              ex_dehl_inst = 1'b0;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* interrupt control                                                                     */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg)
      `IF1B: begin
        casex ({page_reg, inst_reg})
          12'b000011110011: ief_ctl = `IEF_0;
          12'b000011111011: ief_ctl = `IEF_1;
          12'b0001xxxxxxxx: ief_ctl = `IEF_NMI;
          12'b1xxx01000101: ief_ctl = `IEF_RTN;
          default:          ief_ctl = `IEF_NUL;
          endcase
        end
      default:              ief_ctl = `IEF_NUL;
      endcase
    end

  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg)
      `IF1B: begin
        casex ({page_reg, inst_reg})
          12'b1xxx01000110: imd_ctl = `IMD_0;
          12'b1xxx01010110: imd_ctl = `IMD_1;
          12'b1xxx01011110: imd_ctl = `IMD_2;
          default:          imd_ctl = `IMD_NUL;
          endcase
        end
      default:              imd_ctl = `IMD_NUL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* identifiers to create timing signals                                                  */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1,
      `DEC2,
      `OF2A,
      `IF3A,
      `IF1A:                if_frst = 1'b1;
      default:              if_frst = 1'b0;
      endcase
    end

  always @ (state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `INTA,
      `RSTE:                inta_frst = 1'b1;
      default:              inta_frst = 1'b0;
      endcase
    end

  always @ (inst_reg or page_reg or state_nxt) begin
    casex (state_nxt) //synopsys parallel_case
      `RD1A,
      `RD2A:                rd_nxt = 1'b1;
      default:              rd_nxt = 1'b0;
      endcase
    end

  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `RD1A,
      `RD2A:                rd_frst = 1'b1;
      default:              rd_frst = 1'b0;
      endcase
    end

  always @ (state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `WR1A,
      `WR2A:                wr_frst = 1'b1;
      default:              wr_frst = 1'b0;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* wait sample                                                                           */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or par_bit or
            sign_bit or zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1: begin
        casex (inst_reg) //synopsys parallel_case
          8'b00000010,
          8'b00001010,
          8'b00010010,
          8'b00011010,
          8'b00110100,
          8'b00110101,
          8'b011100xx,
          8'b0111010x,
          8'b01110111,
          8'b010xx110,
          8'b0110x110,
          8'b01111110,
          8'b10000110,
          8'b10001110,
          8'b10010110,
          8'b10011110,
          8'b10100110,
          8'b10101110,
          8'b10110110,
          8'b10111110,
          8'b11001001,
          8'b11100011,
          8'b11xx0001,
          8'b11xx0101,
          8'b11xxx111,
          8'b01110110,
          8'b11101001:      ld_wait = 1'b0;
          8'b11000000:      ld_wait =   zero_bit;
          8'b11001000:      ld_wait =  !zero_bit;
          8'b11010000:      ld_wait =  carry_bit;
          8'b11011000:      ld_wait = !carry_bit;
          8'b11100000:      ld_wait =    par_bit;
          8'b11101000:      ld_wait =   !par_bit;
          8'b11110000:      ld_wait =   sign_bit;
          8'b11111000:      ld_wait =  !sign_bit;
          default:          ld_wait = 1'b1;
          endcase
        end
      `DEC2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b0010xxxxx110,
          12'b010x11100001,
          12'b010x11100011,
          12'b010x11100101,
          12'b1xxx00xxx11x, //ld (hl),rr; ld (hl),ii; ld rr,(hl); ld ii,(hl)
          12'b1xxx0100x101,
          12'b1xxx0110x111,
          12'b1xxx01xxx00x,
          12'b1xxx01110110, //slp
          12'b1xxx100xx01x, //indm,indmr,inim,inimr, otdm,otdmr,otim,otimr
          12'b1xxx101xx0xx,
          12'b1xxx10xxx100, //ind2,ind2r,ini2,ini2r, outd2,otd2r,outi2,oti2r
          12'b1xxx1100x01x, //indrx,inirx, otdrx,otirx
          12'b010x11101001: ld_wait = 1'b0;
          default:          ld_wait = 1'b1;
          endcase
        end
      `OF2A,
      `IF3A,
      `RD1A,
      `RD2A,
      `WR1A,
      `WR2A,
      `IF1A,
      `INTA:                ld_wait = 1'b1;
      default:              ld_wait = 1'b0;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* instruction register and page register control                                        */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `IF2B,
      `IF3B,
      `IF1B:                ld_inst = 1'b1;
      default:              ld_inst = 1'b0;
      endcase
    end

  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg)
      `DEC1: begin
        case (inst_reg)
          8'b11001011:      page_sel = `CB_PAGE;
          8'b11011101:      page_sel = `DD_PAGE;
          8'b11101101:      page_sel = `ED_PAGE;
          8'b11111101:      page_sel = `FD_PAGE;
          default:          page_sel = `MAIN_PG;
          endcase
        end
      `DEC2: begin
        casex ({page_reg, inst_reg})
          12'bx10011001011: page_sel = `DDCB_PG;
          12'bx10111001011: page_sel = `FDCB_PG;
          default:          page_sel = `MAIN_PG;
          endcase
        end
      `INTA:                page_sel = `INTR_PG;
      `DMA1:                page_sel = `DMA_PG;
      default:              page_sel = `MAIN_PG;
      endcase
    end

  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1:                ld_page = 1'b1;
      `DEC2: begin
        casex ({page_reg, inst_reg})
          12'bx10x11001011: ld_page = 1'b1;
          default:          ld_page = 1'b0;
          endcase
        end
      `INTA,
      `DMA1:                ld_page = 1'b1;
      default:              ld_page = 1'b0;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  next state control                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or dmar_reg or intr_reg or
            par_bit or sign_bit or tflg_reg or vector_int or xhlt_reg or zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1: begin
        casex (inst_reg) //synopsys parallel_case
          8'b00000010,
          8'b00001010,
          8'b00010010,
          8'b00011010,
          8'b00110100,
          8'b00110101,
          8'b011100xx,
          8'b0111010x,
          8'b01110111,
          8'b010xx110,
          8'b0110x110,
          8'b01111110,
          8'b10000110,
          8'b10001110,
          8'b10010110,
          8'b10011110,
          8'b10100110,
          8'b10101110,
          8'b10110110,
          8'b10111110,
          8'b11001001,
          8'b11100011,
          8'b11xx0001,
          8'b11xx0101,
          8'b11xxx111:      state_nxt = `sADR2;
          8'b11000000:      state_nxt = ( !zero_bit) ? `sADR2 : `sIF1B;
          8'b11001000:      state_nxt = (  zero_bit) ? `sADR2 : `sIF1B;
          8'b11010000:      state_nxt = (!carry_bit) ? `sADR2 : `sIF1B;
          8'b11011000:      state_nxt = ( carry_bit) ? `sADR2 : `sIF1B;
          8'b11100000:      state_nxt = (  !par_bit) ? `sADR2 : `sIF1B;
          8'b11101000:      state_nxt = (   par_bit) ? `sADR2 : `sIF1B;
          8'b11110000:      state_nxt = ( !sign_bit) ? `sADR2 : `sIF1B;
          8'b11111000:      state_nxt = (  sign_bit) ? `sADR2 : `sIF1B;
          8'b11001011,
          8'b11011101,
          8'b11101101,
          8'b11111101:      state_nxt = `sIF2B;
          8'b00010000,
          8'b00011000,
          8'b00100010,
          8'b00101010,
          8'b00110010,
          8'b00111010,
          8'b001xx000,
          8'b00xx0001,
          8'b00xxx110,
          8'b11000011,
          8'b11000110,
          8'b11001101,
          8'b11001110,
          8'b11010011,
          8'b11010110,
          8'b11011011,
          8'b11011110,
          8'b11100110,
          8'b11101110,
          8'b11110110,
          8'b11111110,
          8'b11xxx010,
          8'b11xxx100:      state_nxt = `sOF1B;
          8'b01110110,
          8'b11101001:      state_nxt = `sPCO;
          default:          state_nxt = `sIF1B;
          endcase
        end
      `IF2B:                state_nxt = `sDEC2;
      `DEC2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b001000000110,
          12'b001000001110,
          12'b001000010110,
          12'b001000011110,
          12'b001000100110,
          12'b001000101110,
          12'b001000110110,
          12'b001000111110,
          12'b001001xxx110,
          12'b001010xxx110,
          12'b001011xxx110,
          12'b010011100001,
          12'b010011100011,
          12'b010011100101,
          12'b010111100001,
          12'b010111100011,
          12'b010111100101,
          12'b1xxx00110100,
          12'b1xxx00110110,
          12'b1xxx00110111,
          12'b1xxx00111110,
          12'b1xxx00111111,
          12'b1xxx00xx0111,
          12'b1xxx00xx1111,
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b1xxx01100111,
          12'b1xxx01101111,
          12'b1xxx01xxx000,
          12'b1xxx01xxx001,
          12'b1xxx10000010,
          12'b1xxx10000011,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001011,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010011,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10100000,
          12'b1xxx10100001,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10100100,
          12'b1xxx10101000,
          12'b1xxx10101001,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10101100,
          12'b1xxx10110000,
          12'b1xxx10110001,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111001,
          12'b1xxx10111010,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011: state_nxt = `sADR2;
          12'b001000000xxx,
          12'b001000001xxx,
          12'b001000010xxx,
          12'b001000011xxx,
          12'b001000100xxx,
          12'b001000101xxx,
          12'b001000110xxx,
          12'b001000111xxx,
          12'b001001xxxxxx,
          12'b001010xxxxxx,
          12'b001011xxxxxx,
          12'b010000100011,
          12'b010000100100,
          12'b010000100101,
          12'b010000101011,
          12'b010000101100,
          12'b010000101101,
          12'b010000xx1001,
          12'b01000110x0xx,12'b01000110x10x,12'b01000110x111,
          12'b0100010xx10x,12'b01000110x10x,12'b01000111110x,
          12'b010010000100,
          12'b010010000101,
          12'b010010001100,
          12'b010010001101,
          12'b010010010100,
          12'b010010010101,
          12'b010010011100,
          12'b010010011101,
          12'b010010100100,
          12'b010010100101,
          12'b010010101100,
          12'b010010101101,
          12'b010010110100,
          12'b010010110101,
          12'b010010111100,
          12'b010010111101,
          12'b010011111001,
          12'b010100100011,
          12'b010100100100,
          12'b010100100101,
          12'b010100101011,
          12'b010100101100,
          12'b010100101101,
          12'b010100xx1001,
          12'b01010110x0xx,12'b01010110x10x,12'b01010110x111,
          12'b0101010xx10x,12'b01010110x10x,12'b01010111110x,
          12'b010110000100,
          12'b010110000101,
          12'b010110001100,
          12'b010110001101,
          12'b010110010100,
          12'b010110010101,
          12'b010110011100,
          12'b010110011101,
          12'b010110100100,
          12'b010110100101,
          12'b010110101100,
          12'b010110101101,
          12'b010110110100,
          12'b010110110101,
          12'b010110111100,
          12'b010110111101,
          12'b010111111001,
          12'b1xxx00xxx100,
          12'b1xxx01000100,
          12'b1xxx01000110,
          12'b1xxx01000111,
          12'b1xxx01001111,
          12'b1xxx01010110,
          12'b1xxx01010111,
          12'b1xxx01011110,
          12'b1xxx01011111,
          12'b1xxx01xx1100,
          12'b1xxx01xx0010,
          12'b1xxx01xx1010: state_nxt = `sIF1B;
          12'b010011101001,
          12'b010111101001,
          12'b1xxx01110110: state_nxt = `sPCO;
          default:          state_nxt = `sOF1B;
        endcase
      end
      `OF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b0000000xx110,12'b00000010x110,12'b000000111110,
          12'b000011000110,
          12'b000011001110,
          12'b000011010110,
          12'b000011011110,
          12'b000011100110,
          12'b000011101110,
          12'b000011110110,
          12'b000011111110,
          12'b010000100110,
          12'b010000101110,
          12'b010100100110,
          12'b010100101110,
          12'b1xxx00110010,
          12'b1xxx00110011,
          12'b1xxx00xx0010,
          12'b1xxx00xx0011,
          12'b1xxx01010100,
          12'b1xxx01010101,
          12'b1xxx01100100: state_nxt = `sIF1A;
          12'b000000100000: state_nxt = ( !zero_bit) ? `sPCA : `sIF1A;
          12'b000000101000: state_nxt = (  zero_bit) ? `sPCA : `sIF1A;
          12'b000000110000: state_nxt = (!carry_bit) ? `sPCA : `sIF1A;
          12'b000000111000: state_nxt = ( carry_bit) ? `sPCA : `sIF1A;
          12'b011xxxxxxxxx: state_nxt = `sIF3A; //DD/FD + CB
          12'b000000100010,
          12'b000000101010,
          12'b000000110010,
          12'b000000111010,
          12'b000000xx0001,
          12'b000011000011,
          12'b000011001101,
          12'b000011xxx010,
          12'b000011xxx100,
          12'b010000100001,
          12'b010000100010,
          12'b010000101010,
          12'b010000110110,
          12'b010100100001,
          12'b010100100010,
          12'b010100101010,
          12'b010100110110,
          12'b1xxx01xx0011,
          12'b1xxx01xx1011: state_nxt = `sOF2A;
          12'b000000010000,
          12'b000000011000: state_nxt = `sPCA;
          12'b000000110110: state_nxt = `sWR2A;
          default:          state_nxt = `sADR1;
        endcase
      end
      `OF2A:                state_nxt = `sOF2B;
      `OF2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000xx0001,
          12'b010000100001,
          12'b010100100001: state_nxt = `sIF1A;
          12'b000011000010: state_nxt = ( !zero_bit) ? `sPCA : `sIF1A;
          12'b000011001010: state_nxt = (  zero_bit) ? `sPCA : `sIF1A;
          12'b000011010010: state_nxt = (!carry_bit) ? `sPCA : `sIF1A;
          12'b000011011010: state_nxt = ( carry_bit) ? `sPCA : `sIF1A;
          12'b000011100010: state_nxt = (  !par_bit) ? `sPCA : `sIF1A;
          12'b000011101010: state_nxt = (   par_bit) ? `sPCA : `sIF1A;
          12'b000011110010: state_nxt = ( !sign_bit) ? `sPCA : `sIF1A;
          12'b000011111010: state_nxt = (  sign_bit) ? `sPCA : `sIF1A;
          12'b000011000100: state_nxt = ( !zero_bit) ? `sWR1A : `sIF1A;
          12'b000011001100: state_nxt = (  zero_bit) ? `sWR1A : `sIF1A;
          12'b000011010100: state_nxt = (!carry_bit) ? `sWR1A : `sIF1A;
          12'b000011011100: state_nxt = ( carry_bit) ? `sWR1A : `sIF1A;
          12'b000011100100: state_nxt = (  !par_bit) ? `sWR1A : `sIF1A;
          12'b000011101100: state_nxt = (   par_bit) ? `sWR1A : `sIF1A;
          12'b000011110100: state_nxt = ( !sign_bit) ? `sWR1A : `sIF1A;
          12'b000011111100: state_nxt = (  sign_bit) ? `sWR1A : `sIF1A;
          12'b000011000011: state_nxt = `sPCA;
          12'b000011001101: state_nxt = `sWR1A;
          12'b010000110110,
          12'b010100110110: state_nxt = `sWR2A;
          default:          state_nxt = `sADR1;
        endcase
      end
      `IF3A:                state_nxt = `sIF3B;
      `IF3B:                state_nxt = `sRD2A;
      `ADR1:                state_nxt = `sADR2;
      `ADR2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000101010,
          12'b000011001001,
          12'b000011100011,
          12'b000011xxx000,
          12'b000011xx0001,
          12'b0001xxxxxxxx,
          12'b010000101010,
          12'b010000110001,
          12'b010000110111,
          12'b010000xx0111,
          12'b010011100001,
          12'b010011100011,
          12'b010100101010,
          12'b010100110001,
          12'b010100110111,
          12'b010100xx0111,
          12'b010111100001,
          12'b010111100011,
          12'b1xxx00110110,
          12'b1xxx00110111,
          12'b1xxx00xx0111,
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b1xxx01xx1011,
          12'b1xxx10000010,
          12'b1xxx10000011,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001011,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010011,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10100000,
          12'b1xxx10100001,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10100100,
          12'b1xxx10101000,
          12'b1xxx10101001,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10101100,
          12'b1xxx10110000,
          12'b1xxx10110001,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111001,
          12'b1xxx10111010,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011: state_nxt = `sRD1A;
          12'b000000100010,
          12'b000011xxx111,
          12'b000011xx0101,
          12'b010000100010,
          12'b010000111110,
          12'b010000111111,
          12'b010000xx1111,
          12'b010011100101,
          12'b010100100010,
          12'b010100111110,
          12'b010100111111,
          12'b010100xx1111,
          12'b010111100101,
          12'b1xxx00111110,
          12'b1xxx00111111,
          12'b1xxx00xx1111,
          12'b1xxx01100101,
          12'b1xxx01100110,
          12'b1xxx01xx0011: state_nxt = `sWR1A;
          12'b000000000010,
          12'b000000010010,
          12'b000000110010,
          12'b000001110xxx,
          12'b000011010011,
          12'b010001110xxx,
          12'b010101110xxx,
          12'b1xxx00xxx001,
          12'b1xxx01xxx001: state_nxt = `sWR2A;
          default:          state_nxt = `sRD2A;
        endcase
      end
      `RD1A:                state_nxt = `sRD1B;
      `RD1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100001,
          12'b1xxx10101001,
          12'b1xxx10110001,
          12'b1xxx10111001: state_nxt = `sBLK1;
          12'b1xxx10000010,
          12'b1xxx10000011,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001011,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010011,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10100000,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10100100,
          12'b1xxx10101000,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10101100,
          12'b1xxx10110000,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111010,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011: state_nxt = `sWR1A;
          default:          state_nxt = `sRD2A;
        endcase
      end
      `RD2A:                state_nxt = `sRD2B;
      `RD2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100001,
          12'b1xxx10101001,
          12'b1xxx10110001,
          12'b1xxx10111001: state_nxt = `sBLK1;
          12'b000000001010,
          12'b000000011010,
          12'b000000101010,
          12'b000000111010,
          12'b000001xxxxxx,
          12'b000001xxx110,
          12'b000010000110,
          12'b000010000xxx,
          12'b000010001110,
          12'b000010001xxx,
          12'b000010010110,
          12'b000010011110,
          12'b000010100110,
          12'b000010100xxx,
          12'b000010101110,
          12'b000010110110,
          12'b000010110xxx,
          12'b000010111110,
          12'b000010111xxx,
          12'b000011011011,
          12'b000011xx0001,
          12'b001001xxx110,
          12'b001001xxxxxx,
          12'b010000101010,
          12'b010000110001,
          12'b010000110111,
          12'b010000xx0111,
          12'b010001xxx110,
          12'b010010000110,
          12'b010010001110,
          12'b010010010110,
          12'b010010011110,
          12'b010010100110,
          12'b010010101110,
          12'b010010110110,
          12'b010010111110,
          12'b010011100001,
          12'b010100101010,
          12'b010100110001,
          12'b010100110111,
          12'b010100xx0111,
          12'b010101xxx110,
          12'b010110000110,
          12'b010110001110,
          12'b010110010110,
          12'b010110011110,
          12'b010110100110,
          12'b010110101110,
          12'b010110110110,
          12'b010110111110,
          12'b010111100001,
          12'b011001xxx110,
          12'b011101xxx110,
          12'b1xxx00110100,
          12'b1xxx00110110,
          12'b1xxx00110111,
          12'b1xxx00xx0111,
          12'b1xxx00xxx000,
          12'b1xxx00xxx100,
          12'b1xxx01110100,
          12'b1xxx01xxx000,
          12'b1xxx01xx1011: state_nxt = `sIF1A;
          12'b000011001001,
          12'b000011xxx000,
          12'b1xxx01000101,
          12'b1xxx01001101: state_nxt = `sPCA;
          12'b000011100011,
          12'b0001xxxxxxxx,
          12'b010011100011,
          12'b010111100011: state_nxt = `sWR1A;
          default:          state_nxt = `sWR2A;
        endcase
      end
      `WR1A:                state_nxt = `sWR1B;
      `WR1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10000010,
          12'b1xxx10000011,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001011,
          12'b1xxx10001100,
          12'b1xxx10100000,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10100100,
          12'b1xxx10101000,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10101100: state_nxt = `sIF1A;
          12'b1xxx10010010,
          12'b1xxx10010011,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10110000,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111010,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011: state_nxt = (tflg_reg || intr_reg || dmar_reg) ? `sPCA : `sRD2A;
          default:          state_nxt = `sWR2A;
        endcase
      end
      `WR2A:                state_nxt = `sWR2B;
      `WR2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10010010,
          12'b1xxx10010011,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10100000,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101000,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110000,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111010,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011: state_nxt = (tflg_reg || intr_reg || dmar_reg) ? `sPCA : `sRD2A;
          default:          state_nxt = `sIF1A;
        endcase
      end
      `BLK1:                state_nxt = `sBLK2;
      `BLK2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10110001,
          12'b1xxx10111001: state_nxt = (tflg_reg || intr_reg || dmar_reg) ? `sPCA : `sRD2A;
          default:          state_nxt = `sIF1A;
        endcase
      end
      `PCA:                 state_nxt = `sPCO;
      `PCO: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000001110110,
          12'b1xxx01110110: state_nxt = `sHLTA;
          default:          state_nxt = `sIF1A;
          endcase
        end
      `HLTA:                state_nxt = `sHLTB;
      `HLTB:                state_nxt = (xhlt_reg || (int_req && page_reg[3])) ? `sIF1A : `sHLTA;
      `IF1A:                state_nxt = `sIF1B;
      `IF1B:                state_nxt = `sDEC1;
      `INTA:                state_nxt = `sINTB;
      `INTB:                state_nxt = (vector_int) ? `sADR1 : `sWR1A;
      `DMA1:                state_nxt = `sDMA2;
      `DMA2:                state_nxt = (dmar_reg) ? `sDMA1 : `sIF1A;
      `RSTE:                state_nxt = `sIF1A;
      default:              state_nxt = `sRSTE;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  transaction type control                                                             */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or dmar_reg or intr_reg or
            par_bit or sign_bit or tflg_reg or vector_int or xhlt_reg or zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `IF2B:                tran_sel = `TRAN_IF;
      `OF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000010000,
          12'b000000011000,
          12'b000011010011,
          12'b000011011011,
          12'b010000110001,
          12'b010000110100,
          12'b010000110101,
          12'b010000110111,
          12'b010000111110,
          12'b010000111111,
          12'b010000xx0111,
          12'b010000xx1111,
          12'b010001110xxx,
          12'b010001xxx110,
          12'b010010000110,
          12'b010010001110,
          12'b010010010110,
          12'b010010011110,
          12'b010010100110,
          12'b010010101110,
          12'b010010110110,
          12'b010010111110,
          12'b010100110001,
          12'b010100110100,
          12'b010100110101,
          12'b010100110111,
          12'b010100111110,
          12'b010100111111,
          12'b010100xx0111,
          12'b010100xx1111,
          12'b010101110xxx,
          12'b010101xxx110,
          12'b010110000110,
          12'b010110001110,
          12'b010110010110,
          12'b010110011110,
          12'b010110100110,
          12'b010110101110,
          12'b010110110110,
          12'b010110111110,
          12'b1xxx00110010,
          12'b1xxx00110011,
          12'b1xxx00xx0010,
          12'b1xxx00xx0011,
          12'b1xxx01010100,
          12'b1xxx01010101,
          12'b1xxx01100101,
          12'b1xxx01100110: tran_sel = `TRAN_IDL;
          12'b000000100000: tran_sel = (  zero_bit) ? `TRAN_IF : `TRAN_IDL;
          12'b000000101000: tran_sel = ( !zero_bit) ? `TRAN_IF : `TRAN_IDL;
          12'b000000110000: tran_sel = ( carry_bit) ? `TRAN_IF : `TRAN_IDL;
          12'b000000111000: tran_sel = (!carry_bit) ? `TRAN_IF : `TRAN_IDL;
          12'b000000110110: tran_sel = `TRAN_MEM;
          default:          tran_sel = `TRAN_IF;
          endcase
        end
      `OF2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000xx0001,
          12'b010000100001,
          12'b010100100001: tran_sel = `TRAN_IF;
          12'b010000110110,
          12'b010100110110: tran_sel = `TRAN_MEM;
          12'b000011001101: tran_sel = `TRAN_STK;
          12'b000011000010: tran_sel = ( !zero_bit) ? `TRAN_IDL : `TRAN_IF;
          12'b000011001010: tran_sel = (  zero_bit) ? `TRAN_IDL : `TRAN_IF;
          12'b000011010010: tran_sel = (!carry_bit) ? `TRAN_IDL : `TRAN_IF;
          12'b000011011010: tran_sel = ( carry_bit) ? `TRAN_IDL : `TRAN_IF;
          12'b000011100010: tran_sel = (  !par_bit) ? `TRAN_IDL : `TRAN_IF;
          12'b000011101010: tran_sel = (   par_bit) ? `TRAN_IDL : `TRAN_IF;
          12'b000011110010: tran_sel = ( !sign_bit) ? `TRAN_IDL : `TRAN_IF;
          12'b000011111010: tran_sel = (  sign_bit) ? `TRAN_IDL : `TRAN_IF;
          12'b000011000100: tran_sel = ( !zero_bit) ? `TRAN_STK : `TRAN_IF;
          12'b000011001100: tran_sel = (  zero_bit) ? `TRAN_STK : `TRAN_IF;
          12'b000011010100: tran_sel = (!carry_bit) ? `TRAN_STK : `TRAN_IF;
          12'b000011011100: tran_sel = ( carry_bit) ? `TRAN_STK : `TRAN_IF;
          12'b000011100100: tran_sel = (  !par_bit) ? `TRAN_STK : `TRAN_IF;
          12'b000011101100: tran_sel = (   par_bit) ? `TRAN_STK : `TRAN_IF;
          12'b000011110100: tran_sel = ( !sign_bit) ? `TRAN_STK : `TRAN_IF;
          12'b000011111100: tran_sel = (  sign_bit) ? `TRAN_STK : `TRAN_IF;
          default:          tran_sel = `TRAN_IDL;
        endcase
      end
      `IF3B:                tran_sel = `TRAN_MEM;
      `ADR2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011010011,
          12'b000011011011,
          12'b1xxx00xxx000,
          12'b1xxx00xxx001,
          12'b1xxx01110100,
          12'b1xxx01xxx000,
          12'b1xxx01xxx001,
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011100,
          12'b1xxx10100010,
          12'b1xxx10101010,
          12'b1xxx10110010,
          12'b1xxx10111010,
          12'b1xxx11000010,
          12'b1xxx11001010: tran_sel = `TRAN_IO;
          12'b000011001001,
          12'b000011xxx000,
          12'b000011xxx111,
          12'b000011xx0001,
          12'b000011xx0101,
          12'b010011100001,
          12'b010011100101,
          12'b010111100001,
          12'b010111100101,
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b1xxx01100101,
          12'b1xxx01100110: tran_sel = `TRAN_STK;
          default:          tran_sel = `TRAN_MEM;
        endcase
      end
      `RD1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100001,
          12'b1xxx10101001,
          12'b1xxx10110001,
          12'b1xxx10111001: tran_sel = `TRAN_IDL;
          12'b1xxx10000011,
          12'b1xxx10001011,
          12'b1xxx10010011,
          12'b1xxx10011011,
          12'b1xxx10100011,
          12'b1xxx10100100,
          12'b1xxx10101011,
          12'b1xxx10101100,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000011,
          12'b1xxx11001011: tran_sel = `TRAN_IO;
          12'b000011001001,
          12'b000011xxx000,
          12'b000011xx0001,
          12'b010011100001,
          12'b010111100001,
          12'b1xxx01000101,
          12'b1xxx01001101: tran_sel = `TRAN_STK;
          default:          tran_sel = `TRAN_MEM;
        endcase
      end
      `RD2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011001001,
          12'b000011xxx000,
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b1xxx10100001,
          12'b1xxx10101001,
          12'b1xxx10110001,
          12'b1xxx10111001: tran_sel = `TRAN_IDL;
          12'b000000001010,
          12'b000000011010,
          12'b000000101010,
          12'b000000111010,
          12'b000001xxx110,
          12'b000010000110,
          12'b000010001110,
          12'b000010010110,
          12'b000010011110,
          12'b000010100110,
          12'b000010101110,
          12'b000010110110,
          12'b000010111110,
          12'b000011011011,
          12'b000011xx0001,
          12'b001001xxx110,
          12'b010000101010,
          12'b010000110001,
          12'b010000110111,
          12'b010000xx0111,
          12'b010001xxx110,
          12'b010010000110,
          12'b010010001110,
          12'b010010010110,
          12'b010010011110,
          12'b010010100110,
          12'b010010101110,
          12'b010010110110,
          12'b010010111110,
          12'b010011100001,
          12'b010100101010,
          12'b010100110001,
          12'b010100110111,
          12'b010100xx0111,
          12'b010101xxx110,
          12'b010110000110,
          12'b010110001110,
          12'b010110010110,
          12'b010110011110,
          12'b010110100110,
          12'b010110101110,
          12'b010110110110,
          12'b010110111110,
          12'b010111100001,
          12'b011001xxx110,
          12'b011101xxx110,
          12'b1xxx00110100,
          12'b1xxx00110110,
          12'b1xxx00110111,
          12'b1xxx00xx0111,
          12'b1xxx00xxx000,
          12'b1xxx01xxx000,
          12'b1xxx01xx1011: tran_sel = `TRAN_IF;
          12'b1xxx10000011,
          12'b1xxx10001011,
          12'b1xxx10010011,
          12'b1xxx10011011,
          12'b1xxx10100011,
          12'b1xxx10100100,
          12'b1xxx10101011,
          12'b1xxx10101100,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000011,
          12'b1xxx11001011: tran_sel = `TRAN_IO;
          12'b000011100011,
          12'b0001xxxxxxxx,
          12'b010011100011,
          12'b010111100011: tran_sel = `TRAN_STK;
          default:          tran_sel = `TRAN_MEM;
        endcase
      end
      `WR1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10010010,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011100,
          12'b1xxx10110010,
          12'b1xxx10111010,
          12'b1xxx11000010,
          12'b1xxx11001010: tran_sel = (tflg_reg || intr_reg || dmar_reg) ? `TRAN_IDL : `TRAN_IO;
          12'b1xxx10010011,
          12'b1xxx10011011,
          12'b1xxx10110000,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000011,
          12'b1xxx11001011: tran_sel = (tflg_reg || intr_reg || dmar_reg) ? `TRAN_IDL : `TRAN_MEM;
          12'b000000100010,
          12'b010000100010,
          12'b010000111110,
          12'b010000111111,
          12'b010000xx1111,
          12'b010100100010,
          12'b010100111110,
          12'b010100111111,
          12'b010100xx1111,
          12'b1xxx00111110,
          12'b1xxx00111111,
          12'b1xxx00xx1111,
          12'b1xxx01xx0011: tran_sel = `TRAN_MEM;
          12'b000011001101,
          12'b000011100011,
          12'b000011xxx100,
          12'b000011xxx111,
          12'b000011xx0101,
          12'b0001xxxxxxxx,
          12'b010011100011,
          12'b010011100101,
          12'b010111100011,
          12'b010111100101,
          12'b1xxx01100101,
          12'b1xxx01100110: tran_sel = `TRAN_STK;
          default:          tran_sel = `TRAN_IF;
        endcase
      end
      `WR2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10010010,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011100,
          12'b1xxx10110010,
          12'b1xxx11000010,
          12'b1xxx11001010,
          12'b1xxx10111010: tran_sel = (tflg_reg || intr_reg || dmar_reg) ? `TRAN_IDL : `TRAN_IO;
          12'b1xxx10010011,
          12'b1xxx10011011,
          12'b1xxx10110000,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000011,
          12'b1xxx11001011: tran_sel = (tflg_reg || intr_reg || dmar_reg) ? `TRAN_IDL : `TRAN_MEM;
          default:          tran_sel = `TRAN_IF;
        endcase
      end
      `BLK2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10110001,
          12'b1xxx10111001: tran_sel = (tflg_reg || intr_reg || dmar_reg) ? `TRAN_IDL : `TRAN_MEM;
          default:          tran_sel = `TRAN_IF;
        endcase
      end
      `PCO: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000001110110,
          12'b1xxx01110110: tran_sel = `TRAN_IDL;
          default:          tran_sel = `TRAN_IF;
          endcase
        end
      `IF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b000011110011,
          12'b0001xxxxxxxx: tran_sel = `TRAN_IF;
          default:          tran_sel = (dmar_reg) ? `TRAN_IDL :
                                       (intr_reg) ? `TRAN_IAK : `TRAN_IF;
          endcase
        end
      `HLTB:                tran_sel = (xhlt_reg || (page_reg[3] && int_req))   ? `TRAN_IF  : `TRAN_IDL;
      `INTB:                tran_sel = (vector_int) ? `TRAN_IDL : `TRAN_MEM;
      `DMA2:                tran_sel = (dmar_reg)   ? `TRAN_IDL : `TRAN_IF;
      `RSTE:                tran_sel = `TRAN_IF;
      default:              tran_sel = `TRAN_RSTVAL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  special transaction identifiers                                                      */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or xhlt_reg) begin
    casex (state_reg)
      `PCO,
      `HLTB: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000001110110: halt_nxt = !xhlt_reg;
          12'b1xxx01110110: halt_nxt = !int_req;
          default:          halt_nxt = 1'b0;
          endcase
        end
      default:              halt_nxt = 1'b0;
      endcase
    end

  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg)
      `RD2B: begin
        casex ({page_reg, inst_reg})
          12'b1xxx01001101: reti_nxt = 1'b1;
          default:          reti_nxt = 1'b0;
          endcase
        end
      default:              reti_nxt = 1'b0;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  output inhibit                                                                       */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or dmar_reg or xhlt_reg) begin
    casex (state_reg)
      `IF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b000011110011,
          12'b0001xxxxxxxx: output_inh = 1'b0;
          default:          output_inh = dmar_reg;
          endcase
        end
      `DMA2:                output_inh = dmar_reg;
      `PCO,
      `HLTB: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000001110110: output_inh = !xhlt_reg;
          12'b1xxx01110110: output_inh = !int_req;
          default:          output_inh = 1'b0;
          endcase
        end
      default:              output_inh = 1'b0;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  address output control                                                               */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or par_bit or sign_bit or
            vector_int or zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1: begin
        casex (inst_reg) //synopsys parallel_case
          8'b00000010,
          8'b00001010,
          8'b00010010,
          8'b00011010,
          8'b11101001,
          8'b11xx0101,
          8'b11xxx111:      add_sel = `ADD_ALU;
          8'b00110100,
          8'b00110101,
          8'b00110110,
          8'b011100xx,
          8'b0111010x,
          8'b01110111,
          8'b010xx110,
          8'b0110x110,
          8'b01111110,
          8'b10000110,
          8'b10001110,
          8'b10010110,
          8'b10011110,
          8'b10100110,
          8'b10101110,
          8'b10110110,
          8'b10111110:      add_sel = `ADD_HL;
          8'b11000000:      add_sel = ( !zero_bit) ? `ADD_SP : `ADD_PC;
          8'b11001000:      add_sel = (  zero_bit) ? `ADD_SP : `ADD_PC;
          8'b11010000:      add_sel = (!carry_bit) ? `ADD_SP : `ADD_PC;
          8'b11011000:      add_sel = ( carry_bit) ? `ADD_SP : `ADD_PC;
          8'b11100000:      add_sel = (  !par_bit) ? `ADD_SP : `ADD_PC;
          8'b11101000:      add_sel = (   par_bit) ? `ADD_SP : `ADD_PC;
          8'b11110000:      add_sel = ( !sign_bit) ? `ADD_SP : `ADD_PC;
          8'b11111000:      add_sel = (  sign_bit) ? `ADD_SP : `ADD_PC;
          8'b11xx0001,
          8'b11100011,
          8'b11001001:      add_sel = `ADD_SP;
          default:          add_sel = `ADD_PC;
          endcase
        end
      `DEC2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b010011100101,
          12'b010011101001,
          12'b010111100101,
          12'b010111101001,
          12'b1xxx01xxx000,
          12'b1xxx01xxx001,
          12'b1xxx10000011,
          12'b1xxx10000100,
          12'b1xxx10001011,
          12'b1xxx10001100,
          12'b1xxx10010011,
          12'b1xxx10010100,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10100000,
          12'b1xxx10100001,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101000,
          12'b1xxx10101001,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110000,
          12'b1xxx10110001,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111001,
          12'b1xxx10111010,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011: add_sel = `ADD_ALU;
          12'b1xxx10000010,
          12'b1xxx10001010,
          12'b1xxx10010010,
          12'b1xxx10011010: add_sel = `ADD_ALU8;
          12'b001000000110,
          12'b001000001110,
          12'b001000010110,
          12'b001000011110,
          12'b001000100110,
          12'b001000101110,
          12'b001000110110,
          12'b001000111110,
          12'b001001xxx110,
          12'b001010xxx110,
          12'b001011xxx110,
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b1xxx00110100,
          12'b1xxx00110110,
          12'b1xxx00110111,
          12'b1xxx00111110,
          12'b1xxx00111111,
          12'b1xxx00xx0111,
          12'b1xxx00xx1111,
          12'b1xxx01100111,
          12'b1xxx01101111: add_sel = `ADD_HL;
          12'b010011100001,
          12'b010011100011,
          12'b010111100001,
          12'b010111100011,
          12'b1xxx01000101,
          12'b1xxx01001101: add_sel = `ADD_SP;
          default:          add_sel = `ADD_PC;
        endcase
      end
      `OF2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011001101,
          12'b010000110110,
          12'b010100110110: add_sel = `ADD_ALU;
          12'b000011000100: add_sel = ( !zero_bit) ? `ADD_ALU : `ADD_PC;
          12'b000011001100: add_sel = (  zero_bit) ? `ADD_ALU : `ADD_PC;
          12'b000011010100: add_sel = (!carry_bit) ? `ADD_ALU : `ADD_PC;
          12'b000011011100: add_sel = ( carry_bit) ? `ADD_ALU : `ADD_PC;
          12'b000011100100: add_sel = (  !par_bit) ? `ADD_ALU : `ADD_PC;
          12'b000011101100: add_sel = (   par_bit) ? `ADD_ALU : `ADD_PC;
          12'b000011110100: add_sel = ( !sign_bit) ? `ADD_ALU : `ADD_PC;
          12'b000011111100: add_sel = (  sign_bit) ? `ADD_ALU : `ADD_PC;
          default:          add_sel = `ADD_PC;
        endcase
      end
      `IF3A:                add_sel = `ADD_ALU;
      `ADR1: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01110100,
          12'b1xxx00xxx000,
          12'b1xxx00xxx001: add_sel = `ADD_ALU8;
          default:          add_sel = `ADD_ALU;
        endcase
      end
      `RD1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx100xx011: add_sel = `ADD_ALU8;
          default:          add_sel = `ADD_ALU;
        endcase
      end
      `RD2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011100011,
          12'b0001xxxxxxxx,
          12'b010000110100,
          12'b010000110101,
          12'b010011100011,
          12'b010100110100,
          12'b010100110101,
          12'b010111100011,
          12'b011000000110,
          12'b011000001110,
          12'b011000010110,
          12'b011000011110,
          12'b011000100110,
          12'b011000101110,
          12'b011000110110,
          12'b011000111110,
          12'b011010xxx110,
          12'b011011xxx110,
          12'b011100000110,
          12'b011100001110,
          12'b011100010110,
          12'b011100011110,
          12'b011100100110,
          12'b011100101110,
          12'b011100110110,
          12'b011100111110,
          12'b011110xxx110,
          12'b011111xxx110,
          12'b1xxx10000010,
          12'b1xxx10001010,
          12'b1xxx10010010,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011100,
          12'b1xxx10100000,
          12'b1xxx10100001,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101000,
          12'b1xxx10101001,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110000,
          12'b1xxx10110001,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111001,
          12'b1xxx10111010,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011: add_sel = `ADD_ALU;
          12'b1xxx100xx011: add_sel = `ADD_ALU8;
          12'b000000110100,
          12'b000000110101,
          12'b000000xxx100,
          12'b000000xxx101,
          12'b001000000110,
          12'b001000000xxx,
          12'b001000001110,
          12'b001000001xxx,
          12'b001000010110,
          12'b001000010xxx,
          12'b001000011110,
          12'b001000011xxx,
          12'b001000100110,
          12'b001000100xxx,
          12'b001000101110,
          12'b001000101xxx,
          12'b001000110110,
          12'b001000110xxx,
          12'b001000111110,
          12'b001000111xxx,
          12'b001010xxx110,
          12'b001010xxxxxx,
          12'b001011xxx110,
          12'b001011xxxxxx,
          12'b1xxx01100111,
          12'b1xxx01101111: add_sel = `ADD_HL;
          default:          add_sel = `ADD_PC;
        endcase
      end
      `WR1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10010010,
          12'b1xxx10011010: add_sel = `ADD_ALU8;
          12'b1xxx10000010,
          12'b1xxx10000011,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001011,
          12'b1xxx10001100,
          12'b1xxx10100000,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10100100,
          12'b1xxx10101000,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10101100: add_sel = `ADD_PC;
          default:          add_sel = `ADD_ALU;
        endcase
      end
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011001101,
          12'b000011xxx100,
          12'b000011xxx111,
          12'b0001xxxxxxxx,
          12'b1xxx10000011,
          12'b1xxx10001011,
          12'b1xxx10010011,
          12'b1xxx10010100,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10100000,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101000,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110000,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111010,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011: add_sel = `ADD_ALU;
          12'b1xxx10000010,
          12'b1xxx10001010,
          12'b1xxx10010010,
          12'b1xxx10011010: add_sel = `ADD_ALU8;
          default:          add_sel = `ADD_PC;
        endcase
      end
      `BLK1: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10110001,
          12'b1xxx10111001: add_sel = `ADD_ALU;
          default:          add_sel = `ADD_PC;
        endcase
      end
      `PCA: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000010000,
          12'b000000011000,
          12'b0000001xx000,
          12'b000011000011,
          12'b000011001001,
          12'b000011xxx000,
          12'b000011xxx010,
          12'b1xxx01000101,
          12'b1xxx01001101: add_sel = `ADD_PC;
          default:          add_sel = `ADD_ALU;
        endcase
      end
      `IF1A:                add_sel = `ADD_PC;
      `INTA:                add_sel = (vector_int) ? `ADD_PC : `ADD_ALU;
      `HLTA:                add_sel = `ADD_PC;
      `DMA1:                add_sel = `ADD_PC;
      default:              add_sel = `ADD_RSTVAL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  program counter control                                                              */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or par_bit or sign_bit or
            tflg_reg or zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1: begin
        casex (inst_reg) //synopsys parallel_case
          8'b00000000,
          8'b00000111,
          8'b00001000,
          8'b00001111,
          8'b00010111,
          8'b00011111,
          8'b00100111,
          8'b00101111,
          8'b00110111,
          8'b00111111,
          8'b000xx10x,
          8'b0010x10x,
          8'b0011110x,
          8'b00xx0011,
          8'b00xx1001,
          8'b00xx1011,
          8'b010xx0xx,
          8'b0110x0xx,
          8'b011110xx,
          8'b010xx10x,
          8'b0110x10x,
          8'b0111110x,
          8'b010xx111,
          8'b0110x111,
          8'b01111111,
          8'b10xxx0xx,
          8'b10xxx10x,
          8'b10xxx111,
          8'b11011001,
          8'b11101011,
          8'b11111001,
          8'b11111011:      pc_sel = `PC_NILD;
          8'b01110110,
          8'b11xxx111,
          8'b00000010,
          8'b00001010,
          8'b00010010,
          8'b00011010,
          8'b00110100,
          8'b00110101,
          8'b011100xx,
          8'b0111010x,
          8'b01110111,
          8'b010xx110,
          8'b0110x110,
          8'b01111110,
          8'b10000110,
          8'b10001110,
          8'b10010110,
          8'b10011110,
          8'b10100110,
          8'b10101110,
          8'b10110110,
          8'b10111110,
          8'b11xx0001,
          8'b11xx0101,
          8'b11100011:      pc_sel = `PC_NUL;
          default:          pc_sel = `PC_LD;
          endcase
        end
      `DEC2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b001000000110,
          12'b001000001110,
          12'b001000010110,
          12'b001000011110,
          12'b001000100110,
          12'b001000101110,
          12'b001000110110,
          12'b001000111110,
          12'b001001xxx110,
          12'b001010xxx110,
          12'b001011xxx110,
          12'b010011100001,
          12'b010011100011,
          12'b010011100101,
          12'b010111100001,
          12'b010111100011,
          12'b010111100101,
          12'b1xxx00110100,
          12'b1xxx00110110,
          12'b1xxx00110111,
          12'b1xxx00111110,
          12'b1xxx00111111,
          12'b1xxx00xx0111,
          12'b1xxx00xx1111,
          12'b1xxx01100111,
          12'b1xxx01101111,
          12'b1xxx01110110,
          12'b1xxx01xxx000,
          12'b1xxx01xxx001,
          12'b1xxx10000010,
          12'b1xxx10000011,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001011,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010011,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10100000,
          12'b1xxx10100001,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10100100,
          12'b1xxx10101000,
          12'b1xxx10101001,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10101100,
          12'b1xxx10110000,
          12'b1xxx10110001,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111001,
          12'b1xxx10111010,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011: pc_sel = `PC_NUL;
          12'b010000100001,
          12'b010000100010,
          12'b010000100110,
          12'b010000101010,
          12'b010000101110,
          12'b010000110001,
          12'b010000110100,
          12'b010000110101,
          12'b010000110110,
          12'b010000110111,
          12'b010000111110,
          12'b010000111111,
          12'b010000xx0111,
          12'b010000xx1111,
          12'b010001110xxx,
          12'b010001xxx110,
          12'b010010000110,
          12'b010010001110,
          12'b010010010110,
          12'b010010011110,
          12'b010010100110,
          12'b010010101110,
          12'b010010110110,
          12'b010010111110,
          12'b010011101001,
          12'b010100100001,
          12'b010100100010,
          12'b010100100110,
          12'b010100101010,
          12'b010100101110,
          12'b010100110001,
          12'b010100110100,
          12'b010100110101,
          12'b010100110110,
          12'b010100110111,
          12'b010100111110,
          12'b010100111111,
          12'b010100xx0111,
          12'b010100xx1111,
          12'b010101110xxx,
          12'b010101xxx110,
          12'b010110000110,
          12'b010110001110,
          12'b010110010110,
          12'b010110011110,
          12'b010110100110,
          12'b010110101110,
          12'b010110110110,
          12'b010110111110,
          12'b010111101001,
          12'b010011001011, //DD+CB prefix
          12'b010111001011, //FD+CB prefix
          12'b1xxx00110010,
          12'b1xxx00110011,
          12'b1xxx00xx0010,
          12'b1xxx00xx0011,
          12'b1xxx00xxx000,
          12'b1xxx00xxx001,
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b1xxx01010100,
          12'b1xxx01010101,
          12'b1xxx01100100,
          12'b1xxx01100101,
          12'b1xxx01100110,
          12'b1xxx01110100,
          12'b1xxx01xx1011,
          12'b1xxx01xx0011: pc_sel = `PC_LD;
          default:          pc_sel = `PC_NILD;
        endcase
      end
      `OF2A,
      `IF3A: pc_sel = `PC_LD;
      `RD1B,
      `RD2B: pc_sel = `PC_INT;
      `WR2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011001101,
          12'b000011xxx100,
          12'b000011xxx111,
          12'b0001xxxxxxxx: pc_sel = `PC_LD;
          default:          pc_sel = `PC_NUL;
        endcase
      end
      `PCA: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000010000: pc_sel = (tflg_reg) ? `PC_NUL : `PC_LD;
          12'b000000011000,
          12'b0000001xx000,
          12'b000011000011,
          12'b000011001001,
          12'b000011xxx000,
          12'b000011xxx010,
          12'b1xxx01000101,
          12'b1xxx01001101: pc_sel = `PC_LD;
          default:          pc_sel = `PC_NUL;
        endcase
      end
      `PCO: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011101001,
          12'b010011101001,
          12'b010111101001,
          12'b1xxx10010010,
          12'b1xxx10010011,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10110000,
          12'b1xxx10110001,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111001,
          12'b1xxx10111010,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011: pc_sel = `PC_LD;
          default:          pc_sel = `PC_NUL;
        endcase
      end
      `IF1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b0001xxxxxxxx,
          12'b1xxx01000101,
          12'b1xxx01001101: pc_sel = `PC_LD;
          12'b1xxx10010010,
          12'b1xxx10010011,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10110000,
          12'b1xxx10110001,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111001,
          12'b1xxx10111010,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011: pc_sel = `PC_NILD2;
          default:          pc_sel = `PC_NILD;
          endcase
        end
      `HLTA:                pc_sel = `PC_INT;
      `DMA1:                pc_sel = `PC_DMA;
      default:              pc_sel = `PC_NUL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  interrupt ack and dma ack                                                            */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `IF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b000011110011,
          12'b0001xxxxxxxx: ld_inta = 1'b0;
          default:          ld_inta = 1'b1;
          endcase
        end
      default:              ld_inta = 1'b0;
      endcase
    end

  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `IF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b000011110011,
          12'b0001xxxxxxxx: ld_dmaa = 1'b0;
          default:          ld_dmaa = 1'b1;
          endcase
        end
      `HLTB,
      `DMA2:                ld_dmaa = 1'b1;
      default:              ld_dmaa = 1'b0;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  data input register control                                                          */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `OF1B:                di_ctl = `DI_DI10;
      `OF2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b010000110110,
          12'b010100110110: di_ctl = `DI_DI0;
          default:          di_ctl = `DI_DI1;
          endcase
        end
      `RD1B:                di_ctl = `DI_DI0;
      `RD2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000101010,
          12'b000011001001,
          12'b000011100011,
          12'b000011xxx000,
          12'b000011xx0001,
          12'b0001xxxxxxxx,
          12'b010000101010,
          12'b010000110001,
          12'b010000110111,
          12'b010000xx0111,
          12'b010011100001,
          12'b010011100011,
          12'b010100101010,
          12'b010100110001,
          12'b010100110111,
          12'b010100xx0111,
          12'b010111100001,
          12'b010111100011,
          12'b1xxx00110110,
          12'b1xxx00110111,
          12'b1xxx00xx0111,
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b1xxx01xx1011: di_ctl = `DI_DI1;
          default:          di_ctl = `DI_DI0;
          endcase
        end
      `INTB:                di_ctl = `DI_DI0;
      default:              di_ctl = `DI_NUL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  data output register control                                                         */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `WR1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011001101,
          12'b000011xxx100,
          12'b000011xx0101,
          12'b000011xxx111,
          12'b0001xxxxxxxx,
          12'b010011100101,
          12'b010111100101,
          12'b1xxx01100101,
          12'b1xxx01100110: do_ctl = `DO_MSB;
          12'b1xxx10000011,
          12'b1xxx10001011,
          12'b1xxx10010011,
          12'b1xxx10011011,
          12'b1xxx10100011,
          12'b1xxx10100100,
          12'b1xxx10101011,
          12'b1xxx10101100,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000011,
          12'b1xxx11001011: do_ctl = `DO_IO;
          default:          do_ctl = `DO_LSB;
          endcase
        end
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000100010,
          12'b000011100011,
          12'b010000100010,
          12'b010000111110,
          12'b010000111111,
          12'b010000xx1111,
          12'b010011100011,
          12'b010100100010,
          12'b010100111110,
          12'b010100111111,
          12'b010100xx1111,
          12'b010111100011,
          12'b1xxx00111110,
          12'b1xxx00111111,
          12'b1xxx00xx1111,
          12'b1xxx01xx0011: do_ctl = `DO_MSB;
          12'b000011010011,
          12'b1xxx00xxx001,
          12'b1xxx01xxx001,
          12'b1xxx10000011,
          12'b1xxx10001011,
          12'b1xxx10010011,
          12'b1xxx10011011,
          12'b1xxx10100011,
          12'b1xxx10101011,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx11000011,
          12'b1xxx11001011,
          12'b1xxx10111011: do_ctl = `DO_IO;
          default:          do_ctl = `DO_LSB;
          endcase
        end
      default:              do_ctl = `DO_NUL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  alu operation control                                                                */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or par_bit or sign_bit or
            zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1: begin
        casex (inst_reg) //synopsys parallel_case
          8'b00xx0011,
          8'b00xx1001,
          8'b00xx1011,
          8'b11100011,
          8'b11xx0101,
          8'b11xxx111:      aluop_sel = `ALUOP_ADD;
          8'b10001xxx:      aluop_sel = `ALUOP_BADC;
          8'b00010000,
          8'b00xxx100,
          8'b10000xxx:      aluop_sel = `ALUOP_BADD;
          8'b10100xxx:      aluop_sel = `ALUOP_BAND;
          8'b00xxx101:      aluop_sel = `ALUOP_BDEC;
          8'b10110xxx:      aluop_sel = `ALUOP_BOR;
          8'b10011xxx:      aluop_sel = `ALUOP_BSBC;
          8'b10010xxx,
          8'b10111xxx:      aluop_sel = `ALUOP_BSUB;
          8'b00101111,
          8'b10101xxx:      aluop_sel = `ALUOP_BXOR;
          8'b00111111:      aluop_sel = `ALUOP_CCF;
          8'b00100111:      aluop_sel = `ALUOP_DAA;
          8'b00010111:      aluop_sel = `ALUOP_RLA;
          8'b00000111:      aluop_sel = `ALUOP_RLCA;
          8'b00011111:      aluop_sel = `ALUOP_RRA;
          8'b00001111:      aluop_sel = `ALUOP_RRCA;
          8'b00110111:      aluop_sel = `ALUOP_SCF;
          default:          aluop_sel = `ALUOP_PASS;
          endcase
        end
      `IF2B:                aluop_sel = `ALUOP_ADD;
      `DEC2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01xx1010:  aluop_sel = `ALUOP_ADC;
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b010000100011,
          12'b010000101011,
          12'b010000xx1001,
          12'b010011100101,
          12'b010100100011,
          12'b010100101011,
          12'b010100xx1001,
          12'b010111100101: aluop_sel = `ALUOP_ADD;
          12'b1xxx01010111,
          12'b1xxx01011111: aluop_sel = `ALUOP_APAS;
          12'b010010001100,
          12'b010010001101,
          12'b010110001100,
          12'b010110001101: aluop_sel = `ALUOP_BADC;
          12'b010010000100,
          12'b010010000101,
          12'b010110000100,
          12'b010110000101,
          12'b010000100100,
          12'b010000101100,
          12'b010100100100,
          12'b010100101100: aluop_sel = `ALUOP_BADD;
          12'b010010100100,
          12'b010010100101,
          12'b010110100100,
          12'b010110100101,
          12'b001001xxxxxx,
          12'b001010xxxxxx,
          12'b1xxx00xxx100: aluop_sel = `ALUOP_BAND;
          12'b010000100101,
          12'b010000101101,
          12'b010100100101,
          12'b010100101101: aluop_sel = `ALUOP_BDEC;
          12'b010010110100,
          12'b010010110101,
          12'b010110110100,
          12'b010110110101,
          12'b001011xxxxxx: aluop_sel = `ALUOP_BOR;
          12'b010010011100,
          12'b010010011101,
          12'b010110011100,
          12'b010110011101: aluop_sel = `ALUOP_BSBC;
          12'b010010111100,
          12'b010010111101,
          12'b010110111100,
          12'b010110111101,
          12'b010010010100,
          12'b010010010101,
          12'b010110010100,
          12'b010110010101,
          12'b1xxx01000100: aluop_sel = `ALUOP_BSUB;
          12'b010010101100,
          12'b010010101101,
          12'b010110101100,
          12'b010110101101: aluop_sel = `ALUOP_BXOR;
          12'b1xxx01xx1100: aluop_sel = `ALUOP_MLT;
          12'b001000010xxx: aluop_sel = `ALUOP_RL;
          12'b001000000xxx: aluop_sel = `ALUOP_RLC;
          12'b001000011xxx: aluop_sel = `ALUOP_RR;
          12'b001000001xxx: aluop_sel = `ALUOP_RRC;
          12'b1xxx01xx0010: aluop_sel = `ALUOP_SBC;
          12'b001000100xxx: aluop_sel = `ALUOP_SLA;
          12'b001000110xxx: aluop_sel = `ALUOP_SLL;
          12'b001000101xxx: aluop_sel = `ALUOP_SRA;
          12'b001000111xxx: aluop_sel = `ALUOP_SRL;
          default:          aluop_sel = `ALUOP_PASS;
        endcase
      end
      `OF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000100000: aluop_sel = ( !zero_bit) ? `ALUOP_ADS : `ALUOP_ADD;
          12'b000000101000: aluop_sel = (  zero_bit) ? `ALUOP_ADS : `ALUOP_ADD;
          12'b000000110000: aluop_sel = (!carry_bit) ? `ALUOP_ADS : `ALUOP_ADD;
          12'b000000111000: aluop_sel = ( carry_bit) ? `ALUOP_ADS : `ALUOP_ADD;
          12'b000000010000,
          12'b000000011000: aluop_sel = `ALUOP_ADS;
          12'b1xxx01110100,
          12'b000000110110: aluop_sel = `ALUOP_PASS;
          default:          aluop_sel = `ALUOP_ADD;
        endcase
      end
      `OF2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b010000110110,
          12'b010100110110: aluop_sel = `ALUOP_ADS;
          default:          aluop_sel = `ALUOP_ADD;
        endcase
      end
      `OF2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000xx0001,
          12'b010000100001,
          12'b010100100001: aluop_sel = `ALUOP_ADD;
          12'b000011000010,
          12'b000011000100: aluop_sel = ( !zero_bit) ? `ALUOP_PASS : `ALUOP_ADD;
          12'b000011001010,
          12'b000011001100: aluop_sel = (  zero_bit) ? `ALUOP_PASS : `ALUOP_ADD;
          12'b000011010010,
          12'b000011010100: aluop_sel = (!carry_bit) ? `ALUOP_PASS : `ALUOP_ADD;
          12'b000011011010,
          12'b000011011100: aluop_sel = ( carry_bit) ? `ALUOP_PASS : `ALUOP_ADD;
          12'b000011100010,
          12'b000011100100: aluop_sel = (  !par_bit) ? `ALUOP_PASS : `ALUOP_ADD;
          12'b000011101010,
          12'b000011101100: aluop_sel = (   par_bit) ? `ALUOP_PASS : `ALUOP_ADD;
          12'b000011110010,
          12'b000011110100: aluop_sel = ( !sign_bit) ? `ALUOP_PASS : `ALUOP_ADD;
          12'b000011111010,
          12'b000011111100: aluop_sel = (  sign_bit) ? `ALUOP_PASS : `ALUOP_ADD;
          default:          aluop_sel = `ALUOP_PASS;
        endcase
      end
      `IF3A:                aluop_sel = `ALUOP_ADS;
      `ADR1: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01100101,
          12'b1xxx01100110: aluop_sel = `ALUOP_ADD;
          12'b000000100010,
          12'b000000101010,
          12'b000000110010,
          12'b000000111010,
          12'b000011010011,
          12'b000011011011,
          12'b0001xxxxxxxx,
          12'b010000100010,
          12'b010000101010,
          12'b010100100010,
          12'b010100101010,
          12'b1xxx00xxx000,
          12'b1xxx00xxx001,
          12'b1xxx01110100,
          12'b1xxx01xx1011,
          12'b1xxx01xx0011: aluop_sel = `ALUOP_PASS;
          default:          aluop_sel = `ALUOP_ADS;
        endcase
      end
      `ADR2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10010100,
          12'b1xxx10011100,
          12'b1xxx10100000,
          12'b1xxx10100001,
          12'b1xxx10101000,
          12'b1xxx10101001,
          12'b1xxx10110000,
          12'b1xxx10110001,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111001,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011: aluop_sel = `ALUOP_ADD;
          12'b1xxx01100101,
          12'b1xxx01100110: aluop_sel = `ALUOP_ADS;
          12'b1xxx10000010,
          12'b1xxx10000011,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001011,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010011,
          12'b1xxx10011010,
          12'b1xxx10011011,
          12'b1xxx10100010,
          12'b1xxx10101010,
          12'b1xxx10110010,
          12'b1xxx10111010: aluop_sel = `ALUOP_BADD;
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b1xxx10100011,
          12'b1xxx10101011,
          12'b1xxx10110011,
          12'b1xxx10111011: aluop_sel = `ALUOP_BAND;
          default:          aluop_sel = `ALUOP_PASS;
        endcase
      end
      `RD1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000101010,
          12'b000011001001,
          12'b000011100011,
          12'b000011xxx000,
          12'b000011xx0001,
          12'b0001xxxxxxxx,
          12'b010000101010,
          12'b010000110001,
          12'b010000110111,
          12'b010000xx0111,
          12'b010011100001,
          12'b010011100011,
          12'b010100101010,
          12'b010100110001,
          12'b010100110111,
          12'b010100xx0111,
          12'b010111100001,
          12'b010111100011,
          12'b1xxx00110110,
          12'b1xxx00110111,
          12'b1xxx00xx0111,
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b1xxx01xx1011: aluop_sel = `ALUOP_ADD;
          default:          aluop_sel = `ALUOP_PASS;
        endcase
      end
      `RD1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10111010,
          12'b1xxx10111011: aluop_sel = `ALUOP_BAND;
          12'b1xxx10100001,
          12'b1xxx10101001,
          12'b1xxx10110001,
          12'b1xxx10111001: aluop_sel = `ALUOP_BSUB;
          default:          aluop_sel = `ALUOP_PASS;
        endcase
      end
      `RD2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011001001,
          12'b000011xxx000,
          12'b000011xx0001,
          12'b0001xxxxxxxx,
          12'b010011100001,
          12'b010111100001,
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011100,
          12'b1xxx10100000,
          12'b1xxx10100010,
          12'b1xxx10100100,
          12'b1xxx10101000,
          12'b1xxx10101010,
          12'b1xxx10101100,
          12'b1xxx10110000,
          12'b1xxx10110010,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111010,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11001010: aluop_sel = `ALUOP_ADD;
          12'b1xxx10000011,
          12'b1xxx10001011,
          12'b1xxx10010011,
          12'b1xxx10011011: aluop_sel = `ALUOP_BADD;
          default:          aluop_sel = `ALUOP_PASS;
        endcase
      end
      `RD2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000110100,
          12'b000000xxx100,
          12'b010000110100,
          12'b010100110100: aluop_sel = `ALUOP_BADD;
          12'b001010xxx110,
          12'b001010xxxxxx,
          12'b011010xxx110,
          12'b011110xxx110,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10111010,
          12'b1xxx10111011: aluop_sel = `ALUOP_BAND;
          12'b000000110101,
          12'b000000xxx101,
          12'b010000110101,
          12'b010100110101: aluop_sel = `ALUOP_BDEC;
          12'b001011xxx110,
          12'b001011xxxxxx,
          12'b011011xxx110,
          12'b011111xxx110: aluop_sel = `ALUOP_BOR;
          12'b1xxx10100001,
          12'b1xxx10101001,
          12'b1xxx10110001,
          12'b1xxx10111001: aluop_sel = `ALUOP_BSUB;
          12'b000011001001,
          12'b000011100011,
          12'b000011xxx000,
          12'b0001xxxxxxxx,
          12'b010011100011,
          12'b010111100011,
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b1xxx10000010,
          12'b1xxx10000011,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001011,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010011,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10100000,
          12'b1xxx10100100,
          12'b1xxx10101000,
          12'b1xxx10101100,
          12'b1xxx10110000,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011: aluop_sel = `ALUOP_PASS;
          12'b0x1x00000xxx: aluop_sel = `ALUOP_RLC;
          12'b0x1x00001xxx: aluop_sel = `ALUOP_RRC;
          12'b0x1x00010xxx: aluop_sel = `ALUOP_RL;
          12'b0x1x00011xxx: aluop_sel = `ALUOP_RR;
          12'b0x1x00100xxx: aluop_sel = `ALUOP_SLA;
          12'b0x1x00101xxx: aluop_sel = `ALUOP_SRA;
          12'b0x1x00110xxx: aluop_sel = `ALUOP_SLL;
          12'b0x1x00111xxx: aluop_sel = `ALUOP_SRL;
          12'b1xxx01101111: aluop_sel = `ALUOP_RLD1;
          12'b1xxx01100111: aluop_sel = `ALUOP_RRD1;
          default:          aluop_sel = `ALUOP_ADD;
        endcase
      end
      `WR1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100010,
          12'b1xxx10101010,
          12'b1xxx10110010,
          12'b1xxx10111010,
          12'b1xxx11000010,
          12'b1xxx11001010: aluop_sel = `ALUOP_PASS;
          12'b1xxx10100100,
          12'b1xxx10101100: aluop_sel = `ALUOP_BADD;
          default:          aluop_sel = `ALUOP_ADD;
        endcase
      end
      `WR1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10011011,
          12'b1xxx10010011,
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010100,
          12'b1xxx10011100,
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011,
          12'b1xxx10100000,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101000,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110000,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx10111000: aluop_sel = `ALUOP_ADD;
          12'b1xxx10001011,
          12'b1xxx10000011,
          12'b1xxx10010010,
          12'b1xxx10011010,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10111010,
          12'b1xxx10111011: aluop_sel = `ALUOP_BADD;
          default:          aluop_sel = `ALUOP_PASS;
        endcase
      end
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx100xx011,
          12'b1xxx10010100,
          12'b1xxx10011100,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx11000011,
          12'b1xxx11001011,
          12'b1xxx10100000,
          12'b1xxx10100011,
          12'b1xxx10101000,
          12'b1xxx10101011,
          12'b1xxx10110000,
          12'b1xxx10110011,
          12'b1xxx10111000,
          12'b1xxx10111011: aluop_sel = `ALUOP_ADD;
          12'b000011xxx111,
          12'b0001xxxxxxxx: aluop_sel = `ALUOP_APAS;
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10011010,
          12'b1xxx10100100,
          12'b1xxx10101100: aluop_sel = `ALUOP_BADD;
          default:          aluop_sel = `ALUOP_PASS;
        endcase
      end
      `WR2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx100xx011,
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10011010,
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10111010,
          12'b1xxx10111011: aluop_sel = `ALUOP_BADD;
          default:          aluop_sel = `ALUOP_ADD;
        endcase
      end
      `PCA,
      `PCO:                 aluop_sel = `ALUOP_ADD;
      `IF1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011100,
          12'b1xxx10100000,
          12'b1xxx10100010,
          12'b1xxx10101000,
          12'b1xxx10101010,
          12'b1xxx10110000,
          12'b1xxx10110010,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111010,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011: aluop_sel = `ALUOP_ADD;
          12'b1xxx00011010,
          12'b1xxx01010100,
          12'b1xxx01010101,
          12'b1xxx00110010,
          12'b1xxx00110011,
          12'b1xxx00xx0010,
          12'b1xxx00xx0011: aluop_sel = `ALUOP_ADS;
          12'b000010001xxx,
          12'b000011001110,
          12'b010x10001110: aluop_sel = `ALUOP_BADC;
          12'b000010000xxx,
          12'b000011000110,
          12'b010x10000110,
          12'b1xxx100xx011,
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b1xxx10100011,
          12'b1xxx10101011,
          12'b1xxx10110011,
          12'b1xxx10111011: aluop_sel = `ALUOP_BADD;
          12'b000010100xxx,
          12'b0x1x01xxxxxx,
          12'b010x10100110,
          12'b000011100110,
          12'b1xxx00110100,
          12'b1xxx00xxx000,
          12'b1xxx011x0100,
          12'b1xxx01xxx000: aluop_sel = `ALUOP_BAND;
          12'b000010110xxx,
          12'b010x10110110,
          12'b000011110110: aluop_sel = `ALUOP_BOR;
          12'b000010011xxx,
          12'b010x10011110,
          12'b000011011110: aluop_sel = `ALUOP_BSBC;
          12'b000010010xxx,
          12'b000010111xxx,
          12'b000011010110,
          12'b010x10010110,
          12'b010x10111110,
          12'b000011111110: aluop_sel = `ALUOP_BSUB;
          12'b000010101xxx,
          12'b010x10101110,
          12'b000011101110: aluop_sel = `ALUOP_BXOR;
          12'b1xxx01101111: aluop_sel = `ALUOP_RLD2;
          12'b1xxx01100111: aluop_sel = `ALUOP_RRD2;
          default:          aluop_sel = `ALUOP_PASS;
          endcase
        end
      `INTB:                aluop_sel = `ALUOP_PASS;
      default:              aluop_sel = `ALUOP_ADD;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  alu a input control                                                                  */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or par_bit or sign_bit or
            tflg_reg or zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1: begin
        casex (inst_reg) //synopsys parallel_case
          8'b10000xxx,
          8'b10001xxx,
          8'b10010xxx,
          8'b10011xxx,
          8'b10100xxx,
          8'b10101xxx,
          8'b10110xxx,
          8'b10111xxx:      alua_sel = `ALUA_AA;
          8'b00100111:      alua_sel = `ALUA_DAA;
          8'b00xx1001:      alua_sel = `ALUA_HL;
          8'b00010000,
          8'b00101111,
          8'b00xxx101,
          8'b00xx1011,
          8'b11xx0101,
          8'b11xxx111:      alua_sel = `ALUA_M1;
          default:          alua_sel = `ALUA_ONE;
          endcase
        end
      `DEC2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b001001xxxxxx,
          12'b001010xxxxxx,
          12'b001011xxxxxx: alua_sel = `ALUA_BIT;
          12'b1xxx01xx0010,
          12'b1xxx01xx1010: alua_sel = `ALUA_HL;
          12'b1xxx01010111: alua_sel = `ALUA_II;
          12'b010000xx1001: alua_sel = `ALUA_IX;
          12'b010100xx1001: alua_sel = `ALUA_IY;
          12'b010000100101,
          12'b010000101011,
          12'b010000101101,
          12'b010011100101,
          12'b010100100101,
          12'b010100101011,
          12'b010100101101,
          12'b1xxx10101100,
          12'b010111100101: alua_sel = `ALUA_M1;
          12'b1xxx10100100,
          12'b010000100100,
          12'b010000101100,
          12'b010000100011,
          12'b010100100100,
          12'b010100101100,
          12'b010100100011: alua_sel = `ALUA_ONE;
          12'b1xxx01011111: alua_sel = `ALUA_RR;
          12'b1xxx01000100: alua_sel = `ALUA_ZER;
          default:          alua_sel = `ALUA_AA;
        endcase
      end
      `OF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000100000: alua_sel = ( !zero_bit) ? `ALUA_PC : `ALUA_ONE;
          12'b000000101000: alua_sel = (  zero_bit) ? `ALUA_PC : `ALUA_ONE;
          12'b000000110000: alua_sel = (!carry_bit) ? `ALUA_PC : `ALUA_ONE;
          12'b000000111000: alua_sel = ( carry_bit) ? `ALUA_PC : `ALUA_ONE;
          12'b000000010000,
          12'b000000011000: alua_sel = `ALUA_PC;
          default:          alua_sel = `ALUA_ONE;
        endcase
      end
      `OF2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b010000110110: alua_sel = `ALUA_IX;
          12'b010100110110: alua_sel = `ALUA_IY;
          default:          alua_sel = `ALUA_M1;
        endcase
      end
      `IF3A:                alua_sel = (page_reg[0]) ? `ALUA_IY : `ALUA_IX;
      `ADR1: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011010011: alua_sel = `ALUA_M1;
          12'b1xxx01100101,
          12'b1xxx01100110: alua_sel = `ALUA_M1;
          default:          alua_sel = (page_reg[0]) ? `ALUA_IY : `ALUA_IX;
        endcase
      end
      `ADR2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01100101: alua_sel = `ALUA_IX;
          12'b1xxx01100110: alua_sel = `ALUA_IY;
          default:          alua_sel = `ALUA_M1;
        endcase
      end
      `RD1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100001,
          12'b1xxx10101001,
          12'b1xxx10110001,
          12'b1xxx10111001: alua_sel = `ALUA_AA;
          default:          alua_sel = `ALUA_M1;
        endcase
      end
      `RD2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b0001xxxxxxxx,
          12'b1xxx10001010,
          12'b1xxx10001011,
          12'b1xxx10001100,
          12'b1xxx10011010,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10101000,
          12'b1xxx10101010,
          12'b1xxx10101100,
          12'b1xxx10111000,
          12'b1xxx10111010,
          12'b1xxx10111100,
          12'b1xxx11001010,
          12'b1xxx11001011: alua_sel = `ALUA_M1;
          default:          alua_sel = `ALUA_ONE;
        endcase
      end
      `RD2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01100111,
          12'b1xxx01101111,
          12'b1xxx10100001,
          12'b1xxx10101001,
          12'b1xxx10110001,
          12'b1xxx10111001: alua_sel = `ALUA_AA;
          12'b0x1x1xxxxxxx: alua_sel = `ALUA_BIT;
          12'b000000xxx101,
          12'b010000110101,
          12'b010100110101,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10111010,
          12'b1xxx10111011: alua_sel = `ALUA_M1;
          default:          alua_sel = `ALUA_ONE;
        endcase
      end
      `WR1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011001101,
          12'b000011xxx100,
          12'b000011xx0101,
          12'b000011xxx111,
          12'b0001xxxxxxxx,
          12'b010011100101,
          12'b010111100101,
          12'b1xxx01100101,
          12'b1xxx01100110,
          12'b1xxx10001010,
          12'b1xxx10001011,
          12'b1xxx10001100,
          12'b1xxx10011010,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10101000,
          12'b1xxx10101011,
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b1xxx10111000,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11001010,
          12'b1xxx11001011: alua_sel = `ALUA_M1;
          default:          alua_sel = `ALUA_ONE;
        endcase
      end
      `WR1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10000010,
          12'b1xxx10000011,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001011,
          12'b1xxx10001100,
          12'b1xxx10100000,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10100100,
          12'b1xxx10101000,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10101100: alua_sel = `ALUA_ONE;
          default:          alua_sel = `ALUA_M1;
        endcase
      end
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b0001xxxxxxxx: alua_sel = `ALUA_INT;
          12'b1xxx10001010,
          12'b1xxx10001011,
          12'b1xxx10001100,
          12'b1xxx10011010,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10101000,
          12'b1xxx10101011,
          12'b1xxx10101100,
          12'b1xxx10111000,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11001010,
          12'b1xxx11001011: alua_sel = `ALUA_M1;
          12'b000011xxx111: alua_sel = `ALUA_RST;
          default:          alua_sel = `ALUA_ONE;
        endcase
      end
      `WR2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10000010,
          12'b1xxx10000011,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001011,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010011,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10100000,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10100100,
          12'b1xxx10101000,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10101100,
          12'b1xxx10110000,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10110100,
          12'b1xxx10111000,
          12'b1xxx10111010,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011: alua_sel = `ALUA_M1;
          default:          alua_sel = `ALUA_ONE;
        endcase
      end
      `BLK1: begin
        alua_sel = (inst_reg[3]) ? `ALUA_M1 : `ALUA_ONE;
      end
      `BLK2: begin
        alua_sel = (inst_reg[4]) ? `ALUA_M1 : `ALUA_ONE;
      end
      `PCA:                 alua_sel = (tflg_reg) ? `ALUA_ZER : `ALUA_M2;
      `IF1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b0x1x01xxxxxx: alua_sel = `ALUA_BIT;
          12'b1xxx00110010,
          12'b1xxx00xx0010,
          12'b1xxx01010101: alua_sel = `ALUA_IX;
          12'b1xxx00110011,
          12'b1xxx00xx0011,
          12'b1xxx01010100: alua_sel = `ALUA_IY;
          12'b1xxx00xxx000,
          12'b1xxx01xxx000,
          12'b1xxx10001010,
          12'b1xxx10001011,
          12'b1xxx10001100,
          12'b1xxx10011010,
          12'b1xxx10011011,
          12'b1xxx10011100,
          12'b1xxx10100011,
          12'b1xxx10101000,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10101100,
          12'b1xxx10110011,
          12'b1xxx10111000,
          12'b1xxx10111010,
          12'b1xxx10111011,
          12'b1xxx10111100,
          12'b1xxx11001010,
          12'b1xxx11001011: alua_sel = `ALUA_M1;
          12'b1xxx10000010,
          12'b1xxx10000011,
          12'b1xxx10000100,
          12'b1xxx10010010,
          12'b1xxx10010011,
          12'b1xxx10010100,
          12'b1xxx10100000,
          12'b1xxx10100010,
          12'b1xxx10100100,
          12'b1xxx10110000,
          12'b1xxx10110010,
          12'b1xxx10110100,
          12'b1xxx11000010,
          12'b1xxx11000011: alua_sel = `ALUA_ONE;
          12'b1xxx01110100: alua_sel = `ALUA_TMP;
          default:          alua_sel = `ALUA_AA;
          endcase
        end
      `INTA:                alua_sel = `ALUA_M1;
      default:              alua_sel = `ALUA_ONE;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  alu b input control                                                                  */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or par_bit or sign_bit or
            zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1: begin
        casex (inst_reg) //synopsys parallel_case
          8'b00000111,
          8'b00001111,
          8'b00010111,
          8'b00011111,
          8'b00100111,
          8'b00101111:      alub_sel = `ALUB_AA;
          8'b00010000:      alub_sel = `ALUB_BB;
          8'b00000010,
          8'b00001010:      alub_sel = `ALUB_BC;
          8'b00010010,
          8'b00011010,
          8'b11101011:      alub_sel = `ALUB_DE;
          8'b11101001,
          8'b11111001:      alub_sel = `ALUB_HL;
          8'b01xxx000,
          8'b10xxx000:      alub_sel = `ALUB_BB;
          8'b01xxx001,
          8'b10xxx001:      alub_sel = `ALUB_CC;
          8'b01xxx010,
          8'b10xxx010:      alub_sel = `ALUB_DD;
          8'b01xxx011,
          8'b10xxx011:      alub_sel = `ALUB_EE;
          8'b01xxx100,
          8'b10xxx100:      alub_sel = `ALUB_HH;
          8'b01xxx101,
          8'b10xxx101:      alub_sel = `ALUB_LL;
          8'b01xxx111,
          8'b10xxx111:      alub_sel = `ALUB_AA;
          8'b0000010x:      alub_sel = `ALUB_BB;
          8'b0000110x:      alub_sel = `ALUB_CC;
          8'b0001010x:      alub_sel = `ALUB_DD;
          8'b0001110x:      alub_sel = `ALUB_EE;
          8'b0010010x:      alub_sel = `ALUB_HH;
          8'b0010110x:      alub_sel = `ALUB_LL;
          8'b0011110x:      alub_sel = `ALUB_AA;
          8'b00000011,
          8'b00001001,
          8'b00001011:      alub_sel = `ALUB_BC;
          8'b00010011,
          8'b00011001,
          8'b00011011:      alub_sel = `ALUB_DE;
          8'b00100011,
          8'b00101001,
          8'b00101011:      alub_sel = `ALUB_HL;
          8'b00110011,
          8'b00111001,
          8'b00111011:      alub_sel = `ALUB_SP;
          8'b11xx0101,
          8'b11xxx111:      alub_sel = `ALUB_SP;
          default:          alub_sel = `ALUB_PC;
          endcase
        end
      `IF2B:                alub_sel = `ALUB_PC;
      `DEC2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01000100,
          12'b1xxx01000111,
          12'b1xxx01001111: alub_sel = `ALUB_AA;
          12'b1xxx01xxx000,
          12'b1xxx01xxx001,
          12'b1xxx10000100,
          12'b1xxx10001100,
          12'b1xxx10100010,
          12'b1xxx10101010,
          12'b1xxx10110010,
          12'b1xxx10111010: alub_sel = `ALUB_BC;
          12'b010000100011,
          12'b010000101011,
          12'b010011101001,
          12'b010011111001: alub_sel = `ALUB_IX;
          12'b010000100100,
          12'b010000100101,
          12'b0100010xx100,12'b01000110x100,12'b010001111100,
          12'b010010000100,
          12'b010010001100,
          12'b010010010100,
          12'b010010011100,
          12'b010010100100,
          12'b010010101100,
          12'b010010110100,
          12'b010010111100: alub_sel = `ALUB_IXH;
          12'b010100100100,
          12'b010100100101,
          12'b0101010xx100,12'b01010110x100,12'b010101111100,
          12'b010110000100,
          12'b010110001100,
          12'b010110010100,
          12'b010110011100,
          12'b010110100100,
          12'b010110101100,
          12'b010110110100,
          12'b010110111100: alub_sel = `ALUB_IYH;
          12'b010000101100,
          12'b010000101101,
          12'b0100010xx101,12'b01000110x101,12'b010001111101,
          12'b010010000101,
          12'b010010001101,
          12'b010010010101,
          12'b010010011101,
          12'b010010100101,
          12'b010010101101,
          12'b010010110101,
          12'b010010111101: alub_sel = `ALUB_IXL;
          12'b010100101100,
          12'b010100101101,
          12'b0101010xx101,12'b01010110x101,12'b010101111101,
          12'b010110000101,
          12'b010110001101,
          12'b010110010101,
          12'b010110011101,
          12'b010110100101,
          12'b010110101101,
          12'b010110110101,
          12'b010110111101: alub_sel = `ALUB_IYL;
          12'b010100100011,
          12'b010100101011,
          12'b010111101001,
          12'b010111111001: alub_sel = `ALUB_IY;
          12'b1xxx01000101,
          12'b1xxx01001101: alub_sel = `ALUB_PC;
          12'b010x0110x000,
          12'b1xxx00000100,
          12'b0010xxxxx000: alub_sel = `ALUB_BB;
          12'b010x0110x001,
          12'b1xxx00001100,
          12'b1xxx10000010,
          12'b1xxx10001010,
          12'b1xxx10010010,
          12'b1xxx10011010,
          12'b0010xxxxx001: alub_sel = `ALUB_CC;
          12'b010x0110x010,
          12'b1xxx00010100,
          12'b0010xxxxx010: alub_sel = `ALUB_DD;
          12'b010x0110x011,
          12'b1xxx00011100,
          12'b0010xxxxx011: alub_sel = `ALUB_EE;
          12'b1xxx00100100,
          12'b0010xxxxx100: alub_sel = `ALUB_HH;
          12'b1xxx00101100,
          12'b0010xxxxx101: alub_sel = `ALUB_LL;
          12'b010x0110x111,
          12'b1xxx00111100,
          12'b0010xxxxx111: alub_sel = `ALUB_AA;
          12'b1xxx01001100,
          12'b1xxx0100x010: alub_sel = `ALUB_BC;
          12'b1xxx01011100,
          12'b1xxx0101x010: alub_sel = `ALUB_DE;
          12'b1xxx01111100,
          12'b1xxx0111x010: alub_sel = `ALUB_SP;
          12'b010011100101,
          12'b010111100101: alub_sel = `ALUB_SP;
          12'b010x00001001: alub_sel = `ALUB_BC;
          12'b1xxx10010100,
          12'b1xxx10011100,
          12'b1xxx11000010,
          12'b1xxx11001010,
          12'b010x00011001: alub_sel = `ALUB_DE;
          12'b010000101001: alub_sel = `ALUB_IX;
          12'b010100101001: alub_sel = `ALUB_IY;
          12'b010x00111001: alub_sel = `ALUB_SP;
          default:          alub_sel = `ALUB_HL;
        endcase
      end
      `OF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01110100,
          12'b000000010000,
          12'b000000011000,
          12'b000000110110: alub_sel = `ALUB_DIN;
          12'b000000100000: alub_sel = ( !zero_bit) ? `ALUB_DIN : `ALUB_PC;
          12'b000000101000: alub_sel = (  zero_bit) ? `ALUB_DIN : `ALUB_PC;
          12'b000000110000: alub_sel = (!carry_bit) ? `ALUB_DIN : `ALUB_PC;
          12'b000000111000: alub_sel = ( carry_bit) ? `ALUB_DIN : `ALUB_PC;
          default:          alub_sel = `ALUB_PC;
        endcase
      end
      `OF2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b010000110110,
          12'b010100110110: alub_sel = `ALUB_DIN;
          default:          alub_sel = `ALUB_SP;
        endcase
      end
      `OF2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011000011,
          12'b010000110110,
          12'b010100110110: alub_sel = `ALUB_DIN;
          12'b000011000010: alub_sel = ( !zero_bit) ? `ALUB_DIN : `ALUB_PC;
          12'b000011001010: alub_sel = (  zero_bit) ? `ALUB_DIN : `ALUB_PC;
          12'b000011010010: alub_sel = (!carry_bit) ? `ALUB_DIN : `ALUB_PC;
          12'b000011011010: alub_sel = ( carry_bit) ? `ALUB_DIN : `ALUB_PC;
          12'b000011100010: alub_sel = (  !par_bit) ? `ALUB_DIN : `ALUB_PC;
          12'b000011101010: alub_sel = (   par_bit) ? `ALUB_DIN : `ALUB_PC;
          12'b000011110010: alub_sel = ( !sign_bit) ? `ALUB_DIN : `ALUB_PC;
          12'b000011111010: alub_sel = (  sign_bit) ? `ALUB_DIN : `ALUB_PC;
          12'b000011001101: alub_sel = `ALUB_PCH;
          12'b000011000100: alub_sel = ( !zero_bit) ? `ALUB_PCH : `ALUB_PC;
          12'b000011001100: alub_sel = (  zero_bit) ? `ALUB_PCH : `ALUB_PC;
          12'b000011010100: alub_sel = (!carry_bit) ? `ALUB_PCH : `ALUB_PC;
          12'b000011011100: alub_sel = ( carry_bit) ? `ALUB_PCH : `ALUB_PC;
          12'b000011100100: alub_sel = (  !par_bit) ? `ALUB_PCH : `ALUB_PC;
          12'b000011101100: alub_sel = (   par_bit) ? `ALUB_PCH : `ALUB_PC;
          12'b000011110100: alub_sel = ( !sign_bit) ? `ALUB_PCH : `ALUB_PC;
          12'b000011111100: alub_sel = (  sign_bit) ? `ALUB_PCH : `ALUB_PC;
          default:          alub_sel = `ALUB_PC;
        endcase
      end
      `IF3A:                alub_sel = `ALUB_DIN;
      `ADR1: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01110100: alub_sel = `ALUB_CC;
          12'b000011010011,
          12'b000011011011: alub_sel = `ALUB_IO;
          12'b1xxx01100101,
          12'b1xxx01100110: alub_sel = `ALUB_SP;
          12'b0001xxxxxxxx: alub_sel = `ALUB_TMP;
          default:          alub_sel = `ALUB_DIN;
        endcase
      end
      `ADR2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000000010,
          12'b000000010010,
          12'b000000110010,
          12'b000011010011: alub_sel = `ALUB_AA;
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10011010,
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b1xxx100xx011,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10111010,
          12'b1xxx10111011: alub_sel = `ALUB_BB;
          12'b1xxx10010100,
          12'b1xxx10011100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011,
          12'b1xxx10100000,
          12'b1xxx10100001,
          12'b1xxx10101000,
          12'b1xxx10101001,
          12'b1xxx10110000,
          12'b1xxx10110001,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx10111000,
          12'b1xxx10111001: alub_sel = `ALUB_BC;
          12'b1xxx01100101,
          12'b1xxx01100110: alub_sel = `ALUB_DIN;
          12'b010000100010: alub_sel = `ALUB_IX;
          12'b010011100101: alub_sel = `ALUB_IXH;
          12'b010000111111,
          12'b010100111110,
          12'b1xxx00111111: alub_sel = `ALUB_IXL;
          12'b010100100010: alub_sel = `ALUB_IY;
          12'b010111100101: alub_sel = `ALUB_IYH;
          12'b010000111110,
          12'b010100111111,
          12'b1xxx00111110: alub_sel = `ALUB_IYL;
          12'b000011xxx111: alub_sel = `ALUB_PCH;
          12'b000001xxx000,
          12'b010x01110000,
          12'b1xxx00000001,
          12'b1xxx01000001: alub_sel = `ALUB_BB;
          12'b010000001111,
          12'b010100001111,
          12'b1xxx00001111,
          12'b000001xxx001,
          12'b010x01110001,
          12'b1xxx01110100,
          12'b1xxx00001001,
          12'b1xxx01001001: alub_sel = `ALUB_CC;
          12'b000001xxx010,
          12'b010x01110010,
          12'b1xxx00010001,
          12'b1xxx01010001: alub_sel = `ALUB_DD;
          12'b010000011111,
          12'b010100011111,
          12'b1xxx00011111,
          12'b000001xxx011,
          12'b010x01110011,
          12'b1xxx00011001,
          12'b1xxx01011001: alub_sel = `ALUB_EE;
          12'b000001xxx100,
          12'b010x01110100,
          12'b1xxx00100001,
          12'b1xxx01100001: alub_sel = `ALUB_HH;
          12'b010000101111,
          12'b010100101111,
          12'b1xxx00101111,
          12'b000001xxx101,
          12'b010x01110101,
          12'b1xxx00101001,
          12'b1xxx01101001: alub_sel = `ALUB_LL;
          12'b000001xxx111,
          12'b010x01110111,
          12'b1xxx00111001,
          12'b1xxx01111001: alub_sel = `ALUB_AA;
          12'b1xxx01000011: alub_sel = `ALUB_BC;
          12'b1xxx01010011: alub_sel = `ALUB_DE;
          12'b1xxx01110011: alub_sel = `ALUB_SP;
          12'b000011000101: alub_sel = `ALUB_BB;
          12'b000011010101: alub_sel = `ALUB_DD;
          12'b000011100101: alub_sel = `ALUB_HH;
          12'b000011110101: alub_sel = `ALUB_AA;
          12'b1xxx01100101,
          12'b1xxx01100110: alub_sel = `ALUB_TMP;
          default:          alub_sel = `ALUB_HL;
        endcase
      end
      `RD1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b1xxx10100011,
          12'b1xxx10101011,
          12'b1xxx10110011,
          12'b1xxx10111011: alub_sel = `ALUB_BC;
          12'b1xxx100xx011: alub_sel = `ALUB_CC;
          12'b1xxx11000011,
          12'b1xxx11001011,
          12'b1xxx10100000,
          12'b1xxx10101000,
          12'b1xxx10110000,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx10111000: alub_sel = `ALUB_DE;
          12'b1xxx00110110,
          12'b1xxx00110111,
          12'b1xxx00xx0111,
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011100,
          12'b1xxx11000010,
          12'b1xxx11001010,
          12'b1xxx10100001,
          12'b1xxx10100010,
          12'b1xxx10101001,
          12'b1xxx10101010,
          12'b1xxx10110001,
          12'b1xxx10110010,
          12'b1xxx10111001,
          12'b1xxx10111010: alub_sel = `ALUB_HL;
          12'b010000110001,
          12'b010000110111,
          12'b010000xx0111,
          12'b010100110001,
          12'b010100110111,
          12'b010100xx0111,
          12'b000000101010,
          12'b0001xxxxxxxx,
          12'b010000101010,
          12'b010100101010,
          12'b1xxx01xx1011: alub_sel = `ALUB_TMP;
          default:          alub_sel = `ALUB_SP;
        endcase
      end
      `RD1B: alub_sel = `ALUB_DIN;
      `RD2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b1xxx10100011,
          12'b1xxx10101011,
          12'b1xxx10110011,
          12'b1xxx10111011: alub_sel = `ALUB_BC;
          12'b1xxx01110100,
          12'b1xxx100xx011: alub_sel = `ALUB_CC;
          12'b1xxx11000011,
          12'b1xxx11001011,
          12'b1xxx10100000,
          12'b1xxx10101000,
          12'b1xxx10110000,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx10111000: alub_sel = `ALUB_DE;
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011100,
          12'b1xxx11000010,
          12'b1xxx11001010,
          12'b001010xxxxxx,
          12'b1xxx10100001,
          12'b1xxx10100010,
          12'b1xxx10101001,
          12'b1xxx10101010,
          12'b1xxx10110001,
          12'b1xxx10110010,
          12'b1xxx10111001,
          12'b1xxx10111010: alub_sel = `ALUB_HL;
          12'b000011001001,
          12'b000011100011,
          12'b000011xxx000,
          12'b000011xx0001,
          12'b0001xxxxxxxx,
          12'b010011100001,
          12'b010011100011,
          12'b010111100001,
          12'b010111100011,
          12'b1xxx01000101,
          12'b1xxx01001101: alub_sel = `ALUB_SP;
          default:          alub_sel = `ALUB_TMP;
        endcase
      end
      `RD2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011100011: alub_sel = `ALUB_HL;
          12'b010011100011: alub_sel = `ALUB_IX;
          12'b010111100011: alub_sel = `ALUB_IY;
          12'b010000110001,
          12'b010000110111,
          12'b010000xx0111,
          12'b010100110001,
          12'b010100110111,
          12'b010100xx0111,
          12'b1xxx00110110,
          12'b1xxx00110111,
          12'b1xxx00xx0111,
          12'b000000001010,
          12'b000000011010,
          12'b000000101010,
          12'b000000111010,
          12'b000001xxxxxx,
          12'b000010000xxx,
          12'b000010001xxx,
          12'b000010010xxx,
          12'b000010011xxx,
          12'b000010100xxx,
          12'b000010101xxx,
          12'b000010110xxx,
          12'b000010111xxx,
          12'b000011011011,
          12'b000011xx0001,
          12'b001001xxx110,
          12'b001001xxxxxx,
          12'b010000101010,
          12'b010001xxx110,
          12'b010010000110,
          12'b010010001110,
          12'b010010010110,
          12'b010010011110,
          12'b010010100110,
          12'b010010101110,
          12'b010010110110,
          12'b010010111110,
          12'b010011100001,
          12'b010100101010,
          12'b010101xxx110,
          12'b010110000110,
          12'b010110001110,
          12'b010110010110,
          12'b010110011110,
          12'b010110100110,
          12'b010110101110,
          12'b010110110110,
          12'b010110111110,
          12'b010111100001,
          12'b011001xxx110,
          12'b011101xxx110,
          12'b1xxx00xxx000,
          12'b1xxx00xxx100,
          12'b1xxx01xxx000,
          12'b1xxx01xxx100,
          12'b1xxx01xx1011: alub_sel = `ALUB_PC;
          12'b0001xxxxxxxx: alub_sel = `ALUB_PCH;
          default:          alub_sel = `ALUB_DIN;
        endcase
      end
      `WR1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100100,
          12'b1xxx10101100: alub_sel = `ALUB_BB;
          12'b1xxx10000100,
          12'b1xxx10001100,
          12'b1xxx10100010,
          12'b1xxx10101010,
          12'b1xxx10110010,
          12'b1xxx10111010: alub_sel = `ALUB_BC;
          12'b1xxx10000010,
          12'b1xxx10001010,
          12'b1xxx10010010,
          12'b1xxx10011010: alub_sel = `ALUB_CC;
          12'b1xxx10010100,
          12'b1xxx10011100,
          12'b1xxx11000010,
          12'b1xxx11001010: alub_sel = `ALUB_DE;
          12'b1xxx00111110,
          12'b1xxx00111111,
          12'b1xxx00xx1111,
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx11000011,
          12'b1xxx11001011,
          12'b1xxx100xx011,
          12'b1xxx10100000,
          12'b1xxx10100011,
          12'b1xxx10101000,
          12'b1xxx10101011,
          12'b1xxx10110000,
          12'b1xxx10110011,
          12'b1xxx10111000,
          12'b1xxx10111011: alub_sel = `ALUB_HL;
          12'b010000111110,
          12'b010000111111,
          12'b010000xx1111,
          12'b010100111110,
          12'b010100111111,
          12'b010100xx1111,
          12'b000000100010,
          12'b010000100010,
          12'b010100100010,
          12'b1xxx01xx0011: alub_sel = `ALUB_TMP;
          default:          alub_sel = `ALUB_SP;
        endcase
      end
      `WR1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10010010,
          12'b1xxx10011010,
          12'b010000001111,
          12'b010100001111,
          12'b1xxx00001111,
          12'b1xxx1001x011,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10111010,
          12'b1xxx10111011: alub_sel = `ALUB_BB;
          12'b1xxx10010100,
          12'b1xxx10011100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx10110000,
          12'b1xxx10111000: alub_sel = `ALUB_BC;
          12'b010000011111,
          12'b010100011111,
          12'b1xxx00011111: alub_sel = `ALUB_DD;
          12'b010000101111,
          12'b010100101111,
          12'b1xxx00101111,
          12'b000000100010,
          12'b000011100011: alub_sel = `ALUB_HH;
          12'b010011100101: alub_sel = `ALUB_IX;
          12'b010000111111,
          12'b010100111110,
          12'b1xxx00111111,
          12'b010000100010,
          12'b010011100011: alub_sel = `ALUB_IXH;
          12'b010111100101: alub_sel = `ALUB_IY;
          12'b010000111110,
          12'b010100111111,
          12'b1xxx00111110,
          12'b010100100010,
          12'b010111100011: alub_sel = `ALUB_IYH;
          12'b1xxx01000011: alub_sel = `ALUB_BC;
          12'b1xxx01010011: alub_sel = `ALUB_DE;
          12'b1xxx01100011: alub_sel = `ALUB_HL;
          12'b1xxx01110011: alub_sel = `ALUB_SP;
          12'b000011000101: alub_sel = `ALUB_BC;
          12'b000011010101: alub_sel = `ALUB_DE;
          12'b000011100101: alub_sel = `ALUB_HL;
          12'b000011110101: alub_sel = `ALUB_AF;
          12'b1xxx01100101,
          12'b1xxx01100110: alub_sel = `ALUB_TMP;
          default:          alub_sel = `ALUB_PC;
        endcase
      end
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10000010,
          12'b1xxx10001010,
          12'b1xxx10010010,
          12'b1xxx10011010: alub_sel = `ALUB_CC;
          12'b1xxx10100010,
          12'b1xxx10101010,
          12'b1xxx10110010,
          12'b1xxx10111010: alub_sel = `ALUB_BC;
          12'b1xxx10010100,
          12'b1xxx10011100,
          12'b1xxx11000010,
          12'b1xxx11001010: alub_sel = `ALUB_DE;
          12'b000011001101,
          12'b000011xxx100: alub_sel = `ALUB_DIN;
          default:          alub_sel = `ALUB_HL;
        endcase
      end
      `WR2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10011010,
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b1xxx100xx011,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10111010,
          12'b1xxx10111011: alub_sel = `ALUB_BB;
          12'b1xxx10010100,
          12'b1xxx10011100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx10100000,
          12'b1xxx10101000,
          12'b1xxx10110000,
          12'b1xxx10111000: alub_sel = `ALUB_BC;
          default:          alub_sel = `ALUB_PC;
        endcase
      end
      `BLK1:                alub_sel = `ALUB_HL;
      `BLK2:                alub_sel = (inst_reg[4]) ? `ALUB_BC : `ALUB_PC;
      `PCA,
      `PCO:                 alub_sel = `ALUB_PC;
      `IF1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100011,
          12'b1xxx10101011,
          12'b1xxx10110011,
          12'b1xxx10111011: alub_sel = `ALUB_BB;
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b1xxx100xx011: alub_sel = `ALUB_CC;
          12'b1xxx11000011,
          12'b1xxx11001011,
          12'b1xxx10100000,
          12'b1xxx10101000,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx10110000,
          12'b1xxx10111000: alub_sel = `ALUB_DE;
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011100,
          12'b1xxx10101010,
          12'b1xxx10111010,
          12'b1xxx10100010,
          12'b1xxx10110010,
          12'b1xxx11000010,
          12'b1xxx11001010: alub_sel = `ALUB_HL;
          default:          alub_sel = `ALUB_DIN;
          endcase
        end
      `INTA:                alub_sel = `ALUB_SP;
      `INTB:                alub_sel = `ALUB_PCH;
      default:              alub_sel = `ALUB_PC;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  register write control                                                               */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or par_bit or sign_bit or
            vector_int or zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `OF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000010000: wr_addr = `WREG_BB;
          default:          wr_addr = `WREG_NUL;
          endcase
        end
      `OF2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011001101: wr_addr = `WREG_SP;
          12'b000011000100: wr_addr = ( !zero_bit) ? `WREG_SP : `WREG_NUL;
          12'b000011001100: wr_addr = (  zero_bit) ? `WREG_SP : `WREG_NUL;
          12'b000011010100: wr_addr = (!carry_bit) ? `WREG_SP : `WREG_NUL;
          12'b000011011100: wr_addr = ( carry_bit) ? `WREG_SP : `WREG_NUL;
          12'b000011100100: wr_addr = (  !par_bit) ? `WREG_SP : `WREG_NUL;
          12'b000011101100: wr_addr = (   par_bit) ? `WREG_SP : `WREG_NUL;
          12'b000011110100: wr_addr = ( !sign_bit) ? `WREG_SP : `WREG_NUL;
          12'b000011111100: wr_addr = (  sign_bit) ? `WREG_SP : `WREG_NUL;
          default:          wr_addr = `WREG_NUL;
          endcase
        end
      `IF3B:                wr_addr = `WREG_TMP;
      `ADR1: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01110100: wr_addr = `WREG_TMP;
          default:          wr_addr = `WREG_NUL;
        endcase
      end
      `ADR2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100100,
          12'b1xxx10101100: wr_addr = `WREG_HL;
          12'b1xxx01100101,
          12'b1xxx01100110,
          12'b000011xxx111,
          12'b000011xx0101,
          12'b010011100101,
          12'b010111100101: wr_addr = `WREG_SP;
          12'b010000110001,
          12'b010000110111,
          12'b010000111110,
          12'b010000111111,
          12'b010000xx0111,
          12'b010000xx1111,
          12'b010100110001,
          12'b010100110111,
          12'b010100111110,
          12'b010100111111,
          12'b010100xx0111,
          12'b010100xx1111,
          12'b000000100010,
          12'b000000101010,
          12'b010000100010,
          12'b010000101010,
          12'b010000110100,
          12'b010000110101,
          12'b010100100010,
          12'b010100101010,
          12'b010100110100,
          12'b010100110101,
          12'b1xxx01xx0011,
          12'b1xxx01xx1011: wr_addr = `WREG_TMP;
          default:          wr_addr = `WREG_NUL;
        endcase
      end
      `RD1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10011010,
          12'b1xxx100xx011,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10111010,
          12'b1xxx10111011: wr_addr = `WREG_BB;
          12'b1xxx10010100,
          12'b1xxx10011100,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011,
          12'b1xxx10100000,
          12'b1xxx10100001,
          12'b1xxx10101000,
          12'b1xxx10101001,
          12'b1xxx10110000,
          12'b1xxx10110001,
          12'b1xxx10111000,
          12'b1xxx10111001: wr_addr = `WREG_BC;
          default:          wr_addr = `WREG_NUL;
        endcase
      end
      `RD1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011001001,
          12'b000011xxx000,
          12'b000011xx0001,
          12'b010011100001,
          12'b010111100001,
          12'b1xxx01000101,
          12'b1xxx01001101: wr_addr = `WREG_SP;
          default:          wr_addr = `WREG_NUL;
        endcase
      end
      `RD2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10011010,
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b1xxx100xx011,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10111010,
          12'b1xxx10111011: wr_addr = `WREG_BB;
          12'b1xxx10010100,
          12'b1xxx10011100,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011,
          12'b1xxx10100000,
          12'b1xxx10100001,
          12'b1xxx10101000,
          12'b1xxx10101001,
          12'b1xxx10110000,
          12'b1xxx10110001,
          12'b1xxx10111000,
          12'b1xxx10111001: wr_addr = `WREG_BC;
          default:          wr_addr = `WREG_NUL;
        endcase
      end
      `RD2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx100xx011: wr_addr = `WREG_CC;
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx10100000,
          12'b1xxx10101000,
          12'b1xxx10110000,
          12'b1xxx10111000: wr_addr = `WREG_DE;
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011100,
          12'b1xxx10100010,
          12'b1xxx10101010,
          12'b1xxx10110010,
          12'b1xxx10111010,
          12'b1xxx11000010,
          12'b1xxx11001010: wr_addr = `WREG_HL;
          12'b000011001001,
          12'b000011xxx000,
          12'b000011xx0001,
          12'b0001xxxxxxxx,
          12'b010011100001,
          12'b010111100001,
          12'b1xxx01000101,
          12'b1xxx01001101: wr_addr = `WREG_SP;
          default:          wr_addr = `WREG_NUL;
        endcase
      end
      `WR1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01100101,
          12'b1xxx01100110: wr_addr = `WREG_TMP;
          default:          wr_addr = `WREG_NUL;
        endcase
      end
      `WR1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100100,
          12'b1xxx10101100: wr_addr = `WREG_BB;
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10011010: wr_addr = `WREG_CC;
          12'b1xxx10010100,
          12'b1xxx10011100: wr_addr = `WREG_DE;
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx11000011,
          12'b1xxx11001011,
          12'b1xxx100xx011,
          12'b1xxx10100000,
          12'b1xxx10100011,
          12'b1xxx10101000,
          12'b1xxx10101011,
          12'b1xxx10110000,
          12'b1xxx10110011,
          12'b1xxx10111000,
          12'b1xxx10111011: wr_addr = `WREG_HL;
          12'b1xxx01100101,
          12'b1xxx01100110,
          12'b000011001101,
          12'b000011xxx100,
          12'b000011xxx111,
          12'b000011xx0101,
          12'b0001xxxxxxxx,
          12'b010011100101,
          12'b010111100101: wr_addr = `WREG_SP;
          default:          wr_addr = `WREG_NUL;
        endcase
      end
      `WR2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10011010: wr_addr = `WREG_CC;
          12'b1xxx10010100,
          12'b1xxx10011100: wr_addr = `WREG_DE;
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx11000011,
          12'b1xxx11001011,
          12'b1xxx100xx011,
          12'b1xxx10100000,
          12'b1xxx10100011,
          12'b1xxx10101000,
          12'b1xxx10101011,
          12'b1xxx10110000,
          12'b1xxx10110011,
          12'b1xxx10111000,
          12'b1xxx10111011: wr_addr = `WREG_HL;
          default:          wr_addr = `WREG_NUL;
        endcase
      end
      `BLK2: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100001,
          12'b1xxx10101001,
          12'b1xxx10110001,
          12'b1xxx10111001: wr_addr = `WREG_HL;
          default:          wr_addr = `WREG_NUL;
        endcase
      end
      `IF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000000111,
          12'b000000001010,
          12'b000000001111,
          12'b000000010111,
          12'b000000011010,
          12'b000000011111,
          12'b000000100111,
          12'b000000101111,
          12'b000000111010,
          12'b00000011110x,
          12'b000000111110,
          12'b000001111xxx,
          12'b000010000xxx,
          12'b000010001xxx,
          12'b000010010xxx,
          12'b000010011xxx,
          12'b000010100xxx,
          12'b000010101xxx,
          12'b000010110xxx,
          12'b000011000110,
          12'b000011001110,
          12'b000011010110,
          12'b000011011011,
          12'b000011011110,
          12'b000011100110,
          12'b000011101110,
          12'b000011110110,
          12'b001000xxx111,
          12'b00101xxxx111,
          12'b010010000100,
          12'b010010000101,
          12'b010010000110,
          12'b010010001100,
          12'b010010001101,
          12'b010010001110,
          12'b010010010100,
          12'b010010010101,
          12'b010010010110,
          12'b010010011100,
          12'b010010011101,
          12'b010010011110,
          12'b010010100100,
          12'b010010100101,
          12'b010010100110,
          12'b010010101100,
          12'b010010101101,
          12'b010010101110,
          12'b010010110100,
          12'b010010110101,
          12'b010010110110,
          12'b010110000100,
          12'b010110000101,
          12'b010110000110,
          12'b010110001100,
          12'b010110001101,
          12'b010110001110,
          12'b010110010100,
          12'b010110010101,
          12'b010110010110,
          12'b010110011100,
          12'b010110011101,
          12'b010110011110,
          12'b010110100100,
          12'b010110100101,
          12'b010110100110,
          12'b010110101100,
          12'b010110101101,
          12'b010110101110,
          12'b010110110100,
          12'b010110110101,
          12'b010110110110,
          12'b010x0111110x,
          12'b010x01111110,
          12'b1xxx01000100,
          12'b1xxx01010111,
          12'b1xxx01011111,
          12'b1xxx01100111,
          12'b1xxx01101111,
          12'b1xxx0x111000: wr_addr = `WREG_AA;
          12'b000011110001: wr_addr = `WREG_AF;
          12'b00000000010x,
          12'b000000000110,
          12'b000001000xxx,
          12'b001000xxx000,
          12'b00101xxxx000,
          12'b010x0100010x,
          12'b010x01000110,
          12'b1xxx0x000000,
          12'b1xxx10100011,
          12'b1xxx10101011,
          12'b1xxx10110011,
          12'b1xxx10111011: wr_addr = `WREG_BB;
          12'b010000000111,
          12'b010100000111,
          12'b1xxx00000111,
          12'b1xxx00000010,
          12'b1xxx00000011,
          12'b000000000001,
          12'b00000000x011,
          12'b000011000001,
          12'b1xxx01001100,
          12'b1xxx01001011: wr_addr = `WREG_BC;
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b00000000110x,
          12'b000000001110,
          12'b000001001xxx,
          12'b001000xxx001,
          12'b00101xxxx001,
          12'b010x0100110x,
          12'b010x01001110,
          12'b1xxx100xx011,
          12'b1xxx0x001000: wr_addr = `WREG_CC;
          12'b00000001010x,
          12'b000000010110,
          12'b000001010xxx,
          12'b001000xxx010,
          12'b00101xxxx010,
          12'b010x0101010x,
          12'b010x01010110,
          12'b1xxx0x010000: wr_addr = `WREG_DD;
          12'b010000010111,
          12'b010100010111,
          12'b1xxx00010111,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx00010010,
          12'b1xxx00010011,
          12'b000011010001,
          12'b00000001x011,
          12'b000000010001,
          12'b1xxx01011100,
          12'b1xxx01011011,
          12'b1xxx10100000,
          12'b1xxx10101000,
          12'b1xxx10110000,
          12'b1xxx10111000: wr_addr = `WREG_DE;
          12'b000011101011: wr_addr = `WREG_DEHL;
          12'b00000001110x,
          12'b000000011110,
          12'b000001011xxx,
          12'b001000xxx011,
          12'b00101xxxx011,
          12'b010x0101110x,
          12'b010x01011110,
          12'b1xxx0x011000: wr_addr = `WREG_EE;
          12'b00000010010x,
          12'b000000100110,
          12'b000001100xxx,
          12'b001000xxx100,
          12'b00101xxxx100,
          12'b010x01100110,
          12'b1xxx0x100000: wr_addr = `WREG_HH;
          12'b010000100111,
          12'b010100100111,
          12'b1xxx00100010,
          12'b1xxx00100011,
          12'b1xxx00100111,
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011100,
          12'b000000100001,
          12'b000000101010,
          12'b00000010x011,
          12'b000000xx1001,
          12'b000011100001,
          12'b000011100011,
          12'b1xxx01101100,
          12'b1xxx01101011,
          12'b1xxx01xx0010,
          12'b1xxx01xx1010,
          12'b1xxx10100010,
          12'b1xxx10101010,
          12'b1xxx10110010,
          12'b1xxx10111010,
          12'b1xxx11000010,
          12'b1xxx11001010: wr_addr = `WREG_HL;
          12'b1xxx01000111: wr_addr = `WREG_II;
          12'b010000110111,
          12'b010100110001,
          12'b1xxx00110111,
          12'b1xxx00110010,
          12'b1xxx01010100,
          12'b010000100001,
          12'b010000100011,
          12'b010000101010,
          12'b010000101011,
          12'b010000xx1001,
          12'b010011100001,
          12'b010011100011: wr_addr = `WREG_IX;
          12'b010000100100,
          12'b010000100101,
          12'b010000100110,
          12'b0100011000xx,
          12'b01000110010x,
          12'b010001100111: wr_addr = `WREG_IXH;
          12'b010000101100,
          12'b010000101101,
          12'b010000101110,
          12'b0100011010xx,
          12'b01000110110x,
          12'b010001101111: wr_addr = `WREG_IXL;
          12'b010000110001,
          12'b010100110111,
          12'b1xxx00110110,
          12'b1xxx00110011,
          12'b1xxx01010101,
          12'b010100100001,
          12'b010100100011,
          12'b010100101010,
          12'b010100101011,
          12'b010100xx1001,
          12'b010111100001,
          12'b010111100011: wr_addr = `WREG_IY;
          12'b010100100100,
          12'b010100100101,
          12'b010100100110,
          12'b0101011000xx,
          12'b01010110010x,
          12'b010101100111: wr_addr = `WREG_IYH;
          12'b010100101100,
          12'b010100101101,
          12'b010100101110,
          12'b0101011010xx,
          12'b01010110110x,
          12'b010101101111: wr_addr = `WREG_IYL;
          12'b00000010110x,
          12'b000000101110,
          12'b000001101xxx,
          12'b001000xxx101,
          12'b00101xxxx101,
          12'b010x01101110,
          12'b1xxx0x101000: wr_addr = `WREG_LL;
          12'b1xxx01001111: wr_addr = `WREG_RR;
          12'b000000110001,
          12'b00000011x011,
          12'b000011111001,
          12'b010x11111001,
          12'b1xxx01111100,
          12'b1xxx01111011: wr_addr = `WREG_SP;
          default:          wr_addr = `WREG_NUL;
          endcase
        end
      `INTB:                wr_addr = (vector_int) ? `WREG_TMP : `WREG_SP;
      default:              wr_addr = `WREG_NUL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  s flag control                                                                       */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000110100,
          12'b000000110101,
          12'b001000xxxxxx,
          12'b010000110100,
          12'b010000110101,
          12'b010100110100,
          12'b010100110101,
          12'b011x00xxxxxx: sflg_en = 1'b1;
          default:          sflg_en = 1'b0;
          endcase
        end
      `BLK1: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100001,
          12'b1xxx10101001,
          12'b1xxx10110001,
          12'b1xxx10111001: sflg_en = 1'b1;
          default:          sflg_en = 1'b0;
        endcase
      end
      `IF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000100111,
          12'b0000000xx100,12'b00000010x100,12'b000000111100,
          12'b0000000xx101,12'b00000010x101,12'b000000111101,
          12'b000010000110,
          12'b000010000xxx,
          12'b000010001110,
          12'b000010001xxx,
          12'b000010010110,
          12'b000010010xxx,
          12'b000010011110,
          12'b000010011xxx,
          12'b000010100110,
          12'b000010100xxx,
          12'b000010101110,
          12'b000010101xxx,
          12'b000010110110,
          12'b000010110xxx,
          12'b000010111110,
          12'b000010111xxx,
          12'b000011000110,
          12'b000011001110,
          12'b000011010110,
          12'b000011011110,
          12'b000011100110,
          12'b000011101110,
          12'b000011110110,
          12'b000011111110,
          12'b001000xxx0xx,
          12'b001000xxx10x,
          12'b001000xxx111,
          12'b010000100100,
          12'b010000100101,
          12'b010000101100,
          12'b010000101101,
          12'b010010000100,
          12'b010010000101,
          12'b010010000110,
          12'b010010001100,
          12'b010010001101,
          12'b010010001110,
          12'b010010010100,
          12'b010010010101,
          12'b010010010110,
          12'b010010011100,
          12'b010010011101,
          12'b010010011110,
          12'b010010100100,
          12'b010010100101,
          12'b010010100110,
          12'b010010101100,
          12'b010010101101,
          12'b010010101110,
          12'b010010110100,
          12'b010010110101,
          12'b010010110110,
          12'b010010111100,
          12'b010010111101,
          12'b010010111110,
          12'b010100100100,
          12'b010100100101,
          12'b010100101100,
          12'b010100101101,
          12'b010110000100,
          12'b010110000101,
          12'b010110000110,
          12'b010110001100,
          12'b010110001101,
          12'b010110001110,
          12'b010110010100,
          12'b010110010101,
          12'b010110010110,
          12'b010110011100,
          12'b010110011101,
          12'b010110011110,
          12'b010110100100,
          12'b010110100101,
          12'b010110100110,
          12'b010110101100,
          12'b010110101101,
          12'b010110101110,
          12'b010110110100,
          12'b010110110101,
          12'b010110110110,
          12'b010110111100,
          12'b010110111101,
          12'b010110111110,
          12'b1xxx00110100,
          12'b1xxx00xxxx00,
          12'b1xxx011x0100,
          12'b1xxx01000100,
          12'b1xxx01010111,
          12'b1xxx01011111,
          12'b1xxx01100111,
          12'b1xxx01101111,
          12'b1xxx01xxx000,
          12'b1xxx01xx0010,
          12'b1xxx01xx1010: sflg_en = 1'b1;
          default:          sflg_en = 1'b0;
        endcase
      end
      default:              sflg_en = 1'b0;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  z flag control                                                                       */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `RD1A,
      `RD2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011100,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011,
          12'b1xxx100xx011,
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10111010,
          12'b1xxx10111011: zflg_en = 1'b1;
          default:          zflg_en = 1'b0;
          endcase
        end
      `WR1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100100,
          12'b1xxx10101100: zflg_en = 1'b1;
          default:          zflg_en = 1'b0;
        endcase
      end
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000110100,
          12'b000000110101,
          12'b001000xxxxxx,
          12'b010000110100,
          12'b010000110101,
          12'b010100110100,
          12'b010100110101,
          12'b011x00xxxxxx: zflg_en = 1'b1;
          default:          zflg_en = 1'b0;
        endcase
      end
      `BLK1: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100001,
          12'b1xxx10101001,
          12'b1xxx10110001,
          12'b1xxx10111001: zflg_en = 1'b1;
          default:          zflg_en = 1'b0;
        endcase
      end
      `IF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000100111,
          12'b0000000xx100,12'b00000010x100,12'b000000111100,
          12'b0000000xx101,12'b00000010x101,12'b000000111101,
          12'b000010000110,
          12'b000010000xxx,
          12'b000010001110,
          12'b000010001xxx,
          12'b000010010110,
          12'b000010010xxx,
          12'b000010011110,
          12'b000010011xxx,
          12'b000010100110,
          12'b000010100xxx,
          12'b000010101110,
          12'b000010101xxx,
          12'b000010110110,
          12'b000010110xxx,
          12'b000010111110,
          12'b000010111xxx,
          12'b000011000110,
          12'b000011001110,
          12'b000011010110,
          12'b000011011110,
          12'b000011100110,
          12'b000011101110,
          12'b000011110110,
          12'b000011111110,
          12'b001000xxx0xx,12'b001000xxx10x,12'b001000xxx111,
          12'b001001xxx110,
          12'b001001xxxxxx,
          12'b010000100100,
          12'b010000100101,
          12'b010000101100,
          12'b010000101101,
          12'b010010000100,
          12'b010010000101,
          12'b010010000110,
          12'b010010001100,
          12'b010010001101,
          12'b010010001110,
          12'b010010010100,
          12'b010010010101,
          12'b010010010110,
          12'b010010011100,
          12'b010010011101,
          12'b010010011110,
          12'b010010100100,
          12'b010010100101,
          12'b010010100110,
          12'b010010101100,
          12'b010010101101,
          12'b010010101110,
          12'b010010110100,
          12'b010010110101,
          12'b010010110110,
          12'b010010111100,
          12'b010010111101,
          12'b010010111110,
          12'b010100100100,
          12'b010100100101,
          12'b010100101100,
          12'b010100101101,
          12'b010110000100,
          12'b010110000101,
          12'b010110000110,
          12'b010110001100,
          12'b010110001101,
          12'b010110001110,
          12'b010110010100,
          12'b010110010101,
          12'b010110010110,
          12'b010110011100,
          12'b010110011101,
          12'b010110011110,
          12'b010110100100,
          12'b010110100101,
          12'b010110100110,
          12'b010110101100,
          12'b010110101101,
          12'b010110101110,
          12'b010110110100,
          12'b010110110101,
          12'b010110110110,
          12'b010110111100,
          12'b010110111101,
          12'b010110111110,
          12'b011001xxx110,
          12'b011101xxx110,
          12'b1xxx00xxxx00,
          12'b1xxx01000100,
          12'b1xxx01010111,
          12'b1xxx01011111,
          12'b1xxx01100111,
          12'b1xxx01101111,
          12'b1xxx011x0100,
          12'b1xxx01xxx000,
          12'b1xxx01xx0010,
          12'b1xxx01xx1010,
          12'b1xxx10100011,
          12'b1xxx10101011,
          12'b1xxx10110011,
          12'b1xxx10111011: zflg_en = 1'b1;
          default:          zflg_en = 1'b0;
        endcase
      end
      default:              zflg_en = 1'b0;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  h flag control                                                                       */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b001000xxxxxx,
          12'b011x00xxxxxx,
          12'b1xxx01100111,
          12'b1xxx01101111: hflg_ctl = `HFLG_0;
          12'b000000110100,
          12'b000000110101,
          12'b010x00110100,
          12'b010x00110101: hflg_ctl = `HFLG_H;
          default:          hflg_ctl = `HFLG_NUL;
          endcase
        end
      `BLK1: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100001,
          12'b1xxx10101001,
          12'b1xxx10110001,
          12'b1xxx10111001: hflg_ctl = `HFLG_H;
          default:          hflg_ctl = `HFLG_NUL;
        endcase
      end
      `IF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000000111,
          12'b000000001111,
          12'b000000010111,
          12'b000000011111,
          12'b000000110111,
          12'b000010101110,
          12'b000010101xxx,
          12'b000010110110,
          12'b000010110xxx,
          12'b000011101110,
          12'b000011110110,
          12'b001000000xxx,
          12'b001000001xxx,
          12'b001000010xxx,
          12'b001000011xxx,
          12'b001000100xxx,
          12'b001000101xxx,
          12'b001000110xxx,
          12'b001000111xxx,
          12'b010010101100,
          12'b010010101101,
          12'b010010101110,
          12'b010010110100,
          12'b010010110101,
          12'b010010110110,
          12'b010110101100,
          12'b010110101101,
          12'b010110101110,
          12'b010110110100,
          12'b010110110101,
          12'b010110110110,
          12'b1xxx00xxx000,
          12'b1xxx01010111,
          12'b1xxx01011111,
          12'b1xxx01xxx000,
          12'b1xxx10100000,
          12'b1xxx10101000,
          12'b1xxx10110000,
          12'b1xxx10111000: hflg_ctl = `HFLG_0;
          12'b000000101111,
          12'b000010100110,
          12'b000010100xxx,
          12'b000011100110,
          12'b001001xxx110,
          12'b001001xxxxxx,
          12'b010010100100,
          12'b010010100101,
          12'b010010100110,
          12'b010110100100,
          12'b010110100101,
          12'b010110100110,
          12'b011001xxx110,
          12'b011101xxx110,
          12'b1xxx00xxx100,
          12'b1xxx011x0100: hflg_ctl = `HFLG_1;
          12'b000000111111,
          12'b000000100111,
          12'b0000000xx100,12'b00000010x100,12'b000000111100,
          12'b0000000xx101,12'b00000010x101,12'b000000111101,
          12'b000000xx1001,
          12'b000010000110,
          12'b000010000xxx,
          12'b000010001110,
          12'b000010001xxx,
          12'b000010010110,
          12'b000010010xxx,
          12'b000010011110,
          12'b000010011xxx,
          12'b000010111110,
          12'b000010111xxx,
          12'b000011000110,
          12'b000011001110,
          12'b000011010110,
          12'b000011011110,
          12'b000011111110,
          12'b010000100100,
          12'b010000100101,
          12'b010000101100,
          12'b010000101101,
          12'b010000xx1001,
          12'b010010000100,
          12'b010010000101,
          12'b010010000110,
          12'b010010001100,
          12'b010010001101,
          12'b010010001110,
          12'b010010010100,
          12'b010010010101,
          12'b010010010110,
          12'b010010011100,
          12'b010010011101,
          12'b010010011110,
          12'b010010111100,
          12'b010010111101,
          12'b010010111110,
          12'b010100100100,
          12'b010100100101,
          12'b010100101100,
          12'b010100101101,
          12'b010100xx1001,
          12'b010110000100,
          12'b010110000101,
          12'b010110000110,
          12'b010110001100,
          12'b010110001101,
          12'b010110001110,
          12'b010110010100,
          12'b010110010101,
          12'b010110010110,
          12'b010110011100,
          12'b010110011101,
          12'b010110011110,
          12'b010110111100,
          12'b010110111101,
          12'b010110111110,
          12'b1xxx01000100,
          12'b1xxx01xx0010,
          12'b1xxx01xx1010: hflg_ctl = `HFLG_H;
          default:          hflg_ctl = `HFLG_NUL;
        endcase
      end
      default:              hflg_ctl = `HFLG_NUL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  pv flag control                                                                      */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `RD1A,
      `RD2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100000,
          12'b1xxx10100001,
          12'b1xxx10101000,
          12'b1xxx10101001,
          12'b1xxx10110000,
          12'b1xxx10110001,
          12'b1xxx10111000,
          12'b1xxx10111001: pflg_ctl = `PFLG_B;
          default:          pflg_ctl = `PFLG_NUL;
          endcase
        end
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b001000xxxxxx,
          12'b011x00xxxxxx: pflg_ctl = `PFLG_P;
          12'b000000110100,
          12'b000000110101,
          12'b010000110100,
          12'b010000110101,
          12'b010100110100,
          12'b010100110101: pflg_ctl = `PFLG_V;
          default:          pflg_ctl = `PFLG_NUL;
        endcase
      end
      `IF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01010111,
          12'b1xxx01011111: pflg_ctl = `PFLG_F;
          12'b000000100111,
          12'b000010100110,
          12'b000010100xxx,
          12'b000010101110,
          12'b000010101xxx,
          12'b000010110110,
          12'b000010110xxx,
          12'b000011100110,
          12'b000011101110,
          12'b000011110110,
          12'b001000xxx0xx,12'b001000xxx10x,12'b001000xxx111,
          12'b010010100100,
          12'b010010100101,
          12'b010010100110,
          12'b010010101100,
          12'b010010101101,
          12'b010010101110,
          12'b010010110100,
          12'b010010110101,
          12'b010010110110,
          12'b010110100100,
          12'b010110100101,
          12'b010110100110,
          12'b010110101100,
          12'b010110101101,
          12'b010110101110,
          12'b010110110100,
          12'b010110110101,
          12'b010110110110,
          12'b1xxx00xxxx00,
          12'b1xxx00110100,
          12'b1xxx011x0100,
          12'b1xxx01100111,
          12'b1xxx01101111,
          12'b1xxx01xxx000: pflg_ctl = `PFLG_P;
          12'b0000000xx100,12'b00000010x100,12'b000000111100,
          12'b0000000xx101,12'b00000010x101,12'b000000111101,
          12'b000010000110,
          12'b000010000xxx,
          12'b000010001110,
          12'b000010001xxx,
          12'b000010010110,
          12'b000010010xxx,
          12'b000010011110,
          12'b000010011xxx,
          12'b000010111110,
          12'b000010111xxx,
          12'b000011000110,
          12'b000011001110,
          12'b000011010110,
          12'b000011011110,
          12'b000011111110,
          12'b010000100100,
          12'b010000100101,
          12'b010000101100,
          12'b010000101101,
          12'b010010000100,
          12'b010010000101,
          12'b010010000110,
          12'b010010001100,
          12'b010010001101,
          12'b010010001110,
          12'b010010010100,
          12'b010010010101,
          12'b010010010110,
          12'b010010011100,
          12'b010010011101,
          12'b010010011110,
          12'b010010111100,
          12'b010010111101,
          12'b010010111110,
          12'b010100100100,
          12'b010100100101,
          12'b010100101100,
          12'b010100101101,
          12'b010110000100,
          12'b010110000101,
          12'b010110000110,
          12'b010110001100,
          12'b010110001101,
          12'b010110001110,
          12'b010110010100,
          12'b010110010101,
          12'b010110010110,
          12'b010110011100,
          12'b010110011101,
          12'b010110011110,
          12'b010110111100,
          12'b010110111101,
          12'b010110111110,
          12'b1xxx01000100,
          12'b1xxx01xx0010,
          12'b1xxx01xx1010: pflg_ctl = `PFLG_V;
          default:          pflg_ctl = `PFLG_NUL;
        endcase
      end
      default:              pflg_ctl = `PFLG_NUL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  n flag control                                                                       */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `WR1A,
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10111010,
          12'b1xxx10111011: nflg_ctl = `NFLG_S;
          default:          nflg_ctl = `NFLG_NUL;
          endcase
        end
      `IF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000000111,
          12'b000000001111,
          12'b000000010111,
          12'b000000011111,
          12'b000000110100,
          12'b000000110111,
          12'b000000111111,
          12'b000000xxx100,
          12'b000000xx1001,
          12'b000010000110,
          12'b000010000xxx,
          12'b000010001110,
          12'b000010001xxx,
          12'b000010100110,
          12'b000010100xxx,
          12'b000010101110,
          12'b000010101xxx,
          12'b000010110110,
          12'b000010110xxx,
          12'b000011000110,
          12'b000011001110,
          12'b000011100110,
          12'b000011101110,
          12'b000011110110,
          12'b010000100100,
          12'b010000101100,
          12'b010000110100,
          12'b010000xx1001,
          12'b010010000100,
          12'b010010000101,
          12'b010010000110,
          12'b010010001100,
          12'b010010001101,
          12'b010010001110,
          12'b010010100100,
          12'b010010100101,
          12'b010010100110,
          12'b010010101100,
          12'b010010101101,
          12'b010010101110,
          12'b010010110100,
          12'b010010110101,
          12'b010010110110,
          12'b010100100100,
          12'b010100101100,
          12'b010100110100,
          12'b010100xx1001,
          12'b010110000100,
          12'b010110000101,
          12'b010110000110,
          12'b010110001100,
          12'b010110001101,
          12'b010110001110,
          12'b010110100100,
          12'b010110100101,
          12'b010110100110,
          12'b010110101100,
          12'b010110101101,
          12'b010110101110,
          12'b010110110100,
          12'b010110110101,
          12'b010110110110,
          12'b00100xxxxxxx,
          12'b011x0xxxxxxx,
          12'b1xxx00xxxx00,
          12'b1xxx00110100,
          12'b1xxx011x0100,
          12'b1xxx01010111,
          12'b1xxx01011111,
          12'b1xxx01100111,
          12'b1xxx01101111,
          12'b1xxx01xxx000,
          12'b1xxx01xx1010,
          12'b1xxx10100000,
          12'b1xxx10101000,
          12'b1xxx10110000,
          12'b1xxx10111000: nflg_ctl = `NFLG_0;
          12'b1xxx10000010,
          12'b1xxx10000100,
          12'b1xxx10001010,
          12'b1xxx10001100,
          12'b1xxx10010010,
          12'b1xxx10010100,
          12'b1xxx10011010,
          12'b1xxx10011100,
          12'b1xxx10100100,
          12'b1xxx10101100,
          12'b1xxx10110100,
          12'b1xxx10111100,
          12'b1xxx11000010,
          12'b1xxx11000011,
          12'b1xxx11001010,
          12'b1xxx11001011,
          12'b000000101111,
          12'b000000110101,
          12'b000000xxx101,
          12'b000010010110,
          12'b000010010xxx,
          12'b000010011110,
          12'b000010011xxx,
          12'b000010111110,
          12'b000010111xxx,
          12'b000011010110,
          12'b000011011110,
          12'b000011111110,
          12'b010000100101,
          12'b010000101101,
          12'b010000110101,
          12'b010010010100,
          12'b010010010101,
          12'b010010010110,
          12'b010010011100,
          12'b010010011101,
          12'b010010011110,
          12'b010010111100,
          12'b010010111101,
          12'b010010111110,
          12'b010100100101,
          12'b010100101101,
          12'b010100110101,
          12'b010110010100,
          12'b010110010101,
          12'b010110010110,
          12'b010110011100,
          12'b010110011101,
          12'b010110011110,
          12'b010110111100,
          12'b010110111101,
          12'b010110111110,
          12'b1xxx01000100,
          12'b1xxx01xx0010,
          12'b1xxx100xx011,
          12'b1xxx10100001,
          12'b1xxx10101001,
          12'b1xxx10110001,
          12'b1xxx10111001: nflg_ctl = `NFLG_1;
          default:          nflg_ctl = `NFLG_NUL;
        endcase
      end
      default:              nflg_ctl = `NFLG_NUL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  c flag control                                                                       */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b001000xxxxxx,
          12'b011x00xxxxxx: cflg_en = 1'b1;
          default:          cflg_en = 1'b0;
          endcase
        end
      `IF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000010100110,
          12'b000010100xxx,
          12'b000010101110,
          12'b000010101xxx,
          12'b000010110110,
          12'b000010110xxx,
          12'b000011100110,
          12'b000011101110,
          12'b000011110110,
          12'b010010100100,
          12'b010010100101,
          12'b010010100110,
          12'b010010101100,
          12'b010010101101,
          12'b010010101110,
          12'b010010110100,
          12'b010010110101,
          12'b010010110110,
          12'b010110100100,
          12'b010110100101,
          12'b010110100110,
          12'b010110101100,
          12'b010110101101,
          12'b010110101110,
          12'b010110110100,
          12'b010110110101,
          12'b010110110110,
          12'b000000110111,
          12'b000000000111,
          12'b000000001111,
          12'b000000010111,
          12'b000000011111,
          12'b000000100111,
          12'b000000111111,
          12'b000000xx1001,
          12'b000010000110,
          12'b000010000xxx,
          12'b000010001110,
          12'b000010001xxx,
          12'b000010010110,
          12'b000010010xxx,
          12'b000010011110,
          12'b000010011xxx,
          12'b000010111110,
          12'b000010111xxx,
          12'b000011000110,
          12'b000011001110,
          12'b000011010110,
          12'b000011011110,
          12'b000011111110,
          12'b001000xxx0xx,12'b001000xxx10x,12'b001000xxx111,
          12'b010000xx1001,
          12'b010010000100,
          12'b010010000101,
          12'b010010000110,
          12'b010010001100,
          12'b010010001101,
          12'b010010001110,
          12'b010010010100,
          12'b010010010101,
          12'b010010010110,
          12'b010010011100,
          12'b010010011101,
          12'b010010011110,
          12'b010010111100,
          12'b010010111101,
          12'b010010111110,
          12'b010100xx1001,
          12'b010110000100,
          12'b010110000101,
          12'b010110000110,
          12'b010110001100,
          12'b010110001101,
          12'b010110001110,
          12'b010110010100,
          12'b010110010101,
          12'b010110010110,
          12'b010110011100,
          12'b010110011101,
          12'b010110011110,
          12'b010110111100,
          12'b010110111101,
          12'b010110111110,
          12'b1xxx00xxxx00,
          12'b1xxx00110100,
          12'b1xxx011x0100,
          12'b1xxx01000100,
          12'b1xxx01xx0010,
          12'b1xxx01xx1010: cflg_en = 1'b1;
          default:          cflg_en = 1'b0;
        endcase
      end
      default:              cflg_en = 1'b0;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* temporary flag control                                                                */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `OF1B:                tflg_ctl = `TFLG_Z;
      `RD1A,
      `RD2A: begin
        casex ({page_reg, inst_reg})
          12'b1xxx10100011,
          12'b1xxx10101011,
          12'b1xxx10110011,
          12'b1xxx10111011: tflg_ctl = `TFLG_1;
          default:          tflg_ctl = `TFLG_Z;
          endcase
        end
      `BLK1:                tflg_ctl = `TFLG_B;
      default:              tflg_ctl = `TFLG_NUL;
      endcase
    end

  endmodule





