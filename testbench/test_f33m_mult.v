`timescale 1ns / 1ns
`include "../rtl/inc.v"

module test_f33m_mult;

    // Inputs
    reg clk;
    reg reset;
    reg [`W3:0] a,b,wish;

    // Outputs
    wire done;
    wire [`W3:0] c;

    // Instantiate the Unit Under Test (UUT)
    f33m_mult uut (
        .clk(clk), 
        .reset(reset), 
        .a(a), 
        .b(b), 
        .c(c), 
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        a = 0;
        b = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Add stimulus here
        a = {194'ha05199566491a29190482a612a86561469a2a21a0598425a,194'h29a016819944661925585684aa051456a52a02442a9080568,194'h15219624104641521626a965848208a09a02a9a084499006a};
        b = {194'h16458a4488a64426429a46989868049a5a94a291668056411,194'h4229659440a9689291461604a9a01a20000a191a00142951,194'h504004aaa024886a56504a8a4a58806919aa1a4549a56688};
        wish = {194'ha65a56829a691285518450025a0190642544a08628a965a5,194'h22889984564568942218aa986112026a095a629a68890a859,194'h14a11844416485509289802509a000421864454612559588};
        @ (negedge clk); reset = 1;
        @ (negedge clk); reset = 0;
        @ (posedge done);
        @ (posedge clk);
        if (c !== wish)
            $display("E");
        $finish;
    end
endmodule

