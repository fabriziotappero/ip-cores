
module ff_reset ( phi2, reset_glitch, reset_clean );
input  phi2, reset_glitch;
output reset_clean;
    wire n15;
    IN8 U9 ( .A(n15), .Q(reset_clean) );
    DF8 reset_clean_reg ( .C(phi2), .D(reset_glitch), .QN(n15) );
endmodule


module input_phi2_register_0 ( reset, phi2, \input , \output  );
output [15:0] \output ;
input  [15:0] \input ;
input  reset, phi2;
    wire n75;
    DFA2 output_reg_15 ( .C(phi2), .D(\input [15]), .Q(\output [15]), .RN(n75)
         );
    DFA2 output_reg_14 ( .C(phi2), .D(\input [14]), .Q(\output [14]), .RN(n75)
         );
    DFA2 output_reg_13 ( .C(phi2), .D(\input [13]), .Q(\output [13]), .RN(n75)
         );
    DFA2 output_reg_12 ( .C(phi2), .D(\input [12]), .Q(\output [12]), .RN(n75)
         );
    DFA2 output_reg_11 ( .C(phi2), .D(\input [11]), .Q(\output [11]), .RN(n75)
         );
    DFA2 output_reg_10 ( .C(phi2), .D(\input [10]), .Q(\output [10]), .RN(n75)
         );
    DFA2 output_reg_9 ( .C(phi2), .D(\input [9]), .Q(\output [9]), .RN(n75) );
    DFA2 output_reg_8 ( .C(phi2), .D(\input [8]), .Q(\output [8]), .RN(n75) );
    DFA2 output_reg_7 ( .C(phi2), .D(\input [7]), .Q(\output [7]), .RN(n75) );
    DFA2 output_reg_6 ( .C(phi2), .D(\input [6]), .Q(\output [6]), .RN(n75) );
    DFA2 output_reg_5 ( .C(phi2), .D(\input [5]), .Q(\output [5]), .RN(n75) );
    DFA2 output_reg_4 ( .C(phi2), .D(\input [4]), .Q(\output [4]), .RN(n75) );
    DFA2 output_reg_3 ( .C(phi2), .D(\input [3]), .Q(\output [3]), .RN(n75) );
    DFA2 output_reg_2 ( .C(phi2), .D(\input [2]), .Q(\output [2]), .RN(n75) );
    DFA2 output_reg_1 ( .C(phi2), .D(\input [1]), .Q(\output [1]), .RN(n75) );
    DFA2 output_reg_0 ( .C(phi2), .D(\input [0]), .Q(\output [0]), .RN(n75) );
    BU4 U48 ( .A(reset), .Q(n75) );
endmodule


module input_phi2_register_1 ( reset, phi2, \input , \output  );
output [15:0] \output ;
input  [15:0] \input ;
input  reset, phi2;
    wire n82;
    DFA output_reg_15 ( .C(phi2), .D(\input [15]), .Q(\output [15]), .RN(n82)
         );
    DFA output_reg_14 ( .C(phi2), .D(\input [14]), .Q(\output [14]), .RN(n82)
         );
    DFA2 output_reg_13 ( .C(phi2), .D(\input [13]), .Q(\output [13]), .RN(
        reset) );
    DFA2 output_reg_12 ( .C(phi2), .D(\input [12]), .Q(\output [12]), .RN(
        reset) );
    DFA2 output_reg_11 ( .C(phi2), .D(\input [11]), .Q(\output [11]), .RN(
        reset) );
    DFA2 output_reg_10 ( .C(phi2), .D(\input [10]), .Q(\output [10]), .RN(
        reset) );
    DFA2 output_reg_9 ( .C(phi2), .D(\input [9]), .Q(\output [9]), .RN(reset)
         );
    DFA2 output_reg_8 ( .C(phi2), .D(\input [8]), .Q(\output [8]), .RN(reset)
         );
    DFA2 output_reg_7 ( .C(phi2), .D(\input [7]), .Q(\output [7]), .RN(reset)
         );
    DFA output_reg_6 ( .C(phi2), .D(\input [6]), .Q(\output [6]), .RN(n82) );
    DFA2 output_reg_5 ( .C(phi2), .D(\input [5]), .Q(\output [5]), .RN(reset)
         );
    DFA2 output_reg_4 ( .C(phi2), .D(\input [4]), .Q(\output [4]), .RN(reset)
         );
    DFA2 output_reg_3 ( .C(phi2), .D(\input [3]), .Q(\output [3]), .RN(reset)
         );
    DFA output_reg_2 ( .C(phi2), .D(\input [2]), .Q(\output [2]), .RN(n82) );
    DFA2 output_reg_1 ( .C(phi2), .D(\input [1]), .Q(\output [1]), .RN(reset)
         );
    DFA2 output_reg_0 ( .C(phi2), .D(\input [0]), .Q(\output [0]), .RN(reset)
         );
    BU2 U48 ( .A(reset), .Q(n82) );
endmodule


module input_phi2_register_2 ( reset, phi2, \input , \output  );
output [15:0] \output ;
input  [15:0] \input ;
input  reset, phi2;
    DFA2 output_reg_15 ( .C(phi2), .D(\input [15]), .Q(\output [15]), .RN(
        reset) );
    DFA2 output_reg_14 ( .C(phi2), .D(\input [14]), .Q(\output [14]), .RN(
        reset) );
    DFA2 output_reg_13 ( .C(phi2), .D(\input [13]), .Q(\output [13]), .RN(
        reset) );
    DFA2 output_reg_12 ( .C(phi2), .D(\input [12]), .Q(\output [12]), .RN(
        reset) );
    DFA2 output_reg_11 ( .C(phi2), .D(\input [11]), .Q(\output [11]), .RN(
        reset) );
    DFA2 output_reg_10 ( .C(phi2), .D(\input [10]), .Q(\output [10]), .RN(
        reset) );
    DFA2 output_reg_9 ( .C(phi2), .D(\input [9]), .Q(\output [9]), .RN(reset)
         );
    DFA2 output_reg_8 ( .C(phi2), .D(\input [8]), .Q(\output [8]), .RN(reset)
         );
    DFA2 output_reg_7 ( .C(phi2), .D(\input [7]), .Q(\output [7]), .RN(reset)
         );
    DFA2 output_reg_6 ( .C(phi2), .D(\input [6]), .Q(\output [6]), .RN(reset)
         );
    DFA2 output_reg_5 ( .C(phi2), .D(\input [5]), .Q(\output [5]), .RN(reset)
         );
    DFA output_reg_4 ( .C(phi2), .D(\input [4]), .Q(\output [4]), .RN(reset)
         );
    DFA output_reg_3 ( .C(phi2), .D(\input [3]), .Q(\output [3]), .RN(reset)
         );
    DFA output_reg_2 ( .C(phi2), .D(\input [2]), .Q(\output [2]), .RN(reset)
         );
    DFA output_reg_1 ( .C(phi2), .D(\input [1]), .Q(\output [1]), .RN(reset)
         );
    DFA output_reg_0 ( .C(phi2), .D(\input [0]), .Q(\output [0]), .RN(reset)
         );
endmodule


module input_phi2_register_3 ( reset, phi2, \input , \output  );
output [15:0] \output ;
input  [15:0] \input ;
input  reset, phi2;
    wire n97, n99;
    IN3 U48 ( .A(n97), .Q(n99) );
    DFA output_reg_15 ( .C(phi2), .D(\input [15]), .Q(\output [15]), .RN(n99)
         );
    DFA output_reg_14 ( .C(phi2), .D(\input [14]), .Q(\output [14]), .RN(n99)
         );
    DFA output_reg_13 ( .C(phi2), .D(\input [13]), .Q(\output [13]), .RN(n99)
         );
    DFA output_reg_12 ( .C(phi2), .D(\input [12]), .Q(\output [12]), .RN(n99)
         );
    DFA output_reg_11 ( .C(phi2), .D(\input [11]), .Q(\output [11]), .RN(n99)
         );
    DFA output_reg_10 ( .C(phi2), .D(\input [10]), .Q(\output [10]), .RN(n99)
         );
    DFA output_reg_9 ( .C(phi2), .D(\input [9]), .Q(\output [9]), .RN(n99) );
    DFA output_reg_8 ( .C(phi2), .D(\input [8]), .Q(\output [8]), .RN(n99) );
    DFA output_reg_7 ( .C(phi2), .D(\input [7]), .Q(\output [7]), .RN(n99) );
    DFA output_reg_6 ( .C(phi2), .D(\input [6]), .Q(\output [6]), .RN(n99) );
    DFA output_reg_5 ( .C(phi2), .D(\input [5]), .Q(\output [5]), .RN(n99) );
    DFA output_reg_4 ( .C(phi2), .D(\input [4]), .Q(\output [4]), .RN(n99) );
    DFA output_reg_3 ( .C(phi2), .D(\input [3]), .Q(\output [3]), .RN(n99) );
    DFA output_reg_2 ( .C(phi2), .D(\input [2]), .Q(\output [2]), .RN(n99) );
    DFA output_reg_1 ( .C(phi2), .D(\input [1]), .Q(\output [1]), .RN(n99) );
    DFA output_reg_0 ( .C(phi2), .D(\input [0]), .Q(\output [0]), .RN(n99) );
    IN1 U49 ( .A(reset), .Q(n97) );
endmodule


module input_phi1_register_0 ( reset, phi1, \input , \output  );
output [15:0] \output ;
input  [15:0] \input ;
input  reset, phi1;
    wire n76, n80;
    DFA2 output_reg_15 ( .C(phi1), .D(\input [15]), .Q(\output [15]), .RN(n80)
         );
    DFA2 output_reg_14 ( .C(phi1), .D(\input [14]), .Q(\output [14]), .RN(n80)
         );
    DFA2 output_reg_13 ( .C(phi1), .D(\input [13]), .Q(\output [13]), .RN(n80)
         );
    DFA2 output_reg_12 ( .C(phi1), .D(\input [12]), .Q(\output [12]), .RN(n80)
         );
    DFA2 output_reg_11 ( .C(phi1), .D(\input [11]), .Q(\output [11]), .RN(n80)
         );
    DFA2 output_reg_10 ( .C(phi1), .D(\input [10]), .Q(\output [10]), .RN(n80)
         );
    DFA2 output_reg_9 ( .C(phi1), .D(\input [9]), .Q(\output [9]), .RN(n80) );
    DFA2 output_reg_8 ( .C(phi1), .D(\input [8]), .Q(\output [8]), .RN(n80) );
    DFA2 output_reg_7 ( .C(phi1), .D(\input [7]), .Q(\output [7]), .RN(n80) );
    DFA2 output_reg_6 ( .C(phi1), .D(\input [6]), .Q(\output [6]), .RN(n80) );
    DFA2 output_reg_5 ( .C(phi1), .D(\input [5]), .Q(\output [5]), .RN(n80) );
    DFA2 output_reg_4 ( .C(phi1), .D(\input [4]), .Q(\output [4]), .RN(n80) );
    DFA2 output_reg_3 ( .C(phi1), .D(\input [3]), .Q(\output [3]), .RN(n80) );
    DFA2 output_reg_2 ( .C(phi1), .D(\input [2]), .Q(\output [2]), .RN(n80) );
    DFA2 output_reg_1 ( .C(phi1), .D(\input [1]), .Q(\output [1]), .RN(n80) );
    DFA2 output_reg_0 ( .C(phi1), .D(\input [0]), .Q(\output [0]), .RN(n80) );
    IN1 U48 ( .A(reset), .Q(n76) );
    IN3 U49 ( .A(n76), .Q(n80) );
endmodule


module input_phi1_register_1 ( reset, phi1, \input , \output  );
output [15:0] \output ;
input  [15:0] \input ;
input  reset, phi1;
    DFA2 output_reg_15 ( .C(phi1), .D(\input [15]), .Q(\output [15]), .RN(
        reset) );
    DFA2 output_reg_14 ( .C(phi1), .D(\input [14]), .Q(\output [14]), .RN(
        reset) );
    DFA2 output_reg_13 ( .C(phi1), .D(\input [13]), .Q(\output [13]), .RN(
        reset) );
    DFA2 output_reg_12 ( .C(phi1), .D(\input [12]), .Q(\output [12]), .RN(
        reset) );
    DFA2 output_reg_11 ( .C(phi1), .D(\input [11]), .Q(\output [11]), .RN(
        reset) );
    DFA2 output_reg_10 ( .C(phi1), .D(\input [10]), .Q(\output [10]), .RN(
        reset) );
    DFA2 output_reg_9 ( .C(phi1), .D(\input [9]), .Q(\output [9]), .RN(reset)
         );
    DFA2 output_reg_8 ( .C(phi1), .D(\input [8]), .Q(\output [8]), .RN(reset)
         );
    DFA2 output_reg_7 ( .C(phi1), .D(\input [7]), .Q(\output [7]), .RN(reset)
         );
    DFA2 output_reg_6 ( .C(phi1), .D(\input [6]), .Q(\output [6]), .RN(reset)
         );
    DFA2 output_reg_5 ( .C(phi1), .D(\input [5]), .Q(\output [5]), .RN(reset)
         );
    DFA2 output_reg_4 ( .C(phi1), .D(\input [4]), .Q(\output [4]), .RN(reset)
         );
    DFA2 output_reg_3 ( .C(phi1), .D(\input [3]), .Q(\output [3]), .RN(reset)
         );
    DFA2 output_reg_2 ( .C(phi1), .D(\input [2]), .Q(\output [2]), .RN(reset)
         );
    DFA2 output_reg_1 ( .C(phi1), .D(\input [1]), .Q(\output [1]), .RN(reset)
         );
    DFA2 output_reg_0 ( .C(phi1), .D(\input [0]), .Q(\output [0]), .RN(reset)
         );
endmodule


module input_phi1_register_2 ( reset, phi1, \input , \output  );
output [15:0] \output ;
input  [15:0] \input ;
input  reset, phi1;
    wire n84, n86;
    DFA2 output_reg_15 ( .C(phi1), .D(\input [15]), .Q(\output [15]), .RN(n86)
         );
    DFA2 output_reg_14 ( .C(phi1), .D(\input [14]), .Q(\output [14]), .RN(n86)
         );
    DFA2 output_reg_13 ( .C(phi1), .D(\input [13]), .Q(\output [13]), .RN(n86)
         );
    DFA2 output_reg_12 ( .C(phi1), .D(\input [12]), .Q(\output [12]), .RN(n86)
         );
    DFA2 output_reg_11 ( .C(phi1), .D(\input [11]), .Q(\output [11]), .RN(n86)
         );
    DFA2 output_reg_10 ( .C(phi1), .D(\input [10]), .Q(\output [10]), .RN(n86)
         );
    DFA2 output_reg_9 ( .C(phi1), .D(\input [9]), .Q(\output [9]), .RN(n86) );
    DFA2 output_reg_8 ( .C(phi1), .D(\input [8]), .Q(\output [8]), .RN(n86) );
    DFA2 output_reg_7 ( .C(phi1), .D(\input [7]), .Q(\output [7]), .RN(n86) );
    DFA2 output_reg_6 ( .C(phi1), .D(\input [6]), .Q(\output [6]), .RN(n86) );
    DFA2 output_reg_5 ( .C(phi1), .D(\input [5]), .Q(\output [5]), .RN(n86) );
    DFA2 output_reg_4 ( .C(phi1), .D(\input [4]), .Q(\output [4]), .RN(n86) );
    DFA2 output_reg_3 ( .C(phi1), .D(\input [3]), .Q(\output [3]), .RN(n86) );
    DFA2 output_reg_2 ( .C(phi1), .D(\input [2]), .Q(\output [2]), .RN(n86) );
    DFA2 output_reg_1 ( .C(phi1), .D(\input [1]), .Q(\output [1]), .RN(n86) );
    DFA2 output_reg_0 ( .C(phi1), .D(\input [0]), .Q(\output [0]), .RN(n86) );
    IN1 U48 ( .A(reset), .Q(n84) );
    IN3 U49 ( .A(n84), .Q(n86) );
endmodule


module input_phi1_register_3 ( reset, phi1, \input , \output  );
output [15:0] \output ;
input  [15:0] \input ;
input  reset, phi1;
    wire n88, n90, n92, n98, n100, n102, n104, n106, n111, n115, n119, n123, 
        n127, n131, n135, n139, n157, n159;
    IN3 U48 ( .A(n92), .Q(\output [6]) );
    IN3 U49 ( .A(n98), .Q(\output [10]) );
    IN3 U50 ( .A(n100), .Q(\output [0]) );
    IN3 U51 ( .A(n102), .Q(\output [14]) );
    IN3 U52 ( .A(n104), .Q(\output [13]) );
    IN3 U53 ( .A(n106), .Q(\output [3]) );
    IN1 U54 ( .A(reset), .Q(n88) );
    IN3 U55 ( .A(n88), .Q(n90) );
    DFA2 output_reg_6 ( .C(phi1), .D(\input [6]), .QN(n92), .RN(n90) );
    DFA2 output_reg_10 ( .C(phi1), .D(\input [10]), .QN(n98), .RN(n90) );
    DFA2 output_reg_0 ( .C(phi1), .D(\input [0]), .QN(n100), .RN(n90) );
    DFA2 output_reg_14 ( .C(phi1), .D(\input [14]), .QN(n102), .RN(n90) );
    DFA2 output_reg_13 ( .C(phi1), .D(\input [13]), .QN(n104), .RN(n90) );
    DFA2 output_reg_3 ( .C(phi1), .D(\input [3]), .QN(n106), .RN(n90) );
    IN4 U56 ( .A(n111), .Q(\output [15]) );
    DFA2 output_reg_15 ( .C(phi1), .D(\input [15]), .QN(n111), .RN(n90) );
    IN4 U57 ( .A(n115), .Q(\output [12]) );
    DFA2 output_reg_12 ( .C(phi1), .D(\input [12]), .QN(n115), .RN(n90) );
    IN4 U58 ( .A(n119), .Q(\output [4]) );
    DFA2 output_reg_4 ( .C(phi1), .D(\input [4]), .QN(n119), .RN(n90) );
    IN4 U59 ( .A(n123), .Q(\output [5]) );
    DFA2 output_reg_5 ( .C(phi1), .D(\input [5]), .QN(n123), .RN(n90) );
    IN4 U60 ( .A(n127), .Q(\output [2]) );
    DFA2 output_reg_2 ( .C(phi1), .D(\input [2]), .QN(n127), .RN(n90) );
    IN4 U61 ( .A(n131), .Q(\output [9]) );
    DFA2 output_reg_9 ( .C(phi1), .D(\input [9]), .QN(n131), .RN(n90) );
    IN4 U62 ( .A(n135), .Q(\output [11]) );
    DFA2 output_reg_11 ( .C(phi1), .D(\input [11]), .QN(n135), .RN(n90) );
    IN4 U63 ( .A(n139), .Q(\output [7]) );
    DFA2 output_reg_7 ( .C(phi1), .D(\input [7]), .QN(n139), .RN(n90) );
    IN4 U64 ( .A(n157), .Q(\output [1]) );
    DFA2 output_reg_1 ( .C(phi1), .D(\input [1]), .QN(n157), .RN(n90) );
    IN4 U65 ( .A(n159), .Q(\output [8]) );
    DFA2 output_reg_8 ( .C(phi1), .D(\input [8]), .QN(n159), .RN(n90) );
endmodule


module input_wait ( phi1, phi2, reset, \input , \output  );
output [15:0] \output ;
input  [15:0] \input ;
input  phi1, phi2, reset;
    wire btw1and2_12, btw1and2_7, btw6and7_11, btw3and4_9, btw4and5_1, 
        btw5and6_14, btw5and6_4, btw6and7_9, btw7and8_2, btw2and3_10, 
        btw2and3_3, btw7and8_12, btw3and4_7, btw3and4_0, btw4and5_14, 
        btw4and5_8, btw6and7_0, btw6and7_7, btw3and4_11, btw4and5_13, 
        btw1and2_15, btw1and2_9, btw2and3_4, btw7and8_15, btw5and6_3, 
        btw7and8_5, btw1and2_14, btw1and2_0, btw4and5_6, btw5and6_13, 
        btw1and2_13, btw1and2_8, btw7and8_4, btw1and2_6, btw1and2_1, 
        btw2and3_11, btw2and3_5, btw7and8_14, btw3and4_10, btw3and4_6, 
        btw4and5_12, btw6and7_6, btw4and5_7, btw5and6_12, btw3and4_8, 
        btw5and6_2, btw5and6_5, btw6and7_8, btw4and5_0, btw5and6_15, 
        btw3and4_1, btw6and7_10, btw4and5_15, btw6and7_1, btw4and5_9, 
        btw2and3_2, btw7and8_13, btw7and8_3, btw1and2_11, btw1and2_4, 
        btw2and3_9, btw6and7_12, btw7and8_8, btw4and5_2, btw5and6_7, 
        btw1and2_10, btw1and2_5, btw1and2_3, btw2and3_14, btw2and3_0, 
        btw7and8_11, btw7and8_1, btw3and4_15, btw2and3_13, btw3and4_4, 
        btw3and4_3, btw6and7_3, btw5and6_9, btw6and7_4, btw2and3_7, 
        btw3and4_12, btw4and5_10, btw4and5_5, btw5and6_10, btw5and6_0, 
        btw7and8_6, btw1and2_2, btw2and3_12, btw2and3_6, btw6and7_15, 
        btw7and8_7, btw3and4_13, btw3and4_5, btw4and5_11, btw5and6_8, 
        btw6and7_5, btw6and7_14, btw4and5_4, btw5and6_11, btw5and6_6, 
        btw5and6_1, btw2and3_8, btw4and5_3, btw2and3_15, btw3and4_14, 
        btw3and4_2, btw6and7_13, btw6and7_2, btw7and8_9, btw2and3_1, 
        btw7and8_10, btw7and8_0;
    input_phi2_register_3 Input1 ( .reset(reset), .phi2(phi2), .\input (
        \input ), .\output ({btw1and2_15, btw1and2_14, btw1and2_13, 
        btw1and2_12, btw1and2_11, btw1and2_10, btw1and2_9, btw1and2_8, 
        btw1and2_7, btw1and2_6, btw1and2_5, btw1and2_4, btw1and2_3, btw1and2_2, 
        btw1and2_1, btw1and2_0}) );
    input_phi1_register_3 Input8 ( .reset(reset), .phi1(phi1), .\input ({
        btw7and8_15, btw7and8_14, btw7and8_13, btw7and8_12, btw7and8_11, 
        btw7and8_10, btw7and8_9, btw7and8_8, btw7and8_7, btw7and8_6, 
        btw7and8_5, btw7and8_4, btw7and8_3, btw7and8_2, btw7and8_1, btw7and8_0
        }), .\output (\output ) );
    input_phi1_register_2 Input2 ( .reset(reset), .phi1(phi1), .\input ({
        btw1and2_15, btw1and2_14, btw1and2_13, btw1and2_12, btw1and2_11, 
        btw1and2_10, btw1and2_9, btw1and2_8, btw1and2_7, btw1and2_6, 
        btw1and2_5, btw1and2_4, btw1and2_3, btw1and2_2, btw1and2_1, btw1and2_0
        }), .\output ({btw2and3_15, btw2and3_14, btw2and3_13, btw2and3_12, 
        btw2and3_11, btw2and3_10, btw2and3_9, btw2and3_8, btw2and3_7, 
        btw2and3_6, btw2and3_5, btw2and3_4, btw2and3_3, btw2and3_2, btw2and3_1, 
        btw2and3_0}) );
    input_phi1_register_1 Input6 ( .reset(reset), .phi1(phi1), .\input ({
        btw5and6_15, btw5and6_14, btw5and6_13, btw5and6_12, btw5and6_11, 
        btw5and6_10, btw5and6_9, btw5and6_8, btw5and6_7, btw5and6_6, 
        btw5and6_5, btw5and6_4, btw5and6_3, btw5and6_2, btw5and6_1, btw5and6_0
        }), .\output ({btw6and7_15, btw6and7_14, btw6and7_13, btw6and7_12, 
        btw6and7_11, btw6and7_10, btw6and7_9, btw6and7_8, btw6and7_7, 
        btw6and7_6, btw6and7_5, btw6and7_4, btw6and7_3, btw6and7_2, btw6and7_1, 
        btw6and7_0}) );
    input_phi2_register_2 Input7 ( .reset(reset), .phi2(phi2), .\input ({
        btw6and7_15, btw6and7_14, btw6and7_13, btw6and7_12, btw6and7_11, 
        btw6and7_10, btw6and7_9, btw6and7_8, btw6and7_7, btw6and7_6, 
        btw6and7_5, btw6and7_4, btw6and7_3, btw6and7_2, btw6and7_1, btw6and7_0
        }), .\output ({btw7and8_15, btw7and8_14, btw7and8_13, btw7and8_12, 
        btw7and8_11, btw7and8_10, btw7and8_9, btw7and8_8, btw7and8_7, 
        btw7and8_6, btw7and8_5, btw7and8_4, btw7and8_3, btw7and8_2, btw7and8_1, 
        btw7and8_0}) );
    input_phi2_register_1 Input3 ( .reset(reset), .phi2(phi2), .\input ({
        btw2and3_15, btw2and3_14, btw2and3_13, btw2and3_12, btw2and3_11, 
        btw2and3_10, btw2and3_9, btw2and3_8, btw2and3_7, btw2and3_6, 
        btw2and3_5, btw2and3_4, btw2and3_3, btw2and3_2, btw2and3_1, btw2and3_0
        }), .\output ({btw3and4_15, btw3and4_14, btw3and4_13, btw3and4_12, 
        btw3and4_11, btw3and4_10, btw3and4_9, btw3and4_8, btw3and4_7, 
        btw3and4_6, btw3and4_5, btw3and4_4, btw3and4_3, btw3and4_2, btw3and4_1, 
        btw3and4_0}) );
    input_phi1_register_0 Input4 ( .reset(reset), .phi1(phi1), .\input ({
        btw3and4_15, btw3and4_14, btw3and4_13, btw3and4_12, btw3and4_11, 
        btw3and4_10, btw3and4_9, btw3and4_8, btw3and4_7, btw3and4_6, 
        btw3and4_5, btw3and4_4, btw3and4_3, btw3and4_2, btw3and4_1, btw3and4_0
        }), .\output ({btw4and5_15, btw4and5_14, btw4and5_13, btw4and5_12, 
        btw4and5_11, btw4and5_10, btw4and5_9, btw4and5_8, btw4and5_7, 
        btw4and5_6, btw4and5_5, btw4and5_4, btw4and5_3, btw4and5_2, btw4and5_1, 
        btw4and5_0}) );
    input_phi2_register_0 Input5 ( .reset(reset), .phi2(phi2), .\input ({
        btw4and5_15, btw4and5_14, btw4and5_13, btw4and5_12, btw4and5_11, 
        btw4and5_10, btw4and5_9, btw4and5_8, btw4and5_7, btw4and5_6, 
        btw4and5_5, btw4and5_4, btw4and5_3, btw4and5_2, btw4and5_1, btw4and5_0
        }), .\output ({btw5and6_15, btw5and6_14, btw5and6_13, btw5and6_12, 
        btw5and6_11, btw5and6_10, btw5and6_9, btw5and6_8, btw5and6_7, 
        btw5and6_6, btw5and6_5, btw5and6_4, btw5and6_3, btw5and6_2, btw5and6_1, 
        btw5and6_0}) );
endmodule


