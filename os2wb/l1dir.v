module l1dir(
   input clk,
   input reset,
   
   input        cpu,     // Issuing CPU number
   input        strobe,  // Start transaction
   input [ 1:0] way,     // Way to allocate for allocating loads
   input [39:0] address,
   input        load,
   input        ifill,
   input        store,
   input        cas,
   input        swap,
   input        strload,
   input        strstore,
   input        cacheable,
   input        prefetch,
   input        invalidate,
   input        blockstore,
   
   output [111:0] inval_vect0,    // Invalidation vector
   output [111:0] inval_vect1,    
   output [  1:0] othercachehit, // Other cache hit in the same CPU, wayval0/wayval1
   output [  1:0] othercpuhit,   // Any cache hit in the other CPU, wayval0/wayval1
   output [  1:0] wayval0,       // Way valid
   output [  1:0] wayval1,       // Second way valid for ifill
   output         ready         // Directory init done   
);

wire [3:0] rdy;
wire dquery0=(!cpu) && store && (!blockstore);
wire dquery1=  cpu  && store && (!blockstore);
wire dalloc0=(!cpu) && cacheable && (!invalidate) && load && (!prefetch);
wire dalloc1=  cpu  && cacheable && (!invalidate) && load && (!prefetch);
wire ddealloc0=((!cpu) && ((ifill && (!prefetch) && (!invalidate)) || cas || swap || strstore || (store && blockstore))) ||
               (  cpu  && ((load && cacheable && (!prefetch) && (!invalidate)) || (ifill && (!prefetch) && (!invalidate)) || store || cas || swap || strload || strstore));
wire ddealloc1=(  cpu  && ((ifill && (!prefetch) && (!invalidate)) || cas || swap || strstore || (store && blockstore))) ||
               ((!cpu) && ((load && cacheable && (!prefetch) && (!invalidate)) || (ifill && (!prefetch) && (!invalidate)) || store || cas || swap || strload || strstore));

wire iquery0=0;
wire iquery1=0;
wire ialloc0=(!cpu) && cacheable && (!invalidate) && ifill;
wire ialloc1=  cpu  && cacheable && (!invalidate) && ifill;
wire idealloc0=((!cpu) && ((load && cacheable && (!prefetch) && (!invalidate))          || store || cas || swap || strstore)) ||
               (  cpu  && ((load && cacheable && (!prefetch) && (!invalidate)) || (ifill && (!prefetch) && (!invalidate)) || store || cas || swap || strload || strstore));
wire idealloc1=(  cpu  && ((load && cacheable && (!prefetch) && (!invalidate))          || store || cas || swap || strstore )) ||
               ((!cpu) && ((load && cacheable && (!prefetch) && (!invalidate)) || (ifill && (!prefetch) && (!invalidate)) || store || cas || swap || strload || strstore));


wire [2:0] cpu0_dhit0;
wire [2:0] cpu0_dhit1;
wire [2:0] cpu1_dhit0;
wire [2:0] cpu1_dhit1;
wire [2:0] cpu0_ihit;
wire [2:0] cpu1_ihit;
wire invalidate_d=invalidate && load;
wire invalidate_i=invalidate && ifill;

reg        ifill_d;
reg        load_d;
reg        cacheable_d;
reg        cpu_d;
reg [39:0] address_d;
reg        strobe_d;
reg        strobe_d1;
reg        strobe_d2;

always @(posedge clk)
   begin
      strobe_d<=strobe;
      strobe_d1<=strobe_d;
      strobe_d2<=strobe_d1;
   end
   
always @(posedge clk)
   if(strobe)
      begin
         ifill_d<=ifill;
         load_d<=load;
         cacheable_d<=cacheable;
         cpu_d<=cpu;
         address_d<=address;
      end

l1ddir cpu0_ddir(
   .clk(clk),
   .reset(reset),
   
   .index(address[10:4]),
   .way(way),
   .tag(address[39:11]),
	.strobe(strobe),
   .query(dquery0),
   .allocate(dalloc0),
   .deallocate(ddealloc0),
   .dualdealloc(ifill),
   .invalidate(invalidate_d && !cpu),
   
   .hit0(cpu0_dhit0),
   .hit1(cpu0_dhit1),
   
   .ready(rdy[0])
);

