`timescale 1ns / 1ps

module test_f3_add;

    // Inputs
    reg [1:0] A;
    reg [1:0] B;

    // Outputs
    wire [1:0] C;

    // Instantiate the Unit Under Test (UUT)
    f3_add uut (
        .A(A), 
        .B(B), 
        .C(C)
    );

   task check;
      begin
         #10;
            if ((A+B) % 3 != C) 
               begin 
                   $display("Error"); $finish; 
                end
      end
    endtask

    initial begin
        // Initialize Inputs
        A = 0;
        B = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Add stimulus here
        A = 0; B = 0; check;
        A = 0; B = 1; check;
        A = 0; B = 2; check;
        A = 1; B = 0; check;
        A = 1; B = 1; check;
        A = 1; B = 2; check;
        A = 2; B = 0; check;
        A = 2; B = 1; check;
        A = 2; B = 2; check;
        $finish;
    end
   
endmodule

