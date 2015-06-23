library verilog;
use verilog.vl_types.all;
entity pc_reg_clr is
    port(
        pc_i            : in     vl_logic_vector(31 downto 0);
        pc_o            : out    vl_logic_vector(31 downto 0);
        clk             : in     vl_logic;
        clr             : in     vl_logic;
        hold            : in     vl_logic
    );
end pc_reg_clr;
