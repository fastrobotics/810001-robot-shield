using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO.Ports;

namespace FAST_Rover_GUI
{
    class Variables
    {
        public static int[] read_packet;
        public static int throttle = 128;
        public static int steer = 128;
        public static int armed = 0;
        public static SerialPort myserialport;
        public static int heartbeatin_counter = 0;
        public static int heartbeatin_skipped = 0;
        public static int heartbeatout_counter = 1;
        public static int RSSI = 0;

    }
    class FAST_Definitions
    {
        public static byte SD = 0x24;
        public static byte ED = 0x2A;
        public static int ACTUATOR_MESSAGE = 1;
        public static int ARM_MESSAGE = 2;
        public static int HEARTBEAT_MESSAGE = 3;

    }
    class Message_Types
    {
        public static byte ERROR = 0x01;
        public static byte ACTUATOR = 0x02;
        public static byte ARMED = 0x03;
        public static byte HEARTBEAT = 0x04;
    }
    class SubMessage_Types
    {
        public static byte NO_ERROR = 0x01;
        public static byte GENERAL = 0x01;
    }
    class Value_Types
    {
        public static byte NO_DATA = 0xFF;
        public static byte INT_1 = 0x01;
        public static byte INT_2 = 0x02;
    }
    class Values
    {
        public static byte ARMED = 0x01;
        public static byte DISARMED = 0x02;
    }

}
