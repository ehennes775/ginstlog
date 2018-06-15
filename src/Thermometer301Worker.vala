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
        private static const TemperatureUnits[] TEMPERATURE_UNITS_LOOKUP =
        {
            /* 0 */ TemperatureUnits.FAHRENHEIT,
            /* 1 */ TemperatureUnits.CELSIUS
        };


        /**
         * Lookup table for decoding thermocouple type
         */
        private static const ThermocoupleType[] THERMOCOUPLE_TYPE_LOOKUP =
        {
            /* 0 */ ThermocoupleType.K,
            /* 1 */ ThermocoupleType.J
        };


        /**
         *
         */
        private Channel[] m_channel;


        /**
         * Decode the first channel temperature from a response
         *
         * @param bytes The response to the 'A' command
         * @return The measurement from the first channel
         */
        private Measurement decode_t1(uint8[] bytes) throws Error
        {
            return_val_if_fail(
                bytes.length != MESSAGE_LENGTH,
                null
                );

            var open_loop = (bytes[2] & 0x01) == 0x01;

            if (open_loop)
            {
                return new MeasurementFailure(
                    m_channel[0],
                    "OL"
                    );
            }
            else
            {
                var negative = (bytes[2] & 0x02) == 0x02;
                var tenths = (bytes[2] & 0x04) != 0x04;

                var readout_value = "0000";

                var units = decode_units(bytes);

                return new Temperature(
                    m_channel[0],
                    readout_value,
                    units
                    );
            }
        }


        /**
         * Decode the second channel temperature from a response
         *
         * @param bytes The response to the 'A' command
         * @return The measurement from the first channel
         */
        private Measurement decode_t2(uint8[] bytes) throws Error
        {
            return_val_if_fail(
                bytes.length != MESSAGE_LENGTH,
                null
                );

            var open_loop = (bytes[2] & 0x08) == 0x08;

            if (open_loop)
            {
                return new MeasurementFailure(
                    m_channel[1],
                    "OL"
                    );
            }
            else
            {
                var negative = (bytes[2] & 0x10) == 0x10;
                var tenths = (bytes[2] & 0x20) != 0x20;

                var readout_value = "0000";

                var units = decode_units(bytes);

                return new Temperature(
                    m_channel[1],
                    readout_value,
                    units
                    );
            }
        }


        /**
         * Decode the thermocouple type in the response to the 'A' command

         * The thermocouple type for both channels are the same.
         *
         * @param bytes The response to the 'A' command
         * @return The thermocouple type for both channels
         */
        private ThermocoupleType decode_thermocouple_type(uint8[] bytes)
        {
            return_val_if_fail(
                bytes.length != MESSAGE_LENGTH,
                ThermocoupleType.UNKNOWN
                );

            var index = (bytes[1] >> 3) & 0x01;

            return_val_if_fail(
                index < 0,
                ThermocoupleType.UNKNOWN
                );

            return_val_if_fail(
                index > THERMOCOUPLE_TYPE_LOOKUP.length,
                ThermocoupleType.UNKNOWN
                );

            return THERMOCOUPLE_TYPE_LOOKUP[index];
        }


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
                index > TEMPERATURE_UNITS_LOOKUP.length,
                TemperatureUnits.UNKNOWN
                );

            return TEMPERATURE_UNITS_LOOKUP[index];
        }
    }
}
