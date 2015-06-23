library verilog;
use verilog.vl_types.all;
entity rd_sel is
    port(
        rd_i            : in     vl_logic_vector(4 downto 0);
        rt_i            : in     vl_logic_vector(4 downto 0);
        ctl             : in     vl_logic_vector(1 downto 0);
        rd_o            : out    vl_logic_vector(4 downto 0)
    );
end rd_sel;
