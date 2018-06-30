/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Ea15
{
    /**
     * A command to read measurements from an Extech EA15
     *
     * || ''Manufacturer'' || ''Model'' || ''Notes'' ||
     * || Extech || EA15 || Used for development ||
     */
    public class ReadMeasurementsEa15 : ReadMeasurements
    {
        /**
         * Initialize a new instance
         */
        public ReadMeasurementsEa15(Channel[] channel) throws Error
        {
            m_channel = channel;

            if (m_channel.length != CHANNEL.COUNT)
            {
                throw new ConfigurationError.CHANNEL_COUNT(
                    @"Instrument has $(CHANNEL.COUNT) channels, but $(m_channel.length) specified"
                    );
            }
        }


        /**
         * {@inheritDoc}
         */
        public override Measurement[] execute(SerialDevice device) throws Error
        {
            var response = device.receive_response_with_start(
                RESPONSE_LENGTH,
                START_BYTE
                );

            if (response.length != RESPONSE_LENGTH)
            {
                throw new CommunicationError.MESSAGE_LENGTH(
                    @"Expecting $(RESPONSE_LENGTH) bytes, but received $(response.length) bytes"
                    );
            }

            if (response[0] != START_BYTE)
            {
                throw new CommunicationError.FRAMING_ERROR(
                    @"Framing error: Expecting $(START_BYTE) at start of response"
                    );
            }

            if (response[RESPONSE_LENGTH-1] != END_BYTE)
            {
                throw new CommunicationError.FRAMING_ERROR(
                    @"Framing error: Expecting $(END_BYTE) at end of response"
                    );
            }

            return decode_measurements(response);
        }


        /**
         * The number of channels in the response
         */
         private enum CHANNEL
         {
             TEMPERATURE1,
             TEMPERATURE2,
             COUNT
         }


        /**
         * The last byte in a response, used to detect framing errors
         */
        private const uint8 END_BYTE = 0x03;


        /**
         * This instrument always has a tenths place
         */
        private const int PLACES = 1;


        /**
         * The length of the expected response from the instrument, in bytes
         */
        private const int RESPONSE_LENGTH = 9;


        /**
         * The first byte in a response, used to detect framing errors
         */
        private const uint8 START_BYTE = 0x02;


        /**
         * A lookup table for decoding the temperature units
         */
        private static const TemperatureUnits[] TEMPERATURE_UNITS_LOOKUP =
        {
            /* 0 */ TemperatureUnits.CELSIUS,
            /* 1 */ TemperatureUnits.FAHRENHEIT,
            /* 2 */ TemperatureUnits.KELVIN,
            /* 3 */ TemperatureUnits.FAHRENHEIT
        };


        /**
         * A lookup table for decoding the thermocouple type
         */
        private static const ThermocoupleType[] THERMOCOUPLE_TYPE_LOOKUP =
        {
            /* 0 */ ThermocoupleType.K,
            /* 1 */ ThermocoupleType.J,
            /* 2 */ ThermocoupleType.E,
            /* 3 */ ThermocoupleType.T,
            /* 4 */ ThermocoupleType.R,
            /* 5 */ ThermocoupleType.S,
            /* 6 */ ThermocoupleType.N
        };


        /**
         * Metadata for the measurement channels
         */
        private Channel[] m_channel;


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
                decode_t(m_channel[0], bytes),
                decode_t(m_channel[1], bytes)
            };

            return measurement;
        }


        /**
         * Decode the measurement readout
         *
         * Places can only be 0 or 1.
         *
         * @param negative Indicates the measurement is neagtive
         * @param value The temperature in tenths of degrees
         * @param places Indicates the number of fractional digits
         * @return A string containing the measurement readout
         */
        private string decode_readout(long @value, int places)
        {
            var as_string = @value.to_string();

            var builder = new StringBuilder();

            builder.append(as_string.substring(0, as_string.length - 1));

            if (places > 0)
            {
                builder.append(Posix.nl_langinfo(Posix.NLItem.RADIXCHAR));

                builder.append(as_string.substring(-1, 1));
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
        private Measurement decode_t(Channel channel, uint8[] bytes) throws Error
        {
            return_val_if_fail(
                bytes.length == RESPONSE_LENGTH,
                null
                );

            var status_index = 3 * channel.index + 1;
            var status_byte = bytes[status_index];
            var open_loop = (status_byte & 0x40) == 0x40;

            if (open_loop)
            {
                return new MeasurementFailure(
                    channel,
                    "OL"
                    );
            }
            else
            {
                var negative = (status_byte & 0x80) == 0x80;

                var index0 = status_index + 1;
                var index1 = index0 + 2;

                var @value = decode_value(
                    negative,
                    bytes[index0:index1]
                    );

                var readout_value = decode_readout(
                    @value,
                    PLACES
                    );

                var units = decode_units(status_byte);

                var type = decode_thermocouple_type(bytes);

                return new Temperature(
                    channel,
                    readout_value,
                    units,
                    type
                    );
            }
        }


        /**
         * Decode the thermocouple type from the response
         *
         * The thermocouple type is the same for all channels in the response
         *
         * @param bytes The response
         * @return The thermocouple type
         */
        private static ThermocoupleType decode_thermocouple_type(uint8[] bytes)
        {
            var index = bytes[7];

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


        /**
         * Decode temperature units from the response
         *
         * @param status_byte The status byte for the channel
         * @return The temperature units for the channel
         */
        private static TemperatureUnits decode_units(uint8 status_byte)
        {
            var index = status_byte & 0x03;

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


        /**
         * Decode the value from the response
         *
         * @param negative Indicates the value is negative
         * @param bytes The binary data in the response
         * @return The value in tenths of degrees
         */
        private static long decode_value(bool negative, uint8[] bytes)
        {
            long @value = 0;

            foreach (var @byte in bytes)
            {
                @value = (@value << 8) | @byte;
            }

            if (negative)
            {
                @value = -@value;
            }

            return @value;
        }
    }
}
