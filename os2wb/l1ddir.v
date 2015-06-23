module l1ddir(
   input clk,
   input reset,
   
   input [ 6:0] index,
   input [ 1:0] way,
   input [28:0] tag,
	input        strobe,
   input        query,
   input        allocate,   //tag->{way,index}
   input        deallocate, //if({way,index}==tag) {way,index}<-FFFFFF
   input        dualdealloc,
   input        invalidate, //all ways
   
   output reg [2:0] hit0,
   output reg [2:0] hit1,
   
   output reg       ready // directory init completed
);

`define INVAL_TAG 29'h10000000

reg [28:0] tag_d;
reg [ 6:0] addr0;
reg [ 5:0] addr1;
reg [ 3:0] we0;
reg [ 3:0] we1;
reg [ 3:0] re;
reg [28:0] di;
reg        dualdealloc_d;
wire [28:0] do0_0;
wire [28:0] do1_0;
wire [28:0] do2_0;
wire [28:0] do3_0;
wire [28:0] do0_1;
wire [28:0] do1_1;
wire [28:0] do2_1;
wire [28:0] do3_1;
reg query_d;
reg deallocate_d;
reg query_d1;
reg deallocate_d1;

always @(posedge clk)
   if(strobe)
      if(query || deallocate)
         begin
            tag_d<=tag;
            dualdealloc_d<=dualdealloc;
         end

always @(posedge clk)
   begin
      query_d<=query && strobe;
      deallocate_d<=deallocate && strobe;
      query_d1<=query_d;
      deallocate_d1<=deallocate_d;
   end
   
cachedir dcache0 (
   .clock(clk),
   .enable(we0[0] || we1[0] || re[0]),
   .wren_a(we0[0]),
   .address_a({1'b0,addr0}),
   .data_a(di),
   .q_a(do0_0),
   
   .wren_b(we1[0]),
   .address_b({1'b0,addr1,1'b1}),
   .data_b(`INVAL_TAG),
   .q_b(do0_1) 
);
   
cachedir dcache1 (
   .clock(clk),
   .enable(we0[1] || we1[1] || re[1]),
   .wren_a(we0[1]),
   .address_a({1'b0,addr0}),
   .data_a(di),
   .q_a(do1_0),
   
   .wren_b(we1[1]),
   .address_b({1'b0,addr1,1'b1}),
   .data_b(`INVAL_TAG),
   .q_b(do1_1) 
);

cachedir dcache2 (
   .clock(clk),
   .enable(we0[2] || we1[2] || re[2]),
   .wren_a(we0[2]),
   .address_a({1'b0,addr0}),
   .data_a(di),
   .q_a(do2_0),
   
   .wren_b(we1[2]),
   .address_b({1'b0,addr1,1'b1}),
   .data_b(`INVAL_TAG),
   .q_b(do2_1) 
);
   
cachedir dcache3 (
   .clock(clk),
   .enable(we0[3] || we1[3] || re[3]),
   .wren_a(we0[3]),
   .address_a({1'b0,addr0}),
   .data_a(di),
   .q_a(do3_0),
   
   .wren_b(we1[3]),
   .address_b({1'b0,addr1,1'b1}),
   .data_b(`INVAL_TAG),
   .q_b(do3_1) 
);

wire [3:0] hitvect0={(do3_0==tag_d),(do2_0==tag_d),(do1_0==tag_d),(do0_0==tag_d)};
wire [3:0] hitvect1={(do3_1==tag_d),(do2_1==tag_d),(do1_1==tag_d),(do0_1==tag_d)};

`define L1DDIR_RESET   3'b000
`define L1DDIR_INIT    3'b001
`define L1DDIR_IDLE    3'b010
`define L1DDIR_READ    3'b011
`define L1DDIR_DEALLOC 3'b100

reg [2:0] state;

always @(posedge clk or posedge reset)
   if(reset)
      begin
         state<=`L1DDIR_RESET;
         ready<=0;
      end
   else
      case(state)
         `L1DDIR_RESET:
            begin
               addr0<=7'b0;
               addr1<=6'b0;
               di<=`INVAL_TAG;
               we0<=4'b1111;
               we1<=4'b1111;
               state<=`L1DDIR_INIT;
            end
         `L1DDIR_INIT:
            begin
               addr0<=addr0+2;
               addr1<=addr1+1;
               if(addr0==7'b1111110)
                  begin
                     we0<=4'b0;
                     we1<=4'b0;
                     ready<=1;
                     state<=`L1DDIR_IDLE;
                  end
            end
         `L1DDIR_IDLE:
			   if(strobe)
            if(invalidate)
               begin
                  we0<=4'b1111;
                  we1<=0;
                  addr0<=index;
                  di<=`INVAL_TAG;
               end
            else
				if(allocate)
				   begin
					  case(way)
						 2'b00:we0<=4'b0001;
						 2'b01:we0<=4'b0010;
						 2'b10:we0<=4'b0100;
						 2'b11:we0<=4'b1000;
					  endcase
					  we1<=0;
					  addr0<=index;
					  di<=tag;
				   end
				else
				   if(deallocate)
					  begin
						 re<=4'b1111;
						 we0<=0;
						 we1<=0;
						 if(dualdealloc)
							begin
							   addr0<={index[6:1],1'b0};
							   addr1<=index[6:1];
							end
						 else
							addr0<=index;
						 state<=`L1DDIR_READ;
					  end
				   else
                     if(query)
                        begin
                           addr0<=index;
                           re<=4'b1111;
                           we0<=0;
                           we1<=0;
                        end
                     else
                        begin
                           we0<=0;
                           we1<=0;
                           re<=0;
                        end
			`L1DDIR_READ:
			   state<=`L1DDIR_DEALLOC;
         `L1DDIR_DEALLOC:
            begin
               re<=0;
               di<=`INVAL_TAG;
               we0<=hitvect0;
               if(dualdealloc_d)
                  we1<=hitvect1;
               else
                  we1<=0;
               state<=`L1DDIR_IDLE;
            end
      endcase

always @(posedge clk)
   if(query_d1 || deallocate_d1)
      begin
         case(hitvect0)
            4'b0001:hit0<=3'b100;
            4'b0010:hit0<=3'b101;
            4'b0100:hit0<=3'b110;
            4'b1000:hit0<=3'b111;
            default:hit0<=3'b000; // Hits will be ORed then
         endcase
         if(dualdealloc_d && deallocate_d1)
			 case(hitvect1)
				4'b0001:hit1<=3'b100;
				4'b0010:hit1<=3'b101;
				4'b0100:hit1<=3'b110;
				4'b1000:hit1<=3'b111;
				default:hit1<=3'b000;
			 endcase
	     else
	        hit1<=3'b000;
      end
   else
      if(strobe)
         begin
            hit0<=3'b000;
            hit1<=3'b000;
         end
   
endmodule
