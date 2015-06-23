library verilog;
use verilog.vl_types.all;
entity r5_reg_clr is
    port(
        r5_i            : in     vl_logic_vector(4 downto 0);
        r5_o            : out    vl_logic_vector(4 downto 0);
        clk             : in     vl_logic;
        clr             : in     vl_logic;
        hold            : in     vl_logic
    );
end r5_reg_clr;
