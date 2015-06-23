module async_fifo 
// *************************** Ports ********************************
(
     rdclk_RESET_N  , 
     wrclk_RESET_N  , 
       fifo_rd_clk  ,
       fifo_wr_clk  ,
             rd_en  , 
             wr_en  , 
           fifo_rd  ,
           fifo_wr  ,
        fifo_wdata  ,
        fifo_rdata  ,
        fifo_empty  ,
         fifo_full  ,
        fifo_level  ,
           SRAM_IF
);
   
// ************************ Parameters ******************************
   parameter FIFO_DEPTH_W   =  10 ;
   parameter FIFO_W         =  64 ;

   parameter SRAM_DATA_W    =  64 ;    
   parameter SRAM_ADDR_W    =  14 ;

   parameter SRAM_UNUSED_ADDR_W    =  4 ;
      
// ********************* Local Parameters  **************************
   
// ********************** Inputs/Outputs ****************************
   input wire                     rdclk_RESET_N  ; 
   input wire                     wrclk_RESET_N  ; 
   input wire                       fifo_rd_clk  ;
   input wire                       fifo_wr_clk  ;
   input wire                             rd_en  ;
   input wire                             wr_en  ;
   input wire                           fifo_rd  ;
   input wire                           fifo_wr  ;
   input wire  [FIFO_W-1:0]          fifo_wdata  ;
   output wire [FIFO_W-1:0]          fifo_rdata  ;
   output reg                        fifo_empty  ;
   output reg                         fifo_full  ;
   output reg [FIFO_DEPTH_W:0]       fifo_level  ;
   sram_if.initiator                     SRAM_IF ;
   
// **************************  Wires  *******************************
   wire                            next_fifo_full;
   wire                           next_fifo_empty;
   wire [FIFO_DEPTH_W:0]          next_fifo_level;
   wire [FIFO_DEPTH_W:0]              next_wr_ptr;
   wire [FIFO_DEPTH_W:0]              next_rd_ptr;
   wire [FIFO_DEPTH_W:0]         next_gray_wr_ptr;
   wire [FIFO_DEPTH_W:0]         next_gray_rd_ptr;
   wire [FIFO_DEPTH_W:0]        sync_wr_ptr_rdclk;
   wire [FIFO_DEPTH_W:0]   sync_gray_wr_ptr_rdclk;
   wire [FIFO_DEPTH_W:0]   sync_gray_rd_ptr_wrclk;

// **************************  Regs   *******************************
   reg [FIFO_DEPTH_W:0]             wr_ptr;
   reg [FIFO_DEPTH_W:0]             rd_ptr;
   reg [FIFO_DEPTH_W:0]        gray_wr_ptr;
   reg [FIFO_DEPTH_W:0]        gray_rd_ptr;

// ******************** SRAM_IF control *****************************
   assign SRAM_IF.rd_l = ~fifo_rd;
   assign SRAM_IF.wr_l = ~(fifo_wr & ~fifo_full);
   assign SRAM_IF.rd_address = {  {SRAM_UNUSED_ADDR_W{1'b0}}, rd_ptr[FIFO_DEPTH_W-1:0] }; // rd_ptr in positions (64b words each)
   assign SRAM_IF.wr_address = { {SRAM_UNUSED_ADDR_W{1'b0}}, wr_ptr[FIFO_DEPTH_W-1:0] }; // wr_ptr in positions (64b words each)
   assign SRAM_IF.wdata = fifo_wdata;
   assign fifo_rdata = SRAM_IF.rdata;
   
// ********************* Write pointer  *****************************
   always_ff @(posedge fifo_wr_clk or negedge wrclk_RESET_N)
     begin
        if (!wrclk_RESET_N) begin
           wr_ptr <= 0;
           gray_wr_ptr <= 0;
        end
        else if (wr_en) begin
           wr_ptr <= next_wr_ptr;
           gray_wr_ptr <= next_gray_wr_ptr;
        end
     end

   assign next_wr_ptr = wr_ptr + (fifo_wr & ~fifo_full);
   bin2gray #(.DATA_W(FIFO_DEPTH_W+1)) I_BIN2GRAY (
      .bin  (      next_wr_ptr ),
      .gray ( next_gray_wr_ptr )
   );

// ******************* Read pointer resync  *************************   
   sync_doble_ff #(.DATA_W(FIFO_DEPTH_W+1)) I_SYNC_RD (
     .CLK              (                 fifo_wr_clk ),
     .RESET_N          (               wrclk_RESET_N ),
     .DIN              (                 gray_rd_ptr ),
     .DOUT             (      sync_gray_rd_ptr_wrclk )                                                 
   );
   
// *********************** FIFO full  *******************************
   assign next_fifo_full = (next_gray_wr_ptr == { ~sync_gray_rd_ptr_wrclk[FIFO_DEPTH_W:FIFO_DEPTH_W-1], sync_gray_rd_ptr_wrclk[FIFO_DEPTH_W-2:0] });
   
   always_ff @(posedge fifo_wr_clk or negedge wrclk_RESET_N)
     begin
        if (!wrclk_RESET_N) fifo_full <= 0;
        else if (wr_en) fifo_full <= next_fifo_full;    
     end
   
// ********************** Read pointer  *****************************
   always_ff @(posedge fifo_rd_clk or negedge rdclk_RESET_N)
     begin
        if (!rdclk_RESET_N) begin
           rd_ptr <= 0;
           gray_rd_ptr <= 0;
        end
        else if (rd_en) begin
           rd_ptr <= next_rd_ptr;
           gray_rd_ptr <= next_gray_rd_ptr;
        end
     end

   assign next_rd_ptr = rd_ptr + (fifo_rd & ~fifo_empty);
   bin2gray #(.DATA_W(FIFO_DEPTH_W+1)) I_BIN2GRAY_RD (
      .bin  (      next_rd_ptr ),
      .gray ( next_gray_rd_ptr )
   );

// ***************xt_**** Write pointer resync  *************************   
   sync_doble_ff #(.DATA_W(FIFO_DEPTH_W+1)) I_SYNC_WR (
     .CLK              (                 fifo_rd_clk ),
     .RESET_N          (               rdclk_RESET_N ),
     .DIN              (                 gray_wr_ptr ),
     .DOUT             (      sync_gray_wr_ptr_rdclk )                                                 
   );
   
// ********************  FIFO empty, level  ***************************
   assign next_fifo_empty = (next_gray_rd_ptr == sync_gray_wr_ptr_rdclk );
   
   gray2bin #(.DATA_W(FIFO_DEPTH_W+1)) I_GRAY2BIN_WR (
      .gray (      sync_gray_wr_ptr_rdclk ),
      .bin (            sync_wr_ptr_rdclk )
   );
   assign next_fifo_level = sync_wr_ptr_rdclk - next_rd_ptr;
   
   always_ff @(posedge fifo_rd_clk or negedge rdclk_RESET_N)
     begin
        if (!rdclk_RESET_N) begin
           fifo_empty <= 1;
           fifo_level <= 0;
        end
        else if (rd_en) begin
           fifo_empty <= next_fifo_empty;
           fifo_level <= next_fifo_level;
        end
     end
   
endmodule
