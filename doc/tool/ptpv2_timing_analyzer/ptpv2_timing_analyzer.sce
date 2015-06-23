///*
// * ptpv2_timing_analyzer.sce
// * 
// * Copyright (c) 2013, BABY&HW. All rights reserved.
// *
// * This library is free software; you can redistribute it and/or
// * modify it under the terms of the GNU Lesser General Public
// * License as published by the Free Software Foundation; either
// * version 2.1 of the License, or (at your option) any later version.
// *
// * This library is distributed in the hope that it will be useful,
// * but WITHOUT ANY WARRANTY; without even the implied warranty of
// * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// * Lesser General Public License for more details.
// *
// * You should have received a copy of the GNU Lesser General Public
// * License along with this library; if not, write to the Free Software
// * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
// * MA 02110-1301  USA
// */

clear;
clc;
stacksize('max');
/////////////////////////////////////
// Read pcap file for PTP
/////////////////////////////////////
pcapFile='ptpdv2_long.pcap';
fd1=mopen(pcapFile,'rb');
// skip file header
// check endianness
mseek(24); //24B

// parse capture
packetNum_cap         = {};
messageId_cap         = {};
clockId_cap           = {};
sequenceId_cap        = {};
embeddedTimestamp_cap = {};
capturedTimestamp_cap = {};
packetNum = 0;
while 1
  // parsing capture header per frame
  // get time stamp in second
  capturedTimestamp_Sec =mget(1,'uil',fd1);
  // get time stamp in nsecond
  capturedTimestamp_NSec=mget(1,'uil',fd1);
  // get capture length
  lCaptr=mget(1,'uil',fd1);
  // get frame length
  lFrame=mget(1,'uil',fd1);
  
  // ptp packet parsing here
  
  // ptp packet address filter here
  
  // ptp packet number
  packetNum=packetNum+1;
  
  // skip packet header
  mseek(mtell(fd1)+(14+20+8)); //14B:MAC, 20B:IP, 8B:UDP
  
  // messageId
  mseek(mtell(fd1)+0); // 0B from beginning of ptp
  messageId=modulo(mget(1,'ucb',fd1),2^4); //1B
  mseek(mtell(fd1)-(0+1)); //return to beginning of ptp
  
  // ClockIdentity
  mseek(mtell(fd1)+20); // 20B from beginning of ptp
  clockId=mget(1,'uib',fd1); //4B
  clockId=mget(1,'uib',fd1); //4B
  mseek(mtell(fd1)-(20+4+4)); //return to beginning of ptp
  
  // sequenceId
  mseek(mtell(fd1)+30); // 30B from beginning of ptp
  sequenceId=mget(1,'usb',fd1); //2B
  mseek(mtell(fd1)-(30+2)); //return to beginning of ptp
  
  // embeddedTimestamp
  mseek(mtell(fd1)+34); // 34B from beginning of ptp
  embeddedTimestamp_SecH=mget(1,'usb',fd1); //2B
  embeddedTimestamp_SecL=mget(1,'uib',fd1); //4B
  embeddedTimestamp_NSec=mget(1,'uib',fd1); //4B
  mseek(mtell(fd1)-(34+2+4+4)); //return to beginning of ptp
  
  // return to beginning of packet
  mseek(mtell(fd1)-(14+20+8)); //14B:MAC, 20B:IP, 8B:UDP
  
  // go to end of packet
  mseek(mtell(fd1)+lCaptr);
  
  // get ptp messages
  packetNum_cap         = [packetNum_cap, packetNum];
  messageId_cap         = [messageId_cap, messageId];
  clockId_cap           = [clockId_cap, clockId];
  sequenceId_cap        = [sequenceId_cap, sequenceId];
  embeddedTimestamp_cap = [embeddedTimestamp_cap, (embeddedTimestamp_SecH*4294967296 + embeddedTimestamp_SecL) + embeddedTimestamp_NSec*10^(-9)];
  capturedTimestamp_cap = [capturedTimestamp_cap,  capturedTimestamp_Sec                                       + capturedTimestamp_NSec*10^(-9)];
  
  // EOF checking
  mget(1,'ui',fd1);
  if meof(fd1)
    // break from the loop
    break;
  else
    // switch to the next packet
    mseek(mtell(fd1)-4);
  end