l1ddir cpu1_ddir(
   .clk(clk),
   .reset(reset),
   
   .index(address[10:4]),
   .way(way),
   .tag(address[39:11]),
	.strobe(strobe),
   .query(dquery1),
   .allocate(dalloc1),
   .deallocate(ddealloc1),
   .dualdealloc(ifill),
   .invalidate(invalidate_d && cpu),
   
   .hit0(cpu1_dhit0),
   .hit1(cpu1_dhit1),
   
   .ready(rdy[1])
);

l1idir cpu0_idir(
   .clk(clk),
   .reset(reset),
   
   .index(address[11:5]),
   .way(way),
   .tag(address[39:12]),
	.strobe(strobe),
   .query(iquery0),
   .allocate(ialloc0),
   .deallocate(idealloc0),
   .invalidate(invalidate_i && !cpu),
   
   .hit(cpu0_ihit),
   
   .ready(rdy[2])
);

l1idir cpu1_idir(
   .clk(clk),
   .reset(reset),
   
   .index(address[11:5]),
   .way(way),
   .tag(address[39:12]),
	.strobe(strobe),
   .query(iquery1),
   .allocate(ialloc1),
   .deallocate(idealloc1),
   .invalidate(invalidate_i && cpu),
   
   .hit(cpu1_ihit),
   
   .ready(rdy[3])
);

