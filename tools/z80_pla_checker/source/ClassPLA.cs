using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace z80_pla_checker
{
    /// <summary>
    /// This class defines a complete PLA table and operations on it
    /// </summary>
    class ClassPla
    {
        /// <summary>
        /// List of all PLA entries that we read from the input file
        /// </summary>
        private readonly List<ClassPlaEntry> pla = new List<ClassPlaEntry>();

        /// <summary>
        /// List of PLA entries which we want to ignore for various reasons
        /// </summary>
        public List<int> IgnoredPla = new List<int>();

        /// <summary>
        /// Returns the total number of PLA table entries
        /// </summary>
        public int Count()
        {
            return pla.Count();
        }

        /// <summary>
        /// Read the master PLA table from a text file
        /// </summary>
        public bool Load(string filename)
        {
            // Read each line of the file into a string array. Each element
            // of the array is one line of the file.
            ClassLog.Log("Loading PLA: " + filename);

            try
            {
                string[] lines = File.ReadAllLines(filename);
                pla.Clear();
                foreach (string line in lines)
                {
                    if (line[0] == '#')
                        continue;
                    var p = new ClassPlaEntry();
                    if (p.Init(line))
                        pla.Add(p);
                }
            }
            catch (Exception ex)
            {
                ClassLog.Log(ex.Message);
                return false;
            }
            ClassLog.Log(string.Format("Total {0} PLA lines", pla.Count()));

            ////============================================================
            //// Ignore duplicate PLA entries
            //IgnoredPla.Add(90);     // Duplicate of 26
            //IgnoredPla.Add(36);     // Duplicate of 8
            //IgnoredPla.Add(71);     // Duplicate of 25
            //IgnoredPla.Add(63);     // Duplicate of 17
            //IgnoredPla.Add(87);     // Duplicate of 83
            //IgnoredPla.Add(60);     // Duplicate of 15
            //IgnoredPla.Add(94);     // Duplicate of 12 and 18
            //IgnoredPla.Add(18);     // Duplicate of 12 and 94
            //IgnoredPla.Add(93);     // Duplicate of 11 and 19
            //IgnoredPla.Add(19);     // Duplicate of 11 and 93
            //IgnoredPla.Add(98);     // Duplicate of 37
            //IgnoredPla.Add(41);     // Duplicate of 3
            //IgnoredPla.Add(32);     // Duplicate of 4

            ////============================================================
            //// Special signals (not instructions)
            //IgnoredPla.Add(91);     // This signal goes along block IN/OUT instructions.
            //IgnoredPla.Add(75);     // This signal specifies a decrement operation for PLA 53, 66 and 105. Otherwise, it is an increment.
            //IgnoredPla.Add(55);     // This signal specifies (HL) addressing for all CB-table instructions, PLA entries 70, 72, 73, 74.
            //IgnoredPla.Add(44);     // This signal specifies a regular CB opcode (ignoring IX/IY).
            //IgnoredPla.Add(33);     // This signal specifies whether the register is being loaded or stored to memory for PLA entry 31.
            //IgnoredPla.Add(28);     // This signal specifies the OUT operation for PLA 37. Otherwise, it is operation.
            //IgnoredPla.Add(27);     // This signal goes along individual IN/OUT instructions in the ED table.
            //IgnoredPla.Add(16);     // This signal specifies a PUSH operation for PLA23. Otherwise, it is a POP operation.
            //IgnoredPla.Add(14);     // This signal specifies a decrement operation for PLA 9. Otherwise, it is an increment.
            //IgnoredPla.Add(13);     // This signal specifies whether the value is being loaded or stored for PLA entries 8, 30 and 38.
            //IgnoredPla.Add(4);      // This signal goes along instructions that access I and R register (PLA 57 and 83).
            //IgnoredPla.Add(0);      // This signal specifies *not* to repeat block instructions.

            ////============================================================
            //// Ignore our own reserved entries
            //IgnoredPla.Add(106);
            //IgnoredPla.Add(107);

            //============================================================
            // Remove op-bits so we the output is more readable
            IgnoredPla.Add(99);
            IgnoredPla.Add(100);
            IgnoredPla.Add(101);
            IgnoredPla.Add(102);
            IgnoredPla.Add(103);
            IgnoredPla.Add(104);

            // Remove ALU operation entries so the output is more readable
            IgnoredPla.Add(88);
            IgnoredPla.Add(86);
            IgnoredPla.Add(85);
            IgnoredPla.Add(84);
            IgnoredPla.Add(80);
            IgnoredPla.Add(79);
            IgnoredPla.Add(78);
            IgnoredPla.Add(76);

            //============================================================
            // Mark all PLA entries we decided to ignore
            foreach (var p in pla)
            {
                if (IgnoredPla.Contains<int>(p.N))
                    p.Ignored = true;
            }
            return true;
        }

        /// <summary>
        /// Dumps the content of the entire PLA table
        /// </summary>
        public void Dump()
        {
            ClassLog.Log("Content of the PLA table:");
            foreach (var p in pla.Where(p => !p.IsDuplicate()))
                ClassLog.Log(p.Raw);
        }

        /// <summary>
        /// Find and return all PLA table entries that trigger on a given condition.
        /// </summary>
        public List<string> TableMatch(ClassPlaEntry.Modifier modifier, byte instr)
        {
            var t = new bool[pla.Count];

            // First do a simple search to find the list of *all* PLA entries that match
            foreach (var p in pla)
            {
                if (p.Ignored) continue;
                String match = p.Match(modifier, instr);
                t[p.N] = !string.IsNullOrEmpty(match);
            }

            ////============================================================
            //// Apply any intra-PLA conditions. These are hard-coded into the
            //// timing spreadsheet and we are duplicating them here:

            //// INC/DEC variations with register, (hl) or (ix+d)
            //if (t[66] && !(t[53] || t[105])) ; else t[66] = false;

            //// Generic LD r,r' + (hl), IX variations and on top of that NHALT
            //if (t[61] && !(t[59] || t[103] || t[58] || t[102] || t[95])) ; else t[61] = false;
            //if (t[58] && !t[95]) ; else t[58] = false;
            //if (t[102] && !t[95]) ; else t[102] = false;
            //if (t[59] && !t[95]) ; else t[59] = false;
            //if (t[103] && !t[95]) ; else t[103] = false;

            //// A single LD (hl),n and LD (ix+d),n has precedence over a set of LD r,n
            //if (t[17] && !(t[40] || t[50])) ; else t[17] = false;

            //// ALU A,r' and variations on (hl) and (ix+d)
            //if (t[65] && !(t[52] || t[104])) ; else t[65] = false;

            //// ALU
            //if (t[88] && (t[65] || t[64] || t[52] || t[104])) ; else t[88] = false;
            //if (t[86] && (t[65] || t[64] || t[52] || t[104])) ; else t[86] = false;
            //if (t[85] && (t[65] || t[64] || t[52] || t[104])) ; else t[85] = false;
            //if (t[84] && (t[65] || t[64] || t[52] || t[104])) ; else t[84] = false;
            //if (t[80] && (t[65] || t[64] || t[52] || t[104])) ; else t[80] = false;
            //if (t[79] && (t[65] || t[64] || t[52] || t[104])) ; else t[79] = false;
            //if (t[78] && (t[65] || t[64] || t[52] || t[104])) ; else t[78] = false;
            //if (t[76] && (t[65] || t[64] || t[52] || t[104])) ; else t[76] = false;

            //============================================================

            // Finally, collect and return all PLA entries that are left asserted
            return (from p in pla
                    where t[p.N]
                    select p.Match(modifier, instr)).ToList();
        }

        /// <summary>
        /// Given the PLA ID, return a list of all opcodes that trigger it
        /// </summary>
        public List<string> MatchPLA(ClassPlaEntry.Modifier modifier, int id)
        {
            var m = new List<string>();

            // Find the pla with a given index
            foreach (ClassPlaEntry p in pla)
            {
                if (p.N == id)
                {
                    // For each possible opcode...
                    for (int i = 0; i < 256; i++)
                    {
                        String match = p.Match(modifier, Convert.ToByte(i));
                        if (!string.IsNullOrEmpty(match))
                            m.Add(string.Format("{0:X02} => {1}", i, match));
                    }
                    return m;
                }
            }
            ClassLog.Log("Non-existent PLA index");
            return m;
        }

        /// <summary>
        /// Dump opcode table in various ways.
        /// Returns a "selected" list of opcode numbers, that is, opcodes which were tagged by
        /// the optional input PLA table number given in arg parameter.
        /// </summary>
        public List<int> Table(ClassPlaEntry.Modifier modifier, int testNum, int arg)
        {
            ClassLog.Log(new string('-', 242));
            List<int> tagged = new List<int>();
            for (int y = 0; y < 16; y++)
            {
                string line = string.Format("{0:X} ", y);
                for (int x = 0; x < 16; x++)
                {
                    char prefix = ' ';
                    byte opcode = Convert.ToByte(y * 16 + x);
                    List<string> match = TableMatch(modifier, opcode);
                    foreach (string oneMatch in match.Where(oneMatch => Convert.ToInt32(oneMatch.Substring(1, oneMatch.LastIndexOf(']') - 1)) == arg))
                    {
                        tagged.Add(y * 16 + x);
                        prefix = '*';
                    }
                    string entry = "";

                    //===============================================================================
                    // Table 0 - Show the number of PLA entries that match each opcode
                    //===============================================================================
                    if (testNum == 0)
                    {
                        entry = string.Join(",", match);
                        if (match.Count == 0)
                            entry = ".";
                        if (match.Count > 1)
                            entry = "[" + match.Count + "]";
                    }

                    //===============================================================================
                    // Table 1 - For each opcode, show all PLA entries that trigger
                    //===============================================================================
                    if (testNum == 1)
                    {
                        foreach (string oneMatch in match)
                        {
                            string n = oneMatch.Substring(1, oneMatch.LastIndexOf(']') - 1);
                            entry += n + ",";
                        }
                        entry = entry.TrimEnd(',');
                    }

                    // -------------------------------------------
                    if (entry.Length > 12)
                        entry = entry.Substring(0, 12);
                    line += string.Format(" |{0}{1,-12}", prefix, entry);
                }
                ClassLog.Log(line);
            }
            return tagged;
        }

        /// <summary>
        /// Query PLA table string given as a vector of 0's and 1's
        /// This vector is coped from a ModelSim simulation run. The function will decode PLA string
        /// into a set of PLA entries that are being triggered ("1")
        /// </summary>
        public void QueryPla(String bits)
        {
            int max = pla.Count();
            if (bits.Count() != max)
            {
                ClassLog.Log("Invalid PLA length - the bit array should be " + max + " and it is " + bits.Count());
                return;
            }
            for (int i = 0; i < max; i++)
                if (bits[max - i - 1] == '1')
                    ClassLog.Log(string.Format(@"pla[{0,3}] = 1;   // {1}", pla[i].N, pla[i].Comment));
        }

        /// <summary>
        /// Generates a Verilog module with the PLA logic
        /// </summary>
        public void GenVerilogPla()
        {
            string max = (pla.Count() - 1).ToString();
            string module = "";
            module += @"//=====================================================================================" + Environment.NewLine;
            module += @"// This file is automatically generated by the z80_pla_checker tool. Do not edit!      " + Environment.NewLine;
            module += @"//=====================================================================================" + Environment.NewLine;
            module += @"module pla_decode (opcode, prefix, pla);" + Environment.NewLine;
            module += @"" + Environment.NewLine;
            module += @"input wire [6:0] prefix;" + Environment.NewLine;
            module += @"input wire [7:0] opcode;" + Environment.NewLine;
            module += @"output reg [" + max + ":0] pla;" + Environment.NewLine;
            module += @"" + Environment.NewLine;
            module += @"always_comb" + Environment.NewLine;
            module += @"begin" + Environment.NewLine;

            foreach (var p in pla)
            {
                if (p.IsDuplicate())
                    continue;
                String bitstream = p.GetBitstream();
                module += string.Format(@"    if ({{prefix[6:0], opcode[7:0]}} ==? 15'b{0})  pla[{1,3}]=1'b1; else pla[{1,3}]=1'b0;   // {2}",
                    bitstream, p.N, p.Comment) + Environment.NewLine;
            }

            // Dump all PLA entries that are ignored
            module += @"" + Environment.NewLine;
            module += @"    // Duplicate or ignored entries" + Environment.NewLine;
            foreach (var p in pla)
            {
                if (p.IsDuplicate())
                    module += string.Format(@"    pla[{0,3}]=1'b0;   // {1}", p.N, p.Comment) + Environment.NewLine;
            }

            module += @"end" + Environment.NewLine;
            module += @"" + Environment.NewLine;
            module += @"endmodule" + Environment.NewLine;

            ClassLog.Log(module);
        }
    }
}
