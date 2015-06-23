module l1idir(
   input clk,
   input reset,
   
   input [ 6:0] index,
   input [ 1:0] way,
   input [27:0] tag,
	input        strobe,
   input        query,
   input        allocate,   //tag->{way,index}
   input        deallocate, //if({way,index}==tag) {way,index}<-FFFFFF
   input        invalidate, //all ways
   
   output reg [2:0] hit,
   
   output reg       ready // directory init completed
);

`define INVAL_TAG 28'h8000000

reg [27:0] tag_d;
reg [ 6:0] addr;
reg [ 3:0] we;
reg [ 3:0] re;
reg [28:0] di;

wire [28:0] do0;
wire [28:0] do1;
wire [28:0] do2;
wire [28:0] do3;
reg query_d;
reg deallocate_d;
reg query_d1;
reg deallocate_d1;

always @(posedge clk)
   if(strobe)
      if(query || deallocate)
         begin
            tag_d<=tag;
         end

always @(posedge clk)
   begin
      query_d<=query && strobe;
      deallocate_d<=deallocate && strobe;
      query_d1<=query_d;
      deallocate_d1<=deallocate_d;
   end   
   
cachedir icache01 (
   .clock(clk),
   .enable(we[0] || re[0] || we[1] || re[1]),
   .wren_a(we[0]),
   .address_a({1'b0,addr}),
   .data_a(di),
   .q_a(do0),
   
   .wren_b(we[1]),
   .address_b({1'b1,addr}),
   .data_b(di),
   .q_b(do1) 
);
   
cachedir icache23 (
   .clock(clk),
   .enable(we[2] || re[2] || we[3] || re[3]),
   .wren_a(we[2]),
   .address_a({1'b0,addr}),
   .data_a(di),
   .q_a(do2),
   
   .wren_b(we[3]),
   .address_b({1'b1,addr}),
   .data_b(di),
   .q_b(do3) 
);

wire [3:0] hitvect={(do3[28:1]==tag_d),(do2[28:1]==tag_d),(do1[28:1]==tag_d),(do0[28:1]==tag_d)};

`define L1IDIR_RESET   3'b000
`define L1IDIR_INIT    3'b001
`define L1IDIR_IDLE    3'b010
`define L1IDIR_READ    3'b011
`define L1IDIR_DEALLOC 3'b100

reg [2:0] state;

always @(posedge clk or posedge reset)
   if(reset)
      begin
         state<=`L1IDIR_RESET;
         ready<=0;
      end
   else
      case(state)
         `L1IDIR_RESET:
            begin
               addr<=7'b0;
               di<={`INVAL_TAG,1'b0};
               we<=4'b1111;
               state<=`L1IDIR_INIT;
            end
         `L1IDIR_INIT:
            begin
               addr<=addr+1;
               if(addr==7'b1111111)
                  begin
                     we<=4'b0;
                     ready<=1;
                     state<=`L1IDIR_IDLE;
                  end
            end
         `L1IDIR_IDLE:
			   if(strobe)
            if(invalidate)
               begin
                  we<=4'b1111;
                  addr<=index;
                  di<={`INVAL_TAG,1'b0};
               end
            else
				if(allocate)
				   begin
					  case(way)
						 2'b00:we<=4'b0001;
						 2'b01:we<=4'b0010;
						 2'b10:we<=4'b0100;
						 2'b11:we<=4'b1000;
					  endcase
					  addr<=index;
					  di<={tag,1'b0};
				   end
				else
				   if(deallocate)
					  begin
						 re<=4'b1111;
						 we<=0;
						 addr<=index;
						 state<=`L1IDIR_READ;
					  end
				   else
                     if(query)
                        begin
                           addr<=index;
                           re<=4'b1111;
                           we<=0;
                        end
                     else
                        begin
                           we<=0;
                           re<=0;
                        end
			`L1IDIR_READ:
			   state<=`L1IDIR_DEALLOC;
         `L1IDIR_DEALLOC:
            begin
               re<=0;
               di<={`INVAL_TAG,1'b0};
               we<=hitvect;
               state<=`L1IDIR_IDLE;
            end
      endcase

always @(posedge clk)
   if(query_d1 || deallocate_d1)
      case(hitvect)
         4'b0001:hit<=3'b100;
         4'b0010:hit<=3'b101;
         4'b0100:hit<=3'b110;
         4'b1000:hit<=3'b111;
         default:hit<=3'b000; // Hits will be ORed then
      endcase
   else
      if(strobe)
         hit<=3'b000;
      
endmodule
