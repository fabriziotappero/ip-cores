/***************************************************
 * Module: hazard_detection_unit
 * Project: mips_16
 * Author: fzy
 * Description: 
 *    Data Hazard detection. if there is a RAW hazard, it will stall the pipeline.
 *	
 *	 *	 Method: It compare the source register of the instruction in ID_stage 
 * 			 and it's previous 3 instructions' destination register. If
 *			 the source register is equal to any of the three destination regs 
 *			 and not equals to zero, the Hazard Detction Unit will assert
 *			 pipeline_stall signal. That signal will freeze the IF & ID stage,
 *			 and insert bubbles into EX stage. When the hazard instruction 
 *			 was flushed out of the pipeline, pipeline_stall signal will 
 *			 be canceled.
 *
 * Revise history:
 *     
 ***************************************************/
module hazard_detection_unit
(
	input		[2:0]		decoding_op_src1,		//ID stage source_1 register number
	input		[2:0]		decoding_op_src2,		//ID stage source_2 register number
	
	input		[2:0]		ex_op_dest,				//EX stage destinaton register number
	input		[2:0]		mem_op_dest,			//MEM stage destinaton register number
	input		[2:0]		wb_op_dest,				//WB stage destinaton register number
	
	output	reg				pipeline_stall_n		// Active low
);
	
	always @ (*) begin
		pipeline_stall_n = 1;
		
		if( decoding_op_src1 != 0 &&
			(
				decoding_op_src1 == ex_op_dest	||
				decoding_op_src1 == mem_op_dest	||
				decoding_op_src1 == wb_op_dest	
			)
		)
			pipeline_stall_n = 0;
			
		if( decoding_op_src2 != 0 &&
			(
				decoding_op_src2 == ex_op_dest	||
				decoding_op_src2 == mem_op_dest	||
				decoding_op_src2 == wb_op_dest	
			)
		)
			pipeline_stall_n = 0;
		
		
	end
	
	
	
endmodule 