/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Provides TTY serial communications with an instrument
     */
    public class TtySerialDevice : SerialDevice
    {
        /**
         * The absolute path to the device file (e.g. /dev/ttyUSB0)
         */
        public string device_file
        {
            get;
            construct;
        }


        /**
         *
         */
        public string timeout
        {
            get;
            construct;
        }


        /**
         * Initialize a new serial device
         *
         * @param device_file The absolute path to the device file
         * @param timeout
         */
        public TtySerialDevice(string device_file, string timeout)
        {
            Object(
                device_file : device_file,
                timeout : timeout
                );
        }


        /**
         * Disconnects, if needed.
         */
        ~TtySerialDevice()
        {
            disconnect();
        }


        /**
         * {@inheritDoc}
         */
        public override void connect()
        {
            disconnect();

            m_fd = Posix.open(device_file, Posix.O_RDWR | Posix.O_NOCTTY);

            if (m_fd < 0)
            {
                var inner = Posix.strerror(Posix.errno) ?? @"$(Posix.errno)";

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
                var inner = Posix.strerror(Posix.errno) ?? @"$(Posix.errno)";

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
                var inner = Posix.strerror(Posix.errno) ?? @"$(Posix.errno)";

                throw new InstrumentError.GENERIC(@"Error setting the input baud rate: $(inner)\n");
            }

            status = Posix.cfsetospeed(ref config, SERIAL_SPEED);

            if (status < 0)
            {
                var inner = Posix.strerror(Posix.errno) ?? @"$(Posix.errno)";

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
                var inner = Posix.strerror(Posix.errno) ?? @"$(Posix.errno)";

                throw new InstrumentError.GENERIC(@"Error setting the serial device configuraion: $(inner)\n");
            }
        }


        /**
         * {@inheritDoc}
         */
        public override void disconnect()
        {
            if (m_fd >= 0)
            {
                Posix.close(m_fd);
                m_fd = -1;
            }
        }


        /**
         * {@inheritDoc}
         */
        public override uint8[] receive_response(int length) throws Error

            requires(m_fd >= 0)
            ensures(result.length == length)

        {
            var buffer = new uint8[length];
            size_t count = 0;

            while (count < length)
            {
                var status = Posix.read(m_fd, &buffer[count], length - count);

                if (status < 0)
                {
                    var inner = Posix.strerror(Posix.errno) ?? @"$(Posix.errno)";

                    throw new InstrumentError.GENERIC(
                        @"Error reading from $(device_file): $(inner)\n"
                        );
                }

                if (status == 0)
                {
                    throw new CommunicationError.RESPONSE_TIMEOUT(
                        @"Communication timeout on $(device_file)"
                        );
                }

                count += status;
            }

            return buffer;
        }


        /**
         * {@inheritDoc}
         */
        public override uint8[] receive_response_with_start(int length, uint8 start) throws Error

            requires(m_fd >= 0)
            ensures(result.length == length)

        {
            var buffer = new uint8[length];
            size_t count = 0;

            while (count < length)
            {
                var status = Posix.read(m_fd, &buffer[count], length - count);

                if (status < 0)
                {
                    var inner = Posix.strerror(Posix.errno) ?? @"$(Posix.errno)";

                    throw new InstrumentError.GENERIC(
                        @"Error reading from $(device_file): $(inner)\n"
                        );
                }

                if (status == 0)
                {
                    throw new CommunicationError.RESPONSE_TIMEOUT(
                        @"Communication timeout on $(device_file)"
                        );
                }

                count += status;

                var first_byte = (uint8*) Posix.memchr(&buffer[0], start, count);

                if (first_byte == null)
                {
                    count = 0;
                }
                else
                {
                    count -= first_byte - &buffer[0];

                    Posix.memmove(&buffer[0], first_byte, count);
                }
            }

            return buffer;
        }


        /**
         * {@inheritDoc}
         */
        public override void send_command(uint8[] command) throws Error

            requires(m_fd >= 0)

        {
            //var status = Posix.tcflush(m_fd, Posix.TCIFLUSH);

            //if (status < 0)
            //{
            //    var inner = Posix.strerror(Posix.errno) ?? @"$(Posix.errno)";

            //    throw new InstrumentError.GENERIC(@"Error writing to $(device_file): $(inner)\n");
            //}

            var status = Posix.write(m_fd, command, command.length);

            if (status < 0)
            {
                var inner = Posix.strerror(Posix.errno) ?? @"$(Posix.errno)";

                throw new InstrumentError.GENERIC(@"Error writing to $(device_file): $(inner)\n");
            }
        }


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
         *
         * If the value is negative, then the device is not open.
         */
        private int m_fd = -1;
    }
}
