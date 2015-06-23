library verilog;
use verilog.vl_types.all;
entity ac97_soc is
    port(
        clk             : in     vl_logic;
        wclk            : in     vl_logic;
        rst             : in     vl_logic;
        ps_ce           : in     vl_logic;
        resume          : in     vl_logic;
        suspended       : out    vl_logic;
        sync            : out    vl_logic;
        out_le          : out    vl_logic_vector(5 downto 0);
        in_valid        : out    vl_logic_vector(2 downto 0);
        ld              : out    vl_logic;
        valid           : out    vl_logic
    );
end ac97_soc;
