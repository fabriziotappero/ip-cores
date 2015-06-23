/**************************************************************************************************************
*
*    L Z R W 1   E N C O D E R   C O R E
*
*  A high throughput loss less data compression core.
* 
* Copyright 2012-2013   Lukas Schrittwieser (LS)
*
*    This program is free software: you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation, either version 2 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program; if not, write to the Free Software
*    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*    Or see <http://www.gnu.org/licenses/>
*
***************************************************************************************************************
*
* Change Log:
*
* Version 1.0 - 2013/04/05 - LS
*   released
*
***************************************************************************************************************
*
* This program implements the same algorithm as the core written in VHDL. Moreover it can decode (decompress)
* data compressed by the core (using its testbench for example).
*                                                                                                                    
***************************************************************************************************************/      

import java.io.BufferedOutputStream;
import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.FileReader;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.File;
import java.io.IOException;

class LZ77
{
	final static boolean DEBUG = false;		// set this to true to get verbose output about the algorithm
	// configure core properties
	final static int HISTORY_LEN = 4096;	// buffer length in bytes 
	final static int LOOK_AHEAD_LEN = 16;
	final static int HASH_BIT_LEN = 11;     // number of bits for the index in the hash table
	
	/* configer the number of items (offset-length-tuples or literals) per frame */
	public final int ITEMS_PER_FRAME = 8;
	
	public static void main (String args[])
	{
		LZ77 compressor = new LZ77();
		File dest = null;
		
		if (args.length < 2)
		{
			System.err.println("Usage: LZ77 (encode|decode) in-file [out-file]");
			System.err.println("Usage: LZ77 verify compressed-file clear-text-verify-file");
			return;
		}
		
		if (args.length >= 3)
			dest = new File(args[2]);
		
		try
		{
			if (args[0].compareTo("encode") == 0)
				compressor.encode(new File(args[1]), dest);
			else if (args[0].compareTo("decode") == 0)
				compressor.decode(new File(args[1]), dest, null);
			else if (args[0].compareTo("verify") == 0)
				compressor.decode(new File(args[1]), null, dest);
			else
			{
				System.err.println("Usage: LZ77 (encode|decode) in-file [out-file]");
				System.err.println("Usage: LZ77 verify compressed-file clear-text-verify-file");
			}
		}
		catch(Exception e)
		{
			System.err.println("compression created exception: "+e);	
			e.printStackTrace();
		}
	}
	
	public LZ77 ()
	{
		// allocate a buffer and fill it with \0
		buffer = new int[HISTORY_LEN];
		for (int i=0; i<buffer.length; i++)
			buffer[i] = ' ';
		
		lookAheadBuf = new int[LOOK_AHEAD_LEN];
		lookAheadLen = 0;
		hashTbl = new int[(int)Math.ceil(Math.pow(2,HASH_BIT_LEN))];	// does not have to be initialized
		
		histWrInd = 0;
		
		frameBuffer = new int[ITEMS_PER_FRAME*2];
		frameBufferIndex = 0;
		
	}
	
