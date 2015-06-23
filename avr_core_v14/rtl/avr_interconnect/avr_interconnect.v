//******************************************************************************************
// 
// Version 0.4 
// Modified 09.06.12
// Interconnect for AVR Core (Verilog version)
// 
// Written by Ruslan Lepetenok (lepetenokr@yahoo.com)
// Bug in the DM slave to master mux was fixed (cpuwait) 
//******************************************************************************************

`ifndef C_DIS_DEFAULT_NETTYPE
 // All nets must be declared
 `default_nettype none
`endif

//synthesis translate_off
`include "timescale.vh"
//synthesis translate_on


module avr_interconnect #(
                          parameter num_of_msts         = 4 , 
                          parameter io_slv_num          = 4, 
			  parameter mem_slv_num         = 4, 
			  parameter irqs_width          = 23, 
			  parameter pc22b               = 0,
			  // Added
			  parameter dm_int_sram_read_ws = 0,
			  parameter dm_start_adr        = 'h4000,
			  parameter dm_size             = 16,        // Size of DM SRAM in KBytes
			  // 
			  parameter dm_ext_slv_adr0     = 16'h1000,   
                          parameter dm_ext_slv_len0     = 1*1024, 
			  parameter dm_ext_slv_adr1     = 16'h1000,   
                          parameter dm_ext_slv_len1     = 1*1024, 
			  parameter dm_ext_slv_adr2     = 16'h1000,   
                          parameter dm_ext_slv_len2     = 1*1024, 
			  parameter dm_ext_slv_adr3     = 16'h1000,   
                          parameter dm_ext_slv_len3     = 1*1024 
			  )
        (

	 // To master(s)
	 output wire[7:0]                    msts_dbusout, // Data from the selected slave(Common for all masters)
         output wire[num_of_msts-1:0]        msts_rdy,   // analog of !cpuwait
         output reg[num_of_msts-1:0]         msts_busy,  // analog of cpuwait
	 // To DM slave(s)
	 output wire[15:0]                   ramadr,  
	 output wire[7:0]                    ramdout, 
         output wire                         ramre,   
         output wire                         ramwe,   
         // DM address decoder
	 output wire                         sel_60_ff,    
	 output wire                         sel_100_1ff,
	 output wire[3:0]                    dm_ext_slv_sel,     
	 // IRQ related
	 output reg[irqs_width-1:0]          ind_irq_ack,    
         // Clock and reset
         input                               ireset,  
         input                               cp2,
         // From master(s) 
	 input[num_of_msts*(16+8+1+1)-1:0]   msts_outs,  //  ramwe + ramre + ramadr[15:0] + ramdout[7:0]

         // From DM slave(s) 
	 input[mem_slv_num*(8+1+1)-1:0]      dm_slv_outs,  // out_en + wait + ramdin[7:0]
	 input[7:0]                          dm_dout,      // From DM       
	 // From IO slave(s)
	 input[io_slv_num*(8+1)-1:0]         io_slv_outs, // out_en + dbusout[7:0] 
	 // IRQ related
         input                               irqack,         
         input [4+pc22b:0]                   irqackad       	    
	);
	
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
localparam LP_MSTS_OUTS_WIDTH   = (16+8+1+1); // Length of master bus => ramwe + ramre + ramadr[15:0] + ramdout[7:0]
localparam LP_DM_SLV_OUTS_WIDTH = (8+1+1);    // Length of DM slave output bus => out_en + wait + ramdin[7:0]
localparam LP_IO_SLV_OUTS_WIDTH = (8+1);      // Length of IO slave output bus => out_en + dbusout[7:0]

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// Slave(s) to masters(s) MUXes 

// MUX output for the IO slave
reg[7:0] io_slv_dbusout;

// MUX output for the DM slave
reg[7:0] dm_slv_mux_o_dbusout;
reg      dm_slv_mux_o_wait;   

wire dm_sram_acc;  // DM SRAM access (address decoder output)

reg  dm_sram_wait_st_current;
wire dm_sram_wait_st_next;
  
