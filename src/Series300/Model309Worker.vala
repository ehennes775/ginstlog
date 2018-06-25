/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Background and thread for an unknown OEM thermometer
     *
     * Multple manufacturers provide a variant of this instrument. When queried
     * over RS-232 for the model number, this instrument returns 306.
     *
     * || ''Manufacturer'' || ''Model'' || ''Notes'' ||
     * || B&amp;K Precision || Model 715 || Used for development ||
     */
    public class Model309Worker : Series300Worker
    {
        /**
         * This instrument has two temperature channels
         */
         public enum CHANNEL
         {
             TEMPERATURE1,
             TEMPERATURE2,
             TEMPERATURE3,
             TEMPERATURE4,
             COUNT
         }


        /**
         * When a name is not provided in the configuration file
         */
        public const string DEFAULT_NAME = "Dual Thermometer";


        /**
         * Initialize a new instance
         */
        public Model309Worker(
            Channel[] channels,
            ulong interval,
            string? name,
            SerialDevice serial_device
            )
        {
            Object(
                channel_count : CHANNEL.COUNT,
                name : name ?? DEFAULT_NAME
                );

            m_name = name ?? DEFAULT_NAME;

            if (channels.length != CHANNEL.COUNT)
            {
                throw new ConfigurationError.CHANNEL_COUNT(
                    @"$(m_name) should have $(CHANNEL.COUNT) channel(s), but $(channels.length) are specified in the configuration file"
                    );
            }

            m_channel = channels;
            m_interval = interval;
            m_queue = new AsyncQueue<Measurement>();
            m_serial_device = serial_device;
            AtomicInt.set(ref m_stop, 0);

            m_read = new ReadMeasurements45(channels);
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
         *
         */
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


        private ReadMeasurements45 m_read;

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
    }
}