	// compress a file
	void encode (File source, File destination) throws IOException
	{
		BufferedReader br = new BufferedReader(new FileReader(source));
		BufferedOutputStream bw = null;
		if (destination != null)
			bw = new BufferedOutputStream(new FileOutputStream(destination));
		
		int [] cand = new int[lookAheadBuf.length];
		//FileReader br = new FileReader(f);
		int ch = 0;
		int h;
		int byteCnt = 0;	// for debug purposes (better error messages)
		supressCnt = 0;
		histWrInd = 0;
		frameItemCnt = 0;
		frameBufferIndex = 0;
		validBufferLen = 0;
		
		// fill the lookahead buffer with data
		do
		{
			ch = br.read();
			if (ch != -1)
			{
				//buffer[histWrInd++] = ch;
				lookAheadBuf[lookAheadLen] = ch;
				lookAheadLen++;
				insertIntoHistBuf(ch);	// Note: the front the of the history buffer holds a copy of the lookahead buffer
			}
		} while ((ch != -1) && (lookAheadLen < lookAheadBuf.length-1));
		
		while ((ch != -1) || (lookAheadLen > 0))
		{			
			
			ch = br.read();
			if (ch != -1)
			{
				// enter this char into the stream history buffer
				insertIntoHistBuf(ch);
				// store it in look ahead shift register
				lookAheadBuf[lookAheadLen] = ch;
				lookAheadLen++;
			}
			if (DEBUG)
				System.out.println("lookAheadLen: "+lookAheadLen);
			            		
			byteCnt++;
			if (DEBUG)
				System.out.println("processing byte number "+byteCnt);
			dbgPrint();
			
			// get the hash for the current look ahead buffer
			h = hash(lookAheadBuf[0], lookAheadBuf[1], lookAheadBuf[2]);
			// get match candidate index from table
			int cInd = hashTbl[h];
			// save new pointer in hash table
			int x = histWrInd - lookAheadLen;	//
			if (x < 0)
				x += buffer.length;
			hashTbl[h] = x;
			//System.out.println("h: "+h+"  cInd: "+cInd+"   histWrInd: "+histWrInd);
			// load the candidate from the stream history buffer
			for (int i=0; i<lookAheadLen; i++)
			{
				int ind = cInd + i;
				if (ind >= buffer.length)
					ind -= buffer.length;
				cand[i] = buffer[ind];
			}
			if (DEBUG)
			{
				System.out.print("candidate: <");
				for (int i=0; i<lookAheadLen; i++)
				{
					if (cand[i] != '\n')
						System.out.print(((char)cand[i]));
					else
						System.out.print("\\n");
				}
				System.out.println(">  len:"+lookAheadLen);
			}
			
			int mLen = checkCandidate(cand);
			
			// the hardware has a limitation on the candidate length depending on the candidate address, we model this here
			int maxLen=0;
			if (lookAheadLen == 16)
				maxLen = lookAheadLen - (cInd&0x03);
			else
				maxLen = lookAheadLen;
			
			if (mLen > maxLen)
				mLen = maxLen;
			if (DEBUG)
				System.out.println("mLen: "+mLen+"     maxLen: "+maxLen);
			
			int lit = lookAheadBuf[0];
			shiftLookAhead(1);
			lookAheadLen--;
						
			if (supressCnt > 0)
			{
				// this byte has already been encoded. Discard it
				supressCnt--;
				if (DEBUG)
					System.out.println("data output supressed");
				continue;
			}				
			
			if (mLen < 3)
			{
				// we have no mtach, simply output a literal
				output(bw, 0,1,lit);
				continue;
			}
			
			// we have a match, calculate the offset
			if (DEBUG)
			{
				System.out.println("wrInd: "+histWrInd+"    lookAheadLen: "+lookAheadLen+ "   cInd: "+cInd);	
			}
			int offset = histWrInd - (lookAheadLen+1) - cInd - 1;
			if (offset < 0)
				offset += buffer.length ;
			// check offset
			if (offset >= (validBufferLen))
			{
				System.out.println("offset "+offset+" is too old");
				// this match is too old and therefore not valid (we have already overwritten this data with the lookAhead data)
				output(bw, 0,1,lit);
				continue;
			}
					
			if (offset < 0)
			{
				System.out.println("offset "+offset+" is negative!");
				output(bw, 0,1,lit);
				continue;
			}
			output(bw, offset, mLen-1, 0); // take length -1 to save one bit (we can't have length 0 but 16 becomes 15)
			supressCnt = mLen-1;	// supress output for the next mLen-1 bytes (as we already encoded them)
		}
		br.close();	
		
		// create 'end of data' flag
		output(bw, 0, 0, 0);
		
		if (bw != null)
			bw.close();
	}
	
	
	void decode (File source, File destination, File verify) throws IOException
	{
		BufferedInputStream bi = new BufferedInputStream(new FileInputStream(source));
		BufferedInputStream verifyStream = null;
		BufferedOutputStream bo = null;
		if (destination != null)
			bo = new BufferedOutputStream(new FileOutputStream(destination));
		if (verify != null)
			verifyStream = new BufferedInputStream(new FileInputStream(verify));
		
		int ch = 0;
		int flags = 0;
		int highByte = 0;
		boolean isPair = false;
		histWrInd = 0;
		frameItemCnt = 0;
		boolean verifyFailed = false;
		
		// we keep a statistic of the match length values we encounter during decoding
		int [] mLenCnt = new int[16];
		for (int i=0; i<mLenCnt.length; i++)
			mLenCnt[0] = 0;
				
		while (ch != -1)
		{			
			ch = bi.read();
			
			if (ch == -1)
			{
				System.err.println("corrupt file: EOF without an end of data marker");
				break;
			}
			
			if (isPair)
			{
				// this is the second byte of a length-distance pair, processes it
				isPair = false;
				int len = (highByte>>4) & 0x0f;
				int offset = ((highByte<<8)&0x0f00) + (ch&0xff);
				// increment the counter for this match length
				mLenCnt[len]++;
				
				// check for the end of data signal
				if ((len==0) && (offset==0))
				{
					if (DEBUG)
						System.out.println("found end of data");
					while((ch=bi.read()) != -1)
					{
						System.err.printf("found extra byte: '%c'=%02x\n",ch,ch);
						verifyFailed = true;
					}
					break;
				}
				if (DEBUG)
					System.out.print("copy o="+offset+" l="+len+": ");
				for (int i=0; i<=len; i++)
				{
					// load the byte from the history buffer
					int ind = histWrInd-offset-1;
					if (ind < 0)
						ind += HISTORY_LEN;
					if (ind < 0)
					{
						// index is still zero, this is error in the encoded data
						System.err.println("Error in encoded data, offset is too long");
						verifyFailed = true;
						return;
					}
					ch = buffer[ind];
					
					if (DEBUG)
						System.out.printf(" '%c'=%x",ch,ch);
					if (bo != null)
						bo.write(ch);
					// save this byte in the history buffer
					buffer[histWrInd++] = ch;
					if (histWrInd >= buffer.length)
						histWrInd = 0;
					
					// check with verify file
					if (verifyStream != null)
					{
						int vCh = verifyStream.read();
						if (vCh < 0)
						{
							System.err.printf("verify failed: decoded '%c'=%02x,  verify file is empty\n", ch, ch);
							verifyFailed = true;
						}
						else if (vCh != ch)
						{
							System.err.printf("verify failed: decoded '%c'=%02x,  expected '%c'=%02x\n", ch, ch, vCh, vCh);
							verifyFailed = true;
						}
					}
				}
				if (DEBUG)
					System.out.println(" ");
				
				continue;
			}
			
			// check whether we have a new header
			if (frameItemCnt==0)
			{
				flags = ch;
				if (DEBUG)
					System.out.printf("found header: %02x\n",ch);
				frameItemCnt = 8;
				continue;
			}
			
			if ((flags&0x01) == 1)
			{
				// this is a length-offset pair, save first byte for later processing
				highByte = ch;
				isPair = true;
			}
			else
			{
				isPair = false;
				// this is a literal
				if (DEBUG)
					System.out.printf("lit: '%c'=%02x\n",ch,ch);
				if (bo != null)
					bo.write(ch);
				// count this as a literal in the frequency counter for the statistics
				mLenCnt[0]++;
				// save this byte in the history buffer
				buffer[histWrInd++] = ch;
				if (histWrInd >= buffer.length)
					histWrInd = 0;
				// check with verify file
				if (verifyStream != null)
				{
					int vCh = verifyStream.read();
					if (vCh < 0)
					{
						System.err.printf("verify failed: decoded '%c'=%02x,  verify file is empty\n", ch, ch);
						verifyFailed = true;
					}
					else if (vCh != ch)
					{
						System.err.printf("verify failed: decoded '%c'=%02x,  expected '%c'=%02x\n", ch, ch, vCh, vCh);
						verifyFailed = true;
					}
				}
			}
			// shift header for next byte
			frameItemCnt--;
			flags >>= 1;
		}
			
		bi.close();	
				
		if (bo != null)
			bo.close();
		
		// print some statistics
		System.out.println("Percentages of different match lengths:");
		int total = 0;
		for (int i=0; i<mLenCnt.length; i++)
			total += mLenCnt[i];
		for (int i=0; i<mLenCnt.length; i++)
			System.out.println("match len "+(i+1)+": \t"+(mLenCnt[i]/(float)total));  

		if (verifyStream != null)
		{
			while((ch=verifyStream.read()) != -1)
			{
				verifyFailed = true;
				System.err.printf("found extra byte in verify file: '%c'=%02x\n",ch,ch);
			}
			verifyStream.close();
			if (verifyFailed)
				System.err.println("verify failed");
			else
				System.err.println("verify passed");
		}
		
		
	}
	
