/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE revB.3 Registered Feedback Cycle checker          ////
////                                                             ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@ascis.ws                                   ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/vga_lcd/   ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2003 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

module wb_b3_check (clk_i, cyc_i, stb_i, we_i, cti_i, bte_i, ack_i, err_i, rty_i);

input       clk_i;
input       cyc_i;
input       stb_i;
input [2:0] cti_i;
input [1:0] bte_i;
input       we_i;
input       ack_i;
input       err_i;
input       rty_i;


parameter [2:0] cti_classic   = 3'b000;
parameter [2:0] cti_streaming = 3'b001;
parameter [2:0] cti_inc_burst = 3'b010;
parameter [2:0] cti_eob       = 3'b111;

// check CTI, BTE
reg [2:0] pcti; // previous cti
reg [1:0] pbte; // previous bte
reg       pwe;  // previous we
reg       chk;

integer wb_b3_err;

initial
begin
  chk = 0;
  wb_b3_err = 0;

  $display ("**********************************************");
  $display ("**                                          **");
  $display ("** WISBONE RevB.3 sanity check instantiated **");
  $display ("** (C) 2003 Richard Herveille               **");
  $display ("**                                          **");
  $display ("**********************************************");
end


always @(posedge clk_i)
  begin
      pcti <= #1 cti_i;
      pbte <= #1 bte_i;
      pwe  <= #1 we_i;
  end


always @(posedge clk_i)
  if (cyc_i) begin
    chk <= #1 1'b1;
  end else
    chk <= #1 1'b0;



//
// Check CTI_I
always @(cti_i)
 if (chk)
   if (cyc_i) begin
     if (ack_i)
       case (cti_i)
          cti_eob: ; // ok

          default:
            if ( (cti_i !== pcti) && (pcti !== cti_eob) ) begin
              $display("\nWISHBONE revB.3 Burst error. CTI change from %b to %b not allowed. (%t)\n",
                        pcti, cti_i, $time);

              wb_b3_err = wb_b3_err +1;
            end
       endcase
     else
       if ( (cti_i !== pcti) && (pcti !== cti_eob) ) begin
         $display("\nWISHBONE revB.3 Burst error. Illegal CTI change during burst transfer. (%t)\n",
                   $time);

         wb_b3_err = wb_b3_err +1;
       end
   end else
     case (pcti)
        cti_classic: ; //ok
        cti_eob: ;     // ok

        default: begin
          $display("\nWISHBONE revB.3 Burst error. Cycle negated without EOB (CTI=%b). (%t)\n",
                    pcti, $time);

          wb_b3_err = wb_b3_err +1;
        end
     endcase


//
// Check BTE_I
always @(bte_i)
 if (chk & cyc_i)
   if (ack_i) begin
     if ( (pcti !== cti_eob) && (bte_i !== pbte) ) begin
        $display("\nWISHBONE revB.3 Burst ERROR. BTE change from %b to %b not allowed. (%t)\n",
                  pbte, bte_i, $time);

        wb_b3_err = wb_b3_err +1;
     end
   end else begin
     $display("\nWISHBONE revB.3 Burst error. Illegal BTE change in burst cycle. (%t)\n",
               $time);

     wb_b3_err = wb_b3_err +1;
   end

//
// Check WE_I
always @(we_i)
 if (chk & cyc_i & stb_i)
   if (ack_i) begin
     if ( (pcti !== cti_eob) && (we_i !== pwe)) begin
       $display("\nWISHBONE revB.3 Burst ERROR. WE change from %b to %b not allowed. (%t)\n",
                 pwe, we_i, $time);

       wb_b3_err = wb_b3_err +1;
     end
   end else begin
     $display("\nWISHBONE revB.3 Burst error. Illegal WE change in burst cycle. (%t)\n",
               $time);

     wb_b3_err = wb_b3_err +1;
   end



//
// Check ACK_I, ERR_I, RTY_I
always @(posedge clk_i)
if (cyc_i & stb_i)
  case ({ack_i, err_i, rty_i})
     3'b000: ;
     3'b001: ;
     3'b010: ;
     3'b100: ;

     default: begin
        $display("\n WISHBONE revB.3 ERROR. Either ack(%0b), rty(%0b), or err(%0b) may be asserted. (%t)",
               ack_i, rty_i, err_i, $time);

        wb_b3_err = wb_b3_err +1;
     end
  endcase

//
// check errors
always @(wb_b3_err)
  if (chk && (wb_b3_err > 10) ) begin
    $display ("**********************************************");
    $display ("**                                          **");
    $display ("** More than 10 WISBONE RevB.3 errors found **");
    $display ("** Simulation stopped                       **");
    $display ("**                                          **");
    $display ("**********************************************");
    $stop;
  end
endmodule
