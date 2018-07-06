/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     * An abstract base class for
     */
    public abstract class Writer : Object
    {
        /**
         *
         */
        public abstract void write_failure(FailureEntry entry);


        /**
         *
         */
        public abstract void write_success(SuccessEntry entry);
    }
}
