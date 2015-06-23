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
using PcapDotNet.Packets.Ethernet;

namespace EtherLab
{
    /// <summary>
    /// Represents the EtherLab layer for Pcap.NET.
    /// </summary>
    public sealed class EtherLabLayer : SimpleLayer, IEthernetNextLayer
    {
        /// <summary>
        /// The version number of the EtherLab protocol.
        /// </summary>
        public byte Version { set; get; }

        /// <summary>
        /// The channel number octet. Specifies the virtual channel this 
        /// package belongs to.
        /// </summary>
        public byte Channel { set; get; }

        /// <summary>
        /// The channel data. 8 channels, 16 bit wide each. Data segment is 40
        /// byte wide as we need at least 42 byte of payload for an Ethernet
        /// package (remaining 2 bytes are EtherLab header).
        /// </summary>
        public byte[] Data { get; set; }

        /// <summary>
        /// The default MAC Address value when this layer is the Ethernet payload.
        /// null means there is no default value.
        /// </summary>
        public MacAddress? PreviousLayerDefaultDestination
        {
            get { return EthernetDatagram.BroadcastAddress; }
        }

        /// <summary>
        /// The Ethernet Type the Ethernet layer should write when this layer is the Ethernet payload.
        /// </summary>
        public EthernetType PreviousLayerEtherType
        {
            get { return EthernetType.None; }
        }

        /// <summary>
        /// The number of bytes this layer will take.
        /// </summary>
        public override int Length
        {
            get { return EtherLabDatagram.HeaderLength + 16; }
        }

        /// <summary>
        /// Two EtherLabLayers are always equal. I could not find reasonable
        /// comparison parameters.
        /// </summary>
        /// <param name="other">An EtherLabLayer instance.</param>
        /// <returns>True if the other instance is not null and an instance of EtherLabLayer.</returns>
        public override bool Equals(Layer other)
        {
            return other != null && other.GetType() == GetType();
        }

        /// <summary>
        /// Constructor for a default EtherLab package.
        /// Version 1.
        /// </summary>
        public EtherLabLayer()
        {
            Version = 1;
            Channel = 0;
            Data = new byte[16];
        }

        /// <summary>
        /// Writes the layer to the buffer.
        /// This method ignores the payload length, and the previous and next layers.
        /// </summary>
        /// <param name="buffer">The buffer to write the layer to.</param>
        /// <param name="offset">The offset in the buffer to start writing the layer at.</param>
        protected sealed override void Write(byte[] buffer, int offset)
        {
            EtherLabDatagram.Write(buffer, offset, Version, Channel, Data);
        }

        /// <summary>
        /// Checks, whether there is new data, that has not yet been sent.
        /// </summary>
        /// <returns>True, if at least one channel holds new data.</returns>
        public bool pendingSendData()
        {
            return Channel != 0;
        }

        /// <summary>
        /// Update channel data and set channel flag. Upon next send, updated 
        /// data will be transmitted.
        /// </summary>
        /// <param name="channel">The channel to be updated.</param>
        /// <param name="channelData">The new data.</param>
        public void update(EChannel channel, ushort channelData)
        {
            int pos = (int)channel;
            Channel |= (byte)(1 << pos);
            Data.Write(2 * pos, channelData, Endianity.Big);
        }

        /// <summary>
        /// Read data for a channel from current received packet. If no packet
        /// is available yet, this function returns 0.
        /// </summary>
        /// <param name="channel">The channel to be read from.</param>
        /// <returns>The current channel data.</returns>
        public ushort read(EChannel channel)
        {
            int pos = (int)channel;
            return Data.ReadUShort(2 * pos, Endianity.Big);
        }

        /// <summary>
        /// Reset channel flags to zero. Clear the flags after a package has
        /// been sent. Only set channel flags trigger an update on hardware
        /// level.
        /// </summary>
        public void reset()
        {
            Channel = 0;
        }
    }
}