library verilog;
use verilog.vl_types.all;
entity ac97_sin is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        out_le          : in     vl_logic_vector(5 downto 0);
        slt0            : out    vl_logic_vector(15 downto 0);
        slt1            : out    vl_logic_vector(19 downto 0);
        slt2            : out    vl_logic_vector(19 downto 0);
        slt3            : out    vl_logic_vector(19 downto 0);
        slt4            : out    vl_logic_vector(19 downto 0);
        slt6            : out    vl_logic_vector(19 downto 0);
        sdata_in        : in     vl_logic
    );
end ac97_sin;
