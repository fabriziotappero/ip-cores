library verilog;
use verilog.vl_types.all;
entity i2c_slave_model is
    generic(
        I2C_ADR         : integer := 80;
        idle            : integer := 0;
        slave_ack       : integer := 1;
        get_mem_adr     : integer := 2;
        gma_ack         : integer := 3;
        data            : integer := 4;
        data_ack        : integer := 5
    );
    port(
        scl             : in     vl_logic;
        sda             : inout  vl_logic
    );
end i2c_slave_model;
