library verilog;
use verilog.vl_types.all;
entity cal_cpi is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        is_nop          : in     vl_logic;
        ins_no          : out    vl_logic_vector(100 downto 0);
        clk_no          : out    vl_logic_vector(100 downto 0)
    );
end cal_cpi;
