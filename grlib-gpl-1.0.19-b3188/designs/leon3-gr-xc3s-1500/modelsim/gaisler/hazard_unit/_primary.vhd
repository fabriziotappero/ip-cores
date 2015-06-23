library verilog;
use verilog.vl_types.all;
entity hazard_unit is
    port(
        clk             : in     vl_logic;
        load            : in     vl_logic;
        rt              : in     vl_logic_vector(4 downto 0);
        hold            : in     vl_logic;
        load_o          : out    vl_logic;
        rt_o            : out    vl_logic_vector(4 downto 0)
    );
end hazard_unit;
