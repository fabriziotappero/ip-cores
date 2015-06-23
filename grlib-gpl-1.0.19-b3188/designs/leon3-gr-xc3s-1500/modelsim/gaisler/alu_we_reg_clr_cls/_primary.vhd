library verilog;
use verilog.vl_types.all;
entity alu_we_reg_clr_cls is
    port(
        alu_we_i        : in     vl_logic_vector(0 downto 0);
        alu_we_o        : out    vl_logic_vector(0 downto 0);
        clk             : in     vl_logic;
        clr             : in     vl_logic;
        cls             : in     vl_logic;
        hold            : in     vl_logic
    );
end alu_we_reg_clr_cls;
