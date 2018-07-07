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
            string? name,
            SerialDevice serial_device
            ) throws Error
        {
            Object(
                channel_count : 4,
                name : name
                );

            m_read = new ReadMeasurementsSdl200(channels);

            m_queue = new AsyncQueue<Measurement>();
            m_serial_device = serial_device;
            AtomicInt.set(ref m_stop, 0);
        }


        /**
         *
         */
        public override Measurement[] read() throws CommunicationError
        {
            return null;
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
        private AsyncQueue<Measurement> m_queue;


        /**
         *
         */
        private ReadMeasurements m_read;


        /**
         * The serial device to communicate with the instrument
         */
        private SerialDevice m_serial_device;


        /**
         *
         */
        private int m_stop;


        /**
         *
         */
        private Thread<int> m_thread;


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
            var latest = new Measurement[channel_count];
            var measurement = m_queue.try_pop();

            while (measurement != null)
            {
                latest[measurement.channel_index] = measurement;

                measurement = m_queue.try_pop();
            }

            for (int index = 0; index < channel_count; index++)
            {
                if (latest[index] != null)
                {
                    update_readout(latest[index]);
                }
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
            m_serial_device.connect();

            while (AtomicInt.get(ref m_stop) == 0)
            {
                Thread.usleep(0);

                try
                {
                    var measurements = m_read.execute(m_serial_device);

                    if (measurements != null)
                    {
                        foreach (var measurement in measurements)
                        {
                            m_queue.push(measurement);
                        }
                    }
                    else
                    {
                        stderr.printf(@"NULL measurement on $(name)\n");
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
