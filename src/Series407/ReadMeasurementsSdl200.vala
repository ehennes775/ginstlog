/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Series407
{
    /**
     * Read measurements from an Extech SDL200
     */
    public class ReadMeasurementsSdl200 : ReadMeasurements
    {
        /**
         * The number of channels
         *
         *
         */
        public const int CHANNEL_COUNT = 4;


        /**
         * The length of the expected response from the instrument
         *
         *
         */
        public const int RESPONSE_LENGTH = 16;


        /**
         * Initialize a new instance
         */
        public ReadMeasurementsSdl200(Channel[] channel) throws Error
        {
            m_channel = channel;

            if (m_channel.length != CHANNEL_COUNT)
            {
                throw new ConfigurationError.CHANNEL_COUNT(
                    @"Instrument has $(CHANNEL_COUNT) channels, but $(m_channel.length) specified"
                    );
            }
        }


        /**
         * {@inheritDoc}
         */
        public override Measurement[] execute(SerialDevice device) throws Error
        {
            var measurement = new Measurement[CHANNEL_COUNT] { null };

            for (var count = 0; count < CHANNEL_COUNT; count++)
            {
                var response = device.receive_response(RESPONSE_LENGTH);

                foreach (var @byte in response)
                {
                    stdout.printf(" %x", @byte);
                }

                stdout.printf("\n");

                if (response.length != RESPONSE_LENGTH)
                {
                    throw new CommunicationError.MESSAGE_LENGTH(
                        @"Expecting $(RESPONSE_LENGTH) bytes, but received $(response.length) bytes"
                        );
                }

                if (response[0] != START_BYTE)
                {
                    throw new CommunicationError.FRAMING_ERROR(
                        @"Framing error: Expecting $(START_BYTE) at start of response, but got $(response[0])"
                        );
                }

                if (response[RESPONSE_LENGTH-1] != END_BYTE)
                {
                    throw new CommunicationError.FRAMING_ERROR(
                        @"Framing error: Expecting $(END_BYTE) at end of response, but got $(response[RESPONSE_LENGTH-1])"
                        );
                }

                var channel_index = (response[2] & 0x0F) - 1;

                if ((channel_index < 0) || (channel_index >= CHANNEL_COUNT))
                {
                    throw new CommunicationError.UNKNOWN(
                        @"Invalid channel index $(channel_index)"
                        );
                }

                measurement[channel_index] = decode_measurement(
                    channel_index,
                    response
                    );
            }

            return measurement;
        }


        /**
         * Metadata for the measurement channels
         */
        private Channel[] m_channel;


        /**
         *
         */
        private string decode_readout(uint8[] bytes) throws Error
        {
            var builder = new StringBuilder();

            if (false)
            {
                builder.append_c('-');
            }

            var digits = bytes[7:15];

            for (var index = 0; index < digits.length; index++)
            {
                if (false)
                {
                    builder.append(Posix.nl_langinfo(Posix.NLItem.RADIXCHAR));
                }

                var nibble = digits[index] & 0x0F;

                if (nibble > 9)
                {
                    throw new CommunicationError.UNKNOWN(
                        @"Illegal value if $(nibble) for digit"
                        );
                }

                builder.append_c((char)('0' + nibble));
            }

            return builder.str;
        }


        /**
         * Decode measurements from a response to the 'A' command
         *
         * @param bytes The response to the 'A' command
         * @return An array of measurements
         */
        private Measurement decode_measurement(int index, uint8[] bytes) throws Error
        {
            var open_loop = false;

            if (open_loop)
            {
                return new MeasurementFailure(
                    m_channel[index],
                    "OL"
                    );
            }
            else
            {
                var readout = decode_readout(bytes);

                var units = decode_units(bytes);

                return new Temperature(
                    m_channel[index],
                    readout,
                    units
                    );
            }
        }


        /**
         * Decode the temperature units from the response

         * The units for all channels are the same.
         *
         * @param bytes
         * @return The temperature units for all channels
         */
        private TemperatureUnits decode_units(uint8[] bytes)
        {
            return_val_if_fail(
                bytes.length == RESPONSE_LENGTH,
                TemperatureUnits.UNKNOWN
                );

            var index = ((bytes[3] << 4) & 0xF0) | (bytes[4] & 0x0F);

            TemperatureUnits units;

            switch (index)
            {
                case 0x01:
                    units = TemperatureUnits.CELSIUS;
                    break;

                case 0x02:
                    units = TemperatureUnits.FAHRENHEIT;
                    break;

                default:
                    units = TemperatureUnits.UNKNOWN;
                    break;
            }

            return units;
        }
    }
}
