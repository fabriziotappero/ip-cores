/*	
 * Copyright 2001-2010 Georges Menie (www.menie.org)
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the University of California, Berkeley nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* this code needs standard functions memcpy() and memset()
   and input/output functions _inbyte() and _outbyte().

   the prototypes of the input/output functions are:
     int _inbyte(unsigned short timeout); // msec timeout
     void _outbyte(int c);

 */

#include "crc16.h"
#include "boot-loader.h"

/*
#define DEBUG_XMODEM
*/

#define SOH  0x01
#define STX  0x02
#define EOT  0x04
#define ACK  0x06
#define NAK  0x15
#define CAN  0x18
#define CTRLZ 0x1A


#define MAXRETRANS 25

#ifdef DEBUG_XMODEM        
char* dbuf;
#endif


static int check(int crc, const unsigned char *buf, int sz)
{
	if (crc) {
		unsigned short crc = crc16_ccitt(buf, sz);
		unsigned short tcrc = (buf[sz]<<8)+buf[sz+1];
		if (crc == tcrc) {
                        #ifdef DEBUG_XMODEM        
                        dbuf += sprintf(dbuf, "cok1\n");
                        #endif
			return 1;
                        }
	}
	else {
		int i;
		unsigned char cks = 0;
		for (i = 0; i < sz; ++i) {
			cks += buf[i];
		}
		if (cks == buf[sz]) {
                    #ifdef DEBUG_XMODEM        
                    dbuf += sprintf(dbuf, "cok2\n");
                    #endif
		    return 1;
                    }
	}

        #ifdef DEBUG_XMODEM        
        dbuf += sprintf(dbuf, "cer\n");
        #endif
	return 0;
}


static void flushinput(void)
{
	while (_inbyte(DLY_300MS) >= 0) ;
}


int xmodemReceive(unsigned char *dest, int destsz)
{
	unsigned char xbuff[1030]; /* 1024 for XModem 1k + 3 head chars + 2 crc + nul */
	unsigned char *p;
	int bufsz, crc = 0;
	unsigned char trychar = 'C';
	unsigned char packetno = 1;
	int i, c, len = 0;
	int retry, retrans = MAXRETRANS;
        unsigned int wait;

        #ifdef DEBUG_XMODEM        
        dbuf = (char *) DEBUG_BUF;
        dbuf += sprintf(dbuf, "XR\n");
        #endif
        
	for(;;) {
		for( retry = 0; retry < 80; ++retry) {
			if (trychar) _outbyte(trychar);
			if ((c = _inbyte(DLY_1S)) >= 0) {		
				switch (c) {
				case SOH:
					bufsz = 128;
                                        #ifdef DEBUG_XMODEM
                                        dbuf += sprintf(dbuf, "128\n");
                                        #endif
					goto start_recv;
				case STX:
					bufsz = 1024;
                                        #ifdef DEBUG_XMODEM
                                        dbuf += sprintf(dbuf, "1k\n");
                                        #endif
					goto start_recv;
				case EOT:
					_outbyte(ACK);
					flushinput();
                                        #ifdef DEBUG_XMODEM
                                        dbuf += sprintf(dbuf, "EOT\n");
                                        #endif
					return len; /* normal end */
				case CAN:
                                        #ifdef DEBUG_XMODEM
                                        dbuf += sprintf(dbuf, "CAN\n");
                                        #endif
					if ((c = _inbyte(DLY_1S)) == CAN) {
						flushinput();
						_outbyte(ACK);
						return -1; /* canceled by remote */
					}
					break;
				default:
					break;
				}
			}
		}
		if (trychar == 'C') { trychar = NAK; continue; }
		flushinput();
		_outbyte(CAN);
		_outbyte(CAN);
		_outbyte(CAN);
		return -2; /* sync error */

	start_recv:
                #ifdef DEBUG_XMODEM
                dbuf += sprintf(dbuf, "sr\n");
                #endif
		if (trychar == 'C') crc = 1;
		trychar = 0;
		p = xbuff;
		*p++ = c;
		for (i = 0;  i < (bufsz+(crc?1:0)+3); ++i) {
			if ((c = _inbyte(DLY_1S)) < 0) goto reject;
			*p++ = c;
		}
                
                
		if (xbuff[1] == (unsigned char)(~xbuff[2]) && 
			(xbuff[1] == packetno || xbuff[1] == (unsigned char)packetno-1) &&
			check(crc, &xbuff[3], bufsz)) {
			if (xbuff[1] == packetno)	{
				register int count = destsz - len;
				if (count > bufsz) count = bufsz;
				if (count > 0) {
					memcpy (&dest[len], &xbuff[3], count);
					len += count;
				}
				++packetno;
				retrans = MAXRETRANS+1;
			}
			if (--retrans <= 0) {
				flushinput();
				_outbyte(CAN);
				_outbyte(CAN);
				_outbyte(CAN);
                                #ifdef DEBUG_XMODEM
                                dbuf += sprintf(dbuf, "mx e\n");                
                                #endif
				return -3; /* too many retry error */
			}
			_outbyte(ACK);
			continue;
                        

		}
                else {
                        #ifdef DEBUG_XMODEM
                        dbuf += sprintf(dbuf, "bad\n");                
                        #endif
                        }
                        
	reject:
                #ifdef DEBUG_XMODEM
                dbuf += sprintf(dbuf, "rj %d\n", c);
                #endif
                
		flushinput();
		_outbyte(NAK);
	}
}


