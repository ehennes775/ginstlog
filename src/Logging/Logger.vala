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
        }


        /**
         *
         */
        private LoggerWorker m_worker;
    }
}
