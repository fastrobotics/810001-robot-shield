using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.IO.Ports;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace FAST_Rover_GUI
{
    public partial class Form1 : Form
    {
        public delegate void AddDataDelegate(String myString);
        public AddDataDelegate myDelegate;
        private Queue<byte> recievedData = new Queue<byte>();
        public Form1()
        {
            InitializeComponent();
        }

        private void scrollSteer_Scroll(object sender, ScrollEventArgs e)
        {
            Variables.steer = scrollSteer.Value;
            tSteer.Text = System.Convert.ToString(Variables.steer);
            send_fast_message(FAST_Definitions.ACTUATOR_MESSAGE);
        }
        private void scrollThrottle_Scroll(object sender, ScrollEventArgs e)
        {
            Variables.throttle = scrollThrottle.Value;
            tThrottle.Text = System.Convert.ToString(Variables.throttle);
            send_fast_message(FAST_Definitions.ACTUATOR_MESSAGE);
        }

        private void bNeutral_Click(object sender, EventArgs e)
        {
            tThrottle.Text = "128";
            tSteer.Text = "128";
            Variables.throttle = 128;
            Variables.steer = 128;
            scrollSteer.Value = 128;
            scrollThrottle.Value = 128;
            send_fast_message(FAST_Definitions.ACTUATOR_MESSAGE);
        }
        private void send_fast_message(int mode)
        {
            if (Variables.myserialport != null)
            {
                if (Variables.myserialport.IsOpen)
                {
                    if (mode == FAST_Definitions.ACTUATOR_MESSAGE)
                    {
                        byte[] write_bytes = new byte[8];
                        write_bytes[0] = FAST_Definitions.SD;
                        write_bytes[1] = 0x05;
                        write_bytes[2] = Message_Types.ACTUATOR;
                        write_bytes[3] = SubMessage_Types.GENERAL;
                        write_bytes[4] = Value_Types.INT_2;
                        write_bytes[5] = (byte)Variables.steer;
                        write_bytes[6] = (byte)Variables.throttle;
                        write_bytes[7] = FAST_Definitions.ED;
                        Variables.myserialport.Write(write_bytes, 0, 8);
                    }
                    else if (mode == FAST_Definitions.ARM_MESSAGE)
                    {
                        byte[] write_bytes = new byte[7];
                        write_bytes[0] = FAST_Definitions.SD;
                        write_bytes[1] = 0x04;
                        write_bytes[2] = Message_Types.ARMED;
                        write_bytes[3] = SubMessage_Types.GENERAL;
                        write_bytes[4] = Value_Types.INT_1;
                        if (Variables.armed == 1) { write_bytes[5] = Values.ARMED; }
                        else { write_bytes[5] = Values.DISARMED; }
                        write_bytes[6] = FAST_Definitions.ED;
                        Variables.myserialport.Write(write_bytes, 0, 7);
                    }
                    else if (mode == FAST_Definitions.HEARTBEAT_MESSAGE)
                    {


                        Variables.heartbeatout_counter++;
                        if (Variables.heartbeatout_counter > 255) { Variables.heartbeatout_counter = 1; }
                        byte[] write_bytes = new byte[7];
                        write_bytes[0] = FAST_Definitions.SD;
                        write_bytes[1] = 0x04;
                        write_bytes[2] = Message_Types.HEARTBEAT;
                        write_bytes[3] = SubMessage_Types.GENERAL;
                        write_bytes[4] = Value_Types.INT_1;
                        write_bytes[5] = (byte)Variables.heartbeatout_counter;
                        write_bytes[6] = FAST_Definitions.ED;
                        Variables.myserialport.Write(write_bytes, 0, 7);


                    }
                }
            }
        }
        private void process_fast_message()
        {
            if (Variables.read_packet[0] == Message_Types.HEARTBEAT)
            {
                if (Variables.read_packet[1] == SubMessage_Types.GENERAL)
                {
                    if (Variables.read_packet[2] == Value_Types.INT_1)
                    {
                        int lastbeat = Variables.heartbeatin_counter;
                        
                        Variables.heartbeatin_counter = Variables.read_packet[3];
                        if (Variables.heartbeatin_counter == 0)
                        {
                            Variables.heartbeatin_skipped += Variables.heartbeatin_counter - lastbeat - 1 + 256;
                        }
                        else
                        {
                            Variables.heartbeatin_skipped += Variables.heartbeatin_counter - lastbeat - 1;
                        }
                        
                    }
                }

            }
        }
        private void bConnect_Click(object sender, EventArgs e)
        {
            try
            {
                string portstr = cbComChooser.Text;
                tBox.Text = portstr;
                Variables.myserialport = new SerialPort(portstr);
               
                //mySerialPort = new SerialPort(portstr);
                if (Variables.myserialport.IsOpen)
                {
                    Variables.myserialport.Close();
                }
                Variables.myserialport.BaudRate = 9600;
                Variables.myserialport.Parity = Parity.None;
                Variables.myserialport.StopBits = StopBits.One;
                Variables.myserialport.DataBits = 8;
                Variables.myserialport.Handshake = Handshake.None;
                Variables.myserialport.DataReceived += new SerialDataReceivedEventHandler(DataReceivedHandler);
                Variables.myserialport.Open();
                /*
                byte[] write_bytes = new byte[7];
                while (true)
                {
                    write_bytes[0] = FAST_Definitions.SD;
                    write_bytes[1] = 0x04;
                    write_bytes[2] = Message_Types.ERROR;
                    write_bytes[3] = SubMessage_Types.NO_ERROR;
                    write_bytes[4] = Value_Types.INT_1;
                    write_bytes[5] = (byte)123;
                    write_bytes[6] = FAST_Definitions.ED;
                    mySerialPort.Write(write_bytes, 0, 7);
                }
                 * */
               
            }
            catch (Exception exc)
            {
                tBox.Text = exc.Message;
                Variables.myserialport.Close();
            }
            
                

            

        }

        private void bFindCom_Click(object sender, EventArgs e)
        {
            cbComChooser.Items.Clear();
            string[] ports = SerialPort.GetPortNames();
            foreach(string port in ports)
            {
                cbComChooser.Items.Add(port);
            }
            cbComChooser.Text = ports[0];
        }
        private void DataReceivedHandler(
                        object sender,
                        SerialDataReceivedEventArgs e)
        {
            int read_byte = 0;
            
            int length = 0;
            SerialPort sp = (SerialPort)sender;

            
            read_byte = sp.ReadByte();
            if (read_byte == FAST_Definitions.SD)
            {
                read_byte = sp.ReadByte();
                length = read_byte;
                int[] read_bytes = new int[length];
                for (int i = 0; i < length; i ++ )
                {
                    read_bytes[i] = sp.ReadByte();
                }
                read_byte = sp.ReadByte();
                if (read_byte == FAST_Definitions.ED)//I can process this packet
                {
                    Variables.read_packet = read_bytes;
                    process_fast_message();
                    timerComDropout.Enabled = false;
                    tBox.Invoke(this.myDelegate, "COM OK");
                }
                    //sp.Read(Variables.read_data, 0, length);
 
            }
            else
            {
                tBox.Invoke(this.myDelegate, "0");
            }
            //Variables.read_data = System.Convert.ToString(Variables.read_byte);
            //tBox.Invoke(this.myDelegate, Variables.read_data);  
            //Variables.read_data = sp.ReadLine();
            
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            this.myDelegate = new AddDataDelegate(AddDataMethod);
            timerHeartbeatReset.Enabled = true;
            barRSSI.ForeColor = Color.Red;
            scrollSteer.Value = 128;
            scrollThrottle.Value = 128;
        }
        public void AddDataMethod(String myString)
        {
            tBox.Text = myString;
        }

        

        private void bArm_Click(object sender, EventArgs e)
        {
            tThrottle.Text = "128";
            tSteer.Text = "128";
            Variables.throttle = 128;
            Variables.steer = 128;
            if (Variables.armed==0)
            {
                Variables.armed = 1;
                bArm.Text = "Disarm";
            }
            else
            {
                Variables.armed = 0;
                bArm.Text = "Arm";
            }
            send_fast_message(FAST_Definitions.ARM_MESSAGE);
        }

        private void timerHeartbeatReset_Tick(object sender, EventArgs e)
        {
            Variables.heartbeatin_skipped = 0;
        }

        private void timer10ms_Tick(object sender, EventArgs e)
        {
            send_fast_message(FAST_Definitions.HEARTBEAT_MESSAGE);
            timerComDropout.Enabled = true;
            if (Variables.heartbeatin_skipped > barRSSI.Maximum)
            {
                barRSSI.Value = barRSSI.Maximum;
            }
            else if(Variables.heartbeatin_skipped < barRSSI.Minimum)
            {
                barRSSI.Value = barRSSI.Minimum;
            }
            else
            {
                barRSSI.Value = Variables.heartbeatin_skipped;
            }
        }

        private void timerComDropout_Tick(object sender, EventArgs e)
        {
            tBox.Invoke(this.myDelegate, "COM DROPOUT");
        }

        private void timer100ms_Tick(object sender, EventArgs e)
        {
            
        }





        



        
    }
	
}
/*
 string line = mySerialPort.ReadLine();
                while (line.Length > 0)
                {
                    line = mySerialPort.ReadLine();
                    tBox.Text = line;

                }
 * 
public delegate void AddDataDelegate(String myString);
public AddDataDelegate myDelegate;

private void Form1_Load(object sender, EventArgs e)
{
    //...
    this.myDelegate = new AddDataDelegate(AddDataMethod);
}

public void AddDataMethod(String myString)
{
    textbox1.AppendText(myString);
}

private void mySerialPort_DataReceived(object sender, SerialDataReceivedEventArgs e)
{
   SerialPort sp = (SerialPort)sender;
   string s= sp.ReadExisting();

   textbox1.Invoke(this.myDelegate, new Object[] {s});       
}
*/