namespace FAST_Rover_GUI
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.tBox = new System.Windows.Forms.TextBox();
            this.bConnect = new System.Windows.Forms.Button();
            this.bFindCom = new System.Windows.Forms.Button();
            this.cbComChooser = new System.Windows.Forms.ComboBox();
            this.tSteer = new System.Windows.Forms.TextBox();
            this.tThrottle = new System.Windows.Forms.TextBox();
            this.bNeutral = new System.Windows.Forms.Button();
            this.bArm = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.pictureBox2 = new System.Windows.Forms.PictureBox();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.timerHeartbeatReset = new System.Windows.Forms.Timer(this.components);
            this.barRSSI = new System.Windows.Forms.ProgressBar();
            this.timer10ms = new System.Windows.Forms.Timer(this.components);
            this.labelComStatus = new System.Windows.Forms.Label();
            this.timerComDropout = new System.Windows.Forms.Timer(this.components);
            this.pictureBox3 = new System.Windows.Forms.PictureBox();
            this.timer100ms = new System.Windows.Forms.Timer(this.components);
            this.scrollThrottle = new System.Windows.Forms.VScrollBar();
            this.scrollSteer = new System.Windows.Forms.HScrollBar();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox2)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox3)).BeginInit();
            this.SuspendLayout();
            // 
            // tBox
            // 
            this.tBox.Location = new System.Drawing.Point(647, 285);
            this.tBox.Multiline = true;
            this.tBox.Name = "tBox";
            this.tBox.Size = new System.Drawing.Size(352, 45);
            this.tBox.TabIndex = 1;
            // 
            // bConnect
            // 
            this.bConnect.Location = new System.Drawing.Point(232, 102);
            this.bConnect.Name = "bConnect";
            this.bConnect.Size = new System.Drawing.Size(137, 23);
            this.bConnect.TabIndex = 2;
            this.bConnect.Text = "Connect";
            this.bConnect.UseVisualStyleBackColor = true;
            this.bConnect.Click += new System.EventHandler(this.bConnect_Click);
            // 
            // bFindCom
            // 
            this.bFindCom.Location = new System.Drawing.Point(23, 103);
            this.bFindCom.Name = "bFindCom";
            this.bFindCom.Size = new System.Drawing.Size(75, 23);
            this.bFindCom.TabIndex = 4;
            this.bFindCom.Text = "Find COM";
            this.bFindCom.UseVisualStyleBackColor = true;
            this.bFindCom.Click += new System.EventHandler(this.bFindCom_Click);
            // 
            // cbComChooser
            // 
            this.cbComChooser.FormattingEnabled = true;
            this.cbComChooser.Location = new System.Drawing.Point(105, 104);
            this.cbComChooser.Name = "cbComChooser";
            this.cbComChooser.Size = new System.Drawing.Size(121, 21);
            this.cbComChooser.TabIndex = 5;
            // 
            // tSteer
            // 
            this.tSteer.Location = new System.Drawing.Point(217, 225);
            this.tSteer.Name = "tSteer";
            this.tSteer.Size = new System.Drawing.Size(61, 20);
            this.tSteer.TabIndex = 6;
            this.tSteer.Text = "128";
            this.tSteer.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // tThrottle
            // 
            this.tThrottle.Location = new System.Drawing.Point(1066, 188);
            this.tThrottle.Name = "tThrottle";
            this.tThrottle.Size = new System.Drawing.Size(60, 20);
            this.tThrottle.TabIndex = 7;
            this.tThrottle.Text = "128";
            this.tThrottle.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            // 
            // bNeutral
            // 
            this.bNeutral.Location = new System.Drawing.Point(232, 131);
            this.bNeutral.Name = "bNeutral";
            this.bNeutral.Size = new System.Drawing.Size(137, 80);
            this.bNeutral.TabIndex = 8;
            this.bNeutral.Text = "Neutral";
            this.bNeutral.UseVisualStyleBackColor = true;
            this.bNeutral.Click += new System.EventHandler(this.bNeutral_Click);
            // 
            // bArm
            // 
            this.bArm.Location = new System.Drawing.Point(23, 131);
            this.bArm.Name = "bArm";
            this.bArm.Size = new System.Drawing.Size(203, 80);
            this.bArm.TabIndex = 9;
            this.bArm.Text = "Arm";
            this.bArm.UseVisualStyleBackColor = true;
            this.bArm.Click += new System.EventHandler(this.bArm_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(644, 338);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(162, 13);
            this.label1.TabIndex = 10;
            this.label1.Text = "646002_FAST Robot Shield GUI";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(644, 354);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(101, 13);
            this.label2.TabIndex = 11;
            this.label2.Text = "3-AUG-2014 REV A";
            // 
            // pictureBox1
            // 
            this.pictureBox1.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("pictureBox1.BackgroundImage")));
            this.pictureBox1.Location = new System.Drawing.Point(12, 12);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(619, 77);
            this.pictureBox1.TabIndex = 12;
            this.pictureBox1.TabStop = false;
            // 
            // pictureBox2
            // 
            this.pictureBox2.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("pictureBox2.BackgroundImage")));
            this.pictureBox2.Location = new System.Drawing.Point(818, 9);
            this.pictureBox2.Name = "pictureBox2";
            this.pictureBox2.Size = new System.Drawing.Size(181, 155);
            this.pictureBox2.TabIndex = 13;
            this.pictureBox2.TabStop = false;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(210, 354);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(68, 20);
            this.label3.TabIndex = 14;
            this.label3.Text = "STEER";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label4.Location = new System.Drawing.Point(1039, 135);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(100, 20);
            this.label4.TabIndex = 15;
            this.label4.Text = "THROTTLE";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(1079, 165);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(45, 13);
            this.label5.TabIndex = 16;
            this.label5.Text = "Forward";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(1079, 223);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(47, 13);
            this.label6.TabIndex = 17;
            this.label6.Text = "Reverse";
            // 
            // timerHeartbeatReset
            // 
            this.timerHeartbeatReset.Interval = 1000;
            this.timerHeartbeatReset.Tick += new System.EventHandler(this.timerHeartbeatReset_Tick);
            // 
            // barRSSI
            // 
            this.barRSSI.Location = new System.Drawing.Point(747, 235);
            this.barRSSI.Name = "barRSSI";
            this.barRSSI.Size = new System.Drawing.Size(252, 23);
            this.barRSSI.TabIndex = 18;
            // 
            // timer10ms
            // 
            this.timer10ms.Enabled = true;
            this.timer10ms.Interval = 10;
            this.timer10ms.Tick += new System.EventHandler(this.timer10ms_Tick);
            // 
            // labelComStatus
            // 
            this.labelComStatus.AutoSize = true;
            this.labelComStatus.Location = new System.Drawing.Point(644, 241);
            this.labelComStatus.Name = "labelComStatus";
            this.labelComStatus.Size = new System.Drawing.Size(85, 13);
            this.labelComStatus.TabIndex = 19;
            this.labelComStatus.Text = "Missed Packets:";
            // 
            // timerComDropout
            // 
            this.timerComDropout.Interval = 1000;
            this.timerComDropout.Tick += new System.EventHandler(this.timerComDropout_Tick);
            // 
            // pictureBox3
            // 
            this.pictureBox3.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("pictureBox3.BackgroundImage")));
            this.pictureBox3.Location = new System.Drawing.Point(653, 9);
            this.pictureBox3.Name = "pictureBox3";
            this.pictureBox3.Size = new System.Drawing.Size(152, 101);
            this.pictureBox3.TabIndex = 20;
            this.pictureBox3.TabStop = false;
            // 
            // timer100ms
            // 
            this.timer100ms.Enabled = true;
            this.timer100ms.Tick += new System.EventHandler(this.timer100ms_Tick);
            // 
            // scrollThrottle
            // 
            this.scrollThrottle.LargeChange = 5;
            this.scrollThrottle.Location = new System.Drawing.Point(1142, 12);
            this.scrollThrottle.Maximum = 160;
            this.scrollThrottle.Minimum = 100;
            this.scrollThrottle.Name = "scrollThrottle";
            this.scrollThrottle.Size = new System.Drawing.Size(162, 365);
            this.scrollThrottle.TabIndex = 35;
            this.scrollThrottle.TabStop = true;
            this.scrollThrottle.Value = 128;
            this.scrollThrottle.Scroll += new System.Windows.Forms.ScrollEventHandler(this.scrollThrottle_Scroll);
            // 
            // scrollSteer
            // 
            this.scrollSteer.Location = new System.Drawing.Point(12, 248);
            this.scrollSteer.Maximum = 255;
            this.scrollSteer.Name = "scrollSteer";
            this.scrollSteer.Size = new System.Drawing.Size(470, 92);
            this.scrollSteer.TabIndex = 36;
            this.scrollSteer.Value = 128;
            this.scrollSteer.Scroll += new System.Windows.Forms.ScrollEventHandler(this.scrollSteer_Scroll);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.ControlLight;
            this.ClientSize = new System.Drawing.Size(1313, 386);
            this.Controls.Add(this.scrollSteer);
            this.Controls.Add(this.scrollThrottle);
            this.Controls.Add(this.pictureBox3);
            this.Controls.Add(this.labelComStatus);
            this.Controls.Add(this.barRSSI);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.pictureBox2);
            this.Controls.Add(this.pictureBox1);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.bArm);
            this.Controls.Add(this.bNeutral);
            this.Controls.Add(this.tThrottle);
            this.Controls.Add(this.tSteer);
            this.Controls.Add(this.cbComChooser);
            this.Controls.Add(this.bFindCom);
            this.Controls.Add(this.bConnect);
            this.Controls.Add(this.tBox);
            this.Name = "Form1";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "FAST Robotics Robot Shield Demo GUI";
            this.Load += new System.EventHandler(this.Form1_Load);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox2)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox3)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox tBox;
        private System.Windows.Forms.Button bConnect;
        private System.Windows.Forms.Button bFindCom;
        private System.Windows.Forms.ComboBox cbComChooser;
        private System.Windows.Forms.TextBox tSteer;
        private System.Windows.Forms.TextBox tThrottle;
        private System.Windows.Forms.Button bNeutral;
        private System.Windows.Forms.Button bArm;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.PictureBox pictureBox2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Timer timerHeartbeatReset;
        private System.Windows.Forms.ProgressBar barRSSI;
        private System.Windows.Forms.Timer timer10ms;
        private System.Windows.Forms.Label labelComStatus;
        private System.Windows.Forms.Timer timerComDropout;
        private System.Windows.Forms.PictureBox pictureBox3;
        private System.Windows.Forms.Timer timer100ms;
        private System.Windows.Forms.VScrollBar scrollThrottle;
        private System.Windows.Forms.HScrollBar scrollSteer;
    }
}

