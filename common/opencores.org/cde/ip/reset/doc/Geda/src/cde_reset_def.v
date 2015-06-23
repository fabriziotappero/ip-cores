module 
cde_reset_def 
#(parameter  WIDTH = 1,  // width of reset bus
  parameter  DEPTH = 1   // depth of synchronizer
 )(

   input  clk,
   input  async_reset_n,            
   input  atg_asyncdisable,         
   input  [WIDTH - 1:0] sync_reset,               // signals to control resets

   output [WIDTH - 1:0] reset_n_out,              // Async reset
   output [WIDTH - 1:0] reset_out                 // Sync reset

   
);

// ****************************************************************************
// Reg declarations
// ****************************************************************************


wire  [WIDTH - 1:0]   reset_synced;


  cde_sync_with_reset 
  #(.WIDTH  (WIDTH),
    .DEPTH  (DEPTH),
    .RST_VAL({WIDTH{1'b1}})
   ) 
  cde_1(
    .clk                 (clk),
    .reset_n             (async_reset_n),
    .data_in             (sync_reset),
    .data_out            (reset_synced)
       );
   

  cde_reset_asyncdisable 
   #(.WIDTH(WIDTH)) 
  cde_2(
    .reset               (1'b0),
    .reset_n             (async_reset_n),
    .atg_asyncdisable    (atg_asyncdisable),
    .sync_reset          (reset_synced),
    .reset_n_out         (reset_n_out),
    .reset_out           (reset_out)
     );


   
endmodule

