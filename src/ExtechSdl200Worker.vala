/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Background and thread for instruments
     *
     * || ''Manufacturer'' || ''Model'' || ''Notes'' ||
     */
    public class ExtechSdl200Worker : Thermometer3xxWorker
    {
        /**
         * When a name is not provided in the configuration file
         */
        public const string DEFAULT_NAME = "Instrument";


        /**
         * Initialize a new instance
         */
        public ExtechSdl200Worker(
            Channel[] channel,
            ulong interval,
            string? name,
            SerialDevice serial_device
            )
        {
            Object(
                channel_count : channel.length,
                name : name ?? DEFAULT_NAME
                );

            if (channel_count < 1)
            {
                throw new ConfigurationError.CHANNEL_REQUIRED(
                    @"At least one channel required, $(channel_count) given"
                    );
            }

            m_channel = channel;
            m_interval = interval;
            m_queue = new AsyncQueue<Measurement>();
            m_serial_device = serial_device;
            AtomicInt.set(ref m_stop, 0);
        }


        /**
         * {@inheritDoc}
         */
        public override void start()
        {
            Idle.add(poll_measurement);

            m_thread = new Thread<int>(
                @"Thread.$(name)",
                read_measurements
                );

            m_serial_device.connect();
        }


        /**
         * {@inheritDoc}
         */
        public override void stop()
        {
            AtomicInt.set(ref m_stop, 1);
            Idle.remove_by_data(this);
        }


        /**
         * The length of a message containing one measurement
         */
        private const int MESSAGE_LENGTH = 16;


        /**
         *
         */
        private Channel[] m_channel;


        /**
         * The interval to wait between polls, in microseconds
         */
        private ulong m_interval;


        /**
         * The name of the instrument
         */
        private string m_name;


        /**
         * The serial device to communicate with the instrument
         */
        private SerialDevice m_serial_device;


        /**
         *
         */
        private AsyncQueue<Measurement> m_queue;


        private int m_stop;


        /**
         *
         */
        private Thread<int> m_thread;


        /**
         * Read measurements from the instrument
         *
         * @return A dummy value
         */
        private int read_measurements()
        {
            while (AtomicInt.get(ref m_stop) == 0)
            {
                Thread.usleep(m_interval);

                try
                {
                    var measurements = receive_measurements();

                    foreach (var measurement in measurements)
                    {
                        m_queue.push(measurement);
                    }
                }
                catch (Error error)
                {
                    stderr.printf(@"$(error.message)\n");
                }

            }

            return 0;
        }


        /**
         * Poll for recent measurements
         *
         * Called by the GUI thread to check if another measurement is
         * available.
         *
         * @return
         */
        private bool poll_measurement()
        {
            var measurement = m_queue.try_pop();

            if (measurement != null)
            {
                update_readout(measurement);
            }

            return Source.CONTINUE;
        }


        /**
         * Decode a single measurement from the instrument
         *
         * @param bytes The response containing the measurement
         * @return The decoded measurement
         */
        private Measurement decode_measurement(uint8[] bytes) throws Error
        {
            if (bytes.length != MESSAGE_LENGTH)
            {
                throw new CommunicationError.MESSAGE_LENGTH(
                    @"$(name) recieved a response with an incorrect message length of $(bytes.length), but expected $(MESSAGE_LENGTH)"
                    );
            }

            if ((bytes[0] != 0x00) || (bytes[-1] != 0x00))
            {
                throw new CommunicationError.FRAMING_ERROR(
                    @"$(name): Framing error"
                    );
            }

            var builder = new StringBuilder();

            foreach (var character in bytes[3:5])
            {
                builder.append_c((char) character);
            }

            var units = builder.str;

            if (false)
            {
                throw new CommunicationError.UNKNOWN_UNITS(
                    @"$(name) encountered an unknown unit code of '$(units)'"
                    );
            }

            return null;
        }


        /**
         * Recieve measurements from the instrument
         *
         * @return
         */
        public Measurement[] receive_measurements() throws Error
        {
            try
            {
                var measurement = new Measurement[channel_count];

                for (var index = 0; index < channel_count; index++)
                {
                    var response = m_serial_device.receive_response(MESSAGE_LENGTH);

                    measurement[index] = decode_measurement(response);
                }

                return measurement;
            }
            catch (CommunicationError error)
            {
                error.message = @"$(name): $(error.message)";

                throw error;
            }
        }
    }
}
