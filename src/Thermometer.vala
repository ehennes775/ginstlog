/*
 *  Copyright (C) 2018 Edward Hennessy
 *
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License
 *  as published by the Free Software Foundation; either version 2
 *  of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
namespace ginstlog
{
    /**
     * Supports thermometers by an unknown OEM
     *
     * Models Supported
     * * B&K Precision Model 715
     */
    public class Thermometer : Instrument
    {
        /**
         *
         */
        public string name
        {
            get;
            private set;
            default = "B&K Precision 715";
        }


        /**
         *
         */
        public double t1
        {
            get;
            private set;
            default = 0.0;
        }


        /**
         *
         */
        public double t2
        {
            get;
            private set;
            default = 0.0;
        }


        /**
         * Construct the thermometer
         */
        public Thermometer() throws Error
        {
            Object(
                channel_count : 2
                );

            m_fd = Posix.open("/dev/ttyUSB0", Posix.O_RDWR | Posix.O_NOCTTY);

            if (m_fd == -1)
            {
                var inner = Posix.strerror(Posix.errno) ?? "$(Posix.errno)";

                throw new InstrumentError.GENERIC(@"Unable to open serial device: $(inner)\n");
            }

            if (!Posix.isatty(m_fd))
            {
                // throw
                stdout.printf("Error setting the serial device configuraion\n");
            }

            Posix.termios config;

            var status = Posix.tcgetattr(m_fd, out config);

            if (status < 0)
            {
                var inner = Posix.strerror(Posix.errno) ?? "$(Posix.errno)";

                throw new InstrumentError.GENERIC(@"Error getting the serial device configuraion: $(inner)\n");
            }

            config.c_iflag &= ~Posix.IGNBRK;
            config.c_iflag &= ~Posix.BRKINT;
            config.c_iflag &= ~Posix.ICRNL;
            config.c_iflag &= ~Posix.INLCR;
            config.c_iflag &= ~Posix.PARMRK;
            config.c_iflag &= ~Posix.INPCK;
            config.c_iflag &= ~Posix.ISTRIP;
            config.c_iflag &= ~Posix.IXON;


            config.c_lflag &= ~Posix.OCRNL;
            config.c_lflag &= ~Posix.ONLCR;
            config.c_lflag &= ~Posix.ONLRET;
            config.c_lflag &= ~Posix.ONOCR;
            //config.c_lflag &= ~Posix.ONOEOT;
            config.c_lflag &= ~Posix.OFILL;
            //config.c_lflag &= ~Posix.OLCUC;
            config.c_lflag &= ~Posix.OPOST;



            config.c_lflag &= ~Posix.ECHO;
            config.c_lflag &= ~Posix.ECHONL;
            config.c_lflag &= ~Posix.ICANON;
            config.c_lflag &= ~Posix.IEXTEN;
            config.c_lflag &= ~Posix.ISIG;


            status = Posix.cfsetispeed(ref config, SERIAL_SPEED);

            if (status < 0)
            {
                var inner = Posix.strerror(Posix.errno) ?? "$(Posix.errno)";

                throw new InstrumentError.GENERIC(@"Error setting the input baud rate: $(inner)\n");
            }

            status = Posix.cfsetospeed(ref config, SERIAL_SPEED);

            if (status < 0)
            {
                var inner = Posix.strerror(Posix.errno) ?? "$(Posix.errno)";

                throw new InstrumentError.GENERIC(@"Error setting the output baud rate: $(inner)\n");
            }

            config.c_cflag &= ~Posix.CSIZE;
            config.c_cflag |= SERIAL_SIZE;

            config.c_cflag &= ~ Posix.PARENB;


            config.c_cc[Posix.VMIN] = 0;
            config.c_cc[Posix.VTIME] = SERIAL_TIMEOUT;


            status = Posix.tcsetattr(m_fd, Posix.TCSAFLUSH, config);

            if (status < 0)
            {
                var inner = Posix.strerror(Posix.errno) ?? "$(Posix.errno)";

                throw new InstrumentError.GENERIC(@"Error setting the serial device configuraion: $(inner)\n");
            }

            Idle.add(
                () => { update(); return true; }
                );
        }


        /**
         *
         *
         *
         */
        ~Thermometer()
        {
            Posix.close(m_fd);
        }


		//public void change_units() throws Error
		//{
        //    send_command(CHANGE_UNITS_COMMAND);
		//}


		public void toggle_hold() throws Error
		{
            send_command(TOGGLE_HOLD_COMMAND);
		}


		public void toggle_time() throws Error
		{
            send_command(TOGGLE_TIME_COMMAND);
		}


		public void change_units() throws Error
		{
            send_command(CHANGE_UNITS_COMMAND);
		}


        /**
         *
         *
         *
         */
        public void update() throws Error
        {
            try
            {
                send_command(READ_COMMAND);

                var response = receive_response(10);

                if ((response[0] != 0x02) || (response[9] != 0x03))
                {
                    throw new InstrumentError.FRAMING_ERROR("Framing error\n");
                }

                var time_mode = ((response[1] & 0x08) == 0x08);

                if (!time_mode)
                {
                    var units = 0;

                    if ((response[2] & 0x01) == 0x01)
                    {
                        stdout.printf("Open loop T1 error\n");
                    }
                    else
                    {
                        var temp_t1 = (double) decode_bcd_string(response[3:5]);

                        if ((response[2] & 0x02) == 0x02)
                        {
                            temp_t1 = -temp_t1;
                        }

                        if ((response[2] & 0x04) == 0x00)
                        {
                            temp_t1 *= 0.1;
                        }

                        t1 = temp_t1;

                        var to1 = new Temperature(0, temp_t1);
                        update_readout(to1);
                    }

                    if ((response[2] & 0x08) == 0x08)
                    {
                        stdout.printf("Open loop T2 error\n");
                    }
                    else
                    {
                        var temp_t2 = (double) decode_bcd_string(response[7:9]);

                        if ((response[2] & 0x10) == 0x10)
                        {
                            temp_t2 = -temp_t2;
                        }

                        if ((response[2] & 0x20) == 0x00)
                        {
                            temp_t2 *= 0.1;
                        }

                        t2 = temp_t2;

                        var to2 = new Temperature(1, temp_t2);
                        update_readout(to2);
                    }
                }
            }
            catch (Error error)
            {
                stderr.printf("%s\n", error.message);
            }
        }

        private static uint8 BLANK_NIBBLE = 0x0B;

        /**
         *
         */
        private static const uint8[] CHANGE_UNITS_COMMAND = { 'C' };


        /**
         *
         */
        private static const uint8[] EXIT_MINMAX_COMMAND = { 'N' };


        /**
         *
         */
        private static const uint8[] READ_COMMAND = { 'A' };


        /**
         *
         */
        private static const uint8[] READ_ALL_MEMORY_COMMAND = { 'U' };


        /**
         *
         */
        private static const uint8[] READ_MODEL_COMMAND = { 'K' };


        /**
         *
         */
        private static const uint8[] READ_RECORDINGS_COMMAND = { 'P' };


        /**
         *
         */
        private static const uint8[] SELECT_MINMAX_COMMAND = { 'M' };


        /**
         *
         */
        private static const uint8[] TOGGLE_HOLD_COMMAND = { 'H' };


        /**
         *
         */
        private static const uint8[] TOGGLE_TIME_COMMAND = { 'T' };


        /**
         * The baud rate for this thermometer is fixed at 9600.
         */
        private static const Posix.speed_t SERIAL_SPEED = Posix.B9600;


        /**
         * The character size for this thermometer is fixed at 8 bits.
         */
        private static const Posix.tcflag_t SERIAL_SIZE = Posix.CS8;


        /**
         * The timeout waiting for a response in tenths of seconds.
         */
        private static const Posix.cc_t SERIAL_TIMEOUT = 20;


        /**
         * The file descriptor for the serial device
         */
        private int m_fd;


        /**
         * Decode both BCD digits in a byte
         *
         * The value 0x0B decodes to a "blank."
         *
         * @param byte The BCD byte to decode
         * @param allow Allow leading 'blank' values.
         * @return The value of byte [0,99].
         */
        private static int decode_bcd_byte(uint8 byte, ref bool allow) throws Error

            ensures (result >= 0)
            ensures (result <= 99)

        {
            var binary = 10 * decode_bcd_nibble(byte >> 4, allow);

            if (binary > 0)
            {
                allow = false;
            }

            binary += decode_bcd_nibble(byte, allow);

            return binary;
        }


        /**
         * Decode the BCD digit in the least significant nibble
         *
         * The value 0x0B decodes to a "blank." The blank provides a
         * mechanism to remove leading zeros on the display. If blanks
         * are allowed, then the value is treated as a 0. If blanks
         * are not allowed, an error occurs when a blank is encountered.
         *
         * @param byte The BCD nibble to decode
         * @param allow Allow a 'blank' value.
         * @return The value of the least significant nibble [0,9].
         * @throw InstrumentError.INVALID_DATA
         */
        private static int decode_bcd_nibble(uint8 byte, bool allow) throws Error

            ensures (result >= 0)
            ensures (result <= 9)

        {
            var nibble = byte & 0x0F;

            if (allow && (nibble == BLANK_NIBBLE))
            {
                nibble = 0x00;
            }

            if (nibble > 0x09)
            {
                throw new InstrumentError.INVALID_DATA("");
            }

            return nibble;
        }


        /**
         * Decode a sequence of BCD bytes
         *
         * Most significant bytes are first in the array.
         *
         * @param bytes The string of BCD bytes to decode
         * @return The binary equivalent of the BCD bytes
         */
        private static int decode_bcd_string(uint8[] bytes) throws Error

            ensures (result >= 0)

        {
            bool allow = true;
            int binary = 0;
            uint8 last_byte = 0x00;

            foreach (var byte in bytes)
            {
                last_byte = byte;

                binary *= 100;

                binary += decode_bcd_byte(byte, ref allow);
            }

            if ((last_byte & 0x0F) == BLANK_NIBBLE)
            {
                // throw an error
            }

            return binary;
        }


        /**
         * Receive a response from the thermometer
         *
         * @param size The size of the expected response in characters
         */
        private uint8[] receive_response(int length) throws Error

            ensures(result.length == length)

        {
            var buffer = new uint8[length];
            size_t count = 0;

            while (count < length)
            {
                var status = Posix.read(m_fd, &buffer[count], length - count);

                if (status < 0)
                {
                    var inner = Posix.strerror(Posix.errno) ?? "$(Posix.errno)";

                    throw new InstrumentError.GENERIC(@"Error reading from serial device: $(inner)\n");
                }

                if (status == 0)
                {
                    throw new InstrumentError.COMMUNICATION_TIMEOUT(@"Communication timeout");
                }

                count += status;
            }

            return buffer;
        }


        /**
         * Send a command to the thermometer
         *
         * @param command The command to send to the thermometer
         */
        private void send_command(uint8[] command) throws Error
        {
            //for (int code=-1; code >-100; code--)
           // {
           //   stdout.printf("%4d: %s\n", code, strerror(code));
            //}

            var status = Posix.write(m_fd, command, command.length);

            if (status < 0)
            {
                var inner = Posix.strerror(Posix.errno) ?? "$(Posix.errno)";

                throw new InstrumentError.GENERIC(@"Error writing to serial device: $(inner)\n");
            }
        }
    }
}
