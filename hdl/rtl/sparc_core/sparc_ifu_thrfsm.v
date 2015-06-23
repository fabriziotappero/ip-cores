// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc_ifu_thrfsm.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
// 
// The above named program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
// 
// ========== Copyright Header End ============================================
////////////////////////////////////////////////////////////////////////
/*
//  Module Name: sparc_ifu_swlthrfsm
//  Description:	
//  The switch logithrfsm contains the thread state machine.  
*/

/*
/* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: ifu.h
* Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
* DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
* 
* The above named program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License version 2 as published by the Free Software Foundation.
* 
* The above named program is distributed in the hope that it will be 
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
* 
* You should have received a copy of the GNU General Public
* License along with this work; if not, write to the Free Software
* Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
* 
* ========== Copyright Header End ============================================
*/
////////////////////////////////////////////////////////////////////////
/*
//
//  Module Name: ifu.h
//  Description:	
//  All ifu defines
*/

//--------------------------------------------
// Icache Values in IFU::ICD/ICV/ICT/FDP/IFQDP
//--------------------------------------------
// Set Values

// IC_IDX_HI = log(icache_size/4ways) - 1


// !!IMPORTANT!! a change to IC_LINE_SZ will mean a change to the code as
//   well.  Unfortunately this has not been properly parametrized.
//   Changing the IC_LINE_SZ param alone is *not* enough.


// !!IMPORTANT!! a change to IC_TAG_HI will mean a change to the code as
//   well.  Changing the IC_TAG_HI param alone is *not* enough to
//   change the PA range. 
// highest bit of PA



// Derived Values
// 4095


// number of entries - 1 = 511


// 12


// 28


// 7


// tags for all 4 ways + parity
// 116


// 115



//----------------------------------------------------------------------
// For thread scheduler in IFU::DTU::SWL
//----------------------------------------------------------------------
// thread states:  (thr_state[4:0])









// thread configuration register bit fields







//----------------------------------------------------------------------
// For MIL fsm in IFU::IFQ
//----------------------------------------------------------------------











//---------------------------------------------------
// Interrupt Block
//---------------------------------------------------







//-------------------------------------
// IFQ
//-------------------------------------
// valid bit plus ifill













//`ifdef SPARC_L2_64B


//`else
//`define BANK_ID_HI 8
//`define BANK_ID_LO 7
//`endif

//`define CPX_INV_PA_HI  116
//`define CPX_INV_PA_LO  112







//----------------------------------------
// IFU Traps
//----------------------------------------
// precise















// disrupting








module sparc_ifu_thrfsm(/*AUTOARG*/
   // Outputs
   so, thr_state, 
   // Inputs
   completion, schedule, spec_ld, ldhit, stall, int_activate, 
   start_thread, thaw_thread, nuke_thread, rst_thread, switch_out, 
   halt_thread, sw_cond, clk, se, si, reset
   );

   // thread specific input
   input  completion,   // the op this thread was waiting for is complete
	        schedule,     // this thread was just switched in
	        spec_ld,      // speculative switch in
	        ldhit,        // speculation was correct
	        stall,        // stall thread for ldmiss, imiss or trap
	        int_activate, // activate this thread
          halt_thread,
	        start_thread,    // wake up this thread from dead state
	        nuke_thread,
          thaw_thread,
	        rst_thread;      // reset this thread

   // common inputs
   input  switch_out,   // this thread was just switched out
	        sw_cond;	// wait until completion signal is received

   input       clk, se, si, reset;

   output      so;

   output [4:0] thr_state;

   // local signals
   reg [4:0]    next_state;
   
   //
   // Code Begins Here
   //
   