	private void insertIntoHistBuf (int ch)
	{
		buffer[histWrInd++] = ch;
		if (histWrInd >= buffer.length)
			histWrInd = 0;
		// count the number of valid bytes in the histroy buffer
		if (validBufferLen < (HISTORY_LEN - LOOK_AHEAD_LEN))
			validBufferLen++;
	}
	
	/* checks a candidate to look ahead buffer 
	   returns the length of the match in bytes (0 means no match)*/
	private int checkCandidate(int [] cand)
	{
		int i;
		for (i=0; i<lookAheadLen; i++)
		{
			if (cand[i] != lookAheadBuf[i])
				return i;
		}
		return lookAheadLen;	// all chars matched
	}
		
	// look ahead is implemented as shift to left register
	private void shiftLookAhead(int cnt)
	{
		for (int i=0; i<(LOOK_AHEAD_LEN-cnt); i++)
			lookAheadBuf[i] = lookAheadBuf[i+cnt];	
	}
	
	private int hash(int k0, int k1, int k2)
	{
		int mask = 0;
		for (int i=0; i<HASH_BIT_LEN; i++)
		{	
			mask <<= 1;
			mask |= 1;
		}
		//System.out.println("mask: "+mask);
		// original hash function as used by LZRW
		return ( (40543*((((k0<<4)^k1)<<4)^k2)) >>4 ) & mask;
	}
	
