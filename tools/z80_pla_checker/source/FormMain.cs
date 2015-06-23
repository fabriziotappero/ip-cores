using System;
using System.Collections.Generic;
using System.IO;
using System.Windows.Forms;

namespace z80_pla_checker
{
    public partial class FormMain : Form
    {
        /// <summary>
        /// Master PLA table
        /// </summary>
        private readonly ClassPla pla = new ClassPla();

        /// <summary>
        /// Current modifiers
        /// </summary>
        private ClassPlaEntry.Modifier modifier = ClassPlaEntry.Modifier.XX | ClassPlaEntry.Modifier.NHALT;

        /// <summary>
        /// Various opcode tables we need to display mnemonics
        /// </summary>
        private readonly ClassOpcodeTable tableXX__ = new ClassOpcodeTable();
        private readonly ClassOpcodeTable tableCBXX = new ClassOpcodeTable();
        private readonly ClassOpcodeTable tableEDXX = new ClassOpcodeTable();
        private readonly ClassOpcodeTable tableDDXX = new ClassOpcodeTable();
        private readonly ClassOpcodeTable tableDDCB = new ClassOpcodeTable();

        private readonly List<string> commands = new List<string>();
        private int commandsBrowseIndex;

        public FormMain()
        {
            InitializeComponent();
            WindowState = FormWindowState.Maximized;
        }

        /// <summary>
        /// This is the main program's startup function
        /// </summary>
        public void OnStart()
        {
            ClassLog.Log("PLA Checker Tool  Copyright (C) 2014  Goran Devic");
            ClassLog.Log("This program comes with ABSOLUTELY NO WARRANTY");
            ClassLog.Log("This is free software and you are welcome to redistribute it under certain conditions; for details see GPLv3 license.");
            ClassLog.Log("---------------------------------------------------------------------------------------------------------------------");

            // Load the PLA table from a text file.
            String plaFile = Properties.Settings.Default.plaFileName;
            if (!pla.Load(plaFile))
            {
                ClassLog.Log("*** Error loading the master input PLA source table ***");
                ClassLog.Log("Click on File -> Load PLA table... and select a resource file z80-pla.txt");
                return;
            }

            // Load opcode tables from a previously selected directory
            // We use only IX variation tables since IY's are the same
            String opFile = Properties.Settings.Default.opcodeDir;
            char p = Path.DirectorySeparatorChar;
            tableXX__.Load(opFile + p + "opcodes-xx.txt", 0);
            tableCBXX.Load(opFile + p + "opcodes-cb-xx.txt", 2);
            tableEDXX.Load(opFile + p + "opcodes-ed-xx.txt", 2);
            tableDDXX.Load(opFile + p + "opcodes-dd-xx.txt", 2);
            tableDDCB.Load(opFile + p + "opcodes-dd-cb.txt", 7);

            ClassLog.Log(Command("?"));
        }

        /// <summary>
        /// Print out a log message & always show the last line
        /// </summary>
        public void Log(String s)
        {
            logText.AppendText(s + Environment.NewLine);
            logText.SelectionStart = logText.Text.Length;
            logText.ScrollToCaret();
        }

        /// <summary>
        /// Exit the application
        /// </summary>
        private void ExitToolStripMenuItemClick(object sender, EventArgs e)
        {
            Close();
        }

        /// <summary>
        /// Application is closing
        /// </summary>
        private void FormMainFormClosing(object sender, FormClosingEventArgs e)
        {
            Properties.Settings.Default.Save();
        }

        private static int ScanNumber(string arg, int baseValue)
        {
            try
            {
                return Convert.ToInt32(arg, baseValue);
            }
            catch(Exception ex)
            {
                ClassLog.Log(ex.Message + ": " + arg);
                return -1;
            }
        }

        /// <summary>
        /// List all PLA entries that trigger on a specific opcode
        /// If the opcode # (hex) was not given, dump that information for all opcodes (0-FF)
        /// </summary>
        private void MatchPLA(string arg)
        {
            int op = -1;
            if (!string.IsNullOrEmpty(arg))
            {
                op = ScanNumber(arg, 16);
                if (op < 0)
                    return;
            }
            for (int x = 0; x < 256; x++)
            {
                if (op >= 0 && x != op)
                    continue;
                ClassLog.Log(String.Format("Opcode: {0:X02} ", x));

                Byte opcode = Convert.ToByte(x);
                List<string> m = pla.TableMatch(modifier, opcode);

                foreach (var s in m)
                    ClassLog.Log(s);
            }
        }

        /// <summary>
        /// List all opcodes that trigger on a given PLA table index
        /// </summary>
        private void MatchOpcodes(ClassPlaEntry.Modifier modifier, string arg)
        {
            int index = ScanNumber(arg, 10);
            if (index < 0)
                return;
            List<string> m = pla.MatchPLA(modifier, index);
            if (m.Count == 0)
                return;
            ClassLog.Log(String.Format("PLA Entry: {0}  Modifier: {1}", index, modifier));
            foreach (var s in m)
                ClassLog.Log(s);
        }

