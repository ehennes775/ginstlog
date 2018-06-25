/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Background and thread for an unknown OEM thermometer
     *
     * Multple manufacturers provide a variant of this instrument. When queried
     * over RS-232 for the model number, this instrument returns 304 or 309.
     *
     * || ''Manufacturer'' || ''Model'' || ''Notes'' ||
     * || Omega || HH309A || Used for development ||
     */
    public class Thermometer304Worker : Series300Worker
    {
        /**
         * This instrument has four temperature channels
         */
        public const int CHANNEL_COUNT = 4;


        /**
         * When a name is not provided in the configuration file
         */
        public const string DEFAULT_NAME = "Four Channel Thermometer";


        /**
         * Initialize a new instance
         */
        public Thermometer304Worker()
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
