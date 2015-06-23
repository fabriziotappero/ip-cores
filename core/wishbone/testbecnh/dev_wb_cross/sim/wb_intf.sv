

interface wb_m_if
#(
  parameter int   pA_W = 32 ,
  parameter int   pD_W = 32 ,
  parameter int pSEL_W =  4
)
(
  input wb_clk, wb_rst
);
  logic                cyc_o ;
  logic                stb_o ;
  logic                we_o  ;
  logic   [pA_W-1 : 0] adr_o ;
  logic   [pD_W-1 : 0] dat_o ;
  logic [pSEL_W-1 : 0] sel_o ;
  logic                ack_i ;
  logic                err_i ;
  logic                rty_i ;
  logic   [pD_W-1 : 0] dat_i ;


  default clocking cb @(posedge wb_clk);
    default input #1ns output #1ns;
    output cyc_o, stb_o, we_o, adr_o, dat_o, sel_o;
    input ack_i, err_i, rty_i, dat_i;
  endclocking

  //------------------------------------------------------------------------------------------------------
  // base drivers
  //------------------------------------------------------------------------------------------------------

  // init
  task init ();
    cyc_o <= '0;
    stb_o <= '0;
    we_o  <= '0;
    adr_o <= '0;
    dat_o <= '0;
    sel_o <= '1;
  endtask

  //
  // write
  task write (output int err, input bit [pA_W-1 : 0] addr, input bit [pD_W-1 : 0] data, input int delay = 0, hold = 0);
    cb.cyc_o <= 1'b1;
    cb.stb_o <= 1'b1;
    cb.we_o  <= 1'b1;
    cb.adr_o <= addr;
    cb.dat_o <= data; //$display("[%t]: %m, ps, adr_o==%h, dat_o==%h", $time, addr, data);

    do
      ##1;
    while ((cb.ack_i | cb.err_i | cb.rty_i) != 1'b1);

    err = {cb.err_i , cb.rty_i};

    cb.cyc_o <= hold;
    cb.stb_o <= 1'b0;
    cb.we_o  <= 1'b0;

    ##(delay); //$display("[%t]: %m, pe", $time);
  endtask

  task write_begin (output int err, input bit [pA_W-1 : 0] addr, input bit [pD_W-1 : 0] data, input int delay = 0);
    write (err, addr, data, delay, 1); // hold bus
  endtask

  task write_end (output int err, input bit [pA_W-1 : 0] addr, input bit [pD_W-1 : 0] data, input int delay = 0);
    write(err, addr, data, delay, 0); // free bus
  endtask

  //
  // read
  task read (output int err, output bit [pD_W-1 : 0] data, input bit [pA_W-1 : 0] addr, input int delay = 0, hold = 0);
    cb.cyc_o <= 1'b1;
    cb.stb_o <= 1'b1;
    cb.we_o  <= 1'b0;
    cb.adr_o <= addr;

    do
      ##1;
    while ((cb.ack_i | cb.err_i | cb.rty_i) != 1'b1);

    err     = {cb.err_i , cb.rty_i};
    data    = cb.dat_i;

    cb.cyc_o <= hold;
    cb.stb_o <= 1'b0;
    cb.we_o  <= 1'b0;

    ##(delay);
  endtask

  task read_begin (output int err, output bit [pD_W-1 : 0] data, input bit [pA_W-1 : 0] addr, input int delay = 0);
    read (err, data, addr, delay, 1);
  endtask

  task read_end (output int err, output bit [pD_W-1 : 0] data, input bit [pA_W-1 : 0] addr, input int delay = 0);
    read (err, data, addr, delay, 0);
  endtask

endinterface

