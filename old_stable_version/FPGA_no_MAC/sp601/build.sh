#!/bin/bash
coregen -r -b dcm1.xco -p coregen.cgp
coregen -r -b ack_fifo.xco -p coregen.cgp
xtclsh sp601_eth.tcl rebuild_project

