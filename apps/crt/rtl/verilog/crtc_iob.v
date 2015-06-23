module CRTC_IOB
(
    reset_in,
    clk_in,
    hsync_in,
    vsync_in,
    rgb_in,
    hsync_out,
    vsync_out,
    rgb_out
) ;

input   reset_in,
        clk_in ;

input   hsync_in,
        vsync_in ;

input   [15:4]  rgb_in ;

output          hsync_out,
                vsync_out ;
output  [15:4]  rgb_out ;

reg             hsync_out,
                vsync_out ;

reg     [15:4]  rgb_out ;

always@(posedge clk_in or posedge reset_in)
begin
    if ( reset_in )
    begin
        hsync_out <= #1 1'b0 ;
        vsync_out <= #1 1'b0 ;
        rgb_out   <= #1 12'h000 ;
    end
    else
    begin
        hsync_out <= #1 hsync_in ;
        vsync_out <= #1 vsync_in ;
        rgb_out   <= #1 rgb_in ;
    end
end
endmodule