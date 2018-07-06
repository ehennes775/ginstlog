/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     * An abstract base class for
     */
    public abstract class Entry : Object
    {
        /**
         *
         */
        public abstract void write_to(Writer writer);
    }
}
