//-------------------------------------------------------------------------
//
// File name    :  ldpc_shuffle.v
// Title        :
//              :
// Purpose      : Barrel-rotate of NUINSTANCES, LLRWIDTH-bit inputs
//
// ----------------------------------------------------------------------
// Revision History :
// ----------------------------------------------------------------------
//   Ver  :| Author   :| Mod. Date   :| Changes Made:
//   v1.0  | JTC      :| 2008/07/02  :|
// ----------------------------------------------------------------------
`timescale 1ns/10ps

module ldpc_shuffle #(
  parameter FOLDFACTOR     = 4,
  parameter NUMINSTANCES   = 360/FOLDFACTOR,
  parameter LOG2INSTANCES  = 10 - FOLDFACTOR,
  parameter LLRWIDTH       = 4,
  parameter LASTSHIFTWIDTH = 3,
  parameter LASTSHIFTDIST  = 6
)(
  input clk,
  input rst,

  // control inputs
  input                     first_half,
  input[1:0]                shift0,
  input[2:0]                shift1,
  input[LASTSHIFTWIDTH-1:0] shift2,

  // message I/O
  input[NUMINSTANCES*LLRWIDTH-1:0]  vn_concat,
  input[NUMINSTANCES*LLRWIDTH-1:0]  cn_concat,
  output[NUMINSTANCES*LLRWIDTH-1:0] sh_concat
);

/*----------------*
 * Shift stage 0  *
 *----------------*/
wire[LLRWIDTH-1:0]     unshifted[NUMINSTANCES-1:0];
wire[LLRWIDTH-1:0]     shifted_0[NUMINSTANCES-1:0];

// convert to 2-d array to make simulation easier to follow, and mux vn/cn msgs
generate
  genvar vecpos;

  for( vecpos=0; vecpos<NUMINSTANCES; vecpos=vecpos+1 )
  begin: to2d
    assign unshifted[vecpos] =
      first_half ? vn_concat[vecpos*LLRWIDTH+LLRWIDTH-1 -: LLRWIDTH]
                 : cn_concat[vecpos*LLRWIDTH+LLRWIDTH-1 -: LLRWIDTH];
  end
endgenerate

// shift distance is shift0* SHIFT0_MULT, where SHIFT0_MULT=
// ceiling(360/FOLDFACTOR/4)
localparam SHIFT0_MULT = (FOLDFACTOR==1) ? 90 :
                         (FOLDFACTOR==2) ? 45 :
                         (FOLDFACTOR==3) ? 30 :
                         /* 4 */           23;

generate
  genvar pos0;

  for( pos0=0; pos0<NUMINSTANCES; pos0=pos0+1 )
  begin: quartershift
    wire[4*LLRWIDTH-1:0] muxinp0;

    assign muxinp0 = { unshifted[(NUMINSTANCES+pos0-3*SHIFT0_MULT) %NUMINSTANCES],
                       unshifted[(NUMINSTANCES+pos0-2*SHIFT0_MULT) %NUMINSTANCES],
                       unshifted[(NUMINSTANCES+pos0-  SHIFT0_MULT) %NUMINSTANCES],
                       unshifted[pos0]  };

    ldpc_muxreg #(
      .LLRWIDTH(LLRWIDTH),
      .NUMINPS (4),
      .MUXSIZE (4),
      .SELBITS (2)
    ) ldpc_muxregi (
      .clk( clk ),
      .rst( rst ),
      .sel( shift0 ),
      .din( muxinp0 ),
      .dout( shifted_0[pos0] )
    );
  end
endgenerate

/*----------------*
 * Shift stage 1  *
 *----------------*/
wire[LLRWIDTH-1:0]     shifted_1[NUMINSTANCES-1:0];

// shift distance is shift1* SHIFT1_MULT, where SHIFT1_MULT=
// ceiling(360/FOLDFACTOR/4/8)
localparam SHIFT1_MULT = (FOLDFACTOR==1) ? 12 :
                         (FOLDFACTOR==2) ? 6  :
                         (FOLDFACTOR==3) ? 4  :
                         /* 4 */           3;

generate
  genvar pos1;

  for( pos1=0; pos1<NUMINSTANCES; pos1=pos1+1 )
  begin: middleshift
    wire[8*LLRWIDTH-1:0] muxinp1;

    assign muxinp1 = { shifted_0[(NUMINSTANCES+pos1-7*SHIFT1_MULT) %NUMINSTANCES],
                       shifted_0[(NUMINSTANCES+pos1-6*SHIFT1_MULT) %NUMINSTANCES],
                       shifted_0[(NUMINSTANCES+pos1-5*SHIFT1_MULT) %NUMINSTANCES],
                       shifted_0[(NUMINSTANCES+pos1-4*SHIFT1_MULT) %NUMINSTANCES],
                       shifted_0[(NUMINSTANCES+pos1-3*SHIFT1_MULT) %NUMINSTANCES],
                       shifted_0[(NUMINSTANCES+pos1-2*SHIFT1_MULT) %NUMINSTANCES],
                       shifted_0[(NUMINSTANCES+pos1-  SHIFT1_MULT) %NUMINSTANCES],
                       shifted_0[pos1]  };

    ldpc_muxreg #(
      .LLRWIDTH(LLRWIDTH),
      .NUMINPS (8),
      .MUXSIZE (8),
      .SELBITS (3)
    ) ldpc_muxregi (
      .clk( clk ),
      .rst( rst ),
      .sel( shift1 ),
      .din( muxinp1 ),
      .dout( shifted_1[pos1] )
    );
  end
endgenerate
  
/*----------------*
 * Shift stage 2  *
 *----------------*/
// This stage is a little more complicated than the others, since there is a
// maximum shift distance
wire[LLRWIDTH-1:0]    shifted_2[NUMINSTANCES-1:0];
reg[NUMINSTANCES-1:0] increment_int;

generate
  genvar pos2;

  for( pos2=0; pos2<NUMINSTANCES; pos2=pos2+1 )
  begin: lastshift
    wire[12*LLRWIDTH-1:0] muxinp2;
    
    assign muxinp2 = { shifted_1[(NUMINSTANCES+pos2-11) %NUMINSTANCES],
                       shifted_1[(NUMINSTANCES+pos2-10) %NUMINSTANCES],
                       shifted_1[(NUMINSTANCES+pos2-9)  %NUMINSTANCES],
                       shifted_1[(NUMINSTANCES+pos2-8)  %NUMINSTANCES],
                       shifted_1[(NUMINSTANCES+pos2-7)  %NUMINSTANCES],
                       shifted_1[(NUMINSTANCES+pos2-6)  %NUMINSTANCES],
                       shifted_1[(NUMINSTANCES+pos2-5)  %NUMINSTANCES],
                       shifted_1[(NUMINSTANCES+pos2-4)  %NUMINSTANCES],
                       shifted_1[(NUMINSTANCES+pos2-3)  %NUMINSTANCES],
                       shifted_1[(NUMINSTANCES+pos2-2)  %NUMINSTANCES],
                       shifted_1[(NUMINSTANCES+pos2-1)  %NUMINSTANCES],
                       shifted_1[pos2]  };

    ldpc_muxreg #(
      .LLRWIDTH(LLRWIDTH),
      .NUMINPS (12),
      .MUXSIZE ((LASTSHIFTDIST+1)),
      .SELBITS (LASTSHIFTWIDTH)
    ) ldpc_muxregi (
      .clk( clk ),
      .rst( rst ),
      .sel( shift2 ),
      .din( muxinp2 ),
      .dout( shifted_2[pos2] )
    );
  end
endgenerate

// assign 2-d array to 1-d output port
generate
  genvar ovecpos;

  for( ovecpos=0; ovecpos<NUMINSTANCES; ovecpos=ovecpos+1 )
  begin: to1d
    assign sh_concat[ovecpos*LLRWIDTH+LLRWIDTH-1 -: LLRWIDTH] =
              shifted_2[ovecpos];
  end
endgenerate

// decode
localparam SECTION_LEN = (FOLDFACTOR==1) ? 90 :
                         (FOLDFACTOR==2) ? 45 :
                         (FOLDFACTOR==3) ? 30 :
                                           23;
function[SECTION_LEN-1:0] Decoder( input[LOG2INSTANCES-3:0] incpointxx );
  integer position;
begin
  Decoder[0] = incpointxx==0;
  
  for( position=1; position<SECTION_LEN; position=position+1 )
    Decoder[position] = (incpointxx==position) || Decoder[position-1];
end
endfunction

endmodule
