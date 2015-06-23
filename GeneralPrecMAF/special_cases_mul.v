
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:56:11 10/07/2013 
// Design Name: 
// Module Name:    special_cases_mul
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
module special_cases_mul	#(	parameter size_exception_field = 2'd2,
								parameter [size_exception_field - 1 : 0] zero = 0, //00
								parameter [size_exception_field - 1 : 0] normal_number 	= 1, //01
								parameter [size_exception_field - 1 : 0] infinity		= 2, //10
								parameter [size_exception_field - 1 : 0] NaN			= 3) //11
							( 	input [size_exception_field - 1 : 0] sp_case_a_number,
								input [size_exception_field - 1 : 0] sp_case_b_number,
								output reg [size_exception_field - 1 : 0] sp_case_result_o); 
 
	always
		@(*)
	begin
		case ({sp_case_a_number, sp_case_b_number})
			{zero, zero}: 						sp_case_result_o = zero; 
			{zero, normal_number}: 				sp_case_result_o = zero;
			{zero, infinity}: 					sp_case_result_o = NaN;
			{zero, NaN}: 						sp_case_result_o = NaN;
						
			{normal_number,zero}:				sp_case_result_o = zero; 
			{normal_number,normal_number}:		sp_case_result_o = normal_number;
			{normal_number,infinity}:			sp_case_result_o = infinity; 
			{normal_number,NaN}:				sp_case_result_o = NaN; 
				
			{infinity, zero}: 					sp_case_result_o = NaN; 
			{infinity, normal_number}: 			sp_case_result_o = infinity; 
			{infinity, infinity}: 				sp_case_result_o = NaN; 
			{infinity, NaN}: 					sp_case_result_o = NaN; 
				
			{NaN, zero}: 						sp_case_result_o = NaN; 
			{NaN, normal_number}: 				sp_case_result_o = NaN; 
			{NaN, infinity}: 					sp_case_result_o = NaN; 
			{NaN, NaN}: 						sp_case_result_o = NaN; 
			
			default:							sp_case_result_o = zero;
		endcase
	end
 
endmodule

