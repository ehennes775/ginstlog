/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     * A trigger based on a GLib source timeout
     */
    public class TimeoutTrigger : Trigger
    {
        /**
         * {@inheritDoc}
         */
        public override bool enable
        {
            get
            {
                return (m_source != null);
            }
            set
            {
                if (value)
                {
                    if (m_source == null)
                    {
                        // The source cannot attach/remove/reattach cleanly,
                        // so a new instance is created each time.

                        m_source = new TimeoutSource(m_interval);
                        m_source.set_callback(on_timeout);
                        m_source.attach(null);
                    }
                }
                else if (m_source != null)
                {
                    m_source.destroy();
                    m_source = null;
                }
            }
        }


        /**
         * Initialize a new instance
         *
         * @param interval The timeout interval in microseconds
         */
        public TimeoutTrigger(uint interval) throws ConfigurationError
        {
            m_interval = interval;
        }


        /**
         * Destroy the instance
         */
        ~TimeoutTrigger()
        {
            if (m_source != null)
            {
                m_source.destroy();
                m_source = null;
            }
        }


        /**
         * {@inheritDoc}
         */
        public override void cancel()
        {
            if (m_source != null)
            {
                m_source.destroy();
                m_source = null;
            }

            AtomicInt.@set(ref m_cancel, 1);
            m_cond.@signal();
        }


        /**
         * {@inheritDoc}
         */
        public override bool wait()
        {
            m_mutex.@lock();

            AtomicInt.set(ref m_count, 0);

            var cancel = AtomicInt.@get(ref m_cancel);
            var count = AtomicInt.@get(ref m_count);

            while ((cancel == 0) && (count == 0))
            {
                m_cond.wait(m_mutex);

                cancel = AtomicInt.@get(ref m_cancel);
                count = AtomicInt.get(ref m_count);
            }

            m_mutex.unlock();

            return (cancel <= 0);
        }


        /**
         *
         */
        private int m_cancel = 0;


        /**
         * A condition for signaling a trigger
         */
        private Cond m_cond = Cond();


        /**
         * The number of times the trigger occured
         */
        private int m_count = 0;


        /**
         * The timeout interval in microseconds
         */
        private uint m_interval;


        /**
         * A mutex to use for testing the condition
         */
        private Mutex m_mutex = Mutex();


        /**
         * The timeout source
         */
        private Source? m_source = null;


        /**
         * Callback function for when the source timeout occurs
         */
        private bool on_timeout()
        {
            AtomicInt.inc(ref m_count);
            m_cond.@signal();

            return Source.CONTINUE;
        }
    }
}
