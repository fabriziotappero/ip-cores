module  mod3 (
    input   [ 7: 0] dat_i,
    output  [ 1: 0] reminder
    );
    
    wire    [ 1: 0] dat_1, dat_2, dat_3, dat_4;
    wire    [ 1: 0] dat_5, dat_6;
    
    type_conv TC0(
        .plus_one(dat_i[0]),
        .minus_one(dat_i[1]),
        .dat_o(dat_1)
    );
    
    type_conv TC1(
        .plus_one(dat_i[2]),
        .minus_one(dat_i[3]),
        .dat_o(dat_2)
    );

    type_conv TC2(
        .plus_one(dat_i[4]),
        .minus_one(dat_i[5]),
        .dat_o(dat_3)
    );

    type_conv TC3(
        .plus_one(dat_i[6]),
        .minus_one(dat_i[7]),
        .dat_o(dat_4)
    );    
    
    mod3_adder MA0(
        .din_a(dat_1), .din_b(dat_2),
        .dat_o(dat_5)
    );

    mod3_adder MA1(
        .din_a(dat_3), .din_b(dat_4),
        .dat_o(dat_6)
    );

    mod3_adder MA3(
        .din_a(dat_5), .din_b(dat_6),
        .dat_o(reminder)
    );
    
endmodule
//convert to signed data
module  type_conv (
    input   plus_one,
            minus_one,
    output  reg [ 1: 0] dat_o
    );
    
    always@(*)  begin
        case ({plus_one, minus_one})
            2'b00   :   dat_o   = 2'b00;
            2'b01   :   dat_o   = 2'b10;
            2'b10   :   dat_o   = 2'b01;
            2'b11   :   dat_o   = 2'b00;
            default :   dat_o   = 2'b00;
        endcase
    end
    
endmodule

//a qucik mod3 adder
module  mod3_adder (
    input   [ 1: 0] din_a, din_b,
    output  reg [ 1: 0] dat_o
    );
    
    always@(*)  begin
        case ({din_a, din_b})
            4'b00_00    :   dat_o   = 2'b00;
            4'b00_01    :   dat_o   = 2'b01;
            4'b00_10    :   dat_o   = 2'b10;
            4'b01_00    :   dat_o   = 2'b01;
            4'b01_01    :   dat_o   = 2'b10;
            4'b01_10    :   dat_o   = 2'b00;
            4'b10_00    :   dat_o   = 2'b10;
            4'b10_01    :   dat_o   = 2'b00;
            4'b10_10    :   dat_o   = 2'b01;
            default     :   dat_o   = 2'b00;
        endcase
    end
endmodule
    
