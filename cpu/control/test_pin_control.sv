//==============================================================
// Test pin control unit
//==============================================================
`timescale 100 ns/ 100 ns

module test_pin_control;

// ----------------- CONTROL ----------------
logic fFetch_sig=0;
logic fMRead_sig=0;
logic fMWrite_sig=0;
logic fIORead_sig=0;
logic fIOWrite_sig=0;
logic T1_sig=0;
logic T2_sig=0;
logic T3_sig=0;
logic T4_sig=0;

// ----------------- STATES ----------------
wire bus_ab_pin_we_sig;
wire bus_db_pin_oe_sig;
wire bus_db_pin_re_sig;

// ----------------- TEST -------------------
initial begin
    // Initial condition
    #1  assert(bus_ab_pin_we_sig==0 && bus_db_pin_oe_sig==0 && bus_db_pin_re_sig==0);

        // Activate formula for each signal
        fFetch_sig = 1;
        T1_sig = 1;
    #1  assert(bus_ab_pin_we_sig==1 && bus_db_pin_oe_sig==0 && bus_db_pin_re_sig==0);
        T1_sig = 0;
        T3_sig = 1;
    #1  assert(bus_ab_pin_we_sig==1 && bus_db_pin_oe_sig==0 && bus_db_pin_re_sig==0);
        fFetch_sig = 0;
        T1_sig = 0;
        T3_sig = 0;
    #1  assert(bus_ab_pin_we_sig==0 && bus_db_pin_oe_sig==0 && bus_db_pin_re_sig==0);
        // Read phase
        fMRead_sig = 1;
    #1  assert(bus_ab_pin_we_sig==0 && bus_db_pin_oe_sig==0 && bus_db_pin_re_sig==0);
        T1_sig = 1;
    #1  assert(bus_ab_pin_we_sig==1 && bus_db_pin_oe_sig==0 && bus_db_pin_re_sig==0);
        // Write phase
        fMRead_sig = 0;
        fMWrite_sig = 1;
        fIORead_sig = 0;
        fIOWrite_sig = 0;
    #1  assert(bus_ab_pin_we_sig==1 && bus_db_pin_oe_sig==0 && bus_db_pin_re_sig==0);
        // IO Read phase
        fMRead_sig = 0;
        fMWrite_sig = 0;
        fIORead_sig = 1;
        fIOWrite_sig = 0;
    #1  assert(bus_ab_pin_we_sig==1 && bus_db_pin_oe_sig==0 && bus_db_pin_re_sig==0);
        // IO Write phase
        fMRead_sig = 0;
        fMWrite_sig = 0;
        fIORead_sig = 0;
        fIOWrite_sig = 1;
    #1  assert(bus_ab_pin_we_sig==1 && bus_db_pin_oe_sig==0 && bus_db_pin_re_sig==0);
        fIOWrite_sig = 0;
    #1  assert(bus_ab_pin_we_sig==0 && bus_db_pin_oe_sig==0 && bus_db_pin_re_sig==0);

        // Test bus pin control
        T2_sig = 1;
        fMWrite_sig = 1;
    #1  assert(bus_ab_pin_we_sig==1 && bus_db_pin_oe_sig==1 && bus_db_pin_re_sig==0);
        fMWrite_sig = 0;
        fIORead_sig = 1;
    #1  assert(bus_ab_pin_we_sig==1 && bus_db_pin_oe_sig==0 && bus_db_pin_re_sig==0);
        T3_sig = 1;
    #1  assert(bus_ab_pin_we_sig==1 && bus_db_pin_oe_sig==0 && bus_db_pin_re_sig==1);

    #1  $display("End of test");
end

//--------------------------------------------------------------
// Instantiate pin control
//--------------------------------------------------------------

pin_control pin_control_inst
(
    .fFetch(fFetch_sig) ,               // input  fFetch_sig
    .fMRead(fMRead_sig) ,               // input  fMRead_sig
    .fMWrite(fMWrite_sig) ,             // input  fMWrite_sig
    .fIORead(fIORead_sig) ,             // input  fIORead_sig
    .fIOWrite(fIOWrite_sig) ,           // input  fIOWrite_sig
    .T1(T1_sig) ,                       // input  T1_sig
    .T2(T2_sig) ,                       // input  T2_sig
    .T3(T3_sig) ,                       // input  T3_sig
    .T4(T4_sig) ,                       // input  T4_sig
    .bus_ab_pin_we(bus_ab_pin_we_sig) , // output  bus_ab_pin_we_sig
    .bus_db_pin_oe(bus_db_pin_oe_sig) , // output  bus_db_pin_oe_sig
    .bus_db_pin_re(bus_db_pin_re_sig)   // output  bus_db_pin_re_sig
);

endmodule
