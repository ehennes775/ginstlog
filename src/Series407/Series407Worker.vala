/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Series407
{
    /**
     * Background and thread for Extech models with 407 prefix
     */
    public class Series407Worker : InstrumentWorker
    {
        /**
         * Initialize a new instance
         *
         * @param channel Metadata for the measurement channels
         */
        public Series407Worker(
            Channel[] channels,
            ulong interval,
            string? name,
            SerialDevice serial_device
            ) throws Error
        {
            Object(
                channel_count : 4,
                name : name
                );

            m_name = name;

            m_read = new ReadMeasurementsSdl200(channels);

            if (channels.length != 4)
            {
                throw new ConfigurationError.CHANNEL_COUNT(
                    @"$(m_name) should have $(4) channel(s), but $(channels.length) are specified in the configuration file"
                    );
            }

            m_channel = channels;
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
                @"Thread.$(m_name)",
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
         * The interval to wait between polls, in microseconds
         */
        private ulong m_interval;


        /**
         * The name of the instrument
         */
        private string m_name;


        /**
         *
         */
        private static uint8 BLANK_NIBBLE = 0x0B;


        /**
         * The length of the response to the 'A' command in bytes
         */
        private const int MESSAGE_LENGTH = 8;


        /**
         *
         */
        private static const uint8[] READ_COMMAND = { 'A' };


        /**
         * A lookup table for decoding the temperature units
         */
        private static const TemperatureUnits[] TEMPERATURE_UNITS_LOOKUP =
        {
            /* 0 */ TemperatureUnits.FAHRENHEIT,
            /* 1 */ TemperatureUnits.CELSIUS
        };


        /**
         * A lookup table for decoding the thermocouple type
         */
        private static const ThermocoupleType[] THERMOCOUPLE_TYPE_LOOKUP =
        {
            /* 0 */ ThermocoupleType.K,
            /* 1 */ ThermocoupleType.J
        };


        /**
         * Metadata for the measurement channels
         */
        private Channel[] m_channel;


        private ReadMeasurements m_read;


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
                    var measurements = m_read.execute(m_serial_device);

                    foreach (var measurement in measurements)
                    {
                        m_queue.push(measurement);
                    }
                }
                catch (Error error)
                {
                    stderr.printf(@"Error: $(error.message)\n");
                }
            }

            return 0;
        }
    }
}
