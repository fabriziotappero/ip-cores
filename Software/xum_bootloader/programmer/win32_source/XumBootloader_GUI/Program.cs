using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using System.IO.Ports;

namespace XumBootloader_GUI
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        
        public static string[] comPorts;    // List of available serial ports.
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            try
            {
                comPorts = SerialPort.GetPortNames();
            }
            catch (System.ComponentModel.Win32Exception ex)
            {
                MessageBox.Show(ex.Message);
                Environment.Exit(1);
            }
            Application.Run(new Form1());
        }

        /* Helper function to retrieve serial port names */
        public static string[] getComPortNames()
        {
            return comPorts;
        }
    }
}
