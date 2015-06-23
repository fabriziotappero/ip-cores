/*



  parameter int  pA_W  = 32 ;
  parameter int  pD_W  = 32 ;
  parameter int pSEL_W = 4 ;



  logic                wb_tb_simple_ram_slave__clk    ;
  logic                wb_tb_simple_ram_slave__rst    ;
  logic                wb_tb_simple_ram_slave__cyc_i  ;
  logic                wb_tb_simple_ram_slave__stb_i  ;
  logic                wb_tb_simple_ram_slave__we_i   ;
  logic   [pA_W-1 : 0] wb_tb_simple_ram_slave__adr_i  ;
  logic   [pD_W-1 : 0] wb_tb_simple_ram_slave__dat_i  ;
  logic [pSEL_W-1 : 0] wb_tb_simple_ram_slave__sel_i  ;
  logic                wb_tb_simple_ram_slave__ack_o  ;
  logic                wb_tb_simple_ram_slave__err_o  ;
  logic                wb_tb_simple_ram_slave__rty_o  ;
  logic   [pD_W-1 : 0] wb_tb_simple_ram_slave__dat_o  ;



  wb_tb_simple_ram_slave
  #(
    .pA_W   ( pA_W   ) ,
    .pD_W   ( pD_W   ) ,
    .pSEL_W ( pSEL_W )
  )
  wb_tb_simple_ram_slave
  (
    .clk   ( wb_tb_simple_ram_slave__clk   ) ,
    .rst   ( wb_tb_simple_ram_slave__rst   ) ,
    .cyc_i ( wb_tb_simple_ram_slave__cyc_i ) ,
    .stb_i ( wb_tb_simple_ram_slave__stb_i ) ,
    .we_i  ( wb_tb_simple_ram_slave__we_i  ) ,
    .adr_i ( wb_tb_simple_ram_slave__adr_i ) ,
    .dat_i ( wb_tb_simple_ram_slave__dat_i ) ,
    .sel_i ( wb_tb_simple_ram_slave__sel_i ) ,
    .ack_o ( wb_tb_simple_ram_slave__ack_o ) ,
    .err_o ( wb_tb_simple_ram_slave__err_o ) ,
    .rty_o ( wb_tb_simple_ram_slave__rty_o ) ,
    .dat_o ( wb_tb_simple_ram_slave__dat_o )
  );


  assign wb_tb_simple_ram_slave__clk   = '0 ;
  assign wb_tb_simple_ram_slave__rst   = '0 ;
  assign wb_tb_simple_ram_slave__cyc_i = '0 ;
  assign wb_tb_simple_ram_slave__stb_i = '0 ;
  assign wb_tb_simple_ram_slave__we_i  = '0 ;
  assign wb_tb_simple_ram_slave__adr_i = '0 ;
  assign wb_tb_simple_ram_slave__dat_i = '0 ;
  assign wb_tb_simple_ram_slave__sel_i = '0 ;



*/

//
// this interface is for write/read debug only
//

interface wb_tb_simple_ram_slave
#(
  parameter int pA_W   = 32 ,
  parameter int pD_W   = 32 ,
  parameter int pSEL_W = 4
)
(
  clk   ,
  rst   ,
  cyc_i ,
  stb_i ,
  we_i  ,
  adr_i ,
  dat_i ,
  sel_i ,
  ack_o ,
  err_o ,
  rty_o ,
  dat_o
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                clk   ;
  input  logic                rst   ;
  input  logic                cyc_i ;
  input  logic                stb_i ;
  input  logic                we_i  ;
  input  logic   [pA_W-1 : 0] adr_i ;
  input  logic   [pD_W-1 : 0] dat_i ;
  input  logic [pSEL_W-1 : 0] sel_i ;
  output logic                ack_o ;
  output logic                err_o ;
  output logic                rty_o ;
  output logic   [pD_W-1 : 0] dat_o ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  default clocking cb @(posedge clk);
    default input #1ns output #1ns;
    output ack_o, err_o, rty_o, dat_o;
    input  cyc_i, stb_i, we_i, adr_i, dat_i, sel_i;
  endclocking

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------
  
  localparam    lp_ADDR_32BIT_RANGE     =   33'h1_0000_0000;
  localparam    lp_MEM_ADDR_32BIT_RANGE =   (lp_ADDR_32BIT_RANGE-1);
  
  bit [pD_W-1 : 0] ram [16*512 : 0];// usually lp_MY_MEM_SIZE < 8K WORDs

  bit rnd = 0;  // use random wait states
  int ws  = 1;  // wait states
  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  initial begin : ini
    cb.ack_o <= 1'b0;
    cb.err_o <= 1'b0;
    cb.rty_o <= 1'b0;
    cb.dat_o <= 1'b0;

    run ();
  end

  bit tack;

  assign #1ns tack = (cyc_i & stb_i);

  task run ();
    fork
      forever begin
        if (ws == 0) begin // ws == 0
          force ack_o = tack;
          wait (cyc_i);
          //
          if (rnd)
            ws = $urandom_range(0, 5);
          //
          if (cyc_i & stb_i) begin
            if (we_i)
              ram[adr_i] = dat_i;
            else
              dat_o <= #1ns ram[adr_i];
          end
          //
          ##1;
          release ack_o;
        end // ws == 0

        else begin // ws > 0
          ##1;
          if (cb.cyc_i & cb.stb_i) begin

            ##(ws-1);

            if (rnd)
              ws = $urandom_range(0, 5);

            if (cb.we_i)
              ram[cb.adr_i] = cb.dat_i;
            else
              cb.dat_o <= ram[cb.adr_i];

            cb.ack_o <= 1'b1;
            ##1;
            cb.ack_o <= 1'b0;
          end // access
        end // ws
      end // forever
    join_none
  endtask


  task stop ();
    disable run ;
  endtask

endinterface