module gf_xor_input ( input_fcs, output_wip );
input  [31:0] input_fcs;
output [31:0] output_wip;
    wire net8524, output_wip_18, output_wip_3, net8460, output_wip_15, net6785, 
        output_wip_25, output_wip_12, output_wip_21, output_wip_16;
    assign output_wip[31] = output_wip_25;
    assign output_wip[30] = net6785;
    assign output_wip[25] = output_wip_25;
    assign output_wip[24] = net6785;
    assign output_wip[23] = output_wip_12;
    assign output_wip[21] = output_wip_21;
    assign output_wip[19] = output_wip_25;
    assign output_wip[18] = output_wip_18;
    assign output_wip[17] = net8460;
    assign output_wip[16] = output_wip_16;
    assign output_wip[15] = output_wip_15;
    assign output_wip[14] = output_wip_3;
    assign output_wip[13] = net8460;
    assign output_wip[12] = output_wip_12;
    assign output_wip[11] = output_wip_18;
    assign output_wip[10] = net8524;
    assign output_wip[9] = output_wip_16;
    assign output_wip[5] = output_wip_21;
    assign output_wip[4] = output_wip_15;
    assign output_wip[3] = output_wip_3;
    assign output_wip[2] = net8524;
    assign output_wip[1] = output_wip_16;
    EO1 U7 ( .A(input_fcs[30]), .B(input_fcs[29]), .Q(net8524) );
    EO1 U8 ( .A(input_fcs[30]), .B(input_fcs[29]), .Q(net8460) );
    EO1 U9 ( .A(input_fcs[30]), .B(input_fcs[26]), .Q(net6785) );
    EO1 U10 ( .A(input_fcs[24]), .B(input_fcs[28]), .Q(output_wip[28]) );
    EO1 U11 ( .A(input_fcs[26]), .B(input_fcs[22]), .Q(output_wip[26]) );
    EO1 U12 ( .A(input_fcs[26]), .B(input_fcs[28]), .Q(output_wip[0]) );
    EO1 U13 ( .A(input_fcs[30]), .B(input_fcs[31]), .Q(output_wip_18) );
    EO1 U14 ( .A(input_fcs[30]), .B(input_fcs[31]), .Q(output_wip_3) );
    EO1 U15 ( .A(input_fcs[27]), .B(input_fcs[23]), .Q(output_wip[27]) );
    EO1 U16 ( .A(input_fcs[28]), .B(input_fcs[25]), .Q(output_wip[20]) );
    EO1 U17 ( .A(input_fcs[28]), .B(input_fcs[27]), .Q(output_wip[8]) );
    EO1 U18 ( .A(input_fcs[30]), .B(input_fcs[28]), .Q(output_wip[22]) );
    EO1 U19 ( .A(input_fcs[30]), .B(input_fcs[27]), .Q(output_wip[6]) );
    EO1 U20 ( .A(input_fcs[29]), .B(input_fcs[25]), .Q(output_wip[29]) );
    EO1 U21 ( .A(input_fcs[29]), .B(input_fcs[28]), .Q(output_wip_16) );
    EO1 U22 ( .A(input_fcs[29]), .B(input_fcs[26]), .Q(output_wip_21) );
    EO1 U23 ( .A(input_fcs[31]), .B(input_fcs[26]), .Q(output_wip[7]) );
    EO1 U24 ( .A(input_fcs[29]), .B(input_fcs[31]), .Q(output_wip_12) );
    EO1 U25 ( .A(input_fcs[31]), .B(input_fcs[27]), .Q(output_wip_25) );
    EO1 U26 ( .A(input_fcs[28]), .B(input_fcs[31]), .Q(output_wip_15) );
endmodule


module gf_xor_2x ( input_wip, input_fcs, output_wip );
input  [31:0] input_wip;
input  [31:0] input_fcs;
output [31:0] output_wip;
    EO1 U7 ( .A(input_wip[15]), .B(input_fcs[25]), .Q(output_wip[15]) );
    EO1 U8 ( .A(input_wip[17]), .B(input_fcs[25]), .Q(output_wip[17]) );
    EO1 U9 ( .A(input_wip[10]), .B(input_fcs[25]), .Q(output_wip[10]) );
    EO1 U10 ( .A(input_wip[2]), .B(input_fcs[25]), .Q(output_wip[2]) );
    EO1 U11 ( .A(input_wip[21]), .B(input_fcs[25]), .Q(output_wip[21]) );
    EO1 U12 ( .A(input_wip[7]), .B(input_fcs[24]), .Q(output_wip[7]) );
    EO1 U13 ( .A(input_wip[30]), .B(input_fcs[24]), .Q(output_wip[30]) );
    EO1 U14 ( .A(input_wip[22]), .B(input_fcs[27]), .Q(output_wip[22]) );
    EO1 U15 ( .A(input_wip[19]), .B(input_fcs[24]), .Q(output_wip[19]) );
    EO1 U16 ( .A(input_wip[18]), .B(input_fcs[26]), .Q(output_wip[18]) );
    EO1 U17 ( .A(input_wip[14]), .B(input_fcs[27]), .Q(output_wip[14]) );
    EO1 U18 ( .A(input_wip[13]), .B(input_fcs[26]), .Q(output_wip[13]) );
    EO1 U19 ( .A(input_wip[8]), .B(input_fcs[26]), .Q(output_wip[8]) );
    EO1 U20 ( .A(input_wip[6]), .B(input_fcs[24]), .Q(output_wip[6]) );
    EO1 U21 ( .A(input_wip[1]), .B(input_fcs[27]), .Q(output_wip[1]) );
    EO1 U22 ( .A(input_wip[31]), .B(input_fcs[25]), .Q(output_wip[31]) );
    EO1 U23 ( .A(input_wip[0]), .B(input_fcs[25]), .Q(output_wip[0]) );
    EO1 U24 ( .A(input_wip[25]), .B(input_fcs[24]), .Q(output_wip[25]) );
    EO1 U25 ( .A(input_wip[20]), .B(input_fcs[24]), .Q(output_wip[20]) );
    EO1 U26 ( .A(input_wip[23]), .B(input_fcs[25]), .Q(output_wip[23]) );
    EO1 U27 ( .A(input_wip[28]), .B(input_fcs[22]), .Q(output_wip[28]) );
    EO1 U28 ( .A(input_wip[27]), .B(input_fcs[21]), .Q(output_wip[27]) );
    EO1 U29 ( .A(input_wip[26]), .B(input_fcs[20]), .Q(output_wip[26]) );
    EO1 U30 ( .A(input_wip[11]), .B(input_fcs[28]), .Q(output_wip[11]) );
    EO1 U31 ( .A(input_wip[24]), .B(input_fcs[23]), .Q(output_wip[24]) );
    EO1 U32 ( .A(input_wip[29]), .B(input_fcs[23]), .Q(output_wip[29]) );
    EO1 U33 ( .A(input_wip[5]), .B(input_fcs[23]), .Q(output_wip[5]) );
    EO1 U34 ( .A(input_wip[3]), .B(input_fcs[26]), .Q(output_wip[3]) );
    EO1 U35 ( .A(input_wip[16]), .B(input_fcs[24]), .Q(output_wip[16]) );
    EO1 U36 ( .A(input_wip[4]), .B(input_fcs[27]), .Q(output_wip[4]) );
    EO1 U37 ( .A(input_wip[9]), .B(input_fcs[27]), .Q(output_wip[9]) );
    EO1 U38 ( .A(input_wip[12]), .B(input_fcs[28]), .Q(output_wip[12]) );
endmodule


module gf_xor_3x ( input_wip, input_fcs, output_wip );
input  [31:0] input_wip;
input  [31:0] input_fcs;
output [31:0] output_wip;
    EO1 U7 ( .A(input_wip[6]), .B(input_fcs[23]), .Q(output_wip[6]) );
    EO1 U8 ( .A(input_wip[19]), .B(input_fcs[23]), .Q(output_wip[19]) );
    EO1 U9 ( .A(input_wip[18]), .B(input_fcs[23]), .Q(output_wip[18]) );
    EO1 U10 ( .A(input_wip[13]), .B(input_fcs[23]), .Q(output_wip[13]) );
    EO1 U11 ( .A(input_wip[7]), .B(input_fcs[23]), .Q(output_wip[7]) );
    EO1 U12 ( .A(input_wip[8]), .B(input_fcs[24]), .Q(output_wip[8]) );
    EO1 U13 ( .A(input_wip[4]), .B(input_fcs[24]), .Q(output_wip[4]) );
    EO1 U14 ( .A(input_wip[15]), .B(input_fcs[24]), .Q(output_wip[15]) );
    EO1 U15 ( .A(input_wip[14]), .B(input_fcs[24]), .Q(output_wip[14]) );
    EO1 U16 ( .A(input_wip[2]), .B(input_fcs[24]), .Q(output_wip[2]) );
    EO1 U17 ( .A(input_wip[9]), .B(input_fcs[25]), .Q(output_wip[9]) );
    EO1 U18 ( .A(input_wip[3]), .B(input_fcs[25]), .Q(output_wip[3]) );
    EO1 U19 ( .A(input_wip[12]), .B(input_fcs[25]), .Q(output_wip[12]) );
    EO1 U20 ( .A(input_wip[11]), .B(input_fcs[25]), .Q(output_wip[11]) );
    EO1 U21 ( .A(input_wip[1]), .B(input_fcs[25]), .Q(output_wip[1]) );
    EO1 U22 ( .A(input_wip[24]), .B(input_fcs[18]), .Q(output_wip[24]) );
    EO1 U23 ( .A(input_wip[20]), .B(input_fcs[20]), .Q(output_wip[20]) );
    EO1 U24 ( .A(input_fcs[20]), .B(input_wip[27]), .Q(output_wip[27]) );
    EO1 U25 ( .A(input_wip[25]), .B(input_fcs[19]), .Q(output_wip[25]) );
    EO1 U26 ( .A(input_fcs[19]), .B(input_wip[26]), .Q(output_wip[26]) );
    EO1 U27 ( .A(input_wip[10]), .B(input_fcs[21]), .Q(output_wip[10]) );
    EO1 U28 ( .A(input_wip[16]), .B(input_fcs[21]), .Q(output_wip[16]) );
    EO1 U29 ( .A(input_wip[21]), .B(input_fcs[21]), .Q(output_wip[21]) );
    EO1 U30 ( .A(input_fcs[21]), .B(input_wip[28]), .Q(output_wip[28]) );
    EO1 U31 ( .A(input_wip[0]), .B(input_fcs[22]), .Q(output_wip[0]) );
    EO1 U32 ( .A(input_wip[17]), .B(input_fcs[22]), .Q(output_wip[17]) );
    EO1 U33 ( .A(input_wip[23]), .B(input_fcs[22]), .Q(output_wip[23]) );
    EO1 U34 ( .A(input_fcs[22]), .B(input_wip[29]), .Q(output_wip[29]) );
    EO1 U35 ( .A(input_wip[5]), .B(input_fcs[22]), .Q(output_wip[5]) );
    EO1 U36 ( .A(input_fcs[23]), .B(input_wip[30]), .Q(output_wip[30]) );
    EO1 U37 ( .A(input_fcs[24]), .B(input_wip[31]), .Q(output_wip[31]) );
    EO1 U38 ( .A(input_fcs[25]), .B(input_wip[22]), .Q(output_wip[22]) );
endmodule


module gf_xor_4x ( input_wip, input_fcs, output_wip );
input  [31:0] input_wip;
input  [31:0] input_fcs;
output [31:0] output_wip;
    EO1 U7 ( .A(input_wip[5]), .B(input_fcs[21]), .Q(output_wip[5]) );
    EO1 U8 ( .A(input_wip[31]), .B(input_fcs[21]), .Q(output_wip[31]) );
    EO1 U9 ( .A(input_wip[30]), .B(input_fcs[20]), .Q(output_wip[30]) );
    EO1 U10 ( .A(input_wip[24]), .B(input_fcs[17]), .Q(output_wip[24]) );
    EO1 U11 ( .A(input_wip[19]), .B(input_fcs[19]), .Q(output_wip[19]) );
    EO1 U12 ( .A(input_wip[17]), .B(input_fcs[21]), .Q(output_wip[17]) );
    EO1 U13 ( .A(input_wip[15]), .B(input_fcs[23]), .Q(output_wip[15]) );
    EO1 U14 ( .A(input_wip[13]), .B(input_fcs[22]), .Q(output_wip[13]) );
    EO1 U15 ( .A(input_wip[12]), .B(input_fcs[22]), .Q(output_wip[12]) );
    EO1 U16 ( .A(input_wip[6]), .B(input_fcs[22]), .Q(output_wip[6]) );
    EO1 U17 ( .A(input_wip[23]), .B(input_fcs[17]), .Q(output_wip[23]) );
    EO1 U18 ( .A(input_wip[18]), .B(input_fcs[22]), .Q(output_wip[18]) );
    EO1 U19 ( .A(input_wip[16]), .B(input_fcs[20]), .Q(output_wip[16]) );
    EO1 U20 ( .A(input_wip[11]), .B(input_fcs[20]), .Q(output_wip[11]) );
    EO1 U21 ( .A(input_wip[10]), .B(input_fcs[19]), .Q(output_wip[10]) );
    EO1 U22 ( .A(input_wip[9]), .B(input_fcs[21]), .Q(output_wip[9]) );
    EO1 U23 ( .A(input_wip[7]), .B(input_fcs[21]), .Q(output_wip[7]) );
    EO1 U24 ( .A(input_wip[4]), .B(input_fcs[22]), .Q(output_wip[4]) );
    EO1 U25 ( .A(input_wip[2]), .B(input_fcs[23]), .Q(output_wip[2]) );
    EO1 U26 ( .A(input_wip[1]), .B(input_fcs[23]), .Q(output_wip[1]) );
    EO1 U27 ( .A(input_wip[3]), .B(input_fcs[24]), .Q(output_wip[3]) );
    EO1 U28 ( .A(input_wip[21]), .B(input_fcs[5]), .Q(output_wip[21]) );
    EO1 U29 ( .A(input_wip[20]), .B(input_fcs[4]), .Q(output_wip[20]) );
    EO1 U30 ( .A(input_wip[25]), .B(input_fcs[18]), .Q(output_wip[25]) );
    EO1 U31 ( .A(input_wip[28]), .B(input_fcs[18]), .Q(output_wip[28]) );
    EO1 U32 ( .A(input_wip[29]), .B(input_fcs[19]), .Q(output_wip[29]) );
    EO1 U33 ( .A(input_wip[27]), .B(input_fcs[17]), .Q(output_wip[27]) );
    EO1 U34 ( .A(input_wip[0]), .B(input_fcs[16]), .Q(output_wip[0]) );
    EO1 U35 ( .A(input_wip[22]), .B(input_fcs[16]), .Q(output_wip[22]) );
    EO1 U36 ( .A(input_wip[26]), .B(input_fcs[16]), .Q(output_wip[26]) );
    EO1 U37 ( .A(input_wip[8]), .B(input_fcs[20]), .Q(output_wip[8]) );
    EO1 U38 ( .A(input_wip[14]), .B(input_fcs[23]), .Q(output_wip[14]) );
endmodule


module gf_xor_5x ( input_wip, input_fcs, output_wip );
input  [31:0] input_wip;
input  [31:0] input_fcs;
output [31:0] output_wip;
    wire input_wip_21, input_wip_20, input_wip_0;
    assign input_wip_21 = input_wip[21];
    assign input_wip_20 = input_wip[20];
    assign input_wip_0 = input_wip[0];
    assign output_wip[21] = input_wip_21;
    assign output_wip[20] = input_wip_20;
    assign output_wip[0] = input_wip_0;
    EO1 U7 ( .A(input_wip[3]), .B(input_fcs[23]), .Q(output_wip[3]) );
    EO1 U8 ( .A(input_wip[31]), .B(input_fcs[15]), .Q(output_wip[31]) );
    EO1 U9 ( .A(input_wip[30]), .B(input_fcs[14]), .Q(output_wip[30]) );
    EO1 U10 ( .A(input_wip[29]), .B(input_fcs[13]), .Q(output_wip[29]) );
    EO1 U11 ( .A(input_wip[28]), .B(input_fcs[12]), .Q(output_wip[28]) );
    EO1 U12 ( .A(input_wip[27]), .B(input_fcs[11]), .Q(output_wip[27]) );
    EO1 U13 ( .A(input_wip[26]), .B(input_fcs[10]), .Q(output_wip[26]) );
    EO1 U14 ( .A(input_wip[25]), .B(input_fcs[9]), .Q(output_wip[25]) );
    EO1 U15 ( .A(input_wip[24]), .B(input_fcs[8]), .Q(output_wip[24]) );
    EO1 U16 ( .A(input_wip[22]), .B(input_fcs[6]), .Q(output_wip[22]) );
    EO1 U17 ( .A(input_wip[19]), .B(input_fcs[3]), .Q(output_wip[19]) );
    EO1 U18 ( .A(input_wip[17]), .B(input_fcs[17]), .Q(output_wip[17]) );
    EO1 U19 ( .A(input_wip[16]), .B(input_fcs[16]), .Q(output_wip[16]) );
    EO1 U20 ( .A(input_fcs[16]), .B(input_wip[23]), .Q(output_wip[23]) );
    EO1 U21 ( .A(input_wip[10]), .B(input_fcs[18]), .Q(output_wip[10]) );
    EO1 U22 ( .A(input_fcs[18]), .B(input_wip[18]), .Q(output_wip[18]) );
    EO1 U23 ( .A(input_wip[1]), .B(input_fcs[22]), .Q(output_wip[1]) );
    EO1 U24 ( .A(input_fcs[22]), .B(input_wip[14]), .Q(output_wip[14]) );
    EO1 U25 ( .A(input_wip[2]), .B(input_fcs[22]), .Q(output_wip[2]) );
    EO1 U26 ( .A(input_fcs[19]), .B(input_wip[11]), .Q(output_wip[11]) );
    EO1 U27 ( .A(input_wip[7]), .B(input_fcs[19]), .Q(output_wip[7]) );
    EO1 U28 ( .A(input_wip[8]), .B(input_fcs[19]), .Q(output_wip[8]) );
    EO1 U29 ( .A(input_wip[4]), .B(input_fcs[20]), .Q(output_wip[4]) );
    EO1 U30 ( .A(input_wip[5]), .B(input_fcs[20]), .Q(output_wip[5]) );
    EO1 U31 ( .A(input_fcs[20]), .B(input_wip[9]), .Q(output_wip[9]) );
    EO1 U32 ( .A(input_wip[12]), .B(input_fcs[21]), .Q(output_wip[12]) );
    EO1 U33 ( .A(input_wip[13]), .B(input_fcs[21]), .Q(output_wip[13]) );
    EO1 U34 ( .A(input_fcs[21]), .B(input_wip[15]), .Q(output_wip[15]) );
    EO1 U35 ( .A(input_wip[6]), .B(input_fcs[21]), .Q(output_wip[6]) );
endmodule


module gf_xor_6x ( input_wip, input_fcs, output_wip );
input  [31:0] input_wip;
input  [31:0] input_fcs;
output [31:0] output_wip;
    wire input_wip_22, input_wip_30, input_wip_25, input_wip_19, input_wip_24, 
        input_wip_31, input_wip_21, input_wip_28, input_wip_26, input_wip_27, 
        input_wip_20, input_wip_0, input_wip_29;
    assign input_wip_31 = input_wip[31];
    assign input_wip_30 = input_wip[30];
    assign input_wip_29 = input_wip[29];
    assign input_wip_28 = input_wip[28];
    assign input_wip_27 = input_wip[27];
    assign input_wip_26 = input_wip[26];
    assign input_wip_25 = input_wip[25];
    assign input_wip_24 = input_wip[24];
    assign input_wip_22 = input_wip[22];
    assign input_wip_21 = input_wip[21];
    assign input_wip_20 = input_wip[20];
    assign input_wip_19 = input_wip[19];
    assign input_wip_0 = input_wip[0];
    assign output_wip[31] = input_wip_31;
    assign output_wip[30] = input_wip_30;
    assign output_wip[29] = input_wip_29;
    assign output_wip[28] = input_wip_28;
    assign output_wip[27] = input_wip_27;
    assign output_wip[26] = input_wip_26;
    assign output_wip[25] = input_wip_25;
    assign output_wip[24] = input_wip_24;
    assign output_wip[22] = input_wip_22;
    assign output_wip[21] = input_wip_21;
    assign output_wip[20] = input_wip_20;
    assign output_wip[19] = input_wip_19;
    assign output_wip[0] = input_wip_0;
    EO1 U7 ( .A(input_wip[4]), .B(input_fcs[19]), .Q(output_wip[4]) );
    EO1 U8 ( .A(input_wip[3]), .B(input_fcs[19]), .Q(output_wip[3]) );
    EO1 U9 ( .A(input_wip[13]), .B(input_fcs[19]), .Q(output_wip[13]) );
    EO1 U10 ( .A(input_wip[12]), .B(input_fcs[20]), .Q(output_wip[12]) );
    EO1 U11 ( .A(input_wip[8]), .B(input_fcs[17]), .Q(output_wip[8]) );
    EO1 U12 ( .A(input_wip[6]), .B(input_fcs[20]), .Q(output_wip[6]) );
    EO1 U13 ( .A(input_wip[1]), .B(input_fcs[17]), .Q(output_wip[1]) );
    EO1 U14 ( .A(input_wip[15]), .B(input_fcs[20]), .Q(output_wip[15]) );
    EO1 U15 ( .A(input_wip[9]), .B(input_fcs[18]), .Q(output_wip[9]) );
    EO1 U16 ( .A(input_wip[2]), .B(input_fcs[18]), .Q(output_wip[2]) );
    EO1 U17 ( .A(input_wip[23]), .B(input_fcs[7]), .Q(output_wip[23]) );
    EO1 U18 ( .A(input_wip[18]), .B(input_fcs[2]), .Q(output_wip[18]) );
    EO1 U19 ( .A(input_wip[17]), .B(input_fcs[1]), .Q(output_wip[17]) );
    EO1 U20 ( .A(input_wip[16]), .B(input_fcs[0]), .Q(output_wip[16]) );
    EO1 U21 ( .A(input_wip[10]), .B(input_fcs[16]), .Q(output_wip[10]) );
    EO1 U22 ( .A(input_wip[11]), .B(input_fcs[17]), .Q(output_wip[11]) );
    EO1 U23 ( .A(input_wip[7]), .B(input_fcs[18]), .Q(output_wip[7]) );
    EO1 U24 ( .A(input_wip[14]), .B(input_fcs[20]), .Q(output_wip[14]) );
    EO1 U25 ( .A(input_wip[5]), .B(input_fcs[19]), .Q(output_wip[5]) );
endmodule


module gf_xor_7x ( input_wip, input_fcs, output_wip );
input  [31:0] input_wip;
input  [31:0] input_fcs;
output [31:0] output_wip;
    wire input_wip_22, input_wip_30, input_wip_17, input_wip_10, input_wip_25, 
        input_wip_19, input_wip_18, input_wip_24, input_wip_23, input_wip_31, 
        input_wip_16, input_wip_21, input_wip_28, input_wip_26, input_wip_27, 
        input_wip_20, input_wip_0, input_wip_29;
    assign input_wip_31 = input_wip[31];
    assign input_wip_30 = input_wip[30];
    assign input_wip_29 = input_wip[29];
    assign input_wip_28 = input_wip[28];
    assign input_wip_27 = input_wip[27];
    assign input_wip_26 = input_wip[26];
    assign input_wip_25 = input_wip[25];
    assign input_wip_24 = input_wip[24];
    assign input_wip_23 = input_wip[23];
    assign input_wip_22 = input_wip[22];
    assign input_wip_21 = input_wip[21];
    assign input_wip_20 = input_wip[20];
    assign input_wip_19 = input_wip[19];
    assign input_wip_18 = input_wip[18];
    assign input_wip_17 = input_wip[17];
    assign input_wip_16 = input_wip[16];
    assign input_wip_10 = input_wip[10];
    assign input_wip_0 = input_wip[0];
    assign output_wip[31] = input_wip_31;
    assign output_wip[30] = input_wip_30;
    assign output_wip[29] = input_wip_29;
    assign output_wip[28] = input_wip_28;
    assign output_wip[27] = input_wip_27;
    assign output_wip[26] = input_wip_26;
    assign output_wip[25] = input_wip_25;
    assign output_wip[24] = input_wip_24;
    assign output_wip[23] = input_wip_23;
    assign output_wip[22] = input_wip_22;
    assign output_wip[21] = input_wip_21;
    assign output_wip[20] = input_wip_20;
    assign output_wip[19] = input_wip_19;
    assign output_wip[18] = input_wip_18;
    assign output_wip[17] = input_wip_17;
    assign output_wip[16] = input_wip_16;
    assign output_wip[10] = input_wip_10;
    assign output_wip[0] = input_wip_0;
    EO1 U7 ( .A(input_wip[14]), .B(input_fcs[19]), .Q(output_wip[14]) );
    EO1 U8 ( .A(input_fcs[19]), .B(input_wip[15]), .Q(output_wip[15]) );
    EO1 U9 ( .A(input_wip[2]), .B(input_fcs[17]), .Q(output_wip[2]) );
    EO1 U10 ( .A(input_wip[5]), .B(input_fcs[17]), .Q(output_wip[5]) );
    EO1 U11 ( .A(input_fcs[17]), .B(input_wip[9]), .Q(output_wip[9]) );
    EO1 U12 ( .A(input_wip[1]), .B(input_fcs[16]), .Q(output_wip[1]) );
    EO1 U13 ( .A(input_fcs[16]), .B(input_wip[11]), .Q(output_wip[11]) );
    EO1 U14 ( .A(input_wip[7]), .B(input_fcs[16]), .Q(output_wip[7]) );
    EO1 U15 ( .A(input_wip[8]), .B(input_fcs[16]), .Q(output_wip[8]) );
    EO1 U16 ( .A(input_wip[12]), .B(input_fcs[18]), .Q(output_wip[12]) );
    EO1 U17 ( .A(input_fcs[18]), .B(input_wip[13]), .Q(output_wip[13]) );
    EO1 U18 ( .A(input_wip[3]), .B(input_fcs[18]), .Q(output_wip[3]) );
    EO1 U19 ( .A(input_wip[4]), .B(input_fcs[18]), .Q(output_wip[4]) );
    EO1 U20 ( .A(input_wip[6]), .B(input_fcs[18]), .Q(output_wip[6]) );
endmodule


module gf_xor_8x ( input_wip, input_fcs, output_wip );
input  [31:0] input_wip;
input  [31:0] input_fcs;
output [31:0] output_wip;
    wire input_wip_30, input_wip_22, input_wip_17, input_wip_10, input_wip_25, 
        input_wip_19, input_wip_11, input_wip_18, input_wip_24, input_wip_23, 
        input_wip_31, input_wip_16, input_wip_21, input_wip_8, input_wip_28, 
        input_wip_26, input_wip_1, input_wip_9, input_wip_27, input_wip_20, 
        input_wip_0, input_wip_7, input_wip_29, input_wip_15;
    assign input_wip_31 = input_wip[31];
    assign input_wip_30 = input_wip[30];
    assign input_wip_29 = input_wip[29];
    assign input_wip_28 = input_wip[28];
    assign input_wip_27 = input_wip[27];
    assign input_wip_26 = input_wip[26];
    assign input_wip_25 = input_wip[25];
    assign input_wip_24 = input_wip[24];
    assign input_wip_23 = input_wip[23];
    assign input_wip_22 = input_wip[22];
    assign input_wip_21 = input_wip[21];
    assign input_wip_20 = input_wip[20];
    assign input_wip_19 = input_wip[19];
    assign input_wip_18 = input_wip[18];
    assign input_wip_17 = input_wip[17];
    assign input_wip_16 = input_wip[16];
    assign input_wip_15 = input_wip[15];
    assign input_wip_11 = input_wip[11];
    assign input_wip_10 = input_wip[10];
    assign input_wip_9 = input_wip[9];
    assign input_wip_8 = input_wip[8];
    assign input_wip_7 = input_wip[7];
    assign input_wip_1 = input_wip[1];
    assign input_wip_0 = input_wip[0];
    assign output_wip[31] = input_wip_31;
    assign output_wip[30] = input_wip_30;
    assign output_wip[29] = input_wip_29;
    assign output_wip[28] = input_wip_28;
    assign output_wip[27] = input_wip_27;
    assign output_wip[26] = input_wip_26;
    assign output_wip[25] = input_wip_25;
    assign output_wip[24] = input_wip_24;
    assign output_wip[23] = input_wip_23;
    assign output_wip[22] = input_wip_22;
    assign output_wip[21] = input_wip_21;
    assign output_wip[20] = input_wip_20;
    assign output_wip[19] = input_wip_19;
    assign output_wip[18] = input_wip_18;
    assign output_wip[17] = input_wip_17;
    assign output_wip[16] = input_wip_16;
    assign output_wip[15] = input_wip_15;
    assign output_wip[11] = input_wip_11;
    assign output_wip[10] = input_wip_10;
    assign output_wip[9] = input_wip_9;
    assign output_wip[8] = input_wip_8;
    assign output_wip[7] = input_wip_7;
    assign output_wip[1] = input_wip_1;
    assign output_wip[0] = input_wip_0;
    EO1 U7 ( .A(input_wip[13]), .B(input_fcs[17]), .Q(output_wip[13]) );
    EO1 U8 ( .A(input_wip[12]), .B(input_fcs[17]), .Q(output_wip[12]) );
    EO1 U9 ( .A(input_wip[3]), .B(input_fcs[17]), .Q(output_wip[3]) );
    EO1 U10 ( .A(input_wip[4]), .B(input_fcs[16]), .Q(output_wip[4]) );
    EO1 U11 ( .A(input_wip[2]), .B(input_fcs[16]), .Q(output_wip[2]) );
    EO1 U12 ( .A(input_wip[14]), .B(input_fcs[18]), .Q(output_wip[14]) );
    EO1 U13 ( .A(input_wip[6]), .B(input_fcs[17]), .Q(output_wip[6]) );
    EO1 U14 ( .A(input_wip[5]), .B(input_fcs[16]), .Q(output_wip[5]) );
