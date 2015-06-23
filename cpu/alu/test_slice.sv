//==============================================================
// Test ALU slice
//==============================================================
`timescale 100 ns/ 100 ns

module test_slice;

// ----------------- INPUT -----------------
reg [3:0] op1_sig;          // Operand 1
reg [3:0] op2_sig;          // Operand 2
reg cy_in_sig;              // Carry in (to slice D)
reg R_sig;                  // Operation control "R"
reg S_sig;                  // Operation control "S"
reg V_sig;                  // Operation control "V"

// ----------------- OUTPUT -----------------
wire cy_out_sig;            // Carry out (from slice A)
wire [3:0] result_sig;      // Result bits

// ----------------- CONNECTIONS -----------------
wire cy_out_D_sig;          // Carry out from slice D into slice C
wire cy_out_C_sig;          // Carry out from slice C into slice B
wire cy_out_B_sig;          // Carry out from slice B into slice A

// ----------------- TEST -------------------
`define CHECK(arg) \
   assert(result_sig==arg);

initial begin
    op1_sig = '0;
    op2_sig = '0;
    cy_in_sig = 0;
    R_sig = 0;
    S_sig = 0;
    V_sig = 0;

    //------------------------------------------------------------
    // Test ADD/ADC:    R=0  S=0  V=0    Cin for ADC operation
    R_sig = 0;
    S_sig = 0;
    V_sig = 0;
        op1_sig = 4'h0;     // 0 + 0 + 0 = 0
        op2_sig = 4'h0;
        cy_in_sig = 0;
    #1 `CHECK(0);
        cy_in_sig = 1;      // 0 + 0 + 1 = 1
    #1 `CHECK(1);
        op1_sig = 4'h2;     // 2 + 8 + 0 = A
        op2_sig = 4'h8;
        cy_in_sig = 0;
    #1 `CHECK(4'hA);
        cy_in_sig = 1;      // 2 + 8 + 1 = B
    #1 `CHECK(4'hB);
        op1_sig = 4'hB;     // B + 4 + 0 = F
        op2_sig = 4'h4;
        cy_in_sig = 0;
    #1 `CHECK(4'hF);
        cy_in_sig = 1;      // B + 4 + 1 = 0 + CY
    #1 `CHECK(4'h0);
        op1_sig = 4'hD;     // D + 6 + 0 = 3 + CY
        op2_sig = 4'h6;
        cy_in_sig = 0;
    #1 `CHECK(4'h3);
        cy_in_sig = 1;      // D + 6 + 1 = 4 + CY
    #1 `CHECK(4'h4);

    //------------------------------------------------------------
    // Test XOR:        R=1  S=0  V=0  Cin=0
    #1
    R_sig = 1;
    S_sig = 0;
    V_sig = 0;
    cy_in_sig = 0;
        op1_sig = 4'h0;     // 0 ^ 0 = 0
        op2_sig = 4'h0;
    #1 `CHECK(4'h0);
        op1_sig = 4'h3;     // 3 ^ C = F
        op2_sig = 4'hC;
    #1 `CHECK(4'hF);
        op1_sig = 4'h6;     // 6 ^ 3 = 5
        op2_sig = 4'h3;
    #1 `CHECK(4'h5);
        op1_sig = 4'hF;     // F ^ F = 0
        op2_sig = 4'hF;
    #1 `CHECK(4'h0);

    //------------------------------------------------------------
    // Test AND:        R=0  S=1  V=0  Cin=1
    #1
    R_sig = 0;
    S_sig = 1;
    V_sig = 0;
    cy_in_sig = 1;
        op1_sig = 4'h0;     // 0 & 0 = 0
        op2_sig = 4'h0;
    #1 `CHECK(4'h0);
        op1_sig = 4'h3;     // 3 & C = 0
        op2_sig = 4'hC;
    #1 `CHECK(4'h0);
        op1_sig = 4'h6;     // 6 & 3 = 2
        op2_sig = 4'h3;
    #1 `CHECK(4'h2);
        op1_sig = 4'hF;     // F & F = F
        op2_sig = 4'hF;
    #1 `CHECK(4'hF);

    //------------------------------------------------------------
    // Test OR:         R=1  S=1  V=1  Cin=0
    #1
    R_sig = 1;
    S_sig = 1;
    V_sig = 1;
    cy_in_sig = 0;
        op1_sig = 4'h0;     // 0 | 0 = 0
        op2_sig = 4'h0;
    #1 `CHECK(4'h0);
        op1_sig = 4'h3;     // 3 | C = F
        op2_sig = 4'hC;
    #1 `CHECK(4'hF);
        op1_sig = 4'h6;     // 6 | 3 = 7
        op2_sig = 4'h3;
    #1 `CHECK(4'h7);
        op1_sig = 4'hF;     // F | F = F
        op2_sig = 4'hF;
    #1 `CHECK(4'hF);

    #1 $display("End of test");
end

//--------------------------------------------------------------
// Instantiate 4 ALU slice units, daisy-chained; MSB is slice A
//
//            slice_A slice_B slice_C slice_D
//  cy_out <=   [3]     [2]     [1]     [0]  <= cy_in
//--------------------------------------------------------------
alu_slice slice_A
(
    .op1(op1_sig[3]) ,          // input  op1_sig
    .op2(op2_sig[3]) ,          // input  op2_sig
    .cy_in(cy_out_B_sig) ,      // input  cy_in_sig
    .R(R_sig) ,                 // input  R_sig
    .S(S_sig) ,                 // input  S_sig
    .V(V_sig) ,                 // input  V_sig
    .cy_out(cy_out_sig) ,       // output  cy_out_sig
    .result(result_sig[3])      // output  result_sig
);

alu_slice slice_B
(
    .op1(op1_sig[2]) ,          // input  op1_sig
    .op2(op2_sig[2]) ,          // input  op2_sig
    .cy_in(cy_out_C_sig) ,      // input  cy_in_sig
    .R(R_sig) ,                 // input  R_sig
    .S(S_sig) ,                 // input  S_sig
    .V(V_sig) ,                 // input  V_sig
    .cy_out(cy_out_B_sig) ,     // output  cy_out_sig
    .result(result_sig[2])      // output  result_sig
);

alu_slice slice_C
(
    .op1(op1_sig[1]) ,          // input  op1_sig
    .op2(op2_sig[1]) ,          // input  op2_sig
    .cy_in(cy_out_D_sig) ,      // input  cy_in_sig
    .R(R_sig) ,                 // input  R_sig
    .S(S_sig) ,                 // input  S_sig
    .V(V_sig) ,                 // input  V_sig
    .cy_out(cy_out_C_sig) ,     // output  cy_out_sig
    .result(result_sig[1])      // output  result_sig
);

alu_slice slice_D
(
    .op1(op1_sig[0]) ,          // input  op1_sig
    .op2(op2_sig[0]) ,          // input  op2_sig
    .cy_in(cy_in_sig) ,         // input  cy_in_sig
    .R(R_sig) ,                 // input  R_sig
    .S(S_sig) ,                 // input  S_sig
    .V(V_sig) ,                 // input  V_sig
    .cy_out(cy_out_D_sig) ,     // output  cy_out_sig
    .result(result_sig[0])      // output  result_sig
);

endmodule
