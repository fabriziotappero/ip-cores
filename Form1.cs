using System;
using System.IO;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;

namespace lem9_1min_asm
{
	/// <summary>
	/// Summary description for Form1.
	/// </summary>
	public class Form1 : System.Windows.Forms.Form
	{
		private int IP;
		private System.Windows.Forms.ListBox listBox1;
		private int[] mem = new int[2048];
		private void HLT()	{mem[IP++]=0;}		//DEF	9B#000000000	; wait for system clock
		private void CACC() {mem[IP++]=0x10;}	//DEF	9B#000010000	; clear A, clear C
		private void CASC() {mem[IP++]=0x11;}	//DEF	9B#000010001	; clear A. set C
		private void SACC() {mem[IP++]=0x12;}	//DEF	9B#000010010	; set A, clear C
		private void SASC() {mem[IP++]=0x13;}	//DEF	9B#000010011	; set A, set C
		private void CC()	{mem[IP++]=0x14;}	//DEF	9B#000010100	; clear C
		private void SC()	{mem[IP++]=0x15;}	//DEF	9B#000010101	; set C
		private void CA()	{mem[IP++]=0x16;}	//DEF	9B#000010110	; clear A
		private void SA()	{mem[IP++]=0x17;}	//DEF	9B#000010111	; set A
		private void OR2C()	{mem[IP++]=0x18;}	//DEF	9B#000011000	; A | C to C
		private void NA()	{mem[IP++]=0x19;}	//DEF	9B#000011001	; negate A
		private void NC()	{mem[IP++]=0x1a;}	//DEF	9B#000011010	; negate C
		private void NANC() {mem[IP++]=0x1b;}	//DEF	9B#000011011	; negate A, negate C
		private void AND2C(){mem[IP++]=0x1c;}	//DEF	9B#000011100	; A & C to C
		private void C2A()	{mem[IP++]=0x1d;}	//DEF	9B#000011101	; copy C to A
		private void A2C()	{mem[IP++]=0x1e;}	//DEF	9B#000011110	; copy A to C
		private void XAC()	{mem[IP++]=0x1f;}	//DEF	9B#000011111	; swap A and C
		private void ST(int x)	{mem[IP++]=0x040 | x;}	//DEF	ST,6VB#000000	; store A at memory location
		private void LD(int x)	{mem[IP++]=0x080 | x;}	//DEF	LD,6VB#000000	; load A from memory location
		private void LDC(int x)	{mem[IP++]=0x0c0 | x;}	//DEF	LDC,6VB#000000	; load A complement from memory location
		private void AND(int x)	{mem[IP++]=0x100 | x;}	//DEF	AND,6VB#000000	; AND memory location into A
		private void OR(int x)	{mem[IP++]=0x140 | x;}	//DEF	OR,6VB#000000	; OR memory location into A
		private void XOR(int x)	{mem[IP++]=0x180 | x;}	//DEF	EOR,6VB#000000	; XOR memory location into A
		private void ADC(int x)	{mem[IP++]=0x1c0 | x;}
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.TextBox textBox2;
		private System.Windows.Forms.Button button1;
		private System.Windows.Forms.Label label2;
		private System.Windows.Forms.TextBox textBox3;
		private System.Windows.Forms.Button button2;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public Form1()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			//
			// TODO: Add any constructor code after InitializeComponent call
			//
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if (components != null) 
				{
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}


		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main() 
		{
			Application.Run(new Form1());
		}

