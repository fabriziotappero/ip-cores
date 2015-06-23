#!/usr/bin/gawk
# Copyright 2012, Sinclair R.F., Inc.
#
# Parse the output of the Verilog test bench to ensure the signals transmit
# "Hello World!" and the proper baud and number of stop bits.

function abs(a) {
  return (a>=0) ? a : -a;
}

function append_state() {
  dt = t_cur-state[ix,"t_last"];
  nbits = int(dt/dtBaud);
  if (dt-nbits*dtBaud > 0.5*dtBaud) ++nbits;
  dt -= nbits*dtBaud;
  for (jx=0; jx<nbits; ++jx)
    state[ix,"cur"] = state[ix,"cur"] state[ix,"last"];
}

function convert_state(_v) {
  _v = 0;
  for (jx=0; jx<8; ++jx) {
    _v /= 2;
    _v += strtonum(substr(state[ix,"cur"],2+jx,1))*0x80;
  }
  state[ix,"cur"] = "";
  return sprintf("%c",_v);
}

BEGIN {
  first = 1;
  for (ix=1; ix<=3; ++ix) {
    state[ix,"mode"] = -1;
    state[ix,"msg"] = "";
    state[ix,"nStop"] = 1;
    state[ix,"last"] = 1;
  }
  state[3,"nStop"] = 2;
  dtBaud = 1./115200;
  dtTol = 1./100e6/2;
}

{
  t_cur = $1/1.e9;
  if (first > 0) {
    --first;
    for (ix=1; ix<=3; ++ix)
      state[ix,"t_last"] = t_cur;
    next;
  }
  for (ix=1; ix<=3; ++ix) {
    this = $(ix+2);
    if (this == state[ix,"last"])
      continue;
    if (state[ix,"mode"] == -1) {
      if (this != "0") {
        print "Missing start bit at line",FNR > "/dev/stderr";
        exit(1);
      } else {
        state[ix,"t_last"] = t_cur;
        state[ix,"mode"] = 0;
        state[ix,"last"] = "0";
        state[ix,"cur"] = "";
      }
    } else {
      append_state();
      if (length(state[ix,"cur"]) < 9+state[ix,"nStop"]) {
        if (abs(dt)>dtTol*nbits) {
          print "Baud rate out of tolerance at line",FNR > "/dev/stderr";
          exit(1);
        }
      } else if (length(state[ix,"cur"]) == 9+state[ix,"nStop"]) {
        if (dt < -dtTol*nbits) {
          print "Baud rate out of tolerance at line",FNR > "/dev/stderr";
          exit(1);
        }
        state[ix,"msg"] = state[ix,"msg"] convert_state();
      } else {
      }
    }
    state[ix,"t_last"] = t_cur;
    state[ix,"last"] = this;
  }
}

END {
  t_cur = $1/1.e9;
  for (ix=1; ix<=3; ++ix) {
    append_state();
    state[ix,"msg"] = state[ix,"msg"] convert_state();
  }
  for (ix=1; ix<=3; ++ix)
    print ix, state[ix,"msg"];
}
