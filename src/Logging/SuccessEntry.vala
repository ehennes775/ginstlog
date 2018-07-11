/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     *
     */
    public class SuccessEntry : Entry
    {
        /**
         * Initialize the instance
         *
         * @param mtime
         * @param mtime
         * @param measurements
         */
        public SuccessEntry(int64 mtime, int64 rtime, Measurement[] measurements)
        {
            Object(
                run : true,
                mtime : mtime,
                rtime : rtime
                );

            m_measurements = measurements;
        }


        /**
         * {@inheritDoc}
         */
        public string get_value(string name)
        {
            // temporary for development

            if (name == "rtime")
            {
                return rtime.to_string();
            }

            if (name == "mtime")
            {
                return mtime.to_string();
            }

            return m_measurements[0].get_value("");
        }


        /**
         * {@inheritDoc}
         */
        public override void write_to(Writer writer)
        {
            writer.write_success(this);
        }


        /**
         *
         */
        private Measurement[] m_measurements;
    }
}
