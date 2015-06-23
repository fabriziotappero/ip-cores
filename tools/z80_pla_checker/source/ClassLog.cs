namespace z80_pla_checker
{
    /// <summary>
    /// Implements the logging to the main window
    /// </summary>
    static public class ClassLog
    {
        static public void Log(string m)
        {
            Program.MainForm.Log(m);
        }
    }
}
