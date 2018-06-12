/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Background and thread for an unknown OEM humidity temp meter
     *
     * Multple manufacturers provide a variant of this instrument. When queried
     * over RS-232 for the model number, this instrument returns 315B.
     *
     * || ''Manufacturer'' || ''Model'' || ''Notes'' ||
     * || B&amp;K Precision || Model 720 || Not tested ||
     * || B&amp;K Precision || Model 725 || Used for development ||
     */
    public class HumidityTempMeter314BWorker : Thermometer3xxWorker
    {
        /**
         * One humidity and two temperature channels
         */
        public const int CHANNEL_COUNT = 3;


        /**
         * When a name is not provided in the configuration file
         */
        public const string DEFAULT_NAME = "Humidity Temp Meter";


        /**
         * Initialize a new instance
         */
        public HumidityTempMeter314BWorker()
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
