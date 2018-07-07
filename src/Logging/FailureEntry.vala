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
        public FailureEntry(int64 mtime, int64 rtime, Error error)
        {
            Object(
                mtime : mtime,
                rtime : rtime
                );
        }


        /**
         * {@inheritDoc}
         */
        public override void write_to(Writer writer)
        {
            writer.write_failure(this);
        }
    }
}
