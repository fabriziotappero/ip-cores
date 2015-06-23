library verilog;
use verilog.vl_types.all;
entity wb_we_reg_cls is
    port(
        wb_we_i         : in     vl_logic_vector(0 downto 0);
        wb_we_o         : out    vl_logic_vector(0 downto 0);
        clk             : in     vl_logic;
        cls             : in     vl_logic;
        hold            : in     vl_logic
    );
end wb_we_reg_cls;
