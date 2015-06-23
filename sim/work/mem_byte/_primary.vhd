library verilog;
use verilog.vl_types.all;
entity mem_byte is
    port(
        rst             : in     vl_logic;
        clk             : in     vl_logic;
        din             : in     vl_logic_vector(7 downto 0);
        dout            : out    vl_logic_vector(7 downto 0);
        wen             : in     vl_logic;
        ren             : in     vl_logic
    );
end mem_byte;
