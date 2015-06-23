#!/bin/bash
( 
  cd src/atlys
  coregen -r -b dcm1.xco -p coregen.cgp
  coregen -r -b ack_fifo.xco -p coregen.cgp
)
xtclsh fade_atlys.tcl rebuild_project
