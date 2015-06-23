module  cfg_crc #(
        parameter  datw = 6,
        parameter  [datw - 1: 0] coff = 6'b10_0101
    )
    (
        input   clk, rst,
        input   rst_syn,
        input   crc_en,
        input   dat_i,
        output  reg  [datw - 2: 0] dat_o
    );
    
    wire    lsb	= dat_i ^ dat_o[datw - 2];
    integer i;
	
    always@(posedge clk or posedge rst)  begin
        if (rst)    
            dat_o    <= 0;
        else if (rst_syn)
            dat_o    <= 0;
        else if (crc_en)  begin
            dat_o[0] <= lsb;
            //dat_o[datw - 2: 1]	<= dat_o[datw - 3: 0] ^ coff[datw -2: 1];
			for (i = 0; i <= (datw - 3) ; i = i + 1) begin
				if (coff[i + 1])
					dat_o[i + 1] <= dat_o[i] ^ lsb;
				else
					dat_o[i + 1] <= dat_o[i];
			end
        end
    end

endmodule
