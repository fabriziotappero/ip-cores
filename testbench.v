///*************************************************************///
///                                                             ///
///          Reed-Solomon Decoder (31,19,6)                     ///
///                                                             ///
///                                                             ///
///          Author : Rudy Dwi Putra                            ///
///                   rudy.dp@gmail.com                         ///
///                                                             ///
///*************************************************************///
///                                                             ///
/// Copyright (C) 2006  Rudy Dwi Putra                          ///
///                     rudy.dp@gmail.com                       ///
///                                                             ///
/// This source file may be used and distributed without        ///
/// restriction provided that this copyright statement is not   ///
/// removed from the file and that any derivative work contains ///
/// the original copyright notice and the associated disclaimer.///
///                                                             ///
///     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ///
/// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ///
/// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ///
/// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ///
/// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ///
/// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ///
/// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ///
/// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ///
/// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ///
/// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ///
/// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ///
/// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ///
/// POSSIBILITY OF SUCH DAMAGE.                                 ///
///                                                             ///
///*************************************************************///

//***************************************//
// Testbench for RS Decoder (31, 19, 6)  //
//***************************************//

module testbench_rsdecoder;
    
reg [4:0] recword;
reg clock1, clock2;
reg start, reset;

//******************************************************//
// ready = if set to 1, decoder is ready to input or it //
// is inputting new data																//
// dataoutstart = flag the first symbol of outputted 		//
// received word.																				//
// dataoutend = flag the last symbol of outputted				//
// received word.																				//
// errfound = set to 1, if one of syndrome values 			//
// is not zero.																					//
// decode_fail = set to 1, if decoder fails to correct	//
// the received word.																		//
//******************************************************//
wire ready, decode_fail, errfound, dataoutstart, dataoutend;
wire [4:0] corr_recword;

parameter [5:0] clk_period = 50;

initial
begin
   recword = 5'b0;
   start = 0;
   reset = 0; 
end

//**********//
//  clock1  //
//**********//
initial
begin
    clock1 = 0;
    forever #(clk_period/2) clock1 = ~clock1;
end

//**********//
//  clock2  //
//**********//
initial
begin
    clock2 = 1;
    forever #(clk_period/2) clock2 = ~clock2;
end

