import RegFile::*;
import AvalonSlave::*;
import RegisterMapper::*;
import ClientServer::*;
import GetPut::*;

module mkSmallAvalonRegisterFile (AvalonSlaveWires#(4,32));
  let m <- mkAvalonRegisterFile;
  return m;
endmodule

module mkAvalonRegisterFile (AvalonSlaveWires#(addr_size,data_size));
  Reset reset <- exposeCurrentReset;
  Clock clock <- exposeCurrentClock;
  AvalonSlave#(addr_size,data_size) avalonSlave <- mkAvalonSlave(clock, reset);
  RegisterFile(Bit#(addr_size),Bit#(data_size)) regs <- mkRegFileFull();

  rule handleReqs;
    AvalonRequest#(address_width,data_width) req <- avalonSlave.busClient.request.get;
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