        /// <summary>
        /// Dumps one of the opcode tables depending on the current set of modifiers
        /// </summary>
        private void DumpOpcodeTable(List<int> t)
        {
            bool cb = (modifier & ClassPlaEntry.Modifier.CB) != 0;
            bool ed = (modifier & ClassPlaEntry.Modifier.ED) != 0;
            bool ix = (modifier & ClassPlaEntry.Modifier.IXY1) != 0;
            if (ix & cb)
                tableDDCB.Dump(t);
            else if (cb)
                tableCBXX.Dump(t);
            else if (ed)
                tableEDXX.Dump(t);
            else if (ix)
                tableDDXX.Dump(t);
            else tableXX__.Dump(t);
        }

        /// <summary>
        /// Select the input PLA table file to load
        /// </summary>
        private void LoadPlaTable(object sender, EventArgs e)
        {
            var dlg = new OpenFileDialog();
            dlg.Title = "Select a PLA table source file";
            dlg.Filter = @"z80-pla.txt|*.txt|All files|*.*";
            dlg.FileName = Properties.Settings.Default.plaFileName;
            if (dlg.ShowDialog() == DialogResult.OK)
                Properties.Settings.Default.plaFileName = dlg.FileName;
        }

        /// <summary>
        /// Select the directory that contains opcode tables
        /// </summary>
        private void SelectOpcodeDir(object sender, EventArgs e)
        {
            var dlg = new FolderBrowserDialog();
            dlg.Description = "Select the directory containing opcode files (opcodes-xx.txt etc.):";
            if (dlg.ShowDialog() == DialogResult.OK)
                Properties.Settings.Default.opcodeDir = dlg.SelectedPath;
        }

        /// <summary>
        /// Clear the log text panel
        /// </summary>
        private void BtClearClick(object sender, EventArgs e)
        {
            logText.Clear();
        }

        /// <summary>
        /// User clicked on the Redo button: repeat the command
        /// </summary>
        private void BtRedoClick(object sender, EventArgs e)
        {
            ClassLog.Log(string.Format("{0}>>> {1}", commands.Count, commands[commands.Count - 1]));
            string response = Command(commands[commands.Count - 1]);
            if (!string.IsNullOrEmpty(response))
                ClassLog.Log(response);
        }

        /// <summary>
        /// Update button state after the internal flag state change
        /// </summary>
        private void UpdateButtons()
        {
            btIX0.Checked = (modifier & ClassPlaEntry.Modifier.IXY0) != 0;
            btIX1.Checked = (modifier & ClassPlaEntry.Modifier.IXY1) != 0;
            btHALT.Checked = (modifier & ClassPlaEntry.Modifier.NHALT) != 0;
            btALU.Checked = (modifier & ClassPlaEntry.Modifier.ALU) != 0;
            btXX.Checked = (modifier & ClassPlaEntry.Modifier.XX) != 0;
            btCB.Checked = (modifier & ClassPlaEntry.Modifier.CB) != 0;
            btED.Checked = (modifier & ClassPlaEntry.Modifier.ED) != 0;

            ClassLog.Log("Set modifier to " + modifier);
        }

        private void BtIx0Click(object sender, EventArgs e)
        {
            if ((modifier & ClassPlaEntry.Modifier.IXY0) != 0)
                modifier &= ~ClassPlaEntry.Modifier.IXY0;
            else
            {
                modifier |= ClassPlaEntry.Modifier.IXY0;
                modifier &= ~ClassPlaEntry.Modifier.IXY1;                
            }
            UpdateButtons();
        }

        private void BtIx1Click(object sender, EventArgs e)
        {
            if ((modifier & ClassPlaEntry.Modifier.IXY1) != 0)
                modifier &= ~ClassPlaEntry.Modifier.IXY1;
            else
            {
                modifier |= ClassPlaEntry.Modifier.IXY1;
                modifier &= ~ClassPlaEntry.Modifier.IXY0;
            }
            UpdateButtons();
        }

        private void BtNHaltClick(object sender, EventArgs e)
        {
            modifier ^= ClassPlaEntry.Modifier.NHALT;
            UpdateButtons();
        }

        private void BtAluClick(object sender, EventArgs e)
        {
            modifier ^= ClassPlaEntry.Modifier.ALU;
            UpdateButtons();
        }

        private void BtXxClick(object sender, EventArgs e)
        {
            if ((modifier & ClassPlaEntry.Modifier.XX) != 0)
                modifier &= ~ClassPlaEntry.Modifier.XX;
            else
            {
                modifier |= ClassPlaEntry.Modifier.XX;
                modifier &= ~(ClassPlaEntry.Modifier.CB | ClassPlaEntry.Modifier.ED);
            }
            UpdateButtons();
        }

