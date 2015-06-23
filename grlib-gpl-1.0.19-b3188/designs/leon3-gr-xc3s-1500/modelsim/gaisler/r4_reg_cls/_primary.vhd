library verilog;
use verilog.vl_types.all;
entity r4_reg_cls is
    port(
        r4_i            : in     vl_logic_vector(3 downto 0);
        r4_o            : out    vl_logic_vector(3 downto 0);
        clk             : in     vl_logic;
        cls             : in     vl_logic;
        hold            : in     vl_logic
    );
end r4_reg_cls;