endmodule


module gf_xor_9x ( input_wip, input_fcs, output_wip );
input  [31:0] input_wip;
input  [31:0] input_fcs;
output [31:0] output_wip;
    wire input_wip_30, input_wip_5, input_wip_22, input_wip_17, input_wip_10, 
        input_wip_2, input_wip_25, input_wip_19, input_wip_11, input_wip_18, 
        input_wip_3, input_wip_24, input_wip_4, input_wip_23, input_wip_6, 
        input_wip_31, input_wip_16, input_wip_21, input_wip_8, input_wip_14, 
        input_wip_28, input_wip_13, input_wip_26, input_wip_1, input_wip_9, 
        input_wip_27, input_wip_20, input_wip_0, input_wip_7, input_wip_29, 
        input_wip_15;
    assign input_wip_31 = input_wip[31];
    assign input_wip_30 = input_wip[30];
    assign input_wip_29 = input_wip[29];
    assign input_wip_28 = input_wip[28];
    assign input_wip_27 = input_wip[27];
    assign input_wip_26 = input_wip[26];
    assign input_wip_25 = input_wip[25];
    assign input_wip_24 = input_wip[24];
    assign input_wip_23 = input_wip[23];
    assign input_wip_22 = input_wip[22];
    assign input_wip_21 = input_wip[21];
    assign input_wip_20 = input_wip[20];
    assign input_wip_19 = input_wip[19];
    assign input_wip_18 = input_wip[18];
    assign input_wip_17 = input_wip[17];
    assign input_wip_16 = input_wip[16];
    assign input_wip_15 = input_wip[15];
    assign input_wip_14 = input_wip[14];
    assign input_wip_13 = input_wip[13];
    assign input_wip_11 = input_wip[11];
    assign input_wip_10 = input_wip[10];
    assign input_wip_9 = input_wip[9];
    assign input_wip_8 = input_wip[8];
    assign input_wip_7 = input_wip[7];
    assign input_wip_6 = input_wip[6];
    assign input_wip_5 = input_wip[5];
    assign input_wip_4 = input_wip[4];
    assign input_wip_3 = input_wip[3];
    assign input_wip_2 = input_wip[2];
    assign input_wip_1 = input_wip[1];
    assign input_wip_0 = input_wip[0];
    assign output_wip[31] = input_wip_31;
    assign output_wip[30] = input_wip_30;
    assign output_wip[29] = input_wip_29;
    assign output_wip[28] = input_wip_28;
    assign output_wip[27] = input_wip_27;
    assign output_wip[26] = input_wip_26;
    assign output_wip[25] = input_wip_25;
    assign output_wip[24] = input_wip_24;
    assign output_wip[23] = input_wip_23;
    assign output_wip[22] = input_wip_22;
    assign output_wip[21] = input_wip_21;
    assign output_wip[20] = input_wip_20;
    assign output_wip[19] = input_wip_19;
    assign output_wip[18] = input_wip_18;
    assign output_wip[17] = input_wip_17;
    assign output_wip[16] = input_wip_16;
    assign output_wip[15] = input_wip_15;
    assign output_wip[14] = input_wip_14;
    assign output_wip[13] = input_wip_13;
    assign output_wip[11] = input_wip_11;
    assign output_wip[10] = input_wip_10;
    assign output_wip[9] = input_wip_9;
    assign output_wip[8] = input_wip_8;
    assign output_wip[7] = input_wip_7;
    assign output_wip[6] = input_wip_6;
    assign output_wip[5] = input_wip_5;
    assign output_wip[4] = input_wip_4;
    assign output_wip[3] = input_wip_3;
    assign output_wip[2] = input_wip_2;
    assign output_wip[1] = input_wip_1;
    assign output_wip[0] = input_wip_0;
    EO1 U7 ( .A(input_wip[12]), .B(input_fcs[16]), .Q(output_wip[12]) );
endmodule


module gf_phi1_register_out ( reset, phi1, input_wip, output_final );
input  [31:0] input_wip;
output [31:0] output_final;
input  reset, phi1;
    wire n107, n108, n110, n112, n114, n116, n118, n120, n122, n124, n126, 
        n128, n130, n132, n134, n136, n138;
    DFA2 output_final_reg_29 ( .C(phi1), .D(input_wip[29]), .Q(output_final
        [29]), .RN(n107) );
    DFA2 output_final_reg_27 ( .C(phi1), .D(input_wip[27]), .Q(output_final
        [27]), .RN(n107) );
    DFA2 output_final_reg_25 ( .C(phi1), .D(input_wip[25]), .Q(output_final
        [25]), .RN(n107) );
    DFA2 output_final_reg_24 ( .C(phi1), .D(input_wip[24]), .Q(output_final
        [24]), .RN(n107) );
    DFA2 output_final_reg_23 ( .C(phi1), .D(input_wip[23]), .Q(output_final
        [23]), .RN(n107) );
    DFA2 output_final_reg_22 ( .C(phi1), .D(input_wip[22]), .Q(output_final
        [22]), .RN(n107) );
    DFA2 output_final_reg_21 ( .C(phi1), .D(input_wip[21]), .Q(output_final
        [21]), .RN(n107) );
    DFA2 output_final_reg_20 ( .C(phi1), .D(input_wip[20]), .Q(output_final
        [20]), .RN(n107) );
    DFA2 output_final_reg_19 ( .C(phi1), .D(input_wip[19]), .Q(output_final
        [19]), .RN(n107) );
    DFA2 output_final_reg_18 ( .C(phi1), .D(input_wip[18]), .Q(output_final
        [18]), .RN(n107) );
    DFA2 output_final_reg_17 ( .C(phi1), .D(input_wip[17]), .Q(output_final
        [17]), .RN(n107) );
    DFA2 output_final_reg_16 ( .C(phi1), .D(input_wip[16]), .Q(output_final
        [16]), .RN(n107) );
    BU8 U80 ( .A(reset), .Q(n107) );
    IN2 U81 ( .A(n108), .Q(output_final[6]) );
    IN2 U82 ( .A(n110), .Q(output_final[10]) );
    IN2 U83 ( .A(n112), .Q(output_final[0]) );
    IN2 U84 ( .A(n114), .Q(output_final[14]) );
    IN2 U85 ( .A(n116), .Q(output_final[13]) );
    IN2 U86 ( .A(n118), .Q(output_final[3]) );
    DFA output_final_reg_3 ( .C(phi1), .D(input_wip[3]), .QN(n118), .RN(n107)
         );
    DFA output_final_reg_13 ( .C(phi1), .D(input_wip[13]), .QN(n116), .RN(n107
        ) );
    DFA output_final_reg_14 ( .C(phi1), .D(input_wip[14]), .QN(n114), .RN(n107
        ) );
    DFA output_final_reg_0 ( .C(phi1), .D(input_wip[0]), .QN(n112), .RN(n107)
         );
    DFA output_final_reg_10 ( .C(phi1), .D(input_wip[10]), .QN(n110), .RN(n107
        ) );
    DFA output_final_reg_6 ( .C(phi1), .D(input_wip[6]), .QN(n108), .RN(n107)
         );
    IN3 U87 ( .A(n120), .Q(output_final[15]) );
    DFA2 output_final_reg_15 ( .C(phi1), .D(input_wip[15]), .QN(n120), .RN(
        n107) );
    IN3 U88 ( .A(n122), .Q(output_final[12]) );
    DFA2 output_final_reg_12 ( .C(phi1), .D(input_wip[12]), .QN(n122), .RN(
        n107) );
    IN3 U89 ( .A(n124), .Q(output_final[4]) );
    DFA2 output_final_reg_4 ( .C(phi1), .D(input_wip[4]), .QN(n124), .RN(n107)
         );
    IN3 U90 ( .A(n126), .Q(output_final[5]) );
    DFA2 output_final_reg_5 ( .C(phi1), .D(input_wip[5]), .QN(n126), .RN(n107)
         );
    IN3 U91 ( .A(n128), .Q(output_final[2]) );
    DFA2 output_final_reg_2 ( .C(phi1), .D(input_wip[2]), .QN(n128), .RN(n107)
         );
    IN3 U92 ( .A(n130), .Q(output_final[9]) );
    DFA2 output_final_reg_9 ( .C(phi1), .D(input_wip[9]), .QN(n130), .RN(n107)
         );
    IN3 U93 ( .A(n132), .Q(output_final[11]) );
    DFA2 output_final_reg_11 ( .C(phi1), .D(input_wip[11]), .QN(n132), .RN(
        n107) );
    IN3 U94 ( .A(n134), .Q(output_final[7]) );
    DFA2 output_final_reg_7 ( .C(phi1), .D(input_wip[7]), .QN(n134), .RN(n107)
         );
    IN3 U95 ( .A(n136), .Q(output_final[1]) );
    DFA2 output_final_reg_1 ( .C(phi1), .D(input_wip[1]), .QN(n136), .RN(n107)
         );
    IN3 U96 ( .A(n138), .Q(output_final[8]) );
    DFA2 output_final_reg_8 ( .C(phi1), .D(input_wip[8]), .QN(n138), .RN(n107)
         );
    DFA2 output_final_reg_26 ( .C(phi1), .D(input_wip[26]), .Q(output_final
        [26]), .RN(n107) );
    DFA2 output_final_reg_30 ( .C(phi1), .D(input_wip[30]), .Q(output_final
        [30]), .RN(n107) );
    DFA2 output_final_reg_31 ( .C(phi1), .D(input_wip[31]), .Q(output_final
        [31]), .RN(n107) );
    DFA2 output_final_reg_28 ( .C(phi1), .D(input_wip[28]), .Q(output_final
        [28]), .RN(n107) );
endmodule


module gf_phi1_register_0 ( reset, phi1, input_wip, input_fcs, output_wip, 
    output_fcs );
output [31:0] output_fcs;
input  [31:0] input_fcs;
input  [31:0] input_wip;
output [31:0] output_wip;
input  reset, phi1;
    wire n187, n188, n189, n191, n193, n195, n197, n199, n201, n203, n205, 
        n207, n209, n211, n213, n215, n217, n219, n221, n223, n225, n227, n229, 
        n231, n233, n235, n237, n239, n241, n243, n245, n247, n249, n251, n253, 
        n255, n257, n259, n261, n263, n265, n267, n269, n271, n273;
    DFA output_wip_reg_27 ( .C(phi1), .D(input_wip[27]), .QN(n203), .RN(n188)
         );
    DFA output_wip_reg_24 ( .C(phi1), .D(input_wip[24]), .QN(n209), .RN(n187)
         );
    DFA output_wip_reg_22 ( .C(phi1), .D(input_wip[22]), .QN(n211), .RN(n187)
         );
    DFA output_wip_reg_23 ( .C(phi1), .D(input_wip[23]), .QN(n227), .RN(n188)
         );
    IN1 U147 ( .A(n197), .Q(output_wip[30]) );
    IN1 U148 ( .A(n199), .Q(output_wip[29]) );
    IN1 U149 ( .A(n203), .Q(output_wip[27]) );
    IN1 U150 ( .A(n207), .Q(output_wip[25]) );
    IN1 U151 ( .A(n209), .Q(output_wip[24]) );
    IN1 U152 ( .A(n211), .Q(output_wip[22]) );
    IN1 U153 ( .A(n213), .Q(output_wip[19]) );
    IN1 U154 ( .A(n215), .Q(output_wip[17]) );
    IN1 U155 ( .A(n217), .Q(output_wip[3]) );
    IN1 U156 ( .A(n219), .Q(output_wip[15]) );
    IN1 U157 ( .A(n221), .Q(output_wip[13]) );
    IN1 U158 ( .A(n223), .Q(output_wip[12]) );
    IN1 U159 ( .A(n225), .Q(output_wip[6]) );
    IN1 U160 ( .A(n227), .Q(output_wip[23]) );
    IN1 U161 ( .A(n229), .Q(output_wip[18]) );
    IN1 U162 ( .A(n231), .Q(output_wip[16]) );
    IN1 U163 ( .A(n233), .Q(output_wip[14]) );
    IN1 U164 ( .A(n235), .Q(output_wip[11]) );
    IN1 U165 ( .A(n237), .Q(output_wip[10]) );
    IN1 U166 ( .A(n239), .Q(output_wip[9]) );
    IN1 U167 ( .A(n241), .Q(output_wip[8]) );
    IN1 U168 ( .A(n243), .Q(output_wip[7]) );
    IN1 U169 ( .A(n245), .Q(output_wip[5]) );
    IN1 U170 ( .A(n247), .Q(output_wip[4]) );
    IN1 U171 ( .A(n249), .Q(output_wip[2]) );
    IN1 U172 ( .A(n251), .Q(output_wip[1]) );
    IN1 U173 ( .A(n257), .Q(output_fcs[24]) );
    IN3 U174 ( .A(n263), .Q(output_fcs[17]) );
    IN3 U175 ( .A(n269), .Q(output_fcs[23]) );
    DFA2 output_fcs_reg_31 ( .C(phi1), .D(input_fcs[31]), .Q(output_fcs[31]), 
        .RN(n188) );
    DFA2 output_fcs_reg_30 ( .C(phi1), .D(input_fcs[30]), .Q(output_fcs[30]), 
        .RN(n188) );
    DFA2 output_fcs_reg_29 ( .C(phi1), .D(input_fcs[29]), .Q(output_fcs[29]), 
        .RN(n188) );
    DFA2 output_fcs_reg_28 ( .C(phi1), .D(input_fcs[28]), .Q(output_fcs[28]), 
        .RN(n187) );
    DFA2 output_fcs_reg_26 ( .C(phi1), .D(input_fcs[26]), .Q(output_fcs[26]), 
        .RN(n188) );
    DFA2 output_fcs_reg_15 ( .C(phi1), .D(input_fcs[15]), .Q(output_fcs[15]), 
        .RN(n187) );
    DFA2 output_fcs_reg_14 ( .C(phi1), .D(input_fcs[14]), .Q(output_fcs[14]), 
        .RN(n187) );
    DFA2 output_fcs_reg_13 ( .C(phi1), .D(input_fcs[13]), .Q(output_fcs[13]), 
        .RN(n188) );
    DFA2 output_fcs_reg_12 ( .C(phi1), .D(input_fcs[12]), .Q(output_fcs[12]), 
        .RN(n188) );
    DFA2 output_fcs_reg_11 ( .C(phi1), .D(input_fcs[11]), .Q(output_fcs[11]), 
        .RN(n187) );
    DFA2 output_fcs_reg_10 ( .C(phi1), .D(input_fcs[10]), .Q(output_fcs[10]), 
        .RN(n187) );
    DFA2 output_fcs_reg_9 ( .C(phi1), .D(input_fcs[9]), .Q(output_fcs[9]), 
        .RN(n188) );
    DFA2 output_fcs_reg_8 ( .C(phi1), .D(input_fcs[8]), .Q(output_fcs[8]), 
        .RN(n188) );
    DFA2 output_fcs_reg_7 ( .C(phi1), .D(input_fcs[7]), .Q(output_fcs[7]), 
        .RN(n187) );
    DFA2 output_fcs_reg_6 ( .C(phi1), .D(input_fcs[6]), .Q(output_fcs[6]), 
        .RN(n188) );
    DFA2 output_fcs_reg_3 ( .C(phi1), .D(input_fcs[3]), .Q(output_fcs[3]), 
        .RN(n187) );
    DFA2 output_fcs_reg_2 ( .C(phi1), .D(input_fcs[2]), .Q(output_fcs[2]), 
        .RN(n187) );
    DFA2 output_fcs_reg_1 ( .C(phi1), .D(input_fcs[1]), .Q(output_fcs[1]), 
        .RN(n188) );
    DFA2 output_fcs_reg_0 ( .C(phi1), .D(input_fcs[0]), .Q(output_fcs[0]), 
        .RN(n188) );
    BU4 U176 ( .A(reset), .Q(n187) );
    BU8 U177 ( .A(n187), .Q(n188) );
    IN3 U178 ( .A(n189), .Q(output_wip[0]) );
    DFA2 output_wip_reg_0 ( .C(phi1), .D(input_wip[0]), .QN(n189), .RN(n188)
         );
    IN3 U179 ( .A(n191), .Q(output_wip[21]) );
    DFA2 output_wip_reg_21 ( .C(phi1), .D(input_wip[21]), .QN(n191), .RN(n188)
         );
    IN3 U180 ( .A(n193), .Q(output_wip[20]) );
    DFA2 output_wip_reg_20 ( .C(phi1), .D(input_wip[20]), .QN(n193), .RN(n188)
         );
    IN3 U181 ( .A(n195), .Q(output_wip[31]) );
    DFA2 output_wip_reg_31 ( .C(phi1), .D(input_wip[31]), .QN(n195), .RN(n188)
         );
    DFA2 output_wip_reg_30 ( .C(phi1), .D(input_wip[30]), .QN(n197), .RN(n188)
         );
    DFA2 output_wip_reg_29 ( .C(phi1), .D(input_wip[29]), .QN(n199), .RN(n187)
         );
    IN3 U182 ( .A(n201), .Q(output_wip[28]) );
    DFA2 output_wip_reg_28 ( .C(phi1), .D(input_wip[28]), .QN(n201), .RN(n187)
         );
    IN3 U183 ( .A(n205), .Q(output_wip[26]) );
    DFA2 output_wip_reg_26 ( .C(phi1), .D(input_wip[26]), .QN(n205), .RN(n188)
         );
    DFA2 output_wip_reg_25 ( .C(phi1), .D(input_wip[25]), .QN(n207), .RN(n187)
         );
    DFA2 output_wip_reg_19 ( .C(phi1), .D(input_wip[19]), .QN(n213), .RN(n187)
         );
    DFA2 output_wip_reg_17 ( .C(phi1), .D(input_wip[17]), .QN(n215), .RN(n187)
         );
    DFA2 output_wip_reg_3 ( .C(phi1), .D(input_wip[3]), .QN(n217), .RN(n187)
         );
    DFA2 output_wip_reg_15 ( .C(phi1), .D(input_wip[15]), .QN(n219), .RN(n188)
         );
    DFA2 output_wip_reg_13 ( .C(phi1), .D(input_wip[13]), .QN(n221), .RN(n188)
         );
    DFA2 output_wip_reg_12 ( .C(phi1), .D(input_wip[12]), .QN(n223), .RN(n188)
         );
    DFA2 output_wip_reg_6 ( .C(phi1), .D(input_wip[6]), .QN(n225), .RN(n188)
         );
    DFA2 output_wip_reg_18 ( .C(phi1), .D(input_wip[18]), .QN(n229), .RN(n188)
         );
    DFA2 output_wip_reg_16 ( .C(phi1), .D(input_wip[16]), .QN(n231), .RN(n187)
         );
    DFA2 output_wip_reg_14 ( .C(phi1), .D(input_wip[14]), .QN(n233), .RN(n187)
         );
    DFA2 output_wip_reg_11 ( .C(phi1), .D(input_wip[11]), .QN(n235), .RN(n188)
         );
    DFA2 output_wip_reg_10 ( .C(phi1), .D(input_wip[10]), .QN(n237), .RN(n187)
         );
    DFA2 output_wip_reg_9 ( .C(phi1), .D(input_wip[9]), .QN(n239), .RN(n187)
         );
    DFA2 output_wip_reg_8 ( .C(phi1), .D(input_wip[8]), .QN(n241), .RN(n188)
         );
    DFA2 output_wip_reg_7 ( .C(phi1), .D(input_wip[7]), .QN(n243), .RN(n188)
         );
    DFA2 output_wip_reg_5 ( .C(phi1), .D(input_wip[5]), .QN(n245), .RN(n188)
         );
    DFA2 output_wip_reg_4 ( .C(phi1), .D(input_wip[4]), .QN(n247), .RN(n187)
         );
    DFA2 output_wip_reg_2 ( .C(phi1), .D(input_wip[2]), .QN(n249), .RN(n188)
         );
    DFA2 output_wip_reg_1 ( .C(phi1), .D(input_wip[1]), .QN(n251), .RN(n188)
         );
    IN4 U184 ( .A(n253), .Q(output_fcs[5]) );
    IN4 U185 ( .A(n255), .Q(output_fcs[4]) );
    IN4 U186 ( .A(n259), .Q(output_fcs[18]) );
    IN4 U187 ( .A(n261), .Q(output_fcs[16]) );
    IN4 U188 ( .A(n265), .Q(output_fcs[19]) );
    IN4 U189 ( .A(n267), .Q(output_fcs[20]) );
    IN4 U190 ( .A(n271), .Q(output_fcs[21]) );
    DFA2 output_fcs_reg_21 ( .C(phi1), .D(input_fcs[21]), .QN(n271), .RN(n187)
         );
    IN4 U191 ( .A(n273), .Q(output_fcs[22]) );
    DFA2 output_fcs_reg_22 ( .C(phi1), .D(input_fcs[22]), .QN(n273), .RN(n188)
         );
    DFA2 output_fcs_reg_24 ( .C(phi1), .D(input_fcs[24]), .QN(n257), .RN(n188)
         );
    DFA2 output_fcs_reg_25 ( .C(phi1), .D(input_fcs[25]), .Q(output_fcs[25]), 
        .RN(n188) );
    DFA2 output_fcs_reg_4 ( .C(phi1), .D(input_fcs[4]), .QN(n255), .RN(n187)
         );
    DFA2 output_fcs_reg_5 ( .C(phi1), .D(input_fcs[5]), .QN(n253), .RN(n187)
         );
    DFA2 output_fcs_reg_27 ( .C(phi1), .D(input_fcs[27]), .Q(output_fcs[27]), 
        .RN(n187) );
    DFA2 output_fcs_reg_17 ( .C(phi1), .D(input_fcs[17]), .QN(n263), .RN(n188)
         );
    DFA2 output_fcs_reg_16 ( .C(phi1), .D(input_fcs[16]), .QN(n261), .RN(n188)
         );
    DFA2 output_fcs_reg_23 ( .C(phi1), .D(input_fcs[23]), .QN(n269), .RN(n188)
         );
    DFA2 output_fcs_reg_18 ( .C(phi1), .D(input_fcs[18]), .QN(n259), .RN(n187)
         );
    DFA2 output_fcs_reg_19 ( .C(phi1), .D(input_fcs[19]), .QN(n265), .RN(n187)
         );
    DFA2 output_fcs_reg_20 ( .C(phi1), .D(input_fcs[20]), .QN(n267), .RN(n188)
         );
endmodule


module gf_phi1_register_1 ( reset, phi1, input_wip, input_fcs, output_wip, 
    output_fcs );