end
mtell;
mclose(fd1);

// find Master and Slave clockId
clockId_mastrs=clockId_cap(find(messageId_cap==0));
clockId_mastr =clockId_mastrs(1);
clockId_slaves=clockId_cap(find(clockId_cap~=clockId_mastr));
clockId_slave =clockId_slaves(1);

// function: calc_delta
funcprot(0);
function timestamp_delta=calc_delta(timestamp)
  timestamp=timestamp-timestamp(1);
  timestamp_delta=zeros(1,length(timestamp)-1);
  for i = 1:(length(timestamp)-1)
    timestamp_delta(i)=timestamp(i+1)-timestamp(i);
  end
endfunction

///////////////////////////////////////
// Generate CSV
///////////////////////////////////////
// [packetNum_cap', capturedTimestamp_cap', messageId_cap', clockId_cap', sequenceId_cap', embeddedTimestamp_cap']

// Port Direction
clockId_str_cap={};
for i = 1:length(clockId_cap)
  select clockId_cap(i)
    case  clockId_mastr then clockId_str_cap = {clockId_str_cap, 'M -> S'},
    else                     clockId_str_cap = {clockId_str_cap, 'M <- S'},
  end
end

// MessageId
messageId_str_cap={};
for i = 1:length(messageId_cap)
  select messageId_cap(i)
    case  0 then messageId_str_cap = {messageId_str_cap, '0x0: EVENT:SYNC'},
    case  1 then messageId_str_cap = {messageId_str_cap, '0x1: EVENT:DELAY_REQ'},
    case  2 then messageId_str_cap = {messageId_str_cap, '0x2: EVENT:PATH_DELAY_REQ'},
    case  3 then messageId_str_cap = {messageId_str_cap, '0x3: EVENT:PATH_DELAY_RESP'},
  //case  4- 7 Reserved
    case  8 then messageId_str_cap = {messageId_str_cap, '0x8: GENER:FOLLOW_UP'},
    case  9 then messageId_str_cap = {messageId_str_cap, '0x9: GENER:DELAY_RESP'},
    case 10 then messageId_str_cap = {messageId_str_cap, '0xA: GENER:PATH_DELAY_RESP_FOLLOW_UP'},
    case 11 then messageId_str_cap = {messageId_str_cap, '0xB: GENER:ANNOUNCE'},
    case 12 then messageId_str_cap = {messageId_str_cap, '0xC: GENER:SIGNALLING'},
    case 13 then messageId_str_cap = {messageId_str_cap, '0xD: GENER:MANAGEMENT'},
  //case 14-15 Reserved
    else         messageId_str_cap = {messageId_str_cap, messageId},
  end
end

// Inter-Packet Time
interPacketTime={0, calc_delta(capturedTimestamp_cap)};

