/*
Project        : AES
Standard doc.  : FIPS 197
Module name    : Top_AES_PipelinedCipher testbench
Dependancy     :
Design doc.    : 
References     : 
Description    :
Owner          : Amr Salah
*/

`timescale 1 ns/1 ps

module Top_PipelinedCipher_tb();

parameter DATA_W = 128;            //data width
parameter KEY_L = 128;             //key length
parameter NO_ROUNDS = 10;          //number of rounds
parameter Clk2Q = 2;               //Clk-Q delay
parameter No_Patterns = 284;       //number of patterns

reg clk;
reg reset;
reg data_valid_in;
reg cipherkey_valid_in;
reg [KEY_L-1:0] cipher_key;
reg [DATA_W-1:0] plain_text;
wire valid_out;
wire[DATA_W-1:0]cipher_text;
reg dut_error;
reg [DATA_W-1:0] data_expected;
reg [DATA_W-1:0] data_input_vectors [0:No_Patterns-1] ;
reg [DATA_W-1:0] cipherkey_input_vectors [0:No_Patterns-1] ;
reg [DATA_W-1:0] output_vectors [0:No_Patterns-1] ;

integer i;

Top_PipelinedCipher  U            //connecting DUT
(             
.clk(clk),
.reset(reset),
.data_valid_in(data_valid_in),
.cipherkey_valid_in(cipherkey_valid_in),
.cipher_key(cipher_key),
.plain_text(plain_text),
.valid_out(valid_out),
.cipher_text(cipher_text)
);

event terminate_sim;
event reset_enable;

initial begin                    //reading input data and cipherkey vectors and expected output vectors        
 
$readmemh("topcipher_data_test_inputs.txt",data_input_vectors);    
$readmemh("topcipher_key_test_inputs.txt",cipherkey_input_vectors);   
$readmemh("topcipher_test_outputs.txt",output_vectors); 

end 

initial begin
    $display ("###################################################");
    clk = 0;
    reset = 1;
    data_valid_in = 0;
	  cipherkey_valid_in = 0;
    dut_error = 0;    //design error counter
end

always 
  #5  clk =  !clk;   //clock generator
 
`ifndef GATES     //if not gate simulation 
initial begin  
    $dumpfile("Top_PipelinedCipher.vcd");
    $dumpvars;
end
`endif

initial 
forever @ (terminate_sim)  begin                  //simulation  termination logic
 $display ("Terminating simulation");
 if (dut_error == 0) begin
   $display ("Simulation Result : PASSED");
 end
 else begin
   $display ("Simulation Result : FAILED");
 end
 $display ("###################################################");
 #1 $stop;  

end

event reset_done;

initial                       //reset logic
forever begin
 @ (reset_enable);
 @ (negedge clk)
 $display ("Applying reset");
   reset = 0;
   data_expected = 'b0;
 @ (negedge clk)
   reset = 1;
 $display ("Came out of Reset");
 -> reset_done;
end  
     
initial begin                      
  #10 -> reset_enable;
  @ (reset_done);

  for (i=0;i< No_Patterns;i=i+1) begin      //apply inputs
  @ (posedge clk)
  #Clk2Q
  data_valid_in = 1;                       //assert valid signals
  cipherkey_valid_in = 1;
  plain_text = data_input_vectors[i];
  cipher_key = cipherkey_input_vectors[i];
  end
  
  @(posedge clk)
  data_valid_in = 0;                      //deassert valid signals
  cipherkey_valid_in = 0;
  
end

integer j;

initial @(reset_done) begin
    
repeat((4 * NO_ROUNDS)+1) begin          //waiting for first output (latency)
@(posedge clk);
end

for(j=0;j< No_Patterns;j=j+1) begin     //assign expected outputs
@(posedge clk)
data_expected = output_vectors[j];   
end
 
end
  
   
//compare logic

always @ (posedge clk) begin         
if (valid_out || (!reset)) begin 
  if(data_expected != cipher_text) begin
  $display ("DUT ERROR AT TIME%d",$time);
  $display ("Expected Data value %h, Got Data Value %h", data_expected, cipher_text);
  dut_error = 1;
   -> terminate_sim;                //stop simulation when error occures
  end
end
if(j == No_Patterns) begin         //terminate  simulation after the end of output vectors
   -> terminate_sim;
end
 end
endmodule