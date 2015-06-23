`timescale 1ns / 1ps

module test_f32m_mult;

    // Inputs
    reg reset;
    reg clk;
    reg [387:0] a,b;

    // Outputs
    wire [387:0] c;
    wire done;

    // Instantiate the Unit Under Test (UUT)
    f32m_mult uut (
        .reset(reset), 
        .clk(clk), 
        .a(a), 
        .b(b), 
        .c(c), 
        .done(done)
    );

    initial begin
        // Initialize Inputs
        reset = 0;
        clk = 0;
        a = 0;
        b = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Add stimulus here
        a={194'h2a8aa25aa245066106a40806618aa88a2946881162a864652,194'h28258889288590a464559a0854a0a269820495a6069969aa2};
        b={194'h59a0a46891951042640592a2969888012108059214504048,194'h55812555968918122622106514a25488204895614889112};
        @ (negedge clk) reset = 1;
        @ (negedge clk) reset = 0;
        @ (posedge done);
        if (c!=={194'h9594010a580186621a840406105460622891085122060a45,194'h59a1595621295a89260802a045194a96050a6202164000a9}) $display("E1");
        #100;
        
        a={194'h8864990666a959a88500249a244495aaa26a2a0194082aa1,194'h2a9481526946468065456052045865262520a4a9520a5a665};
        b={194'h116698585aa229805611194a6520151245204aa9114a89200,194'h8855225a25520a048a912141800501862189941946906540};
        @ (negedge clk) reset = 1;
        @ (negedge clk) reset = 0;
        @ (posedge done);
        if (c!=={194'h215608121442a91950aaa59514a9486258684486825840894,194'h284845aa0664918068988811691a290658228028985249a48}) $display("E2");
        #100;
        
        $finish;
    end
    
    always #5 clk = ~clk;
endmodule

