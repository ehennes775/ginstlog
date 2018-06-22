/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
    public abstract class ReadMeasurements : Object
    {
        /**
         * The last byte in a response, used to detect framing errors
         */
        public const uint8 END_BYTE = 0x03;


        /**
         * The command to send to the instrument for a reading
         */
        public static const uint8[] READ_COMMAND = { 'A' };


        /**
         * The first byte in a response, used to detect framing errors
         */
        public const uint8 START_BYTE = 0x02;


        /**
         * Initialize a new instance
         */
        public ReadMeasurements()
        {
        }


        /**
         *
         */
        public abstract Measurement[] execute(SerialDevice device) throws Error;


        /**
         * A lookup table for decoding the temperature units
         */
        protected static const TemperatureUnits[] TEMPERATURE_UNITS_LOOKUP =
        {
            /* 0 */ TemperatureUnits.FAHRENHEIT,
            /* 1 */ TemperatureUnits.CELSIUS
        };
    }
}