// Inter-Message Time
interMessageTime=zeros(1,length(capturedTimestamp_cap));
indexMastr=find(clockId_cap==clockId_mastr);
indexSlave=find(clockId_cap==clockId_slave);
indexSync=indexMastr(find(messageId_cap(indexMastr)== 0));
indexDreq=indexMastr(find(messageId_cap(indexMastr)== 1));
indexPreq=indexMastr(find(messageId_cap(indexMastr)== 2));
indexPres=indexMastr(find(messageId_cap(indexMastr)== 3));
indexFlup=indexMastr(find(messageId_cap(indexMastr)== 8));
indexDres=indexMastr(find(messageId_cap(indexMastr)== 9));
indexPrfl=indexMastr(find(messageId_cap(indexMastr)==10));
indexAnnc=indexMastr(find(messageId_cap(indexMastr)==11));
indexSign=indexMastr(find(messageId_cap(indexMastr)==12));
indexMang=indexMastr(find(messageId_cap(indexMastr)==13));
interMessageTime(indexSync)={0, calc_delta(capturedTimestamp_cap(indexSync))};
interMessageTime(indexDreq)={0, calc_delta(capturedTimestamp_cap(indexDreq))};
interMessageTime(indexPreq)={0, calc_delta(capturedTimestamp_cap(indexPreq))};
interMessageTime(indexPres)={0, calc_delta(capturedTimestamp_cap(indexPres))};
interMessageTime(indexFlup)={0, calc_delta(capturedTimestamp_cap(indexFlup))};
interMessageTime(indexDres)={0, calc_delta(capturedTimestamp_cap(indexDres))};
interMessageTime(indexPrfl)={0, calc_delta(capturedTimestamp_cap(indexPrfl))};
interMessageTime(indexAnnc)={0, calc_delta(capturedTimestamp_cap(indexAnnc))};
interMessageTime(indexSign)={0, calc_delta(capturedTimestamp_cap(indexSign))};
interMessageTime(indexMang)={0, calc_delta(capturedTimestamp_cap(indexMang))};
indexSync=indexSlave(find(messageId_cap(indexSlave)== 0));
indexDreq=indexSlave(find(messageId_cap(indexSlave)== 1));
indexPreq=indexSlave(find(messageId_cap(indexSlave)== 2));
indexPres=indexSlave(find(messageId_cap(indexSlave)== 3));
indexFlup=indexSlave(find(messageId_cap(indexSlave)== 8));
indexDres=indexSlave(find(messageId_cap(indexSlave)== 9));
indexPrfl=indexSlave(find(messageId_cap(indexSlave)==10));
indexAnnc=indexSlave(find(messageId_cap(indexSlave)==11));
indexSign=indexSlave(find(messageId_cap(indexSlave)==12));
indexMang=indexSlave(find(messageId_cap(indexSlave)==13));
interMessageTime(indexSync)={0, calc_delta(capturedTimestamp_cap(indexSync))};
interMessageTime(indexDreq)={0, calc_delta(capturedTimestamp_cap(indexDreq))};
interMessageTime(indexPreq)={0, calc_delta(capturedTimestamp_cap(indexPreq))};
interMessageTime(indexPres)={0, calc_delta(capturedTimestamp_cap(indexPres))};
interMessageTime(indexFlup)={0, calc_delta(capturedTimestamp_cap(indexFlup))};
interMessageTime(indexDres)={0, calc_delta(capturedTimestamp_cap(indexDres))};
interMessageTime(indexPrfl)={0, calc_delta(capturedTimestamp_cap(indexPrfl))};
interMessageTime(indexAnnc)={0, calc_delta(capturedTimestamp_cap(indexAnnc))};
interMessageTime(indexSign)={0, calc_delta(capturedTimestamp_cap(indexSign))};
interMessageTime(indexMang)={0, calc_delta(capturedTimestamp_cap(indexMang))};

u=file('open',PWD+'/ptpv2_'+'parsed'+'.csv','unknown');
  fprintf(u,"Port, Packet #, Arrival Time, Inter-Packet Time, Inter-Message Time, messageType, sequenceId, embedded Time");
for i = 1:(length(packetNum_cap))
  fprintf(u,"%s, %d, %6.9f, %6.9f, %6.9f, %s, %d, %6.9f", clockId_str_cap(i), packetNum_cap(i), capturedTimestamp_cap(i)-capturedTimestamp_cap(1), interPacketTime(i), interMessageTime(i), messageId_str_cap(i), sequenceId_cap(i), embeddedTimestamp_cap(i));
end
file('close',u);

///////////////////////////////////////
// Generate graph
///////////////////////////////////////

