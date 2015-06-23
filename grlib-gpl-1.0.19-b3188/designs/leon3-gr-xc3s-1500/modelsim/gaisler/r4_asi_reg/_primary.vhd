library verilog;
use verilog.vl_types.all;
entity r4_asi_reg is
    port(
        r4_i            : in     vl_logic_vector(4 downto 0);
        r4_o            : out    vl_logic_vector(4 downto 0);
        clk             : in     vl_logic;
        hold            : in     vl_logic
    );
end r4_asi_reg;
