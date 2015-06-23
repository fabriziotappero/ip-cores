library verilog;
use verilog.vl_types.all;
entity fifo4 is
    generic(
        dw              : integer := 8
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        clr             : in     vl_logic;
        din             : in     vl_logic_vector;
        we              : in     vl_logic;
        dout            : out    vl_logic_vector;
        re              : in     vl_logic;
        full            : out    vl_logic;
        empty           : out    vl_logic
    );
end fifo4;