output [31:0] output_fcs;
input  [31:0] input_fcs;
input  [31:0] input_wip;
output [31:0] output_wip;
input  reset, phi1;
    wire n214, n232, n236, n244, n252, n270, n274, n315, n317, n319, n321, 
        n323, n325, n327, n329, n331, n333, n335, n337, n339, n341, n343, n345, 
        n347, n349, n351, n353, n355, n357, n359, n361, n363, n365, n367, n369, 
        n371, n373, n375, n377, n379, n381, n383, n385;
    DFA output_wip_reg_24 ( .C(phi1), .D(input_wip[24]), .QN(n236), .RN(n232)
         );
    DFA output_wip_reg_29 ( .C(phi1), .D(input_wip[29]), .QN(n270), .RN(n214)
         );
    DFA output_wip_reg_28 ( .C(phi1), .D(input_wip[28]), .QN(n274), .RN(n232)
         );
    DFA output_wip_reg_12 ( .C(phi1), .D(input_wip[12]), .QN(n335), .RN(n232)
         );
    DFA output_wip_reg_5 ( .C(phi1), .D(input_wip[5]), .QN(n349), .RN(n232) );
    IN1 U147 ( .A(n236), .Q(output_wip[24]) );
    IN1 U148 ( .A(n270), .Q(output_wip[29]) );
    IN1 U149 ( .A(n274), .Q(output_wip[28]) );
    IN1 U150 ( .A(n317), .Q(output_wip[22]) );
    IN1 U151 ( .A(n323), .Q(output_wip[18]) );
    IN1 U152 ( .A(n331), .Q(output_wip[14]) );
    IN1 U153 ( .A(n335), .Q(output_wip[12]) );
    IN1 U154 ( .A(n341), .Q(output_wip[9]) );
    IN1 U155 ( .A(n345), .Q(output_wip[7]) );
    IN1 U156 ( .A(n349), .Q(output_wip[5]) );
    IN1 U157 ( .A(n351), .Q(output_wip[4]) );
    IN1 U158 ( .A(n353), .Q(output_wip[3]) );
    IN1 U159 ( .A(n357), .Q(output_wip[1]) );
    IN1 U160 ( .A(n359), .Q(output_wip[0]) );
    IN1 U161 ( .A(n361), .Q(output_wip[27]) );
    IN1 U162 ( .A(n363), .Q(output_wip[26]) );
    IN1 U163 ( .A(n365), .Q(output_wip[25]) );
    IN1 U164 ( .A(n367), .Q(output_wip[20]) );
    IN1 U165 ( .A(n373), .Q(output_fcs[20]) );
    IN1 U166 ( .A(n371), .Q(output_fcs[21]) );
    DFA2 output_fcs_reg_19 ( .C(phi1), .D(input_fcs[19]), .Q(output_fcs[19]), 
        .RN(n214) );
    DFA2 output_fcs_reg_18 ( .C(phi1), .D(input_fcs[18]), .Q(output_fcs[18]), 
        .RN(n232) );
    DFA2 output_fcs_reg_17 ( .C(phi1), .D(input_fcs[17]), .Q(output_fcs[17]), 
        .RN(n214) );
    DFA2 output_fcs_reg_16 ( .C(phi1), .D(input_fcs[16]), .Q(output_fcs[16]), 
        .RN(n232) );
    DFA2 output_fcs_reg_15 ( .C(phi1), .D(input_fcs[15]), .Q(output_fcs[15]), 
        .RN(n232) );
    DFA2 output_fcs_reg_14 ( .C(phi1), .D(input_fcs[14]), .Q(output_fcs[14]), 
        .RN(n232) );
    DFA2 output_fcs_reg_13 ( .C(phi1), .D(input_fcs[13]), .Q(output_fcs[13]), 
        .RN(n232) );
    DFA2 output_fcs_reg_12 ( .C(phi1), .D(input_fcs[12]), .Q(output_fcs[12]), 
        .RN(n232) );
    DFA2 output_fcs_reg_11 ( .C(phi1), .D(input_fcs[11]), .Q(output_fcs[11]), 
        .RN(n232) );
    DFA2 output_fcs_reg_10 ( .C(phi1), .D(input_fcs[10]), .Q(output_fcs[10]), 
        .RN(n232) );
    DFA2 output_fcs_reg_9 ( .C(phi1), .D(input_fcs[9]), .Q(output_fcs[9]), 
        .RN(n232) );
    DFA2 output_fcs_reg_8 ( .C(phi1), .D(input_fcs[8]), .Q(output_fcs[8]), 
        .RN(n232) );
    DFA2 output_fcs_reg_7 ( .C(phi1), .D(input_fcs[7]), .Q(output_fcs[7]), 
        .RN(n232) );
    DFA2 output_fcs_reg_6 ( .C(phi1), .D(input_fcs[6]), .Q(output_fcs[6]), 
        .RN(n232) );
    DFA2 output_fcs_reg_5 ( .C(phi1), .D(input_fcs[5]), .Q(output_fcs[5]), 
        .RN(n232) );
    DFA2 output_fcs_reg_4 ( .C(phi1), .D(input_fcs[4]), .Q(output_fcs[4]), 
        .RN(n232) );
    DFA2 output_fcs_reg_3 ( .C(phi1), .D(input_fcs[3]), .Q(output_fcs[3]), 
        .RN(n232) );
    DFA2 output_fcs_reg_2 ( .C(phi1), .D(input_fcs[2]), .Q(output_fcs[2]), 
        .RN(n232) );
    DFA2 output_fcs_reg_1 ( .C(phi1), .D(input_fcs[1]), .Q(output_fcs[1]), 
        .RN(n232) );
    DFA2 output_fcs_reg_0 ( .C(phi1), .D(input_fcs[0]), .Q(output_fcs[0]), 
        .RN(n232) );
    BU8 U167 ( .A(n214), .Q(n232) );
    BU4 U168 ( .A(reset), .Q(n214) );
    DFA4 output_fcs_reg_24 ( .C(phi1), .D(input_fcs[24]), .QN(n383), .RN(n232)
         );
    DFA4 output_fcs_reg_25 ( .C(phi1), .D(input_fcs[25]), .QN(n385), .RN(n232)
         );
    IN3 U169 ( .A(n244), .Q(output_wip[31]) );
    DFA2 output_wip_reg_31 ( .C(phi1), .D(input_wip[31]), .QN(n244), .RN(n232)
         );
    IN3 U170 ( .A(n252), .Q(output_wip[30]) );
    DFA2 output_wip_reg_30 ( .C(phi1), .D(input_wip[30]), .QN(n252), .RN(n232)
         );
    IN3 U171 ( .A(n315), .Q(output_wip[23]) );
    DFA2 output_wip_reg_23 ( .C(phi1), .D(input_wip[23]), .QN(n315), .RN(n232)
         );
    DFA2 output_wip_reg_22 ( .C(phi1), .D(input_wip[22]), .QN(n317), .RN(n214)
         );
    IN3 U172 ( .A(n319), .Q(output_wip[21]) );
    DFA2 output_wip_reg_21 ( .C(phi1), .D(input_wip[21]), .QN(n319), .RN(n214)
         );
    IN3 U173 ( .A(n321), .Q(output_wip[19]) );
    DFA2 output_wip_reg_19 ( .C(phi1), .D(input_wip[19]), .QN(n321), .RN(n214)
         );
    DFA2 output_wip_reg_18 ( .C(phi1), .D(input_wip[18]), .QN(n323), .RN(n232)
         );
    IN3 U174 ( .A(n325), .Q(output_wip[17]) );
    DFA2 output_wip_reg_17 ( .C(phi1), .D(input_wip[17]), .QN(n325), .RN(n232)
         );
    IN3 U175 ( .A(n327), .Q(output_wip[16]) );
    DFA2 output_wip_reg_16 ( .C(phi1), .D(input_wip[16]), .QN(n327), .RN(n214)
         );
    IN3 U176 ( .A(n329), .Q(output_wip[15]) );
    DFA2 output_wip_reg_15 ( .C(phi1), .D(input_wip[15]), .QN(n329), .RN(n214)
         );
    DFA2 output_wip_reg_14 ( .C(phi1), .D(input_wip[14]), .QN(n331), .RN(n232)
         );
    IN3 U177 ( .A(n333), .Q(output_wip[13]) );
    DFA2 output_wip_reg_13 ( .C(phi1), .D(input_wip[13]), .QN(n333), .RN(n232)
         );
    IN3 U178 ( .A(n337), .Q(output_wip[11]) );
    DFA2 output_wip_reg_11 ( .C(phi1), .D(input_wip[11]), .QN(n337), .RN(n232)
         );
    IN3 U179 ( .A(n339), .Q(output_wip[10]) );
    DFA2 output_wip_reg_10 ( .C(phi1), .D(input_wip[10]), .QN(n339), .RN(n232)
         );
    DFA2 output_wip_reg_9 ( .C(phi1), .D(input_wip[9]), .QN(n341), .RN(n232)
         );
    IN3 U180 ( .A(n343), .Q(output_wip[8]) );
    DFA2 output_wip_reg_8 ( .C(phi1), .D(input_wip[8]), .QN(n343), .RN(n214)
         );
    DFA2 output_wip_reg_7 ( .C(phi1), .D(input_wip[7]), .QN(n345), .RN(n214)
         );
    IN3 U181 ( .A(n347), .Q(output_wip[6]) );
    DFA2 output_wip_reg_6 ( .C(phi1), .D(input_wip[6]), .QN(n347), .RN(n232)
         );
    DFA2 output_wip_reg_4 ( .C(phi1), .D(input_wip[4]), .QN(n351), .RN(n214)
         );
    DFA2 output_wip_reg_3 ( .C(phi1), .D(input_wip[3]), .QN(n353), .RN(n232)
         );
    IN3 U182 ( .A(n355), .Q(output_wip[2]) );
    DFA2 output_wip_reg_2 ( .C(phi1), .D(input_wip[2]), .QN(n355), .RN(n232)
         );
    DFA2 output_wip_reg_1 ( .C(phi1), .D(input_wip[1]), .QN(n357), .RN(n232)
         );
    DFA2 output_wip_reg_0 ( .C(phi1), .D(input_wip[0]), .QN(n359), .RN(n232)
         );
    DFA2 output_wip_reg_27 ( .C(phi1), .D(input_wip[27]), .QN(n361), .RN(n232)
         );
    DFA2 output_wip_reg_26 ( .C(phi1), .D(input_wip[26]), .QN(n363), .RN(n214)
         );
    DFA2 output_wip_reg_25 ( .C(phi1), .D(input_wip[25]), .QN(n365), .RN(n214)
         );
    DFA2 output_wip_reg_20 ( .C(phi1), .D(input_wip[20]), .QN(n367), .RN(n214)
         );
    IN4 U183 ( .A(n369), .Q(output_fcs[22]) );
    DFA2 output_fcs_reg_20 ( .C(phi1), .D(input_fcs[20]), .QN(n373), .RN(n214)
         );
    IN4 U184 ( .A(n375), .Q(output_fcs[28]) );
    IN4 U185 ( .A(n377), .Q(output_fcs[23]) );
    IN8 U186 ( .A(n385), .Q(output_fcs[25]) );
    IN8 U187 ( .A(n383), .Q(output_fcs[24]) );
    IN4 U188 ( .A(n379), .Q(output_fcs[26]) );
    IN4 U189 ( .A(n381), .Q(output_fcs[27]) );
    DFA2 output_fcs_reg_27 ( .C(phi1), .D(input_fcs[27]), .QN(n381), .RN(n214)
         );
    DFA2 output_fcs_reg_21 ( .C(phi1), .D(input_fcs[21]), .QN(n371), .RN(n214)
         );
    DFA2 output_fcs_reg_30 ( .C(phi1), .D(input_fcs[30]), .Q(output_fcs[30]), 
        .RN(n214) );
    DFA2 output_fcs_reg_23 ( .C(phi1), .D(input_fcs[23]), .QN(n377), .RN(n214)
         );
    DFA2 output_fcs_reg_22 ( .C(phi1), .D(input_fcs[22]), .QN(n369), .RN(n214)
         );
    DFA2 output_fcs_reg_26 ( .C(phi1), .D(input_fcs[26]), .QN(n379), .RN(n214)
         );
    DFA2 output_fcs_reg_29 ( .C(phi1), .D(input_fcs[29]), .Q(output_fcs[29]), 
        .RN(n232) );
    DFA2 output_fcs_reg_28 ( .C(phi1), .D(input_fcs[28]), .QN(n375), .RN(n214)
         );
    DFA2 output_fcs_reg_31 ( .C(phi1), .D(input_fcs[31]), .Q(output_fcs[31]), 
        .RN(n232) );
endmodule


module gf_phi1_register_2 ( reset, phi1, input_wip, input_fcs, output_wip, 
    output_fcs );
output [31:0] output_fcs;
input  [31:0] input_fcs;
input  [31:0] input_wip;
output [31:0] output_wip;
input  reset, phi1;
    wire n318, n322, n326, n330, n342, n346, n350, n354, n358, n362, n366, 
        n370, n374, n378;
    IN1 U147 ( .A(n366), .Q(output_wip[12]) );
    DFA2 output_fcs_reg_31 ( .C(phi1), .D(input_fcs[31]), .Q(output_fcs[31]), 
        .RN(n326) );
    DFA2 output_fcs_reg_30 ( .C(phi1), .D(input_fcs[30]), .Q(output_fcs[30]), 
        .RN(n322) );
    DFA2 output_fcs_reg_29 ( .C(phi1), .D(input_fcs[29]), .Q(output_fcs[29]), 
        .RN(n326) );
    DFA2 output_fcs_reg_28 ( .C(phi1), .D(input_fcs[28]), .Q(output_fcs[28]), 
        .RN(n322) );
    DFA2 output_fcs_reg_27 ( .C(phi1), .D(input_fcs[27]), .Q(output_fcs[27]), 
        .RN(n326) );
    DFA2 output_fcs_reg_26 ( .C(phi1), .D(input_fcs[26]), .Q(output_fcs[26]), 
        .RN(n322) );
    DFA2 output_fcs_reg_25 ( .C(phi1), .D(input_fcs[25]), .Q(output_fcs[25]), 
        .RN(n326) );
    DFA2 output_fcs_reg_24 ( .C(phi1), .D(input_fcs[24]), .Q(output_fcs[24]), 
        .RN(n322) );
    DFA2 output_fcs_reg_23 ( .C(phi1), .D(input_fcs[23]), .Q(output_fcs[23]), 
        .RN(n326) );
    DFA2 output_fcs_reg_22 ( .C(phi1), .D(input_fcs[22]), .Q(output_fcs[22]), 
        .RN(n322) );
    DFA2 output_fcs_reg_21 ( .C(phi1), .D(input_fcs[21]), .Q(output_fcs[21]), 
        .RN(n318) );
    DFA2 output_fcs_reg_20 ( .C(phi1), .D(input_fcs[20]), .Q(output_fcs[20]), 
        .RN(n326) );
    DFA2 output_fcs_reg_15 ( .C(phi1), .D(input_fcs[15]), .Q(output_fcs[15]), 
        .RN(n322) );
    DFA2 output_fcs_reg_14 ( .C(phi1), .D(input_fcs[14]), .Q(output_fcs[14]), 
        .RN(n322) );
    DFA2 output_fcs_reg_13 ( .C(phi1), .D(input_fcs[13]), .Q(output_fcs[13]), 
        .RN(n322) );
    DFA2 output_fcs_reg_12 ( .C(phi1), .D(input_fcs[12]), .Q(output_fcs[12]), 
        .RN(n322) );
    DFA2 output_fcs_reg_11 ( .C(phi1), .D(input_fcs[11]), .Q(output_fcs[11]), 
        .RN(n322) );
    DFA2 output_fcs_reg_10 ( .C(phi1), .D(input_fcs[10]), .Q(output_fcs[10]), 
        .RN(n322) );
    DFA2 output_fcs_reg_9 ( .C(phi1), .D(input_fcs[9]), .Q(output_fcs[9]), 
        .RN(n322) );
    DFA2 output_fcs_reg_8 ( .C(phi1), .D(input_fcs[8]), .Q(output_fcs[8]), 
        .RN(n318) );
    DFA2 output_fcs_reg_7 ( .C(phi1), .D(input_fcs[7]), .Q(output_fcs[7]), 
        .RN(n322) );
    DFA2 output_fcs_reg_6 ( .C(phi1), .D(input_fcs[6]), .Q(output_fcs[6]), 
        .RN(n322) );
    DFA2 output_fcs_reg_5 ( .C(phi1), .D(input_fcs[5]), .Q(output_fcs[5]), 
        .RN(n322) );
    DFA2 output_fcs_reg_4 ( .C(phi1), .D(input_fcs[4]), .Q(output_fcs[4]), 
        .RN(n322) );
    DFA2 output_fcs_reg_3 ( .C(phi1), .D(input_fcs[3]), .Q(output_fcs[3]), 
        .RN(n322) );
    DFA2 output_fcs_reg_2 ( .C(phi1), .D(input_fcs[2]), .Q(output_fcs[2]), 
        .RN(n326) );
    DFA2 output_fcs_reg_1 ( .C(phi1), .D(input_fcs[1]), .Q(output_fcs[1]), 
        .RN(n322) );
    DFA2 output_fcs_reg_0 ( .C(phi1), .D(input_fcs[0]), .Q(output_fcs[0]), 
        .RN(n326) );
    DFA2 output_wip_reg_31 ( .C(phi1), .D(input_wip[31]), .Q(output_wip[31]), 
        .RN(n322) );
    DFA2 output_wip_reg_30 ( .C(phi1), .D(input_wip[30]), .Q(output_wip[30]), 
        .RN(n322) );
    DFA2 output_wip_reg_29 ( .C(phi1), .D(input_wip[29]), .Q(output_wip[29]), 
        .RN(n322) );
    DFA2 output_wip_reg_28 ( .C(phi1), .D(input_wip[28]), .Q(output_wip[28]), 
        .RN(n318) );
    DFA2 output_wip_reg_27 ( .C(phi1), .D(input_wip[27]), .Q(output_wip[27]), 
        .RN(n326) );
    DFA2 output_wip_reg_26 ( .C(phi1), .D(input_wip[26]), .Q(output_wip[26]), 
        .RN(n326) );
    DFA2 output_wip_reg_25 ( .C(phi1), .D(input_wip[25]), .Q(output_wip[25]), 
        .RN(n326) );
    DFA2 output_wip_reg_24 ( .C(phi1), .D(input_wip[24]), .Q(output_wip[24]), 
        .RN(n326) );
    DFA2 output_wip_reg_23 ( .C(phi1), .D(input_wip[23]), .Q(output_wip[23]), 
        .RN(n326) );
    DFA2 output_wip_reg_22 ( .C(phi1), .D(input_wip[22]), .Q(output_wip[22]), 
        .RN(n326) );
    DFA2 output_wip_reg_21 ( .C(phi1), .D(input_wip[21]), .Q(output_wip[21]), 
        .RN(n326) );
    DFA2 output_wip_reg_20 ( .C(phi1), .D(input_wip[20]), .Q(output_wip[20]), 
        .RN(n318) );
    DFA2 output_wip_reg_19 ( .C(phi1), .D(input_wip[19]), .Q(output_wip[19]), 
        .RN(n326) );
    DFA2 output_wip_reg_18 ( .C(phi1), .D(input_wip[18]), .Q(output_wip[18]), 
        .RN(n326) );
    DFA2 output_wip_reg_17 ( .C(phi1), .D(input_wip[17]), .Q(output_wip[17]), 
        .RN(n326) );
    DFA2 output_wip_reg_16 ( .C(phi1), .D(input_wip[16]), .Q(output_wip[16]), 
        .RN(n326) );
    DFA2 output_wip_reg_10 ( .C(phi1), .D(input_wip[10]), .Q(output_wip[10]), 
        .RN(n326) );
    DFA2 output_wip_reg_0 ( .C(phi1), .D(input_wip[0]), .Q(output_wip[0]), 
        .RN(n326) );
    BU4 U148 ( .A(n318), .Q(n326) );
    BU4 U149 ( .A(n318), .Q(n322) );
    BU2 U150 ( .A(reset), .Q(n318) );
    IN3 U151 ( .A(n330), .Q(output_wip[4]) );
    DFA2 output_wip_reg_4 ( .C(phi1), .D(input_wip[4]), .QN(n330), .RN(n318)
         );
    IN3 U152 ( .A(n342), .Q(output_wip[2]) );
    DFA2 output_wip_reg_2 ( .C(phi1), .D(input_wip[2]), .QN(n342), .RN(n318)
         );
    IN3 U153 ( .A(n346), .Q(output_wip[5]) );
    DFA2 output_wip_reg_5 ( .C(phi1), .D(input_wip[5]), .QN(n346), .RN(n318)
         );
    IN3 U154 ( .A(n350), .Q(output_wip[14]) );
    DFA2 output_wip_reg_14 ( .C(phi1), .D(input_wip[14]), .QN(n350), .RN(n318)
         );
    IN3 U155 ( .A(n354), .Q(output_wip[6]) );
    DFA2 output_wip_reg_6 ( .C(phi1), .D(input_wip[6]), .QN(n354), .RN(n318)
         );
    IN3 U156 ( .A(n358), .Q(output_wip[3]) );
    DFA2 output_wip_reg_3 ( .C(phi1), .D(input_wip[3]), .QN(n358), .RN(n326)
         );
    IN3 U157 ( .A(n362), .Q(output_wip[13]) );
    DFA2 output_wip_reg_13 ( .C(phi1), .D(input_wip[13]), .QN(n362), .RN(n326)
         );
    DFA2 output_wip_reg_12 ( .C(phi1), .D(input_wip[12]), .QN(n366), .RN(n326)
         );
    IN4 U158 ( .A(n370), .Q(output_fcs[18]) );
    IN4 U159 ( .A(n374), .Q(output_fcs[16]) );
    IN4 U160 ( .A(n378), .Q(output_fcs[17]) );
    DFA2 output_fcs_reg_18 ( .C(phi1), .D(input_fcs[18]), .QN(n370), .RN(n322)
         );
    DFA2 output_fcs_reg_16 ( .C(phi1), .D(input_fcs[16]), .QN(n374), .RN(n326)
         );
    DFA2 output_wip_reg_15 ( .C(phi1), .D(input_wip[15]), .Q(output_wip[15]), 
        .RN(n322) );
    DFA2 output_wip_reg_9 ( .C(phi1), .D(input_wip[9]), .Q(output_wip[9]), 
        .RN(n326) );
    DFA2 output_wip_reg_11 ( .C(phi1), .D(input_wip[11]), .Q(output_wip[11]), 
        .RN(n322) );
    DFA2 output_wip_reg_8 ( .C(phi1), .D(input_wip[8]), .Q(output_wip[8]), 
        .RN(n326) );
    DFA2 output_wip_reg_7 ( .C(phi1), .D(input_wip[7]), .Q(output_wip[7]), 
        .RN(n322) );
    DFA2 output_wip_reg_1 ( .C(phi1), .D(input_wip[1]), .Q(output_wip[1]), 
        .RN(n326) );
    DFA2 output_fcs_reg_19 ( .C(phi1), .D(input_fcs[19]), .Q(output_fcs[19]), 
        .RN(n322) );
    DFA2 output_fcs_reg_17 ( .C(phi1), .D(input_fcs[17]), .QN(n378), .RN(n322)
         );
endmodule


module gf_phi1_register_3 ( reset, phi1, input_wip, input_fcs, output_wip, 
    output_fcs );
output [31:0] output_fcs;
input  [31:0] input_fcs;
input  [31:0] input_wip;
output [31:0] output_wip;
input  reset, phi1;
    wire n340, n344, n348, n356, n364, n372, n380, n430, n432, n434, n436, 
        n438, n440, n442, n444, n446, n448, n450, n452, n454, n456, n458, n460, 
        n462, n464, n466, n468, n470, n472, n474;
    DFA output_wip_reg_11 ( .C(phi1), .D(input_wip[11]), .QN(n434), .RN(n344)
         );
    DFA output_wip_reg_8 ( .C(phi1), .D(input_wip[8]), .QN(n436), .RN(n344) );
    DFA output_wip_reg_1 ( .C(phi1), .D(input_wip[1]), .QN(n446), .RN(n340) );
    DFA output_wip_reg_9 ( .C(phi1), .D(input_wip[9]), .QN(n452), .RN(n344) );
    DFA output_wip_reg_2 ( .C(phi1), .D(input_wip[2]), .QN(n456), .RN(n344) );
    IN1 U147 ( .A(n430), .Q(output_wip[13]) );
    IN1 U148 ( .A(n432), .Q(output_wip[12]) );
    IN1 U149 ( .A(n434), .Q(output_wip[11]) );
    IN1 U150 ( .A(n436), .Q(output_wip[8]) );
    IN1 U151 ( .A(n438), .Q(output_wip[7]) );
    IN1 U152 ( .A(n440), .Q(output_wip[6]) );
    IN1 U153 ( .A(n442), .Q(output_wip[4]) );
    IN1 U154 ( .A(n444), .Q(output_wip[3]) );
    IN1 U155 ( .A(n446), .Q(output_wip[1]) );
    IN1 U156 ( .A(n448), .Q(output_wip[15]) );
    IN1 U157 ( .A(n450), .Q(output_wip[14]) );
    IN1 U158 ( .A(n452), .Q(output_wip[9]) );
    IN1 U159 ( .A(n454), .Q(output_wip[5]) );
    IN1 U160 ( .A(n456), .Q(output_wip[2]) );
    DFA2 output_fcs_reg_31 ( .C(phi1), .D(input_fcs[31]), .Q(output_fcs[31]), 
        .RN(n340) );
    DFA2 output_fcs_reg_30 ( .C(phi1), .D(input_fcs[30]), .Q(output_fcs[30]), 
        .RN(n340) );
    DFA2 output_fcs_reg_29 ( .C(phi1), .D(input_fcs[29]), .Q(output_fcs[29]), 
        .RN(n344) );
    DFA2 output_fcs_reg_28 ( .C(phi1), .D(input_fcs[28]), .Q(output_fcs[28]), 
        .RN(n344) );
    DFA2 output_fcs_reg_27 ( .C(phi1), .D(input_fcs[27]), .Q(output_fcs[27]), 
        .RN(n340) );
    DFA2 output_fcs_reg_26 ( .C(phi1), .D(input_fcs[26]), .Q(output_fcs[26]), 
        .RN(n344) );
    DFA2 output_fcs_reg_25 ( .C(phi1), .D(input_fcs[25]), .Q(output_fcs[25]), 
        .RN(n340) );
    DFA2 output_fcs_reg_24 ( .C(phi1), .D(input_fcs[24]), .Q(output_fcs[24]), 
        .RN(n340) );
    DFA2 output_fcs_reg_5 ( .C(phi1), .D(input_fcs[5]), .Q(output_fcs[5]), 
        .RN(n344) );
    DFA2 output_fcs_reg_4 ( .C(phi1), .D(input_fcs[4]), .Q(output_fcs[4]), 
        .RN(n344) );
    DFA2 output_wip_reg_21 ( .C(phi1), .D(input_wip[21]), .Q(output_wip[21]), 
        .RN(n340) );
    DFA2 output_wip_reg_20 ( .C(phi1), .D(input_wip[20]), .Q(output_wip[20]), 
        .RN(n344) );
    DFA2 output_wip_reg_0 ( .C(phi1), .D(input_wip[0]), .Q(output_wip[0]), 
        .RN(n344) );
    BU4 U161 ( .A(reset), .Q(n340) );
    BU8 U162 ( .A(n340), .Q(n344) );
    IN3 U163 ( .A(n348), .Q(output_wip[10]) );
    DFA2 output_wip_reg_10 ( .C(phi1), .D(input_wip[10]), .QN(n348), .RN(n344)
         );
    IN3 U164 ( .A(n356), .Q(output_wip[23]) );
    DFA2 output_wip_reg_23 ( .C(phi1), .D(input_wip[23]), .QN(n356), .RN(n344)
         );
    IN3 U165 ( .A(n364), .Q(output_wip[18]) );
    DFA2 output_wip_reg_18 ( .C(phi1), .D(input_wip[18]), .QN(n364), .RN(n344)
         );
    IN3 U166 ( .A(n372), .Q(output_wip[17]) );
    DFA2 output_wip_reg_17 ( .C(phi1), .D(input_wip[17]), .QN(n372), .RN(n344)
         );
    IN3 U167 ( .A(n380), .Q(output_wip[16]) );
    DFA2 output_wip_reg_16 ( .C(phi1), .D(input_wip[16]), .QN(n380), .RN(n344)
         );
    DFA2 output_wip_reg_13 ( .C(phi1), .D(input_wip[13]), .QN(n430), .RN(n340)
         );
    DFA2 output_wip_reg_12 ( .C(phi1), .D(input_wip[12]), .QN(n432), .RN(n340)
         );
    DFA2 output_wip_reg_7 ( .C(phi1), .D(input_wip[7]), .QN(n438), .RN(n340)
         );
    DFA2 output_wip_reg_6 ( .C(phi1), .D(input_wip[6]), .QN(n440), .RN(n340)
         );
    DFA2 output_wip_reg_4 ( .C(phi1), .D(input_wip[4]), .QN(n442), .RN(n340)
         );
    DFA2 output_wip_reg_3 ( .C(phi1), .D(input_wip[3]), .QN(n444), .RN(n340)
         );
    DFA2 output_wip_reg_15 ( .C(phi1), .D(input_wip[15]), .QN(n448), .RN(n340)
         );
    DFA2 output_wip_reg_14 ( .C(phi1), .D(input_wip[14]), .QN(n450), .RN(n344)
         );
    DFA2 output_wip_reg_5 ( .C(phi1), .D(input_wip[5]), .QN(n454), .RN(n344)
         );
    IN4 U168 ( .A(n458), .Q(output_fcs[7]) );
    IN4 U169 ( .A(n460), .Q(output_fcs[2]) );
    IN4 U170 ( .A(n462), .Q(output_fcs[1]) );
    IN4 U171 ( .A(n464), .Q(output_fcs[0]) );
    IN4 U172 ( .A(n466), .Q(output_fcs[16]) );
    IN4 U173 ( .A(n468), .Q(output_fcs[17]) );
    IN4 U174 ( .A(n470), .Q(output_fcs[18]) );
    IN4 U175 ( .A(n472), .Q(output_fcs[19]) );
    IN4 U176 ( .A(n474), .Q(output_fcs[20]) );
    DFA2 output_fcs_reg_21 ( .C(phi1), .D(input_fcs[21]), .Q(output_fcs[21]), 
        .RN(n340) );
    DFA2 output_fcs_reg_0 ( .C(phi1), .D(input_fcs[0]), .QN(n464), .RN(n344)
         );
    DFA2 output_fcs_reg_1 ( .C(phi1), .D(input_fcs[1]), .QN(n462), .RN(n340)
         );
    DFA2 output_fcs_reg_2 ( .C(phi1), .D(input_fcs[2]), .QN(n460), .RN(n340)
         );
    DFA2 output_fcs_reg_7 ( .C(phi1), .D(input_fcs[7]), .QN(n458), .RN(n344)
         );
    DFA2 output_wip_reg_31 ( .C(phi1), .D(input_wip[31]), .Q(output_wip[31]), 
        .RN(n344) );
    DFA2 output_wip_reg_30 ( .C(phi1), .D(input_wip[30]), .Q(output_wip[30]), 
        .RN(n344) );
    DFA2 output_wip_reg_29 ( .C(phi1), .D(input_wip[29]), .Q(output_wip[29]), 
        .RN(n340) );
    DFA2 output_wip_reg_28 ( .C(phi1), .D(input_wip[28]), .Q(output_wip[28]), 
        .RN(n344) );
    DFA2 output_wip_reg_27 ( .C(phi1), .D(input_wip[27]), .Q(output_wip[27]), 
        .RN(n344) );
    DFA2 output_wip_reg_26 ( .C(phi1), .D(input_wip[26]), .Q(output_wip[26]), 
        .RN(n340) );
    DFA2 output_wip_reg_25 ( .C(phi1), .D(input_wip[25]), .Q(output_wip[25]), 
        .RN(n344) );
    DFA2 output_wip_reg_24 ( .C(phi1), .D(input_wip[24]), .Q(output_wip[24]), 
        .RN(n340) );
    DFA2 output_wip_reg_22 ( .C(phi1), .D(input_wip[22]), .Q(output_wip[22]), 
        .RN(n344) );
    DFA2 output_wip_reg_19 ( .C(phi1), .D(input_wip[19]), .Q(output_wip[19]), 
        .RN(n344) );
    DFA2 output_fcs_reg_15 ( .C(phi1), .D(input_fcs[15]), .Q(output_fcs[15]), 
        .RN(n344) );
    DFA2 output_fcs_reg_14 ( .C(phi1), .D(input_fcs[14]), .Q(output_fcs[14]), 
        .RN(n340) );
    DFA2 output_fcs_reg_13 ( .C(phi1), .D(input_fcs[13]), .Q(output_fcs[13]), 
        .RN(n340) );
    DFA2 output_fcs_reg_12 ( .C(phi1), .D(input_fcs[12]), .Q(output_fcs[12]), 
        .RN(n340) );
    DFA2 output_fcs_reg_11 ( .C(phi1), .D(input_fcs[11]), .Q(output_fcs[11]), 
        .RN(n344) );
    DFA2 output_fcs_reg_10 ( .C(phi1), .D(input_fcs[10]), .Q(output_fcs[10]), 
        .RN(n344) );
    DFA2 output_fcs_reg_9 ( .C(phi1), .D(input_fcs[9]), .Q(output_fcs[9]), 
        .RN(n344) );
    DFA2 output_fcs_reg_8 ( .C(phi1), .D(input_fcs[8]), .Q(output_fcs[8]), 
        .RN(n340) );
    DFA2 output_fcs_reg_6 ( .C(phi1), .D(input_fcs[6]), .Q(output_fcs[6]), 
        .RN(n340) );
    DFA2 output_fcs_reg_3 ( .C(phi1), .D(input_fcs[3]), .Q(output_fcs[3]), 
        .RN(n344) );
    DFA2 output_fcs_reg_17 ( .C(phi1), .D(input_fcs[17]), .QN(n468), .RN(n344)
         );
    DFA2 output_fcs_reg_23 ( .C(phi1), .D(input_fcs[23]), .Q(output_fcs[23]), 
        .RN(n344) );
    DFA2 output_fcs_reg_16 ( .C(phi1), .D(input_fcs[16]), .QN(n466), .RN(n344)
         );
    DFA2 output_fcs_reg_18 ( .C(phi1), .D(input_fcs[18]), .QN(n470), .RN(n340)
         );
    DFA2 output_fcs_reg_19 ( .C(phi1), .D(input_fcs[19]), .QN(n472), .RN(n340)
         );
    DFA2 output_fcs_reg_20 ( .C(phi1), .D(input_fcs[20]), .QN(n474), .RN(n344)
         );
    DFA2 output_fcs_reg_22 ( .C(phi1), .D(input_fcs[22]), .Q(output_fcs[22]), 
        .RN(n344) );