		#region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.label1 = new System.Windows.Forms.Label();
			this.textBox2 = new System.Windows.Forms.TextBox();
			this.button1 = new System.Windows.Forms.Button();
			this.label2 = new System.Windows.Forms.Label();
			this.textBox3 = new System.Windows.Forms.TextBox();
			this.button2 = new System.Windows.Forms.Button();
			this.listBox1 = new System.Windows.Forms.ListBox();
			this.SuspendLayout();
			// 
			// label1
			// 
			this.label1.Location = new System.Drawing.Point(152, 128);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(56, 16);
			this.label1.TabIndex = 1;
			this.label1.Text = "File Name";
			// 
			// textBox2
			// 
			this.textBox2.Location = new System.Drawing.Point(16, 152);
			this.textBox2.Name = "textBox2";
			this.textBox2.Size = new System.Drawing.Size(280, 20);
			this.textBox2.TabIndex = 2;
			this.textBox2.Text = "lem1_9min_hw_041127";
			// 
			// button1
			// 
			this.button1.Location = new System.Drawing.Point(16, 184);
			this.button1.Name = "button1";
			this.button1.Size = new System.Drawing.Size(64, 23);
			this.button1.TabIndex = 3;
			this.button1.Text = "save xmt";
			this.button1.Click += new System.EventHandler(this.button1_Click);
			// 
			// label2
			// 
			this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
			this.label2.Location = new System.Drawing.Point(96, 0);
			this.label2.Name = "label2";
			this.label2.Size = new System.Drawing.Size(112, 23);
			this.label2.TabIndex = 5;
			this.label2.Text = "lem1_9min_asm";
			// 
			// textBox3
			// 
			this.textBox3.AcceptsReturn = true;
			this.textBox3.AcceptsTab = true;
			this.textBox3.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
			this.textBox3.Location = new System.Drawing.Point(320, 0);
			this.textBox3.Multiline = true;
			this.textBox3.Name = "textBox3";
			this.textBox3.ScrollBars = System.Windows.Forms.ScrollBars.Both;
			this.textBox3.Size = new System.Drawing.Size(368, 616);
			this.textBox3.TabIndex = 3;
			this.textBox3.Text = "; lem1_9min listing";
			// 
			// button2
			// 
			this.button2.Location = new System.Drawing.Point(16, 104);
			this.button2.Name = "button2";
			this.button2.Size = new System.Drawing.Size(64, 23);
			this.button2.TabIndex = 6;
			this.button2.Text = "assemble";
			this.button2.Click += new System.EventHandler(this.button2_Click);
			// 
			// listBox1
			// 
			this.listBox1.Items.AddRange(new object[] {
														  "toggle",
														  "cntr24",
														  "HEllo UJord"});
			this.listBox1.Location = new System.Drawing.Point(16, 32);
			this.listBox1.Name = "listBox1";
			this.listBox1.Size = new System.Drawing.Size(176, 56);
			this.listBox1.TabIndex = 8;
			// 
			// Form1
			// 
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.ClientSize = new System.Drawing.Size(696, 630);
			this.Controls.AddRange(new System.Windows.Forms.Control[] {
																		  this.listBox1,
																		  this.button2,
																		  this.textBox3,
																		  this.label2,
																		  this.button1,
																		  this.textBox2,
																		  this.label1});
			this.Name = "Form1";
			this.Text = "Form1";
			this.ResumeLayout(false);

		}
		#endregion

		private void toggle()				// toggle Accum & Carry
			{CACC(); SASC(); HLT();}

		private void INC(int loc)			// increment memory bit "macro"
			{ADC(loc); ST(loc); CA();}
		private void CNTR24()				// 24 bit incrementing counter "macro"
		{CASC(); for(int i=23; i>0; i--)INC(i); ADC(0); ST(0);}

		private void cntr24(){CNTR24(); HLT();}	// 24 bit incrementing counter program

