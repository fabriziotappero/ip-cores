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
* This is an example decoder (decompressor) for which can be used to decompress data encoded by the core.
*                                                                                                                    
***************************************************************************************************************/   

package org.sump.analyzer;
import java.io.IOException;

class LZRW1Decoder
{
	final static boolean DEBUG = false;		// set this to true for detailed debug output to the console
	
	final static int HISTORY_LEN = 4096;	// buffer length in bytes 
	final static int LOOK_AHEAD_LEN = 16;	// look ahead buffer length in bytes
	final static int HASH_BIT_LEN = 11;     // number of bits for the index in the hash table
	
	/* configer the number of items (offset-length-tuples or literals) per frame */
	public final int ITEMS_PER_FRAME = 8;
	
	public LZRW1Decoder ()
	{
		// allocate the history buffer
		buffer = new int[HISTORY_LEN];
		validBufferLen = 0;
		histWrInd = 0;
		flags = 0;
		frameItemCnt = 0;
		offset = -1;
		copyCnt = 0;
		readIndex = 0;
		endOfData = false;
		if (DEBUG)
			System.out.println("LZRW1Decoder constructed");
	}
	
	/**
	* Loads a block of compressed data into the module. Decoding will start at a given offset.
	* @param cd		The data to be decompressed
	* @param o		Index of the first byte of encoded data in cd
	*/
	void loadCompressedData (byte [] cd, int o)
	{
		compressed = cd;
		// reset all internal states for a new stream
		validBufferLen = 0;
		histWrInd = 0;
		flags = 0;
		frameItemCnt = 0;
		offset = -1;
		copyCnt = 0;
		readIndex = o;
		endOfData = false;
		if (DEBUG)
			System.out.println("compressed data loaded");
	}
	
	/**
	* Decompresses one byte of data stored in source block and returns it. If no source data is available an
	* exception will be created. If the end-of-data symbol is encountered -1 will be returned. If the compressed
	* data ends without an end-of-data symbol an exception will be created as well. Any data after an end-of-data
	* symbol will be ignored and can not be decoded. However the method may still be called, it will keep returning
	* -1 to indicated the end of the decoded data.
	* @return	The next byte in the stream of decoded data. -1 if end-of-data was reached
	* @throws IOException if an error is found in the encoded data
	*/
	int decodeNextByte () throws IOException
	{
		int ch = 0;		// decoded char (to be returned)
						
		// make sure that we have data
		if (compressed == null)
			throw new IOException("no compressed data loaded");
		
		if (endOfData)
			return -1;
		
		// check wether we can copy data from the stream history (due to a offset/length pair found earlier)
		if (copyCnt > 0)
		{	
			ch = readFromHistory();
			copyCnt--;
			// the byte is decoded, it becomes part of the stream history
			insertIntoHistBuf(ch);
			return ch;
		}
		
		// get next byte from compressed data stream
		if (readIndex >= compressed.length)
			throw new IOException("encountered end of compressed data without end-of-data symbol (data corrupt)");
		ch = compressed[readIndex++];	
		
		// load a new header if necessary
		if (frameItemCnt==0)
		{
			flags = ch&0xff;
			if (DEBUG)
				System.out.printf("   found header: %02x\n",flags);
			frameItemCnt = 8;
			// load the next byte
			if (readIndex >= compressed.length)
				throw new IOException("encountered end of compressed data without end-of-data symbol (data corrupt)");
			ch = compressed[readIndex++];	
		}
		
		// check whether we have a pair or not
		if ((flags&0x01) == 1)
		{
			// this is a length-offset pair, load the second byte
			if (readIndex >= compressed.length)
				throw new IOException("encountered end of compressed data without end-of-data symbol (data corrupt)");
			int lowByte = compressed[readIndex++];	
			int highByte = ch;
			// decode the pair into offset and length
			copyCnt = (highByte>>4) & 0x0f;
			offset = ((highByte<<8)&0x0f00) + (lowByte&0xff);
			// check for the end-of-data symbol
			if ((offset==0) && (copyCnt==0))
			{
				if (DEBUG)
					System.out.println("   found end of data symbol");
				endOfData = true;
				// check that there is no data left in the encoded input
				/*if (readIndex < compressed.length)
					throw new IOException("compressed data after end-of-data symbol (data corrupt) "+readIndex+"  "+compressed.length);*/
				return -1;
			}	
			copyCnt++;	// Note: the encoder saves the number of byte to be copied minus 1 to save some space (2 means copy 3 bytes, and so on)
			if (DEBUG)
				System.out.println("len:"+copyCnt+" off:"+offset);
			// load the first copy byte from the history buffer
			ch = readFromHistory();
			copyCnt--;	// one byte copied
			// this byte is decoded, it becomes part of the stream history
			insertIntoHistBuf(ch);
		}
		else
		{
			// convert the signed char (-128..127) to an unsigned value
			//if (ch < 0)
			//	ch += 256;
			ch &= 0xff;
		
			// this is a literal
			if (DEBUG)
				System.out.printf("lit: '%c'=%02x\n",ch,ch);
			// save this byte in the history buffer
			insertIntoHistBuf(ch);
		}

		// shift header for next byte
		frameItemCnt--;
		flags >>= 1;
		return ch;
	}
	
	/**
	* read one byte from the history buffer from the position defined by offset.
	*/
	private int readFromHistory() throws IOException
	{
		if (offset >= validBufferLen)
			throw new IOException("offset is pointing to a location before the beginning of the data (data corrupt)");
		// calculate index (move back offset bytes) from last one (-1 because histWrInd point to next free location)	
		int ind = histWrInd-offset-1;	
		if (ind < 0)	// wrap around (ring buffer)
			ind += HISTORY_LEN;
		if (ind < 0)
			// index is still negative, this is an error in the encoded data
			throw new IOException("Offset wraps more than once in history buffer (data corrupt)");
		// load the byte from the histroy buffer	
		return buffer[ind];
	}
	
	private void insertIntoHistBuf (int ch)
	{
		buffer[histWrInd++] = ch;
		if (histWrInd >= buffer.length)
			histWrInd = 0;
		// count the number of valid bytes in the histroy buffer
		if (validBufferLen < HISTORY_LEN)
			validBufferLen++;
	}

	int [] buffer;
	int validBufferLen;
	int histWrInd;
	int flags;
	int frameItemCnt;	
	int offset;
	int copyCnt;
	byte [] compressed;	// holds the compressed data
	int readIndex;
	boolean endOfData;	
}


