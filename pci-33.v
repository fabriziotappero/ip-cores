// *************************************************************** //
//																						 //
//			PCI_TARGET-Wishbone_MASTER INTERFACE MODULE	(PCI-mini)	 //
//											v2.0										 //
//																						 //
//   The original PCI module is from:	Ben Jackson						 //
//				http://www.ben.com/minipci/verilog.php						 //
//																						 //
//	  Redesigned for wishbone : Istvan Nagy, buenos@freemail.hu		 //
//						PEC Products, Industrial Technologies				 //
//																						 //
// *************************************************************** //

// The core implements a 16MB relocable memory image. Relocable on the
//   wb bus. the wb address = 4M*wb_baseaddr_reg + PCI_addr[23:2]
//   Only Dword aligned Dword accesses allowed on the PCI. This way
//   we can access to the 4GB wb-space through a 16MB PCI-window.
//   The addressing on the wb-bus, is Dword addressing, while on the
//   PCI bus, the addressing is byte addressing. A(pci)=A(wb)*4
//   The PCI address is increasing by 4, and we get 4 bytes. The wb
//   address is increasing by 1, and we get 1 Dword (= 4 bytes also).
//   The wb_baseaddr_reg is the wb image relocation register, can be
//   accessed at 50h address in the PCI configuration space.
//   Other bridge status and command is at the 54h and 58h addresses.
//   if access fails with timeout, then the address will be in the 
//   wb address will be stored in the failed_addr_reg at 5Ch address.
//
// Wishbone compatibility:
//  Wishbone signals: wb_address, wb_dat_o, wb_dat_i, wb_sel_o, wb_cyc_o, 
//  wb_stb_o, wb_wr_o, wb_reset_o, wb_clk_o, wb_ack_i.
//  Not implemented wb signals: error, lock, retry, tag-signals.
//  The peripheral has to response with ack in 16 clk cycles.
//  The core has wishbone clk and reset outputs, just like a Syscon module.
//  The core generates single reads/writes. These are made of 4 phases, so
//  dont write new data, until internal data movement finishes: about 300...500ns
//
// PCI compatibility: 
// Only single DWORD reads/writes are supported. between them, the software has 
//   to wait 300...500nsec, to prevent data corrupting. STOP signaling is not 
//   implemented, so target terminations also not. 
//   Single Byte access is NOT supported! It may cause corrupt data.
//   The core uses INTA interrupt signal. There are some special PCI config
//   registers, from 50h...60h config-space addresses.
//   PCI-parity: it generates parity, but doesnt check incoming parity.
//   Because of the PC chipset, if you read a value and write it back,
//   the chipset will not write anything, because it can see the data is not 
//   changed. This is important at some peripherals, where you write, to control.
// Device specific PCI config header registers:
//   name:					addr:		function:
//   wb_baseaddr_reg;	50h		A(wb)=(A(pci)-BAR0)/4 + wb_baseaddr_reg
//   user_status_reg;	54h		not used yet
//   user_command_reg;	58h		not used yet
//   failed_addr_reg;	5Ch		address, when timeout occurs on the wb bus.
//
// Local bus arbitration: 
// This is not really wishbone compatible, but needed for the PCI.
//  The method is: "brute force". it means if the PCI interface wants to
//  be mastering on the local (wishbone) bus, then it will be mastering,
//  so, the other master(s) must stop anything immediately. The req signal
//  goes high when there is an Address hit on teh PCI bus. so the other
//  master has few clk cycles to finish.
// Restrictions: the peripherals have to be fast: If the other master
//  starts a transaction before req goes high, the ack has to arrive before 
//  the PCI interface starts its own transaction. (max 4clk ACK delay)
//  The other master or the bus unit must sense the req, and give bus
//  mastering to the PCI-IF immediatelly, not just when the other master
//  finished everything, like at normal arbitration schemes.
//
// Buffering:
//  There is a single Dword buffering only.
//
// The led_out interface: 
//  only for system-debug: we can write to the LEDs, at any address. 
//  (in the same time there is a wishbone write also)
//
// Changes since original version: wishbone interface,
//  bigger memory-image, parity-generation,
//  interrupt handling. Code size is 3x bigger. New registers, 
//
// *************************************************************** //



