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
            m_thread = new Thread<int>("LoggerWorker", log);
            m_trigger = trigger;
        }


        /**
         * A thread for reading and logging the measurements
         */
        private Thread<int> m_thread;


        /**
         * The trigger for initiating a set of measurements
         */
        private Trigger m_trigger;


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
                stdout.printf("Perform measurements\n");

                running = m_trigger.wait();
            }

            return 0;
        }
    }
}
