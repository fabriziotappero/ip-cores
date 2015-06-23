//----------------------------------------------------------------------------
// Copyright (C) 2009 , Olivier Girard
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the authors nor the names of its contributors
//       may be used to endorse or promote products derived from this software
//       without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
// THE POSSIBILITY OF SUCH DAMAGE
//
//----------------------------------------------------------------------------
// 
// *File Name: omsp_timerA_undefines.v
// 
// *Module Description:
//                      omsp_timerA Verilog `undef file
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 23 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-08-30 18:39:26 +0200 (Sun, 30 Aug 2009) $
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// SYSTEM CONFIGURATION
//----------------------------------------------------------------------------



//==========================================================================//
//==========================================================================//
//==========================================================================//
//==========================================================================//
//=====        SYSTEM CONSTANTS --- !!!!!!!! DO NOT EDIT !!!!!!!!      =====//
//==========================================================================//
//==========================================================================//
//==========================================================================//
//==========================================================================//

// Timer A: TACTL Control Register
`ifdef TASSELx
`undef TASSELx
`endif
`ifdef TAIDx
`undef TAIDx
`endif
`ifdef TAMCx
`undef TAMCx
`endif
`ifdef TACLR
`undef TACLR
`endif
`ifdef TAIE
`undef TAIE
`endif
`ifdef TAIFG
`undef TAIFG
`endif

// Timer A: TACCTLx Capture/Compare Control Register
`ifdef TACMx
`undef TACMx
`endif
`ifdef TACCISx
`undef TACCISx
`endif
`ifdef TASCS
`undef TASCS
`endif
`ifdef TASCCI
`undef TASCCI
`endif
`ifdef TACAP
`undef TACAP
`endif
`ifdef TAOUTMODx
`undef TAOUTMODx
`endif
`ifdef TACCIE
`undef TACCIE
`endif
`ifdef TACCI
`undef TACCI
`endif
`ifdef TAOUT
`undef TAOUT
`endif
`ifdef TACOV
`undef TACOV
`endif
`ifdef TACCIFG
`undef TACCIFG
`endif
