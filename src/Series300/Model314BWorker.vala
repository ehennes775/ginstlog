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
    public class HumidityTempMeter314BWorker : Series300Worker
    {
        /**
         * This instrument has one humidity and two temperature channels
         */
        public enum CHANNEL
        {
            HUMIDITY,
            TEMPERATURE1,
            TEMPERATURE2,
            COUNT
        }

        /**
         * When a name is not provided in the configuration file
         */
        public const string DEFAULT_NAME = "Humidity Temp Meter";


        /**
         * Initialize a new instance
         */
        public HumidityTempMeter314BWorker(
            Channel[] channels,
            ulong interval,
            string? name,
            SerialDevice serial_device
            ) throws Error
        {
            base(
                channels,
                interval,
                name ?? DEFAULT_NAME,
                serial_device
                );

            if (channels.length != CHANNEL.COUNT)
            {
                throw new ConfigurationError.CHANNEL_COUNT(
                    @"$(name ?? DEFAULT_NAME) should have $(CHANNEL.COUNT) channel(s), but $(channels.length) are specified in the configuration file"
                    );
            }
        }


        /**
         * {@inheritDoc}
         */
        protected override Measurement[] read_measurements_inner(SerialDevice device) throws Error
        {
            device.send_command(READ_COMMAND);

            var response = device.receive_response_with_start(
                RESPONSE_LENGTH,
                ReadMeasurements.START_BYTE
                );

            if (response.length != RESPONSE_LENGTH)
            {
                throw new CommunicationError.MESSAGE_LENGTH(
                    @"Expecting $(RESPONSE_LENGTH) bytes, but received $(response.length) bytes"
                    );
            }

            if (response[0] != ReadMeasurements.START_BYTE)
            {
                throw new CommunicationError.FRAMING_ERROR(
                    @"Framing error: Expecting $(ReadMeasurements.START_BYTE) at start of response"
                    );
            }

            if (response[RESPONSE_LENGTH-1] != ReadMeasurements.END_BYTE)
            {
                throw new CommunicationError.FRAMING_ERROR(
                    @"Framing error: Expecting $(ReadMeasurements.END_BYTE) at end of response"
                    );
            }

            return decode_measurements(response);
        }


        /**
         *
         */
        private static uint8 BLANK_NIBBLE = 0x0B;


        /**
         * The length of the response to the 'A' command in bytes
         */
        private const int RESPONSE_LENGTH = 10;


        /**
         *
         */
        private static const uint8[] READ_COMMAND = { 'A' };


        /**
         * A lookup table for decoding the temperature units
         */
        private static const TemperatureUnits[] TEMPERATURE_UNITS_LOOKUP =
        {
            /* 0 */ TemperatureUnits.CELSIUS,
            /* 1 */ TemperatureUnits.FAHRENHEIT
        };


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
                bytes.length == RESPONSE_LENGTH,
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
                var places = 1;

                var readout_value = decode_readout(
                    negative,
                    bytes[3:5],
                    places
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
                decode_humidity(m_channel[CHANNEL.HUMIDITY], bytes),
                decode_t1(m_channel[CHANNEL.TEMPERATURE1], bytes),
                decode_t2(m_channel[CHANNEL.TEMPERATURE2], bytes)
            };

            return measurement;
        }


        /**
         * Decode the measurement readout
         *
         * @param negative Indicates the measurement is neagtive
         * @param bytes The string of binary bytes, MSBs first
         * @param places Indicates the number of fractional digits
         * @return A string containing the measurement readout
         */
        private string decode_readout(bool negative, uint8[] bytes, int places)
        {
            long @value = 0;

            foreach (var @byte in bytes)
            {
                @value = (@value << 8) | @byte;
            }

            var as_string = @value.to_string();

            var builder = new StringBuilder();

            if (negative)
            {
                builder.append_c('-');
            }

            builder.append(as_string.substring(0, as_string.length - places));

            if (places > 0)
            {
                builder.append(Posix.nl_langinfo(Posix.NLItem.RADIXCHAR));

                builder.append(as_string.substring(-places, places));
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
                bytes.length == RESPONSE_LENGTH,
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
                var places = 1;

                var readout_value = decode_readout(
                    negative,
                    bytes[5:7],
                    places
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
                bytes.length == RESPONSE_LENGTH,
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
                var places = (bytes[2] & 0x02) != 0x02 ? 1 : 0;

                var readout_value = decode_readout(
                    negative,
                    bytes[7:9],
                    places
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
                bytes.length == RESPONSE_LENGTH,
                TemperatureUnits.UNKNOWN
                );

            var index = (bytes[1] >> 3) & 0x01;

            return_val_if_fail(
                index >= 0,
                TemperatureUnits.UNKNOWN
                );

            return_val_if_fail(
                index < TEMPERATURE_UNITS_LOOKUP.length,
                TemperatureUnits.UNKNOWN
                );

            return TEMPERATURE_UNITS_LOOKUP[index];
        }
    }
}