module pci(reset,clk,frame,irdy,trdy,devsel,idsel,ad,cbe,par,stop,inta,serr,perr,led_out, wb_address, wb_dat_o, wb_dat_i, wb_sel_o, wb_cyc_o, wb_stb_o, wb_wr_o, wb_reset_o, wb_clk_o, wb_ack_i, wb_irq, wb_req, wb_gnt, wb_req_other, contr_o);
    input reset;
    input clk;
    input frame;
    input irdy;
    output trdy;
    output devsel;
    input idsel;
    inout [31:0] ad;
    input [3:0] cbe;
    inout par;
    output stop;
    output inta;
    output serr;
    output perr;
    output [3:0] led_out;
		output [31:0] wb_address;
		output [31:0] wb_dat_o; 
		input [31:0] wb_dat_i;
		output [3:0] wb_sel_o; 
		output wb_cyc_o; 
		output wb_stb_o; 
		output wb_wr_o; 
		output wb_reset_o;
		output wb_clk_o;
		input wb_ack_i;
		input wb_irq;
		output wb_req;
		input wb_gnt;
		input wb_req_other;	
	output [7:0] contr_o; 
	 
	 

parameter DEVICE_ID = 16'h9500;
parameter VENDOR_ID = 16'h10EE; //	 16'h10EE=xilinx, 16'h106d; // Sequent!
parameter DEVICE_CLASS = 24'h068000;	// Bridge device - other_bridge_type (original:FF0000 Misc)
parameter DEVICE_REV = 8'h01;
parameter SUBSYSTEM_ID = 16'h0001;	// Card identifier
parameter SUBSYSTEM_VENDOR_ID = 16'hBEBE; // Card identifier
parameter DEVSEL_TIMING = 2'b00;	// Fast!

reg [2:0] state;
reg [31:0] data;

reg [1:0] enable;
parameter EN_NONE = 0;
parameter EN_RD = 1;
parameter EN_WR = 2;
parameter EN_TR = 3;

reg memen; // respond to baseaddr?
reg [7:0] baseaddr;
reg [5:0] address;

reg [9:0] wb_baseaddr_reg; //remap the image on the wishbone bus
reg [31:0] wb_address_1;
reg [31:0] user_status_reg;
reg [31:0] user_command_reg;
reg [31:0] failed_addr_reg;
reg [31:0] dummy_reg;
reg [31:0] pci_read_reg;
reg [31:0] pci_write_reg;
reg [31:0] wb_read_reg;
reg [31:0] wb_write_reg;
reg [3:0] pci_read_sel_reg;
reg [3:0] pci_write_sel_reg;
reg [3:0] wb_read_sel_reg;
reg [3:0] wb_write_sel_reg;

assign contr_o = user_command_reg [7:0];

parameter ST_IDLE = 3'b000;
parameter ST_BUSY = 3'b010;
parameter ST_MEMREAD = 3'b100;
parameter ST_MEMWRITE = 3'b101;
parameter ST_CFGREAD = 3'b110;
parameter ST_CFGWRITE = 3'b111;

parameter MEMREAD = 4'b0110;
parameter MEMWRITE = 4'b0111;
parameter CFGREAD = 4'b1010;
parameter CFGWRITE = 4'b1011;