        private void BtCbClick(object sender, EventArgs e)
        {
            if ((modifier & ClassPlaEntry.Modifier.CB) != 0)
                modifier &= ~ClassPlaEntry.Modifier.CB;
            else
            {
                modifier |= ClassPlaEntry.Modifier.CB;
                modifier &= ~(ClassPlaEntry.Modifier.XX | ClassPlaEntry.Modifier.ED);
            }
            UpdateButtons();
        }

        private void BtEdClick(object sender, EventArgs e)
        {
            if ((modifier & ClassPlaEntry.Modifier.ED) != 0)
                modifier &= ~ClassPlaEntry.Modifier.ED;
            else
            {
                modifier |= ClassPlaEntry.Modifier.ED;
                modifier &= ~(ClassPlaEntry.Modifier.XX | ClassPlaEntry.Modifier.CB);
            }
            UpdateButtons();
        }

        /// <summary>
        /// Implements a simple command history
        /// </summary>
        private void TextOpKeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                // Mark the handled flag so this key won't be processed.
                e.Handled = true;
                string cmd = textOp.Text.Trim();
                if (cmd.Length > 0)
                {
                    commands.Add(cmd);
                    btRedo.Enabled = true;
                    ClassLog.Log(string.Format("{0}>>> {1}", commands.Count, cmd));
                    string response = Command(textOp.Text);
                    if (!string.IsNullOrEmpty(response))
                        ClassLog.Log(response);

                    commandsBrowseIndex = commands.Count;
                    textOp.Text = "";
                }
                textOp.Focus();
            }
            if (e.KeyCode == Keys.PageUp && commandsBrowseIndex > 0)
            {
                commandsBrowseIndex--;
                textOp.Text = commands[commandsBrowseIndex];
                e.Handled = true;
            }
            if (e.KeyCode == Keys.PageDown && commandsBrowseIndex < commands.Count - 1)
            {
                commandsBrowseIndex++;
                textOp.Text = commands[commandsBrowseIndex];
                e.Handled = true;
            }
            if (e.KeyCode == Keys.Escape)
            {
                textOp.Text = "";
                e.Handled = true;
            }
        }

        /// <summary>
        /// Execute a command
        /// </summary>
        private string Command(string cmd)
        {
            try
            {
                string[] tokens = cmd.Split(new string[] { " " }, StringSplitOptions.RemoveEmptyEntries);
                if (tokens.Length == 0)
                    return "";
                switch (tokens[0])
                {
                    case "?":
                    case "h":
                        return Environment.NewLine +
                            "p         - Dump the content of the PLA table" + Environment.NewLine +
                            "p [#]     - For a given PLA entry # (dec) show opcodes that trigger it" + Environment.NewLine +
                            "m [#]     - Match opcode # (hex) with a PLA entry (or match 0-FF)" + Environment.NewLine +
                            "g         - Generate a Verilog PLA module" + Environment.NewLine +
                            "t [#] <#> - Show opcode table in various ways" + Environment.NewLine +
                            "            0 - Display number of PLA entries that trigger on each opcode" + Environment.NewLine +
                            "            1 - For each opcode, display all PLA entry numbers that trigger" + Environment.NewLine +
                            "            <#> - Add a * to opcodes for which the specified PLA entry triggers" + Environment.NewLine +
                            "q 101000... Query PLA table string" + Environment.NewLine +
                            "c         - Clear the screen";
                    case "p": if (tokens.Length > 1)
                            MatchOpcodes(modifier, tokens[1]);
                        else
                            pla.Dump();
                        break;
                    case "m": MatchPLA(tokens.Length > 1 ? tokens[1] : "");
                        break;
                    case "g": pla.GenVerilogPla();
                        break;
                    case "c": BtClearClick(null, null);
                        break;
                    case "t":
                        {
                            int arg1 = 0, arg2 = -1;
                            if (tokens.Length > 1)
                                arg1 = ScanNumber(tokens[1], 10);
                            if (tokens.Length > 2)
                                arg2 = ScanNumber(tokens[2], 10);
                            if (arg1 == 0 || arg1 == 1)
                            {
                                List<int> tagged = pla.Table(modifier, arg1, arg2);
                                DumpOpcodeTable(tagged);
                            }
                            else
                                ClassLog.Log("Invalid table number!");
                        }
                        break;
                    case "q": pla.QueryPla(tokens[1].Trim());
                        break;
                    default:
                        return "?";
                }
            }
            catch (Exception ex)
            {
                ClassLog.Log("Error: " + ex.Message);
            }
            return string.Empty;
        }
    }
}
