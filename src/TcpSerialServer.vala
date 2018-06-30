/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Provides communications with an instrument using a TCP serial server
     */
    public class TcpSerialServer : SerialDevice
    {
        /**
         * The address of the TCP serial server
         */
        public string address
        {
            get;
            construct;
        }


        /**
         * The port number
         */
        public int port
        {
            get;
            construct;
        }


        /**
         * Initialize a new instance
         *
         * @param address
         * @param port
         */
        public TcpSerialServer(string address, uint16 port)
        {
            Object(
                address : address,
                port : port
                );
        }


        /**
         * {@inheritDoc}
         */
        public override void connect() throws CommunicationError
        {
            disconnect();

            var domain = Posix.AF_INET;

            m_fd = Posix.socket(
                domain,
                Posix.SOCK_STREAM,
                Posix.IPProto.TCP
                );

            if (m_fd < 0)
            {
                throw new CommunicationError.UNKNOWN(
                    @"Error connecting to server $(address):$(port) : $(strerror(errno))"
                    );
            }

            if (domain == Posix.AF_INET)
            {
                var socket_address = Posix.SockAddrIn()
                {
                    sin_family = Posix.AF_INET,
                    sin_port = Posix.htons((uint16)port),
                    sin_addr = Posix.InAddr()
                    {
                        s_addr = Posix.inet_addr(address)
                    }
                };

                var status = Posix.connect(
                    m_fd,
                    ref socket_address,
                    sizeof(Posix.SockAddrIn)
                    );

                if (status < 0)
                {
                    throw new CommunicationError.UNKNOWN(
                        @"Error connecting to server $(address):$(port) : $(strerror(errno))"
                        );
                }
            }
            else if (domain == Posix.AF_INET6)
            {
                var socket_address = Posix.SockAddrIn6()
                {
                    sin6_family = Posix.AF_INET6,
                    sin6_port = 0,
                    sin6_flowinfo = 0,
                    sin6_scope_id = 0
                };

                Posix.inet_pton(
                    Posix.AF_INET6,
                    "x:x:x:x:x:x:x:x",
                    socket_address.sin6_addr.s6_addr
                    );

                var status = Posix.connect(
                    m_fd,
                    socket_address,
                    sizeof(Posix.SockAddrIn6)
                    );

                if (status < 0)
                {
                    throw new CommunicationError.UNKNOWN(
                        @"Error connecting to server $(address):$(port) : $(strerror(errno))"
                        );
                }
            }
            else
            {
                throw new CommunicationError.UNKNOWN("Ouch 4");
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
        public override uint8[] receive_response(int length) throws CommunicationError
        {
            var buffer = new uint8[length];
            /* size_t count = 0;

            while (count < length)
            {
                var status = Posix.read(m_fd, &buffer[count], length - count);

                if (status < 0)
                {
                    var inner = Posix.strerror(Posix.errno) ?? @"$(Posix.errno)";

                    throw new InstrumentError.GENERIC(@"Error reading from socket: $(inner)\n");
                }

                if (status == 0)
                {
                    throw new InstrumentError.COMMUNICATION_TIMEOUT(@"Communication timeout socket");
                }

                count += status;
            } */

            return buffer;
        }


        /**
         * {@inheritDoc}
         */
        public override uint8[] receive_response_with_start(int length, uint8 start) throws CommunicationError
        {
            var buffer = new uint8[length];
            size_t count = 0;

            while (count < length)
            {
                var status = Posix.read(m_fd, &buffer[count], length - count);

                if (status < 0)
                {
                    var inner = Posix.strerror(Posix.errno) ?? @"$(Posix.errno)";

                    throw new CommunicationError.UNKNOWN(@"Error reading from socket: $(inner)\n");
                }

                if (status == 0)
                {
                    throw new CommunicationError.RESPONSE_TIMEOUT(@"Communication timeout socket");
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
        public override void send_command(uint8[] command) throws CommunicationError
        {
            var status = Posix.write(m_fd, command, command.length);

            if (status < 0)
            {
                var inner = Posix.strerror(Posix.errno) ?? @"$(Posix.errno)";

                throw new CommunicationError.UNKNOWN(@"Error writing to socket: $(inner)\n");
            }
        }


        /**
         * The file descriptor for the serial device
         *
         * If the value is negative, then the device is not open.
         */
        private int m_fd = -1;
    }
}