endmodule


module gf_phi2_register_0 ( reset, phi2, input_wip, input_fcs, output_wip, 
    output_fcs );
output [31:0] output_fcs;
input  [31:0] input_wip;
input  [31:0] input_fcs;
output [31:0] output_wip;
input  reset, phi2;
    wire n190, n192, n194, n196, n200, n204, n208, n212, n216;
    DFA output_wip_reg_30 ( .C(phi2), .D(input_wip[30]), .Q(output_wip[30]), 
        .RN(n192) );
    DFA output_wip_reg_29 ( .C(phi2), .D(input_wip[29]), .Q(output_wip[29]), 
        .RN(n192) );
    DFA output_wip_reg_27 ( .C(phi2), .D(input_wip[27]), .Q(output_wip[27]), 
        .RN(n192) );
    DFA output_wip_reg_25 ( .C(phi2), .D(input_wip[25]), .Q(output_wip[25]), 
        .RN(n194) );
    DFA output_wip_reg_24 ( .C(phi2), .D(input_wip[24]), .Q(output_wip[24]), 
        .RN(n192) );
    DFA output_wip_reg_22 ( .C(phi2), .D(input_wip[22]), .Q(output_wip[22]), 
        .RN(n194) );
    DFA output_wip_reg_19 ( .C(phi2), .D(input_wip[19]), .Q(output_wip[19]), 
        .RN(n192) );
    DFA output_wip_reg_17 ( .C(phi2), .D(input_wip[17]), .Q(output_wip[17]), 
        .RN(n190) );
    DFA output_wip_reg_3 ( .C(phi2), .D(input_wip[3]), .Q(output_wip[3]), .RN(
        n192) );
    DFA output_wip_reg_15 ( .C(phi2), .D(input_wip[15]), .Q(output_wip[15]), 
        .RN(n190) );
    DFA output_wip_reg_13 ( .C(phi2), .D(input_wip[13]), .Q(output_wip[13]), 
        .RN(n190) );
    DFA output_wip_reg_12 ( .C(phi2), .D(input_wip[12]), .Q(output_wip[12]), 
        .RN(n190) );
    DFA output_wip_reg_6 ( .C(phi2), .D(input_wip[6]), .Q(output_wip[6]), .RN(
        n194) );
    DFA output_wip_reg_23 ( .C(phi2), .D(input_wip[23]), .Q(output_wip[23]), 
        .RN(n194) );
    DFA output_wip_reg_18 ( .C(phi2), .D(input_wip[18]), .Q(output_wip[18]), 
        .RN(n194) );
    DFA output_wip_reg_16 ( .C(phi2), .D(input_wip[16]), .Q(output_wip[16]), 
        .RN(n192) );
    DFA output_wip_reg_14 ( .C(phi2), .D(input_wip[14]), .Q(output_wip[14]), 
        .RN(n194) );
    DFA output_wip_reg_11 ( .C(phi2), .D(input_wip[11]), .Q(output_wip[11]), 
        .RN(n194) );
    DFA output_wip_reg_10 ( .C(phi2), .D(input_wip[10]), .Q(output_wip[10]), 
        .RN(n194) );
    DFA output_wip_reg_9 ( .C(phi2), .D(input_wip[9]), .Q(output_wip[9]), .RN(
        n194) );
    DFA output_wip_reg_8 ( .C(phi2), .D(input_wip[8]), .Q(output_wip[8]), .RN(
        n192) );
    DFA output_wip_reg_7 ( .C(phi2), .D(input_wip[7]), .Q(output_wip[7]), .RN(
        n194) );
    DFA output_wip_reg_5 ( .C(phi2), .D(input_wip[5]), .Q(output_wip[5]), .RN(
        n192) );
    DFA output_wip_reg_4 ( .C(phi2), .D(input_wip[4]), .Q(output_wip[4]), .RN(
        n194) );
    DFA output_wip_reg_2 ( .C(phi2), .D(input_wip[2]), .Q(output_wip[2]), .RN(
        n192) );
    DFA output_wip_reg_1 ( .C(phi2), .D(input_wip[1]), .Q(output_wip[1]), .RN(
        n194) );
    DFA2 output_fcs_reg_31 ( .C(phi2), .D(input_fcs[31]), .Q(output_fcs[31]), 
        .RN(n192) );
    DFA2 output_fcs_reg_30 ( .C(phi2), .D(input_fcs[30]), .Q(output_fcs[30]), 
        .RN(n194) );
    DFA2 output_fcs_reg_29 ( .C(phi2), .D(input_fcs[29]), .Q(output_fcs[29]), 
        .RN(n194) );
    DFA2 output_fcs_reg_28 ( .C(phi2), .D(input_fcs[28]), .Q(output_fcs[28]), 
        .RN(n190) );
    DFA2 output_fcs_reg_27 ( .C(phi2), .D(input_fcs[27]), .Q(output_fcs[27]), 
        .RN(n194) );
    DFA2 output_fcs_reg_26 ( .C(phi2), .D(input_fcs[26]), .Q(output_fcs[26]), 
        .RN(n194) );
    DFA output_fcs_reg_7 ( .C(phi2), .D(input_fcs[7]), .Q(output_fcs[7]), .RN(
        n194) );
    DFA output_fcs_reg_2 ( .C(phi2), .D(input_fcs[2]), .Q(output_fcs[2]), .RN(
        n194) );
    DFA output_fcs_reg_1 ( .C(phi2), .D(input_fcs[1]), .Q(output_fcs[1]), .RN(
        n194) );
    DFA output_fcs_reg_0 ( .C(phi2), .D(input_fcs[0]), .Q(output_fcs[0]), .RN(
        n194) );
    BU4 U147 ( .A(n190), .Q(n194) );
    BU4 U148 ( .A(n190), .Q(n192) );
    BU2 U149 ( .A(reset), .Q(n190) );
    IN4 U150 ( .A(n196), .Q(output_fcs[18]) );
    IN4 U151 ( .A(n200), .Q(output_fcs[16]) );
    DFA output_fcs_reg_24 ( .C(phi2), .D(input_fcs[24]), .Q(output_fcs[24]), 
        .RN(n192) );
    DFA output_wip_reg_0 ( .C(phi2), .D(input_wip[0]), .Q(output_wip[0]), .RN(
        n194) );
    DFA2 output_fcs_reg_17 ( .C(phi2), .D(input_fcs[17]), .Q(output_fcs[17]), 
        .RN(n194) );
    IN4 U152 ( .A(n204), .Q(output_fcs[19]) );
    IN4 U153 ( .A(n208), .Q(output_fcs[22]) );
    IN4 U154 ( .A(n212), .Q(output_fcs[20]) );
    IN4 U155 ( .A(n216), .Q(output_fcs[21]) );
    DFA2 output_fcs_reg_25 ( .C(phi2), .D(input_fcs[25]), .Q(output_fcs[25]), 
        .RN(n190) );
    DFA output_wip_reg_21 ( .C(phi2), .D(input_wip[21]), .Q(output_wip[21]), 
        .RN(n194) );
    DFA output_wip_reg_20 ( .C(phi2), .D(input_wip[20]), .Q(output_wip[20]), 
        .RN(n192) );
    DFA output_fcs_reg_5 ( .C(phi2), .D(input_fcs[5]), .Q(output_fcs[5]), .RN(
        n194) );
    DFA output_fcs_reg_4 ( .C(phi2), .D(input_fcs[4]), .Q(output_fcs[4]), .RN(
        n192) );
    DFA2 output_wip_reg_31 ( .C(phi2), .D(input_wip[31]), .Q(output_wip[31]), 
        .RN(n190) );
    DFA2 output_wip_reg_28 ( .C(phi2), .D(input_wip[28]), .Q(output_wip[28]), 
        .RN(n194) );
    DFA2 output_wip_reg_26 ( .C(phi2), .D(input_wip[26]), .Q(output_wip[26]), 
        .RN(n194) );
    DFA2 output_fcs_reg_23 ( .C(phi2), .D(input_fcs[23]), .Q(output_fcs[23]), 
        .RN(n192) );
    DFA2 output_fcs_reg_3 ( .C(phi2), .D(input_fcs[3]), .Q(output_fcs[3]), 
        .RN(n194) );
    DFA2 output_fcs_reg_6 ( .C(phi2), .D(input_fcs[6]), .Q(output_fcs[6]), 
        .RN(n194) );
    DFA2 output_fcs_reg_8 ( .C(phi2), .D(input_fcs[8]), .Q(output_fcs[8]), 
        .RN(n192) );
    DFA2 output_fcs_reg_9 ( .C(phi2), .D(input_fcs[9]), .Q(output_fcs[9]), 
        .RN(n190) );
    DFA2 output_fcs_reg_10 ( .C(phi2), .D(input_fcs[10]), .Q(output_fcs[10]), 
        .RN(n192) );
    DFA2 output_fcs_reg_11 ( .C(phi2), .D(input_fcs[11]), .Q(output_fcs[11]), 
        .RN(n192) );
    DFA2 output_fcs_reg_12 ( .C(phi2), .D(input_fcs[12]), .Q(output_fcs[12]), 
        .RN(n192) );
    DFA2 output_fcs_reg_13 ( .C(phi2), .D(input_fcs[13]), .Q(output_fcs[13]), 
        .RN(n192) );
    DFA2 output_fcs_reg_14 ( .C(phi2), .D(input_fcs[14]), .Q(output_fcs[14]), 
        .RN(n192) );
    DFA2 output_fcs_reg_15 ( .C(phi2), .D(input_fcs[15]), .Q(output_fcs[15]), 
        .RN(n192) );
    DFA2 output_fcs_reg_16 ( .C(phi2), .D(input_fcs[16]), .QN(n200), .RN(n192)
         );
    DFA2 output_fcs_reg_18 ( .C(phi2), .D(input_fcs[18]), .QN(n196), .RN(n190)
         );
    DFA2 output_fcs_reg_19 ( .C(phi2), .D(input_fcs[19]), .QN(n204), .RN(n192)
         );
    DFA2 output_fcs_reg_20 ( .C(phi2), .D(input_fcs[20]), .QN(n212), .RN(n192)
         );
    DFA2 output_fcs_reg_22 ( .C(phi2), .D(input_fcs[22]), .QN(n208), .RN(n192)
         );
    DFA2 output_fcs_reg_21 ( .C(phi2), .D(input_fcs[21]), .QN(n216), .RN(n192)
         );
endmodule


module gf_phi2_register_1 ( reset, phi2, input_wip, input_fcs, output_wip, 
    output_fcs );
output [31:0] output_fcs;
input  [31:0] input_wip;
input  [31:0] input_fcs;
output [31:0] output_wip;
input  reset, phi2;
    wire n198, n202, n206, n210, n218, n234, n238, n242, n246, n250;
    DFA output_fcs_reg_27 ( .C(phi2), .D(input_fcs[27]), .Q(output_fcs[27]), 
        .RN(n202) );
    DFA output_wip_reg_24 ( .C(phi2), .D(input_wip[24]), .Q(output_wip[24]), 
        .RN(n202) );
    DFA output_wip_reg_29 ( .C(phi2), .D(input_wip[29]), .Q(output_wip[29]), 
        .RN(n202) );
    DFA output_wip_reg_28 ( .C(phi2), .D(input_wip[28]), .Q(output_wip[28]), 
        .RN(n202) );
    DFA output_wip_reg_22 ( .C(phi2), .D(input_wip[22]), .Q(output_wip[22]), 
        .RN(n202) );
    DFA output_wip_reg_18 ( .C(phi2), .D(input_wip[18]), .Q(output_wip[18]), 
        .RN(n202) );
    DFA output_wip_reg_14 ( .C(phi2), .D(input_wip[14]), .Q(output_wip[14]), 
        .RN(n202) );
    DFA output_wip_reg_12 ( .C(phi2), .D(input_wip[12]), .Q(output_wip[12]), 
        .RN(n202) );
    DFA output_wip_reg_9 ( .C(phi2), .D(input_wip[9]), .Q(output_wip[9]), .RN(
        n202) );
    DFA output_wip_reg_7 ( .C(phi2), .D(input_wip[7]), .Q(output_wip[7]), .RN(
        n202) );
    DFA output_wip_reg_5 ( .C(phi2), .D(input_wip[5]), .Q(output_wip[5]), .RN(
        n206) );
    DFA output_wip_reg_4 ( .C(phi2), .D(input_wip[4]), .Q(output_wip[4]), .RN(
        n202) );
    DFA output_wip_reg_3 ( .C(phi2), .D(input_wip[3]), .Q(output_wip[3]), .RN(
        n206) );
    DFA output_wip_reg_1 ( .C(phi2), .D(input_wip[1]), .Q(output_wip[1]), .RN(
        n202) );
    DFA output_wip_reg_0 ( .C(phi2), .D(input_wip[0]), .Q(output_wip[0]), .RN(
        n206) );
    DFA output_wip_reg_27 ( .C(phi2), .D(input_wip[27]), .Q(output_wip[27]), 
        .RN(n206) );
    DFA output_wip_reg_26 ( .C(phi2), .D(input_wip[26]), .Q(output_wip[26]), 
        .RN(n202) );
    DFA output_wip_reg_25 ( .C(phi2), .D(input_wip[25]), .Q(output_wip[25]), 
        .RN(n206) );
    DFA output_wip_reg_20 ( .C(phi2), .D(input_wip[20]), .Q(output_wip[20]), 
        .RN(n202) );
    DFA output_fcs_reg_31 ( .C(phi2), .D(input_fcs[31]), .Q(output_fcs[31]), 
        .RN(n202) );
    DFA output_fcs_reg_17 ( .C(phi2), .D(input_fcs[17]), .Q(output_fcs[17]), 
        .RN(n202) );
    DFA output_fcs_reg_16 ( .C(phi2), .D(input_fcs[16]), .Q(output_fcs[16]), 
        .RN(n202) );
    DFA output_fcs_reg_15 ( .C(phi2), .D(input_fcs[15]), .Q(output_fcs[15]), 
        .RN(n202) );
    DFA output_fcs_reg_14 ( .C(phi2), .D(input_fcs[14]), .Q(output_fcs[14]), 
        .RN(n198) );
    DFA output_fcs_reg_13 ( .C(phi2), .D(input_fcs[13]), .Q(output_fcs[13]), 
        .RN(n206) );
    DFA output_fcs_reg_12 ( .C(phi2), .D(input_fcs[12]), .Q(output_fcs[12]), 
        .RN(n206) );
    DFA output_fcs_reg_11 ( .C(phi2), .D(input_fcs[11]), .Q(output_fcs[11]), 
        .RN(n206) );
    DFA output_fcs_reg_10 ( .C(phi2), .D(input_fcs[10]), .Q(output_fcs[10]), 
        .RN(n206) );
    DFA output_fcs_reg_9 ( .C(phi2), .D(input_fcs[9]), .Q(output_fcs[9]), .RN(
        n206) );
    DFA output_fcs_reg_8 ( .C(phi2), .D(input_fcs[8]), .Q(output_fcs[8]), .RN(
        n206) );
    DFA output_fcs_reg_7 ( .C(phi2), .D(input_fcs[7]), .Q(output_fcs[7]), .RN(
        n206) );
    DFA output_fcs_reg_6 ( .C(phi2), .D(input_fcs[6]), .Q(output_fcs[6]), .RN(
        n198) );
    DFA output_fcs_reg_5 ( .C(phi2), .D(input_fcs[5]), .Q(output_fcs[5]), .RN(
        n206) );
    DFA output_fcs_reg_4 ( .C(phi2), .D(input_fcs[4]), .Q(output_fcs[4]), .RN(
        n206) );
    DFA output_fcs_reg_3 ( .C(phi2), .D(input_fcs[3]), .Q(output_fcs[3]), .RN(
        n206) );
    DFA output_fcs_reg_2 ( .C(phi2), .D(input_fcs[2]), .Q(output_fcs[2]), .RN(
        n198) );
    DFA output_fcs_reg_1 ( .C(phi2), .D(input_fcs[1]), .Q(output_fcs[1]), .RN(
        n206) );
    DFA output_fcs_reg_0 ( .C(phi2), .D(input_fcs[0]), .Q(output_fcs[0]), .RN(
        n206) );
    BU4 U147 ( .A(n198), .Q(n206) );
    BU4 U148 ( .A(n198), .Q(n202) );
    DFA output_wip_reg_15 ( .C(phi2), .D(input_wip[15]), .Q(output_wip[15]), 
        .RN(n198) );
    DFA output_wip_reg_10 ( .C(phi2), .D(input_wip[10]), .Q(output_wip[10]), 
        .RN(n198) );
    DFA output_wip_reg_2 ( .C(phi2), .D(input_wip[2]), .Q(output_wip[2]), .RN(
        n198) );
    DFA output_wip_reg_21 ( .C(phi2), .D(input_wip[21]), .Q(output_wip[21]), 
        .RN(n198) );
    DFA output_wip_reg_31 ( .C(phi2), .D(input_wip[31]), .Q(output_wip[31]), 
        .RN(n198) );
    DFA output_fcs_reg_30 ( .C(phi2), .D(input_fcs[30]), .Q(output_fcs[30]), 
        .RN(n206) );
    BU2 U149 ( .A(reset), .Q(n198) );
    IN4 U150 ( .A(n210), .Q(output_fcs[20]) );
    IN4 U151 ( .A(n218), .Q(output_fcs[19]) );
    DFA output_fcs_reg_28 ( .C(phi2), .D(input_fcs[28]), .Q(output_fcs[28]), 
        .RN(n206) );
    DFA output_fcs_reg_26 ( .C(phi2), .D(input_fcs[26]), .Q(output_fcs[26]), 
        .RN(n202) );
    IN4 U152 ( .A(n242), .Q(output_fcs[23]) );
    IN4 U153 ( .A(n246), .Q(output_fcs[24]) );
    IN4 U154 ( .A(n250), .Q(output_fcs[25]) );
    IN4 U155 ( .A(n234), .Q(output_fcs[21]) );
    IN4 U156 ( .A(n238), .Q(output_fcs[22]) );
    DFA2 output_fcs_reg_29 ( .C(phi2), .D(input_fcs[29]), .Q(output_fcs[29]), 
        .RN(n202) );
    DFA2 output_fcs_reg_18 ( .C(phi2), .D(input_fcs[18]), .Q(output_fcs[18]), 
        .RN(n202) );
    DFA2 output_wip_reg_30 ( .C(phi2), .D(input_wip[30]), .Q(output_wip[30]), 
        .RN(n206) );
    DFA2 output_wip_reg_23 ( .C(phi2), .D(input_wip[23]), .Q(output_wip[23]), 
        .RN(n206) );
    DFA2 output_wip_reg_19 ( .C(phi2), .D(input_wip[19]), .Q(output_wip[19]), 
        .RN(n206) );
    DFA2 output_wip_reg_17 ( .C(phi2), .D(input_wip[17]), .Q(output_wip[17]), 
        .RN(n206) );
    DFA2 output_wip_reg_16 ( .C(phi2), .D(input_wip[16]), .Q(output_wip[16]), 
        .RN(n206) );
    DFA2 output_wip_reg_13 ( .C(phi2), .D(input_wip[13]), .Q(output_wip[13]), 
        .RN(n206) );
    DFA2 output_wip_reg_11 ( .C(phi2), .D(input_wip[11]), .Q(output_wip[11]), 
        .RN(n206) );
    DFA2 output_wip_reg_8 ( .C(phi2), .D(input_wip[8]), .Q(output_wip[8]), 
        .RN(n206) );
    DFA2 output_wip_reg_6 ( .C(phi2), .D(input_wip[6]), .Q(output_wip[6]), 
        .RN(n206) );
    DFA2 output_fcs_reg_19 ( .C(phi2), .D(input_fcs[19]), .QN(n218), .RN(n202)
         );
    DFA2 output_fcs_reg_20 ( .C(phi2), .D(input_fcs[20]), .QN(n210), .RN(n202)
         );
    DFA2 output_fcs_reg_21 ( .C(phi2), .D(input_fcs[21]), .QN(n234), .RN(n202)
         );
    DFA2 output_fcs_reg_22 ( .C(phi2), .D(input_fcs[22]), .QN(n238), .RN(n198)
         );
    DFA2 output_fcs_reg_23 ( .C(phi2), .D(input_fcs[23]), .QN(n242), .RN(n202)
         );
    DFA2 output_fcs_reg_24 ( .C(phi2), .D(input_fcs[24]), .QN(n246), .RN(n202)
         );
    DFA2 output_fcs_reg_25 ( .C(phi2), .D(input_fcs[25]), .QN(n250), .RN(n202)
         );
endmodule


module gf_phi2_register_2 ( reset, phi2, input_wip, input_fcs, output_wip, 
    output_fcs );
output [31:0] output_fcs;
input  [31:0] input_wip;
input  [31:0] input_fcs;
output [31:0] output_wip;
input  reset, phi2;
    wire n240, n248;
    DFA output_fcs_reg_16 ( .C(phi2), .D(input_fcs[16]), .Q(output_fcs[16]), 
        .RN(n240) );
    DFA output_wip_reg_12 ( .C(phi2), .D(input_wip[12]), .Q(output_wip[12]), 
        .RN(n248) );
    DFA2 output_fcs_reg_31 ( .C(phi2), .D(input_fcs[31]), .Q(output_fcs[31]), 
        .RN(n248) );
    DFA2 output_fcs_reg_30 ( .C(phi2), .D(input_fcs[30]), .Q(output_fcs[30]), 
        .RN(n248) );
    DFA2 output_fcs_reg_29 ( .C(phi2), .D(input_fcs[29]), .Q(output_fcs[29]), 
        .RN(n240) );
    DFA2 output_fcs_reg_28 ( .C(phi2), .D(input_fcs[28]), .Q(output_fcs[28]), 
        .RN(n240) );
    DFA2 output_fcs_reg_27 ( .C(phi2), .D(input_fcs[27]), .Q(output_fcs[27]), 
        .RN(n240) );
    DFA2 output_fcs_reg_26 ( .C(phi2), .D(input_fcs[26]), .Q(output_fcs[26]), 
        .RN(n248) );
    DFA2 output_fcs_reg_25 ( .C(phi2), .D(input_fcs[25]), .Q(output_fcs[25]), 
        .RN(n240) );
    DFA2 output_fcs_reg_24 ( .C(phi2), .D(input_fcs[24]), .Q(output_fcs[24]), 
        .RN(n240) );
    DFA2 output_fcs_reg_23 ( .C(phi2), .D(input_fcs[23]), .Q(output_fcs[23]), 
        .RN(n248) );
    DFA2 output_fcs_reg_22 ( .C(phi2), .D(input_fcs[22]), .Q(output_fcs[22]), 
        .RN(n248) );
    DFA2 output_fcs_reg_21 ( .C(phi2), .D(input_fcs[21]), .Q(output_fcs[21]), 
        .RN(n248) );
    DFA2 output_fcs_reg_20 ( .C(phi2), .D(input_fcs[20]), .Q(output_fcs[20]), 
        .RN(n240) );
    DFA2 output_fcs_reg_15 ( .C(phi2), .D(input_fcs[15]), .Q(output_fcs[15]), 
        .RN(n240) );
    DFA2 output_fcs_reg_14 ( .C(phi2), .D(input_fcs[14]), .Q(output_fcs[14]), 
        .RN(n248) );
    DFA2 output_fcs_reg_13 ( .C(phi2), .D(input_fcs[13]), .Q(output_fcs[13]), 
        .RN(n248) );
    DFA2 output_fcs_reg_12 ( .C(phi2), .D(input_fcs[12]), .Q(output_fcs[12]), 
        .RN(n240) );
    DFA2 output_fcs_reg_11 ( .C(phi2), .D(input_fcs[11]), .Q(output_fcs[11]), 
        .RN(n248) );
    DFA2 output_fcs_reg_10 ( .C(phi2), .D(input_fcs[10]), .Q(output_fcs[10]), 
        .RN(n248) );
    DFA2 output_fcs_reg_9 ( .C(phi2), .D(input_fcs[9]), .Q(output_fcs[9]), 
        .RN(n248) );
    DFA2 output_fcs_reg_8 ( .C(phi2), .D(input_fcs[8]), .Q(output_fcs[8]), 
        .RN(n240) );
    DFA2 output_fcs_reg_7 ( .C(phi2), .D(input_fcs[7]), .Q(output_fcs[7]), 
        .RN(n240) );
    DFA2 output_fcs_reg_6 ( .C(phi2), .D(input_fcs[6]), .Q(output_fcs[6]), 
        .RN(n248) );
    DFA2 output_fcs_reg_5 ( .C(phi2), .D(input_fcs[5]), .Q(output_fcs[5]), 
        .RN(n240) );
    DFA2 output_fcs_reg_4 ( .C(phi2), .D(input_fcs[4]), .Q(output_fcs[4]), 
        .RN(n240) );
    DFA2 output_fcs_reg_3 ( .C(phi2), .D(input_fcs[3]), .Q(output_fcs[3]), 
        .RN(n240) );
    DFA2 output_fcs_reg_2 ( .C(phi2), .D(input_fcs[2]), .Q(output_fcs[2]), 
        .RN(n248) );
    DFA2 output_fcs_reg_1 ( .C(phi2), .D(input_fcs[1]), .Q(output_fcs[1]), 
        .RN(n248) );
    DFA2 output_fcs_reg_0 ( .C(phi2), .D(input_fcs[0]), .Q(output_fcs[0]), 
        .RN(n248) );
    DFA output_wip_reg_31 ( .C(phi2), .D(input_wip[31]), .Q(output_wip[31]), 
        .RN(n240) );
    DFA output_wip_reg_30 ( .C(phi2), .D(input_wip[30]), .Q(output_wip[30]), 
        .RN(n240) );
    DFA output_wip_reg_29 ( .C(phi2), .D(input_wip[29]), .Q(output_wip[29]), 
        .RN(n240) );
    DFA output_wip_reg_28 ( .C(phi2), .D(input_wip[28]), .Q(output_wip[28]), 
        .RN(n240) );
    DFA output_wip_reg_27 ( .C(phi2), .D(input_wip[27]), .Q(output_wip[27]), 
        .RN(n240) );
    DFA output_wip_reg_26 ( .C(phi2), .D(input_wip[26]), .Q(output_wip[26]), 
        .RN(n240) );
    DFA output_wip_reg_25 ( .C(phi2), .D(input_wip[25]), .Q(output_wip[25]), 
        .RN(n240) );
    DFA output_wip_reg_24 ( .C(phi2), .D(input_wip[24]), .Q(output_wip[24]), 
        .RN(n240) );
    DFA output_wip_reg_23 ( .C(phi2), .D(input_wip[23]), .Q(output_wip[23]), 
        .RN(n240) );
    DFA output_wip_reg_22 ( .C(phi2), .D(input_wip[22]), .Q(output_wip[22]), 
        .RN(n240) );
    DFA output_wip_reg_21 ( .C(phi2), .D(input_wip[21]), .Q(output_wip[21]), 
        .RN(n240) );
    DFA output_wip_reg_20 ( .C(phi2), .D(input_wip[20]), .Q(output_wip[20]), 
        .RN(n240) );
    DFA output_wip_reg_19 ( .C(phi2), .D(input_wip[19]), .Q(output_wip[19]), 
        .RN(n240) );
    DFA output_wip_reg_18 ( .C(phi2), .D(input_wip[18]), .Q(output_wip[18]), 
        .RN(n240) );
    DFA output_wip_reg_17 ( .C(phi2), .D(input_wip[17]), .Q(output_wip[17]), 
        .RN(n240) );
    DFA output_wip_reg_16 ( .C(phi2), .D(input_wip[16]), .Q(output_wip[16]), 
        .RN(n240) );
    DFA output_wip_reg_15 ( .C(phi2), .D(input_wip[15]), .Q(output_wip[15]), 
        .RN(n240) );
    DFA output_wip_reg_11 ( .C(phi2), .D(input_wip[11]), .Q(output_wip[11]), 
        .RN(n240) );
    DFA output_wip_reg_10 ( .C(phi2), .D(input_wip[10]), .Q(output_wip[10]), 
        .RN(n240) );
    DFA output_wip_reg_9 ( .C(phi2), .D(input_wip[9]), .Q(output_wip[9]), .RN(
        n240) );
    DFA output_wip_reg_8 ( .C(phi2), .D(input_wip[8]), .Q(output_wip[8]), .RN(
        n240) );
    DFA output_wip_reg_7 ( .C(phi2), .D(input_wip[7]), .Q(output_wip[7]), .RN(
        n240) );
    DFA output_wip_reg_1 ( .C(phi2), .D(input_wip[1]), .Q(output_wip[1]), .RN(
        n240) );
    DFA output_wip_reg_0 ( .C(phi2), .D(input_wip[0]), .Q(output_wip[0]), .RN(
        n240) );
    BU8 U147 ( .A(reset), .Q(n240) );
    BU4 U148 ( .A(n240), .Q(n248) );
    DFA output_wip_reg_4 ( .C(phi2), .D(input_wip[4]), .Q(output_wip[4]), .RN(
        n240) );
    DFA output_wip_reg_2 ( .C(phi2), .D(input_wip[2]), .Q(output_wip[2]), .RN(
        n240) );
    DFA output_wip_reg_5 ( .C(phi2), .D(input_wip[5]), .Q(output_wip[5]), .RN(
        n240) );
    DFA output_wip_reg_14 ( .C(phi2), .D(input_wip[14]), .Q(output_wip[14]), 
        .RN(n240) );
    DFA output_wip_reg_13 ( .C(phi2), .D(input_wip[13]), .Q(output_wip[13]), 
        .RN(n240) );
    DFA output_wip_reg_3 ( .C(phi2), .D(input_wip[3]), .Q(output_wip[3]), .RN(
        n240) );
    DFA output_wip_reg_6 ( .C(phi2), .D(input_wip[6]), .Q(output_wip[6]), .RN(
        n240) );
    DFA2 output_fcs_reg_18 ( .C(phi2), .D(input_fcs[18]), .Q(output_fcs[18]), 
        .RN(n240) );
    DFA2 output_fcs_reg_19 ( .C(phi2), .D(input_fcs[19]), .Q(output_fcs[19]), 
        .RN(n248) );
    DFA2 output_fcs_reg_17 ( .C(phi2), .D(input_fcs[17]), .Q(output_fcs[17]), 
        .RN(n240) );
