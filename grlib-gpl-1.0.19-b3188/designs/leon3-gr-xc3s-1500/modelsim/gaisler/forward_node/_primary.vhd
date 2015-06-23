library verilog;
use verilog.vl_types.all;
entity forward_node is
    port(
        rn              : in     vl_logic_vector(4 downto 0);
        alu_wr_rn       : in     vl_logic_vector(4 downto 0);
        alu_we          : in     vl_logic;
        mem_wr_rn       : in     vl_logic_vector(4 downto 0);
        mem_we          : in     vl_logic;
        mux_fw          : out    vl_logic_vector(2 downto 0)
    );
end forward_node;
