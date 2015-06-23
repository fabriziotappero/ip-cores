library verilog;
use verilog.vl_types.all;
entity custom_fifo_dp is
    port(
        clk_rd          : in     vl_logic;
        clk_wr          : in     vl_logic;
        d_i             : in     vl_logic_vector(7 downto 0);
        d_o             : out    vl_logic_vector(7 downto 0);
        rst             : in     vl_logic;
        wr_en           : in     vl_logic;
        rd_en           : in     vl_logic;
        full            : out    vl_logic;
        empty           : out    vl_logic
    );
end custom_fifo_dp;
