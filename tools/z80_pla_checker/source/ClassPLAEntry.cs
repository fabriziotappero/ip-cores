using System;

namespace z80_pla_checker
{
    /// <summary>
    /// This class defines a single PLA entry and the operations on it
    /// </summary>
    public class ClassPlaEntry
    {
        // IX/IY Modifiers
        [FlagsAttribute] 
        public enum Modifier
        {
            IXY0 = (1 << 6),                    // IX or IY flag is reset 
            IXY1 = (1 << 5),                    // IX or IY flag is set
            NHALT = (1 << 4),                   // Not in HALT state
            ALU  = (1 << 3),                    // ALU operation
            XX = (1 << 2),                      // Regular instruction
            CB = (1 << 1),                      // CB instruction table modifier
            ED = (1 << 0)                       // ED instruction table modifier
        };

        private int prefix;                         // Modifier bitfield
        private int opcode;                         // Opcode bitfield
        private bool duplicate;                     // This entry is a duplicate
        public bool IsDuplicate() { return duplicate; }

        public int N { get; private set; }          // Ordinal number of this entry, or the entry ID
        public string Comment { get; private set; } // PLA line description / comment text
        public string Raw { get; private set; }     // Raw line as-is
        public bool Ignored = false;                // This entry can optionally be ignored

        /// <summary>
        /// PLA entry class constructor
        /// Accepts the init string which should contain a line from the PLA master table.
        /// Various fields from that line are read into this class.
        /// </summary>
        public bool Init(string init)
        {
            try
            {
                Raw = init;
                char[] delimiterChars = { '\t' };
                string[] w = init.Split(delimiterChars);

                // Example of an input line:
                // w[0]                    w[1] w[2] w[3]     w[4]
                // ....1.. 1.1........1.11.  D   63  00xxx110 ld r,*

                // Mark a duplicate
                duplicate = w[1].Contains("D");

                // Read the 7 bits of the prefix
                for (int i = 0; i < 7; i++)
                    if (w[0][6-i] == '1') prefix |= (1 << i);

                // Read 16 bits of the opcode mask
                for (int i = 0; i < 16; i++)
                    if (w[0][23 - i] == '1') opcode |= (1 << i);

                N = Convert.ToInt32(w[2]);
                Comment = w[4];

                return true;
            }
            catch (Exception ex)
            {
                ClassLog.Log("ClassPlaEntry: Can't parse line: " + init);
                ClassLog.Log(ex.Message);
            }
            return false;
        }


        /// <summary>
        /// Matches a given opcode to this PLA line. Returns empty string if not a match
        /// or PLA number and mnemonic if there is a match. Duplicates are ignored.
        /// </summary>
        public string Match(Modifier modifier, Byte instr)
        {
            if (duplicate) return string.Empty;

            // Check the modifiers against the prefix bitfield.
            if ((((int)modifier) & prefix) != prefix)
                return string.Empty;

            // Check each opcode bit
            // If any bit in the opcode map is 1, the instruction needs to be "0" or "1"
            for (int i = 0; i < 8; i++)
            {
                int testbit = (instr >> i) & 1;
                int test1 = (opcode >> (i * 2)) & 1;
                int test0 = (opcode >> (i * 2 + 1)) & 1;
                if (test1 == 1 && testbit != 1) return string.Empty;
                if (test0 == 1 && testbit != 0) return string.Empty;
            }

            return string.Format("[{0}] {1}", N, Comment);
        }

        /// <summary>
        /// Return a PLA entry suitable to use in a System Verilog compare statement
        /// </summary>
        public string GetBitstream()
        {
            // Write out these bits in order; they can be 1 or don't care (X)
            string bitstream = "";
            // Create 7 bits of the prefix
            for (int i = 6; i >= 0; i--)
                bitstream += (prefix & (1 << i))==0 ? "X" : "1";
            bitstream += "_";
            // Followed by the 8 bits of the opcode mask
            for (int i = 7; i >= 0; i--)
            {
                string code = "X";
                int test1 = (opcode >> (i * 2)) & 1;
                int test0 = (opcode >> (i * 2 + 1)) & 1;
                if (test1 == 1)
                    code = "1";
                if (test0 == 1)
                    code = "0";
                bitstream += code;
            }
            return bitstream;
        }
    }
}
