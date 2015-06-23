
module model_sd(
	input reset_n,
	
	input sd_clk,
	inout sd_cmd_io,
	inout sd_dat_io
);

reg sd_cmd_o;
reg sd_dat_o;
reg sd_cmd_enable;
reg sd_data_enable;

assign sd_cmd_io = (sd_cmd_enable == 1'b1) ? sd_cmd_o : 1'bZ;
assign sd_dat_io = (sd_data_enable == 1'b1) ? sd_dat_o : 1'bZ;

reg [3:0] cmd_state;
reg [47:0] cmd_contents;
reg [135:0] cmd_reply;
reg [7:0] cmd_counter;
reg [6:0] crc7;

parameter [3:0]
	S_CMD_START_BIT = 4'd0,
	S_CMD_CONTENTS = 4'd1,
	S_CMD_CRC7_END_BIT = 4'd2,
	S_CMD_CHECK = 4'd3,
	S_CMD_WAIT = 4'd4,
	S_CMD_SEND_CONTENTS = 4'd5,
	S_CMD_SEND_CRC7 = 4'd6,
	S_CMD_SEND_END_BIT = 4'd7,
	S_CMD_SEND_FINISHED = 4'd8;
	
always @(posedge sd_clk or negedge reset_n) begin
	if(reset_n == 1'b0) begin
		cmd_state <= S_CMD_START_BIT;
		sd_cmd_enable <= 1'b0;
		sd_cmd_o <= 1'b1;
		cmd_contents <= 48'd0;
		cmd_counter <= 8'd0;
		crc7 <= 7'd0;
	end
	else if(cmd_state == S_CMD_START_BIT) begin
		if(sd_cmd_io == 1'b0) begin
			cmd_contents <= { cmd_contents[46:0], sd_cmd_io };
			crc7 <= { sd_cmd_io ^ crc7[0], crc7[6:5], sd_cmd_io ^ crc7[4] ^ crc7[0], crc7[3:1] };
			cmd_state <= S_CMD_CONTENTS;
			cmd_counter <= 8'd0;
		end
	end
	else if(cmd_state == S_CMD_CONTENTS) begin
		cmd_contents <= { cmd_contents[46:0], sd_cmd_io };
		crc7 <= { sd_cmd_io ^ crc7[0], crc7[6:5], sd_cmd_io ^ crc7[4] ^ crc7[0], crc7[3:1] };
		
		if(cmd_counter == 8'd38) begin
			cmd_state <= S_CMD_CRC7_END_BIT;
			cmd_counter <= 8'd0;
		end
		else cmd_counter <= cmd_counter + 8'd1;
	end
	else if(cmd_state == S_CMD_CRC7_END_BIT) begin
		cmd_contents <= { cmd_contents[46:0], sd_cmd_io };
		
		if(cmd_counter == 8'd7) begin
			cmd_state <= S_CMD_CHECK;
			cmd_counter <= 8'd0;
		end
		else cmd_counter <= cmd_counter + 8'd1;
	end
	else if(cmd_state == S_CMD_CHECK) begin
		crc7 <= 7'd0;
		
		if(
			cmd_contents == { 1'b0, 1'b1, 6'd0, 32'd0, crc7[0],crc7[1],crc7[2],crc7[3],crc7[4],crc7[5],crc7[6], 1'b1 }
		) begin 
			$display("CMD0");
			cmd_state <= S_CMD_START_BIT;
		end
		else if(
			cmd_contents == { 1'b0, 1'b1, 6'd8, 20'd0, 4'b0001, 8'b10101010, crc7[0],crc7[1],crc7[2],crc7[3],crc7[4],crc7[5],crc7[6], 1'b1 }
		) begin 
			$display("CMD8");
			cmd_reply[135:88] <= { 1'b0, 1'b0, 6'd8, 20'd0, 4'b0001, cmd_contents[15:8], 7'd0, 1'b1}; 
			cmd_state <= S_CMD_WAIT;
		end
		else if(
			cmd_contents == { 1'b0, 1'b1, 6'd55, 16'd0, 16'd0, crc7[0],crc7[1],crc7[2],crc7[3],crc7[4],crc7[5],crc7[6], 1'b1 }
		) begin 
			$display("CMD55");
			cmd_reply[135:88] <= { 1'b0, 1'b0, 6'd55, 32'b100000, 7'd0, 1'b1}; 
			cmd_state <= S_CMD_WAIT;
		end
		else if(
			cmd_contents == { 1'b0, 1'b1, 6'd41, 1'b0, 1'b1, 6'b0, 24'b0001_0000_0000_0000_0000_0000,
				crc7[0],crc7[1],crc7[2],crc7[3],crc7[4],crc7[5],crc7[6], 1'b1 }
		) begin 
			$display("CMD41");
			cmd_reply[135:88] <= { 1'b0, 1'b0, 6'b111111, 32'b1100_0000_00000000_00000000_00000000, 7'b1111111, 1'b1}; 
			cmd_state <= S_CMD_WAIT;
		end
		else if(
			cmd_contents == { 1'b0, 1'b1, 6'd2, 32'd0, crc7[0],crc7[1],crc7[2],crc7[3],crc7[4],crc7[5],crc7[6], 1'b1 }
		) begin 
			$display("CMD2");
			cmd_reply[135:0] <= { 135'd0, 1'b1}; 
			cmd_state <= S_CMD_WAIT;
		end
		else if(
			cmd_contents == { 1'b0, 1'b1, 6'd3, 32'd0, crc7[0],crc7[1],crc7[2],crc7[3],crc7[4],crc7[5],crc7[6], 1'b1 }
		) begin 
			$display("CMD3");
			cmd_reply[135:88] <= { 1'b0, 1'b0, 6'd3, 16'hA0A0, 16'b0, 7'd0, 1'b1}; 
			cmd_state <= S_CMD_WAIT;
		end
		else if(
			cmd_contents == { 1'b0, 1'b1, 6'd7, 16'hA0A0, 16'd0, crc7[0],crc7[1],crc7[2],crc7[3],crc7[4],crc7[5],crc7[6], 1'b1 }
		) begin 
			$display("CMD7: %08h", cmd_contents);
			
			cmd_reply[135:88] <= { 1'b0, 1'b0, 6'd7, 32'b0, 7'd0, 1'b1}; 
			cmd_state <= S_CMD_WAIT;
		end
		else if(
			cmd_contents[47:40] == { 1'b0, 1'b1, 6'd17 } && cmd_contents[7:0] == { crc7[0],crc7[1],crc7[2],crc7[3],crc7[4],crc7[5],crc7[6], 1'b1 }
		) begin 
			$display("CMD17: %08h", cmd_contents);
			
			cmd_reply[135:88] <= { 1'b0, 1'b0, 6'd17, 32'b0, 7'd0, 1'b1}; 
			cmd_state <= S_CMD_WAIT;
		end
		else if(
			cmd_contents[47:40] == { 1'b0, 1'b1, 6'd24 } && cmd_contents[7:0] == { crc7[0],crc7[1],crc7[2],crc7[3],crc7[4],crc7[5],crc7[6], 1'b1 }
		) begin 
			$display("CMD24: %08h", cmd_contents);
			
			cmd_reply[135:88] <= { 1'b0, 1'b0, 6'd24, 32'b0, 7'd0, 1'b1}; 
			cmd_state <= S_CMD_WAIT;
		end
		else begin
			$display("Other cmd: %02d, contents: %08h", cmd_contents[45:40], cmd_contents);
			cmd_state <= S_CMD_START_BIT;
		end
	end
	else if(cmd_state == S_CMD_WAIT) begin
		if(cmd_counter == 8'd15) begin
			cmd_counter <= 8'd0;
			sd_cmd_enable <= 1'b1;
			sd_cmd_o <= 1'b1;
			cmd_state <= S_CMD_SEND_CONTENTS;
		end
		else cmd_counter <= cmd_counter + 8'd1;
	end
	else if(cmd_state == S_CMD_SEND_CONTENTS) begin
		sd_cmd_o <= cmd_reply[135];
		cmd_reply <= { cmd_reply[134:0], 1'b0 };
		crc7 <= { cmd_reply[135] ^ crc7[0], crc7[6:5], cmd_reply[135] ^ crc7[4] ^ crc7[0], crc7[3:1] };
		
		if(cmd_counter == 8'd47 && cmd_contents[45:40] == 6'd41) begin
			cmd_counter <= 8'd0;
			cmd_state <= S_CMD_SEND_FINISHED;
		end
		else if(cmd_counter == 8'd39 && cmd_contents[45:40] != 6'd2 && cmd_contents[45:40] != 6'd41) begin
			cmd_counter <= 8'd0;
			cmd_state <= S_CMD_SEND_CRC7;
		end
		else if(cmd_counter == 8'd135 && cmd_contents[45:40] == 8'd2) begin
			cmd_counter <= 8'd0;
			cmd_state <= S_CMD_SEND_FINISHED;
		end
		else cmd_counter <= cmd_counter + 8'd1;
	end
	else if(cmd_state == S_CMD_SEND_CRC7) begin
		sd_cmd_o <= crc7[0];
		crc7 <= { 1'b0, crc7[6:1] };
		
		if(cmd_counter == 8'd6) begin
			cmd_counter <= 8'd0;
			cmd_state <= S_CMD_SEND_END_BIT;
		end
		else cmd_counter <= cmd_counter + 8'd1;
	end
	else if(cmd_state == S_CMD_SEND_END_BIT) begin
		sd_cmd_o <= 1'b1;
		cmd_state <= S_CMD_SEND_FINISHED;
	end
	else if(cmd_state == S_CMD_SEND_FINISHED) begin
		sd_cmd_o <= 1'b1;
		sd_cmd_enable <= 1'b0;
		crc7 <= 7'd0;
		cmd_state <= S_CMD_START_BIT;
	end
end

reg [2:0] data_state;
reg [11:0] data_counter;
reg [4095:0] data_contents;
reg [15:0] crc16;

parameter [2:0]
	S_DATA_IDLE = 3'd0,
	S_DATA_R1B_REPLY = 3'd1,
	S_DATA_R1B_REPLY_1 = 3'd2,
	S_DATA_READ = 3'd3,
	S_DATA_READ_1 = 3'd4,
	S_DATA_READ_2 = 3'd5,
	S_DATA_READ_3 = 3'd6;
	
	
always @(posedge sd_clk or negedge reset_n) begin
	if(reset_n == 1'b0) begin
		sd_data_enable <= 1'b0;
		sd_dat_o <= 1'b1;
		data_state <= S_DATA_IDLE;
		data_counter <= 12'd0;
		crc16 <= 16'd0;
	end
	else if(data_state == S_DATA_IDLE) begin
		if(cmd_contents[45:40] == 6'd7 && cmd_state == S_CMD_SEND_CRC7) begin
			sd_data_enable <= 1'b1;
			sd_dat_o <= 1'b1;
			data_state <= S_DATA_R1B_REPLY;
		end
		else if(cmd_contents[45:40] == 6'd17 && cmd_state == S_CMD_SEND_CRC7) begin
			sd_data_enable <= 1'b1;
			sd_dat_o <= 1'b1;
			data_contents <= { 1'b1, 31'b0, 1'b1, 4062'd0, 1'b1 };
			data_state <= S_DATA_READ;
		end
	end
	else if(data_state == S_DATA_R1B_REPLY) begin
		if(data_counter == 12'd16) begin
			sd_dat_o <= 1'b1;
			data_counter <= 12'd0;
			data_state <= S_DATA_R1B_REPLY_1;
		end
		else begin
			sd_dat_o <= 1'b0;
			data_counter <= data_counter + 12'd1;
		end
	end
	else if(data_state == S_DATA_R1B_REPLY_1) begin
		sd_data_enable <= 1'b0;
		data_state <= S_DATA_IDLE;
	end
	
	
	else if(data_state == S_DATA_READ) begin
		sd_dat_o <= 1'b0;
		crc16 <= { 1'b0 ^ crc16[0], crc16[15:12], 1'b0 ^ crc16[11] ^ crc16[0], crc16[10:5],
			1'b0 ^ crc16[4] ^ crc16[0], crc16[3:1] };
		
		data_counter <= 12'd0;
		data_state <= S_DATA_READ_1;
	end
	else if(data_state == S_DATA_READ_1) begin
		sd_dat_o <= data_contents[4095];
		crc16 <= { data_contents[4095] ^ crc16[0], crc16[15:12], data_contents[4095] ^ crc16[11] ^ crc16[0], crc16[10:5],
			data_contents[4095] ^ crc16[4] ^ crc16[0], crc16[3:1] };
		data_contents <= { data_contents[4094:0], 1'b0 };
		
		if(data_counter == 12'd4095) begin
			data_counter <= 12'd0;
			data_state <= S_DATA_READ_2;
		end
		else data_counter <= data_counter + 12'd1;
	end
	
	else if(data_state == S_DATA_READ_2) begin
		sd_dat_o <= crc16[0];
		
		if(data_counter == 12'd16) begin
			data_counter <= 12'd0;
			data_state <= S_DATA_READ_3;
		end
		else begin
			crc16 <= { 1'b1, crc16[15:1] };
			data_counter <= data_counter + 12'd1;
		end
	end
	else if(data_state == S_DATA_READ_3) begin
		sd_data_enable <= 1'b0;
		crc16 <= 16'd0;
		data_state <= S_DATA_IDLE;
	end
	
end

endmodule

