
task code_read;
begin
	cyc_type <= `CT_CODE;
	cyc_o <= 1'b1;
	stb_o <= 1'b1;
	we_o <= 1'b0;
	adr_o <= csip;
end
endtask

task read;
input [2:0] ct;
input [19:0] ad;
begin
	cyc_type <= ct;
	cyc_o <= 1'b1;
	stb_o <= 1'b1;
	we_o <= 1'b0;
	adr_o <= ad;
end
endtask

task pause_read;
begin
	cyc_type <= `CT_PASSIVE;
	stb_o <= 1'b0;
end
endtask

task write;
input [2:0] ct;
input [19:0] ad;
input [7:0] dat;
begin
	cyc_type <= ct;
	cyc_o <= 1'b1;
	stb_o <= 1'b1;
	we_o <= 1'b1;
	adr_o <= ad;
	dat_o <= dat;
end
endtask

task nack;
begin
	cyc_type <= `CT_PASSIVE;
	cyc_o <= 1'b0;
	stb_o <= 1'b0;
	we_o <= 1'b0;
	adr_o <= 20'd0;
	dat_o <= 8'd0;
end
endtask

task nack_ir;
begin
	nack();
	ir <= dat_i;
	ip <= ip_inc;
end
endtask

task nack_ir2;
begin
	nack();
	ir2 <= dat_i;
	ip <= ip_inc;
end
endtask

task pause_code_read;
begin
	cyc_type <= `CT_PASSIVE;
	stb_o <= 1'b0;
	ip <= ip_inc;
end
endtask

task continue_code_read;
begin
	cyc_type <= `CT_CODE;
	stb_o <= 1'b1;
	adr_o <= csip;
end
endtask

task term_code_read;
begin
	nack();
	ip <= ip_inc;
end
endtask

task stack_push;
begin
	cyc_type <= `CT_WRMEM;
	cyc_o <= 1'b1;
	stb_o <= 1'b1;
	we_o <= 1'b1;
	adr_o <= sssp;
end
endtask

task pause_stack_push;
begin
	cyc_type <= `CT_PASSIVE;
	sp <= sp_dec;
	stb_o <= 1'b0;
	we_o <= 1'b0;
end
endtask

task stack_pop;
begin
	cyc_type <= `CT_RDMEM;
	lock_o <= 1'b1;
	cyc_o <= 1'b1;
	stb_o <= 1'b1;
	adr_o <= sssp;
end
endtask

task pause_stack_pop;
begin
	cyc_type <= `CT_PASSIVE;
	stb_o <= 1'b0;
	sp <= sp_inc;
end
endtask

task continue_stack_pop;
begin
	cyc_type <= `CT_RDMEM;
	stb_o <= 1'b1;
	adr_o <= sssp;
end
endtask

task stack_pop_nack;
begin
	lock_o <= bus_locked;
	sp <= sp_inc;
	nack();
end
endtask

