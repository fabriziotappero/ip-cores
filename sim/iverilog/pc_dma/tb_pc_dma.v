
module tb_pc_dma();

reg clk;
reg rst_n;

reg  [3:0] slave_address        = 4'd0;
reg        slave_read           = 1'b0;
wire [7:0] slave_readdata;
reg        slave_write          = 1'b0;
reg  [7:0] slave_writedata      = 8'd0;

reg  [3:0] page_address         = 4'd0;
reg        page_read            = 1'b0;
wire [7:0] page_readdata;
reg        page_write           = 1'b0;
reg  [7:0] page_writedata       = 8'd0;

reg  [4:0] master_address       = 5'd0;
reg        master_read          = 1'b0;
wire [7:0] master_readdata;
reg        master_write         = 1'b0;
reg  [7:0] master_writedata     = 8'd0;

wire [31:0] avm_address;
reg         avm_waitrequest     = 1'b0;
wire        avm_read;
reg         avm_readdatavalid   = 1'b0;
reg  [7:0]  avm_readdata        = 8'd0;
wire        avm_write;
wire [7:0]  avm_writedata;

reg        dma_floppy_req       = 1'b0;
wire       dma_floppy_ack;
wire       dma_floppy_terminal;
wire [7:0] dma_floppy_readdata;
reg  [7:0] dma_floppy_writedata = 8'd0;

reg        dma_soundblaster_req         = 1'b0;
wire       dma_soundblaster_ack;
wire       dma_soundblaster_terminal;
wire [7:0] dma_soundblaster_readdata;
reg  [7:0] dma_soundblaster_writedata   = 8'd0;

pc_dma pc_dma_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    //000h - 00Fh for slave DMA
    .slave_address              (slave_address),      //input [3:0]
    .slave_read                 (slave_read),         //input
    .slave_readdata             (slave_readdata),     //output [7:0]
    .slave_write                (slave_write),        //input
    .slave_writedata            (slave_writedata),    //input [7:0]
    
    //080h - 08Fh for DMA page    
    .page_address               (page_address),       //input [3:0]
    .page_read                  (page_read),          //input
    .page_readdata              (page_readdata),      //output [7:0]
    .page_write                 (page_write),         //input
    .page_writedata             (page_writedata),     //input [7:0]
    
    //0C0h - 0DFh for master DMA
    .master_address             (master_address),     //input [4:0]
    .master_read                (master_read),        //input
    .master_readdata            (master_readdata),    //output [7:0]
    .master_write               (master_write),       //input
    .master_writedata           (master_writedata),   //input [7:0]
    
    //master
    .avm_address                (avm_address),        //output [31:0]
    .avm_waitrequest            (avm_waitrequest),    //input
    .avm_read                   (avm_read),           //output
    .avm_readdatavalid          (avm_readdatavalid),  //input
    .avm_readdata               (avm_readdata),       //input [7:0]
    .avm_write                  (avm_write),          //output
    .avm_writedata              (avm_writedata),      //output [7:0]
    
    //floppy 8-bit dma channel
    .dma_floppy_req             (dma_floppy_req),         //input
    .dma_floppy_ack             (dma_floppy_ack),         //output
    .dma_floppy_terminal        (dma_floppy_terminal),    //output
    .dma_floppy_readdata        (dma_floppy_readdata),    //output [7:0]
    .dma_floppy_writedata       (dma_floppy_writedata),   //input [7:0]
    
    //soundblaster 8-bit dma channel
    .dma_soundblaster_req       (dma_soundblaster_req),       //input
    .dma_soundblaster_ack       (dma_soundblaster_ack),       //output
    .dma_soundblaster_terminal  (dma_soundblaster_terminal),  //output
    .dma_soundblaster_readdata  (dma_soundblaster_readdata),  //output [7:0]
    .dma_soundblaster_writedata (dma_soundblaster_writedata)  //input [7:0]
);

initial begin
    avm_readdatavalid = 1'b0;
    avm_readdata = 8'd0;
    forever begin
        #10
        avm_readdatavalid = ~avm_readdatavalid;
        avm_readdata = avm_readdata + 8'd1;
    end
end

initial begin
    dma_floppy_req = 1'b0;
    #50
    dma_floppy_req = 1'b1;
    #300
    dma_floppy_req = 1'b0;
end

initial begin
    dma_soundblaster_req = 1'b0;
    #50
    dma_soundblaster_req = 1'b1;
    #400
    dma_soundblaster_req = 1'b0;
end

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

`define WRITE_SLA(addr, data)  \
    slave_write        = 1'b1; \
    slave_address      = addr; \
    slave_writedata    = data; \
    #10;                       \
    slave_write        = 1'b0;

`define WRITE_MAS(addr, data)   \
    master_write        = 1'b1; \
    master_address      = addr; \
    master_writedata    = data; \
    #10;                        \
    master_write        = 1'b0;

