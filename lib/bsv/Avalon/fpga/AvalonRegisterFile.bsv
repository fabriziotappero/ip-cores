import RegFile::*;
import AvalonSlave::*;
import RegisterMapper::*;
import ClientServer::*;
import GetPut::*;

(*synthesize*)
module mkSmallAvalonRegisterFile (AvalonSlaveWires#(4,32));
  let m <- mkAvalonRegisterFile;
  return m;
endmodule

module mkAvalonRegisterFile (AvalonSlaveWires#(addr_size,data_size));
  Reset reset <- exposeCurrentReset;
  Clock clock <- exposeCurrentClock;
  AvalonSlave#(addr_size,data_size) avalonSlave <- mkAvalonSlave(clock, reset);
  RegFile#(Bit#(addr_size),Bit#(data_size)) regs <- mkRegFileFull();

  rule handleReqs;
    AvalonRequest#(addr_size,data_size) req <- avalonSlave.busClient.request.get;
    if(req.command == Write)
      begin
        regs.upd(req.addr,req.data);
      end
    else
      begin
         avalonSlave.busClient.response.put(regs.sub(req.addr));
      end
  endrule

  return avalonSlave.slaveWires;

endmodule