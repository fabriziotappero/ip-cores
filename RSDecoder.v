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


module RSDecoder(recword, start, clock1, clock2, reset, ready,
               errfound, decode_fail, dataoutstart, dataoutend,
               corr_recword);

input [4:0] recword;
input clock1, clock2;
input start, reset;
output ready, decode_fail, errfound, dataoutstart, dataoutend;
output [4:0] corr_recword;

wire active_sc, active_kes, active_csee, en_sccell;
wire evalsynd, holdsynd, evalerror, lastdataout;
wire shift_fifo, hold_fifo, en_infifo, en_outfifo;
wire errdetect, finish_kes;
wire [4:0] dataout_fifo, errorvalue;

wire [4:0] syndvalue0, syndvalue1, syndvalue2, syndvalue3, 
           syndvalue4, syndvalue5, syndvalue6, syndvalue7, 
           syndvalue8, syndvalue9, syndvalue10, syndvalue11;
wire [4:0] lambda0, lambda1, lambda2, lambda3, lambda4, lambda5, 
           lambda6;
wire [4:0] homega0, homega1, homega2, homega3, homega4, homega5;
wire [2:0] rootcntr, lambda_degree;

//****************************//
assign en_sccell = shift_fifo;

SCblock SCblock(recword, clock1, clock2, active_sc, reset, syndvalue0,
               syndvalue1, syndvalue2, syndvalue3, syndvalue4, 
               syndvalue5, syndvalue6, syndvalue7, syndvalue8, 
               syndvalue9, syndvalue10, syndvalue11, errdetect, 
               en_sccell, evalsynd, holdsynd);
KES_block KESblock(active_kes, clock1, clock2, reset, syndvalue0, syndvalue1,                 syndvalue2, syndvalue3, syndvalue4, syndvalue5, syndvalue6, 
                syndvalue7, syndvalue8, syndvalue9, syndvalue10, syndvalue11, 
                lambda0, lambda1, lambda2, lambda3, lambda4, lambda5, 
                lambda6, homega0, homega1, homega2, homega3, homega4, 
                homega5, lambda_degree, finish_kes);
CSEEblock CSEEblock(lambda0, lambda1, lambda2, lambda3, lambda4,
                  lambda5, lambda6, homega0, homega1, homega2,
                  homega3, homega4, homega5, errorvalue, clock1,
                  clock2, active_csee, reset, lastdataout, evalerror,
                  en_outfifo, rootcntr);
MainControl controller(start, reset, clock1, clock2, finish_kes,
                  errdetect, rootcntr, lambda_degree, active_sc, 
                  active_kes, active_csee, evalsynd, holdsynd, 
                  errfound, decode_fail, ready, dataoutstart, dataoutend, 
                  shift_fifo, hold_fifo, en_infifo, en_outfifo, 
                  lastdataout, evalerror);
fifo_register fiforeg(clock1, clock2, shift_fifo, hold_fifo, 
                     en_outfifo, en_infifo, recword, dataout_fifo);

// Received word correction//
gfadder adder(errorvalue, dataout_fifo, corr_recword);                                  

endmodule