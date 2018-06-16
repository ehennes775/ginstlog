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
    public errordomain CommunicationError
    {
        /**
         * An unknown error
         *
         * This entry is the first item in the table, so the error code will
         * be zero.
         */
        UNKNOWN = 0,


        /**
         * A response from an instrument has a framing error.
         */
        FRAMING_ERROR,


        /**
         * A response from the instrument could not be processed because of
         * the message length.
         */
        MESSAGE_LENGTH,


        /**
         * Communication timed out waiting for a response.
         */
        RESPONSE_TIMEOUT,


        /**
         * The instrument sent a unit of measurement that the application does
         * not recognize.
         */
        UNKNOWN_UNITS
    }
}
