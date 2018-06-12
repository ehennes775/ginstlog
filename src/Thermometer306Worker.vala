/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Background and thread for an unknown OEM thermometer
     *
     * Multple manufacturers provide a variant of this instrument. When queried
     * over RS-232 for the model number, this instrument returns 306.
     *
     * || ''Manufacturer'' || ''Model'' || ''Notes'' ||
     * || B&amp;K Precision || Model 715 || Used for development ||
     */
    public class Thermometer306Worker : Thermometer3xxWorker
    {
        /**
         * Two temperature channels
         */
        public const int CHANNEL_COUNT = 2;


        /**
         * Initialize a new instance
         */
        public Thermometer306Worker()
        {

        }
    }
}
