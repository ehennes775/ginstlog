/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Series300
{
    /**
     * A command to read measurements with a 45 byte response
     *
     * Multple manufacturers provide a variant of this instrument. When queried
     * over RS-232 for the model number, this instrument returns 309.
     *
     * || ''Manufacturer'' || ''Model'' || ''Notes'' ||
     * || Omega Engineering || HH309A || Used for development ||
     */
    public class ReadMeasurements45 : ReadMeasurements
    {
        /**
         * The number of channels in the response
         */
         public enum CHANNEL
         {
             TEMPERATURE1,
             TEMPERATURE2,
             TEMPERATURE3,
             TEMPERATURE4,
             COUNT
         }


        /**
         * The length of the expected response from the instrument, in bytes
         */
        public const int RESPONSE_LENGTH = 45;


        /**
         * Initialize a new instance
         */
        public ReadMeasurements45(Channel[] channel) throws Error
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
            device.send_command(READ_COMMAND);

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
        * This value in the temperature data bytes indicates the
        * thermocouple below the lower threshold
         */
        private const long NEGATIVE_OPEN_LOOP = -32768;


        /**
         * This value in the temperature data bytes indicates the
         * thermocouple is open loop
         */
        private const long OPEN_LOOP = 32767;


        /**
         * This model only supports Type K.
         */
        private const ThermocoupleType TYPE = ThermocoupleType.K;


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
                decode_t(m_channel[1], bytes),
                decode_t(m_channel[2], bytes),
                decode_t(m_channel[3], bytes)
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

            var index0 = 2 * channel.index + 7;
            var index1 = index0 + 2;

            var @value = decode_value(bytes[index0:index1]);

            if (@value == OPEN_LOOP)
            {
                return new MeasurementFailure(
                    channel,
                    "OL"
                    );
            }
            else if (@value == NEGATIVE_OPEN_LOOP)
            {
                return new MeasurementFailure(
                    channel,
                    "-OL"
                    );
            }
            else
            {
                var mask = 0x01 << channel.index;

                var places = (bytes[43] & mask) == mask ? 0 : 1;

                var readout_value = decode_readout(
                    @value,
                    places
                    );

                var units = decode_units(bytes);

                return new Temperature(
                    channel,
                    readout_value,
                    units,
                    TYPE
                    );
            }
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
                bytes.length == RESPONSE_LENGTH,
                TemperatureUnits.UNKNOWN
                );

            var index = (bytes[1] >> 7) & 0x01;

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
         * The bytes represent the temperature in tenths of degress. The format
         * is binary twos compliment. The sign bit is in the MSB. When no
         * decimal place is used, the digit does not contain a useful value.
         *
         * @param bytes The binary data in the response
         * @return The value in tenths of degrees
         */
        public long decode_value(uint8[] bytes)
        {
            bool negative = (bytes[0] & 0x80) == 0x80;
            long @value = negative ? -1 : 0;

            foreach (var @byte in bytes)
            {
                @value = (@value << 8) | @byte;
            }

            return @value;
        }
    }
}
