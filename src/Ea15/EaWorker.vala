/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Ea15
{
    /**
     *
     */
     /**
      * An inner class to separate reference counting
      *
      * The threads and idle process add reference counts to the inner
      * class. The lifespan of an instance of the inner class lasts
      * until the idle process and thread are finished.
      *
      * The rest of the system adds reference counts to the outer class.
      * The lifespan of an instance of the outer class lasts until clients
      * no longer needs the outer class.
      *
      * If reference counting occured on an instance of the same class, then
      * an alternate mechanism would be requred to force garbage collection.
      */
    public abstract class EaWorker : InstrumentWorker
    {
        /**
         * Initialize the instance
         *
         * @param channels The metadata on the channels
         * @param interval The interval in between polls
         * @param name The name of the instrument to appear in the GUI
         * @param serial_device The serial device to communicate with the instrument
         */
        public EaWorker(
            Channel[] channels,
            ulong interval,
            string name,
            SerialDevice serial_device
            ) throws Error
        {
            Object(
                channel_count : channels.length,
                name : name
                );

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
        protected abstract Measurement[] read_measurements_inner(SerialDevice device) throws Error;


        /**
         * Metadata for the measurement channels
         */
        protected Channel[] m_channel;


        /**
         * The interval to wait between polls, in microseconds
         */
        private ulong m_interval;


        /**
         *
         */
        private AsyncQueue<Measurement> m_queue;


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
            m_serial_device.connect();

            while (AtomicInt.get(ref m_stop) == 0)
            {
                Thread.usleep(m_interval);

                try
                {
                    var measurements = read_measurements_inner(m_serial_device);

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
