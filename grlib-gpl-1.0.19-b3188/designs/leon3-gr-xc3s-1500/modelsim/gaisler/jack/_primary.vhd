library verilog;
use verilog.vl_types.all;
entity jack is
    port(
        ins_i           : in     vl_logic_vector(31 downto 0);
        rs_o            : out    vl_logic_vector(4 downto 0);
        rt_o            : out    vl_logic_vector(4 downto 0);
        rd_o            : out    vl_logic_vector(4 downto 0)
    );
end jack;
