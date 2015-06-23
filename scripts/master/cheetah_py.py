#==========================================================================
# Cheetah Interface Library
#--------------------------------------------------------------------------
# Copyright (c) 2004-2008 Total Phase, Inc.
# All rights reserved.
# www.totalphase.com
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# - Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
# - Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
# - Neither the name of Total Phase, Inc. nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#--------------------------------------------------------------------------
# To access Total Phase Cheetah devices through the API:
#
# 1) Use one of the following shared objects:
#      cheetah.so       --  Linux shared object
#          or
#      cheetah.dll      --  Windows dynamic link library
#
# 2) Along with one of the following language modules:
#      cheetah.c/h      --  C/C++ API header file and interface module
#      cheetah_py.py    --  Python API
#      cheetah.bas      --  Visual Basic 6 API
#      cheetah.cs       --  C# .NET source
#      cheetah_net.dll  --  Compiled .NET binding
#==========================================================================


#==========================================================================
# VERSION
#==========================================================================
CH_API_VERSION    = 0x0300   # v3.00
CH_REQ_SW_VERSION = 0x0300   # v3.00

import os
import sys
try:
    import cheetah as api
except ImportError, ex1:
    import imp, platform
    ext = platform.system() == 'Windows' and '.dll' or '.so'
    try:
        api = imp.load_dynamic('cheetah', 'cheetah' + ext)
    except ImportError, ex2:
        msg  = 'Error importing cheetah%s\n' % ext
        msg += '  Architecture of cheetah%s may be wrong\n' % ext
        msg += '%s\n%s' % (ex1, ex2)
        raise ImportError(msg)

CH_SW_VERSION      = api.py_version() & 0xffff
CH_REQ_API_VERSION = (api.py_version() >> 16) & 0xffff
CH_LIBRARY_LOADED  = \
    ((CH_SW_VERSION >= CH_REQ_SW_VERSION) and \
     (CH_API_VERSION >= CH_REQ_API_VERSION))

from array import array, ArrayType
import struct


#==========================================================================
# HELPER FUNCTIONS
#==========================================================================
def array_u08 (n):  return array('B', '\0'*n)
def array_u16 (n):  return array('H', '\0\0'*n)
def array_u32 (n):  return array('I', '\0\0\0\0'*n)
def array_u64 (n):  return array('K', '\0\0\0\0\0\0\0\0'*n)
def array_s08 (n):  return array('b', '\0'*n)
def array_s16 (n):  return array('h', '\0\0'*n)
def array_s32 (n):  return array('i', '\0\0\0\0'*n)
def array_s64 (n):  return array('L', '\0\0\0\0\0\0\0\0'*n)


#==========================================================================
# STATUS CODES
#==========================================================================
# All API functions return an integer which is the result of the
# transaction, or a status code if negative.  The status codes are
# defined as follows:
# enum CheetahStatus
# General codes (0 to -99)
CH_OK                      =    0
CH_UNABLE_TO_LOAD_LIBRARY  =   -1
CH_UNABLE_TO_LOAD_DRIVER   =   -2
CH_UNABLE_TO_LOAD_FUNCTION =   -3
CH_INCOMPATIBLE_LIBRARY    =   -4
CH_INCOMPATIBLE_DEVICE     =   -5
CH_INCOMPATIBLE_DRIVER     =   -6
CH_COMMUNICATION_ERROR     =   -7
CH_UNABLE_TO_OPEN          =   -8
CH_UNABLE_TO_CLOSE         =   -9
CH_INVALID_HANDLE          =  -10
CH_CONFIG_ERROR            =  -11
CH_UNKNOWN_PROTOCOL        =  -12
CH_STILL_ACTIVE            =  -13
CH_FUNCTION_NOT_AVAILABLE  =  -14
CH_OS_ERROR                =  -15

# SPI codes (-100 to -199)
CH_SPI_WRITE_ERROR         = -100
CH_SPI_BATCH_EMPTY_QUEUE   = -101
CH_SPI_BATCH_SHORT_BUFFER  = -102
CH_SPI_ASYNC_EMPTY         = -103
CH_SPI_ASYNC_PENDING       = -104
CH_SPI_ASYNC_MAX_REACHED   = -105
CH_SPI_ASYNC_EXCESS_DELAY  = -106


#==========================================================================
# GENERAL TYPE DEFINITIONS
#==========================================================================
# Cheetah handle type definition
# typedef Cheetah => integer

