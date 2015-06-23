`timescale 1ns / 1ps

module test_f3_neg;

    // Inputs
    reg [1:0] A;

    // Outputs
    wire [1:0] B;

    // Instantiate the Unit Under Test (UUT)
    f3_neg uut (
        .A(A), 
        .B(B)
    );

   task check;
      begin
         #10;
            if ((A+B) % 3 != 0) 
               begin 
                   $display("Error"); $finish; 
                end
      end
    endtask

    initial begin
        // Initialize Inputs
        A = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Add stimulus here
        A = 0; check;
        A = 1; check;
        A = 2; check;
        $finish;
    end
   
endmodule

