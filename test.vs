/***********************************************************************
 *
 * This file is a part of the Rachael SPARC project accessible at
 * https://www.rachaelsparc.org. Unless otherwise noted code is released
 * under the Lesser GPL (LGPL) available at http://www.gnu.org.
 *
 * Copyright (c) 2005:
 *   Michael Cowell
 *
 * Rachael SPARC is based heavily upon the LEON SPARC microprocessor
 * released by Gaisler Research, at http://www.gaisler.com, under the
 * LGPL. Much of the architectural work on Rachael was done by g2
 * Microsystems. Contact michael.cowell@g2microsystems.com for more
 * information.
 *
 ***********************************************************************
 * $Id: test.vs,v 1.1 2008-10-10 21:03:35 julius Exp $
 * $URL: $
 * $Rev: $
 * $Author: julius $
 **********************************************************************
 *
 * Test Verilog file
 *
 **********************************************************************/

`sinclude "test.struct"

module test (
  // Inputs
  clk, reset, pie, pie2
  );
  input clk;
  input reset;
  input memory_bus pie2;
  input dual_bus pie;

  wire  dual_bus db1;

  reg   complex a;

  reg   memory_bus mb1;
  wire  dual_bus db2 = db1;
  reg [4:1] memory_bus mb2;
  reg [4:1] memory_bus mb5;
  reg [4:1] memory_bus mb6;
  wire      memory_bus mb3 = mb2[1];

  assign    db2.primary.req = 1'b1, db2.primary.address[31:28] = 4'h4;
  assign    db2.primary.address[31:28] = 4'h4;

  always @(posedge clk or posedge db2.primary.req
           or db2.secondary.address or mb2[1]) begin
    mb1.address <= 32'h12348765;
    begin assign mb2[1].req = 1'b1;
      force mb2[2].req = 1'b1;
      assign thing = mb6[2].address[16:0];
      release mb2[2].req;
    end
  end

  wire [3:0] memory_bus mb2;

  fake_module fake_inst2 (mb2[1], db1, db1.primary.req,
                          db1.primary.address[1], mb2[1].req);

  fake_module fake_inst ( . port1 ( mb2[1] ) ,
                          .port2 (db1),
                          .port3 (mb2[2]),
                          .port4 (db1.primary.req),
                          .port5 (db1.primary.address[1]),
                          .port6 (mb2[1].req));

  assign mb2[3].req = 1'b1;

  wire [15:0] temp;
  wire [1:0]  dual_bus db3;

  assign      temp = mb2[2].address[15:0], temp = db2[2].primary.data[4:3];

  assign      p=q, db3[2] =db2 , q=p;

  //assign      mb2[2].address[15:0] = 16'h00;

  always @(posedge clk) begin
    if (mb2[3].primary == 1'b1)
      temp = mb5[3].address[15:0];
    while (mb2[1].address[1] == 1'b1)
      #1;
    case (mb2[1].req)
      1'b1: temp <= 4'h1;
      1'b0: begin
        temp <= 4'h1;
        case (mb2[2].req)
          1'b1: temp <= 4'h2;
        endcase // case(mb2[2].req)
      end
      mb2[3].req, mb2[4].req: temp <= 4'hx;
    endcase // case(mb2[1].req)
    for (mb1.req = 1'b1; mb1.req < db1[1].primary.address[15]; mb2[1].req++)
      temp <= 1'b1;
    sometask(mb1.req);
  end


endmodule

/* */