// 1. SYNC PDV
subplot(8,1,1);
xtitle('', '', 'SYNC PDV/s');
indexSync=find(messageId_cap==0);
indexFlup=find(messageId_cap==8);
indexSync=indexSync(find(clockId_cap(indexSync)==clockId_mastr)); // SYNC M->S
indexFlup=indexFlup(find(clockId_cap(indexFlup)==clockId_mastr)); // FLUP M->S
capturedTimestamp_sync=capturedTimestamp_cap(indexSync); // t2
sequenceId_sync       =sequenceId_cap       (indexSync);
embeddedTimestamp_flup=embeddedTimestamp_cap(indexFlup); // t1
sequenceId_flup       =sequenceId_cap       (indexFlup);

captured_sync={};
embedded_flup={};
for i=1:length(sequenceId_sync)
  index=find(sequenceId_flup==sequenceId_sync(i));
  if index==[]
    continue;
  else
    captured_sync={captured_sync, capturedTimestamp_sync(i)};
    embedded_flup={embedded_flup, embeddedTimestamp_flup(index)};
  end
end

captured_syncDelta=calc_delta(captured_sync);
embedded_flupDelta=calc_delta(embedded_flup);
plot((captured_sync(2:length(captured_sync))-capturedTimestamp_cap(1)), (captured_syncDelta-embedded_flupDelta));

// 2. DELAY_REQ PDV
subplot(8,1,2);
xtitle('', '', 'DELAY_REQ PDV/s');
indexReq=find(messageId_cap==2);
indexRes=find(messageId_cap==3);
indexReq=indexSync(find(clockId_cap(indexReq)==clockId_slave)); // DELAY_REQ S->M
indexRes=indexFlup(find(clockId_cap(indexRes)==clockId_mastr)); // DELAY_RES M->S
capturedTimestamp_req=capturedTimestamp_cap(indexReq); // t3
sequenceId_req       =sequenceId_cap       (indexReq);
embeddedTimestamp_res=embeddedTimestamp_cap(indexRes); // t4
sequenceId_res       =sequenceId_cap       (indexRes);

captured_req={};
embedded_res={};
for i=1:length(sequenceId_req)
  index=find(sequenceId_res==sequenceId_req(i));
  if index==[]
    continue;
  else
    captured_req={captured_req, capturedTimestamp_req(i)};
    embedded_res={embedded_res, embeddedTimestamp_res(index)};
  end
end

captured_reqDelta=calc_delta(captured_req);
embedded_resDelta=calc_delta(embedded_res);
plot((captured_req(2:length(captured_req))-capturedTimestamp_cap(1)), (captured_reqDelta-embedded_resDelta));

// 3. FOLLOW_UP PDV
subplot(8,1,3);
xtitle('', '', 'FOLLOW_UP PDV/s');
indexSync=find(messageId_cap==0);
indexFlup=find(messageId_cap==8);
indexSync=indexSync(find(clockId_cap(indexSync)==clockId_mastr)); // SYNC M->S
indexFlup=indexFlup(find(clockId_cap(indexFlup)==clockId_mastr)); // FLUP M->S
capturedTimestamp_sync=capturedTimestamp_cap(indexSync); // t2
sequenceId_sync       =sequenceId_cap       (indexSync);
capturedTimestamp_flup=capturedTimestamp_cap(indexFlup);
sequenceId_flup       =sequenceId_cap       (indexFlup);

captured_sync={};
captured_flup={};
for i=1:length(sequenceId_sync)
  index=find(sequenceId_flup==sequenceId_sync(i));
  if index==[]
    continue;
  else
    captured_sync={captured_sync, capturedTimestamp_sync(i)};
    captured_flup={captured_flup, capturedTimestamp_flup(index)};
  end
end

captured_syncDelta=calc_delta(captured_sync);
captured_flupDelta=calc_delta(captured_flup);
plot((captured_sync(2:length(captured_sync))-capturedTimestamp_cap(1)), (captured_flupDelta-captured_syncDelta));

// 4. Slave Clock Wander
subplot(8,1,4);
xtitle('', '', 'Slave Clock Wander/s');
indexReq=find(messageId_cap==2);
indexReq=indexReq(find(clockId_cap(indexReq)==clockId_slave)); // PATH_DELAY_REQ S->M
capturedTimestamp_req=capturedTimestamp_cap(indexReq); // t4
embeddedTimestamp_req=embeddedTimestamp_cap(indexReq);
sequenceId_req       =sequenceId_cap       (indexReq);