assign ready=(!rdy[0] | !rdy[1] | !rdy[2] | !rdy[3]) ? 0:1;
assign inval_vect0[3:0]={wayval0,cpu0_ihit[2] && (!address_d[5]),cpu0_dhit0[2] && (address_d[5:4]==2'b00)};
assign inval_vect0[7:4]={wayval0,cpu1_ihit[2] && (!address_d[5]),cpu1_dhit0[2] && (address_d[5:4]==2'b00)};
assign inval_vect0[31:8]=0;
assign inval_vect0[34:32]={wayval0,cpu0_dhit0[2] && (address_d[5:4]==2'b01)};
assign inval_vect0[37:35]={wayval0,cpu1_dhit0[2] && (address_d[5:4]==2'b01)};
assign inval_vect0[55:38]=0;
assign inval_vect0[59:56]={wayval0,cpu0_ihit[2] && address_d[5],cpu0_dhit0[2] && (address_d[5:4]==2'b10)};
assign inval_vect0[63:60]={wayval0,cpu1_ihit[2] && address_d[5],cpu1_dhit0[2] && (address_d[5:4]==2'b10)};
assign inval_vect0[87:64]=0;
assign inval_vect0[90:88]={wayval0,cpu0_dhit0[2] && (address_d[5:4]==2'b11)};
assign inval_vect0[93:91]={wayval0,cpu1_dhit0[2] && (address_d[5:4]==2'b11)};
assign inval_vect0[111:94]=0;

/*assign inval_vect1[3:0]={wayval1,cpu0_dhit1[2] && (address_d[5:4]==2'b00)};
assign inval_vect1[7:4]={wayval1,cpu1_dhit1[2] && (address_d[5:4]==2'b00)};
assign inval_vect1[31:8]=0;
assign inval_vect1[34:32]={wayval1,cpu0_dhit1[2] && (address_d[5:4]==2'b01)};
assign inval_vect1[37:35]={wayval1,cpu1_dhit1[2] && (address_d[5:4]==2'b01)};
assign inval_vect1[55:38]=0;
assign inval_vect1[59:56]={wayval1,cpu0_dhit1[2] && (address_d[5:4]==2'b10)};
assign inval_vect1[63:60]={wayval1,cpu1_dhit1[2] && (address_d[5:4]==2'b10)};
assign inval_vect1[87:64]=0;
assign inval_vect1[90:88]={wayval1,cpu0_dhit1[2] && (address_d[5:4]==2'b11)};
assign inval_vect1[93:91]={wayval1,cpu1_dhit1[2] && (address_d[5:4]==2'b11)};
assign inval_vect1[111:94]=0;*/

assign inval_vect1[3:0]=0;
assign inval_vect1[7:4]=0;
assign inval_vect1[31:8]=0;
assign inval_vect1[34:32]={wayval1,cpu0_dhit1[2] && (address_d[5]==0)};
assign inval_vect1[37:35]={wayval1,cpu1_dhit1[2] && (address_d[5]==0)};
assign inval_vect1[55:38]=0;
assign inval_vect1[59:56]=0;
assign inval_vect1[63:60]=0;
assign inval_vect1[87:64]=0;
assign inval_vect1[90:88]={wayval1,cpu0_dhit1[2] && (address_d[5]==1)};
assign inval_vect1[93:91]={wayval1,cpu1_dhit1[2] && (address_d[5]==1)};
assign inval_vect1[111:94]=0;

assign wayval0=cpu0_dhit0[1:0] | cpu1_dhit0[1:0] | cpu0_ihit[1:0] | cpu1_ihit[1:0];
assign wayval1=cpu0_dhit1[1:0] | cpu1_dhit1[1:0];
assign othercachehit[0]=((!cpu_d) && ifill_d && cpu0_dhit0[2]) ||
                        (  cpu_d  && ifill_d && cpu1_dhit0[2]) ||
                        ((!cpu_d) && load_d && cacheable_d && cpu0_ihit[2]) ||
                        (  cpu_d  && load_d && cacheable_d && cpu1_ihit[2]);
assign othercachehit[1]=((!cpu_d) && ifill_d && cpu0_dhit1[2]) ||
                        (  cpu_d  && ifill_d && cpu1_dhit1[2]);
assign othercpuhit[0]=((!cpu_d) && (cpu1_dhit0[2] || cpu1_ihit[2])) ||
                      (  cpu_d  && (cpu0_dhit0[2] || cpu0_ihit[2]));
assign othercpuhit[1]=((!cpu_d) && ifill_d && cpu1_dhit1[2]) ||
                      (  cpu_d  && ifill_d && cpu0_dhit1[2]);

wire [149:0] ILA_DATA;

st2 st2_inst(
	.acq_clk(clk),
	.acq_data_in(ILA_DATA),
	.acq_trigger_in(ILA_DATA),
	.storage_enable(strobe || strobe_d || strobe_d1 || strobe_d2)
);

assign ILA_DATA[39:0]=address;
assign ILA_DATA[41:40]=way;
assign ILA_DATA[42]=strobe;
assign ILA_DATA[43]=load;
assign ILA_DATA[44]=ifill;
assign ILA_DATA[45]=store;
assign ILA_DATA[46]=cas;
assign ILA_DATA[47]=swap;
assign ILA_DATA[48]=strload;
assign ILA_DATA[49]=strstore;
assign ILA_DATA[50]=cacheable;
assign ILA_DATA[51]=prefetch;
assign ILA_DATA[52]=invalidate;
assign ILA_DATA[53]=blockstore;
assign ILA_DATA[55:54]=othercachehit;
assign ILA_DATA[57:56]=othercpuhit;
assign ILA_DATA[59:58]=wayval0;
assign ILA_DATA[61:60]=wayval1;
assign ILA_DATA[69:62]=inval_vect0[7:0];
assign ILA_DATA[75:70]=inval_vect0[37:32];
assign ILA_DATA[83:76]=inval_vect0[63:56];
assign ILA_DATA[89:84]=inval_vect0[93:88];
assign ILA_DATA[97:90]=inval_vect1[7:0];
assign ILA_DATA[103:98]=inval_vect1[37:32];
assign ILA_DATA[111:104]=inval_vect1[63:56];
assign ILA_DATA[117:112]=inval_vect1[93:88];
assign ILA_DATA[118]=dquery0;
assign ILA_DATA[119]=dquery1;
assign ILA_DATA[120]=dalloc0;
assign ILA_DATA[121]=dalloc1;
assign ILA_DATA[122]=ddealloc0;
assign ILA_DATA[123]=ddealloc1;
assign ILA_DATA[124]=iquery0;
assign ILA_DATA[125]=iquery1;
assign ILA_DATA[126]=ialloc0;
assign ILA_DATA[127]=ialloc1;
assign ILA_DATA[128]=idealloc0;
assign ILA_DATA[129]=idealloc1;

endmodule
