`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:56:11 10/07/2013 
// Design Name: 
// Module Name:    special_cases_mul_acc
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module special_cases_mul_acc	#(	parameter size_exception_field = 2'd2,
											parameter [size_exception_field - 1 : 0] zero = 0, //00
											parameter [size_exception_field - 1 : 0] normal_number 	= 1, //01
											parameter [size_exception_field - 1 : 0] infinity		= 2, //10
											parameter [size_exception_field - 1 : 0] NaN			= 3) //11
										( 	input [size_exception_field - 1 : 0] sp_case_a_number,
											input [size_exception_field - 1 : 0] sp_case_b_number,
											input [size_exception_field - 1 : 0] sp_case_c_number,
											output reg [size_exception_field - 1 : 0] sp_case_result_o); 
 
	always
		@(*)
	begin
		case ({sp_case_a_number, sp_case_b_number, sp_case_c_number})
			{zero, zero, zero}: 										sp_case_result_o = zero; 
			{zero, zero, normal_number}: 							sp_case_result_o = normal_number;
			{zero, zero, infinity}: 								sp_case_result_o = infinity;
			{zero, zero, NaN}: 										sp_case_result_o = NaN;
						
			{zero, normal_number,zero}:							sp_case_result_o = zero; 
			{zero, normal_number,normal_number}:				sp_case_result_o = normal_number;
			{zero, normal_number,infinity}:						sp_case_result_o = infinity; 
			{zero, normal_number,NaN}:								sp_case_result_o = NaN; 
				
			{zero, infinity, zero}: 								sp_case_result_o = NaN; 
			{zero, infinity, normal_number}: 					sp_case_result_o = NaN; 
			{zero, infinity, infinity}: 							sp_case_result_o = NaN; 
			{zero, infinity, NaN}: 									sp_case_result_o = NaN; 
				
			{zero, NaN, zero}: 										sp_case_result_o = NaN; 
			{zero, NaN, normal_number}: 							sp_case_result_o = NaN; 
			{zero, NaN, infinity}: 									sp_case_result_o = NaN; 
			{zero, NaN, NaN}: 										sp_case_result_o = NaN; 
				
			{normal_number, zero, zero}: 							sp_case_result_o = zero; 
			{normal_number, zero, normal_number}: 				sp_case_result_o = zero; 
			{normal_number, zero, infinity}: 					sp_case_result_o = infinity; 
			{normal_number, zero, NaN}: 							sp_case_result_o = NaN; 
				
			{normal_number, normal_number, zero}: 				sp_case_result_o = normal_number;
			{normal_number, normal_number, normal_number}: 	sp_case_result_o = normal_number;
			{normal_number, normal_number, infinity}: 		sp_case_result_o = infinity; 
			{normal_number, normal_number, NaN}: 				sp_case_result_o = NaN; 
				
			{normal_number, infinity, zero}: 					sp_case_result_o = infinity; 
			{normal_number, infinity, normal_number}: 		sp_case_result_o = infinity;
			{normal_number, infinity, infinity}: 				sp_case_result_o = infinity;
			{normal_number, infinity, NaN}: 						sp_case_result_o = NaN;
				
			{normal_number, NaN, zero}: 							sp_case_result_o = NaN; 
			{normal_number, NaN, normal_number}: 				sp_case_result_o = NaN; 
			{normal_number, NaN, infinity}: 						sp_case_result_o = NaN; 
			{normal_number, NaN, NaN}: 							sp_case_result_o = NaN; 
				
			{infinity, zero, zero}: 								sp_case_result_o = NaN; 
			{infinity, zero, normal_number}: 					sp_case_result_o = NaN; 
			{infinity, zero, infinity}: 							sp_case_result_o = NaN; 
			{infinity, zero, NaN}: 									sp_case_result_o = NaN; 
				
			{infinity, normal_number, zero}: 					sp_case_result_o = infinity; 
			{infinity, normal_number, normal_number}: 		sp_case_result_o = infinity; 
			{infinity, normal_number, infinity}: 				sp_case_result_o = infinity; 
			{infinity, normal_number, NaN}: 						sp_case_result_o = NaN; 
				
			{infinity, infinity, zero}: 							sp_case_result_o = infinity; 
			{infinity, infinity, normal_number}: 				sp_case_result_o = infinity; 
			{infinity, infinity, infinity}: 						sp_case_result_o = infinity; 
			{infinity, infinity, NaN}:	 							sp_case_result_o = NaN; 
				
			{infinity, NaN, zero}: 									sp_case_result_o = NaN; 
			{infinity, NaN, normal_number}: 						sp_case_result_o = NaN; 
			{infinity, NaN, infinity}: 							sp_case_result_o = NaN; 
			{infinity, NaN, NaN}: 									sp_case_result_o = NaN; 
				
			{NaN, zero, zero}: 										sp_case_result_o = NaN; 
			{NaN, zero, normal_number}: 							sp_case_result_o = NaN; 
			{NaN, zero, infinity}: 									sp_case_result_o = NaN; 
			{NaN, zero, NaN}: 										sp_case_result_o = NaN; 
				
			{NaN, normal_number, zero}: 							sp_case_result_o = NaN; 
			{NaN, normal_number, normal_number}: 				sp_case_result_o = NaN; 
			{NaN, normal_number, infinity}: 						sp_case_result_o = NaN; 
			{NaN, normal_number, NaN}: 							sp_case_result_o = NaN; 
				
			{NaN, infinity, zero}: 									sp_case_result_o = NaN; 
			{NaN, infinity, normal_number}: 						sp_case_result_o = NaN; 
			{NaN, infinity, infinity}: 							sp_case_result_o = NaN; 
			{NaN, infinity, NaN}: 									sp_case_result_o = NaN; 
				
			{NaN, NaN, zero}: 										sp_case_result_o = NaN; 
			{NaN, NaN, normal_number}: 							sp_case_result_o = NaN; 
			{NaN, NaN, infinity}: 									sp_case_result_o = NaN; 
			{NaN, NaN, NaN}: 											sp_case_result_o = NaN; 
			default:														sp_case_result_o = zero;
		endcase
	end
 
endmodule

