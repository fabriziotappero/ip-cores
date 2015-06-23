`ifndef _const_
`define _const_

// Packet Types
`define Unknown		0
`define UDP				1
`define ARPReq	 		2
`define ARPReply 		3
`define ICMPReq 		4
`define ICMPReply 	5

// Commands
`define CmdDone			0
`define CmdStatus			1
`define CmdLEDCtrl		2
`define CmdSetConfig		3
`define CmdSwChanged		4
`define CmdDataEcho		5

`endif
