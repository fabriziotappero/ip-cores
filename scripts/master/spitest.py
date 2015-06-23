import sys
import spilib
import time
import datetime
import random

def GenRandomByteArray(byteCount):
  dataToSend = []
  for byteIndex in range(byteCount):
    dataToSend.append(random.randint(0, 255))
  return dataToSend

#
# SingleBytePacketTest: 
#
# Sends a predefined pattern of single-byte SPI transmissions (master-out)
#
def SingleBytePacketsSendTest():
  packetsToSend = [[0x55],[0xAA],[0x33],[0x66],[0xCC],[0x99],[0xF0],\
                   [0x0F],[0xFF],[0x00]]
  packetIndex = 0
  while True:
    dataToSend = packetsToSend[packetIndex]
    
    sys.stdout.write("Sending: [")
    for sendByte in dataToSend:
      sys.stdout.write(" 0x%02x" % (sendByte))
    sys.stdout.write(" ]\n")
    spi.SendToSlave(dataToSend)
  
    packetIndex = (packetIndex + 1) % len(packetsToSend)
    time.sleep(1)
  
    packetIndex + 1

#
# MultiBytePacketSendTest:
#
# Sends a predefined single multi-byte packet over SPI (master-out)
#
def MultiBytePacketSendTest():
  dataToSend = [0x01, 0x55, 0xAA, 0x33, 0x66, 0xCC, 0x99, 0xF0, 0xFF, 0x0F]
  sys.stdout.write("Sending: [")
  for sendByte in dataToSend:
    sys.stdout.write(" 0x%02x" % (sendByte))
  sys.stdout.write(" ]\n")
  spi.SendToSlave(dataToSend)

#
# MemLoopbackTest:
#
# Sends randomly generated blocks of data over SPI, then reads back 
# data. Assumes that slave is using a common read and write buffer
# and reads the block of data back. The test verifies that the block of 
# data is identical to the one sent. The test will run continuously
# until a received packet does not match the sent packet.
#
def MemLoopbackTest():
  passCount = 0
  loopbackErrors = 0
  packetByteSize = 4000
  while loopbackErrors == 0:
    print("PassCount: %d" % (passCount))
  
    dataToSend = GenRandomByteArray(packetByteSize)
    
    print("Sending [0x%x 0x%x 0x%x 0x%x 0x%x ...]" % (
        dataToSend[0], dataToSend[1], dataToSend[2],
        dataToSend[3], dataToSend[4]))
    
    # Send some data to the slave
    sys.stdout.write("Sending data to slave...");
    spi.WriteMemory(dataToSend)
    sys.stdout.write("done!\n")
   
    # Receive some data from the slave
    recvData = spi.ReadMemory(packetByteSize)
    
    # Make sure bytes sent match bytes received
    if len(recvData) != packetByteSize:
      sys.stdout.write("[FAIL] Did not receive 4096 bytes from spiifc\n")
      sys.exit(0)
    for byteIndex in range(packetByteSize):
      if recvData[byteIndex] != dataToSend[byteIndex]:
        sys.stdout.write("[FAIL] mismatch at index %d: sent=0x%x, recv=0x%x\n" \
            % (byteIndex, dataToSend[byteIndex], recvData[byteIndex]))
        loopbackErrors = loopbackErrors + 1
        if loopbackErrors >= 5:
          break
    if 0 == loopbackErrors:
      sys.stdout.write("[PASS] All loopback SPI bytes match.\n");
      passCount = passCount + 1

  # Print number of passed tests before failure
  print("PassCount: %d" % (passCount))

#
# RegLoopbackTest:
#
# Randomly writes and reads to vSPI's register and makes sure
# values are as expected
# 
def RegLoopbackTest():
  # First, zero out all registers
  print("Zeroing all registers...")
  for regId in range(16):
    spi.WriteReg(regId=regId, value=0)
  
  # Second, check that all registers are zeroed
  print("Checking all registers are zeroed...")
  for regId in range(16):
    regVal = spi.ReadReg(regId)
    if (0 != regVal):
      sys.stdout.write("ERROR: Reg %d was not zeroed (was 0x%08x)\n" % \
          (regId, regVal))
      return

  # Local mapping of expected register values
  expectedRegs = list(0 for i in range(16))

  # Random read and writes
  passCount = 0
  while (True):
    print("")
    regWriteId = random.randint(0, 15)
    regReadId = random.randint(0, 15)
    regWriteVal = random.randint(0, 0xFFFFFFFF)

    print("Writing Reg%d=0x%08x" % (regWriteId, regWriteVal))
    spi.WriteReg(regId=regWriteId, value=regWriteVal)
    expectedRegs[regWriteId] = regWriteVal

    print("Checking Reg%d==0x%08x" % (regReadId, expectedRegs[regReadId]))
    regReadVal = spi.ReadReg(regReadId)
    if (expectedRegs[regReadId] != regReadVal):
      sys.stderr.write("ERROR: Reg %d - expected=0x%08x, actual=0x%08x\n" % \
          (expectedRegs[regReadId], regReadVal))
      return
    
    passCount = passCount + 1
    print("PASS [%d]" % (passCount))