	private void dbgPrint()
	{
		if (DEBUG)
		{
			int ind = histWrInd;
			System.out.print('|');
			for (int i=0; i<buffer.length; i++)
			{
				char c = (char)buffer[ind++];
				if (c == '\n')
					System.out.print("\\n");
				else
					System.out.print(c);
			//	System.out.print(" ");
				if (ind >= buffer.length)
					ind = 0;
			}
			System.out.print("|   |");
			for (int i=0; i<lookAheadLen; i++)
			{
				char c = (char)lookAheadBuf[i];
				if (c == '\n')
					System.out.print("\\n");
				else
					System.out.print(c);
			//	System.out.print(" ");
			}
			System.out.println("|");
		}
	}
	
	private void output (BufferedOutputStream bw, int offset, int len, int ch) throws IOException
	{
		if (DEBUG)
		{
			if (len<=1)
			{
				System.out.print("lit: '");
				if (ch == '\n')
					System.out.print("\\n");
				else
					System.out.print((char)ch);
				System.out.println("'");
				
			}
			else
				System.out.println("off: "+offset+"\t  len:"+len);
			if (len == 0)
				System.out.println("creating EOD");
		}
		
		if (bw != null)
		{
			assert(len < 16);
			assert(len >= 0);
			assert(ch >= 0);
			assert(ch <= 255);
			
			if (len == 1)
			{
				// output a string literal
				header &= (~(1<<frameItemCnt));         // clear flag bit in header to indicate a literal
				frameBuffer[frameBufferIndex++] = ch; // copy literal to buffer
			}
			
			if (len >= 2)
			{
				header |= (1<<frameItemCnt);         // set flag bit in header to indicate a pair
				int code = (len<<12) | offset;
				// we use big endian encoding
				frameBuffer[frameBufferIndex++] = (code>>8) & 0xff;
				frameBuffer[frameBufferIndex++] = (code & 0xff);
			}
			
			if (len == 0)
			{
				// create an end of data code (pair with length of zero)
				header |= (1<<frameItemCnt);         // set flag bit in header to indicate a pair
				frameBuffer[frameBufferIndex++] = 0;
				frameBuffer[frameBufferIndex++] = 0;
			}
			
			frameItemCnt++;
			//if (DEBUG)
			//	System.out.println("frame item cnt: "+frameItemCnt);
			
			// send the buffer if the frame is full or if we have to send an end of data signal
			if ((frameItemCnt==8) || (len==0))
			{
				header &= 0xff;
				bw.write(header);
				for (int i=0; i<frameBufferIndex; i++)
					bw.write(frameBuffer[i] & 0xff);
				frameBufferIndex = 0;
				frameItemCnt = 0;
				/*header = 0;
				bw.flush();
				BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
				in.readLine();*/
			}
		}
	}
	
	int [] buffer;
	int validBufferLen;
	int [] hashTbl;
	int [] lookAheadBuf;
	int lookAheadLen;
	int histWrInd;
	int supressCnt;
	int header;
	int frameItemCnt;
	int [] frameBuffer;
	int frameBufferIndex;
	
		
}


