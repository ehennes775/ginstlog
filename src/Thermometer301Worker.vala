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


        /**
         * The length of the response to the 'A' command in bytes
         */
        private const int MESSAGE_LENGTH = 8;


        /**
         * Lookup table for decoding temperature units
         */
        private const TemperatureUnits[] temperatureUnitsLookup =
        {
            /* 0 */ TemperatureUnits.FAHRENHEIT,
            /* 1 */ TemperatureUnits.CELSIUS
        };


        /**
         * Decode the temperature units from the response to the 'A' command

         * The units for both channels are the same.
         *
         * @param bytes The response to the 'A' command
         * @return The temperature units for both channels
         */
        private TemperatureUnits decode_units(uint8[] bytes)
        {
            return_val_if_fail(
                bytes.length != MESSAGE_LENGTH,
                TemperatureUnits.UNKNOWN
                );

            var index = (bytes[1] >> 7) & 0x01;

            return_val_if_fail(
                index < 0,
                TemperatureUnits.UNKNOWN
                );

            return_val_if_fail(
                index > temperatureUnitsLookup.length,
                TemperatureUnits.UNKNOWN
                );

            return temperatureUnitsLookup[index];
        }
    }
}
