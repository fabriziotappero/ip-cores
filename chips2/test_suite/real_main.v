//name : real_main
//tag : c components
//source_file : test.c
///=========
///
///*Created by C2CHIP*

// Register Allocation
// ===================
//         Register                 Name                   Size          
//            0             real_main return address            2            
  
`timescale 1ns/1ps
module real_main;
  integer file_count;
  reg       [15:0] timer;
  reg       [1:0] program_counter;
  reg       [15:0] address_2;
  reg       [15:0] data_out_2;
  reg       [15:0] data_in_2;
  reg       write_enable_2;
  reg       [15:0] address_4;
  reg       [31:0] data_out_4;
  reg       [31:0] data_in_4;
  reg       write_enable_4;
  reg       [15:0] register_0;
  reg       clk;
  reg       rst;

  //////////////////////////////////////////////////////////////////////////////
  // CLOCK AND RESET GENERATION                                                 
  //                                                                            
  // This file was generated in test bench mode. In this mode, the verilog      
  // output file can be executed directly within a verilog simulator.           
  // In test bench mode, a simulated clock and reset signal are generated within
  // the output file.                                                           
  // Verilog files generated in testbecnch mode are not suitable for synthesis, 
  // or for instantiation within a larger design.
  
  initial
  begin
    rst <= 1'b1;
    #50 rst <= 1'b0;
  end

  
  initial
  begin
    clk <= 1'b0;
    while (1) begin
      #5 clk <= ~clk;
    end
  end


  //////////////////////////////////////////////////////////////////////////////
  // FSM IMPLEMENTAION OF C PROCESS                                             
  //                                                                            
  // This section of the file contains a Finite State Machine (FSM) implementing
  // the C process. In general execution is sequential, but the compiler will   
  // attempt to execute instructions in parallel if the instruction dependencies
  // allow. Further concurrency can be achieved by executing multiple C         
  // processes concurrently within the device.                                  
  
  always @(posedge clk)
  begin

    //implement timer
    timer <= 16'h0000;

    case(program_counter)

      16'd0:
      begin
        program_counter <= 16'd1;
        program_counter <= 16'd3;
        register_0 <= 16'd1;
      end

      16'd1:
      begin
        program_counter <= 16'd3;
        $finish;
        program_counter <= program_counter;
      end

      16'd3:
      begin
        program_counter <= 16'd2;
        program_counter <= register_0;
      end

    endcase
    if (rst == 1'b1) begin
      program_counter <= 0;
    end
  end

endmodule
