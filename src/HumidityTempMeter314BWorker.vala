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
         * This instrument has one humidity and two temperature channels
         */
        public const int CHANNEL_COUNT = 3;


        /**
         * When a name is not provided in the configuration file
         */
        public const string DEFAULT_NAME = "Humidity Temp Meter";


        /**
         * Initialize a new instance
         */
        public HumidityTempMeter314BWorker(Channel[] channel) throws Error
        {
            if (channel.length != CHANNEL_COUNT)
            {
                // TODO throw an error
            }

            m_channel = channel;
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
        private const int MESSAGE_LENGTH = 10;


        /**
         * A lookup table for decoding the temperature units
         */
        private static const TemperatureUnits[] TEMPERATURE_UNITS_LOOKUP =
        {
            /* 0 */ TemperatureUnits.CELSIUS,
            /* 1 */ TemperatureUnits.FAHRENHEIT
        };


        /**
         * Metadata for the measurement channels
         */
        private Channel[] m_channel;


        /**
         * Decode the humidity from a response
         *
         * @param channel The channel to present the measurement on
         * @param bytes The response to the 'A' command
         * @return The measurement from the first channel
         */
        private Measurement decode_humidity(Channel channel, uint8[] bytes) throws Error
        {
            return_val_if_fail(
                bytes.length != MESSAGE_LENGTH,
                null
                );

            var open_loop = (bytes[2] & 0x40) == 0x40;

            if (open_loop)
            {
                return new MeasurementFailure(
                    channel,
                    "OL"
                    );
            }
            else
            {
                var negative = (bytes[2] & 0x80) == 0x80;
                var tenths = true;

                var readout_value = decode_readout(
                    negative,
                    bytes[3:5],
                    tenths
                    );

                return new RelativeHumidity(
                    channel,
                    readout_value
                    );
            }
        }


        /**
         * Decode measurements from a response to the 'A' command
         *
         * @param bytes The response to the 'A' command
         * @return An array of measurements
         */
        private Measurement[] decode_measurements(uint8[] bytes) throws Error
        {
            var measurement = new Measurement[]
            {
                decode_humidity(m_channel[0], bytes),
                decode_t1(m_channel[1], bytes),
                decode_t2(m_channel[2], bytes)
            };

            return measurement;
        }


        /**
         * Decode the measurement readout
         *
         * @param negative Indicates the measurement is neagtive
         * @param bytes The string of BCD bytes
         * @param tenths Indicates a tenths places is present on the readout
         * @return A string containing the measurement readout
         */
        private string decode_readout(bool negative, uint8[] bytes, bool tenths) throws Error
        {
            var builder = new StringBuilder();
            var index = bytes.length - 1;

            while (index >= 0)
            {
                var nibble = bytes[index] & 0x0F;

                // TODO: prepend nibble

                if (tenths)
                {
                    builder.prepend_c('.');
                }

                nibble = (bytes[index] >> 4) & 0x0F;

                // TODO: prepend nibble

                index--;
            }

            if (negative)
            {
                builder.prepend_c('-');
            }

            return builder.str;
        }


        /**
         * Decode the first channel temperature from a response
         *
         * @param channel The channel to present the measurement on
         * @param bytes The response to the 'A' command
         * @return The measurement from the first channel
         */
        private Measurement decode_t1(Channel channel, uint8[] bytes) throws Error
        {
            return_val_if_fail(
                bytes.length != MESSAGE_LENGTH,
                null
                );

            var open_loop = (bytes[2] & 0x10) == 0x10;

            if (open_loop)
            {
                return new MeasurementFailure(
                    channel,
                    "OL"
                    );
            }
            else
            {
                var negative = (bytes[2] & 0x20) == 0x20;
                var tenths = true;

                var readout_value = decode_readout(
                    negative,
                    bytes[5:7],
                    tenths
                    );

                var units = decode_units(bytes);

                return new Temperature(
                    channel,
                    readout_value,
                    units
                    );
            }
        }


        /**
         * Decode the second channel temperature from a response
         *
         * @param channel The channel to present the measurement on
         * @param bytes The response to the 'A' command
         * @return The measurement from the first channel
         */
        private Measurement decode_t2(Channel channel, uint8[] bytes) throws Error
        {
            return_val_if_fail(
                bytes.length != MESSAGE_LENGTH,
                null
                );

            var open_loop = (bytes[2] & 0x04) == 0x04;

            if (open_loop)
            {
                return new MeasurementFailure(
                    channel,
                    "OL"
                    );
            }
            else
            {
                var negative = (bytes[2] & 0x80) == 0x80;
                var tenths = (bytes[2] & 0x02) != 0x02;

                var readout_value = decode_readout(
                    negative,
                    bytes[7:9],
                    tenths
                    );

                var units = decode_units(bytes);

                return new Temperature(
                    channel,
                    readout_value,
                    units
                    );
            }
        }


        /**
         * Decode the temperature units from the response to the 'A' command

         * The units for both temperature channels are the same.
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

            var index = (bytes[1] >> 3) & 0x01;

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
