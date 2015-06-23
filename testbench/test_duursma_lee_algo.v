`timescale 1ns / 1ns
`include "../rtl/inc.v"

module test_duursma_lee_algo;

    // Inputs
    reg clk;
    reg reset;
    reg [`WIDTH:0] xp,yp,xr,yr;

    // Outputs
    wire done;
    wire [`W6:0] out;
    wire [`WIDTH:0] o0,o1,o2,o3,o4,o5;

    // Instantiate the Unit Under Test (UUT)
    duursma_lee_algo uut (
        .clk(clk), 
        .reset(reset), 
        .xp(xp), 
        .yp(yp), 
        .xr(xr), 
        .yr(yr), 
        .done(done), 
        .out(out)
    );
    
    assign {o5,o4,o3,o2,o1,o0} = out;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        xp = 0;
        yp = 0;
        xr = 0;
        yr = 0;

        // Wait 100 ns for global reset to finish
        #100;

        // Add stimulus here
        xp = 194'haa5a8129a02a0544a4409a500045458901280969815aa820;
        yp = 194'h1414a205a21a4428968985650895464402249258428049204;
        xr = 194'h614011499522506668a01a20988812468a5aa8641aa24595;
        yr = 194'haa01145590659058124a0261410682860225909182a92189;
        @ (negedge clk); reset = 1;
        @ (negedge clk); reset = 0;
        @ (posedge done);
        #100;
        if (out !== {{194'h289898988a561125505a60640642444905248262004845aa6,194'ha6a208a8402504225588a080a124292404061158a96a6a44},{194'h2266261625a9894a45640906a242a99295816525895a98a25,194'h21868921614220506a96a9285119405a15550801829589214},{194'h26a4200680102269189946046919aa804602128246999685a,194'h1a558028a5a964224120a9212a9089a0966a0918a41612219}})
          begin
            $display("E");
            $display("o0=%h",o0);
            $display("o1=%h",o1);
            $display("o2=%h",o2);
            $display("o3=%h",o3);
            $display("o4=%h",o4);
            $display("o5=%h",o5);
          end
        #100;
        $finish;
    end
    
    always #5 clk = ~clk;
endmodule

