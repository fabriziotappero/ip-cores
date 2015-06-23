/*
 * Interrupt Controller
 *
 * (C) 2007 Simply RISC LLP
 * AUTHOR: Fabrizio Fazzino <fabrizio.fazzino@srisc.com>
 *
 * LICENSE:
 * This is a Free Hardware Design; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * version 2 as published by the Free Software Foundation.
 * The above named program is distributed in the hope that it will
 * be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * DESCRIPTION:
 * This block implements the Interrupt Controller used by the S1
 * to detect if some peripheral raised an interrupt request.
 * A proper interrupt packet is sent to the SPARC Core by the
 * bridge with one of the 64 interrupt sources (provided by this
 * controller) encoded in the 6-bit Interrupt Source field.
 * Please note that IRQ 0 is reserved for Power-On Reset (handled
 * directly by the bridge) so up to 63 external peripherals can be
 * connected to the S1.
 * Note also that currently the interrupt vector is hardwired to
 * all zeroes.
 */

module int_ctrl (
    sys_clock_i, sys_reset_i, sys_irq_i,
    sys_interrupt_source_o
  );

  // System inputs
  input sys_clock_i;
  input sys_reset_i;

  // Incoming Interrupt Requests
  input[63:0] sys_irq_i;

  // Encoded Interrupt Source
  output[5:0] sys_interrupt_source_o;
  reg[5:0] sys_interrupt_source_o;

  // Encoding of the source using priority and ignoring IRQ 0
  always @(posedge sys_clock_i) begin
    if(sys_reset_i==1) sys_interrupt_source_o = 0;
    else if(sys_irq_i[63]) sys_interrupt_source_o = 63;
    else if(sys_irq_i[62]) sys_interrupt_source_o = 62;
    else if(sys_irq_i[61]) sys_interrupt_source_o = 61;
    else if(sys_irq_i[60]) sys_interrupt_source_o = 60;
    else if(sys_irq_i[59]) sys_interrupt_source_o = 59;
    else if(sys_irq_i[58]) sys_interrupt_source_o = 58;
    else if(sys_irq_i[57]) sys_interrupt_source_o = 57;
    else if(sys_irq_i[56]) sys_interrupt_source_o = 56;
    else if(sys_irq_i[55]) sys_interrupt_source_o = 55;
    else if(sys_irq_i[54]) sys_interrupt_source_o = 54;
    else if(sys_irq_i[53]) sys_interrupt_source_o = 53;
    else if(sys_irq_i[52]) sys_interrupt_source_o = 52;
    else if(sys_irq_i[51]) sys_interrupt_source_o = 51;
    else if(sys_irq_i[50]) sys_interrupt_source_o = 50;
    else if(sys_irq_i[49]) sys_interrupt_source_o = 49;
    else if(sys_irq_i[48]) sys_interrupt_source_o = 48;
    else if(sys_irq_i[47]) sys_interrupt_source_o = 47;
    else if(sys_irq_i[46]) sys_interrupt_source_o = 46;
    else if(sys_irq_i[45]) sys_interrupt_source_o = 45;
    else if(sys_irq_i[44]) sys_interrupt_source_o = 44;
    else if(sys_irq_i[43]) sys_interrupt_source_o = 43;
    else if(sys_irq_i[42]) sys_interrupt_source_o = 42;
    else if(sys_irq_i[41]) sys_interrupt_source_o = 41;
    else if(sys_irq_i[40]) sys_interrupt_source_o = 40;
    else if(sys_irq_i[39]) sys_interrupt_source_o = 39;
    else if(sys_irq_i[38]) sys_interrupt_source_o = 38;
    else if(sys_irq_i[37]) sys_interrupt_source_o = 37;
    else if(sys_irq_i[36]) sys_interrupt_source_o = 36;
    else if(sys_irq_i[35]) sys_interrupt_source_o = 35;
    else if(sys_irq_i[34]) sys_interrupt_source_o = 34;
    else if(sys_irq_i[33]) sys_interrupt_source_o = 33;
    else if(sys_irq_i[32]) sys_interrupt_source_o = 32;
    else if(sys_irq_i[31]) sys_interrupt_source_o = 31;
    else if(sys_irq_i[30]) sys_interrupt_source_o = 30;
    else if(sys_irq_i[29]) sys_interrupt_source_o = 29;
    else if(sys_irq_i[28]) sys_interrupt_source_o = 28;
    else if(sys_irq_i[27]) sys_interrupt_source_o = 27;
    else if(sys_irq_i[26]) sys_interrupt_source_o = 26;
    else if(sys_irq_i[25]) sys_interrupt_source_o = 25;
    else if(sys_irq_i[24]) sys_interrupt_source_o = 24;
    else if(sys_irq_i[23]) sys_interrupt_source_o = 23;
    else if(sys_irq_i[22]) sys_interrupt_source_o = 22;
    else if(sys_irq_i[21]) sys_interrupt_source_o = 21;
    else if(sys_irq_i[20]) sys_interrupt_source_o = 20;
    else if(sys_irq_i[19]) sys_interrupt_source_o = 19;
    else if(sys_irq_i[18]) sys_interrupt_source_o = 18;
    else if(sys_irq_i[17]) sys_interrupt_source_o = 17;
    else if(sys_irq_i[16]) sys_interrupt_source_o = 16;
    else if(sys_irq_i[15]) sys_interrupt_source_o = 15;
    else if(sys_irq_i[14]) sys_interrupt_source_o = 14;
    else if(sys_irq_i[13]) sys_interrupt_source_o = 13;
    else if(sys_irq_i[12]) sys_interrupt_source_o = 12;
    else if(sys_irq_i[11]) sys_interrupt_source_o = 11;
    else if(sys_irq_i[10]) sys_interrupt_source_o = 10;
    else if(sys_irq_i[9]) sys_interrupt_source_o = 9;
    else if(sys_irq_i[8]) sys_interrupt_source_o = 8;
    else if(sys_irq_i[7]) sys_interrupt_source_o = 7;
    else if(sys_irq_i[6]) sys_interrupt_source_o = 6;
    else if(sys_irq_i[5]) sys_interrupt_source_o = 5;
    else if(sys_irq_i[4]) sys_interrupt_source_o = 4;
    else if(sys_irq_i[3]) sys_interrupt_source_o = 3;
    else if(sys_irq_i[2]) sys_interrupt_source_o = 2;
    else if(sys_irq_i[1]) sys_interrupt_source_o = 1;
    else sys_interrupt_source_o = 0;
  end

endmodule
