/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Series300
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
         * A lookup table for decoding the thermocouple type
         */
        protected static const ThermocoupleType[] THERMOCOUPLE_TYPE_LOOKUP =
        {
            /* 0 */ ThermocoupleType.K,
            /* 1 */ ThermocoupleType.J
        };


        /**
         * A lookup table for decoding the temperature units
         */
        protected static const TemperatureUnits[] TEMPERATURE_UNITS_LOOKUP =
        {
            /* 0 */ TemperatureUnits.FAHRENHEIT,
            /* 1 */ TemperatureUnits.CELSIUS
        };


        /**
         * Decode the thermocouple type from the response
         *
         * @param bytes The response
         * @return The thermocouple type
         */
        protected ThermocoupleType decode_thermocouple_type(uint8[] bytes)
        {
            var index = (bytes[1] >> 3) & 0x01;

            return_val_if_fail(
                index >= 0,
                ThermocoupleType.UNKNOWN
                );

            return_val_if_fail(
                index < THERMOCOUPLE_TYPE_LOOKUP.length,
                ThermocoupleType.UNKNOWN
                );

            return THERMOCOUPLE_TYPE_LOOKUP[index];
        }
    }
}
