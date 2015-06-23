module gray2bin (bin, gray);

parameter lpm_size = 4;

output [lpm_size-1:0] bin;
input [lpm_size-1:0] gray;
reg [lpm_size-1:0] bin;

integer i;
always @(gray)
    for (i=0; i<lpm_size; i=i+1)
        bin[i] = ^(gray>>i);
endmodule