#
# ReadRegsTest
#
# Reads out the value of all registers
#
def ReadRegsTest():
  for regId in range(16):
    regVal = spi.ReadReg(regId)
    print("Reg%d = 0x%08x" % (regId, regVal))

#
# WriteRegsTest
#
# Writes a test pattern to the spi registers
#
def WriteRegsTest():
  for regId in range(16):
    regVal = 255 - regId
    regVal = (regVal * 256) + regVal
    regVal = (regVal * 256 * 256) + regVal
    print("Reg%d = 0x%08x" % (regId, regVal))
    spi.WriteReg(regId=regId, value=regVal) 

#
# XpsLoopbackTest
#
# Tests loopback utilizing the XPS/XSDK system and SPI memory + SPI.r0
#
def XpsLoopbackTest():
  dataBytes = 4096
  
  passCount = 0

  while (True):
    print("Starting run %d..." % (passCount + 1))

    # Generate random data blob
    dataToSend = GenRandomByteArray(dataBytes)
  
    # Send data blob
    print("Sending data to FPGA")
    spi.WriteMemory(dataToSend)
  
    # Set SPI.reg0 = 0x1 (M->S transfer complete)
    print("Setting spi.r0[0] = 1")
    spi.WriteReg(regId=0, value=0x1)
  
    # Wait for microblaze to finish DMAing data from MOSI to MISO buffer
    print("Waiting for FPGA's DMA to complete (poll spi.r0[1])")
    while 0 == (spi.ReadReg(regId=0) & 0x2):
      pass
  
    # Read MISO buffer
    print("Read data back from FPGA")
    recvData = spi.ReadMemory(len(dataToSend))
  
    print("Verify: comparing send and received data")
    # Verify loopbacked data matches original data
    errorCount = 0
    if len(recvData) != len(dataToSend):
      sys.stdout.write("[ERROR] received data blob length (%d) does not " + \
                       "match original length (%d)" % \
                       (len(recvData), len(dataToSend)))
      errorCount = errorCount + 1
      return
    for byteIndex in range(len(dataToSend)):
      if dataToSend[byteIndex] != recvData[byteIndex]:
        print("[ERROR] transmission mismatch - Index %d, Expect:0x%02x, " + \
              "Actual:0x%02x" % (byteIndex, dataToSend[byteIndex], \
              recvData[byteIndex]))
        errorCount = errorCount + 1
        if errorCount >= 5:
          print("Stopping due to errors...")
          return
    
    if 0 == errorCount:
      print("[PASS] Loopbacked without any errors\n")
      passCount = passCount + 1
    else:
      return
  
#
# PrintCliSyntax:
#
# Displays the syntax for the command line interface (CLI)
def PrintCliSyntax():
  print """
Syntax:
  spitest.py test [random-seed]
            
Valid tests (case sensitive): 
  - SingleBytePacketsSend
  - MultiBytePacketSend
  - MemLoopback
  - RegLoopback
  - ReadRegs
  - WriteRegs
  - XpsLoopback
"""

#
# Main
#  

# Parse CLI
if len(sys.argv) < 2 or len(sys.argv) > 3:
  PrintCliSyntax()
  sys.exit(1)

# Retreive specified test function(s)
cliTest = sys.argv[1]
testMapping = {'SingleBytePacketsSend' : [SingleBytePacketsSendTest],
               'MultiBytePacketSend' : [MultiBytePacketSendTest],
               'MemLoopback' : [MemLoopbackTest],
               'RegLoopback' : [RegLoopbackTest],
               'ReadRegs' : [ReadRegsTest],
               'WriteRegs' : [WriteRegsTest],
               'XpsLoopback' : [XpsLoopbackTest]}
if cliTest not in testMapping:
  sys.stderr.write('%s is not a valid test.\n' % (cliTest,))
  PrintCliSyntax()
  sys.exit(1)
testsToRun = testMapping[cliTest]

# Seed random number generator
if len(sys.argv) == 3:
  seed = int(sys.argv[2])
else:
  seed = datetime.datetime.utcnow().microsecond

# Initialize Cheetah SPI/USB adapter
spi = spilib.SpiComm()

# Seed random
print("Random seed: %d" % seed)
random.seed(seed)

# Run specified test
for testToRun in testsToRun:
  testToRun()

# Close and exit
sys.stdout.write("Exiting...\n")
sys.exit(0)