//   assign       spec_rdy     = thr_state[`TCR_READY];

   always @ (/*AUTOSENSE*/ completion
             or halt_thread or int_activate or ldhit or nuke_thread
             or rst_thread or schedule or spec_ld or stall
             or start_thread or sw_cond or switch_out or thaw_thread 
             or thr_state)
     begin
	      case (thr_state[4:0])
          5'b00000:  // 5'b00000
	          begin
	             if (rst_thread | thaw_thread)
		             next_state = 5'b00001;
	             else if (start_thread)    
		             next_state = 5'b11001;
	             else  // all other interrupts ignored
		             next_state = thr_state[4:0];
	          end

	        5'b00010:  // 5'b00010
	          begin
	             if (nuke_thread)
		             next_state = 5'b00000;
	             else if (rst_thread | thaw_thread)
		             next_state = 5'b00001;
	             else if (int_activate | start_thread) 
		             next_state = 5'b11001;
	             else
		             next_state = thr_state[4:0];
	          end
	        
	        5'b11001:       // 5'b11001
	          begin
	             if (stall)     
		             // trap also kills inst_s2 and nir
		             // Ldmiss should not happen in this state
		             next_state = 5'b00001;
	             else if (schedule)
		             next_state = 5'b00101;
	             else
		             next_state = thr_state[4:0];
	          end // case: `THRFSM_RDY

	        5'b00101:       // 5'b00101
	          begin
	             if (stall | sw_cond)
		             // trap also kills inst_s2 and nir
		             // ldmiss should not happen in this state		 
		             next_state = 5'b00001;
	             else if (switch_out)
	               // on an interrupt or thread stall, the fcl has to
	               // switch out the thread and inform the fsm 
		             next_state = 5'b11001;
	             else
		             next_state = thr_state[4:0];
	          end // case: `THRFSM_RUN

	        5'b00001:       // 5'b00001
	          begin
	             if (nuke_thread) 
		             next_state = 5'b00000;
	             else if (halt_thread) // exclusive with above
		             next_state = 5'b00010;
	             else if (stall) // excl. with above
		             next_state = 5'b00001;
	             else if (spec_ld) // exclusive with above
		             next_state = 5'b10011;
	             else if (completion & ~halt_thread)
		             next_state = 5'b11001;
	             else
		             next_state = thr_state[4:0];
	          end // case: `THRFSM_WAIT
	        
	        5'b10011:       // 5'b10011
	          begin
	             if (stall)
		             next_state = 5'b00001;
	             else if (schedule & ~ldhit) // exclusive
		             next_state = 5'b00111;
	             else if (schedule & ldhit)  // exclusive
		             next_state = 5'b00101;
	             else if (ldhit)
		             next_state = 5'b11001;
	             else
		             next_state = thr_state[4:0];
	          end // case: `THRFSM_SPEC_RDY

	        5'b00111:       // 5'b00111
	          begin
	             if (stall | sw_cond)
		             next_state = 5'b00001;
	             else if ((ldhit) & switch_out)
		             next_state = 5'b11001;
	             else if ((ldhit) & ~switch_out)
		             next_state = 5'b00101;
	             else if (~(ldhit) & switch_out)
		             next_state = 5'b10011;
	             // on an interrupt or thread stall, the fcl has to
	             // switch out the thread and inform the fsm 
	             else
		             next_state = thr_state[4:0];
	          end // case: `THRFSM_SPEC_RUN

//VCS coverage off
	        default:
	          begin
               // synopsys translate_off
		     // 0in <fire -message "thrfsm.v: Error! Invalid State"

           
		


	             //$display("ILLEGAL_THR_STATE", "thrfsm.v: Error! Invalid State %b\n", thr_state);
				 
		     
               // synopsys translate_on
	             if (rst_thread)
		             next_state = 5'b00001;
	             else if (nuke_thread)
		             next_state = 5'b00000;		 
	             else 
		             next_state = thr_state[4:0];
	          end
//VCS coverage on
	      endcase // casex({thr_state[4:0]})
     end // always @ (...

   // thread config register (tcr)
   dffr #(5) tcr(.din  (next_state),
	             .clk  (clk),
	             .q    (thr_state),
	             .rst  (reset),
	             .se   (se), .so(), .si());


endmodule
