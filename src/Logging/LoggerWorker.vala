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
         * @param writer
         */
        public LoggerWorker(Trigger trigger, Writer writer) throws ConfigurationError
        {
            m_log_thread = new Thread<int>("LoggerWorkerLogger", log);
            m_trigger = trigger;
            m_write_thread = new Thread<int>("LoggerWorkerWriter", write);
            m_writer = writer;
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
        private AsyncQueue<Entry> m_queue = new AsyncQueue<Entry>();


        /**
         * The trigger for initiating a set of measurements
         */
        private Trigger m_trigger;


        /**
         * A thread for writing measurements to the log
         */
        private Thread<int> m_write_thread;


        /**
         *
         */
        private Writer m_writer;


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
                var mtime = get_monotonic_time();
                var rtime = get_real_time();

                try
                {
                    var entry = new SuccessEntry(mtime, rtime);

                    m_queue.push(entry);
                }
                catch (Error error)
                {
                    var entry = new FailureEntry(mtime, rtime, error);

                    m_queue.push(entry);
                }

                running = m_trigger.wait();
            }

            return 0;
        }


        /**
         * A thread function to write entries to a log
         *
         * @return A dummy integer
         */
        private int write()
        {
            var entry = m_queue.pop();

            while (true)
            {
                try
                {
                    entry.write_to(m_writer);

                    AtomicInt.inc(ref m_count);
                }
                catch (Error error)
                {

                }

                entry = m_queue.pop();
            }

            return 0;
        }
    }
}
