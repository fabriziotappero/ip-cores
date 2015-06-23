namespace XumBootloader_GUI
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.label1 = new System.Windows.Forms.Label();
            this.serialPortSelect = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.baudRateSelect = new System.Windows.Forms.ComboBox();
            this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            this.selectFile = new System.Windows.Forms.Button();
            this.label3 = new System.Windows.Forms.Label();
            this.labelFilename = new System.Windows.Forms.Label();
            this.labelSize = new System.Windows.Forms.Label();
            this.Send = new System.Windows.Forms.Label();
            this.sendButton = new System.Windows.Forms.Button();
            this.serialPort1 = new System.IO.Ports.SerialPort(this.components);
            this.label4 = new System.Windows.Forms.Label();
            this.setOffset = new System.Windows.Forms.TextBox();
            this.labelSuccess = new System.Windows.Forms.Label();
            this.progressBar1 = new System.Windows.Forms.ProgressBar();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(13, 13);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(55, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Serial Port";
            // 
            // serialPortSelect
            // 
            this.serialPortSelect.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.serialPortSelect.FormattingEnabled = true;
            this.serialPortSelect.Location = new System.Drawing.Point(16, 30);
            this.serialPortSelect.Name = "serialPortSelect";
            this.serialPortSelect.Size = new System.Drawing.Size(74, 21);
            this.serialPortSelect.TabIndex = 1;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(104, 13);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(58, 13);
            this.label2.TabIndex = 2;
            this.label2.Text = "Baud Rate";
            // 
            // baudRateSelect
            // 
            this.baudRateSelect.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.baudRateSelect.FormattingEnabled = true;
            this.baudRateSelect.Items.AddRange(new object[] {
            "110",
            "300",
            "1200",
            "2400",
            "4800",
            "9600",
            "19200",
            "38400",
            "57600",
            "115200",
            "230400",
            "460800",
            "921600"});
            this.baudRateSelect.Location = new System.Drawing.Point(107, 30);
            this.baudRateSelect.Name = "baudRateSelect";
            this.baudRateSelect.Size = new System.Drawing.Size(89, 21);
            this.baudRateSelect.TabIndex = 3;
            // 
            // selectFile
            // 
            this.selectFile.Location = new System.Drawing.Point(211, 30);
            this.selectFile.Name = "selectFile";
            this.selectFile.Size = new System.Drawing.Size(53, 23);
            this.selectFile.TabIndex = 4;
            this.selectFile.Text = "Open...";
            this.selectFile.UseVisualStyleBackColor = true;
            this.selectFile.Click += new System.EventHandler(this.selectFile_Click);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(208, 13);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(56, 13);
            this.label3.TabIndex = 5;
            this.label3.Text = "Select File";
            // 
            // labelFilename
            // 
            this.labelFilename.AutoSize = true;
            this.labelFilename.Location = new System.Drawing.Point(16, 67);
            this.labelFilename.Name = "labelFilename";
            this.labelFilename.Size = new System.Drawing.Size(85, 13);
            this.labelFilename.TabIndex = 6;
            this.labelFilename.Text = "No File Selected";
            // 
            // labelSize
            // 
            this.labelSize.AutoSize = true;
            this.labelSize.Location = new System.Drawing.Point(16, 86);
            this.labelSize.Name = "labelSize";
            this.labelSize.Size = new System.Drawing.Size(27, 13);
            this.labelSize.TabIndex = 7;
            this.labelSize.Text = "Size";
            // 
            // Send
            // 
            this.Send.AutoSize = true;
            this.Send.Location = new System.Drawing.Point(349, 13);
            this.Send.Name = "Send";
            this.Send.Size = new System.Drawing.Size(32, 13);
            this.Send.TabIndex = 8;
            this.Send.Text = "Do it!";
            // 
            // sendButton
            // 
            this.sendButton.Location = new System.Drawing.Point(352, 30);
            this.sendButton.Name = "sendButton";
            this.sendButton.Size = new System.Drawing.Size(75, 23);
            this.sendButton.TabIndex = 9;
            this.sendButton.Text = "Send";
            this.sendButton.UseVisualStyleBackColor = true;
            this.sendButton.Click += new System.EventHandler(this.sendButton_Click);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(276, 13);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(35, 13);
            this.label4.TabIndex = 10;
            this.label4.Text = "Offset";
            // 
            // setOffset
            // 
            this.setOffset.Location = new System.Drawing.Point(279, 32);
            this.setOffset.Name = "setOffset";
            this.setOffset.Size = new System.Drawing.Size(58, 20);
            this.setOffset.TabIndex = 11;
            this.setOffset.Text = "0";
            this.setOffset.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            // 
            // labelSuccess
            // 
            this.labelSuccess.AutoSize = true;
            this.labelSuccess.Location = new System.Drawing.Point(16, 105);
            this.labelSuccess.Name = "labelSuccess";
            this.labelSuccess.Size = new System.Drawing.Size(48, 13);
            this.labelSuccess.TabIndex = 12;
            this.labelSuccess.Text = "Success";
            // 
            // progressBar1
            // 
            this.progressBar1.Location = new System.Drawing.Point(352, 105);
            this.progressBar1.Name = "progressBar1";
            this.progressBar1.Size = new System.Drawing.Size(75, 13);
            this.progressBar1.TabIndex = 13;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(444, 131);
            this.Controls.Add(this.progressBar1);
            this.Controls.Add(this.labelSuccess);
            this.Controls.Add(this.setOffset);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.sendButton);
            this.Controls.Add(this.Send);
            this.Controls.Add(this.labelSize);
            this.Controls.Add(this.labelFilename);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.selectFile);
            this.Controls.Add(this.baudRateSelect);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.serialPortSelect);
            this.Controls.Add(this.label1);
            this.Name = "Form1";
            this.Text = "XUM Bootloader";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox serialPortSelect;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ComboBox baudRateSelect;
        private System.Windows.Forms.OpenFileDialog openFileDialog1;
        private System.Windows.Forms.Button selectFile;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label labelFilename;
        private System.Windows.Forms.Label labelSize;
        private System.Windows.Forms.Label Send;
        private System.Windows.Forms.Button sendButton;
        private System.IO.Ports.SerialPort serialPort1;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.TextBox setOffset;
        private System.Windows.Forms.Label labelSuccess;
        private System.Windows.Forms.ProgressBar progressBar1;
    }
}

