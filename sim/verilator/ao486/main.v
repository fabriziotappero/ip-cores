module main(
    input               clk,
    input               rst_n,
    
    //--------------------------------------------------------------------------
    input               interrupt_do,
    input   [7:0]       interrupt_vector,
    output              interrupt_done,
    
    //-------------------------------------------------------------------------- Altera Avalon io bus
    output  [15:0]      avalon_io_address,
    output  [3:0]       avalon_io_byteenable,
    
    output              avalon_io_read,
    input               avalon_io_readdatavalid,
    input   [31:0]      avalon_io_readdata,
    
    output              avalon_io_write,
    output  [31:0]      avalon_io_writedata,
    
    input               avalon_io_waitrequest,
    
    //memory master
    output      [31:0]  sdram_address,
    output      [3:0]   sdram_byteenable,
    output              sdram_read,
    input       [31:0]  sdram_readdata,
    output              sdram_write,
    output      [31:0]  sdram_writedata,
    input               sdram_waitrequest,
    input               sdram_readdatavalid,
    output      [2:0]   sdram_burstcount,
    
    //vga master
    output      [31:0]  vga_address,
    output      [3:0]   vga_byteenable,
    output              vga_read,
    input       [31:0]  vga_readdata,
    output              vga_write,
    output      [31:0]  vga_writedata,
    input               vga_waitrequest,
    input               vga_readdatavalid,
    output      [2:0]   vga_burstcount,
    
    //----------------------- debug
    output              tb_finish_instr,
    //SW
    
    output  [15:0]      dbg_io_address,
    output  [3:0]       dbg_io_byteenable,
    output              dbg_io_write,
    output              dbg_io_read,
    output  [31:0]      dbg_io_data,
    
    output  [7:0]       dbg_int_vector,
    output              dbg_int,
    
    output  [7:0]       dbg_exc_vector,
    output              dbg_exc,
    
    output  [31:0]      dbg_mem_address,
    output  [3:0]       dbg_mem_byteenable,
    output              dbg_mem_write,
    output              dbg_mem_read,
    output  [31:0]      dbg_mem_data
);

//------------------------------------------------------------------------------

wire [31:0] avm_address;
wire [31:0] avm_writedata;
wire [3:0]  avm_byteenable;
wire [2:0]  avm_burstcount;
wire        avm_write;
wire        avm_read;

wire        avm_waitrequest     = mem_waitrequest;
wire        avm_readdatavalid   = mem_readdatavalid;
wire [31:0] avm_readdata        = mem_readdata;


wire [31:0] mem_readdata;
wire        mem_waitrequest;
wire        mem_readdatavalid;

wire [29:0] mem_address         = avm_address[31:2];
wire [3:0]  mem_byteenable      = avm_byteenable;
wire        mem_read            = avm_read;
wire        mem_write           = avm_write;
wire [31:0] mem_writedata       = avm_writedata;
wire [2:0]  mem_burstcount      = avm_burstcount;

//------------------------------------------------------------------------------

wire [17:0] SW = 18'h0007F;