//***********************************************//
// This section defines feeding of received word //
// and start signal. Start signal is active 1    //
// clock cycle before first symbol of received   //
// word. All input and output synchronize with   //
// clock2. First received word contains no error //
// symbol. Thus, all syndrome values will be zero//
// and decoder will pass the received word.      //
// Second received word contains 6 error symbol. //
// Decoder will determine its error locator      //
// and error evaluator polynomial in KES block.  //
// Then, it calculates error values in CSEE      //
// block. Third received word contains 8 error   //
// symbol. Decoder can't correct the error and   //
// at the end of outputted received word, it will//
// set decode_fail to 1.                         //
//***********************************************//  
initial
begin
    #(clk_period) reset = 1;
    
    //start has to be active 1 clock cycle before first recword, 
    //otherwise decoder will output wrong recword.
    #(clk_period) start = 1; 
    #(clk_period) start = 0;
    
    //First received word contains no error symbol.
    //The decoder should give errfound = 0 at the end
    //of syndrome calculation stage.
    recword = 5'b10100;
    #(clk_period) recword = 5'b00100;
    #(clk_period) recword = 5'b00101;
    #(clk_period) recword = 5'b10001;
    #(clk_period) recword = 5'b10110;
    #(clk_period) recword = 5'b00001;
    #(clk_period) recword = 5'b00010;
    #(clk_period) recword = 5'b11100;
    #(clk_period) recword = 5'b00011;
    #(clk_period) recword = 5'b10001;
    #(clk_period) recword = 5'b00110;
    #(clk_period) recword = 5'b00111;
    #(clk_period) recword = 5'b01010;
    #(clk_period) recword = 5'b11111;
    #(clk_period) recword = 5'b01011;
    #(clk_period) recword = 5'b10100;
    #(clk_period) recword = 5'b00100;
    #(clk_period) recword = 5'b00101;
    #(clk_period) recword = 5'b00001;
    #(clk_period) recword = 5'b10111;
    #(clk_period) recword = 5'b10100;
    #(clk_period) recword = 5'b00010;
    #(clk_period) recword = 5'b10110;
    #(clk_period) recword = 5'b00100;
    #(clk_period) recword = 5'b01011;
    #(clk_period) recword = 5'b00110;
    #(clk_period) recword = 5'b11110;
    #(clk_period) recword = 5'b10100;
    #(clk_period) recword = 5'b11111;
    #(clk_period) recword = 5'b01010;
    #(clk_period) recword = 5'b11110;
    #(clk_period) recword = 5'b0;
    
    
    #(18*clk_period) start = 1;
    #(clk_period) start = 0;
    
    //Second received word contains 6 error symbols.
    //The decoder sets errfound = 1, and activates
    //KES block and then CSEE block. Because the
    //number of errors is equal to correction capability
    //of the decoder, decoder can correct the received
    //word.
    recword = 5'b01100; //it should be 5'b10100
    #(clk_period) recword = 5'b00100; 
    #(clk_period) recword = 5'b00101;
    #(clk_period) recword = 5'b10001;
    #(clk_period) recword = 5'b10110;
    #(clk_period) recword = 5'b00001;
    #(clk_period) recword = 5'b00110; //it should be 5'b00010
    #(clk_period) recword = 5'b11100;
    #(clk_period) recword = 5'b00011;
    #(clk_period) recword = 5'b10001;
    #(clk_period) recword = 5'b00110;
    #(clk_period) recword = 5'b00101; //it should be 5'b00111
    #(clk_period) recword = 5'b01010;
    #(clk_period) recword = 5'b11111;
    #(clk_period) recword = 5'b11111; //it should be 5'b01011
    #(clk_period) recword = 5'b10100;
    #(clk_period) recword = 5'b00100;
    #(clk_period) recword = 5'b00101;
    #(clk_period) recword = 5'b00001;
    #(clk_period) recword = 5'b10111;
    #(clk_period) recword = 5'b01101; //it should be 5'b10100
    #(clk_period) recword = 5'b00010;
    #(clk_period) recword = 5'b10110;
    #(clk_period) recword = 5'b00100;
    #(clk_period) recword = 5'b01011;
    #(clk_period) recword = 5'b00110;
    #(clk_period) recword = 5'b11110;
    #(clk_period) recword = 5'b10100;
    #(clk_period) recword = 5'b10101; //it should be 5'b11111
    #(clk_period) recword = 5'b01010;
    #(clk_period) recword = 5'b11110;
    #(clk_period) recword = 5'b0;
    
    #(20*clk_period) start = 1;
    #(clk_period) start = 0;
    //Third received word contains 8 error symbols.
    //Because the number of errors is greater than correction
    //capability, decoder will resume decoding failure at the end of
    //outputted received word.
    recword = 5'b10100;
    #(clk_period) recword = 5'b00100; 
    #(clk_period) recword = 5'b00101;
    #(clk_period) recword = 5'b10001;
    #(clk_period) recword = 5'b10110;
    #(clk_period) recword = 5'b00100; //it should be 5'b00001
    #(clk_period) recword = 5'b00010; 
    #(clk_period) recword = 5'b11100;
    #(clk_period) recword = 5'b10010; //it should be 5'b00011
    #(clk_period) recword = 5'b10101; //it should be 5'b10001
    #(clk_period) recword = 5'b00110;
    #(clk_period) recword = 5'b10011; //it should be 5'b00111
    #(clk_period) recword = 5'b01010;
    #(clk_period) recword = 5'b11111;
    #(clk_period) recword = 5'b01011; 
    #(clk_period) recword = 5'b10100;
    #(clk_period) recword = 5'b00110; //it should be 5'b00100
    #(clk_period) recword = 5'b00101;
    #(clk_period) recword = 5'b00100; //it should be 5'b00001
    #(clk_period) recword = 5'b10110; //it should be 5'b10111
    #(clk_period) recword = 5'b10100;
    #(clk_period) recword = 5'b00010;
    #(clk_period) recword = 5'b10110;
    #(clk_period) recword = 5'b00100;
    #(clk_period) recword = 5'b01011;
    #(clk_period) recword = 5'b00110;
    #(clk_period) recword = 5'b11110;
    #(clk_period) recword = 5'b10010; //it should be 5'b10100
    #(clk_period) recword = 5'b11111; 
    #(clk_period) recword = 5'b01010;
    #(clk_period) recword = 5'b11110;
    #(clk_period) recword = 5'b0;
end


RSDecoder rsdecoder(recword, start, clock1, clock2, reset, ready,
                  errfound, decode_fail, dataoutstart, dataoutend,
                  corr_recword);

endmodule