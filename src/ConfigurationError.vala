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
    public errordomain ConfigurationError
    {
        /**
         * An unknown error
         *
         * This entry is the first item in the table, so the error code will
         * be zero.
         */
        UNKNOWN = 0,


        /**
         * The number of channels specified in the configuration file does not
         * match the number of channels on the instrument.
         */
        CHANNEL_COUNT = 1,


        /**
         * The instrument requires at least one channel specified in the
         * configuration file.
         */
        CHANNEL_REQUIRED = 2,


        /**
         *
         */
        GENERIC = 3,


        /**
         *
         */
        FILE_NOT_FOUND = 4
    }
}