captured_req={};
embedded_req={};
for i=1:length(sequenceId_req)
  index=find(sequenceId_req==sequenceId_req(i));
  if index==[]
    continue;
  else
    captured_req={captured_req, capturedTimestamp_req(index)};
    embedded_req={embedded_req, embeddedTimestamp_req(index)};
  end
end

embedded_reqDelta=calc_delta(embedded_req);
plot((captured_req(2:length(captured_req))-capturedTimestamp_cap(1)), embedded_reqDelta-mean(embedded_reqDelta));

// 5. Round Trip Delay variation
subplot(8,1,5);
xtitle('', '', 'RTD Variation/s');
indexSync=find(messageId_cap==0);
indexFlup=find(messageId_cap==8);
indexSync=indexSync(find(clockId_cap(indexSync)==clockId_mastr)); // SYNC M->S
indexFlup=indexFlup(find(clockId_cap(indexFlup)==clockId_mastr)); // FLUP M->S
capturedTimestamp_sync=capturedTimestamp_cap(indexSync); // t2
sequenceId_sync       =sequenceId_cap       (indexSync);
embeddedTimestamp_flup=embeddedTimestamp_cap(indexFlup); // t1
sequenceId_flup       =sequenceId_cap       (indexFlup);

captured_sync={};
embedded_flup={};
for i=1:length(sequenceId_sync)
  index=find(sequenceId_flup==sequenceId_sync(i));
  if index==[]
    continue;
  else
    captured_sync={captured_sync, capturedTimestamp_sync(i)};
    embedded_flup={embedded_flup, embeddedTimestamp_flup(index)};
  end
end

indexReq=find(messageId_cap==2);
indexRes=find(messageId_cap==3);
indexReq=indexReq(find(clockId_cap(indexReq)==clockId_slave)); // DELAY_REQ S->M
indexRes=indexRes(find(clockId_cap(indexRes)==clockId_mastr)); // DELAY_RES M->S 
capturedTimestamp_req=capturedTimestamp_cap(indexReq); // t3
sequenceId_req       =sequenceId_cap       (indexReq);
embeddedTimestamp_res=embeddedTimestamp_cap(indexRes); // t4
sequenceId_res       =sequenceId_cap       (indexRes);

captured_req={};
embedded_res={};
for i=1:length(sequenceId_req)
  index=find(sequenceId_res==sequenceId_req(i));
  if index==[]
    continue;
  else
    captured_req={captured_req, capturedTimestamp_req(i)};
    embedded_res={embedded_res, embeddedTimestamp_res(index)};
  end
end

captured_syncDelta=calc_delta(captured_sync);
embedded_flupDelta=calc_delta(embedded_flup);
captured_reqDelta=calc_delta(captured_req);
embedded_resDelta=calc_delta(embedded_res);
commonLength=min(length(captured_sync),length(captured_req));
captured_syncDelta=captured_syncDelta(1:commonLength-1);
embedded_flupDelta=embedded_flupDelta(1:commonLength-1);
captured_reqDelta=captured_reqDelta(1:commonLength-1);
embedded_resDelta=embedded_resDelta(1:commonLength-1);
plot((captured_req(2:commonLength)-capturedTimestamp_cap(1)), ((captured_syncDelta-embedded_flupDelta)+(embedded_resDelta-captured_reqDelta))/2); //((t2-t1)+(t4-t3))/2

// 6. Asymmetry
subplot(8,1,6);
xtitle('', '', 'Delay Asymmetry/s');
indexSync=find(messageId_cap==0);
indexFlup=find(messageId_cap==8);
indexSync=indexSync(find(clockId_cap(indexSync)==clockId_mastr)); // SYNC M->S
indexFlup=indexFlup(find(clockId_cap(indexFlup)==clockId_mastr)); // FLUP M->S
capturedTimestamp_sync=capturedTimestamp_cap(indexSync); // t2
sequenceId_sync       =sequenceId_cap       (indexSync);
embeddedTimestamp_flup=embeddedTimestamp_cap(indexFlup); // t1
sequenceId_flup       =sequenceId_cap       (indexFlup);

