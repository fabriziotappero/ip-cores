<' 
import alu_components;

unit alu_mon_u {
	alu_result: in simple_port of byte;
	alu_status: in simple_port of byte;
	alu_x: in simple_port of byte;
	alu_y: in simple_port of byte;

	event main_clk;

	on main_clk {
		agent.chk.compare(alu_result$, alu_status$, alu_x$, alu_y$);

	};
};
'>