		private void HEllo_UJorld()			// sliding 7-segment "hello world" with w via reversed & forward "j"
		{	CNTR24();	// lsb at location 23, msb at location 0
			// add segment position ("00"+14..15) to counter position (4..7)
			const int LT0=56, LT1=57, LT2=58, LT3=59, CT14=14, CT15=15, CT7=5, CT6=4, CT5=3, CT4=2;
			CACC(); LD(CT15); ADC(CT7); ST(LT0);
			LD(CT14); ADC(CT6); ST(LT1); 
			CA(); ADC(CT5); ST(LT2); 
			CA(); ADC(CT4); ST(LT3);
			// digit select decode, from 14..15, acitve low
			const int DIG3 = 60, DIG2 = 61, DIG1 = 62, DIG0 = 63, BT0 = 15, BT1 = 14; 
			LD(BT1); OR(BT0); ST(DIG0); 
			LDC(BT1); OR(BT0); ST(DIG2);  
			XOR(BT1); ST(DIG3); 
			XOR(BT0); ST(DIG1);
			// segment logic, segments: 0:top, 1:top right, 2:bottom right; 3:bottom, 4:bottom left,
			//							5:top left, 6:middle, 7:decimal point
			const int SEG0=55, SEG1=54, SEG2=53, SEG3=52, SEG4=51, SEG5=50, SEG6=49, DP=48; 
			const int A0=LT3, B0=LT2, C0=LT1, D0=LT0;
			
//			LD(LT0); OR(LT1); OR(LT2); OR(LT3); ST(DP);	// rotating decimal point
			SA(); ST(DP);	// no decimal point

			// rotating HELLO UJOrLd
			const int AB=47, AD=46, BD=45, NCD=44, BNCD=43, NANB=42, CND=41, t=40;
			LD(A0); AND(B0); ST(AB);	//ab
			LD(A0); AND(D0); ST(AD);	//ad
			LD(B0); AND(D0); ST(BD);	//bd
			LDC(C0); AND(D0); ST(NCD); AND(B0); ST(BNCD);	//ncd, bncd
			LD(A0); OR(B0); NA(); ST(NANB);	//nanb
			LDC(D0); AND(C0); ST(CND);	//cnd

			LDC(D0); AND(NANB); OR(C0); OR(BD); OR(AD); OR(AB); ST(SEG0);	//nanbnd+c+bd+ad+ab
			LD(NANB); AND(D0); OR(NCD); OR(CND); OR(AB); ST(SEG1);	// ncd+cnd+ab+nanbd
			LD(NANB); AND(C0); ST(t); LDC(B0); AND(CND); OR(t); OR(NCD); OR(AB); ST(SEG2);	//ncd+ab+nanbc+nbcnd
			LD(C0); OR(D0); NA(); AND(NANB); ST(t); LD(A0); AND(NCD); OR(t); OR(BNCD); OR(AB); ST(SEG3);// nanbncnd+bncd+ancd+ab
			LD(BNCD); OR(AB); ST(SEG4);	// bncd+ab
			LD(BD); OR(AD); OR(AB); ST(SEG5);	// bd+ad+ab
			LDC(A0); AND(C0); ST(t); LDC(D0); AND(A0); OR(B0); OR(t); ST(SEG6);	//nac+b+and

//			// rotating HEllo UJorld
//			const int t1=47, t2=46, t3=45, t4=44, t5=43, t6=42;
//			LDC(D0); OR(A0); OR(B0); OR(C0); ST(SEG0);

//			LD(A0); OR(B0); OR(C0); OR(D0); ST(t1);
//			LD(B0); AND(C0); AND(D0); NA(); OR(A0); AND(t1); ST(t1);
//			LD(A0); AND(C0); AND(D0); NA(); OR(B0); AND(t1); ST(SEG1);

//			LD(B0); AND(C0); NA(); OR(A0); ST(t2);
//			LD(B0); OR(C0); OR(D0); AND(t2); ST(t2);
//			LD(A0); AND(C0); AND(D0); NA(); OR(B0); AND(t2); ST(t2);
//			LD(A0); OR(C0); OR(D0); AND(t2); ST(SEG2);

//			LDC(B0); OR(A0); OR(D0); ST(t3);
//			LD(B0); AND(C0); NA(); OR(A0); AND(t3); ST(t3);
//			LDC(A0); OR(B0); OR(C0); OR(D0); AND(t3); ST(t3);
//			LD(A0); AND(C0); AND(D0); NA(); OR(B0); AND(t3);
//			AND(SEG0); ST(SEG3);

//			LD(A0); OR(D0); ST(t4);
//			LDC(C0); OR(A0); AND(t4); AND(B0); ST(SEG4);

//			LD(A0); OR(B0); ST(t5);
//			LDC(C0); OR(A0); OR(D0); AND(t5); ST(t5);
//			LDC(C0); OR(B0); OR(D0); AND(t5); ST(SEG5);

//			LD(B0); OR(C0); ST(t6);
//			LD(A0); OR(C0); OR(D0); AND(t6); ST(t6);
//			LD(A0); AND(D0); NA(); OR(B0); AND(t6); ST(SEG6);

//			// rotating HEllo UJorld
			//const int AB=47, BD=46, BNC=45, BNCD=44, ANC=43, NANB=42, NANBC=41, NANBD=40, NANBND=39,
			//		CND=38, NBCND=37, NCD=36, NBND=35;
//			LD(A0); AND(B0); ST(AB); LDC(D0); AND(C0); ST(CND); LD(A0); OR(B0); NA(); ST(NANB); AND(D0); ST(NANBD);
//			LDC(C0); AND(B0); ST(BNC); LDC(C0); AND(A0); ST(ANC); OR(BNC); OR(NANBD); OR(CND); OR(AB); ST(SEG1);

//			LDC(C0); AND(D0); ST(NCD); LD(NANB); AND(C0); ST(NANBC); LD(B0); OR(D0); NA(); ST(NBND); AND(C0);
//			OR(NANBC); OR(AB); OR(NCD); ST(SEG2);

//			LDC(C0); AND(B0); AND(D0); A2C(); LD(A0); AND(B0); OR2C(); C2A(); ST(SEG4);
//			LDC(C0); AND(B0); AND(D0); ST(SEG4); LD(A0); AND(B0); OR(SEG4); ST(SEG4);

//			SA(); ST(SEG3); SA(); ST(SEG4); SA(); ST(SEG5); SA(); ST(SEG6); 
//			ST(SEG1); ST(SEG2);
//			LD(A0); AND(B0); ST(AB); 
//			LD(B0); AND(D0); ST(BD);
//			LDC(C0); AND(B0); ST(BNC); AND(D0); ST(BNCD);
//			LDC(C0); AND(A0); ST(ANC);
//			LD(A0); OR(B0); NA(); ST(NANB); AND(C0); ST(NANBC);
//			LD(NANB); AND(D0); ST(NANBD);
//			LDC(D0); AND(NANB); ST(NANBND); NA(); OR(C0); ST(SEG0); // seg A = a+b+c+nd
//			LDC(D0); AND(C0); ST(CND);
//			LDC(B0); AND(CND); ST(NBCND);
//			LDC(A0); AND(C0); OR(BD); OR(CND); OR(AB); ST(SEG6); // seg G = nac+bd+cnd+ab
//			LDC(C0); AND(D0); OR(AB); OR(NANBC); OR(NBCND); ST(SEG2); // seg C = ncd+ab+nabc+nbcd
//			LD(A0); AND(D0); OR(BNC); OR(BD); OR(ANC); OR(AB); ST(SEG5); // seg F = bnc+bd+anc+ad+ab
//			LDC(C0); AND(A0); AND(D0); 
//			OR(NANBND); OR(NANBC); OR(BNCD); OR(AB); OR(NBCND); ST(SEG3); // seg D = nanbnd+nanbc+bncd+ancd+ab+nbcnd
//			LD(NANBD); OR(AB); OR(CND); OR(BNC); OR(ANC); ST(SEG1); // seg B = ab+cnd+nanbd+bnc+anc
//			LD(NBCND); OR(AB); ST(SEG4); // seg E = bncd+ab
			HLT();
		}

