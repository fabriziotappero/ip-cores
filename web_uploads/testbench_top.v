`timescale 1 ns / 1 ns

module testbench();

// DATE:     Mon May 19 20:22:16 2003 
// TITLE:    
// MODULE:   TDM_Switch
// DESIGN:   TDM_Switch
// FILENAME: TDM_Switch
// PROJECT:  tdm_switch
// VERSION:  Version


// Inputs
    reg CLKIN;
    reg reset;
    reg R_W;
    reg EN;
    reg ram_clk;
    reg [8:0] ADDR;
    reg [8:0] DIN;	    

    wire [7:0] tdm_in;


// Outputs
    wire [7:0] tdm_out;
    wire CLKOUT;
    wire FS_SIG;
    wire [8:0] DOUT;


// Bidirs
 

reg	[7:0] frame_reg;
reg	[7:0] slot_load_reg;
wire	slot_load;
wire	[4:0] time_slot;


reg	[7:0] bit_counter;
reg	[4:0] timeslot_counter;

reg	[7:0] stream_0_mem_in [31:0];
reg	[7:0] stream_1_mem_in [31:0];
reg	[7:0] stream_2_mem_in [31:0];
reg	[7:0] stream_3_mem_in [31:0];
reg	[7:0] stream_4_mem_in [31:0];
reg	[7:0] stream_5_mem_in [31:0];
reg	[7:0] stream_6_mem_in [31:0];
reg	[7:0] stream_7_mem_in [31:0];

reg	[15:0] MEMORY [0:263];

reg	[7:0] stream_0_shift_reg_in;
reg	[7:0] stream_1_shift_reg_in;
reg	[7:0] stream_2_shift_reg_in;
reg	[7:0] stream_3_shift_reg_in;
reg	[7:0] stream_4_shift_reg_in;
reg	[7:0] stream_5_shift_reg_in;
reg	[7:0] stream_6_shift_reg_in;
reg	[7:0] stream_7_shift_reg_in;

reg	[7:0] stream_0_shift_reg_out;
reg	[7:0] stream_1_shift_reg_out;
reg	[7:0] stream_2_shift_reg_out;
reg	[7:0] stream_3_shift_reg_out;
reg	[7:0] stream_4_shift_reg_out;
reg	[7:0] stream_5_shift_reg_out;
reg	[7:0] stream_6_shift_reg_out;
reg	[7:0] stream_7_shift_reg_out;


reg	[4:0] display_en;

wire	in_stream_0, out_stream_0;
wire	in_stream_1, out_stream_1;
wire	in_stream_2, out_stream_2;
wire	in_stream_3, out_stream_3;
wire	in_stream_4, out_stream_4;
wire	in_stream_5, out_stream_5;
wire	in_stream_6, out_stream_6;
wire	in_stream_7, out_stream_7;

wire	[15:0] DATA_IN;

// Instantiate the UUT

tdm_switch_top    UUT (
                       .clk_in(CLKIN),
                       .clk_out(CLKOUT),
                       .frame_sync(FS_SIG),
                       .rx_stream(tdm_in),
                       .tx_stream(tdm_out),
                       .reset(reset),
                       .mpi_clk(ram_clk),
                       .mpi_cs(EN),
                       .mpi_rw(R_W),
                       .mpi_addr(ADDR[8:0]),
                       .mpi_data_in(DIN),
                       .mpi_data_out(DOUT)
                      );

// Initialize Inputs
//    `ifdef auto_init

        initial begin
            CLKIN = 0;
            reset = 0;
            R_W = 0;
            EN = 0;
            ram_clk = 0;
            ADDR = 0;
            DIN = 0;
            display_en = 0; 
           #2000 reset = 1;
        end

//    `endif


