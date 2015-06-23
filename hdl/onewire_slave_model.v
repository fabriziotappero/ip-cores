//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  1-wire (owr) slave model                                                //
//                                                                          //
//  Copyright (C) 2010  Iztok Jeras                                         //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  This HDL is free hardware: you can redistribute it and/or modify        //
//  it under the terms of the GNU Lesser General Public License             //
//  as published by the Free Software Foundation, either                    //
//  version 3 of the License, or (at your option) any later version.        //
//                                                                          //
//  This RTL is distributed in the hope that it will be useful,             //
//  but WITHOUT ANY WARRANTY; without even the implied warranty of          //
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           //
//  GNU General Public License for more details.                            //
//                                                                          //
//  You should have received a copy of the GNU General Public License       //
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
 
`timescale 1us / 1ns

module onewire_slave_model #(
  // time slot (min=15.0, typ=30.0, max=60.0)
  parameter TS = 30.0
)(
  // configuration
  input  wire ena,    // response enable
  input  wire ovd,    // overdrive mode select
  input  wire dat_r,  // read data
  output wire dat_w,  // write data
  // 1-wire
  inout wire owr
);

// IO
reg pul;
reg dat;

// events
event sample_dat;
event sample_rst;

//////////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////////

// onewire open collector signal
assign owr = pul & ena ? 1'b0 : 1'bz;

// read data output
assign dat_w = ena ? dat : 1'bz;

//////////////////////////////////////////////////////////////////////////////
// events inside a cycle
//////////////////////////////////////////////////////////////////////////////

// power up state
initial pul  <= 1'b0;

always @ (negedge owr)  if (ena)  transfer (ovd, dat_r, dat);

task automatic transfer (
  input  ovd,
  input  dat_r,
  output dat_w
); begin
  // provide read data response
  pul = ~dat_r;
  // wait 1 time slot
  if (ovd)  #(1*TS/8);
  else      #(1*TS);
  // write data is sampled here
  -> sample_dat;
  dat_w = owr;
  // release the wire
  pul = 1'b0;
  // fork into data or reset cycle
  fork
    // transfer data
    begin : transfer_dat
      // if cycle ends before reset is detected
      if (~owr) @ (posedge owr);
      // disable reset path
      disable transfer_rst;
    end
    // transfer reset
    begin : transfer_rst
      // wait 7 time slots
      if (ovd)  #(7*TS/8);
      else      #(7*TS);
      // reset is sampled here
      -> sample_rst;
      // if reset is detected disable data path
      if (~owr) disable transfer_dat;
      // wait for reset low to end
      @ (posedge owr)
      // wait 1 time slot
      if (ovd)  #(1*TS/8);
      else      #(1*TS);
      // provide presence pulse
      pul = 1'b1;
      // wait 4 time slot
      if (ovd)  #(4*TS/8);
      else      #(4*TS);
      // release the wire
      pul = 1'b0;
    end
  join
end endtask

endmodule