endmodule


module gf_phi2_register_3 ( reset, phi2, input_wip, input_fcs, output_wip, 
    output_fcs );
output [31:0] output_fcs;
input  [31:0] input_wip;
input  [31:0] input_fcs;
output [31:0] output_wip;
input  reset, phi2;
    wire n268, n272, n314, n316, n320, n324, n328;
    DFA output_wip_reg_13 ( .C(phi2), .D(input_wip[13]), .Q(output_wip[13]), 
        .RN(n314) );
    DFA output_wip_reg_12 ( .C(phi2), .D(input_wip[12]), .Q(output_wip[12]), 
        .RN(n314) );
    DFA output_wip_reg_11 ( .C(phi2), .D(input_wip[11]), .Q(output_wip[11]), 
        .RN(n268) );
    DFA output_wip_reg_8 ( .C(phi2), .D(input_wip[8]), .Q(output_wip[8]), .RN(
        n268) );
    DFA output_wip_reg_7 ( .C(phi2), .D(input_wip[7]), .Q(output_wip[7]), .RN(
        n268) );
    DFA output_wip_reg_6 ( .C(phi2), .D(input_wip[6]), .Q(output_wip[6]), .RN(
        n314) );
    DFA output_wip_reg_4 ( .C(phi2), .D(input_wip[4]), .Q(output_wip[4]), .RN(
        n314) );
    DFA output_wip_reg_3 ( .C(phi2), .D(input_wip[3]), .Q(output_wip[3]), .RN(
        n272) );
    DFA output_wip_reg_1 ( .C(phi2), .D(input_wip[1]), .Q(output_wip[1]), .RN(
        n268) );
    DFA output_wip_reg_15 ( .C(phi2), .D(input_wip[15]), .Q(output_wip[15]), 
        .RN(n314) );
    DFA output_wip_reg_14 ( .C(phi2), .D(input_wip[14]), .Q(output_wip[14]), 
        .RN(n314) );
    DFA output_wip_reg_9 ( .C(phi2), .D(input_wip[9]), .Q(output_wip[9]), .RN(
        n268) );
    DFA output_wip_reg_5 ( .C(phi2), .D(input_wip[5]), .Q(output_wip[5]), .RN(
        n314) );
    DFA output_wip_reg_2 ( .C(phi2), .D(input_wip[2]), .Q(output_wip[2]), .RN(
        n314) );
    DFA2 output_fcs_reg_31 ( .C(phi2), .D(input_fcs[31]), .Q(output_fcs[31]), 
        .RN(n314) );
    DFA2 output_fcs_reg_30 ( .C(phi2), .D(input_fcs[30]), .Q(output_fcs[30]), 
        .RN(n272) );
    DFA2 output_fcs_reg_29 ( .C(phi2), .D(input_fcs[29]), .Q(output_fcs[29]), 
        .RN(n314) );
    DFA2 output_fcs_reg_28 ( .C(phi2), .D(input_fcs[28]), .Q(output_fcs[28]), 
        .RN(n268) );
    DFA2 output_fcs_reg_27 ( .C(phi2), .D(input_fcs[27]), .Q(output_fcs[27]), 
        .RN(n272) );
    DFA2 output_fcs_reg_26 ( .C(phi2), .D(input_fcs[26]), .Q(output_fcs[26]), 
        .RN(n314) );
    DFA2 output_fcs_reg_25 ( .C(phi2), .D(input_fcs[25]), .Q(output_fcs[25]), 
        .RN(n272) );
    DFA2 output_fcs_reg_24 ( .C(phi2), .D(input_fcs[24]), .Q(output_fcs[24]), 
        .RN(n314) );
    DFA2 output_fcs_reg_23 ( .C(phi2), .D(input_fcs[23]), .Q(output_fcs[23]), 
        .RN(n272) );
    DFA2 output_fcs_reg_15 ( .C(phi2), .D(input_fcs[15]), .Q(output_fcs[15]), 
        .RN(n314) );
    DFA2 output_fcs_reg_14 ( .C(phi2), .D(input_fcs[14]), .Q(output_fcs[14]), 
        .RN(n272) );
    DFA2 output_fcs_reg_13 ( .C(phi2), .D(input_fcs[13]), .Q(output_fcs[13]), 
        .RN(n268) );
    DFA2 output_fcs_reg_12 ( .C(phi2), .D(input_fcs[12]), .Q(output_fcs[12]), 
        .RN(n314) );
    DFA2 output_fcs_reg_11 ( .C(phi2), .D(input_fcs[11]), .Q(output_fcs[11]), 
        .RN(n272) );
    DFA2 output_fcs_reg_10 ( .C(phi2), .D(input_fcs[10]), .Q(output_fcs[10]), 
        .RN(n314) );
    DFA2 output_fcs_reg_9 ( .C(phi2), .D(input_fcs[9]), .Q(output_fcs[9]), 
        .RN(n314) );
    DFA2 output_fcs_reg_8 ( .C(phi2), .D(input_fcs[8]), .Q(output_fcs[8]), 
        .RN(n272) );
    DFA2 output_fcs_reg_6 ( .C(phi2), .D(input_fcs[6]), .Q(output_fcs[6]), 
        .RN(n272) );
    DFA2 output_fcs_reg_5 ( .C(phi2), .D(input_fcs[5]), .Q(output_fcs[5]), 
        .RN(n272) );
    DFA2 output_fcs_reg_4 ( .C(phi2), .D(input_fcs[4]), .Q(output_fcs[4]), 
        .RN(n268) );
    DFA2 output_fcs_reg_3 ( .C(phi2), .D(input_fcs[3]), .Q(output_fcs[3]), 
        .RN(n272) );
    DFA2 output_wip_reg_31 ( .C(phi2), .D(input_wip[31]), .Q(output_wip[31]), 
        .RN(n272) );
    DFA2 output_wip_reg_30 ( .C(phi2), .D(input_wip[30]), .Q(output_wip[30]), 
        .RN(n272) );
    DFA2 output_wip_reg_29 ( .C(phi2), .D(input_wip[29]), .Q(output_wip[29]), 
        .RN(n272) );
    DFA2 output_wip_reg_28 ( .C(phi2), .D(input_wip[28]), .Q(output_wip[28]), 
        .RN(n272) );
    DFA2 output_wip_reg_27 ( .C(phi2), .D(input_wip[27]), .Q(output_wip[27]), 
        .RN(n272) );
    DFA2 output_wip_reg_26 ( .C(phi2), .D(input_wip[26]), .Q(output_wip[26]), 
        .RN(n272) );
    DFA2 output_wip_reg_25 ( .C(phi2), .D(input_wip[25]), .Q(output_wip[25]), 
        .RN(n272) );
    DFA2 output_wip_reg_24 ( .C(phi2), .D(input_wip[24]), .Q(output_wip[24]), 
        .RN(n272) );
    DFA2 output_wip_reg_22 ( .C(phi2), .D(input_wip[22]), .Q(output_wip[22]), 
        .RN(n272) );
    DFA2 output_wip_reg_21 ( .C(phi2), .D(input_wip[21]), .Q(output_wip[21]), 
        .RN(n314) );
    DFA2 output_wip_reg_20 ( .C(phi2), .D(input_wip[20]), .Q(output_wip[20]), 
        .RN(n314) );
    DFA2 output_wip_reg_19 ( .C(phi2), .D(input_wip[19]), .Q(output_wip[19]), 
        .RN(n314) );
    DFA2 output_wip_reg_0 ( .C(phi2), .D(input_wip[0]), .Q(output_wip[0]), 
        .RN(n314) );
    BU4 U147 ( .A(n268), .Q(n314) );
    BU4 U148 ( .A(n268), .Q(n272) );
    BU2 U149 ( .A(reset), .Q(n268) );
    IN4 U150 ( .A(n316), .Q(output_fcs[19]) );
    DFA output_wip_reg_10 ( .C(phi2), .D(input_wip[10]), .Q(output_wip[10]), 
        .RN(n272) );
    DFA output_fcs_reg_20 ( .C(phi2), .D(input_fcs[20]), .Q(output_fcs[20]), 
        .RN(n314) );
    IN4 U151 ( .A(n320), .Q(output_fcs[17]) );
    IN4 U152 ( .A(n324), .Q(output_fcs[16]) );
    DFA2 output_fcs_reg_21 ( .C(phi2), .D(input_fcs[21]), .Q(output_fcs[21]), 
        .RN(n314) );
    IN4 U153 ( .A(n328), .Q(output_fcs[18]) );
    DFA output_wip_reg_23 ( .C(phi2), .D(input_wip[23]), .Q(output_wip[23]), 
        .RN(n272) );
    DFA output_wip_reg_18 ( .C(phi2), .D(input_wip[18]), .Q(output_wip[18]), 
        .RN(n314) );
    DFA output_wip_reg_17 ( .C(phi2), .D(input_wip[17]), .Q(output_wip[17]), 
        .RN(n272) );
    DFA output_wip_reg_16 ( .C(phi2), .D(input_wip[16]), .Q(output_wip[16]), 
        .RN(n314) );
    DFA output_fcs_reg_7 ( .C(phi2), .D(input_fcs[7]), .Q(output_fcs[7]), .RN(
        n314) );
    DFA output_fcs_reg_2 ( .C(phi2), .D(input_fcs[2]), .Q(output_fcs[2]), .RN(
        n314) );
    DFA output_fcs_reg_1 ( .C(phi2), .D(input_fcs[1]), .Q(output_fcs[1]), .RN(
        n272) );
    DFA output_fcs_reg_0 ( .C(phi2), .D(input_fcs[0]), .Q(output_fcs[0]), .RN(
        n272) );
    DFA2 output_fcs_reg_22 ( .C(phi2), .D(input_fcs[22]), .Q(output_fcs[22]), 
        .RN(n314) );
    DFA2 output_fcs_reg_19 ( .C(phi2), .D(input_fcs[19]), .QN(n316), .RN(n272)
         );
    DFA2 output_fcs_reg_17 ( .C(phi2), .D(input_fcs[17]), .QN(n320), .RN(n314)
         );
    DFA2 output_fcs_reg_16 ( .C(phi2), .D(input_fcs[16]), .QN(n324), .RN(n272)
         );
    DFA2 output_fcs_reg_18 ( .C(phi2), .D(input_fcs[18]), .QN(n328), .RN(n268)
         );
endmodule


