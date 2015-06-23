 module 
  cpu_def 
    #( parameter 
      BOOT_VEC=8'hfc,
      CPU_ADD=16,
      PROG_ROM_ADD=0,
      PROG_ROM_WIDTH=16,
      PROG_ROM_WORDS=0,
      STACK_RAM_SIZE=8,
      STACK_RAM_WIDTH=16,
      STACK_RAM_WORDS=256,
      VEC_TABLE=8'hff)
     (
 input   wire                 clk,
 input   wire                 enable,
 input   wire                 nmi,
 input   wire                 reset,
 input   wire    [ 15 :  0]        rdata,
 input   wire    [ 7 :  0]        pg0_data,
 input   wire    [ 7 :  0]        vec_int,
 output   wire                 pg0_rd,
 output   wire                 pg0_wr,
 output   wire                 rd,
 output   wire                 wr,
 output   wire    [ 7 :  0]        alu_status,
 output   wire    [ 7 :  0]        pg0_add,
 output   wire    [ 7 :  0]        wdata,
 output   wire    [ CPU_ADD-1 :  0]        addr);
wire                        stk_pull;
wire                        stk_push;
wire     [ 15 :  0]              prog_data;
wire     [ 15 :  0]              stk_pull_data;
wire     [ 15 :  0]              stk_push_data;
wire     [ CPU_ADD-1 :  0]              prog_counter;
core_def
#( .BOOT_VEC (BOOT_VEC),
   .VEC_TABLE (VEC_TABLE))
core 
   (
    .addr      ( addr[15:0] ),
    .alu_status      ( alu_status[7:0] ),
    .clk      ( clk  ),
    .enable      ( enable  ),
    .nmi      ( nmi  ),
    .pg0_add      ( pg0_add[7:0] ),
    .pg0_data      ( pg0_data[7:0] ),
    .pg0_rd      ( pg0_rd  ),
    .pg0_wr      ( pg0_wr  ),
    .prog_counter      ( prog_counter[15:0] ),
    .prog_data      ( prog_data[15:0] ),
    .rd      ( rd  ),
    .rdata      ( rdata[15:0] ),
    .reset      ( reset  ),
    .stk_pull      ( stk_pull  ),
    .stk_pull_data      ( stk_pull_data[15:0] ),
    .stk_push      ( stk_push  ),
    .stk_push_data      ( stk_push_data[15:0] ),
    .vec_int      ( vec_int[7:0] ),
    .wdata      ( wdata[7:0] ),
    .wr      ( wr  ));
cde_sram_dp
#( .ADDR (PROG_ROM_ADD),
   .WIDTH (PROG_ROM_WIDTH),
   .WORDS (PROG_ROM_WORDS))
prog_rom 
   (
    .clk      ( clk  ),
    .cs      ( 1'b1  ),
    .raddr      ( prog_counter[PROG_ROM_ADD:1] ),
    .rd      ( 1'b1  ),
    .rdata      ( prog_data[15:0] ),
    .waddr      ( addr[PROG_ROM_ADD:1] ),
    .wdata      ( 16'h0000  ),
    .wr      ( 1'b0  ));
cde_lifo_def
#( .SIZE (STACK_RAM_SIZE),
   .WIDTH (STACK_RAM_WIDTH),
   .WORDS (STACK_RAM_WORDS))
stack_ram 
   (
    .clk      ( clk  ),
    .din      ( stk_push_data[15:0] ),
    .dout      ( stk_pull_data[15:0] ),
    .pop      ( stk_pull  ),
    .push      ( stk_push  ),
    .reset      ( reset  ));
  endmodule
