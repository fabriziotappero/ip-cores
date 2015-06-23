/******************************************************************************
 * ETHERLAB - FPGA To C# To LABVIEW Bridge                                    *
 ******************************************************************************
 *                                                                            *
 * Copyright (C)2012  Mathias Hörtnagl <mathias.hoertnagl@gmail.com>          *
 *                                                                            *
 * This program is free software: you can redistribute it and/or modify       *
 * it under the terms of the GNU General Public License as published by       *
 * the Free Software Foundation, either version 3 of the License, or          *
 * (at your option) any later version.                                        *
 *                                                                            *
 * This program is distributed in the hope that it will be useful,            *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 * GNU General Public License for more details.                               *
 *                                                                            *
 * You should have received a copy of the GNU General Public License          *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.      *
 ******************************************************************************/
using PcapDotNet.Packets;

namespace EtherLab
{
    /// <summary>
    /// Represents an EtherLab datagram.
    /// 
    /// An EtherLab Datagram sends data for all active channels in one
    /// packet whenever send() is called.
    /// A packet, whether sent or received, contains at most 8 independent
    /// data chunks of 16 bit size each.
    /// 
    /// <pre>
    /// +-----+----------------+----------------+ 
    /// | Bit | 0-7            | 8-15           |
    /// +-----+----------------+----------------+
    /// | 0   | Version        | Channels       |
    /// +-----+----------------+----------------+
    /// | 16  | Channel A Data                  |
    /// +-----+---------------------------------+
    /// | 32  | Channel B Data                  |    
    /// +-----+---------------------------------+  
    /// :     :                                 :
    /// +-----+---------------------------------+
    /// | 112 | Channel H Data                  |
    /// +-----+---------------------------------+
    /// </pre>
    /// 
    /// <para>
    /// Channel Field
    /// 
    /// The Channels field is 1 byte wide and can thus hold 8 seperate 
    /// channels. An active channel is repesented by its flag set to 1.
    /// <pre>
    /// +-----+-------------------------------+
    /// | Bit | 8-15                          |
    /// +-----+---+---+---+---+---+---+---+---+
    /// | 8   | H | G | F | E | D | C | B | A |
    /// +-----+---+---+---+---+---+---+---+---+
    /// </pre>
    /// Each channel is labeled with an alphabetic letter (A to H).
    /// </para>
    /// </summary>
    public sealed class EtherLabDatagram : Datagram
    {
        private static class Offset
        {
            public const int Version = 0;
            public const int Channel = 1;
            public const int Data = 2;
        }

        /// <summary>
        /// The number of bytes the EtherLab header takes.
        /// </summary>
        public const int HeaderLength = 2;

        /// <summary>
        /// The version number of the EtherLab protocol.
        /// </summary>
        public byte Version
        {
            get { return this[Offset.Version]; }
        }

        /// <summary>
        /// The channel number octet. Specifies the virtual channel this 
        /// package belongs to.
        /// </summary>
        public byte Channel
        {
            get { return this[Offset.Channel]; }
        }

        /// <summary>
        /// The channel data. 8 channels, 16 bit wide each. Data segment is 40
        /// byte wide as we need at least 42 byte of payload for an Ethernet
        /// package (remaining 2 bytes are EtherLab header).
        /// </summary>
        public byte[] Data
        {
            get 
            { 
                return ReadBytes(Offset.Data, Length - HeaderLength);
            }
        }
        
        /// <summary>
        /// Constructor for a new EtherLab Datagram.
        /// </summary>
        /// <param name="buffer">The buffer to write the layer to.</param>
        /// <param name="offset">The offset in the buffer to start writing the layer at.</param>
        /// <param name="length">The datagram length.</param>
        internal EtherLabDatagram(byte[] buffer, int offset, int length)
            : base(buffer, offset, length)
        {
        }

        /// <summary>
        /// Creates a Layer that represents the datagram to be used with PacketBuilder.
        /// </summary>
        public override ILayer ExtractLayer()
        {
            return new EtherLabLayer
            {
                Version = Version,
                Channel = Channel,
                Data = Data
            };
        }

        /// <summary>
        /// Writes the Datagram to the buffer.
        /// </summary>
        /// <param name="buffer">The buffer to write the layer to.</param>
        /// <param name="offset">The offset in the buffer to start writing the layer at.</param>
        /// <param name="version">The EtherLab protocol version.</param>
        /// <param name="channel">The active channels.</param>
        /// <param name="data">The channels' data.</param>
        internal static void Write(byte[] buffer, int offset, byte version, byte channel, byte[] data)
        {
            buffer.Write(offset + Offset.Version, version);
            buffer.Write(offset + Offset.Channel, channel);

            for (int i = 0; i < 16; i++)
                buffer.Write(offset + Offset.Data + i, data[i]);
        }
    }
}