ao486 ao486_inst(
    .clk                        (clk),                      //input
    .rst_n                      (rst_n),                    //input
    
    .rst_internal_n             (rst_n),                    //input
    
    //--------------------------------------------------------------------------
    .interrupt_do               (interrupt_do),             //input
    .interrupt_vector           (interrupt_vector),         //input [7:0]
    .interrupt_done             (interrupt_done),           //output
    
    //-------------------------------------------------------------------------- Altera Avalon memory bus
    .avm_address                (avm_address),              //output [31:0]
    .avm_writedata              (avm_writedata),            //output [31:0]
    .avm_byteenable             (avm_byteenable),           //output [3:0]
    .avm_burstcount             (avm_burstcount),           //output [2:0]
    .avm_write                  (avm_write),                //output
    .avm_read                   (avm_read),                 //output
    
    .avm_waitrequest            (avm_waitrequest),          //input
    .avm_readdatavalid          (avm_readdatavalid),        //input
    .avm_readdata               (avm_readdata),             //input [31:0]
    
    //-------------------------------------------------------------------------- Altera Avalon io bus
    .avalon_io_address          (avalon_io_address),        //output [15:0]
    .avalon_io_byteenable       (avalon_io_byteenable),     //output [3:0]
    
    .avalon_io_read             (avalon_io_read),           //output
    .avalon_io_readdatavalid    (avalon_io_readdatavalid),  //input
    .avalon_io_readdata         (avalon_io_readdata),       //input [31:0]
    
    .avalon_io_write            (avalon_io_write),          //output
    .avalon_io_writedata        (avalon_io_writedata),      //output [31:0]
    
    .avalon_io_waitrequest      (avalon_io_waitrequest),    //input
    
    //-------------------------------------------------------------------------- debug
    .SW                         (SW),                       //input [17:0]
    .tb_finish_instr (tb_finish_instr),

    .dbg_io_address     (dbg_io_address),
    .dbg_io_byteenable  (dbg_io_byteenable),
    .dbg_io_write       (dbg_io_write),
    .dbg_io_read        (dbg_io_read),
    .dbg_io_data        (dbg_io_data),
    
    .dbg_int_vector     (dbg_int_vector),
    .dbg_int            (dbg_int),
    
    .dbg_exc_vector     (dbg_exc_vector),
    .dbg_exc            (dbg_exc),
    
    .dbg_mem_address    (dbg_mem_address),
    .dbg_mem_byteenable (dbg_mem_byteenable),
    .dbg_mem_write      (dbg_mem_write),
    .dbg_mem_read       (dbg_mem_read),
    .dbg_mem_data       (dbg_mem_data)
);

//------------------------------------------------------------------------------

wire [1:0]  ctrl_address    = 2'd0;
wire        ctrl_write      = 1'b0;
wire [31:0] ctrl_writedata  = 32'd0;

pc_bus pc_bus_inst(
    .clk                (clk),                  //input
    .rst_n              (rst_n),                //input
    
    //control slave
    .ctrl_address       (ctrl_address),         //input [1:0]
    .ctrl_write         (ctrl_write),           //input
    .ctrl_writedata     (ctrl_writedata),       //input [31:0]
    
    //memory slave
    .mem_address        (mem_address),          //input [29:0]
    .mem_byteenable     (mem_byteenable),       //input [3:0]
    .mem_read           (mem_read),             //input
    .mem_readdata       (mem_readdata),         //output [31:0]
    .mem_write          (mem_write),            //input
    .mem_writedata      (mem_writedata),        //input [31:0]
    .mem_waitrequest    (mem_waitrequest),      //output
    .mem_readdatavalid  (mem_readdatavalid),    //output
    .mem_burstcount     (mem_burstcount),       //input [2:0]
    
    //memory master
    .sdram_address      (sdram_address),        //output [31:0]
    .sdram_byteenable   (sdram_byteenable),     //output [3:0]
    .sdram_read         (sdram_read),           //output
    .sdram_readdata     (sdram_readdata),       //input [31:0]
    .sdram_write        (sdram_write),          //output
    .sdram_writedata    (sdram_writedata),      //output [31:0]
    .sdram_waitrequest  (sdram_waitrequest),    //input
    .sdram_readdatavalid(sdram_readdatavalid),  //input
    .sdram_burstcount   (sdram_burstcount),     //output [2:0]
    
    //vga master
    .vga_address        (vga_address),          //output [31:0]
    .vga_byteenable     (vga_byteenable),       //output [3:0]
    .vga_read           (vga_read),             //output
    .vga_readdata       (vga_readdata),         //input [31:0]
    .vga_write          (vga_write),            //output
    .vga_writedata      (vga_writedata),        //output [31:0]
    .vga_waitrequest    (vga_waitrequest),      //input
    .vga_readdatavalid  (vga_readdatavalid),    //input
    .vga_burstcount     (vga_burstcount)        //output [2:0]
);

//------------------------------------------------------------------------------

wire _unused_ok = &{ 1'b0, avm_address[1:0], 1'b0 };

//------------------------------------------------------------------------------

endmodule
