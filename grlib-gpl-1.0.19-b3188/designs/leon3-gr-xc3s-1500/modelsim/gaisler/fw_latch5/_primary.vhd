library verilog;
use verilog.vl_types.all;
entity fw_latch5 is
    port(
        clk             : in     vl_logic;
        d               : in     vl_logic_vector(4 downto 0);
        hold            : in     vl_logic;
        q               : out    vl_logic_vector(4 downto 0)
    );
end fw_latch5;