`define LED
`ifdef LED
reg [3:0] led;
`endif

`undef STATE_DEBUG_LED
`ifdef STATE_DEBUG_LED
assign led_out = ~state;
`else
`ifdef LED
assign led_out = ~led; 
`endif
`endif

assign ad = (enable == EN_RD) ? data : 32'bZ;
assign trdy = (enable == EN_NONE) ? 'bZ : (enable == EN_TR ? 1 : 0);
//assign par = (enable == EN_RD) ? 0 : 'bZ;
reg devsel;

assign stop = 1'bZ;
//assign inta = 1'bZ;
assign serr = 1'bZ;
assign perr = 1'bZ;


wire cfg_hit = ((cbe == CFGREAD || cbe == CFGWRITE) && idsel && ad[1:0] == 2'b00);
wire addr_hit = ((cbe == MEMREAD || cbe == MEMWRITE) && memen && ad[31:24] == {baseaddr});
wire hit = cfg_hit | addr_hit;

// Wishbone SYSCON: output signals------------------------------------
assign wb_reset_o = ~reset;
assign wb_clk_o = clk;
//reg wb_clk_o;
   //always @(posedge clk)
		//wb_clk_o = wb_clk_o+ 1;


// PCI parity generation:---------------------------------------------
// during read, the parity on AD, and delayen by one clk.
reg par_en;
reg par_latched;
reg EN_RDd;
wire data_par = (data[31] ^ data[30] ^ data[29] ^ data[28]) ^
                (data[27] ^ data[26] ^ data[25] ^ data[24]) ^
                (data[23] ^ data[22] ^ data[21] ^ data[20]) ^
                (data[19] ^ data[18] ^ data[17] ^ data[16]) ^
                (data[15] ^ data[14] ^ data[13] ^ data[12]) ^
                (data[11] ^ data[10] ^ data[9]  ^ data[8])  ^
                (data[7]  ^ data[6]  ^ data[5]  ^ data[4])  ^
					  (cbe[3]  ^ cbe[2]  ^ cbe[1]  ^ cbe[0])  ^
                (data[3]  ^ data[2]  ^ data[1]  ^ data[0]) ;
	
   always @(posedge clk) //delaying of parity
      if ((enable == EN_RD)|(enable == EN_TR)) begin
         par_latched = data_par; end
      else                  
         begin par_latched = 0; end
			
   always @(posedge clk) //delaying of EN_RD
			EN_RDd = EN_RD;
			
	//assign par = (enable == EN_RD) ? 0 : 'bZ;
	assign par = ((enable == EN_RD)|(enable == EN_RDd)) ? par_latched : 'bZ; //output control



// Interrupt handling:--------------------------------------------------------------------
reg int_dis;
wire int_stat;
reg [7:0] int_line;
assign inta = ((wb_irq == 1) && (int_dis == 0)) ? 1'b0 : 1'bZ;
assign int_stat = wb_irq;



// WB bus arbitration:--------------------------------------------------------------------
//assign wb_req = mastering;
reg arb_start;
reg arb_stop;
reg wb_req;

   parameter arb_state1 = 2'b00;
   parameter arb_state2 = 2'b01;
   reg  arb_state = arb_state1;
   always@(posedge clk) begin
      if (wb_reset_o) begin
         arb_state <= arb_state1;
         wb_req <= 0;
      end
      else
         case (arb_state)
            arb_state1 : begin //arbitration is not needed: IDLE
               wb_req <= 0;
               if (arb_start == 1)
                  arb_state <= arb_state2;
            end
            arb_state2 : begin //arbitration is needed
               wb_req <= 1;
               if (arb_stop == 1)
                  arb_state <= arb_state1;
            end
            default : begin  // Fault Recovery
               arb_state <= arb_state1;
               wb_req <= 0;
            end   
         endcase
		end	
			


// -------------- wishbone state machine --------------------------------------------------
//write FIFO buffer:
reg [31:0] wb_wr_buf [5:0]; //64 Dwords wb write buffer: wb_wr_buf[index] <= value;
reg [3:0] wb_wr_sel_buf [5:0]; //select lines, write buffer: wb_wr_buf[index] <= value;
reg [31:0] fifo_start_wb_addr;
reg [31:0] fifo_act_wb_addr;
reg [5:0] fifo_max_count;
reg [5:0] fifo_wb_counter;
reg [5:0] fifo_wb_counter_o;
reg fifo_flush; //wb output mux control
reg fifo_flush_start; //start pulse
reg fifo_fill; //disable wb during filling fifo
reg [3:0] wbw_timeout_count_new;
reg [1:0] wbw_phase;
//read FIFO buffer:
reg [31:0] wb_rd_buf [5:0]; //64 Dwords wb read buffer: wb_rd_buf[index] <= value;
reg [3:0] wb_rd_sel_buf [5:0]; //select lines, write buffer: wb_wr_buf[index] <= value;
reg [31:0] fifo_start_wb_addr_rd;
reg [31:0] fifo_act_wb_addr_rd;
reg [5:0] fifo_max_count_rd;
reg [5:0] fifo_wb_counter_rd;
reg [5:0] fifo_wb_counter_o_rd;
reg fifo_flush_rd; //wb output mux control
reg fifo_fill_start_rd; //start pulse
reg fifo_fill_rd; //disable wb during filling fifo
reg [3:0] wbr_timeout_count_new;
reg [1:0] wbr_phase;
//
reg wb_cyc_o;
reg wb_stb_o;
reg wb_wr_o;
reg [31:0] wb_address;
reg [3:0] wb_sel_o;
reg [31:0] wb_dat_o;
reg machinereset;
reg mastering;
//assign wb_req = mastering;


   parameter machine_waiting = 2'b00;
   parameter machine_flushing = 2'b01;
   parameter machine_read_filling = 2'b11;
   reg [1:0] wbwf_state = machine_waiting;
	
   always@(posedge wb_clk_o) 
      if (wb_reset_o) begin
         wbwf_state <= machine_waiting;
			 wbw_phase <= 0;
			wbw_timeout_count_new <= 0;
			fifo_wb_counter_o<=0;
			fifo_flush <= 0;
			wb_cyc_o <= 0;
			wb_stb_o <= 0;
			wb_wr_o <= 0;
			 wbr_phase <= 0;
			wbr_timeout_count_new <= 0;
			fifo_wb_counter_o_rd<=0;
			fifo_fill_rd <= 0;
			wb_address[31:0] = 32'b0;
			wb_sel_o = 4'b0;
			wb_dat_o = 32'b0;
			pci_read_reg <= 0;
			mastering <= 0;
			arb_stop <= 0;
			failed_addr_reg <= 0;
      end
      else
         case (wbwf_state)
			
            machine_waiting : begin //no operation on Wishbone bus **************
					wbw_phase <= 0;
					wbw_timeout_count_new <= 0;
					wbr_phase <= 0;
					wbr_timeout_count_new <= 0;
					wb_address[31:0] = 32'b0;
					wb_cyc_o <= 0;
					wb_stb_o <= 0;
					wb_wr_o <= 0;		
					wb_sel_o = 4'b0;	
					wb_dat_o = 32'b0;		
					arb_stop <= 0;					
               if (fifo_flush_start  == 1)
                  begin fifo_flush <= 1; wbwf_state <= machine_flushing; fifo_wb_counter_o<=0; mastering <= 1; end 
					else if (fifo_fill_start_rd == 1)
                  begin fifo_fill_rd <= 1; wbwf_state <= machine_read_filling; fifo_wb_counter_o_rd<=0; mastering <= 1; end 	
            end
				
            machine_flushing : begin //wr-FIFO flushing: wb write***********************
					wb_sel_o = pci_write_sel_reg;
					wb_dat_o  = pci_write_reg; //wb_wr_buf[fifo_wb_counter_o];
					wb_address[31:0]  = fifo_start_wb_addr; //[31:0]+fifo_wb_counter_o ;
               if ( wbw_phase== 0 ) begin //phase 0: setup
                  wb_cyc_o <= 0;
						wb_stb_o <= 0;
						wb_wr_o <= 0;
						wbw_phase <= wbw_phase + 1;
						//address and data also changes now, from FIFO
					end
					else if ( wbw_phase== 1 ) begin //phase 1: access
                  wb_cyc_o <= 1;
						wb_stb_o <= 1;
						wb_wr_o <= 1;
						wbw_phase <= wbw_phase + 1;					
					end
					else if ( wbw_phase== 2 ) begin //phase 2: wait for ack
 						wbw_timeout_count_new <= wbw_timeout_count_new +1;
						if ((wb_ack_i==1) | (wbw_timeout_count_new==15)) begin 
							wbw_phase <= wbw_phase + 1; 
							wb_cyc_o <= 0;	
							wb_stb_o <= 0;	
							wb_wr_o <= 0;
							if (wbw_timeout_count_new==15) begin failed_addr_reg <= wb_address; end
							end	
						else begin wb_cyc_o <= 1;	wb_stb_o <= 1;	wb_wr_o <= 1; end
					end
					else  if ( wbw_phase== 3 ) begin //phase 3: hold (finish)
					   wb_cyc_o <= 0;
						wb_stb_o <= 0;
						wb_wr_o <= 0;
						wbw_phase <= wbw_phase + 1;
						wbw_timeout_count_new <=0;
						fifo_wb_counter_o <= fifo_wb_counter_o + 1; //for next word
						//if ((fifo_wb_counter_o == fifo_max_count-1)|(machinereset == 1)) begin 
							fifo_flush <= 0; 
							wbwf_state <= machine_waiting; 
							fifo_wb_counter_o<=0; 
							mastering <= 0;
							arb_stop <= 1;
						//end
					end
            end
				
            machine_read_filling : begin //rd-FIFO filling: wb read********************
				   wb_sel_o = pci_read_sel_reg;
					wb_dat_o = 32'b0;
					wb_address[31:0]  = fifo_start_wb_addr_rd; //[31:0]+fifo_wb_counter_o_rd ;
               if ( wbr_phase== 0 ) begin //phase 0: setup
                  wb_cyc_o <= 0;
						wb_stb_o <= 0;
						wb_wr_o <= 0;
						wbr_phase <= wbr_phase + 1;
						//address and data also changes now, from FIFO
					end
					else if ( wbr_phase== 1 ) begin //phase 1: access
                  wb_cyc_o <= 1;
						wb_stb_o <= 1;
						wb_wr_o <= 0;
						wbr_phase <= wbr_phase + 1;					
					end
					else if ( wbr_phase== 2 ) begin //phase 2: wait for ack
 						wbr_timeout_count_new <= wbr_timeout_count_new +1;
						if ((wb_ack_i==1) | (wbr_timeout_count_new==15)) begin 
							//wb_rd_buf[fifo_wb_counter_o_rd] <= wb_dat_i; //sampling
							pci_read_reg <= wb_dat_i; //sampling
							wbr_phase <= wbr_phase + 1; 
							wb_cyc_o <= 0;	
							wb_stb_o <= 0;	
							wb_wr_o <= 0;
							if (wbw_timeout_count_new==15) begin failed_addr_reg <= wb_address; end
							end	
						else begin wb_cyc_o <= 1;	wb_stb_o <= 1;	wb_wr_o <= 0; end
					end
					else  if ( wbr_phase== 3 ) begin //phase 3: hold (finish)
					   wb_cyc_o <= 0;
						wb_stb_o <= 0;
						wb_wr_o <= 0;
						wbr_phase <= wbw_phase + 1;
						wbr_timeout_count_new <=0;
						fifo_wb_counter_o_rd <= fifo_wb_counter_o_rd + 1; //for next word
						//if ((fifo_wb_counter_o_rd == fifo_max_count_rd-1)|(machinereset == 1)) begin 
							fifo_fill_rd <= 0; 
							wbwf_state <= machine_waiting; 
							fifo_wb_counter_o_rd<=0; 
							mastering <= 0;
							arb_stop <= 1;
						//end
					end
            end
				
            default : begin  // Fault Recovery
               wbwf_state <= machine_waiting;
            end   				
				
				
         endcase	







// main PCI state machine: ---------------------------------------------------------------
always @(posedge clk)
begin
    if (~reset) begin
        state <= ST_IDLE;
        enable <= EN_NONE;
        baseaddr <= 0;
        devsel <= 'bZ;
        memen <= 0;
		  int_line <= 8'b0;
		  int_dis <= 0;
		  wb_baseaddr_reg <= 0;
		  wb_address_1[31:0] <= 0;
		  user_status_reg <= 0;
		  user_command_reg <= 0;
		  fifo_flush_start <= 0;
		  fifo_fill_start_rd <= 0;
		  fifo_wb_counter <= 0;
		  fifo_wb_counter_rd <= 0;		 
			dummy_reg  <= 0;		
			pci_write_reg <= 0;
			machinereset   <= 0;			
        led <= 0;
		  arb_start <= 0;

    end
    else    begin
                
    case (state)
        ST_IDLE: begin
            enable <= EN_NONE;
            devsel <= 'bZ;
				fifo_flush_start <= 0;
				fifo_fill_start_rd <= 0;
				fifo_wb_counter <= 0;
				fifo_wb_counter_rd <= 0;
				machinereset   <= 0;	
            if (~frame) begin
                address <= ad[7:2];
                if (hit) begin
                    state <= {1'b1, cbe[3], cbe[0]};
						  if (addr_hit) begin  arb_start <= 1; end
                    devsel <= 0;
						  wb_address_1[31:0] <= {wb_baseaddr_reg, ad[23:2]};
						  //if (wbwf_state == machine_waiting) begin //sample address, if FIFO is not busy
								fifo_start_wb_addr <= {wb_baseaddr_reg, ad[23:2]};
								fifo_start_wb_addr_rd <= {wb_baseaddr_reg, ad[23:2]};
						  //end		
                    // pipeline the write enable
                    if (cbe[0])
                        enable <= EN_WR;
                end
                else begin
                    state <= ST_BUSY;
                    enable <= EN_NONE;
                end
            end
        end

        ST_BUSY: begin
            devsel <= 'bZ;
            enable <= EN_NONE;
				arb_start <= 0;
            if (frame)
                state <= ST_IDLE;
        end

        ST_CFGREAD: begin
            enable <= EN_RD;
            if (~irdy || trdy) begin
                case (address)
                    0: data <= { DEVICE_ID, VENDOR_ID };
                    1: data <= { 5'b0, DEVSEL_TIMING,  5'b0, int_stat, 8'b0, int_dis, 8'b0, memen, 1'b0};
                    2: data <= { DEVICE_CLASS, DEVICE_REV };
                    4: data <= { baseaddr, 12'b0, 8'b0, 4'b0000 }; // baseaddr + request mem < 1Mbyte
                    11: data <= {SUBSYSTEM_ID, SUBSYSTEM_VENDOR_ID };
						  15: data <= {16'b0, 7'b0, 1'b1, int_line}; //irq pin and line
                    16: data <= { 24'b0, baseaddr };
						  20: data <= { wb_baseaddr_reg, 22'b0}; //wb base address: for wb-local relocation
						  21: data <= user_status_reg;
						  22: data <= user_command_reg;
						  23: data <= failed_addr_reg; //actual addr, at a timeout
                    default: data <= 'h00000000;
                endcase
                address <= address + 1;
					 arb_start <= 0;
            end
            if (frame && ~irdy && ~trdy) begin
                devsel <= 1;
                state <= ST_IDLE;
                enable <= EN_TR;
            end
        end

        ST_CFGWRITE: begin
            enable <= EN_WR;
            if (~irdy) begin
                case (address)
                    4: baseaddr <= ad[31:24];  // XXX examine cbe
                    1: begin memen <= ad[1]; int_dis <= ad[10]; end
						  15: int_line <= ad[7:0];
						  20: wb_baseaddr_reg <= ad[31:22];
						  22: user_command_reg  <= ad[31:0];
						  24: machinereset   <= 1;	//resetting the wb state machine (60h)
                    default: ;
                endcase
                address <= address + 1;
					 arb_start <= 0;
                if (frame) begin
                    devsel <= 1;
                    state <= ST_IDLE;
                    enable <= EN_TR;
                end
            end
        end

        ST_MEMREAD: begin
            enable <= EN_RD;
				arb_start <= 0;
            if (~irdy || trdy) begin
                address <= address + 1;
					 data <= pci_read_reg; 
					 pci_read_sel_reg  <= ~cbe;
            end
            if (frame && ~irdy && ~trdy) begin
                devsel <= 1;
                state <= ST_IDLE;
                enable <= EN_TR;
						  fifo_fill_rd<=0;
						  //if (wbwf_state == machine_waiting) begin 
								fifo_fill_start_rd <= 1;	
						  //end 					 
            end
        end

        ST_MEMWRITE: begin
            enable <= EN_WR;
				arb_start <= 0;
            if (~irdy) begin
					 led <= ad[3:0];
					 pci_write_reg  <= ad[31:0]; 
					 pci_write_sel_reg <= ~cbe;
                address <= address + 1;
                if (frame) begin
                    devsel <= 1;
                    state <= ST_IDLE;
                    enable <= EN_TR;
						  fifo_fill<=0;
						  //if (wbwf_state == machine_waiting) begin 
								fifo_flush_start <= 1;	
						  //end 	
               end
            end

        end

    endcase
    end
end
endmodule