# Cheetah version matrix.
# 
# This matrix describes the various version dependencies
# of Cheetah components.  It can be used to determine
# which component caused an incompatibility error.
# 
# All version numbers are of the format:
#   (major << 8) | minor
# 
# ex. v1.20 would be encoded as:  0x0114
class CheetahVersion:
    def __init__ (self):
        # Software, firmware, and hardware versions.
        self.software        = 0
        self.firmware        = 0
        self.hardware        = 0

        # Hardware revisions that are compatible with this software version.
        # The top 16 bits gives the maximum accepted hardware revision.
        # The lower 16 bits gives the minimum accepted hardware revision.
        self.hw_revs_for_sw  = 0

        # Firmware revisions that are compatible with this software version.
        # The top 16 bits gives the maximum accepted fw revision.
        # The lower 16 bits gives the minimum accepted fw revision.
        self.fw_revs_for_sw  = 0

        # Driver revisions that are compatible with this software version.
        # The top 16 bits gives the maximum accepted driver revision.
        # The lower 16 bits gives the minimum accepted driver revision.
        # This version checking is currently only pertinent for WIN32
        # platforms.
        self.drv_revs_for_sw = 0

        # Software requires that the API interface must be >= this version.
        self.api_req_by_sw   = 0


#==========================================================================
# GENERAL API
#==========================================================================
# Get a list of ports to which Cheetah devices are attached.
# 
# num_devices = maximum number of elements to return
# devices     = array into which the port numbers are returned
# 
# Each element of the array is written with the port number.
# Devices that are in-use are ORed with CH_PORT_NOT_FREE
# (0x8000).
#
# ex.  devices are attached to ports 0, 1, 2
#      ports 0 and 2 are available, and port 1 is in-use.
#      array => 0x0000, 0x8001, 0x0002
# 
# If the array is NULL, it is not filled with any values.
# If there are more devices than the array size, only the
# first nmemb port numbers will be written into the array.
# 
# Returns the number of devices found, regardless of the
# array size.
CH_PORT_NOT_FREE = 0x8000
def ch_find_devices (devices):
    """usage: (int return, u16[] devices) = ch_find_devices(u16[] devices)

    All arrays can be passed into the API as an ArrayType object or as
    a tuple (array, length), where array is an ArrayType object and
    length is an integer.  The user-specified length would then serve
    as the length argument to the API funtion (please refer to the
    product datasheet).  If only the array is provided, the array's
    intrinsic length is used as the argument to the underlying API
    function.

    Additionally, for arrays that are filled by the API function, an
    integer can be passed in place of the array argument and the API
    will automatically create an array of that length.  All output
    arrays, whether passed in or generated, are passed back in the
    returned tuple."""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # devices pre-processing
    __devices = isinstance(devices, int)
    if __devices:
        (devices, num_devices) = (array_u16(devices), devices)
    else:
        (devices, num_devices) = isinstance(devices, ArrayType) and (devices, len(devices)) or (devices[0], min(len(devices[0]), int(devices[1])))
        if devices.typecode != 'H':
            raise TypeError("type for 'devices' must be array('H')")
    # Call API function
    (_ret_) = api.py_ch_find_devices(num_devices, devices)
    # devices post-processing
    if __devices: del devices[max(0, min(_ret_, len(devices))):]
    return (_ret_, devices)


# Get a list of ports to which Cheetah devices are attached
#
# This function is the same as ch_find_devices() except that
# it returns the unique IDs of each Cheetah device.  The IDs
# are guaranteed to be non-zero if valid.
#
# The IDs are the unsigned integer representation of the 10-digit
# serial numbers.
def ch_find_devices_ext (devices, unique_ids):
    """usage: (int return, u16[] devices, u32[] unique_ids) = ch_find_devices_ext(u16[] devices, u32[] unique_ids)

    All arrays can be passed into the API as an ArrayType object or as
    a tuple (array, length), where array is an ArrayType object and
    length is an integer.  The user-specified length would then serve
    as the length argument to the API funtion (please refer to the
    product datasheet).  If only the array is provided, the array's
    intrinsic length is used as the argument to the underlying API
    function.

    Additionally, for arrays that are filled by the API function, an
    integer can be passed in place of the array argument and the API
    will automatically create an array of that length.  All output
    arrays, whether passed in or generated, are passed back in the
    returned tuple."""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # devices pre-processing
    __devices = isinstance(devices, int)
    if __devices:
        (devices, num_devices) = (array_u16(devices), devices)
    else:
        (devices, num_devices) = isinstance(devices, ArrayType) and (devices, len(devices)) or (devices[0], min(len(devices[0]), int(devices[1])))
        if devices.typecode != 'H':
            raise TypeError("type for 'devices' must be array('H')")
    # unique_ids pre-processing
    __unique_ids = isinstance(unique_ids, int)
    if __unique_ids:
        (unique_ids, num_ids) = (array_u32(unique_ids), unique_ids)
    else:
        (unique_ids, num_ids) = isinstance(unique_ids, ArrayType) and (unique_ids, len(unique_ids)) or (unique_ids[0], min(len(unique_ids[0]), int(unique_ids[1])))
        if unique_ids.typecode != 'I':
            raise TypeError("type for 'unique_ids' must be array('I')")
    # Call API function
    (_ret_) = api.py_ch_find_devices_ext(num_devices, num_ids, devices, unique_ids)
    # devices post-processing
    if __devices: del devices[max(0, min(_ret_, len(devices))):]
    # unique_ids post-processing
    if __unique_ids: del unique_ids[max(0, min(_ret_, len(unique_ids))):]
    return (_ret_, devices, unique_ids)


