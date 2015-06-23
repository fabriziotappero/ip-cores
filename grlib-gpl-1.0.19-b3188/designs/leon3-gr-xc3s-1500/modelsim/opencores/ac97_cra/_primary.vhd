library verilog;
use verilog.vl_types.all;
entity ac97_cra is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        crac_we         : in     vl_logic;
        crac_din        : out    vl_logic_vector(15 downto 0);
        crac_out        : in     vl_logic_vector(31 downto 0);
        crac_wr_done    : out    vl_logic;
        crac_rd_done    : out    vl_logic;
        valid           : in     vl_logic;
        out_slt1        : out    vl_logic_vector(19 downto 0);
        out_slt2        : out    vl_logic_vector(19 downto 0);
        in_slt2         : in     vl_logic_vector(19 downto 0);
        crac_valid      : out    vl_logic;
        crac_wr         : out    vl_logic
    );
end ac97_cra;