module gf_multiplier ( reset, phi1, phi2, \input , output_fcs, output_xor );
output [15:0] output_fcs;
input  [31:0] \input ;
output [15:0] output_xor;
input  reset, phi1, phi2;
    wire btw1x_2_7, btw2x_3_4, btw3_4_29, btw3_3x_14, btw6_7_7, btw7_8_0, 
        btw7x_8_3, btw9_9x_31, btw9_9x_16, btw8x_9_26, btw7x_8_27, btw1x_2_20, 
        btw4x_5_28, btw6x_7_21, btw7_7x_16, btw7_7x_31, btw2_3_23, btw3x_4_21, 
        btw5_5x_14, btw8_9_26, btw4_4x_11, btw4_4x_2, btw6_6x_13, btw9_10_0, 
        btw4x_5_7, btw5x_6_5, btw6x_7_6, btw9_10_10, btw5_6_11, btw7_8_12, 
        btw9x_10_7, btw1x_2_29, btw2_3_6, btw3_4_15, btw3_4_0, btw4_5_13, 
        btw4x_5_14, btw5_5x_28, btw8_9_5, btw2_2x_24, btw2_2x_11, btw2x_3_10, 
        btw3_3x_28, btw5x_6_11, btw6_6x_2, btw3_3x_1, btw3x_4_0, btw6_7_13, 
        btw8_8x_13, btw9_9x_4, btw9x_10_20, btw7_8_9, btw9x_10_15, btw2x_3_25, 
        btw6_7_26, btw8_8x_26, btw4_5_26, btw5x_6_24, btw4x_5_21, btw6x_7_28, 
        btw3_4_20, btw1x_2_15, btw2_3_31, btw2_3_16, btw3x_4_28, btw4_5_4, 
        btw5_6_24, btw7_8_27, btw4_4x_24, btw6_6x_26, btw8x_9_3, btw9_10_25, 
        btw4_4x_18, btw3_4_9, btw3x_4_14, btw9_10_19, btw9_10_9, btw7_7x_4, 
        btw8_9_13, btw8_8x_2, btw5_5x_21, btw2_3_11, btw2_3_8, btw2_2x_18, 
        btw2_2x_7, btw7_7x_23, btw2x_3_19, btw3_3x_8, btw5_6_18, btw6x_7_14, 
        btw7x_8_12, btw3x_4_9, btw3_3x_21, btw5_6_4, btw5x_6_18, btw8x_9_13, 
        btw5_6_3, btw5_5x_4, btw9x_10_29, btw8x_9_14, btw9_9x_23, btw3_3x_26, 
        btw3x_4_13, btw5_5x_3, btw8_8x_5, btw9_9x_24, btw4x_5_9, btw6x_7_8, 
        btw7x_8_15, btw9x_10_9, btw1x_2_12, btw2_2x_0, btw6x_7_13, btw7_7x_24, 
        btw3_4_27, btw5_6_23, btw5_5x_26, btw7_7x_3, btw7x_8_29, btw8_9_14, 
        btw1x_2_9, btw4_5_21, btw4x_5_26, btw7_7x_18, btw8_9_28, btw4_5_3, 
        btw4_4x_23, btw6_6x_21, btw8x_9_4, btw9_10_22, btw7_8_20, btw2_3_1, 
        btw2_2x_23, btw6_7_21, btw9_9x_18, btw2x_3_30, btw2x_3_22, btw5x_6_23, 
        btw8x_9_28, btw9x_10_12, btw6_7_9, btw2x_3_17, btw3_3x_6, btw8_8x_21, 
        btw3x_4_7, btw5x_6_31, btw8_8x_14, btw6_6x_5, btw5x_6_16, btw2_2x_31, 
        btw2_2x_16, btw6_7_14, btw9_9x_3, btw9x_10_27, btw2_3_18, btw7_8_15, 
        btw9x_10_0, btw2_2x_9, btw3_4_7, btw4_4x_31, btw4_4x_16, btw4x_5_0, 
        btw9_10_30, btw4_4x_5, btw5x_6_2, btw9_10_17, btw6_6x_14, btw6x_7_1, 
        btw9_10_7, btw4_5_14, btw5_6_31, btw8_9_2, btw4x_5_13, btw3_4_12, 
        btw1x_2_27, btw4_5_28, btw5_6_16, btw5_5x_13, btw8_9_21, btw6x_7_26, 
        btw7_7x_11, btw7x_8_20, btw1x_2_8, btw1x_2_0, btw2_3_24, btw7_8_29, 
        btw2x_3_3, btw3x_4_26, btw6_7_28, btw6_6x_28, btw7_8_7, btw7x_8_4, 
        btw9_9x_11, btw3_3x_13, btw8_8x_28, btw6_7_0, btw8x_9_21, btw2_2x_22, 
        btw6_7_20, btw9_9x_19, btw9x_10_13, btw2x_3_23, btw5x_6_22, btw6_7_8, 
        btw8x_9_29, btw5_6_22, btw7x_8_28, btw8_8x_20, btw1x_2_26, btw1x_2_13, 
        btw2_3_10, btw3_4_26, btw3x_4_12, btw4_5_20, btw4x_5_27, btw7_7x_19, 
        btw4_5_2, btw4_4x_22, btw6_6x_20, btw8_9_29, btw8x_9_5, btw9_10_23, 
        btw7_8_21, btw6x_7_9, btw8_8x_4, btw2_2x_1, btw4x_5_8, btw7_7x_25, 
        btw7x_8_14, btw9x_10_8, btw6x_7_12, btw1x_2_1, btw2_3_9, btw5_6_2, 
        btw5_5x_27, btw7_7x_2, btw8_9_15, btw8x_9_15, btw2x_3_2, btw3_3x_27, 
        btw5_5x_2, btw6_7_29, btw7_8_6, btw9_9x_25, btw7x_8_5, btw9_9x_10, 
        btw3_3x_12, btw8_8x_29, btw4_5_29, btw6_7_1, btw8_9_20, btw8x_9_20, 
        btw5_5x_12, btw6x_7_27, btw7_7x_10, btw7x_8_21, btw2_3_25, btw7_8_28, 
        btw2_3_19, btw3x_4_27, btw4x_5_1, btw6_6x_29, btw7_8_14, btw9x_10_1, 
        btw9_10_31, btw2_2x_8, btw3_4_6, btw4_5_15, btw4_4x_30, btw4_4x_17, 
        btw9_10_16, btw4_4x_4, btw6_6x_15, btw9_10_6, btw5_6_30, btw5x_6_3, 
        btw6x_7_0, btw4x_5_12, btw8_9_3, btw2_3_7, btw2_3_0, btw2x_3_16, 
        btw3_4_13, btw3_3x_7, btw3x_4_6, btw5_6_17, btw5x_6_30, btw8_8x_15, 
        btw2_2x_30, btw2_2x_17, btw2x_3_31, btw6_6x_4, btw5x_6_17, btw9x_10_26, 
        btw6_7_15, btw9_9x_2, btw5x_6_10, btw6_6x_3, btw2_2x_10, btw2x_3_11, 
        btw3_3x_29, btw3_3x_0, btw3x_4_1, btw6_7_12, btw8_8x_12, btw9_9x_5, 
        btw3_4_14, btw4_4x_10, btw4_4x_3, btw5x_6_4, btw9x_10_21, btw6_6x_12, 
        btw6x_7_7, btw9_10_1, btw9_10_11, btw4x_5_6, btw5_6_10, btw7_8_13, 
        btw9x_10_6, btw3_4_28, btw3_4_1, btw4x_5_15, btw8_9_4, btw4_5_12, 
        btw5_5x_29, btw7x_8_26, btw1x_2_28, btw1x_2_21, btw6x_7_20, btw7_7x_17, 
        btw1x_2_14, btw1x_2_6, btw2_3_22, btw3x_4_20, btw4x_5_29, btw5_5x_15, 
        btw7_7x_30, btw8_9_27, btw2x_3_5, btw2_3_30, btw2_3_17, btw2_2x_19, 
        btw2x_3_18, btw3_3x_20, btw3_3x_15, btw6_7_6, btw7_8_1, btw7x_8_2, 
        btw9_9x_30, btw9_9x_17, btw8x_9_27, btw3_3x_9, btw3x_4_8, btw5_6_5, 
        btw5x_6_19, btw8x_9_12, btw9x_10_28, btw4_4x_19, btw5_5x_5, btw9_9x_22, 
        btw9_10_18, btw3_4_8, btw3x_4_15, btw5_5x_20, btw8_8x_3, btw9_10_8, 
        btw7_7x_5, btw8_9_12, btw2_2x_6, btw4_5_27, btw5_6_19, btw6x_7_15, 
        btw7_7x_22, btw7x_8_13, btw4x_5_20, btw3_4_21, btw6x_7_29, btw5_6_25, 
        btw1x_2_23, btw1x_2_4, btw2_2x_25, btw3x_4_29, btw4_5_5, btw4_4x_25, 
        btw7_8_26, btw6_6x_27, btw8x_9_2, btw9_10_24, btw2x_3_24, btw6_7_27, 
        btw7_8_8, btw9x_10_14, btw8_8x_27, btw2x_3_7, btw3_3x_30, btw3_3x_17, 
        btw5x_6_25, btw6_7_4, btw8x_9_25, btw7_8_3, btw9_9x_15, btw7x_8_0, 
        btw2_3_20, btw3x_4_22, btw8x_9_9, btw5_5x_17, btw8_9_25, btw7x_8_24, 
        btw3_4_31, btw4x_5_17, btw5_5x_30, btw6x_7_22, btw7_7x_15, btw3_4_16, 
        btw3_4_3, btw4_5_10, btw8_9_19, btw8_9_6, btw2_3_29, btw2_3_5, 
        btw2_2x_12, btw4_4x_12, btw4x_5_30, btw5_6_12, btw7x_8_18, btw7_7x_29, 
        btw4x_5_4, btw4_4x_1, btw5x_6_6, btw6_6x_10, btw7_8_11, btw9x_10_4, 
        btw8_8x_8, btw6_7_10, btw6x_7_5, btw9_10_3, btw9_10_13, btw9_9x_7, 
        btw9_9x_29, btw2x_3_13, btw9x_10_23, btw3_3x_2, btw3x_4_3, btw8_8x_10, 
        btw8x_9_19, btw2_2x_27, btw2x_3_26, btw5x_6_27, btw5x_6_12, btw6_6x_1, 
        btw8_8x_25, btw7x_8_9, btw9x_10_31, btw4_5_7, btw6_7_25, btw9x_10_16, 
        btw6_6x_25, btw8x_9_0, btw9_10_26, btw7_8_24, btw4_4x_27, btw3_4_23, 
        btw5_6_27, btw1x_2_31, btw4_5_25, btw4x_5_22, btw7_7x_20, btw2_2x_4, 
        btw6x_7_17, btw1x_2_16, btw4_5_19, btw5_5x_22, btw7_7x_7, btw7x_8_11, 
        btw8_9_10, btw6x_7_30, btw1x_2_11, btw2_3_15, btw3x_4_30, btw3x_4_17, 
        btw4_4x_8, btw6_6x_19, btw8_8x_1, btw7_8_18, btw3_3x_25, btw3_3x_22, 
        btw5_6_7, btw5_5x_7, btw6_7_19, btw9_9x_20, btw6_6x_8, btw8_8x_19, 
        btw8x_9_10, btw5_5x_0, btw9_9x_9, btw9_9x_27, btw5_6_0, btw8x_9_30, 
        btw8x_9_17, btw2_3_12, btw2_2x_3, btw3_4_18, btw4x_5_19, btw5_5x_25, 
        btw7x_8_31, btw7_7x_0, btw8_9_17, btw8_9_8, btw7x_8_16, btw8_9_30, 
        btw6x_7_10, btw7_7x_27, btw3x_4_10, btw4_5_22, btw4_5_0, btw4_4x_20, 
        btw5x_6_8, btw8_8x_6, btw4x_5_25, btw6_6x_22, btw7_8_23, btw8x_9_7, 
        btw9_10_21, btw5_5x_19, btw2_3_2, btw2_2x_20, btw2x_3_21, btw3_4_24, 
        btw5_6_20, btw3_3x_19, btw5x_6_20, btw8_8x_22, btw6_7_22, btw9x_10_11, 
        btw2_2x_15, btw2x_3_9, btw6_7_30, btw9x_10_24, btw5_5x_9, btw5x_6_15, 
        btw6_7_17, btw9_9x_0, btw6_6x_6, btw2x_3_14, btw3_3x_5, btw3x_4_4, 
        btw5_6_9, btw8_8x_30, btw8_8x_17, btw4_5_30, btw6x_7_19, btw5_6_15, 
        btw3_4_11, btw3_4_4, btw7_7x_9, btw8_9_1, btw4_5_17, btw1x_2_18, 
        btw4x_5_10, btw2_3_27, btw3x_4_25, btw3x_4_19, btw4_4x_6, btw9_10_14, 
        btw9_10_4, btw5x_6_1, btw6x_7_2, btw4_4x_15, btw6_6x_30, btw6_6x_17, 
        btw7_8_31, btw7_8_16, btw9x_10_3, btw4x_5_3, btw9_10_28, btw4_5_9, 
        btw4_4x_29, btw5_6_29, btw6x_7_25, btw7_7x_12, btw7x_8_23, btw1x_2_24, 
        btw5_5x_10, btw8_9_22, btw1x_2_3, btw2x_3_28, btw3_3x_10, btw5x_6_29, 
        btw6_7_3, btw8x_9_22, btw2x_3_0, btw2_2x_29, btw7_8_4, btw7x_8_7, 
        btw2_2x_21, btw2x_3_20, btw3_3x_18, btw9_9x_12, btw9x_10_18, 
        btw5x_6_21, btw8_8x_23, btw6_7_23, btw2x_3_8, btw9x_10_10, btw3_4_25, 
        btw4_5_23, btw4_5_1, btw4_4x_21, btw7_8_22, btw4x_5_24, btw6_6x_23, 
        btw8x_9_6, btw9_10_20, btw5_5x_18, btw1x_2_10, btw4x_5_18, btw5_6_21, 
        btw1x_2_2, btw2_3_13, btw2_2x_2, btw3_4_19, btw5_5x_24, btw7_7x_1, 
        btw8_9_16, btw8_9_9, btw7x_8_30, btw7x_8_17, btw8_9_31, btw7_7x_26, 
        btw6x_7_11, btw2x_3_29, btw3_3x_24, btw3x_4_11, btw5x_6_9, btw5_5x_1, 
        btw8_8x_7, btw9_9x_26, btw9_9x_8, btw5_6_1, btw8x_9_31, btw5x_6_28, 
        btw8x_9_16, btw6_7_2, btw8x_9_23, btw2x_3_1, btw3_3x_11, btw2_3_26, 
        btw2_2x_28, btw9x_10_19, btw3x_4_24, btw7_8_5, btw7x_8_6, btw9_10_29, 
        btw9_9x_13, btw4_5_8, btw4_4x_28, btw6x_7_24, btw7_7x_13, btw7x_8_22, 
        btw1x_2_25, btw5_6_28, btw5_5x_11, btw8_9_23, btw3_4_10, btw4_5_31, 
        btw6x_7_18, btw5_6_14, btw4_5_16, btw1x_2_19, btw3_4_5, btw7_7x_8, 
        btw8_9_0, btw2_3_4, btw2_3_3, btw2_2x_14, btw3x_4_18, btw4x_5_11, 
        btw7_8_30, btw9_10_15, btw4_4x_14, btw4_4x_7, btw5x_6_0, btw6_6x_16, 
        btw4x_5_2, btw6_6x_31, btw6x_7_3, btw9_10_5, btw7_8_17, btw9x_10_2, 
        btw6_7_31, btw5_5x_8, btw6_7_16, btw9x_10_25, btw9_9x_1, btw2_2x_13, 
        btw2x_3_15, btw3_3x_4, btw5_6_8, btw5x_6_14, btw6_6x_7, btw8_8x_31, 
        btw3x_4_5, btw8_8x_16, btw6_7_11, btw9_9x_28, btw9_9x_6, btw9x_10_22, 
        btw2x_3_12, btw3_3x_3, btw3x_4_2, btw5x_6_13, btw6_6x_0, btw8_8x_11, 
        btw8x_9_18, btw3_4_30, btw3_4_2, btw4x_5_16, btw8_9_18, btw8_9_7, 
        btw4_5_11, btw1x_2_22, btw2_3_21, btw3_4_17, btw4_4x_13, btw4x_5_31, 
        btw5_6_13, btw7x_8_19, btw7_7x_28, btw4_4x_0, btw4x_5_5, btw7_8_10, 
        btw9x_10_5, btw9_10_2, btw5x_6_7, btw6_6x_11, btw6x_7_4, btw8_8x_9, 
        btw9_10_12, btw3x_4_23, btw8x_9_8, btw5_5x_16, btw7x_8_25, btw8_9_24, 
        btw1x_2_30, btw1x_2_5, btw2x_3_6, btw3_3x_31, btw3_3x_16, btw5_5x_31, 
        btw6x_7_23, btw7_7x_14, btw8x_9_24, btw6_7_5, btw7_8_2, btw9_9x_14, 
        btw7x_8_1, btw2_2x_5, btw3_3x_23, btw5_6_6, btw5_5x_6, btw6_7_18, 
        btw6_6x_9, btw9_9x_21, btw8x_9_11, btw8_8x_18, btw6x_7_16, btw7_7x_21, 
        btw1x_2_17, btw4_5_18, btw5_5x_23, btw7x_8_10, btw6x_7_31, btw7_7x_6, 
        btw8_9_11, btw2_3_28, btw2_3_14, btw3x_4_31, btw3x_4_16, btw6_6x_18, 
        btw8_8x_0, btw4_4x_9, btw7_8_19, btw4_5_6, btw6_6x_24, btw8x_9_1, 
        btw9_10_27, btw4_4x_26, btw7_8_25, btw5_6_26, btw2_2x_26, btw2x_3_27, 
        btw3_4_22, btw4_5_24, btw4x_5_23, btw5x_6_26, btw8_8x_24, btw9x_10_30, 
        btw9x_10_17, btw6_7_24, btw7x_8_8;
    gf_xor_input GF1x ( .input_fcs(\input ), .output_wip({btw1x_2_31, 
        btw1x_2_30, btw1x_2_29, btw1x_2_28, btw1x_2_27, btw1x_2_26, btw1x_2_25, 
        btw1x_2_24, btw1x_2_23, btw1x_2_22, btw1x_2_21, btw1x_2_20, btw1x_2_19, 
        btw1x_2_18, btw1x_2_17, btw1x_2_16, btw1x_2_15, btw1x_2_14, btw1x_2_13, 
        btw1x_2_12, btw1x_2_11, btw1x_2_10, btw1x_2_9, btw1x_2_8, btw1x_2_7, 
        btw1x_2_6, btw1x_2_5, btw1x_2_4, btw1x_2_3, btw1x_2_2, btw1x_2_1, 
        btw1x_2_0}) );
    gf_xor_2x GF2x ( .input_wip({btw2_2x_31, btw2_2x_30, btw2_2x_29, 
        btw2_2x_28, btw2_2x_27, btw2_2x_26, btw2_2x_25, btw2_2x_24, btw2_2x_23, 
        btw2_2x_22, btw2_2x_21, btw2_2x_20, btw2_2x_19, btw2_2x_18, btw2_2x_17, 
        btw2_2x_16, btw2_2x_15, btw2_2x_14, btw2_2x_13, btw2_2x_12, btw2_2x_11, 
        btw2_2x_10, btw2_2x_9, btw2_2x_8, btw2_2x_7, btw2_2x_6, btw2_2x_5, 
        btw2_2x_4, btw2_2x_3, btw2_2x_2, btw2_2x_1, btw2_2x_0}), .input_fcs({
        btw2_3_31, btw2_3_30, btw2_3_29, btw2_3_28, btw2_3_27, btw2_3_26, 
        btw2_3_25, btw2_3_24, btw2_3_23, btw2_3_22, btw2_3_21, btw2_3_20, 
        btw2_3_19, btw2_3_18, btw2_3_17, btw2_3_16, btw2_3_15, btw2_3_14, 
        btw2_3_13, btw2_3_12, btw2_3_11, btw2_3_10, btw2_3_9, btw2_3_8, 
        btw2_3_7, btw2_3_6, btw2_3_5, btw2_3_4, btw2_3_3, btw2_3_2, btw2_3_1, 
        btw2_3_0}), .output_wip({btw2x_3_31, btw2x_3_30, btw2x_3_29, 
        btw2x_3_28, btw2x_3_27, btw2x_3_26, btw2x_3_25, btw2x_3_24, btw2x_3_23, 
        btw2x_3_22, btw2x_3_21, btw2x_3_20, btw2x_3_19, btw2x_3_18, btw2x_3_17, 
        btw2x_3_16, btw2x_3_15, btw2x_3_14, btw2x_3_13, btw2x_3_12, btw2x_3_11, 
        btw2x_3_10, btw2x_3_9, btw2x_3_8, btw2x_3_7, btw2x_3_6, btw2x_3_5, 
        btw2x_3_4, btw2x_3_3, btw2x_3_2, btw2x_3_1, btw2x_3_0}) );
    gf_phi1_register_3 GF6 ( .reset(reset), .phi1(phi1), .input_wip({
        btw5x_6_31, btw5x_6_30, btw5x_6_29, btw5x_6_28, btw5x_6_27, btw5x_6_26, 
        btw5x_6_25, btw5x_6_24, btw5x_6_23, btw5x_6_22, btw5x_6_21, btw5x_6_20, 
        btw5x_6_19, btw5x_6_18, btw5x_6_17, btw5x_6_16, btw5x_6_15, btw5x_6_14, 
        btw5x_6_13, btw5x_6_12, btw5x_6_11, btw5x_6_10, btw5x_6_9, btw5x_6_8, 
        btw5x_6_7, btw5x_6_6, btw5x_6_5, btw5x_6_4, btw5x_6_3, btw5x_6_2, 
        btw5x_6_1, btw5x_6_0}), .input_fcs({btw5_6_31, btw5_6_30, btw5_6_29, 
        btw5_6_28, btw5_6_27, btw5_6_26, btw5_6_25, btw5_6_24, btw5_6_23, 
        btw5_6_22, btw5_6_21, btw5_6_20, btw5_6_19, btw5_6_18, btw5_6_17, 
        btw5_6_16, btw5_6_15, btw5_6_14, btw5_6_13, btw5_6_12, btw5_6_11, 
        btw5_6_10, btw5_6_9, btw5_6_8, btw5_6_7, btw5_6_6, btw5_6_5, btw5_6_4, 
        btw5_6_3, btw5_6_2, btw5_6_1, btw5_6_0}), .output_wip({btw6_6x_31, 
        btw6_6x_30, btw6_6x_29, btw6_6x_28, btw6_6x_27, btw6_6x_26, btw6_6x_25, 
        btw6_6x_24, btw6_6x_23, btw6_6x_22, btw6_6x_21, btw6_6x_20, btw6_6x_19, 
        btw6_6x_18, btw6_6x_17, btw6_6x_16, btw6_6x_15, btw6_6x_14, btw6_6x_13, 
        btw6_6x_12, btw6_6x_11, btw6_6x_10, btw6_6x_9, btw6_6x_8, btw6_6x_7, 
        btw6_6x_6, btw6_6x_5, btw6_6x_4, btw6_6x_3, btw6_6x_2, btw6_6x_1, 
        btw6_6x_0}), .output_fcs({btw6_7_31, btw6_7_30, btw6_7_29, btw6_7_28, 
        btw6_7_27, btw6_7_26, btw6_7_25, btw6_7_24, btw6_7_23, btw6_7_22, 
        btw6_7_21, btw6_7_20, btw6_7_19, btw6_7_18, btw6_7_17, btw6_7_16, 
        btw6_7_15, btw6_7_14, btw6_7_13, btw6_7_12, btw6_7_11, btw6_7_10, 
        btw6_7_9, btw6_7_8, btw6_7_7, btw6_7_6, btw6_7_5, btw6_7_4, btw6_7_3, 
        btw6_7_2, btw6_7_1, btw6_7_0}) );
    gf_phi1_register_2 GF8 ( .reset(reset), .phi1(phi1), .input_wip({
        btw7x_8_31, btw7x_8_30, btw7x_8_29, btw7x_8_28, btw7x_8_27, btw7x_8_26, 
        btw7x_8_25, btw7x_8_24, btw7x_8_23, btw7x_8_22, btw7x_8_21, btw7x_8_20, 
        btw7x_8_19, btw7x_8_18, btw7x_8_17, btw7x_8_16, btw7x_8_15, btw7x_8_14, 
        btw7x_8_13, btw7x_8_12, btw7x_8_11, btw7x_8_10, btw7x_8_9, btw7x_8_8, 
        btw7x_8_7, btw7x_8_6, btw7x_8_5, btw7x_8_4, btw7x_8_3, btw7x_8_2, 
        btw7x_8_1, btw7x_8_0}), .input_fcs({btw7_8_31, btw7_8_30, btw7_8_29, 
        btw7_8_28, btw7_8_27, btw7_8_26, btw7_8_25, btw7_8_24, btw7_8_23, 
        btw7_8_22, btw7_8_21, btw7_8_20, btw7_8_19, btw7_8_18, btw7_8_17, 
        btw7_8_16, btw7_8_15, btw7_8_14, btw7_8_13, btw7_8_12, btw7_8_11, 
        btw7_8_10, btw7_8_9, btw7_8_8, btw7_8_7, btw7_8_6, btw7_8_5, btw7_8_4, 
        btw7_8_3, btw7_8_2, btw7_8_1, btw7_8_0}), .output_wip({btw8_8x_31, 
        btw8_8x_30, btw8_8x_29, btw8_8x_28, btw8_8x_27, btw8_8x_26, btw8_8x_25, 
        btw8_8x_24, btw8_8x_23, btw8_8x_22, btw8_8x_21, btw8_8x_20, btw8_8x_19, 
        btw8_8x_18, btw8_8x_17, btw8_8x_16, btw8_8x_15, btw8_8x_14, btw8_8x_13, 
        btw8_8x_12, btw8_8x_11, btw8_8x_10, btw8_8x_9, btw8_8x_8, btw8_8x_7, 
        btw8_8x_6, btw8_8x_5, btw8_8x_4, btw8_8x_3, btw8_8x_2, btw8_8x_1, 
        btw8_8x_0}), .output_fcs({btw8_9_31, btw8_9_30, btw8_9_29, btw8_9_28, 
        btw8_9_27, btw8_9_26, btw8_9_25, btw8_9_24, btw8_9_23, btw8_9_22, 
        btw8_9_21, btw8_9_20, btw8_9_19, btw8_9_18, btw8_9_17, btw8_9_16, 
        btw8_9_15, btw8_9_14, btw8_9_13, btw8_9_12, btw8_9_11, btw8_9_10, 
        btw8_9_9, btw8_9_8, btw8_9_7, btw8_9_6, btw8_9_5, btw8_9_4, btw8_9_3, 
        btw8_9_2, btw8_9_1, btw8_9_0}) );
    gf_xor_6x GF6x ( .input_wip({btw6_6x_31, btw6_6x_30, btw6_6x_29, 
        btw6_6x_28, btw6_6x_27, btw6_6x_26, btw6_6x_25, btw6_6x_24, btw6_6x_23, 
        btw6_6x_22, btw6_6x_21, btw6_6x_20, btw6_6x_19, btw6_6x_18, btw6_6x_17, 
        btw6_6x_16, btw6_6x_15, btw6_6x_14, btw6_6x_13, btw6_6x_12, btw6_6x_11, 
        btw6_6x_10, btw6_6x_9, btw6_6x_8, btw6_6x_7, btw6_6x_6, btw6_6x_5, 
        btw6_6x_4, btw6_6x_3, btw6_6x_2, btw6_6x_1, btw6_6x_0}), .input_fcs({
        btw6_7_31, btw6_7_30, btw6_7_29, btw6_7_28, btw6_7_27, btw6_7_26, 
        btw6_7_25, btw6_7_24, btw6_7_23, btw6_7_22, btw6_7_21, btw6_7_20, 
        btw6_7_19, btw6_7_18, btw6_7_17, btw6_7_16, btw6_7_15, btw6_7_14, 
        btw6_7_13, btw6_7_12, btw6_7_11, btw6_7_10, btw6_7_9, btw6_7_8, 
        btw6_7_7, btw6_7_6, btw6_7_5, btw6_7_4, btw6_7_3, btw6_7_2, btw6_7_1, 
        btw6_7_0}), .output_wip({btw6x_7_31, btw6x_7_30, btw6x_7_29, 
        btw6x_7_28, btw6x_7_27, btw6x_7_26, btw6x_7_25, btw6x_7_24, btw6x_7_23, 
        btw6x_7_22, btw6x_7_21, btw6x_7_20, btw6x_7_19, btw6x_7_18, btw6x_7_17, 
        btw6x_7_16, btw6x_7_15, btw6x_7_14, btw6x_7_13, btw6x_7_12, btw6x_7_11, 
        btw6x_7_10, btw6x_7_9, btw6x_7_8, btw6x_7_7, btw6x_7_6, btw6x_7_5, 
        btw6x_7_4, btw6x_7_3, btw6x_7_2, btw6x_7_1, btw6x_7_0}) );
    gf_phi2_register_3 GF7 ( .reset(reset), .phi2(phi2), .input_wip({
        btw6x_7_31, btw6x_7_30, btw6x_7_29, btw6x_7_28, btw6x_7_27, btw6x_7_26, 
        btw6x_7_25, btw6x_7_24, btw6x_7_23, btw6x_7_22, btw6x_7_21, btw6x_7_20, 
        btw6x_7_19, btw6x_7_18, btw6x_7_17, btw6x_7_16, btw6x_7_15, btw6x_7_14, 
        btw6x_7_13, btw6x_7_12, btw6x_7_11, btw6x_7_10, btw6x_7_9, btw6x_7_8, 
        btw6x_7_7, btw6x_7_6, btw6x_7_5, btw6x_7_4, btw6x_7_3, btw6x_7_2, 
        btw6x_7_1, btw6x_7_0}), .input_fcs({btw6_7_31, btw6_7_30, btw6_7_29, 
        btw6_7_28, btw6_7_27, btw6_7_26, btw6_7_25, btw6_7_24, btw6_7_23, 
        btw6_7_22, btw6_7_21, btw6_7_20, btw6_7_19, btw6_7_18, btw6_7_17, 
        btw6_7_16, btw6_7_15, btw6_7_14, btw6_7_13, btw6_7_12, btw6_7_11, 
        btw6_7_10, btw6_7_9, btw6_7_8, btw6_7_7, btw6_7_6, btw6_7_5, btw6_7_4, 
        btw6_7_3, btw6_7_2, btw6_7_1, btw6_7_0}), .output_wip({btw7_7x_31, 
        btw7_7x_30, btw7_7x_29, btw7_7x_28, btw7_7x_27, btw7_7x_26, btw7_7x_25, 
        btw7_7x_24, btw7_7x_23, btw7_7x_22, btw7_7x_21, btw7_7x_20, btw7_7x_19, 
        btw7_7x_18, btw7_7x_17, btw7_7x_16, btw7_7x_15, btw7_7x_14, btw7_7x_13, 
        btw7_7x_12, btw7_7x_11, btw7_7x_10, btw7_7x_9, btw7_7x_8, btw7_7x_7, 
        btw7_7x_6, btw7_7x_5, btw7_7x_4, btw7_7x_3, btw7_7x_2, btw7_7x_1, 
        btw7_7x_0}), .output_fcs({btw7_8_31, btw7_8_30, btw7_8_29, btw7_8_28, 
        btw7_8_27, btw7_8_26, btw7_8_25, btw7_8_24, btw7_8_23, btw7_8_22, 
        btw7_8_21, btw7_8_20, btw7_8_19, btw7_8_18, btw7_8_17, btw7_8_16, 
        btw7_8_15, btw7_8_14, btw7_8_13, btw7_8_12, btw7_8_11, btw7_8_10, 
        btw7_8_9, btw7_8_8, btw7_8_7, btw7_8_6, btw7_8_5, btw7_8_4, btw7_8_3, 
        btw7_8_2, btw7_8_1, btw7_8_0}) );
    gf_xor_4x GF4x ( .input_wip({btw4_4x_31, btw4_4x_30, btw4_4x_29, 
        btw4_4x_28, btw4_4x_27, btw4_4x_26, btw4_4x_25, btw4_4x_24, btw4_4x_23, 
        btw4_4x_22, btw4_4x_21, btw4_4x_20, btw4_4x_19, btw4_4x_18, btw4_4x_17, 
        btw4_4x_16, btw4_4x_15, btw4_4x_14, btw4_4x_13, btw4_4x_12, btw4_4x_11, 
        btw4_4x_10, btw4_4x_9, btw4_4x_8, btw4_4x_7, btw4_4x_6, btw4_4x_5, 
        btw4_4x_4, btw4_4x_3, btw4_4x_2, btw4_4x_1, btw4_4x_0}), .input_fcs({
        btw4_5_31, btw4_5_30, btw4_5_29, btw4_5_28, btw4_5_27, btw4_5_26, 
        btw4_5_25, btw4_5_24, btw4_5_23, btw4_5_22, btw4_5_21, btw4_5_20, 
        btw4_5_19, btw4_5_18, btw4_5_17, btw4_5_16, btw4_5_15, btw4_5_14, 
        btw4_5_13, btw4_5_12, btw4_5_11, btw4_5_10, btw4_5_9, btw4_5_8, 
        btw4_5_7, btw4_5_6, btw4_5_5, btw4_5_4, btw4_5_3, btw4_5_2, btw4_5_1, 
        btw4_5_0}), .output_wip({btw4x_5_31, btw4x_5_30, btw4x_5_29, 
        btw4x_5_28, btw4x_5_27, btw4x_5_26, btw4x_5_25, btw4x_5_24, btw4x_5_23, 
        btw4x_5_22, btw4x_5_21, btw4x_5_20, btw4x_5_19, btw4x_5_18, btw4x_5_17, 
        btw4x_5_16, btw4x_5_15, btw4x_5_14, btw4x_5_13, btw4x_5_12, btw4x_5_11, 
        btw4x_5_10, btw4x_5_9, btw4x_5_8, btw4x_5_7, btw4x_5_6, btw4x_5_5, 
        btw4x_5_4, btw4x_5_3, btw4x_5_2, btw4x_5_1, btw4x_5_0}) );
    gf_phi2_register_2 GF9 ( .reset(reset), .phi2(phi2), .input_wip({
        btw8x_9_31, btw8x_9_30, btw8x_9_29, btw8x_9_28, btw8x_9_27, btw8x_9_26, 
        btw8x_9_25, btw8x_9_24, btw8x_9_23, btw8x_9_22, btw8x_9_21, btw8x_9_20, 
        btw8x_9_19, btw8x_9_18, btw8x_9_17, btw8x_9_16, btw8x_9_15, btw8x_9_14, 
        btw8x_9_13, btw8x_9_12, btw8x_9_11, btw8x_9_10, btw8x_9_9, btw8x_9_8, 
        btw8x_9_7, btw8x_9_6, btw8x_9_5, btw8x_9_4, btw8x_9_3, btw8x_9_2, 
        btw8x_9_1, btw8x_9_0}), .input_fcs({btw8_9_31, btw8_9_30, btw8_9_29, 
        btw8_9_28, btw8_9_27, btw8_9_26, btw8_9_25, btw8_9_24, btw8_9_23, 
        btw8_9_22, btw8_9_21, btw8_9_20, btw8_9_19, btw8_9_18, btw8_9_17, 
        btw8_9_16, btw8_9_15, btw8_9_14, btw8_9_13, btw8_9_12, btw8_9_11, 
        btw8_9_10, btw8_9_9, btw8_9_8, btw8_9_7, btw8_9_6, btw8_9_5, btw8_9_4, 
        btw8_9_3, btw8_9_2, btw8_9_1, btw8_9_0}), .output_wip({btw9_9x_31, 
        btw9_9x_30, btw9_9x_29, btw9_9x_28, btw9_9x_27, btw9_9x_26, btw9_9x_25, 
        btw9_9x_24, btw9_9x_23, btw9_9x_22, btw9_9x_21, btw9_9x_20, btw9_9x_19, 
        btw9_9x_18, btw9_9x_17, btw9_9x_16, btw9_9x_15, btw9_9x_14, btw9_9x_13, 
        btw9_9x_12, btw9_9x_11, btw9_9x_10, btw9_9x_9, btw9_9x_8, btw9_9x_7, 
        btw9_9x_6, btw9_9x_5, btw9_9x_4, btw9_9x_3, btw9_9x_2, btw9_9x_1, 
        btw9_9x_0}), .output_fcs({btw9_10_31, btw9_10_30, btw9_10_29, 
        btw9_10_28, btw9_10_27, btw9_10_26, btw9_10_25, btw9_10_24, btw9_10_23, 
        btw9_10_22, btw9_10_21, btw9_10_20, btw9_10_19, btw9_10_18, btw9_10_17, 
        btw9_10_16, btw9_10_15, btw9_10_14, btw9_10_13, btw9_10_12, btw9_10_11, 
        btw9_10_10, btw9_10_9, btw9_10_8, btw9_10_7, btw9_10_6, btw9_10_5, 
        btw9_10_4, btw9_10_3, btw9_10_2, btw9_10_1, btw9_10_0}) );
    gf_xor_9x GF9x ( .input_wip({btw9_9x_31, btw9_9x_30, btw9_9x_29, 
        btw9_9x_28, btw9_9x_27, btw9_9x_26, btw9_9x_25, btw9_9x_24, btw9_9x_23, 
        btw9_9x_22, btw9_9x_21, btw9_9x_20, btw9_9x_19, btw9_9x_18, btw9_9x_17, 
        btw9_9x_16, btw9_9x_15, btw9_9x_14, btw9_9x_13, btw9_9x_12, btw9_9x_11, 
        btw9_9x_10, btw9_9x_9, btw9_9x_8, btw9_9x_7, btw9_9x_6, btw9_9x_5, 
        btw9_9x_4, btw9_9x_3, btw9_9x_2, btw9_9x_1, btw9_9x_0}), .input_fcs({
        btw9_10_31, btw9_10_30, btw9_10_29, btw9_10_28, btw9_10_27, btw9_10_26, 
        btw9_10_25, btw9_10_24, btw9_10_23, btw9_10_22, btw9_10_21, btw9_10_20, 
        btw9_10_19, btw9_10_18, btw9_10_17, btw9_10_16, btw9_10_15, btw9_10_14, 
        btw9_10_13, btw9_10_12, btw9_10_11, btw9_10_10, btw9_10_9, btw9_10_8, 
        btw9_10_7, btw9_10_6, btw9_10_5, btw9_10_4, btw9_10_3, btw9_10_2, 
        btw9_10_1, btw9_10_0}), .output_wip({btw9x_10_31, btw9x_10_30, 
        btw9x_10_29, btw9x_10_28, btw9x_10_27, btw9x_10_26, btw9x_10_25, 
        btw9x_10_24, btw9x_10_23, btw9x_10_22, btw9x_10_21, btw9x_10_20, 
        btw9x_10_19, btw9x_10_18, btw9x_10_17, btw9x_10_16, btw9x_10_15, 
        btw9x_10_14, btw9x_10_13, btw9x_10_12, btw9x_10_11, btw9x_10_10, 
        btw9x_10_9, btw9x_10_8, btw9x_10_7, btw9x_10_6, btw9x_10_5, btw9x_10_4, 
        btw9x_10_3, btw9x_10_2, btw9x_10_1, btw9x_10_0}) );
    gf_xor_5x GF5x ( .input_wip({btw5_5x_31, btw5_5x_30, btw5_5x_29, 
        btw5_5x_28, btw5_5x_27, btw5_5x_26, btw5_5x_25, btw5_5x_24, btw5_5x_23, 
        btw5_5x_22, btw5_5x_21, btw5_5x_20, btw5_5x_19, btw5_5x_18, btw5_5x_17, 
        btw5_5x_16, btw5_5x_15, btw5_5x_14, btw5_5x_13, btw5_5x_12, btw5_5x_11, 
        btw5_5x_10, btw5_5x_9, btw5_5x_8, btw5_5x_7, btw5_5x_6, btw5_5x_5, 
        btw5_5x_4, btw5_5x_3, btw5_5x_2, btw5_5x_1, btw5_5x_0}), .input_fcs({
        btw5_6_31, btw5_6_30, btw5_6_29, btw5_6_28, btw5_6_27, btw5_6_26, 
        btw5_6_25, btw5_6_24, btw5_6_23, btw5_6_22, btw5_6_21, btw5_6_20, 
        btw5_6_19, btw5_6_18, btw5_6_17, btw5_6_16, btw5_6_15, btw5_6_14, 
        btw5_6_13, btw5_6_12, btw5_6_11, btw5_6_10, btw5_6_9, btw5_6_8, 
        btw5_6_7, btw5_6_6, btw5_6_5, btw5_6_4, btw5_6_3, btw5_6_2, btw5_6_1, 
        btw5_6_0}), .output_wip({btw5x_6_31, btw5x_6_30, btw5x_6_29, 
        btw5x_6_28, btw5x_6_27, btw5x_6_26, btw5x_6_25, btw5x_6_24, btw5x_6_23, 
        btw5x_6_22, btw5x_6_21, btw5x_6_20, btw5x_6_19, btw5x_6_18, btw5x_6_17, 
        btw5x_6_16, btw5x_6_15, btw5x_6_14, btw5x_6_13, btw5x_6_12, btw5x_6_11, 
        btw5x_6_10, btw5x_6_9, btw5x_6_8, btw5x_6_7, btw5x_6_6, btw5x_6_5, 
        btw5x_6_4, btw5x_6_3, btw5x_6_2, btw5x_6_1, btw5x_6_0}) );
    gf_phi1_register_1 GF2 ( .reset(reset), .phi1(phi1), .input_wip({
        btw1x_2_31, btw1x_2_30, btw1x_2_29, btw1x_2_28, btw1x_2_27, btw1x_2_26, 
        btw1x_2_25, btw1x_2_24, btw1x_2_23, btw1x_2_22, btw1x_2_21, btw1x_2_20, 
        btw1x_2_19, btw1x_2_18, btw1x_2_17, btw1x_2_16, btw1x_2_15, btw1x_2_14, 
        btw1x_2_13, btw1x_2_12, btw1x_2_11, btw1x_2_10, btw1x_2_9, btw1x_2_8, 
        btw1x_2_7, btw1x_2_6, btw1x_2_5, btw1x_2_4, btw1x_2_3, btw1x_2_2, 
        btw1x_2_1, btw1x_2_0}), .input_fcs(\input ), .output_wip({btw2_2x_31, 
        btw2_2x_30, btw2_2x_29, btw2_2x_28, btw2_2x_27, btw2_2x_26, btw2_2x_25, 
        btw2_2x_24, btw2_2x_23, btw2_2x_22, btw2_2x_21, btw2_2x_20, btw2_2x_19, 
        btw2_2x_18, btw2_2x_17, btw2_2x_16, btw2_2x_15, btw2_2x_14, btw2_2x_13, 
        btw2_2x_12, btw2_2x_11, btw2_2x_10, btw2_2x_9, btw2_2x_8, btw2_2x_7, 
        btw2_2x_6, btw2_2x_5, btw2_2x_4, btw2_2x_3, btw2_2x_2, btw2_2x_1, 
        btw2_2x_0}), .output_fcs({btw2_3_31, btw2_3_30, btw2_3_29, btw2_3_28, 
        btw2_3_27, btw2_3_26, btw2_3_25, btw2_3_24, btw2_3_23, btw2_3_22, 
        btw2_3_21, btw2_3_20, btw2_3_19, btw2_3_18, btw2_3_17, btw2_3_16, 
        btw2_3_15, btw2_3_14, btw2_3_13, btw2_3_12, btw2_3_11, btw2_3_10, 
        btw2_3_9, btw2_3_8, btw2_3_7, btw2_3_6, btw2_3_5, btw2_3_4, btw2_3_3, 
        btw2_3_2, btw2_3_1, btw2_3_0}) );
    gf_phi2_register_1 GF3 ( .reset(reset), .phi2(phi2), .input_wip({
        btw2x_3_31, btw2x_3_30, btw2x_3_29, btw2x_3_28, btw2x_3_27, btw2x_3_26, 
        btw2x_3_25, btw2x_3_24, btw2x_3_23, btw2x_3_22, btw2x_3_21, btw2x_3_20, 
        btw2x_3_19, btw2x_3_18, btw2x_3_17, btw2x_3_16, btw2x_3_15, btw2x_3_14, 
        btw2x_3_13, btw2x_3_12, btw2x_3_11, btw2x_3_10, btw2x_3_9, btw2x_3_8, 
        btw2x_3_7, btw2x_3_6, btw2x_3_5, btw2x_3_4, btw2x_3_3, btw2x_3_2, 
        btw2x_3_1, btw2x_3_0}), .input_fcs({btw2_3_31, btw2_3_30, btw2_3_29, 
        btw2_3_28, btw2_3_27, btw2_3_26, btw2_3_25, btw2_3_24, btw2_3_23, 
        btw2_3_22, btw2_3_21, btw2_3_20, btw2_3_19, btw2_3_18, btw2_3_17, 
        btw2_3_16, btw2_3_15, btw2_3_14, btw2_3_13, btw2_3_12, btw2_3_11, 
        btw2_3_10, btw2_3_9, btw2_3_8, btw2_3_7, btw2_3_6, btw2_3_5, btw2_3_4, 
        btw2_3_3, btw2_3_2, btw2_3_1, btw2_3_0}), .output_wip({btw3_3x_31, 
        btw3_3x_30, btw3_3x_29, btw3_3x_28, btw3_3x_27, btw3_3x_26, btw3_3x_25, 
        btw3_3x_24, btw3_3x_23, btw3_3x_22, btw3_3x_21, btw3_3x_20, btw3_3x_19, 
        btw3_3x_18, btw3_3x_17, btw3_3x_16, btw3_3x_15, btw3_3x_14, btw3_3x_13, 
        btw3_3x_12, btw3_3x_11, btw3_3x_10, btw3_3x_9, btw3_3x_8, btw3_3x_7, 
        btw3_3x_6, btw3_3x_5, btw3_3x_4, btw3_3x_3, btw3_3x_2, btw3_3x_1, 
        btw3_3x_0}), .output_fcs({btw3_4_31, btw3_4_30, btw3_4_29, btw3_4_28, 
        btw3_4_27, btw3_4_26, btw3_4_25, btw3_4_24, btw3_4_23, btw3_4_22, 
        btw3_4_21, btw3_4_20, btw3_4_19, btw3_4_18, btw3_4_17, btw3_4_16, 
        btw3_4_15, btw3_4_14, btw3_4_13, btw3_4_12, btw3_4_11, btw3_4_10, 
        btw3_4_9, btw3_4_8, btw3_4_7, btw3_4_6, btw3_4_5, btw3_4_4, btw3_4_3, 
        btw3_4_2, btw3_4_1, btw3_4_0}) );
    gf_xor_3x GF3x ( .input_wip({btw3_3x_31, btw3_3x_30, btw3_3x_29, 
        btw3_3x_28, btw3_3x_27, btw3_3x_26, btw3_3x_25, btw3_3x_24, btw3_3x_23, 
        btw3_3x_22, btw3_3x_21, btw3_3x_20, btw3_3x_19, btw3_3x_18, btw3_3x_17, 
        btw3_3x_16, btw3_3x_15, btw3_3x_14, btw3_3x_13, btw3_3x_12, btw3_3x_11, 
        btw3_3x_10, btw3_3x_9, btw3_3x_8, btw3_3x_7, btw3_3x_6, btw3_3x_5, 
        btw3_3x_4, btw3_3x_3, btw3_3x_2, btw3_3x_1, btw3_3x_0}), .input_fcs({
        btw3_4_31, btw3_4_30, btw3_4_29, btw3_4_28, btw3_4_27, btw3_4_26, 
        btw3_4_25, btw3_4_24, btw3_4_23, btw3_4_22, btw3_4_21, btw3_4_20, 
        btw3_4_19, btw3_4_18, btw3_4_17, btw3_4_16, btw3_4_15, btw3_4_14, 
        btw3_4_13, btw3_4_12, btw3_4_11, btw3_4_10, btw3_4_9, btw3_4_8, 
        btw3_4_7, btw3_4_6, btw3_4_5, btw3_4_4, btw3_4_3, btw3_4_2, btw3_4_1, 
        btw3_4_0}), .output_wip({btw3x_4_31, btw3x_4_30, btw3x_4_29, 
        btw3x_4_28, btw3x_4_27, btw3x_4_26, btw3x_4_25, btw3x_4_24, btw3x_4_23, 
        btw3x_4_22, btw3x_4_21, btw3x_4_20, btw3x_4_19, btw3x_4_18, btw3x_4_17, 
        btw3x_4_16, btw3x_4_15, btw3x_4_14, btw3x_4_13, btw3x_4_12, btw3x_4_11, 
        btw3x_4_10, btw3x_4_9, btw3x_4_8, btw3x_4_7, btw3x_4_6, btw3x_4_5, 
        btw3x_4_4, btw3x_4_3, btw3x_4_2, btw3x_4_1, btw3x_4_0}) );
    gf_phi2_register_0 GF5 ( .reset(reset), .phi2(phi2), .input_wip({
        btw4x_5_31, btw4x_5_30, btw4x_5_29, btw4x_5_28, btw4x_5_27, btw4x_5_26, 
        btw4x_5_25, btw4x_5_24, btw4x_5_23, btw4x_5_22, btw4x_5_21, btw4x_5_20, 
        btw4x_5_19, btw4x_5_18, btw4x_5_17, btw4x_5_16, btw4x_5_15, btw4x_5_14, 
        btw4x_5_13, btw4x_5_12, btw4x_5_11, btw4x_5_10, btw4x_5_9, btw4x_5_8, 
        btw4x_5_7, btw4x_5_6, btw4x_5_5, btw4x_5_4, btw4x_5_3, btw4x_5_2, 
        btw4x_5_1, btw4x_5_0}), .input_fcs({btw4_5_31, btw4_5_30, btw4_5_29, 
        btw4_5_28, btw4_5_27, btw4_5_26, btw4_5_25, btw4_5_24, btw4_5_23, 
        btw4_5_22, btw4_5_21, btw4_5_20, btw4_5_19, btw4_5_18, btw4_5_17, 
        btw4_5_16, btw4_5_15, btw4_5_14, btw4_5_13, btw4_5_12, btw4_5_11, 
        btw4_5_10, btw4_5_9, btw4_5_8, btw4_5_7, btw4_5_6, btw4_5_5, btw4_5_4, 
        btw4_5_3, btw4_5_2, btw4_5_1, btw4_5_0}), .output_wip({btw5_5x_31, 
        btw5_5x_30, btw5_5x_29, btw5_5x_28, btw5_5x_27, btw5_5x_26, btw5_5x_25, 
        btw5_5x_24, btw5_5x_23, btw5_5x_22, btw5_5x_21, btw5_5x_20, btw5_5x_19, 
        btw5_5x_18, btw5_5x_17, btw5_5x_16, btw5_5x_15, btw5_5x_14, btw5_5x_13, 
        btw5_5x_12, btw5_5x_11, btw5_5x_10, btw5_5x_9, btw5_5x_8, btw5_5x_7, 
        btw5_5x_6, btw5_5x_5, btw5_5x_4, btw5_5x_3, btw5_5x_2, btw5_5x_1, 
        btw5_5x_0}), .output_fcs({btw5_6_31, btw5_6_30, btw5_6_29, btw5_6_28, 
        btw5_6_27, btw5_6_26, btw5_6_25, btw5_6_24, btw5_6_23, btw5_6_22, 
        btw5_6_21, btw5_6_20, btw5_6_19, btw5_6_18, btw5_6_17, btw5_6_16, 
        btw5_6_15, btw5_6_14, btw5_6_13, btw5_6_12, btw5_6_11, btw5_6_10, 
        btw5_6_9, btw5_6_8, btw5_6_7, btw5_6_6, btw5_6_5, btw5_6_4, btw5_6_3, 
        btw5_6_2, btw5_6_1, btw5_6_0}) );
    gf_xor_8x GF8x ( .input_wip({btw8_8x_31, btw8_8x_30, btw8_8x_29, 
        btw8_8x_28, btw8_8x_27, btw8_8x_26, btw8_8x_25, btw8_8x_24, btw8_8x_23, 
        btw8_8x_22, btw8_8x_21, btw8_8x_20, btw8_8x_19, btw8_8x_18, btw8_8x_17, 
        btw8_8x_16, btw8_8x_15, btw8_8x_14, btw8_8x_13, btw8_8x_12, btw8_8x_11, 
        btw8_8x_10, btw8_8x_9, btw8_8x_8, btw8_8x_7, btw8_8x_6, btw8_8x_5, 
        btw8_8x_4, btw8_8x_3, btw8_8x_2, btw8_8x_1, btw8_8x_0}), .input_fcs({
        btw8_9_31, btw8_9_30, btw8_9_29, btw8_9_28, btw8_9_27, btw8_9_26, 
        btw8_9_25, btw8_9_24, btw8_9_23, btw8_9_22, btw8_9_21, btw8_9_20, 
        btw8_9_19, btw8_9_18, btw8_9_17, btw8_9_16, btw8_9_15, btw8_9_14, 
        btw8_9_13, btw8_9_12, btw8_9_11, btw8_9_10, btw8_9_9, btw8_9_8, 
        btw8_9_7, btw8_9_6, btw8_9_5, btw8_9_4, btw8_9_3, btw8_9_2, btw8_9_1, 
        btw8_9_0}), .output_wip({btw8x_9_31, btw8x_9_30, btw8x_9_29, 
        btw8x_9_28, btw8x_9_27, btw8x_9_26, btw8x_9_25, btw8x_9_24, btw8x_9_23, 
        btw8x_9_22, btw8x_9_21, btw8x_9_20, btw8x_9_19, btw8x_9_18, btw8x_9_17, 
        btw8x_9_16, btw8x_9_15, btw8x_9_14, btw8x_9_13, btw8x_9_12, btw8x_9_11, 
        btw8x_9_10, btw8x_9_9, btw8x_9_8, btw8x_9_7, btw8x_9_6, btw8x_9_5, 
        btw8x_9_4, btw8x_9_3, btw8x_9_2, btw8x_9_1, btw8x_9_0}) );
    gf_phi1_register_0 GF4 ( .reset(reset), .phi1(phi1), .input_wip({
        btw3x_4_31, btw3x_4_30, btw3x_4_29, btw3x_4_28, btw3x_4_27, btw3x_4_26, 
        btw3x_4_25, btw3x_4_24, btw3x_4_23, btw3x_4_22, btw3x_4_21, btw3x_4_20, 
        btw3x_4_19, btw3x_4_18, btw3x_4_17, btw3x_4_16, btw3x_4_15, btw3x_4_14, 
        btw3x_4_13, btw3x_4_12, btw3x_4_11, btw3x_4_10, btw3x_4_9, btw3x_4_8, 
        btw3x_4_7, btw3x_4_6, btw3x_4_5, btw3x_4_4, btw3x_4_3, btw3x_4_2, 
        btw3x_4_1, btw3x_4_0}), .input_fcs({btw3_4_31, btw3_4_30, btw3_4_29, 
        btw3_4_28, btw3_4_27, btw3_4_26, btw3_4_25, btw3_4_24, btw3_4_23, 
        btw3_4_22, btw3_4_21, btw3_4_20, btw3_4_19, btw3_4_18, btw3_4_17, 
        btw3_4_16, btw3_4_15, btw3_4_14, btw3_4_13, btw3_4_12, btw3_4_11, 
        btw3_4_10, btw3_4_9, btw3_4_8, btw3_4_7, btw3_4_6, btw3_4_5, btw3_4_4, 
        btw3_4_3, btw3_4_2, btw3_4_1, btw3_4_0}), .output_wip({btw4_4x_31, 
        btw4_4x_30, btw4_4x_29, btw4_4x_28, btw4_4x_27, btw4_4x_26, btw4_4x_25, 
        btw4_4x_24, btw4_4x_23, btw4_4x_22, btw4_4x_21, btw4_4x_20, btw4_4x_19, 
        btw4_4x_18, btw4_4x_17, btw4_4x_16, btw4_4x_15, btw4_4x_14, btw4_4x_13, 
        btw4_4x_12, btw4_4x_11, btw4_4x_10, btw4_4x_9, btw4_4x_8, btw4_4x_7, 
        btw4_4x_6, btw4_4x_5, btw4_4x_4, btw4_4x_3, btw4_4x_2, btw4_4x_1, 
        btw4_4x_0}), .output_fcs({btw4_5_31, btw4_5_30, btw4_5_29, btw4_5_28, 
        btw4_5_27, btw4_5_26, btw4_5_25, btw4_5_24, btw4_5_23, btw4_5_22, 
        btw4_5_21, btw4_5_20, btw4_5_19, btw4_5_18, btw4_5_17, btw4_5_16, 
        btw4_5_15, btw4_5_14, btw4_5_13, btw4_5_12, btw4_5_11, btw4_5_10, 
        btw4_5_9, btw4_5_8, btw4_5_7, btw4_5_6, btw4_5_5, btw4_5_4, btw4_5_3, 
        btw4_5_2, btw4_5_1, btw4_5_0}) );
    gf_xor_7x GF7x ( .input_wip({btw7_7x_31, btw7_7x_30, btw7_7x_29, 
        btw7_7x_28, btw7_7x_27, btw7_7x_26, btw7_7x_25, btw7_7x_24, btw7_7x_23, 
        btw7_7x_22, btw7_7x_21, btw7_7x_20, btw7_7x_19, btw7_7x_18, btw7_7x_17, 
        btw7_7x_16, btw7_7x_15, btw7_7x_14, btw7_7x_13, btw7_7x_12, btw7_7x_11, 
        btw7_7x_10, btw7_7x_9, btw7_7x_8, btw7_7x_7, btw7_7x_6, btw7_7x_5, 
        btw7_7x_4, btw7_7x_3, btw7_7x_2, btw7_7x_1, btw7_7x_0}), .input_fcs({
        btw7_8_31, btw7_8_30, btw7_8_29, btw7_8_28, btw7_8_27, btw7_8_26, 
        btw7_8_25, btw7_8_24, btw7_8_23, btw7_8_22, btw7_8_21, btw7_8_20, 
        btw7_8_19, btw7_8_18, btw7_8_17, btw7_8_16, btw7_8_15, btw7_8_14, 
        btw7_8_13, btw7_8_12, btw7_8_11, btw7_8_10, btw7_8_9, btw7_8_8, 
        btw7_8_7, btw7_8_6, btw7_8_5, btw7_8_4, btw7_8_3, btw7_8_2, btw7_8_1, 
        btw7_8_0}), .output_wip({btw7x_8_31, btw7x_8_30, btw7x_8_29, 
        btw7x_8_28, btw7x_8_27, btw7x_8_26, btw7x_8_25, btw7x_8_24, btw7x_8_23, 
        btw7x_8_22, btw7x_8_21, btw7x_8_20, btw7x_8_19, btw7x_8_18, btw7x_8_17, 
        btw7x_8_16, btw7x_8_15, btw7x_8_14, btw7x_8_13, btw7x_8_12, btw7x_8_11, 
        btw7x_8_10, btw7x_8_9, btw7x_8_8, btw7x_8_7, btw7x_8_6, btw7x_8_5, 
        btw7x_8_4, btw7x_8_3, btw7x_8_2, btw7x_8_1, btw7x_8_0}) );
    gf_phi1_register_out GF10 ( .reset(reset), .phi1(phi1), .input_wip({
        btw9x_10_31, btw9x_10_30, btw9x_10_29, btw9x_10_28, btw9x_10_27, 
        btw9x_10_26, btw9x_10_25, btw9x_10_24, btw9x_10_23, btw9x_10_22, 
        btw9x_10_21, btw9x_10_20, btw9x_10_19, btw9x_10_18, btw9x_10_17, 
        btw9x_10_16, btw9x_10_15, btw9x_10_14, btw9x_10_13, btw9x_10_12, 
        btw9x_10_11, btw9x_10_10, btw9x_10_9, btw9x_10_8, btw9x_10_7, 
        btw9x_10_6, btw9x_10_5, btw9x_10_4, btw9x_10_3, btw9x_10_2, btw9x_10_1, 
        btw9x_10_0}), .output_final({output_fcs[15], output_fcs[14], 
        output_fcs[13], output_fcs[12], output_fcs[11], output_fcs[10], 
        output_fcs[9], output_fcs[8], output_fcs[7], output_fcs[6], 
        output_fcs[5], output_fcs[4], output_fcs[3], output_fcs[2], 
        output_fcs[1], output_fcs[0], output_xor[15], output_xor[14], 
        output_xor[13], output_xor[12], output_xor[11], output_xor[10], 
        output_xor[9], output_xor[8], output_xor[7], output_xor[6], 
        output_xor[5], output_xor[4], output_xor[3], output_xor[2], 
        output_xor[1], output_xor[0]}) );