captured_sync={};
embedded_flup={};
for i=1:length(sequenceId_sync)
  index=find(sequenceId_flup==sequenceId_sync(i));
  if index==[]
    continue;
  else
    captured_sync={captured_sync, capturedTimestamp_sync(i)};
    embedded_flup={embedded_flup, embeddedTimestamp_flup(index)};
  end
end

indexReq=find(messageId_cap==2);
indexRes=find(messageId_cap==3);
indexReq=indexReq(find(clockId_cap(indexReq)==clockId_slave)); // DELAY_REQ S->M
indexRes=indexRes(find(clockId_cap(indexRes)==clockId_mastr)); // DELAY_RES M->S 
capturedTimestamp_req=capturedTimestamp_cap(indexReq); // t3
sequenceId_req       =sequenceId_cap       (indexReq);
embeddedTimestamp_res=embeddedTimestamp_cap(indexRes); // t4
sequenceId_res       =sequenceId_cap       (indexRes);

captured_req={};
embedded_res={};
for i=1:length(sequenceId_req)
  index=find(sequenceId_res==sequenceId_req(i));
  if index==[]
    continue;
  else
    captured_req={captured_req, capturedTimestamp_req(i)};
    embedded_res={embedded_res, embeddedTimestamp_res(index)};
  end
end

commonLength=min(length(captured_sync),length(captured_req));
captured_sync=captured_sync(1:commonLength);
embedded_flup=embedded_flup(1:commonLength);
captured_req=captured_req(1:commonLength);
embedded_res=embedded_res(1:commonLength);
plot((captured_req(1:commonLength)-capturedTimestamp_cap(1)), (captured_sync-embedded_flup)-(embedded_res-captured_req)); //(t2-t1)-(t4-t3)

// 7. Sync Inter-Packet Gap
subplot(8,1,7);
xtitle('', '', 'SYNC IPG/s');
indexSync=find(messageId_cap==0);
indexSync=indexSync(find(clockId_cap(indexSync)==clockId_mastr)); // SYNC M->S
capturedTimestamp_sync=capturedTimestamp_cap(indexSync); // t2
sequenceId_sync       =sequenceId_cap       (indexSync);

captured_sync={};
for i=1:length(sequenceId_sync)
  index=find(sequenceId_sync==sequenceId_sync(i));
  if index==[]
    continue;
  else
    captured_sync={captured_sync, capturedTimestamp_sync(index)};
  end
end

captured_syncDelta=calc_delta(captured_sync);
plot((captured_sync(2:length(captured_sync))-capturedTimestamp_cap(1)), captured_syncDelta);

// 8. Delay-Resp Round Trip Delay
subplot(8,1,8);
xtitle('', '', 'Delay-Resp Latency/s');
indexReq=find(messageId_cap==2);
indexRes=find(messageId_cap==3);
indexReq=indexReq(find(clockId_cap(indexReq)==clockId_slave)); // DELAY_REQ S->M
indexRes=indexRes(find(clockId_cap(indexRes)==clockId_mastr)); // DELAY_RES M->S 
capturedTimestamp_req=capturedTimestamp_cap(indexReq); // t3
sequenceId_req       =sequenceId_cap       (indexReq);
capturedTimestamp_res=capturedTimestamp_cap(indexRes);
sequenceId_res       =sequenceId_cap       (indexRes);

captured_req={};
captured_res={};
for i=1:length(sequenceId_req)
  index=find(sequenceId_res==sequenceId_req(i));
  if index==[]
    continue;
  else
    captured_req={captured_req, capturedTimestamp_req(i)};
    captured_res={captured_res, capturedTimestamp_res(index)};
  end
end

plot((captured_req(1:length(captured_req))-capturedTimestamp_cap(1)), (captured_res-captured_req));
