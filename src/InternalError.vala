/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     *
     * Keep entries in this table in alphabetical order, with UNKNOWN as the
     * first entry.
     */
    public errordomain InternalError
    {
        /**
         * An unknown error
         *
         * This entry is the first item in the table, so the error code will
         * be zero.
         */
        UNKNOWN = 0,


        /**
         * Unable to lookup a static resource that should be linked with
         * the program
         */
        RESOURCE_LOOKUP,


        /**
         * Unable to parse a static resource
         */
        RESOURCE_PARSE
    }
}