wire dm_sram_wait_st; // Analog of cpuwait (for internal DM sram)


reg cpuwait_del_current;

localparam LP_MST_NUM_REG_WIDTH = (num_of_msts <= 2)  ? 1 :
                                  (num_of_msts <= 4)  ? 2 :
                                  (num_of_msts <= 8)  ? 3 :
                                  (num_of_msts <= 16) ? 4 : 0; // fn_log2x(num_of_msts); // Or may be integer

reg[LP_MST_NUM_REG_WIDTH-1:0] mst_num_current;
wire[LP_MST_NUM_REG_WIDTH-1:0] mst_num_next;   
wire[LP_MST_NUM_REG_WIDTH-1:0] mst_num_mux;    



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


always@(*)
 begin : comb
  integer i;
  integer j;

  // IO slaves
  io_slv_dbusout = {8{1'b0}}; 
  for(i = 0; i < io_slv_num; i = i + 1) begin
   if(io_slv_outs[i*LP_IO_SLV_OUTS_WIDTH+8]) begin // out_en is high -> slave is selected
    for(j = 0; j < 8; j = j + 1) begin    
     io_slv_dbusout[j] = io_slv_outs[i*LP_IO_SLV_OUTS_WIDTH+j]; 
    end  
   end
  end 
 
  // DM slaves 
  dm_slv_mux_o_dbusout = {8{1'b0}};
  dm_slv_mux_o_wait    =  dm_sram_wait_st; // 1'b0;  // wait from DM SRAM !!!TBD!!! 
  
//  for(i = 0; i < mem_slv_num; i = i + 1) begin
//   if(dm_slv_outs[i*LP_DM_SLV_OUTS_WIDTH+8+1]) begin // out_en is high -> slave is selected
//     dm_slv_mux_o_wait = dm_slv_outs[i*LP_DM_SLV_OUTS_WIDTH+8]; // Wait  
//    for(j = 0; j < 8; j = j + 1) begin    
//     dm_slv_mux_o_dbusout[j] = dm_slv_outs[i*LP_DM_SLV_OUTS_WIDTH+j]; // DM data
//    end  
//   end
//  end 
 
   // Read data mux  
  for(i = 0; i < mem_slv_num; i = i + 1) begin
   if(dm_slv_outs[i*LP_DM_SLV_OUTS_WIDTH+8+1]) begin // out_en is high -> slave is selected
    for(j = 0; j < 8; j = j + 1) begin    
     dm_slv_mux_o_dbusout[j] = dm_slv_outs[i*LP_DM_SLV_OUTS_WIDTH+j]; // DM read data
    end  
   end
  end 
  
 // cpuwait mux - MUST NOT relay upon out_en signal. 
 // Since out_en is only high on read operation. 
 // DM slaves MUST ASSERT cpuwait output only in responce to the
 // access to the corresponded memory area
    for(i = 0; i < mem_slv_num; i = i + 1) begin
      if(dm_slv_outs[i*LP_DM_SLV_OUTS_WIDTH+8]) dm_slv_mux_o_wait = 1'b1; // Wait  
   end

 end // comb

// TBD

assign dm_sram_acc = (ramadr >= dm_start_adr && ramadr <= (dm_start_adr + dm_size -1)) ? 1'b1 : 1'b0;

assign  msts_dbusout = (ramre) ? 
                                ((dm_sram_acc) ? dm_dout[7:0] : dm_slv_mux_o_dbusout[7:0] ) :   // DM SRAM or DM IO
				io_slv_dbusout[7:0];                                            // IO slaves


//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// DM arbitration functions (begin)
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[LP_MST_NUM_REG_WIDTH-1:0] fn_arb;
input [num_of_msts*LP_MSTS_OUTS_WIDTH-1:0] msts_outs_i;
integer i;
begin
 fn_arb = {LP_MST_NUM_REG_WIDTH{1'b0}};
 for(i = 0 ; i < num_of_msts; i = i +1 ) begin  : search_for_brq_label
  if(msts_outs_i[i*LP_MSTS_OUTS_WIDTH+(16+8+1)] || msts_outs_i[i*LP_MSTS_OUTS_WIDTH+(16+8)]) begin // ramre=1'b1 or ramwe=1'b1 
   fn_arb = i[LP_MST_NUM_REG_WIDTH-1:0];
   disable search_for_brq_label; 
  end 
 end // search_for_brq_label
end
endfunction // fn_arb
 
 
// fn_arb_det_req return 1'b1 if at least one master requests the bus (DM) 
function fn_arb_det_req;
input [num_of_msts*LP_MSTS_OUTS_WIDTH-1:0]   msts_outs_i;
integer i;
reg done;
begin
fn_arb_det_req = 1'b0;
for(i = 0 ; i < num_of_msts; i = i +1 ) begin : search_for_brq_label
 if(msts_outs_i[i*LP_MSTS_OUTS_WIDTH + (16+8+1)] || msts_outs_i[i*LP_MSTS_OUTS_WIDTH + (16+8)]) begin // ramre=1'b1 or ramwe=1'b1 
  fn_arb_det_req = 1'b1;
  disable search_for_brq_label; 
 end 
end // search_for_brq_label
end
endfunction // fn_arb_det_req 
 

// vector to return  ramwe + ramre + ramadr[15:0] + ramdout[7:0] 
function[LP_MSTS_OUTS_WIDTH-1:0] fn_arb_sel_bus;
input [num_of_msts*LP_MSTS_OUTS_WIDTH-1:0] msts_outs_i;
input [LP_MST_NUM_REG_WIDTH-1:0]           mst_num;    
integer i;
integer j;
begin
fn_arb_sel_bus = {LP_MSTS_OUTS_WIDTH{1'b0}};
 if(fn_arb_det_req(msts_outs_i)) begin // At least one master requests the bus
  for(i = 0 ; i < num_of_msts; i = i + 1 ) begin  : bus_mux_label
   if(i[LP_MST_NUM_REG_WIDTH-1:0] == mst_num) begin
     for(j = 0 ; j < LP_MSTS_OUTS_WIDTH; j = j + 1 ) begin fn_arb_sel_bus[j] = msts_outs_i[i*LP_MSTS_OUTS_WIDTH+j]; end
     disable bus_mux_label; 
   end 
  end // bus_mux_label
end 
 
end
endfunction // fn_arb_sel_bus 

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// DM arbitration functions (end)
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


//***********************************************************************************************************

always@(posedge cp2 or negedge ireset)
begin : seq_prc
 if(!ireset) begin
  cpuwait_del_current  <= 1'b0;
  mst_num_current      <= {LP_MST_NUM_REG_WIDTH{1'b0}};  
 end
 else begin
  cpuwait_del_current  <= dm_slv_mux_o_wait; // NOT_READY signal from the selected slave
  mst_num_current      <= mst_num_next;
 end 
end // seq_prc


assign mst_num_next = (cpuwait_del_current) ?  mst_num_current : fn_arb(msts_outs);
assign mst_num_mux  = (cpuwait_del_current) ?  mst_num_current : mst_num_next;

// Master MUX
assign {ramwe,ramre,ramadr[15:0],ramdout[7:0]} = fn_arb_sel_bus(msts_outs,mst_num_mux);  

always@(*)
 begin : bus_wait_gen
 integer i;
  
  msts_busy = {num_of_msts{1'b0}}; // ???
 
  for(i = 0 ; i < num_of_msts; i = i + 1 ) begin 
   if (i == mst_num_mux) begin  
    msts_busy[i] =  dm_slv_mux_o_wait; // NOT_READY signal from the selected slave  
   end
   else begin
    if(msts_outs[i*LP_MSTS_OUTS_WIDTH + (16+8+1)] || msts_outs[i*LP_MSTS_OUTS_WIDTH + (16+8)]) begin // ramre=1'b1 or ramwe=1'b1 
     msts_busy[i] = 1'b1; // BUSY for the master which is not granted the bus
    end
   end
  end
 end // bus_wait_gen

assign msts_rdy = ~msts_busy;


// !!!!!!!!!!!!!!!!!!!! DM Address decoder !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// 0x60 - 0xFF (ATMega128 or ATMega1280) => 160 locations
assign sel_60_ff    =  (ramadr >= 16'h0060 && ramadr <= 16'h00FF) ? 1'b1 : 1'b0;

// 0x100 - 0x1FF (ATMega1280 only) => 256 locations
assign sel_100_1ff  =  (ramadr >= 16'h0100 && ramadr <= 16'h01FF) ? 1'b1 : 1'b0;


// Memory configurations
//
//Memory Configuration A (ATmega128)
//
//Data Memory
//
//32 Registers       $0000 - $001F 
//
//64 I/O Registers   $0020 - $005F
//
//160 Ext I/O Reg.   $0060 - $00FF
//
//Internal SRAM      $0100 - $10FF 
//(4096 x 8)
//	  
//External SRAM      $1100 - $FFFF   
//(0 - 64K x 8)
//
//
//Memory Configuration B (ATmega103)
//
//Data Memory
//
//32 Registers       $0000 - $001F 
//64 I/O Registers   $0020 - $005F
//Internal SRAM      $0060 - $0FFF 
//(4000 x 8)
//
//External SRAM      $1000 - $FFFF
//(0 - 64K x 8)


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Interrupt related ~~~~~~~~~~~~~~~~~~~~~~~``

//******************************** IRQs *************************************	
//interrupt_ack:for i in ind_irq_ack'range generate
// ind_irq_ack(i) <= '1' when (fn_to_integer(irqackad)=i+1 and irqack='1') else '0';
//end generate;

always@(*)
 begin : irq_ack_comb
  integer i;
  ind_irq_ack = {irqs_width{1'b0}};
  for(i = 0 ; i < irqs_width; i = i + 1 ) begin
   if((i[4+pc22b:0] + 1) == irqackad && irqack) ind_irq_ack[i] = 1'b1;
  end 
end // irq_ack_comb 


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

generate 
 if(dm_int_sram_read_ws) begin : ws_dm_sram_read

always@(posedge cp2 or negedge ireset)
begin : rdy_seq_prc
 if(!ireset) begin
  dm_sram_wait_st_current <= 1'b0;  
 end
 else begin
  dm_sram_wait_st_current <= dm_sram_wait_st_next;
 end 
end // rdy_seq_prc

assign dm_sram_wait_st_next = (~dm_sram_wait_st_current & ramre & dm_sram_acc) ? 1'b1 : 1'b0;
assign dm_sram_wait_st = ramre & dm_sram_acc & !dm_sram_wait_st_current;    

 end // ws_dm_sram_read
 else begin : no_ws_dm_sram_read
 
 always@(*) dm_sram_wait_st_current = 1'b0; 
 assign dm_sram_wait_st_next = 1'b0;
 assign dm_sram_wait_st      = 1'b0;
  
 end // no_ws_dm_sram_read
endgenerate


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
assign dm_ext_slv_sel[0] = (ramadr >= dm_ext_slv_adr0 && ramadr <= (dm_ext_slv_adr0 + dm_ext_slv_len0 -1)) ? 1'b1 : 1'b0;
assign dm_ext_slv_sel[1] = (ramadr >= dm_ext_slv_adr1 && ramadr <= (dm_ext_slv_adr1 + dm_ext_slv_len1 -1)) ? 1'b1 : 1'b0;
assign dm_ext_slv_sel[2] = (ramadr >= dm_ext_slv_adr2 && ramadr <= (dm_ext_slv_adr2 + dm_ext_slv_len2 -1)) ? 1'b1 : 1'b0;
assign dm_ext_slv_sel[3] = (ramadr >= dm_ext_slv_adr3 && ramadr <= (dm_ext_slv_adr3 + dm_ext_slv_len3 -1)) ? 1'b1 : 1'b0;




endmodule // avr_interconnect
