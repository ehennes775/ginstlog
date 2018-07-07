/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     * An abstract base class for log entries
     */
    public abstract class Entry : Object
    {
        /**
         * The monotonic time of the entry
         *
         * Contains the time in microseconds (probably since the machine
         * started)
         */
        public int64 mtime
        {
            get;
            construct;
        }


        /**
         * The wall clock time of the entry
         *
         * Contains the time in microseconds since the epoch date.
         */
        public int64 rtime
        {
            get;
            construct;
        }


        /**
         * Write this entry to a log
         *
         * @param writer The writer to accept this entry
         */
        public abstract void write_to(Writer writer);
    }
}
