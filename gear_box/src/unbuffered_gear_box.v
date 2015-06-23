// --------------------------------------------------------------------
//
// --------------------------------------------------------------------


module
  unbuffered_gear_box(
    input       [12:0]  adc_bus,
    output              adc_rd_en,

    output reg  [7:0]   out,

    input               gb_en,
    input               clk_250,
    input               sys_reset
  );


  // --------------------------------------------------------------------
  //
  wire        adc_bus_bank_select;
  wire [3:0]  gear_select;
  wire        ugb_enable = gb_en;
    
  unbuffered_gear_box_fsm 
    i_unbuffered_gear_box_fsm
    (
      .ugb_enable(ugb_enable),
      
      .adc_bus_bank_select(adc_bus_bank_select),
      .adc_rd_en(adc_rd_en),
      .gear_select(gear_select),
      
      .ugb_clock(clk_250),
      .ugb_reset(sys_reset)
    );
    

  // --------------------------------------------------------------------
  //
  reg   [12:0] adc_bus_b0_r;
  reg   [12:0] adc_bus_b1_r;

  always @( posedge clk_250 )
    if( ~adc_bus_bank_select )
        adc_bus_b0_r <= adc_bus;

  always @( posedge clk_250 )
    if( adc_bus_bank_select )
        adc_bus_b1_r <= adc_bus;
        
        
  // --------------------------------------------------------------------
  //  bypass mux
  wire  [12:0] adc_bus_b0_w = adc_bus_bank_select ? adc_bus_b0_r : adc_bus;
  wire  [12:0] adc_bus_b1_w = adc_bus_bank_select ? adc_bus : adc_bus_b1_r;
  wire  [25:0] adc_bus_mux = {adc_bus_b1_w, adc_bus_b0_w};


  // --------------------------------------------------------------------
  //  out mux
  always @( * )
    case( gear_select )
      4'h0:     out = adc_bus_mux[7:0];
      4'h1:     out = adc_bus_mux[15:8];
      4'h2:     out = adc_bus_mux[23:16];
      4'h3:     out = {adc_bus_mux[5:0],adc_bus_mux[25:24]};
      4'h4:     out = adc_bus_mux[13:6];
      4'h5:     out = adc_bus_mux[21:14];
      4'h6:     out = {adc_bus_mux[3:0],adc_bus_mux[25:22]};
      4'h7:     out = adc_bus_mux[11:4];
      4'h8:     out = adc_bus_mux[19:12];
      4'h9:     out = {adc_bus_mux[1:0],adc_bus_mux[25:20]};
      4'ha:     out = adc_bus_mux[9:2];
      4'hb:     out = adc_bus_mux[17:10];
      4'hc:     out = adc_bus_mux[25:18];
      default:  out = adc_bus_mux[7:0];
    endcase


endmodule
