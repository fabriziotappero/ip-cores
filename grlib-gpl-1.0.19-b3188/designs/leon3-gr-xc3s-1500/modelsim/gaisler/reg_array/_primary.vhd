library verilog;
use verilog.vl_types.all;
entity reg_array is
    port(
        data            : in     vl_logic_vector(31 downto 0);
        wraddress       : in     vl_logic_vector(4 downto 0);
        rdaddress_a     : in     vl_logic_vector(4 downto 0);
        rdaddress_b     : in     vl_logic_vector(4 downto 0);
        wren            : in     vl_logic;
        clock           : in     vl_logic;
        qa              : out    vl_logic_vector(31 downto 0);
        qb              : out    vl_logic_vector(31 downto 0);
        rd_clk_cls      : in     vl_logic
    );
end reg_array;
