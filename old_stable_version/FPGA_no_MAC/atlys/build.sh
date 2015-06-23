#!/bin/bash
coregen -r -b dcm1.xco -p coregen.cgp
coregen -r -b ack_fifo.xco -p coregen.cgp
xtclsh atlys_eth_art.tcl rebuild_project
