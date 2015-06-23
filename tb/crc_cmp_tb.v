module  crc_cmp_tb();

    parameter  datw  = 8;
    reg   clk, rst, rst_syn;
    reg   crc_en;
    reg   [15: 0] random_dat;
    wire  dat_i = random_dat[15];
    wire  [datw - 2: 0] dat_o, dat_o_2;
    
    initial  begin
        clk  = 0;
        forever  #5 clk = ~clk;
    end
    
    initial  begin
        rst_syn  = 0;
        crc_en   = 0;
    end
    
    initial  begin
             rst  = 0;
        #200 rst  = 1;
        #20  rst  = 0;
    end
    
    initial    begin
        @(negedge rst)
        repeat(20)	begin
			CRC_task;
			if (dat_o == dat_o_2)
				$display("\tData is correct!\n");
		end
    end
    
    task CRC_task;

    begin
        random_dat = 16'hff;//$random();
        rst_syn    = 1;
        #20
        rst_syn    = 0;
        repeat (16)    begin
            crc_en    = 1;
            @(posedge clk)
            random_dat    = random_dat << 1;
        end
        crc_en    = 0;
    end
    endtask
    
    
    cfg_crc
    #(
        .datw(datw),
        .coff(8'b1000_1001)
    ) CRC_F0 
    (
        .clk(clk), .rst(rst),
        .rst_syn(rst_syn),
        .crc_en(crc_en),
        .dat_i(dat_i),
        .dat_o(dat_o)
    );
	
	crc_7	CRC_F1(
		.clk(clk), .rst(rst_syn),
		.crc_en(crc_en),
		.sda_i(dat_i),
		.crc_o(dat_o_2)
    );
endmodule
