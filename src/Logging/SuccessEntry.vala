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
         *
         *
         * @param mtime
         * @param mtime
         */
        public SuccessEntry(int64 mtime, int64 rtime)
        {
            Object(
                mtime : mtime,
                rtime : rtime
                );
        }


        /**
         *
         */
        public string get_value(string name)
        {
            // temporary for development

            stdout.printf(@"$(name)\n");

            if (name == "rtime")
            {
                return rtime.to_string();
            }

            if (name == "mtime")
            {
                return mtime.to_string();
            }

            return "0.0";
        }


        /**
         * {@inheritDoc}
         */
        public override void write_to(Writer writer)
        {
            writer.write_success(this);
        }
    }
}
