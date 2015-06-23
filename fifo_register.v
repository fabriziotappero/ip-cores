//********************************************************//
// FIFO Register stores 31 recieved word symbols          //
//********************************************************//
module fifo_register(clock1, clock2, shift_fifo, hold_fifo, 
                     en_outfifo, en_infifo, datain, dataout);

input clock1, clock2;
input shift_fifo, hold_fifo, en_outfifo, en_infifo;
input [4:0] datain;
output [4:0] dataout;

wire [4:0] outreg0, outreg1, outreg2, outreg3, outreg4,
			    outreg5, outreg6, outreg7, outreg8, outreg9,
			    outreg10, outreg11, outreg12, outreg13, outreg14,
			    outreg15, outreg16, outreg17, outreg18, outreg19,
			    outreg20, outreg21, outreg22, outreg23, outreg24,
			    outreg25, outreg26, outreg27, outreg28, outreg29,
			    outreg30;
wire [4:0] inputzero;
reg [4:0] outmux;

assign inputzero = 5'b0;

always@(en_infifo or inputzero or datain)
begin
    case(en_infifo)
        0 : outmux = inputzero;
        1 : outmux = datain;
    endcase
end

// 31 registers storing received words operate on clock1 //
register5_wlh Reg0(outmux, outreg0, shift_fifo, hold_fifo, clock1);
register5_wlh Reg1(outreg0, outreg1, shift_fifo, hold_fifo, clock1);
register5_wlh Reg2(outreg1, outreg2, shift_fifo, hold_fifo, clock1);
register5_wlh Reg3(outreg2, outreg3, shift_fifo, hold_fifo, clock1);
register5_wlh Reg4(outreg3, outreg4, shift_fifo, hold_fifo, clock1);
register5_wlh Reg5(outreg4, outreg5, shift_fifo, hold_fifo, clock1);
register5_wlh Reg6(outreg5, outreg6, shift_fifo, hold_fifo, clock1);
register5_wlh Reg7(outreg6, outreg7, shift_fifo, hold_fifo, clock1);
register5_wlh Reg8(outreg7, outreg8, shift_fifo, hold_fifo, clock1);
register5_wlh Reg9(outreg8, outreg9, shift_fifo, hold_fifo, clock1);
register5_wlh Reg10(outreg9, outreg10, shift_fifo, hold_fifo, clock1);
register5_wlh Reg11(outreg10, outreg11, shift_fifo, hold_fifo, clock1);
register5_wlh Reg12(outreg11, outreg12, shift_fifo, hold_fifo, clock1);
register5_wlh Reg13(outreg12, outreg13, shift_fifo, hold_fifo, clock1);
register5_wlh Reg14(outreg13, outreg14, shift_fifo, hold_fifo, clock1);
register5_wlh Reg15(outreg14, outreg15, shift_fifo, hold_fifo, clock1);
register5_wlh Reg16(outreg15, outreg16, shift_fifo, hold_fifo, clock1);
register5_wlh Reg17(outreg16, outreg17, shift_fifo, hold_fifo, clock1);
register5_wlh Reg18(outreg17, outreg18, shift_fifo, hold_fifo, clock1);
register5_wlh Reg19(outreg18, outreg19, shift_fifo, hold_fifo, clock1);
register5_wlh Reg20(outreg19, outreg20, shift_fifo, hold_fifo, clock1);
register5_wlh Reg21(outreg20, outreg21, shift_fifo, hold_fifo, clock1);
register5_wlh Reg22(outreg21, outreg22, shift_fifo, hold_fifo, clock1);
register5_wlh Reg23(outreg22, outreg23, shift_fifo, hold_fifo, clock1);
register5_wlh Reg24(outreg23, outreg24, shift_fifo, hold_fifo, clock1);
register5_wlh Reg25(outreg24, outreg25, shift_fifo, hold_fifo, clock1);
register5_wlh Reg26(outreg25, outreg26, shift_fifo, hold_fifo, clock1);
register5_wlh Reg27(outreg26, outreg27, shift_fifo, hold_fifo, clock1);
register5_wlh Reg28(outreg27, outreg28, shift_fifo, hold_fifo, clock1);
register5_wlh Reg29(outreg28, outreg29, shift_fifo, hold_fifo, clock1);
register5_wlh Reg30(outreg29, outreg30, shift_fifo, hold_fifo, clock1);

// Output register operates on clock2 to synchronize with //
// output of CSEE.                                        //
register5_wl outreg(outreg30, dataout, clock2, en_outfifo);

endmodule

