// ============================================================================
//  2009,2010  Robert Finch
//  rplaskitti[remove]@birdcomputer.ca
//  Stratford
//
//  
//  Detect an edge on nmi.
//
//
//  This source code is available for evaluation and validation purposes
//  only. This copyright statement and disclaimer must remain present in
//  the file.
//
//	NO WARRANTY.
//  THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
//  EXPRESS OR IMPLIED. The user must assume the entire risk of using the
//  Work.
//
//  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
//  INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
//  THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.
//
//  IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
//  IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
//  REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
//  LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
//  AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
//  LOSSES RELATING TO SUCH UNAUTHORIZED USE.
//
//
//  Verilog 
//
// ============================================================================
//
module nmi_detector(RESET, CLK, nmi_i, rst_nmi, pe_nmi);
input RESET;
input CLK;
input nmi_i;
input rst_nmi;				// reset the nmi flag
output pe_nmi;
reg pe_nmi;

reg prev_nmi;				// records previous nmi state

always @(posedge CLK)
    if (RESET) begin
        prev_nmi <= 1'b0;
        pe_nmi <= 1'b0;
    end
    else begin
        prev_nmi <= nmi_i;
        if (nmi_i & !prev_nmi)
            pe_nmi <= 1'b1;
        else if (rst_nmi)
            pe_nmi <= 1'b0;
    end

endmodule
