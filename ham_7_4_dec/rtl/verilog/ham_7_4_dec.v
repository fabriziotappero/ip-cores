///
module ham_7_4_dec(

clk, 
reset,
datain, 
dvin,
dvout, 
code);

input clk, reset, datain, dvin;
output dvout;
reg dvout;
output code;
reg code;



reg [6:0]
datareg;
reg [6:0]
outdatareg;


reg [2:0] 
cntr,
ocntr, 
scntr;

reg [2:0]
s_;

reg ocntr_en;

wire
and2,
and1,
and0,
xor2,
xor1,
xor0,
err;

assign and2 = datareg[0] & cntr[2];
assign and1 = datareg[0] & cntr[1];
assign and0 = datareg[0] & cntr[0];

assign xor2 = and2 ^ s_[2];
assign xor1 = and1 ^ s_[1];
assign xor0 = and0 ^ s_[0];

assign err = (!scntr[2])&(!scntr[1])&scntr[0];

/////////////////////////////////////////////////


always@(posedge clk or negedge reset)

if (!reset)

s_<=0;

else if (cntr==0)

s_<=0;

else if ( (!dvin)||(cntr==7) )

s_<={xor2,xor1,xor0};

/////////////////////////////////////////////////
always@(posedge clk or negedge reset)

if (!reset)

scntr<=0;

else if (cntr==7)

scntr<={xor2, xor1, xor0};

else if (scntr!=0)

scntr<=scntr-1;

/////////////////////////////////////////////////

always@(posedge clk or negedge reset)

if (!reset)

cntr<=0;

else if (cntr==7)

cntr<=0;

else if (!dvin)

cntr<=cntr+1;

/////////////////////////////////////////////////

always@(posedge clk or negedge reset)

if(!reset)

datareg<=0;

else if (!dvin)

datareg<={datareg[5:0], datain};


/////////////////////////////////////////////////
always@(posedge clk or negedge reset)

if (!reset)

ocntr<=0;

else if (ocntr_en)

ocntr<=ocntr+1;


/////////////////////////////////////////////////
always@(posedge clk or negedge reset)

if (!reset)

ocntr_en<=0;

else if (cntr==7)

ocntr_en<=1;

else if ( (ocntr==7)&&(cntr!=7) )

ocntr_en<=0;

/////////////////////////////////////////////////

always@(posedge clk or negedge reset)

if (!reset)

dvout<=1;

else if (ocntr==7)

dvout<=1;

else if (ocntr_en)

dvout<=0;


/////////////////////////////////////////////////
always@(posedge clk or negedge reset)

if (!reset)

outdatareg<=0;

else if (cntr==7)

outdatareg<=datareg;

else if (ocntr_en)

outdatareg<={outdatareg[5:0],1'b0};

/////////////////////////////////////////////////
always@(posedge clk or negedge reset)

if (!reset)

code<=0;

else

code<=outdatareg[6]^err;

/////////////////////////////////////////////////


endmodule












