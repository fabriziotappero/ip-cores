/* verilator lint_off UNUSED */
/* verilator lint_off CASEX */
/* verilator lint_off PINNOCONNECT */
/* verilator lint_off PINMISSING */
/* verilator lint_off IMPLICIT */
/* verilator lint_off WIDTH */
/* verilator lint_off CASEINCOMPLETE */



module asram_core #(parameter SRAM_DATA_WIDTH = 32,
                    parameter SRAM_ADDR_WIDTH = 18,
                    parameter READ_LATENCY = 1,
                    parameter WRITE_LATENCY = 1
                    )
  (// Clock and reset
   clk_i,
   rst_i,
   // Wishbone side interface
   cti_i,
   bte_i,
   addr_i,
   dat_i,
   sel_i,
   we_i,
   stb_i,
   cyc_i,
   ack_o,
   dat_o,
   // SRAM side interface
   sram_addr,
   sram_data_in,
   sram_data_out,
   sram_csn,
   sram_be,
   sram_wen,
   sram_oen);

   parameter                  SRAM_CYCLE     = 32/SRAM_DATA_WIDTH;
   parameter                  SRAM_BE_WIDTH  = SRAM_DATA_WIDTH/8;

   //////////////////////////////////////////////////////////////////////////////
                              //clock and reset inputs
   input                      clk_i;
   input                      rst_i;
   //Wishbone side interface
   input [2:0]                cti_i;
   input [1:0]                bte_i;
   input [31:0]               addr_i;
   input [31:0]               dat_i;
   input [3:0]                sel_i;
   input                      we_i;
   input                      stb_i;
   input                      cyc_i;
   output                     ack_o;
   output [31:0]              dat_o;
   //SRAM side interface
   output [SRAM_ADDR_WIDTH-1:0] sram_addr;
   output                       sram_csn;
   output [SRAM_BE_WIDTH-1:0]   sram_be;
   output                       sram_wen;
   output                       sram_oen;
   input [SRAM_DATA_WIDTH-1:0]  sram_data_in;
   output [SRAM_DATA_WIDTH-1:0] sram_data_out;

   ///////////////////////////////////////////////////////////////////////////
   // Internal registers and wires
              reg [31:0] dat_o;
   reg [2:0]             main_sm; 
   reg                   ack_o;
   reg                   sram_wen;
   reg [3:0]             read_latency_cnt;
   reg [3:0]             write_latency_cnt;
   reg [2:0]             cycle;
   wire                  sram_data_width_32 = (SRAM_DATA_WIDTH == 32 ? 1 : 0);
   wire                  sram_data_width_16 = (SRAM_DATA_WIDTH == 16 ? 1 : 0);
   wire                  sram_data_width_8  = (SRAM_DATA_WIDTH == 8  ? 1 : 0);
   wire [31:0]           sram_addr_cls;
   reg [31:0]            sram_addr_bst;
   reg                   we_bst,rd_bst ;

   wire 		 burst_enabled = 1;
   
 `define IDLE    3'b000
 `define READ1   3'b001
 `define READ2   3'b010
 `define READ3   3'b011
 `define RD_BST  3'b100
 `define WRITE1  3'b101
 `define WRITE2  3'b110
 `define WRITE3  3'b111

   // Main State Machine which controls the WishBone and SRAM interface
   always @ (posedge rst_i or posedge clk_i) begin
      if (rst_i) begin
         main_sm <=  `IDLE;
         read_latency_cnt  <=  READ_LATENCY;
         write_latency_cnt <=  WRITE_LATENCY;
         dat_o <=  0;
         cycle <= 0;
         sram_wen  <=  1'b1;
         ack_o     <=  1'b0;
         we_bst    <= 0;
         rd_bst    <= 0;
         sram_addr_bst <= 0;     
      end else begin
         case (main_sm)
           `IDLE: begin
              if (cyc_i && stb_i && ~ack_o)
                if (we_i) begin            
                   ack_o <= 1'b0;
                   sram_wen     <=  1'b0;
                   write_latency_cnt <=  WRITE_LATENCY - 1;
                   main_sm      <=  `WRITE1;
                   rd_bst       <= 0;              
                   // classic cycle or single cycle or data width < 32
                   if (cti_i == 3'b000 || cti_i == 3'b111 || !sram_data_width_32) begin
                      we_bst        <= 1'b0;                  
                      sram_addr_bst <= 0;                     
                   end else begin
                      sram_addr_bst <= addr_i[SRAM_ADDR_WIDTH-1:0];                   
                      we_bst        <= 1'b1;                  
                   end
                   // classic cycle or if data width < 32
                end else if (cti_i == 3'b000 || cti_i == 3'b111 || !sram_data_width_32) begin 
                   we_bst <= 1'b0;
                   rd_bst <= 0;
                   sram_addr_bst     <= 0;                 
                   read_latency_cnt  <=  READ_LATENCY - 1;
 `ifdef NO_READ_WAIT
                   main_sm <=  `READ2;
                   if (sram_data_width_32)
                     ack_o <=  1'b1;
                   else
                     ack_o <=  1'b0;
                   dat_o[SRAM_DATA_WIDTH - 1 : 0] <=  sram_data_in;
 `else
                   main_sm <=  `READ1;
                   ack_o <=  1'b0;
 `endif
                end else begin                  // burst read cycle
                   main_sm      <= `RD_BST;
                   ack_o        <= 1'b0;
                   we_bst       <= 1'b0;
                   rd_bst       <= 1'b1;
                   sram_addr_bst<= addr_i[SRAM_ADDR_WIDTH-1:0];            
                   read_latency_cnt  <=  READ_LATENCY - 1;
                end
              else begin
                 main_sm <=  `IDLE;
                 sram_wen <= 1'b1;
                 ack_o <=  1'b0; 
                 we_bst <= 1'b0;                      
		 rd_bst <= 1'b0;
              end
              cycle <= SRAM_CYCLE;
              dat_o <=  0;
           end
           `READ1: if (read_latency_cnt != 4'b0000)
             read_latency_cnt <=  read_latency_cnt - 1;
           else begin
              main_sm <=  `READ2;
              ack_o <= (cycle == 1) ? 1'b1 : 1'b0;
              if (sram_data_width_32)
                dat_o <= sram_data_in;
              if (sram_data_width_16) begin
                 if (cycle == 1) dat_o[31:16] <= sram_data_in;
                 else dat_o[15:0] <= sram_data_in;
              end
              if (sram_data_width_8) begin
                 if (cycle == 4) dat_o[7:0] <= sram_data_in;
                 else if (cycle == 3) dat_o[15:8] <= sram_data_in;
                 else if (cycle == 2) dat_o[23:16] <= sram_data_in;
                 else dat_o[31:24] <= sram_data_in;
              end
           end
           `READ2: begin
              ack_o <=  1'b0;
              main_sm <=  `READ3;
              read_latency_cnt <=  READ_LATENCY - 1;
              if (cycle == 1)
                cycle <= SRAM_CYCLE;
              else
                cycle <= cycle - 1; end
           `READ3: begin
              if (cycle != SRAM_CYCLE) begin
 `ifdef NO_READ_WAIT
                 if (sram_data_width_32)
                   dat_o <= sram_data_in;
                 if (sram_data_width_16) begin
                    if (cycle == 1) dat_o[31:16] <= sram_data_in;
                    else dat_o[15:0] <= sram_data_in;
                 end
                 if (sram_data_width_8) begin
                    if (cycle == 3) dat_o[15:8] <= sram_data_in;
                    else if (cycle == 2) dat_o[23:16] <= sram_data_in;
                    else if (cycle == 1) dat_o[31:24] <= sram_data_in;
                 end
                 ack_o <= (cycle == 1) ? 1'b1 : 1'b0;
                 main_sm <=  `READ2;
 `else
                 main_sm <=  `READ1;
                 ack_o <=  1'b0;
 `endif
              end
              else if (cyc_i & stb_i) begin
                 read_latency_cnt  <=  READ_LATENCY - 1;
 `ifdef NO_READ_WAIT
                 main_sm <=  `READ2;
                 if (SRAM_DATA_WIDTH == 32)
                   ack_o <=  1'b1;
                 else
                   ack_o <=  1'b0;
                 dat_o[SRAM_DATA_WIDTH - 1 : 0] <=  sram_data_in;
 `else
                 main_sm <=  `READ1;
                 ack_o <=  1'b0;
 `endif
                 cycle <= SRAM_CYCLE;
              end else begin
                 main_sm <=  `IDLE;
                 ack_o <=  1'b0; 
              end
           end
           `RD_BST: begin  
              if (read_latency_cnt == 0) begin           
                 dat_o         <= sram_data_in;
                 ack_o         <= 1'b1;
                 sram_addr_bst <= sram_addr_bst + 4; // always four because 32 bit array                 
                 if (cti_i == 3'b111) begin
                    main_sm <= `IDLE;
                 end else begin
                    read_latency_cnt <= READ_LATENCY - 1;
                    main_sm <= `RD_BST;             
                 end 
              end else begin
                 ack_o         <= 1'b0;
                 read_latency_cnt <= read_latency_cnt - 1;
                 main_sm       <= `RD_BST;               
              end 
           end
           `WRITE1: begin
              if (write_latency_cnt == 0) begin
                 if ((sram_data_width_16 ==1) && (cycle ==3'b010) && (sel_i[3:2]==2'b00))
					   begin
				            ack_o <=  1;
					    main_sm <= `IDLE;
				           end
					  else 
					   begin
                                            ack_o <=  (cycle == 1) ? 1'b1 : 1'b0;
                                            main_sm  <= `WRITE2;                  
					   end
                  sram_addr_bst <= sram_addr_bst + 4; // always four because 32 bit array                 
                 if (we_bst) begin
                    if (cti_i == 3'b111) begin
                       sram_wen <=  1'b1;
                       we_bst   <= 0;                  
                    end
                 end else begin
                    sram_wen <=  1'b1;
                 end 
              end else begin
                 ack_o    <=  1'b0;
                 sram_wen <=  1'b0;
                 write_latency_cnt <=  write_latency_cnt - 1; 
              end
           end
           `WRITE2: begin
              ack_o <=  1'b0;
              if (cycle != 1) begin
                 cycle <= cycle - 1;
                 main_sm <=  `WRITE1;
                 write_latency_cnt <=  WRITE_LATENCY - 1;
              end else begin
                 cycle <= SRAM_CYCLE;
                 main_sm <=  `IDLE;
              end
           end
         endcase
      end
   end

   assign  sram_addr_cls = (cyc_i && (SRAM_CYCLE == 1)) ? {addr_i[31:2],2'b00} :
                           (cyc_i && (SRAM_CYCLE == 2) && (cycle == 2)) ? {addr_i[31:2],2'b00} :
                           (cyc_i && (SRAM_CYCLE == 2) && (cycle == 1)) ? {addr_i[31:2],2'b10} :
                           (cyc_i && (SRAM_CYCLE == 4) && (cycle == 4)) ? {addr_i[31:2],2'b00} :
                           (cyc_i && (SRAM_CYCLE == 4) && (cycle == 3)) ? {addr_i[31:2],2'b01} :
                           (cyc_i && (SRAM_CYCLE == 4) && (cycle == 2)) ? {addr_i[31:2],2'b10} :
                           (cyc_i && (SRAM_CYCLE == 4) && (cycle == 1)) ? {addr_i[31:2],2'b11} :

                           0;
   assign  sram_addr = ((rd_bst | we_bst) ? sram_addr_bst : sram_addr_cls);

   assign  sram_oen  = ~(stb_i && cyc_i && ~we_i && (main_sm==`READ1) );
   assign  sram_csn  = ~(stb_i && cyc_i);
   assign  sram_be   = ((stb_i==0) || (cyc_i==0)) ? 4'b1111 :
           (sram_oen    == 0)                  ?  4'b0000 :
           ((SRAM_CYCLE == 1)                ) ? ~sel_i | {sram_wen,sram_wen,sram_wen,sram_wen} :
           ((SRAM_CYCLE == 2) && (cycle == 2)) ? ~sel_i[1:0] | {sram_wen,sram_wen} :
           ((SRAM_CYCLE == 2) && (cycle == 1)) ? ~sel_i[3:2] | {sram_wen,sram_wen} :
           ((SRAM_CYCLE == 4) && (cycle == 4)) ? ~sel_i[0] | sram_wen :
           ((SRAM_CYCLE == 4) && (cycle == 3)) ? ~sel_i[1] | sram_wen :
           ((SRAM_CYCLE == 4) && (cycle == 2)) ? ~sel_i[2] | sram_wen :
           ((SRAM_CYCLE == 4) && (cycle == 1)) ? ~sel_i[3] | sram_wen : {4'b111};

   assign  sram_data_out = (sram_data_width_32 ? dat_i :
                            (sram_data_width_16 ? ((cycle == 2) ? dat_i[15:0] : dat_i[31:16]) :
                             ((cycle == 4) ? dat_i[7:0] :
                              (cycle == 3) ? dat_i[15:8] :
                              (cycle == 2) ? dat_i[23:16] :
                              (cycle == 1) ? dat_i[31:24] : 0)));

endmodule