# Open the Cheetah port.
# 
# The port number is a zero-indexed integer.
#
# The port number is the same as that obtained from the
# ch_find_devices() function above.
# 
# Returns an Cheetah handle, which is guaranteed to be
# greater than zero if it is valid.
# 
# This function is recommended for use in simple applications
# where extended information is not required.  For more complex
# applications, the use of ch_open_ext() is recommended.
def ch_open (port_number):
    """usage: Cheetah return = ch_open(int port_number)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_open(port_number)


# Open the Cheetah port, returning extended information
# in the supplied structure.  Behavior is otherwise identical
# to ch_open() above.  If 0 is passed as the pointer to the
# structure, this function is exactly equivalent to ch_open().
# 
# The structure is zeroed before the open is attempted.
# It is filled with whatever information is available.
# 
# For example, if the hardware version is not filled, then
# the device could not be queried for its version number.
# 
# This function is recommended for use in complex applications
# where extended information is required.  For more simple
# applications, the use of ch_open() is recommended.
class CheetahExt:
    def __init__ (self):
        # Version matrix
        self.version  = CheetahVersion()

        # Features of this device.
        self.features = 0

def ch_open_ext (port_number):
    """usage: (Cheetah return, CheetahExt ch_ext) = ch_open_ext(int port_number)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    (_ret_, c_ch_ext) = api.py_ch_open_ext(port_number)
    # ch_ext post-processing
    ch_ext = CheetahExt()
    (ch_ext.version.software, ch_ext.version.firmware, ch_ext.version.hardware, ch_ext.version.hw_revs_for_sw, ch_ext.version.fw_revs_for_sw, ch_ext.version.drv_revs_for_sw, ch_ext.version.api_req_by_sw, ch_ext.features) = c_ch_ext
    return (_ret_, ch_ext)


# Close the Cheetah port.
def ch_close (cheetah):
    """usage: int return = ch_close(Cheetah cheetah)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_close(cheetah)


# Return the port for this Cheetah handle.
# 
# The port number is a zero-indexed integer.
def ch_port (cheetah):
    """usage: int return = ch_port(Cheetah cheetah)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_port(cheetah)


# Return the unique ID for this Cheetah adapter.
# IDs are guaranteed to be non-zero if valid.
# The ID is the unsigned integer representation of the
# 10-digit serial number.
def ch_unique_id (cheetah):
    """usage: u32 return = ch_unique_id(Cheetah cheetah)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_unique_id(cheetah)


# Return the status string for the given status code.
# If the code is not valid or the library function cannot
# be loaded, return a NULL string.
def ch_status_string (status):
    """usage: str return = ch_status_string(int status)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_status_string(status)


# Return the version matrix for the device attached to the
# given handle.  If the handle is 0 or invalid, only the
# software and required api versions are set.
def ch_version (cheetah):
    """usage: (int return, CheetahVersion version) = ch_version(Cheetah cheetah)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    (_ret_, c_version) = api.py_ch_version(cheetah)
    # version post-processing
    version = CheetahVersion()
    (version.software, version.firmware, version.hardware, version.hw_revs_for_sw, version.fw_revs_for_sw, version.drv_revs_for_sw, version.api_req_by_sw) = c_version
    return (_ret_, version)


# Sleep for the specified number of milliseconds
# Accuracy depends on the operating system scheduler
# Returns the number of milliseconds slept
def ch_sleep_ms (milliseconds):
    """usage: u32 return = ch_sleep_ms(u32 milliseconds)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_sleep_ms(milliseconds)


