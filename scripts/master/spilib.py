from cheetah_py import *

class SpiComm:
  """Controls a Cheetah USB/SPI adapter to talk over SPI to the spiifc
  module"""
  
  _port = 0         # Change if using multiple Cheetahs
  _mode = 3         # spiifc SPI mode

  handle = None     # handle to Cheetah SPI

  class SpiCommError(Exception):
    """There was some error interacting with the Cheetah SPI adapter"""
    def __init__(self, msg):
      self.msg = msg

  def __init__(self, kbpsBitrate=9000):
    self.handle = ch_open(self._port)
    if (self.handle <= 0):
      raise SpiCommError("Unable to open Cheetah device on port %d.\nError code = %d (%s)" % (self._port, self.handle, ch_status_string(self.handle)))
    ch_host_ifce_speed(self.handle)
    ch_spi_configure(self.handle, (self._mode >> 1), self._mode & 1, 
        CH_SPI_BITORDER_MSB, 0x0)
    ch_spi_bitrate(self.handle, kbpsBitrate)

  def __del__(self):
    ch_close(self.handle)

  def SendToSlave(self, byteArray):
    byteCount = len(byteArray) + 1
    data_in = array('B', [0 for i in range(byteCount)])
    actualByteCount = 0
    ch_spi_queue_clear(self.handle)
    ch_spi_queue_oe(self.handle, 1)
    ch_spi_queue_ss(self.handle, 0x1)
    for byte in byteArray:
      ch_spi_queue_byte(self.handle, 1, byte)
    ch_spi_queue_ss(self.handle, 0)
    ch_spi_queue_oe(self.handle, 0)
    (actualByteCount, data_in) = ch_spi_batch_shift(self.handle, byteCount)
    
  def RecvFromSlave(self, command, byteCount):
    totalByteCount = byteCount + 1          # Extra byte for cmd
    data_in = array('B', [0 for i in range(totalByteCount)])
    actualByteCount = 0
    ch_spi_queue_clear(self.handle)
    ch_spi_queue_oe(self.handle, 1)
    ch_spi_queue_ss(self.handle, 1)
    ch_spi_queue_byte(self.handle, 1, command)    # Receive data from slave
    ch_spi_queue_byte(self.handle, byteCount, 0xFF)
    ch_spi_queue_ss(self.handle, 0x0)
    ch_spi_queue_oe(self.handle, 0)
    (actualByteCount, data_in) = ch_spi_batch_shift(self.handle,
        totalByteCount)
    return data_in[1:]

  def ReadMemory(self, byteCount):
    return self.RecvFromSlave(0x3, byteCount)

  def WriteMemory(self, bytesToWrite):
    bytePacket = [0x01]
    bytePacket.extend(bytesToWrite)
    return self.SendToSlave(bytePacket)

  def ReadReg(self, regId):
    commandCode = 0x80 + regId
    regValBytes = self.RecvFromSlave(commandCode, 4)
    regValWord = 0
    for regValByte in regValBytes:
      regValWord = (regValWord * 256) + regValByte
    return regValWord

  def WriteReg(self, regId, value):
    commandCode = 0xC0 + regId
    bytesToSend = [commandCode, 0, 0, 0, 0]
    for sendByteId in range(4,0,-1):
      bytesToSend[sendByteId] = value % 256
      value = value / 256
    self.SendToSlave(bytesToSend)

