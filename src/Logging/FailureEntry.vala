/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     *
     */
    public class FailureEntry : Entry
    {
        /**
         *
         *
         * @param time
         */
        public FailureEntry(int64 time, Error error)
        {
        }


        /**
         *
         */
        public override void write_to(Writer writer)
        {
            writer.write_failure(this);
        }
    }
}
