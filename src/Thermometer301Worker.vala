/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Background and thread for an unknown OEM thermometer
     *
     * Multple manufacturers provide a variant of this instrument. When queried
     * over RS-232 for the model number, this instrument returns 301.
     *
     * || ''Manufacturer'' || ''Model'' || ''Notes'' ||
     * || B&amp;K Precision || Model 710 || Used for development ||
     */
    public class Thermometer301Worker : Thermometer3xxWorker
    {
        /**
         * This instrument has two temperature channels
         */
        public const int CHANNEL_COUNT = 2;


        /**
         * When a name is not provided in the configuration file
         */
        public const string DEFAULT_NAME = "Dual Thermometer";


        /**
         * Initialize a new instance
         */
        public Thermometer301Worker()
        {

        }


        /**
         * {@inheritDoc}
         */
        public override void start()
        {

        }


        /**
         * {@inheritDoc}
         */
        public override void stop()
        {

        }
    }
}
