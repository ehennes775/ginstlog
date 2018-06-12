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
         * {@inheritDoc}
         */
        public override void connect()
        {
            disconnect();

            var domain = Posix.AF_INET;

            m_fd = Posix.socket(
                domain,
                Posix.SOCK_STREAM,
                0
                );

            if (m_fd < 0)
            {

            }

            if (domain == Posix.AF_INET)
            {
                var socket_address = Posix.SockAddrIn()
                {
                    sin_family = Posix.AF_INET,
                    sin_port = 0,
                    sin_addr = Posix.InAddr()
                    {
                        s_addr = Posix.inet_addr("127.0.0.1")
                    }
                };

                var status = Posix.connect(
                    m_fd,
                    socket_address,
                    sizeof(Posix.SockAddrIn)
                    );

                if (status < 0)
                {

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

                }
            }
            else
            {

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
        {
            var buffer = new uint8[length];
            size_t count = 0;

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
            }

            return buffer;
        }


        /**
         * {@inheritDoc}
         */
        public override void send_command(uint8[] command) throws Error
        {
            var status = Posix.write(m_fd, command, command.length);

            if (status < 0)
            {
                var inner = Posix.strerror(Posix.errno) ?? @"$(Posix.errno)";

                throw new InstrumentError.GENERIC(@"Error writing to socket: $(inner)\n");
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
