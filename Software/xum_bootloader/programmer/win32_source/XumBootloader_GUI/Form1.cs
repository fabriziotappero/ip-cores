/* Implements the XUM bootloader protocol.
 * 
 * Designed by Grant Ayers (ayers@cs.utah.edu) for
 * XUM project of the Gauss group at the University of Utah.
 * 
 * You may reuse this code with proper attribution.
 *
 * Summer 2010
*/
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Security.Permissions;
using System.IO.Ports;
using System.Diagnostics;


namespace XumBootloader_GUI
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
            
            /* Initialize some form components */
            foreach (string str in Program.getComPortNames())
            {
                try
                {
                    serialPortSelect.Items.Add(str);
                }
                catch (System.ArgumentNullException ex)
                {
                    MessageBox.Show(this, ex.Message + "\nYour system doesn't have any serial ports!");
                    Environment.Exit(0);
                }
            }
            try
            {
                serialPortSelect.SelectedIndex = 0;
                baudRateSelect.SelectedItem = "115200";
                serialPort1.Parity = System.IO.Ports.Parity.None;
                serialPort1.DataBits = 8;
                serialPort1.StopBits = System.IO.Ports.StopBits.One;
                serialPort1.Handshake = System.IO.Ports.Handshake.None;
                //serialPort1.WriteBufferSize = 1048576;  // 1MB
                //serialPort1.ReadBufferSize = 1048576;   // 1MB
                serialPort1.ReadTimeout = 1400; // 1400ms more than enough for 1KB even at 9600 baud.
                serialPort1.WriteTimeout = 1400;
                labelSuccess.Text = "";
                labelSize.Text = "";
                progressBar1.Visible = false;
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.Message);
                Environment.Exit(1);
            }

        }

        private void selectFile_Click(object sender, EventArgs e)
        {
            labelSuccess.Text = "";
            progressBar1.Visible = false;
            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                string filename = openFileDialog1.FileName;
                labelFilename.Text = "Selected: " + filename;
                try
                {
                    System.IO.FileInfo fi = new System.IO.FileInfo(filename);
                    long filesize = fi.Length;
                    if (filesize > 1048576) // currently just 1MB
                    {
                        MessageBox.Show(this, "Maxiumum supported file size is 1MB");
                        labelFilename.Text = "";
                        labelSize.Text = "";
                        openFileDialog1.FileName = "";
                        return;
                    }
                    labelSize.Text = "Size: " + filesize + " bytes.";
                    if ((filesize % 4) != 0)
                        labelSize.Text = labelSize.Text + " (Not aligned to 32 bits!)";
                }
                catch (Exception ex)
                {
                    MessageBox.Show(this, ex.Message);
                    return;
                }
            }
            if (openFileDialog1.FileName == "")
            {
                labelFilename.Text = "No File Selected.";
                labelSize.Text = "";
            }
        }

        private void sendButton_Click(object sender, EventArgs e)
        {
            try
            {
                labelSuccess.Text = "";
                if (openFileDialog1.FileName == "")
                {
                    MessageBox.Show(this, "You must first select a file.");
                    return;
                }
                object portName = serialPortSelect.SelectedItem;
                if (portName == null)
                {
                    MessageBox.Show(this, "You must first select a serial port.");
                    return;
                }
                serialPort1.PortName = portName.ToString();
                object baudRate = baudRateSelect.SelectedItem;
                if (baudRate == null)
                {
                    MessageBox.Show(this, "You must first select the baud rate.");
                    return;
                }
                serialPort1.BaudRate = Convert.ToInt32(baudRate.ToString());
                if (serialPort1.IsOpen) // this doesn't work...
                {
                    MessageBox.Show(this, "Serial port " + portName + " could not be opened and may be in use");
                    return;
                }
                string filename = openFileDialog1.FileName;
                int fileSizeBytes = 0;
                System.IO.FileInfo fi = new System.IO.FileInfo(filename);
                fileSizeBytes = (int)fi.Length; // already verified <= 1MB
                labelSize.Text = "Size: " + fileSizeBytes + " bytes.";
                int offsetWords;
                string offsetStr = setOffset.Text;
                if (offsetStr == "")
                {
                    MessageBox.Show(this, "You must enter an offset between 0 and 262143");
                    return;
                }
                try
                {
                    offsetWords = Convert.ToInt32(offsetStr, 10);
                }
                catch (Exception)
                {
                    MessageBox.Show(this, "\"" + offsetStr + "\" is not a valid number between 0 and 262143");
                    return;
                }
                if ((offsetWords < 0) || (offsetWords > (1048576 - fileSizeBytes)))
                {
                    MessageBox.Show(this, "Offset must be between 0 and (262144 - number of words).");
                    return;
                }
                sendButton.Enabled = false;
                serialPort1.Open();
                /* Send the data */
                fileSizeBytes--;
                UInt32 size_head = (UInt32)((fileSizeBytes / 4));
                UInt32 offs_head = (UInt32)offsetWords;
                byte size1 = (byte)((size_head << 14) >> 30);
                byte size2 = (byte)((size_head << 16) >> 24);
                byte size3 = (byte)((size_head << 24) >> 24);
                byte offs1 = (byte)((offs_head << 14) >> 30);
                byte offs2 = (byte)((offs_head << 16) >> 24);
                byte offs3 = (byte)((offs_head << 24) >> 24);
                byte[] header = { 0x58, 0x55, 0x4d, size1, size2, size3, offs1, offs2, offs3 }; // 'X''U''M' followed by size, offset.
                serialPort1.Write(header, 0, header.Length);
                fileSizeBytes++;

                /* Check that the copy of size3 came back */
                serialPort1.ReadTimeout = 500;  // 500 ms to respond is more than enough.
                byte[] response = new byte[1];
                try
                {
                    serialPort1.Read(response, 0, 1);
                }
                catch (System.TimeoutException)
                {
                    MessageBox.Show(this, "The device did not respond.\n\nIt may be off, disconnected, set at a different baud rate," +
                        "\nor not listening for the XUM boot protocol.");
                    serialPort1.Close();
                    sendButton.Enabled = true;
                    return;
                }
                if (response[0] != size3)
                {
                    MessageBox.Show(this, "An unexpected response was received from the device.\n" +
                        "(Expected " + size3 + ", Received " + response[0] + ")\n\n" +
                        "Make sure it is configured for the XUM boot protocol.");
                    serialPort1.Close();
                    sendButton.Enabled = true;
                    return;
                }

                /* Send and verify the data */
                progressBar1.Visible = true;
                progressBar1.Minimum = 0;
                progressBar1.Maximum = fileSizeBytes;
                progressBar1.Value = 0;
                byte[] fileData = new byte[fileSizeBytes];
                byte[] echoData = new byte[1024];
                System.IO.BinaryReader file = new System.IO.BinaryReader(File.Open(filename, FileMode.Open));
                file.Read(fileData, 0, fileSizeBytes);
                file.Close();
                int sentByteCount = 0;
                int currentSendSize = 0;
                Stopwatch stopwatch = new Stopwatch();
                stopwatch.Start();
                while (sentByteCount < fileSizeBytes)
                {
                    if ((fileSizeBytes - sentByteCount) >= 1024)
                        currentSendSize = 1024;
                    else
                        currentSendSize = (fileSizeBytes - sentByteCount);

                    serialPort1.Write(fileData, sentByteCount, currentSendSize);
                    long waitStart = stopwatch.ElapsedMilliseconds;
                    while (serialPort1.BytesToRead < currentSendSize) {
                        if ((stopwatch.ElapsedMilliseconds - waitStart) > 4000)
                        {
                            MessageBox.Show(this, "The device stopped responding. Giving up." + "\nDevice Ack'd : " + serialPort1.BytesToRead + " of " + currentSendSize);
                            serialPort1.Close();
                            sendButton.Enabled = true;
                            progressBar1.Value = 0;
                            progressBar1.Visible = false;
                            return;
                        }
                    }
                    if (serialPort1.BytesToRead > currentSendSize)
                    {
                        MessageBox.Show(this, "The device sent back an extra " + (serialPort1.BytesToRead - currentSendSize) + " byte(s), which was unexpected.");
                    }
                    serialPort1.Read(echoData, 0, currentSendSize);
                    for (int i = 0; i < currentSendSize; i++)
                    {
                        if (fileData[sentByteCount + i] != echoData[i])
                        {
                            MessageBox.Show(this, "The device sent back non-matching data. There was a transmission error." +
                            "\n\n" + (sentByteCount + i) + " bytes were transmitted successfully.");
                            serialPort1.Close();
                            sendButton.Enabled = true;
                            return;
                        }
                    }
                    sentByteCount += currentSendSize;
                    progressBar1.Value = sentByteCount;
                }
                stopwatch.Stop();
                labelSuccess.Text = "Success (" + (stopwatch.ElapsedMilliseconds / 1000.0) + " seconds).";
                serialPort1.Close();
                sendButton.Enabled = true;
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.Message);
                if (serialPort1.IsOpen)
                    serialPort1.Close();
                sendButton.Enabled = true;
                progressBar1.Value = 0;
                return;
            }

        }


    }
}
