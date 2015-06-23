// --------------------------------------------------------------------
//
// --------------------------------------------------------------------


module
  buffered_gear_box(
    input   [12:0]  adc_bus,
    output          adc_data_stall,

    output  [7:0]   out,

    input           clk_1250,
    input           clk_250,
    input           sys_reset
  );


  // --------------------------------------------------------------------
  //
  reg [3:0] gear_select;
  wire      gear_reset = sys_reset | ~(gear_select < 4'hc);

  always @( posedge clk_250 )
    if( gear_reset )
      gear_select <= 0;
    else
      gear_select <= gear_select + 1;


  // --------------------------------------------------------------------
  //
  reg load_shift_r_select;
  
  always @( posedge clk_250 )
    if( sys_reset )
      load_shift_r_select <= 0;
    else if( gear_reset )
      load_shift_r_select <= ~load_shift_r_select;
  

  // --------------------------------------------------------------------
  //
  reg [3:0] counter;
  wire      shift_en = (~gear_reset) & (counter < 4'h8);

  always @( posedge clk_1250 )
    if( gear_reset )
      counter <= 0;
    else if( shift_en )
      counter <= counter + 1;


  // --------------------------------------------------------------------
  //
  reg [103:0] shift_b0_r;
  reg [103:0] shift_b1_r;

  always @( posedge clk_1250 )
    if( ~load_shift_r_select & shift_en )
        shift_b0_r <= {adc_bus, shift_b0_r[103:13]};

  always @( posedge clk_1250 )
    if( load_shift_r_select & shift_en )
        shift_b1_r <= {adc_bus, shift_b1_r[103:13]};


  // --------------------------------------------------------------------
  //
  reg  [7:0] shift_b0_r_mux;

  always @( * )
    case( gear_select )
      4'h0:      shift_b0_r_mux = shift_b0_r[7:0];
      4'h1:      shift_b0_r_mux = shift_b0_r[15:8];
      4'h2:      shift_b0_r_mux = shift_b0_r[23:16];
      4'h3:      shift_b0_r_mux = shift_b0_r[31:24];
      4'h4:      shift_b0_r_mux = shift_b0_r[39:32];
      4'h5:      shift_b0_r_mux = shift_b0_r[47:40];
      4'h6:      shift_b0_r_mux = shift_b0_r[55:48];
      4'h7:      shift_b0_r_mux = shift_b0_r[63:56];
      4'h8:      shift_b0_r_mux = shift_b0_r[71:64];
      4'h9:      shift_b0_r_mux = shift_b0_r[79:72];
      4'ha:      shift_b0_r_mux = shift_b0_r[87:80];
      4'hb:      shift_b0_r_mux = shift_b0_r[95:88];
      4'hc:      shift_b0_r_mux = shift_b0_r[103:96];
      default:   shift_b0_r_mux = shift_b0_r[7:0];
    endcase


  // --------------------------------------------------------------------
  //
  reg  [7:0] shift_b1_r_mux;

  always @( * )
    case( gear_select )
      4'h0:      shift_b1_r_mux = shift_b1_r[7:0];
      4'h1:      shift_b1_r_mux = shift_b1_r[15:8];
      4'h2:      shift_b1_r_mux = shift_b1_r[23:16];
      4'h3:      shift_b1_r_mux = shift_b1_r[31:24];
      4'h4:      shift_b1_r_mux = shift_b1_r[39:32];
      4'h5:      shift_b1_r_mux = shift_b1_r[47:40];
      4'h6:      shift_b1_r_mux = shift_b1_r[55:48];
      4'h7:      shift_b1_r_mux = shift_b1_r[63:56];
      4'h8:      shift_b1_r_mux = shift_b1_r[71:64];
      4'h9:      shift_b1_r_mux = shift_b1_r[79:72];
      4'ha:      shift_b1_r_mux = shift_b1_r[87:80];
      4'hb:      shift_b1_r_mux = shift_b1_r[95:88];
      4'hc:      shift_b1_r_mux = shift_b1_r[103:96];
      default:   shift_b1_r_mux = shift_b1_r[7:0];
    endcase


  // --------------------------------------------------------------------
  //
  assign adc_data_stall = ~shift_en;
 
  
  assign out = load_shift_r_select ? shift_b0_r_mux : shift_b1_r_mux;


endmodule
