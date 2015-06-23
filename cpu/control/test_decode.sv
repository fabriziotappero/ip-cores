//==============================================================
// Test PLA decode and combinatorial static execute
//==============================================================
`timescale 100 ns/ 100 ns

module test_decode;

reg [7:0] ir_sig;
reg [4:0] prefix_sig;
wire [107:0] pla_sig;

// ----------------- TEST -------------------
initial begin
    integer opcode;

    // Test every opcode in the first table

    //================================================
    // Regular instructions with no prefix
    //================================================
    $display("START IXY0:XX");
    opcode = 0;
    while(opcode<256) begin
        #1 $display("OPCODE: 0x%2H", opcode);
           prefix_sig[4:0] = 5'b10100;
           ir_sig[7:0] = opcode;
        #1 // Reset the IR into NOP so we get the trigger signal again
           prefix_sig[4:0] = 5'b01100;
           ir_sig[7:0] = 0;
           opcode++;
    end
    #1 $display("END");

    //================================================
    // Regular instructions with IX/IY prefix
    //================================================
    $display("START IXY1:XX");
    opcode = 0;
    while(opcode<256) begin
        #1 $display("OPCODE: 0x%2H", opcode);
           prefix_sig[4:0] = 5'b01100;
           ir_sig[7:0] = opcode;
        #1 // Reset the IR into NOP so we get the trigger signal again
           prefix_sig[4:0] = 5'b01100;
           ir_sig[7:0] = 0;
           opcode++;
    end
    #1 $display("END");

    //================================================
    // CD instructions with no prefix
    //================================================
    $display("START IXY0:CB");
    opcode = 0;
    while(opcode<256) begin
        #1 $display("OPCODE: 0x%2H", opcode);
           prefix_sig[4:0] = 5'b10010;
           ir_sig[7:0] = opcode;
        #1 // Reset the IR into NOP so we get the trigger signal again
           prefix_sig[4:0] = 5'b01100;
           ir_sig[7:0] = 0;
           opcode++;
    end
    #1 $display("END");

    //================================================
    // CB instructions with IX/IY prefix
    //================================================
    $display("START IXY1:CB");
    opcode = 0;
    while(opcode<256) begin
        #1 $display("OPCODE: 0x%2H", opcode);
           prefix_sig[4:0] = 5'b01010;
           ir_sig[7:0] = opcode;
        #1 // Reset the IR into NOP so we get the trigger signal again
           prefix_sig[4:0] = 5'b01100;
           ir_sig[7:0] = 0;
           opcode++;
    end
    #1 $display("END");

    //================================================
    // ED instructions with no prefix
    //================================================
    $display("START IXY0:ED");
    opcode = 0;
    while(opcode<256) begin
        #1 $display("OPCODE: 0x%2H", opcode);
           prefix_sig[4:0] = 5'b10001;
           ir_sig[7:0] = opcode;
        #1 // Reset the IR into NOP so we get the trigger signal again
           prefix_sig[4:0] = 5'b01100;
           ir_sig[7:0] = 0;
           opcode++;
    end
    #1 $display("END");

    //================================================
    // ED instructions with IX/IY prefix
    //================================================
    $display("START IXY1:ED");
    opcode = 0;
    while(opcode<256) begin
        #1 $display("OPCODE: 0x%2H", opcode);
           prefix_sig[4:0] = 5'b01001;
           ir_sig[7:0] = opcode;
        #1 // Reset the IR into NOP so we get the trigger signal again
           prefix_sig[4:0] = 5'b01001;
           ir_sig[7:0] = 0;
           opcode++;
    end
    #1 $display("END");

end

//--------------------------------------------------------------
// Instantiate decode blocks
//--------------------------------------------------------------

pla_decode pla_decode_inst
(
    .prefix(prefix_sig) ,       // input [6:0] prefix_sig
    .opcode(ir_sig) ,           // input [7:0] opcode
    .pla(pla_sig)               // output [104:0] pla_sig
);

execute execute_inst
(
    .pla(pla_sig) ,             // input [107:0] pla_sig
    .M1(M1_sig) ,               // input  M1_sig
    .M2(M2_sig) ,               // input  M2_sig
    .M3(M3_sig) ,               // input  M3_sig
    .M4(M4_sig) ,               // input  M4_sig
    .M5(M5_sig) ,               // input  M5_sig
    .M6(M6_sig) ,               // input  M6_sig
    .T1(T1_sig) ,               // input  T1_sig
    .T2(T2_sig) ,               // input  T2_sig
    .T3(T3_sig) ,               // input  T3_sig
    .T4(T4_sig) ,               // input  T4_sig
    .T5(T5_sig) ,               // input  T5_sig
    .T6(T6_sig) ,               // input  T6_sig
    .nextM(nextM_sig) ,         // output  nextM_sig
    .setM1(setM1_sig) ,         // output  setM1_sig
    .setM1ss(setM1ss_sig) ,     // output  setM1ss_sig
    .setM1cc(setM1cc_sig) ,     // output  setM1cc_sig
    .setM1bz(setM1bz_sig) ,     // output  setM1bz_sig
    .fFetch(fFetch_sig) ,       // output  fFetch_sig
    .fMRead(fMRead_sig) ,       // output  fMRead_sig
    .fMWrite(fMWrite_sig) ,     // output  fMWrite_sig
    .fIORead(fIORead_sig) ,     // output  fIORead_sig
    .fIOWrite(fIOWrite_sig) ,   // output  fIOWrite_sig
    .FIntr(FIntr_sig) ,         // output  FIntr_sig
    .ctl_bus_sw1(ctl_bus_sw1_sig) ,         // output  ctl_bus_sw1_sig
    .ctl_bus_sw2(ctl_bus_sw2_sig) ,         // output  ctl_bus_sw2_sig
    .ctl_bus_sw4(ctl_bus_sw4_sig) ,         // output  ctl_bus_sw4_sig
    .ctl_al_we(ctl_al_we_sig) ,             // output  ctl_al_we_sig
    .ctl_inc_dec(ctl_inc_dec_sig) ,         // output  ctl_inc_dec_sig
    .ctl_inc_limit6(ctl_inc_limit6_sig) ,   // output  ctl_inc_limit6_sig
    .ctl_inc_cy(ctl_inc_cy_sig) ,           // output  ctl_inc_cy_sig
    .ctl_ab_mux_inc(ctl_ab_mux_inc_sig) ,   // output  ctl_ab_mux_inc_sig
    .explode(explode_sig)                   // output  explode_sig
);

endmodule
