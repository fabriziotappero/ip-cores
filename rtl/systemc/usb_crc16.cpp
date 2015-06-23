/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB CRC16                                                  ////
////                                                             ////
////  SystemC Version: usb_crc16.cpp                             ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb1_crc16.v                               ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

#include "systemc.h"
#include "usb_crc16.h"

void usb_crc16::update(void) {
	sc_uint<16> temp;

	temp[0] = din.read()[7] ^ din.read()[6] ^ din.read()[5] ^ din.read()[4] ^ din.read()[3] ^ din.read()[2] ^
			din.read()[1] ^ din.read()[0] ^ crc_in.read()[8] ^ crc_in.read()[9] ^ crc_in.read()[10] ^
			crc_in.read()[11] ^ crc_in.read()[12] ^ crc_in.read()[13] ^ crc_in.read()[14] ^
			crc_in.read()[15];
	temp[1] = din.read()[7] ^ din.read()[6] ^ din.read()[5] ^ din.read()[4] ^ din.read()[3] ^ din.read()[2] ^
			din.read()[1] ^ crc_in.read()[9] ^ crc_in.read()[10] ^ crc_in.read()[11] ^ crc_in.read()[12] ^
			crc_in.read()[13] ^ crc_in.read()[14] ^ crc_in.read()[15];
	temp[2] = din.read()[1] ^ din.read()[0] ^ crc_in.read()[8] ^ crc_in.read()[9];
	temp[3] = din.read()[2] ^ din.read()[1] ^ crc_in.read()[9] ^ crc_in.read()[10];
	temp[4] = din.read()[3] ^ din.read()[2] ^ crc_in.read()[10] ^ crc_in.read()[11];
	temp[5] = din.read()[4] ^ din.read()[3] ^ crc_in.read()[11] ^ crc_in.read()[12];
	temp[6] = din.read()[5] ^ din.read()[4] ^ crc_in.read()[12] ^ crc_in.read()[13];
	temp[7] = din.read()[6] ^ din.read()[5] ^ crc_in.read()[13] ^ crc_in.read()[14];
	temp[8] = din.read()[7] ^ din.read()[6] ^ crc_in.read()[0] ^ crc_in.read()[14] ^ crc_in.read()[15];
	temp[9] = din.read()[7] ^ crc_in.read()[1] ^ crc_in.read()[15];
	temp[10] = crc_in.read()[2];
	temp[11] = crc_in.read()[3];
	temp[12] = crc_in.read()[4];
	temp[13] = crc_in.read()[5];
	temp[14] = crc_in.read()[6];
	temp[15] = din.read()[7] ^ din.read()[6] ^ din.read()[5] ^ din.read()[4] ^ din.read()[3] ^
			din.read()[2] ^ din.read()[1] ^ din.read()[0] ^ crc_in.read()[7] ^ crc_in.read()[8] ^
			crc_in.read()[9] ^ crc_in.read()[10] ^ crc_in.read()[11] ^ crc_in.read()[12] ^
			crc_in.read()[13] ^ crc_in.read()[14] ^ crc_in.read()[15];

	crc_out.write(temp);
}