`define WRITE_PAGE(addr, data) \
    page_write        = 1'b1;  \
    page_address      = addr;  \
    page_writedata    = data;  \
    #10;                       \
    page_write        = 1'b0;
    
integer finished = 0;

reg [255:0] dumpfile_name;
initial begin
    if( $value$plusargs("dumpfile=%s", dumpfile_name) == 0 ) begin
        dumpfile_name = "default.vcd";
    end
    
    $dumpfile(dumpfile_name);
    $dumpvars(0);
    $dumpon();
    
    $display("START");
    
    rst_n = 1'b0;
    #10 rst_n = 1'b1;
    
/*

  xor ax, ax
  out PORT_DMA1_MASTER_CLEAR(0x0D),al
  out PORT_DMA2_MASTER_CLEAR(0xDA),al

  ;; then initialize the DMA controllers
  mov al, #0xC0
  out PORT_DMA2_MODE_REG(0xD6), al ; cascade mode of channel 4 enabled
  mov al, #0x00
  out PORT_DMA2_MASK_REG(0xD4), al ; unmask channel 4

#define PORT_DMA_ADDR_2        0x0004
#define PORT_DMA_CNT_2         0x0005
#define PORT_DMA1_MASK_REG     0x000a
#define PORT_DMA1_MODE_REG     0x000b
#define PORT_DMA1_CLEAR_FF_REG 0x000c
#define PORT_DMA1_MASTER_CLEAR 0x000d
#define PORT_DMA_PAGE_2        0x0081
#define PORT_DMA2_MASTER_CLEAR 0x00da
#define PORT_DMA2_MASK_REG     0x00d4
#define PORT_DMA2_MODE_REG     0x00d6

  BX_DEBUG_INT13_FL("masking DMA-1 c2\n");
  outb(PORT_DMA1_MASK_REG(0x0A), 0x06);

  BX_DEBUG_INT13_FL("clear flip-flop\n");
      outb(PORT_DMA1_CLEAR_FF_REG(0x0C), 0x00); // clear flip-flop
      outb(PORT_DMA_ADDR_2(0x04), base_address);
      outb(PORT_DMA_ADDR_2(0x04), base_address>>8);
  BX_DEBUG_INT13_FL("clear flip-flop\n");
      outb(PORT_DMA1_CLEAR_FF_REG(0x0C), 0x00); // clear flip-flop
      outb(PORT_DMA_CNT_2(0x05), base_count);
      outb(PORT_DMA_CNT_2(0x05), base_count>>8);

  // Read Diskette Sectors

  // port 0b: DMA-1 Mode Register
    mode_register = 0x46; // single mode, increment, autoinit disable,
                          // transfer type=write, channel 2
  BX_DEBUG_INT13_FL("setting mode register\n");
    outb(PORT_DMA1_MODE_REG(0x0B), mode_register);

  BX_DEBUG_INT13_FL("setting page register\n");
    // port 81: DMA-1 Page Register, channel 2
   outb(PORT_DMA_PAGE_2(0x81), page);

  BX_DEBUG_INT13_FL("unmask chan 2\n");
    outb(PORT_DMA1_MASK_REG(0x0A), 0x02); // unmask channel 2

    BX_DEBUG_INT13_FL("unmasking DMA-1 c2\n");
    outb(PORT_DMA1_MASK_REG(0x0A), 0x02);

    //--------------------------------------
    // set up floppy controller for transfer
    //--------------------------------------
    floppy_prepare_controller(drive);

    // send read-normal-data command (9 bytes) to controller
    outb(PORT_FD_DATA, 0xe6); // e6: read normal data
*/
    
    /*
    `WRITE_SLA(4'hE, 8'd0) //clear slave mask
    
    `WRITE_MAS(5'h1C, 8'd0) //clear master mask
    
    `WRITE_SLA(4'hB, 8'b00001010) //mode for floppy
    
    `WRITE_SLA(4'hB, 8'b00000101) //mode for soundblaster
    
    `WRITE_SLA(4'h4, 8'h1A) //address
    `WRITE_SLA(4'h4, 8'hCD)
    
    `WRITE_SLA(4'h5, 8'h03) //count
    `WRITE_SLA(4'h5, 8'h00)
    */
    
    `WRITE_SLA(4'hD, 8'h00)
    `WRITE_MAS(5'h1A, 8'h00)
    
    `WRITE_MAS(5'h16, 8'hC0)
    `WRITE_MAS(5'h14, 8'h00)
    
    `WRITE_SLA(4'hA, 8'h06)
    `WRITE_SLA(4'hC, 8'h00)
    `WRITE_SLA(4'h4, 8'hCD)
    `WRITE_SLA(4'h4, 8'hAB)
    
    `WRITE_SLA(4'hC, 8'h00)
    `WRITE_SLA(4'h5, 8'h05)
    `WRITE_SLA(4'h5, 8'h00)
    
    `WRITE_SLA(4'hB, 8'h46)
    `WRITE_PAGE(4'h1, 8'h78)
    
    `WRITE_SLA(4'hA, 8'h02)
    `WRITE_SLA(4'hA, 8'h02)
    
    #100
    
    dma_floppy_req = 1'b1;
    
    #5000
    
    
    while(finished == 0) begin
        if($time > 50000) $finish_and_return(-1);
        #10;
        
        //$dumpflush();
    end
    
    #60;
    
    $dumpoff();
    $finish_and_return(0);
end

endmodule