		private void listBox1_SelectedIndexChanged(object sender, System.EventArgs e)
		{
		}

		private void button1_Click(object sender, System.EventArgs e)
		{	// wirte assembled binary to Xilinx "RAMB16_S9 generic map(" initialization text
			FileInfo cvf = new FileInfo(@"C:\br\digilent_projs\d3_lem1_9min_hw\"+textBox2.Text+".xmt");
			StreamWriter stmw = cvf.CreateText();
			int nwds = IP;
			int nlines = (nwds+31)/32;
			int nplines = (nwds+255)/256;
			byte[] wds = new byte[nlines*32];
			byte[] pbits = new byte[nplines*256];
			for (int i=0; i<nwds; i++)
			{
				wds[i] = (byte)(mem[i] & 0xff);
				pbits[i] = (byte)(mem[i] >> 8 & 1);
			}
			for (int i=0; i<nlines; i++)	// write the 8-bit part
			{	stmw.Write("	INIT_{0:X2}  => X\"",i);
				for (int j=31; j>=0; j--) stmw.Write("{0:X2}",wds[i*32+j]);
				stmw.WriteLine("\",");
			}	
			for (int i=0; i<nplines; i++)	// write the parity-bit part
			{	stmw.Write("	INITP_{0:X2} => X\"",i);
				for (int j=63; j>=0; j--) stmw.Write("{0:X1}",
											  pbits[i*256+j*4+3]*8 + pbits[i*256+j*4+2]*4 +
											  pbits[i*256+j*4+1]*2 + pbits[i*256+j*4]);
				stmw.WriteLine((i == (nplines-1)) ? "\")" : "\",");
			}
			stmw.Close();
		}

		private void button2_Click(object sender, System.EventArgs e)
		{	int prog = listBox1.SelectedIndex;
			IP = 0;
			switch (prog)
			{	case 0: toggle(); break;
				case 1: cntr24(); break;
				case 2: HEllo_UJorld(); break;
			}
			string[] xx = new String[IP+1];
			xx[0] = listBox1.SelectedItem + " listing";
			for (int i=0; i<IP; i++) 
				xx[i+1] =  i.ToString("X3").PadLeft(3,'0') +
									 ": " + mem[i].ToString("X3").PadLeft(3,'0');
			textBox3.Lines = xx;
		}
	}
}