# Configure the target power pin.
CH_TARGET_POWER_OFF = 0x00
CH_TARGET_POWER_ON = 0x01
CH_TARGET_POWER_QUERY = 0x80
def ch_target_power (cheetah, power_flag):
    """usage: int return = ch_target_power(Cheetah cheetah, u08 power_flag)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_target_power(cheetah, power_flag)


CH_HOST_IFCE_FULL_SPEED = 0x00
CH_HOST_IFCE_HIGH_SPEED = 0x01
def ch_host_ifce_speed (cheetah):
    """usage: int return = ch_host_ifce_speed(Cheetah cheetah)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_host_ifce_speed(cheetah)


# Returns the device address that the beagle is attached to.
def ch_dev_addr (cheetah):
    """usage: int return = ch_dev_addr(Cheetah cheetah)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_dev_addr(cheetah)



#==========================================================================
# SPI API
#==========================================================================
# Set the SPI bit rate in kilohertz.
def ch_spi_bitrate (cheetah, bitrate_khz):
    """usage: int return = ch_spi_bitrate(Cheetah cheetah, int bitrate_khz)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_spi_bitrate(cheetah, bitrate_khz)


# These configuration parameters specify how to clock the
# bits that are sent and received on the Cheetah SPI
# interface.
# 
# The polarity option specifies which transition
# constitutes the leading edge and which transition is the
# falling edge.  For example, CH_SPI_POL_RISING_FALLING
# would configure the SPI to idle the SCK clock line low.
# The clock would then transition low-to-high on the
# leading edge and high-to-low on the trailing edge.
# 
# The phase option determines whether to sample or setup on
# the leading edge.  For example, CH_SPI_PHASE_SAMPLE_SETUP
# would configure the SPI to sample on the leading edge and
# setup on the trailing edge.
# 
# The bitorder option is used to indicate whether LSB or
# MSB is shifted first.
#
# The SS polarity option is to indicate the polarity of the
# slave select pin (active high or active low).  Each of
# the lower three bits of ss_polarity corresponds to each
# of the SS lines.  Set the bit value for a given SS line
# to 0 for active low or 1 for active high.
# enum CheetahSpiPolarity
CH_SPI_POL_RISING_FALLING = 0
CH_SPI_POL_FALLING_RISING = 1

# enum CheetahSpiPhase
CH_SPI_PHASE_SAMPLE_SETUP = 0
CH_SPI_PHASE_SETUP_SAMPLE = 1

# enum CheetahSpiBitorder
CH_SPI_BITORDER_MSB = 0
CH_SPI_BITORDER_LSB = 1

# Configure the SPI master interface
def ch_spi_configure (cheetah, polarity, phase, bitorder, ss_polarity):
    """usage: int return = ch_spi_configure(Cheetah cheetah, CheetahSpiPolarity polarity, CheetahSpiPhase phase, CheetahSpiBitorder bitorder, u08 ss_polarity)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_spi_configure(cheetah, polarity, phase, bitorder, ss_polarity)


# Clear the batch queue
def ch_spi_queue_clear (cheetah):
    """usage: int return = ch_spi_queue_clear(Cheetah cheetah)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_spi_queue_clear(cheetah)


# Enable / disable the master outputs
def ch_spi_queue_oe (cheetah, oe):
    """usage: int return = ch_spi_queue_oe(Cheetah cheetah, u08 oe)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_spi_queue_oe(cheetah, oe)


# Queue a delay in clock cycles
# The return value is the actual number of cycles queued.
def ch_spi_queue_delay_cycles (cheetah, cycles):
    """usage: int return = ch_spi_queue_delay_cycles(Cheetah cheetah, int cycles)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_spi_queue_delay_cycles(cheetah, cycles)


# Queue a delay in nanoseconds
# The return value is the approximate number of nanoseconds queued.
def ch_spi_queue_delay_ns (cheetah, nanoseconds):
    """usage: int return = ch_spi_queue_delay_ns(Cheetah cheetah, int nanoseconds)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_spi_queue_delay_ns(cheetah, nanoseconds)


# Assert the slave select lines.  Each of the lower three
# bits of ss_polarity corresponds to each of the SS lines.
# Set the bit value for a given SS line to 1 to assert the
# line or 0 to deassert the line.  The polarity is determined
# by ch_spi_configure() above.
def ch_spi_queue_ss (cheetah, active):
    """usage: int return = ch_spi_queue_ss(Cheetah cheetah, u08 active)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_spi_queue_ss(cheetah, active)


