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
using System;
using System.Collections.Generic;
using System.Threading;

using PcapDotNet.Core;
using PcapDotNet.Packets;
using PcapDotNet.Packets.Ethernet;

namespace EtherLab
{
    /// <summary>
    /// A socket for EtherLab communication.
    /// 
    /// <para>
    /// Sending
    /// 
    /// To send data, first update any channel's data with <see cref="update()"/>.
    /// Subsequently call <see cref="send()"/> to send the updated EtherLab
    /// packet. If <see cref="update()"/> isn't invoked at least once, 
    /// <see cref="send()"/> will NOT send the packet, as there is no updated
    /// data available.
    /// <example>
    /// <code>
    ///     /** 
    ///      * Create a new instance of EtherSocket with default 
    ///      * destination MAC. The first parameter identifies the
    ///      * network device to select.
    ///      */
    ///     EtherSocket es = new EtherSocket(0, "00:1f:16:01:95:a5");
    ///     
    ///     // Update data for channel H and B.
    ///     es.update(EChannel.CHANNEL_H, 0x1234);
    ///     es.update(EChannel.CHANNEL_B, 0x4321);
    ///     
    ///     // Send the updated packet.
    ///     es.send();
    /// </code>
    /// </example>
    /// </para>
    /// 
    /// <para>
    /// Receiving
    /// 
    /// EtherSocket starts a new Thread automatically for the reception process.
    /// Data is read constatntly from the networ device. 
    /// To read a channel's current data chunk, invoke <see cref="read()"/>.
    /// 
    /// NOTE: There is no locking mechanism, to circumvent reading data while
    ///       new data is read from the network device.
    /// <example>
    /// <code>
    ///     /** 
    ///      * Create a new instance of EtherSocket with default 
    ///      * destination MAC. The first parameter identifies the
    ///      * network device to select.
    ///      */
    ///     EtherSocket es = new EtherSocket(0, "00:1f:16:01:95:a5");
    ///     
    ///     ushort data;
    ///     
    ///     // Read data of channel H;
    ///     data = es.read(EChannel.CHANNEL_H);
    /// </code>
    /// </example>
    /// </para>
    /// </summary>
    public sealed class EtherSocket
    {
        /// <summary>
        /// Packet receiver filter. Capture packages with EtherType = 0x0000
        /// and with a Version 2 field only.
        /// </summary>
        private const String RCV_FILTER 
            = "(ether[12:2] = 0x0000) and (ether[14] = 0x02)";

        private LivePacketDevice device;
        private PacketCommunicator com;
        private PacketBuilder builder;
        private EtherLabLayer sendLayer;
        private EtherLabLayer receiveLayer;
        private Thread receiverThread;

        /// <summary>
        /// Creates a new EtherSocket with "00:0a:35:00:00:00" as a default
        /// destination MAC.
        /// </summary>
        /// <param name="deviceId">The integer ID of the network device.</param>
        /// <param name="srcMAC">The source MAC address.</param>
        public EtherSocket(int deviceId, String srcMAC)
            : this(deviceId, srcMAC, "00:0a:35:00:00:00")
        {
        }

        /// <summary>
        /// Creates a new EtherSocket.
        /// </summary>
        /// <param name="deviceId">The integer ID of the network device.</param>
        /// <param name="srcMAC">The source MAC address.</param>
        /// <param name="dstMAC">The destination MAC address.</param>
        public EtherSocket(int deviceId, String srcMAC, String dstMAC)
        {
            IList<LivePacketDevice> allDevices = LivePacketDevice.AllLocalMachine;

            if ( (allDevices.Count == 0) || (allDevices.Count < deviceId) )
            {
                return;
            }

            device = allDevices[deviceId];
            com = device.Open(56, PacketDeviceOpenAttributes.Promiscuous, 1000);
            
            // Filter packages.
            using (BerkeleyPacketFilter filter = com.CreateFilter(RCV_FILTER)) 
            {
                com.SetFilter(filter);
            }

            EthernetLayer ethernetLayer = new EthernetLayer 
            {
                Source = new MacAddress(srcMAC),
                Destination = new MacAddress(dstMAC)
            };

            sendLayer = new EtherLabLayer();

            builder = new PacketBuilder(ethernetLayer, sendLayer);

            // Start receiver thread.
            receiverThread = new Thread(this.receive);
            receiverThread.Start();
        }

        /// <summary>
        /// Update channel data and set channel flag. Call send() to send
        /// the updated data in a new packet.
        /// </summary>
        /// <param name="channel">The channel to be updated.</param>
        /// <param name="channelData">The new data for that channel.</param>
        public void update(EChannel channel, ushort channelData)
        {
            sendLayer.update(channel, channelData);
        }

        /// <summary>
        /// Sends the current EtherLab packet and resets the channel
        /// flags to 0. A packet is sent only if at least one channel 
        /// flag is set.
        /// </summary>
        public void send()
        {
            if (sendLayer.pendingSendData())
            {
                com.SendPacket(builder.Build(DateTime.Now));
                sendLayer.reset();
            }
        }

        /// <summary>
        /// Receive a single packet. Packet data can be read with <see cref="read()"/>.
        /// </summary>
        private void receive()
        {
            com.ReceivePackets(0, PacketHandler);
        }

        /// <summary>
        /// Packet reception callback.
        /// </summary>
        /// <param name="packet">The received packet.</param>
        private void PacketHandler(Packet packet) 
        {
            EtherLabDatagram etherLabPacket 
                = new EtherLabDatagram(packet.Buffer, EthernetDatagram.HeaderLength, 18);

            receiveLayer = (EtherLabLayer) etherLabPacket.ExtractLayer();
        }

        /// <summary>
        /// Read data for a channel from current received packet. If no packet
        /// is available yet, this function returns 0.
        /// </summary>
        /// <param name="channel">The channel to be read from.</param>
        /// <returns>The current channel data.</returns>
        public ushort read(EChannel channel)
        {
            return (receiveLayer != null) ? receiveLayer.read(channel) : ushort.MinValue;
        }
    }
}