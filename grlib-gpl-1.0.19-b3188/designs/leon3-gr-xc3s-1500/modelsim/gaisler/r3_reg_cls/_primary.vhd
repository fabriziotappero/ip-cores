library verilog;
use verilog.vl_types.all;
entity r3_reg_cls is
    port(
        r3_i            : in     vl_logic_vector(2 downto 0);
        r3_o            : out    vl_logic_vector(2 downto 0);
        clk             : in     vl_logic;
        cls             : in     vl_logic;
        hold            : in     vl_logic
    );
end r3_reg_cls;