# Repeatedly send a single byte
def ch_spi_queue_byte (cheetah, count, data):
    """usage: int return = ch_spi_queue_byte(Cheetah cheetah, int count, u08 data)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_spi_queue_byte(cheetah, count, data)


# Send a byte array.  Repeated bytes are automatically
# optimized into a repeated byte sequence.
def ch_spi_queue_array (cheetah, data_out):
    """usage: int return = ch_spi_queue_array(Cheetah cheetah, u08[] data_out)

    All arrays can be passed into the API as an ArrayType object or as
    a tuple (array, length), where array is an ArrayType object and
    length is an integer.  The user-specified length would then serve
    as the length argument to the API funtion (please refer to the
    product datasheet).  If only the array is provided, the array's
    intrinsic length is used as the argument to the underlying API
    function."""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # data_out pre-processing
    (data_out, num_bytes) = isinstance(data_out, ArrayType) and (data_out, len(data_out)) or (data_out[0], min(len(data_out[0]), int(data_out[1])))
    if data_out.typecode != 'B':
        raise TypeError("type for 'data_out' must be array('B')")
    # Call API function
    return api.py_ch_spi_queue_array(cheetah, num_bytes, data_out)


# Calculate the expected length of the returned data
def ch_spi_batch_length (cheetah):
    """usage: int return = ch_spi_batch_length(Cheetah cheetah)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_spi_batch_length(cheetah)


# Perform the SPI shift operation.
#
# After the operation completes, the batch queue is untouched.
# Therefore, this function may be called repeatedly in rapid
# succession.
def ch_spi_batch_shift (cheetah, data_in):
    """usage: (int return, u08[] data_in) = ch_spi_batch_shift(Cheetah cheetah, u08[] data_in)

    All arrays can be passed into the API as an ArrayType object or as
    a tuple (array, length), where array is an ArrayType object and
    length is an integer.  The user-specified length would then serve
    as the length argument to the API funtion (please refer to the
    product datasheet).  If only the array is provided, the array's
    intrinsic length is used as the argument to the underlying API
    function.

    Additionally, for arrays that are filled by the API function, an
    integer can be passed in place of the array argument and the API
    will automatically create an array of that length.  All output
    arrays, whether passed in or generated, are passed back in the
    returned tuple."""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # data_in pre-processing
    __data_in = isinstance(data_in, int)
    if __data_in:
        (data_in, num_bytes) = (array_u08(data_in), data_in)
    else:
        (data_in, num_bytes) = isinstance(data_in, ArrayType) and (data_in, len(data_in)) or (data_in[0], min(len(data_in[0]), int(data_in[1])))
        if data_in.typecode != 'B':
            raise TypeError("type for 'data_in' must be array('B')")
    # Call API function
    (_ret_) = api.py_ch_spi_batch_shift(cheetah, num_bytes, data_in)
    # data_in post-processing
    if __data_in: del data_in[max(0, min(num_bytes, len(data_in))):]
    return (_ret_, data_in)


# Queue the current batch queue for asynchronous shifting.
#
# After the operation completes, the batch queue is untouched.
# Therefore, this function may be called repeatedly in rapid
# succession.
def ch_spi_async_submit (cheetah):
    """usage: int return = ch_spi_async_submit(Cheetah cheetah)"""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # Call API function
    return api.py_ch_spi_async_submit(cheetah)


# Collect an asynchronous batch that was previously submitted.
def ch_spi_async_collect (cheetah, data_in):
    """usage: (int return, u08[] data_in) = ch_spi_async_collect(Cheetah cheetah, u08[] data_in)

    All arrays can be passed into the API as an ArrayType object or as
    a tuple (array, length), where array is an ArrayType object and
    length is an integer.  The user-specified length would then serve
    as the length argument to the API funtion (please refer to the
    product datasheet).  If only the array is provided, the array's
    intrinsic length is used as the argument to the underlying API
    function.

    Additionally, for arrays that are filled by the API function, an
    integer can be passed in place of the array argument and the API
    will automatically create an array of that length.  All output
    arrays, whether passed in or generated, are passed back in the
    returned tuple."""

    if not CH_LIBRARY_LOADED: return CH_INCOMPATIBLE_LIBRARY
    # data_in pre-processing
    __data_in = isinstance(data_in, int)
    if __data_in:
        (data_in, num_bytes) = (array_u08(data_in), data_in)
    else:
        (data_in, num_bytes) = isinstance(data_in, ArrayType) and (data_in, len(data_in)) or (data_in[0], min(len(data_in[0]), int(data_in[1])))
        if data_in.typecode != 'B':
            raise TypeError("type for 'data_in' must be array('B')")
    # Call API function
    (_ret_) = api.py_ch_spi_async_collect(cheetah, num_bytes, data_in)
    # data_in post-processing
    if __data_in: del data_in[max(0, min(num_bytes, len(data_in))):]
    return (_ret_, data_in)


