//this code is generate automatically by https://www.ghsi.de/CRC/index.php?
//for compare.
module crc_7(
    input    clk, rst,
    input    crc_en,
    input    sda_i,
    output   reg [ 6: 0] crc_o
    );

    wire  inv = sda_i ^ crc_o[6];
    //CRC-7	= x7 + x3 + 1 
    always @(posedge clk or posedge rst)  begin
        if (rst) begin
            crc_o <= 0;           
        end
        else begin
            if (crc_en == 1)  begin
                crc_o[6] <= crc_o[5];
                crc_o[5] <= crc_o[4];
                crc_o[4] <= crc_o[3];
                crc_o[3] <= crc_o[2] ^ inv;
                crc_o[2] <= crc_o[1];
                crc_o[1] <= crc_o[0];
                crc_o[0] <= inv;
            end
        end
     end
   
endmodule

