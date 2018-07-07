/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     * A fake entry to unblock the thread processing the entries and signal the
     * thread to exit.
     */
    public class CancelEntry : Entry
    {
        /**
         * Initialize a new instance
         */
        public CancelEntry()
        {
            Object(
                run : false,
                mtime : get_monotonic_time(),
                rtime : get_real_time()
                );
        }


        /**
         * {@inheritDoc}
         */
        public override void write_to(Writer writer)
        {
        }
    }
}
