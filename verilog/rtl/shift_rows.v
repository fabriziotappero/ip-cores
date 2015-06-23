//---------------------------------------------------------------------------------------
//
//  shift_rows module file (converted from shift_rows function)
//
//  Description:
//     shift rows for encryption
//
//  Author(s):
//      - Moti Litochevski
//
//---------------------------------------------------------------------------------------

module shift_rows (
	si, so 
);
 
input	[127:0]	si;
output	[127:0]	so;
 
wire [127:0] so;

assign so[127:96] = {si[127:120],si[87:80],si[47:40],si[7:0]};
assign so[95:64] = {si[95:88],si[55:48],si[15:8],si[103:96]};
assign so[63:32] = {si[63:56],si[23:16],si[111:104],si[71:64]};
assign so[31:0] = {si[31:24],si[119:112],si[79:72],si[39:32]};

endmodule