endmodule


module big_xor ( reset, phi2, input_input, fcs_input, gf_input, \output  );
input  [15:0] gf_input;
output [31:0] \output ;
input  [15:0] input_input;
input  [15:0] fcs_input;
input  reset, phi2;
    wire output_xor_15, output_xor_12, output_xor_9, output_xor_7, 
        output_xor_0, output_xor_14, output_xor_13, output_xor_8, output_xor_6, 
        output_xor_1, output_xor_11, output_xor_10, output_xor_5, output_xor_4, 
        output_xor_3, output_xor_2, n77, n78, n79, n81, n83, n85, n87, n89, 
        n91;
    DFA2 output_reg_31 ( .C(phi2), .D(fcs_input[15]), .QN(n91), .RN(n78) );
    DFA output_reg_20 ( .C(phi2), .D(fcs_input[4]), .Q(\output [20]), .RN(n78)
         );
    DF9 output_reg_21 ( .C(phi2), .D(fcs_input[5]), .Q(\output [21]), .SN(n78)
         );
    DF92 output_reg_16 ( .C(phi2), .D(fcs_input[0]), .Q(\output [16]), .SN(n78
        ) );
    DF92 output_reg_18 ( .C(phi2), .D(fcs_input[2]), .Q(\output [18]), .SN(n78
        ) );
    DF92 output_reg_19 ( .C(phi2), .D(fcs_input[3]), .Q(\output [19]), .SN(n78
        ) );
    DF92 output_reg_17 ( .C(phi2), .D(fcs_input[1]), .Q(\output [17]), .SN(n78
        ) );
    BU4 U49 ( .A(n77), .Q(n78) );
    BU2 U50 ( .A(reset), .Q(n77) );
    IN4 U51 ( .A(n79), .Q(\output [22]) );
    IN8 U52 ( .A(n89), .Q(\output [28]) );
    IN8 U53 ( .A(n83), .Q(\output [26]) );
    IN8 U54 ( .A(n87), .Q(\output [29]) );
    IN8 U55 ( .A(n81), .Q(\output [30]) );
    DF9 output_reg_3 ( .C(phi2), .D(output_xor_3), .Q(\output [3]), .SN(n78)
         );
    DF9 output_reg_13 ( .C(phi2), .D(output_xor_13), .Q(\output [13]), .SN(n78
        ) );
    DF9 output_reg_14 ( .C(phi2), .D(output_xor_14), .Q(\output [14]), .SN(n78
        ) );
    DF9 output_reg_0 ( .C(phi2), .D(output_xor_0), .Q(\output [0]), .SN(n78)
         );
    DF9 output_reg_10 ( .C(phi2), .D(output_xor_10), .Q(\output [10]), .SN(n78
        ) );
    DF9 output_reg_6 ( .C(phi2), .D(output_xor_6), .Q(\output [6]), .SN(n78)
         );
    DFA output_reg_15 ( .C(phi2), .D(output_xor_15), .Q(\output [15]), .RN(n78
        ) );
    DFA output_reg_12 ( .C(phi2), .D(output_xor_12), .Q(\output [12]), .RN(n78
        ) );
    DFA output_reg_4 ( .C(phi2), .D(output_xor_4), .Q(\output [4]), .RN(n78)
         );
    DFA output_reg_5 ( .C(phi2), .D(output_xor_5), .Q(\output [5]), .RN(n78)
         );
    DFA output_reg_2 ( .C(phi2), .D(output_xor_2), .Q(\output [2]), .RN(n78)
         );
    DFA output_reg_9 ( .C(phi2), .D(output_xor_9), .Q(\output [9]), .RN(n78)
         );
    DFA output_reg_11 ( .C(phi2), .D(output_xor_11), .Q(\output [11]), .RN(n78
        ) );
    DFA output_reg_7 ( .C(phi2), .D(output_xor_7), .Q(\output [7]), .RN(n78)
         );
    DFA output_reg_1 ( .C(phi2), .D(output_xor_1), .Q(\output [1]), .RN(n78)
         );
    DFA output_reg_8 ( .C(phi2), .D(output_xor_8), .Q(\output [8]), .RN(n78)
         );
    EO1 U56 ( .A(gf_input[12]), .B(input_input[12]), .Q(output_xor_12) );
    EO1 U57 ( .A(gf_input[15]), .B(input_input[15]), .Q(output_xor_15) );
    EO1 U58 ( .A(gf_input[4]), .B(input_input[4]), .Q(output_xor_4) );
    EO1 U59 ( .A(gf_input[5]), .B(input_input[5]), .Q(output_xor_5) );
    EO1 U60 ( .A(gf_input[2]), .B(input_input[2]), .Q(output_xor_2) );
    EO1 U61 ( .A(gf_input[9]), .B(input_input[9]), .Q(output_xor_9) );
    EO1 U62 ( .A(gf_input[11]), .B(input_input[11]), .Q(output_xor_11) );
    EO1 U63 ( .A(gf_input[7]), .B(input_input[7]), .Q(output_xor_7) );
    EO1 U64 ( .A(gf_input[1]), .B(input_input[1]), .Q(output_xor_1) );
    EO1 U65 ( .A(gf_input[8]), .B(input_input[8]), .Q(output_xor_8) );
    EO1 U66 ( .A(gf_input[3]), .B(input_input[3]), .Q(output_xor_3) );
    EO1 U67 ( .A(gf_input[13]), .B(input_input[13]), .Q(output_xor_13) );
    EO1 U68 ( .A(gf_input[14]), .B(input_input[14]), .Q(output_xor_14) );
    EO1 U69 ( .A(gf_input[0]), .B(input_input[0]), .Q(output_xor_0) );
    EO1 U70 ( .A(gf_input[10]), .B(input_input[10]), .Q(output_xor_10) );
    EO1 U71 ( .A(gf_input[6]), .B(input_input[6]), .Q(output_xor_6) );
    DF92 output_reg_30 ( .C(phi2), .D(fcs_input[14]), .QN(n81), .SN(n78) );
    DF92 output_reg_26 ( .C(phi2), .D(fcs_input[10]), .QN(n83), .SN(n78) );
    IN4 U72 ( .A(n85), .Q(\output [27]) );
    DFA2 output_reg_28 ( .C(phi2), .D(fcs_input[12]), .QN(n89), .RN(n78) );
    DFA2 output_reg_29 ( .C(phi2), .D(fcs_input[13]), .QN(n87), .RN(n78) );
    IN8 U73 ( .A(n91), .Q(\output [31]) );
    DF92 output_reg_23 ( .C(phi2), .D(fcs_input[7]), .Q(\output [23]), .SN(n78
        ) );
    DF92 output_reg_25 ( .C(phi2), .D(fcs_input[9]), .Q(\output [25]), .SN(n78
        ) );
    DFA2 output_reg_22 ( .C(phi2), .D(fcs_input[6]), .QN(n79), .RN(n78) );
    DFA2 output_reg_24 ( .C(phi2), .D(fcs_input[8]), .Q(\output [24]), .RN(n78
        ) );
    DFA2 output_reg_27 ( .C(phi2), .D(fcs_input[11]), .QN(n85), .RN(n78) );
endmodule


module CRC_top ( phi1, phi2, reset, \input , fcs_out );
input  [15:0] \input ;
output [31:0] fcs_out;
input  phi1, phi2, reset;
    wire wait_intermediate_10, xor_intermediate_0, fcs_intermediate_10, 
        fcs_intermediate_8, xor_intermediate_9, wait_intermediate_2, 
        fcs_intermediate_6, fcs_intermediate_1, wait_intermediate_5, 
        reset_intermediate, xor_intermediate_11, wait_intermediate_15, 
        wait_intermediate_14, wait_intermediate_13, wait_intermediate_11, 
        wait_intermediate_4, xor_intermediate_7, wait_intermediate_3, 
        fcs_intermediate_7, xor_intermediate_6, xor_intermediate_10, 
        fcs_intermediate_9, fcs_intermediate_0, xor_intermediate_1, 
        xor_intermediate_8, wait_intermediate_8, fcs_intermediate_11, 
        xor_intermediate_15, xor_intermediate_3, fcs_intermediate_13, 
        wait_intermediate_6, wait_intermediate_1, fcs_intermediate_5, 
        fcs_intermediate_2, fcs_intermediate_14, xor_intermediate_12, 
        fcs_intermediate_15, xor_intermediate_4, wait_intermediate_7, 
        fcs_intermediate_4, xor_intermediate_13, xor_intermediate_5, 
        xor_intermediate_14, wait_intermediate_12, wait_intermediate_9, 
        wait_intermediate_0, fcs_intermediate_3, xor_intermediate_2, 
        fcs_intermediate_12;
    ff_reset ff_reset_1 ( .phi2(phi2), .reset_glitch(reset), .reset_clean(
        reset_intermediate) );
    input_wait input_wait_1 ( .phi1(phi1), .phi2(phi2), .reset(
        reset_intermediate), .\input (\input ), .\output ({
        wait_intermediate_15, wait_intermediate_14, wait_intermediate_13, 
        wait_intermediate_12, wait_intermediate_11, wait_intermediate_10, 
        wait_intermediate_9, wait_intermediate_8, wait_intermediate_7, 
        wait_intermediate_6, wait_intermediate_5, wait_intermediate_4, 
        wait_intermediate_3, wait_intermediate_2, wait_intermediate_1, 
        wait_intermediate_0}) );
    gf_multiplier gf_multiplier_1 ( .reset(reset_intermediate), .phi1(phi1), 
        .phi2(phi2), .\input (fcs_out), .output_fcs({fcs_intermediate_15, 
        fcs_intermediate_14, fcs_intermediate_13, fcs_intermediate_12, 
        fcs_intermediate_11, fcs_intermediate_10, fcs_intermediate_9, 
        fcs_intermediate_8, fcs_intermediate_7, fcs_intermediate_6, 
        fcs_intermediate_5, fcs_intermediate_4, fcs_intermediate_3, 
        fcs_intermediate_2, fcs_intermediate_1, fcs_intermediate_0}), 
        .output_xor({xor_intermediate_15, xor_intermediate_14, 
        xor_intermediate_13, xor_intermediate_12, xor_intermediate_11, 
        xor_intermediate_10, xor_intermediate_9, xor_intermediate_8, 
        xor_intermediate_7, xor_intermediate_6, xor_intermediate_5, 
        xor_intermediate_4, xor_intermediate_3, xor_intermediate_2, 
        xor_intermediate_1, xor_intermediate_0}) );
    big_xor big_xor_1 ( .reset(reset_intermediate), .phi2(phi2), .input_input(
        {wait_intermediate_15, wait_intermediate_14, wait_intermediate_13, 
        wait_intermediate_12, wait_intermediate_11, wait_intermediate_10, 
        wait_intermediate_9, wait_intermediate_8, wait_intermediate_7, 
        wait_intermediate_6, wait_intermediate_5, wait_intermediate_4, 
        wait_intermediate_3, wait_intermediate_2, wait_intermediate_1, 
        wait_intermediate_0}), .fcs_input({fcs_intermediate_15, 
        fcs_intermediate_14, fcs_intermediate_13, fcs_intermediate_12, 
        fcs_intermediate_11, fcs_intermediate_10, fcs_intermediate_9, 
        fcs_intermediate_8, fcs_intermediate_7, fcs_intermediate_6, 
        fcs_intermediate_5, fcs_intermediate_4, fcs_intermediate_3, 
        fcs_intermediate_2, fcs_intermediate_1, fcs_intermediate_0}), 
        .gf_input({xor_intermediate_15, xor_intermediate_14, 
        xor_intermediate_13, xor_intermediate_12, xor_intermediate_11, 
        xor_intermediate_10, xor_intermediate_9, xor_intermediate_8, 
        xor_intermediate_7, xor_intermediate_6, xor_intermediate_5, 
        xor_intermediate_4, xor_intermediate_3, xor_intermediate_2, 
        xor_intermediate_1, xor_intermediate_0}), .\output (fcs_out) );
endmodule

