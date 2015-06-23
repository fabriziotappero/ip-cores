module hd_data_reader (
    input           clk,
    input           rst,

    input           enable,
    output  reg     error,

    input           hd_read_from_host,
    input   [31:0]  hd_data_from_host
);

//Registers/Wires
reg                 prev_enable;
wire                posedge_enable;
reg         [31:0]  test_data;

//Submodules

//Asynchronous Logic
assign              posedge_enable = (!prev_enable && enable);

//Synchronous Logic
always @ (posedge clk) begin
    if (rst) begin
        prev_enable         <=  0;
        error               <=  0;
        test_data           <=  0;
    end
    else begin
        prev_enable         <=  enable;
        if (posedge_enable) begin
            error           <=  0;
            test_data       <=  0;
        end
        else begin
            if (hd_read_from_host) begin
                if (hd_data_from_host != test_data) begin
                    error   <=  1;
                end
                test_data   <=  test_data + 1;
            end
        end
    end
end


endmodule
