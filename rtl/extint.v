/*******************************************************************************************/
/**                                                                                       **/
/** COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED          **/
/**                                                                                       **/
/** external interface module                                         Rev 0.0  07/21/2011 **/
/**                                                                                       **/
/*******************************************************************************************/
module extint (data_in, dma_ack, ftch_tran, halt_tran, iack_tran, io_addr_out, io_data_out,
               io_read, io_strobe, io_tran, ivec_rd, mem_addr_out, mem_data_out, mem_rd,
               mem_tran, mem_wr, reti_tran, t1, addr_reg_in, clkc, dmar_reg,
               dout_io_reg, dout_mem_reg, halt_nxt, if_frst, inta_frst, io_data_in,
               ivec_data_in, ld_dmaa, ld_wait, mem_data_in, output_inh, rd_frst, rd_nxt,
               resetb, reti_nxt, tran_sel, wr_frst);

  input         clkc;          /* main cpu clock                                           */
  input         dmar_reg;      /* latched dma request                                      */
  input         halt_nxt;      /* halt cycle identifier                                    */
  input         if_frst;       /* first part of fetch cycle identifier                     */
  input         inta_frst;     /* first part of intack cycle identifier                    */
  input         ld_dmaa;       /* load dma request                                         */
  input         ld_wait;       /* load wait request                                        */
  input         output_inh;    /* disable cpu outputs                                      */
  input         rd_frst;       /* first part of read cycle identifier                      */
  input         rd_nxt;        /* read cycle identifier                                    */
  input         resetb;        /* internal reset                                           */
  input         reti_nxt;      /* reti cycle identifier                                    */
  input         wr_frst;       /* first part of write cycle identifier                     */
  input   [7:0] dout_io_reg;   /* io data output                                           */
  input   [7:0] dout_mem_reg;  /* mem data output                                          */
  input   [7:0] io_data_in;    /* i/o input data bus                                       */
  input   [7:0] ivec_data_in;  /* interrupt vector bus                                     */
  input   [7:0] mem_data_in;   /* memory input bus                                         */
  input  [15:0] addr_reg_in;   /* processor logical address bus                            */
  input  [`TTYPE_IDX:0] tran_sel;    /* transaction type select                            */
  output        dma_ack;       /* dma acknowledge                                          */
  output        ftch_tran;     /* instruction fetch transaction                            */
  output        halt_tran;     /* halt transaction                                         */
  output        iack_tran;     /* interrupt acknowledge transaction                        */
  output        io_read;       /* i/o read enable                                          */
  output        io_strobe;     /* i/o data strobe                                          */
  output        io_tran;       /* i/o transaction                                          */
  output        ivec_rd;       /* interrupt vector enable                                  */
  output        mem_rd;        /* memory read enable                                       */
  output        mem_tran;      /* memory transaction                                       */
  output        mem_wr;        /* memory write enable                                      */
  output        reti_tran;     /* return from interrupt transaction                        */
  output        t1;            /* first clock of transaction                               */
  output  [7:0] data_in;       /* data input bus                                           */
  output  [7:0] io_data_out;   /* i/o output data bus                                      */
  output  [7:0] mem_data_out;  /* memory output data bus                                   */
  output [15:0] io_addr_out;   /* i/o address bus                                          */
  output [15:0] mem_addr_out;  /* memory address bus                                       */

  /*****************************************************************************************/
  /*                                                                                       */
  /* signal declarations                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  wire          ld_io_addr;                                /* update io address            */
  wire          ld_mem_addr;                               /* update memory address        */
  wire    [7:0] io_data_out;                               /* i/o output data bus          */
  wire    [7:0] mem_data_out;                              /* memory output data bus       */

  reg           dma_ack;                                   /* dma acknowledge              */
  reg           ftch_tran;                                 /* inst fetch transaction       */
  reg           halt_tran;                                 /* halt transaction             */
  reg           iack_tran;                                 /* int ack transaction          */
  reg           io_read;                                   /* i/o read enable              */
  reg           io_tran;                                   /* i/o transaction              */
  reg           io_strobe;                                 /* i/o data strobe              */
  reg           ivec_rd;                                   /* interrupt vector enable      */
  reg           mem_rd;                                    /* memory read enable           */
  reg           mem_tran;                                  /* memory transaction           */
  reg           mem_wr;                                    /* memory write enable          */
  reg           out_inh_reg;                               /* latched output inhibit       */
  reg           reti_tran;                                 /* reti transaction             */
  reg           t1;                                        /* first clock of transaction   */
  reg     [7:0] data_in;                                   /* data input bus               */
  reg    [15:0] io_addr_out;                               /* i/o address bus              */
  reg    [15:0] mem_addr_out;                              /* memory address bus           */

  /*****************************************************************************************/
  /*                                                                                       */
  /* misc signals & buses                                                                  */
  /*                                                                                       */
  /*****************************************************************************************/
  assign io_data_out  = (out_inh_reg) ? 8'h00 : dout_io_reg;
  assign mem_data_out = (out_inh_reg) ? 8'h00 : dout_mem_reg;
  assign ld_io_addr   = tran_sel[`TT_IO] || output_inh;
  assign ld_mem_addr  = tran_sel[`TT_IAK] || tran_sel[`TT_IDL] || tran_sel[`TT_IF] ||
                        tran_sel[`TT_MEM] || tran_sel[`TT_STK];

  always @ (iack_tran or io_tran or io_data_in or ivec_data_in or mem_data_in) begin
    case ({iack_tran, io_tran})
      2'b01:    data_in = io_data_in;
      2'b10:    data_in = ivec_data_in;
      default:  data_in = mem_data_in;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* timing generation                                                                     */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (posedge clkc or negedge resetb) begin
    if (!resetb) begin
      dma_ack      <= 1'b0;
      ftch_tran    <= 1'b0;
      halt_tran    <= 1'b0;
      iack_tran    <= 1'b0;
      io_addr_out  <= 16'h0000;
      io_read      <= 1'b0;
      io_tran      <= 1'b0;
      mem_addr_out <= 16'h0000;
      mem_tran     <= 1'b0;
      out_inh_reg  <= 1'b0;
      reti_tran    <= 1'b0;
      end
    else if (|tran_sel) begin
      dma_ack      <= ld_dmaa && dmar_reg;
      ftch_tran    <= tran_sel[`TT_IF];
      halt_tran    <= halt_nxt;
      iack_tran    <= tran_sel[`TT_IAK];
      if (ld_io_addr) io_addr_out <= (output_inh) ? 16'h0000 : addr_reg_in;
      io_read      <= tran_sel[`TT_IO] && rd_nxt;
      io_tran      <= tran_sel[`TT_IO];
      if (ld_mem_addr) mem_addr_out <= (output_inh) ? 16'h0000 : addr_reg_in;
      mem_tran     <= (tran_sel[`TT_IDL] || tran_sel[`TT_IF] || tran_sel[`TT_MEM] ||
                       tran_sel[`TT_STK]) && !output_inh;
      out_inh_reg  <= output_inh;
      reti_tran    <= reti_nxt;
      end
    end

  always @ (posedge clkc or negedge resetb) begin
    if (!resetb) begin
      io_strobe    <= 1'b0;
      ivec_rd      <= 1'b0;
      mem_rd       <= 1'b0;
      mem_wr       <= 1'b0;
      t1           <= 1'b0;
      end
    else begin
      io_strobe    <= io_tran && (rd_frst || wr_frst);
      ivec_rd      <= iack_tran && inta_frst;
      mem_rd       <= (if_frst || (mem_tran && rd_frst)) && ld_wait;
      mem_wr       <= mem_tran && wr_frst;
      t1           <= |tran_sel && !(halt_nxt || dmar_reg);
      end
    end

  endmodule










