module 
cde_reset_asyncdisable
#(parameter    WIDTH = 1      ) 
(
   input  wire               reset,                      
   input  wire               reset_n,                    
   input  wire               atg_asyncdisable,           
   input  wire [WIDTH - 1:0] sync_reset,   

   output wire [WIDTH - 1:0] reset_n_out,
   output wire [WIDTH - 1:0] reset_out
);

assign  reset_out   =   sync_reset                                 | {WIDTH{reset}};
assign  reset_n_out = (~sync_reset    | {WIDTH{atg_asyncdisable}}) & {WIDTH{reset_n}};
   
endmodule

