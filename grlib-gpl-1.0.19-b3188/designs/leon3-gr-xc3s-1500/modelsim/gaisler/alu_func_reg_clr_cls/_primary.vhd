library verilog;
use verilog.vl_types.all;
entity alu_func_reg_clr_cls is
    port(
        alu_func_i      : in     vl_logic_vector(4 downto 0);
        alu_func_o      : out    vl_logic_vector(4 downto 0);
        clk             : in     vl_logic;
        clr             : in     vl_logic;
        cls             : in     vl_logic;
        hold            : in     vl_logic
    );
end alu_func_reg_clr_cls;
