/*
    provides delay on both edges of pulse
    1st positive, and 2nd stage negative
*/
module delay_pulse_ff(d
                , clock, enable, clrn
                , q
                );
parameter delay = 1;
parameter lpm_width =1;

input wire[lpm_width-1:0] d;
output wire[lpm_width-1:0] q;
input wire clock, enable, clrn;

generate
    if (delay == 0) begin
        assign q = d;
    end
    else begin
        reg [lpm_width-1:0] qt_pos [1:delay];
        reg [lpm_width-1:0] qt_neg [1:delay];
        integer k;

        always @(posedge clock or negedge clrn) begin
            if (~clrn)
                qt_pos[1] <= 0;
            else if (enable)
                qt_pos[1] <= d;

            for (k = 1; k < delay; k=k+1) begin : DelayRiseInstance
                if (~clrn)
                    qt_pos[k+1] <= 0;
                else if (enable)
                    qt_pos[k+1] <= qt_neg[k];
            end
        end

        always @(negedge clock or negedge clrn) begin
            if (~clrn)
                qt_neg[1] <= 0;
            else if (enable)
                qt_neg[1] <= qt_pos[1];

            for (k = 1; k < delay; k=k+1) begin : DelayFallInstance
                if (~clrn)
                    qt_neg[k+1] <= 0;
                else if (enable)
                    qt_neg[k+1] <= qt_pos[k];
            end
        end

        assign q = qt_neg[delay];
    end
endgenerate

endmodule
