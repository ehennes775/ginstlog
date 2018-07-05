/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     *
     */
    public class LoggerWorker : Object
    {
        /**
         * Counter of the number of records written
         */
        public int count
        {
            get
            {
                return AtomicInt.@get(ref m_count);
            }
        }


        /**
         * Enable or disable logging
         */
        public bool enable
        {
            get
            {
                return_val_if_fail(m_trigger != null, false);

                return m_trigger.enable;
            }
            set
            {
                return_if_fail(m_trigger != null);

                m_trigger.enable = value;
            }
        }


        /**
         * Initialize a new instance
         *
         * @param trigger The trigger for initiating a set of measurements
         */
        public LoggerWorker(Trigger trigger) throws ConfigurationError
        {
            m_log_thread = new Thread<int>("LoggerWorkerLogger", log);
            m_trigger = trigger;
            m_write_thread = new Thread<int>("LoggerWorkerWriter", write);
        }


        /**
         * Counter of the number of records written
         *
         * Read from the GUI thread. Modified by another thread. Use AtomicInt
         * for access.
         */
        private int m_count = 0;


        /**
         * A thread for reading and logging the measurements
         */
        private Thread<int> m_log_thread;


        /**
         * The trigger for initiating a set of measurements
         */
        private AsyncQueue<string> m_queue = new AsyncQueue<string>();


        /**
         * The trigger for initiating a set of measurements
         */
        private Trigger m_trigger;


        /**
         * A thread for writing measurements to the log
         */
        private Thread<int> m_write_thread;


        /**
         * The thread function to read and log measurements
         *
         * @return A dummy integer
         */
        private int log()
        {
            var running = m_trigger.wait();

            while (running)
            {
                m_queue.push("Measurements");

                running = m_trigger.wait();
            }

            return 0;
        }


        /**
         *
         *
         * @return A dummy integer
         */
        private int write()
        {
            var data = m_queue.pop();

            while (true)
            {
                AtomicInt.inc(ref m_count);

                data = m_queue.pop();
            }

            return 0;
        }
    }
}
