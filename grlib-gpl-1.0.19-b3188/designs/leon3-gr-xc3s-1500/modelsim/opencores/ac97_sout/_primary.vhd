library verilog;
use verilog.vl_types.all;
entity ac97_sout is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        so_ld           : in     vl_logic;
        slt0            : in     vl_logic_vector(15 downto 0);
        slt1            : in     vl_logic_vector(19 downto 0);
        slt2            : in     vl_logic_vector(19 downto 0);
        slt3            : in     vl_logic_vector(19 downto 0);
        slt4            : in     vl_logic_vector(19 downto 0);
        slt6            : in     vl_logic_vector(19 downto 0);
        slt7            : in     vl_logic_vector(19 downto 0);
        slt8            : in     vl_logic_vector(19 downto 0);
        slt9            : in     vl_logic_vector(19 downto 0);
        sdata_out       : out    vl_logic
    );
end ac97_sout;
