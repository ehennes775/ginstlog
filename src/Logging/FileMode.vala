/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     *
     * Keep entries in this table in alphabetical order.
     */
    public enum FileMode
    {
        /**
         * New entries are appended to the existing file
         */
        APPEND,


        /**
         * A new file is created
         *
         * If a file already exists, and error is thrown.
         */
        CREATE,


        /**
         * An existing file is replaced, if any
         */
        REPLACE,


        /**
         * The number of file modes
         */
        COUNT
    }
}
