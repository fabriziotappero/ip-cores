using System;
using System.Collections.Generic;
using System.IO;

namespace z80_pla_checker
{
    /// <summary>
    /// This class loads from a file the opcode table and provides
    /// access functions to a table.
    /// </summary>
    class ClassOpcodeTable
    {
        /// <summary>
        /// Contains the opcode description indexed by the opcode byte
        /// </summary>
        private readonly Dictionary<int, string> op = new Dictionary<int, string>();

        /// <summary>
        /// Loads an opcode table from a text file
        /// </summary>
        public void Load(string filename, int xxindex)
        {
            ClassLog.Log("Loading opcode table: " + filename);

            try
            {
                string[] lines = File.ReadAllLines(filename);
                op.Clear();
                foreach (string line in lines)
                {
                    string hex = line.Substring(xxindex, 2);
                    string instr = line.Substring(12);
                    int xx = Convert.ToInt32(hex, 16);
                    op[xx] = instr;
                }

            }
            catch (Exception ex)
            {
                ClassLog.Log(ex.Message);
            }
        }

        /// <summary>
        /// Dumps the opcode table in a table format
        /// The opcode numbers in the list t will be tagged (marked with *)
        /// </summary>
        public void Dump(List<int> t)
        {
            ClassLog.Log(new string('-', 242));
            for (int y = 0; y < 16; y++)
            {
                string line = string.Format("{0:X} ", y);
                for (int x = 0; x < 16; x++)
                {
                    string opcode = "";
                    if (op.ContainsKey(y * 16 + x))
                        opcode = op[y * 16 + x];
                    if (opcode.Length > 12)
                        opcode = opcode.Substring(0, 12);
                    char tag = ' ';
                    if (t.Contains(y * 16 + x)) tag = '*';
                    line += string.Format(" |{0}{1,-12}", tag, opcode);
                }
                ClassLog.Log(line);
            }
        }
    }
}
