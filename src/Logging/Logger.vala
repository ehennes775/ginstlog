/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     *
     */
    public class Logger : Object
    {
        /**
         * Counter of the number of records written
         */
        public int count
        {
            get
            {
                return_val_if_fail(m_worker != null, 0);

                return m_worker.count;
            }
        }


        /**
         * Enable or disable logging
         */
        public bool enable
        {
            get
            {
                return_val_if_fail(m_worker != null, false);

                return m_worker.enable;
            }
            set
            {
                return_if_fail(m_worker != null);

                m_worker.enable = value;
            }
        }


        /**
         * Initialize a new instance
         *
         * @param worker
         */
        public Logger(LoggerWorker worker) throws ConfigurationError
        {
            m_worker = worker;
        }


        /**
         *
         */
        ~Logger()
        {
            if (m_worker != null)
            {
                m_worker.stop();
                m_worker = null;
            }
        }


        /**
         *
         */
        private LoggerWorker m_worker;
    }
}
