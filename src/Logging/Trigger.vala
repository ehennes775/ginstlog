/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     * An abstract base class for triggers
     */
    public abstract class Trigger : Object
    {
        /**
         * Enable or disable the trigger
         *
         * These property accessors are intended to be called from the GUI
         * thread.
         */
        public abstract bool enable
        {
            get;
            set;
        }


        /**
         * Remove reference counts by timeouts and threads so the object can be
         * destroyed.
         *
         * After calling cancel, wait() will return false.
         */
        public abstract void cancel();


        /**
         * Block until the trigger occurs
         *
         * This function should be called from the thread making the
         * measurements. This function should not be called with the GUI
         * thread.
         *
         * @return A false return value indicates the program is shutting down
         * and the thread making the measurements should exit.
         */
        public abstract bool wait();
    }
}