//=====================================================================
initial
    begin
      $readmemh ("stream_0.dat", stream_0_mem_in);
      $readmemh ("stream_1.dat", stream_1_mem_in);
      $readmemh ("stream_2.dat", stream_2_mem_in);
      $readmemh ("stream_3.dat", stream_3_mem_in);
      $readmemh ("stream_4.dat", stream_4_mem_in);
      $readmemh ("stream_5.dat", stream_5_mem_in);
      $readmemh ("stream_6.dat", stream_6_mem_in);
      $readmemh ("stream_7.dat", stream_7_mem_in);

	 $readmemh ("map.dat", MEMORY);
    end

//=====================================================================
always #122 CLKIN = ~CLKIN;
  
always #100 ram_clk = ~ram_clk;

assign	DATA_IN = MEMORY [ADDR];

always @ (DATA_IN)
   DIN = DATA_IN [8:0]; 

always @ (negedge ram_clk or negedge reset)
    if (!reset)
       ADDR = 0;
	  else
		 if (ADDR == 9'h107)
		    ADDR = ADDR;
		  else
		    ADDR = ADDR + 1;

always @ (ADDR)
    EN = (ADDR < 9'h108);

initial #1000000 $stop;


always @ (posedge CLKOUT)
    if (FS_SIG)
        frame_reg <= 0;
     else
        frame_reg <= frame_reg + 1;
//=====================================================================

always @ (posedge CLKOUT)
    if (FS_SIG)
        bit_counter <= 0;
     else
        bit_counter <= bit_counter + 1;

always @ (bit_counter)
      timeslot_counter <= (bit_counter + 1) >> 3;


always @ (negedge CLKOUT)
    case (frame_reg)
      8'hFF : slot_load_reg <= 8'h80;
      default : slot_load_reg[7:0] <= {slot_load_reg[0], slot_load_reg[7:1]};
    endcase

assign  slot_load = slot_load_reg[7];

always @ (posedge CLKOUT)
    if (slot_load)
      begin
        stream_0_shift_reg_in <= stream_0_mem_in [timeslot_counter];
        stream_1_shift_reg_in <= stream_1_mem_in [timeslot_counter];
        stream_2_shift_reg_in <= stream_2_mem_in [timeslot_counter];
        stream_3_shift_reg_in <= stream_3_mem_in [timeslot_counter];
        stream_4_shift_reg_in <= stream_4_mem_in [timeslot_counter];
        stream_5_shift_reg_in <= stream_5_mem_in [timeslot_counter];
        stream_6_shift_reg_in <= stream_6_mem_in [timeslot_counter];
        stream_7_shift_reg_in <= stream_7_mem_in [timeslot_counter];
      end
     else
      begin
        stream_0_shift_reg_in <= stream_0_shift_reg_in >> 1;
        stream_1_shift_reg_in <= stream_1_shift_reg_in >> 1;
        stream_2_shift_reg_in <= stream_2_shift_reg_in >> 1;
        stream_3_shift_reg_in <= stream_3_shift_reg_in >> 1;
        stream_4_shift_reg_in <= stream_4_shift_reg_in >> 1;
        stream_5_shift_reg_in <= stream_5_shift_reg_in >> 1;
        stream_6_shift_reg_in <= stream_6_shift_reg_in >> 1;
        stream_7_shift_reg_in <= stream_7_shift_reg_in >> 1;
      end

assign  in_stream_0 = stream_0_shift_reg_in[0];
assign  in_stream_1 = stream_1_shift_reg_in[0];
assign  in_stream_2 = stream_2_shift_reg_in[0];
assign  in_stream_3 = stream_3_shift_reg_in[0];
assign  in_stream_4 = stream_4_shift_reg_in[0];
assign  in_stream_5 = stream_5_shift_reg_in[0];
assign  in_stream_6 = stream_6_shift_reg_in[0];
assign  in_stream_7 = stream_7_shift_reg_in[0];

assign  out_stream_0 = tdm_out[0];
assign  out_stream_1 = tdm_out[1];
assign  out_stream_2 = tdm_out[2];
assign  out_stream_3 = tdm_out[3];
assign  out_stream_4 = tdm_out[4];
assign  out_stream_5 = tdm_out[5];
assign  out_stream_6 = tdm_out[6];
assign  out_stream_7 = tdm_out[7];

assign  tdm_in[0] = in_stream_0;	
assign  tdm_in[1] = in_stream_1;
assign  tdm_in[2] = in_stream_2;
assign  tdm_in[3] = in_stream_3;
assign  tdm_in[4] = in_stream_4;
assign  tdm_in[5] = in_stream_5;
assign  tdm_in[6] = in_stream_6;
assign  tdm_in[7] = in_stream_7;


always @ (negedge CLKOUT)
      begin
        stream_0_shift_reg_out <= {out_stream_0, stream_0_shift_reg_out[7:1]};
        stream_1_shift_reg_out <= {out_stream_1, stream_1_shift_reg_out[7:1]};
        stream_2_shift_reg_out <= {out_stream_2, stream_2_shift_reg_out[7:1]};
        stream_3_shift_reg_out <= {out_stream_3, stream_3_shift_reg_out[7:1]};
        stream_4_shift_reg_out <= {out_stream_4, stream_4_shift_reg_out[7:1]};
        stream_5_shift_reg_out <= {out_stream_5, stream_5_shift_reg_out[7:1]};
        stream_6_shift_reg_out <= {out_stream_6, stream_6_shift_reg_out[7:1]};
        stream_7_shift_reg_out <= {out_stream_7, stream_7_shift_reg_out[7:1]};
      end

assign time_slot = timeslot_counter-1;

always @ (negedge FS_SIG)
	display_en = display_en + 1;

/*
always @ (posedge CLKOUT)
   if (FS_SIG)
     display_en = display_en + 1;
    else
     display_en = display_en;
*/     	
integer SimFile;

initial  SimFile = $fopen("sim_result.dat");

initial
   begin
      $display ("||=======================================================================================================||");
      $display ("||***************************** SWITCHING **************** RESULTAT *************************************||");
      $display ("||=======================================================================================================||");
      $display ("|| Time Slot  # || STREAM_0 | STREAM_1 | STREAM_2 | STREAM_3 | STREAM_4 | STREAM_5 | STREAM_6 | STREAM_7 ||");
      $display ("||==============||==========|==========|==========|==========|==========|==========|==========|==========||");
                   
      $fdisplay (SimFile, "||=======================================================================================================||");
      $fdisplay (SimFile, "||***************************** SWITCHING **************** RESULTAT *************************************||");
      $fdisplay (SimFile, "||=======================================================================================================||");
      $fdisplay (SimFile, "|| Time Slot  # || STREAM_0 | STREAM_1 | STREAM_2 | STREAM_3 | STREAM_4 | STREAM_5 | STREAM_6 | STREAM_7 ||");
      $fdisplay (SimFile, "||==============||==========|==========|==========|==========|==========|==========|==========|==========||");
   end
    
always @ (posedge CLKOUT)
  if (display_en > 4)
    if (slot_load)
      begin
        $display ("|| Time Slot %d ||    %h    |    %h    |    %h    |    %h    |    %h    |    %h    |   %h     |    %h    ||  ", time_slot,
        						stream_0_shift_reg_out,
        						stream_1_shift_reg_out,
        						stream_2_shift_reg_out,
        						stream_3_shift_reg_out,
        						stream_4_shift_reg_out,
        						stream_5_shift_reg_out,
        						stream_6_shift_reg_out,
        						stream_7_shift_reg_out);
       $display ("||=======================================================================================================||");
        
        
       $fdisplay (SimFile, "|| Time Slot %d ||    %h    |    %h    |    %h    |    %h    |    %h    |    %h    |   %h     |    %h    ||  ", time_slot,
        						stream_0_shift_reg_out,
        						stream_1_shift_reg_out,
        						stream_2_shift_reg_out,
        						stream_3_shift_reg_out,
        						stream_4_shift_reg_out,
        						stream_5_shift_reg_out,
        						stream_6_shift_reg_out,
        						stream_7_shift_reg_out);
       $fdisplay (SimFile, "||=======================================================================================================||"); 						  
      end

endmodule

