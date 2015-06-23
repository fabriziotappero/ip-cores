module sram_model (
CLK,
NCE,   //Wr and Rd Select signal
NWRT,
NOE,
DIN,
ADDR,
DOUT
);
parameter MEM_ADDR_W = 10;
parameter MEM_DATA_W = 32;
localparam MEM_DEPTH = 1<<MEM_ADDR_W;
input                   CLK;
input                   NCE;
input                   NWRT;
input                   NOE;
input [MEM_ADDR_W-1:0]  ADDR;
input [MEM_DATA_W-1:0]  DIN;
output [MEM_DATA_W-1:0] DOUT;

reg [MEM_DATA_W-1:0]  r_din;
reg [MEM_DATA_W-1:0]  write_data;
reg [MEM_DATA_W-1:0]  do_reg;
reg [MEM_ADDR_W-1:0]  r_addr;
reg                   r_nwrt;
reg                   r_nce;


reg [MEM_DATA_W-1:0]  array[MEM_DEPTH-1:0];

event write, read; 

always @(posedge CLK) begin
  r_din = DIN;
  r_addr = ADDR;
  r_nce  = NCE;
  r_nwrt = NWRT;
  if (!r_nce && !r_nwrt) 
    ->write;
  if (!r_nce &&  r_nwrt)
    ->read;
end 
always @(write) begin 
   write_data = r_din;
   array[r_addr] = write_data;
end 
 
always @(read) begin 
  do_reg = array[r_addr];
end  

wire [MEM_DATA_W-1:0]  BDO;
genvar i;
generate for (i=0; i<MEM_DATA_W; i=i+1) begin 
            buf (BDO[i], do_reg[i]);
            bufif0 (DOUT[i], BDO[i], NOE);
         end
endgenerate 


endmodule
