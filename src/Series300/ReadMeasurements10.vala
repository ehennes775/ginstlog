/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * A command to read measurements with a 10 byte response
     *
     * Multple manufacturers provide a variant of this instrument. When queried
     * over RS-232 for the model number, this instrument returns 306.
     *
     * || ''Manufacturer'' || ''Model'' || ''Notes'' ||
     * || B&amp;K Precision || Model 715 || Used for development ||
     */
    public class ReadMeasurements10 : ReadMeasurements
    {
         /**
          * This instrument has two temperature channels
          */
          public enum CHANNEL
          {
              TEMPERATURE1,
              TEMPERATURE2,
              COUNT
          }


        /**
         * The length of the expected response from the instrument, in bytes
         */
        public const int RESPONSE_LENGTH = 10;


        /**
         * Initialize a new instance
         */
        public ReadMeasurements10(Channel[] channel) throws Error
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
         *
         */
        private static uint8 BLANK_NIBBLE = 0x0B;


        /**
         * Metadata for the measurement channels
         */
        private Channel[] m_channel;


        /**
         * Decode the BCD digit in the least significant nibble
         *
         * The value 0x0B decodes to a "blank." The blank provides a
         * mechanism to remove leading zeros on the display. If blanks
         * are allowed, then the value is treated as a 0. If blanks
         * are not allowed, an error occurs when a blank is encountered.
         *
         * @param byte The BCD nibble to decode
         * @param allow Allow a 'blank' value.
         * @return The value of the least significant nibble [0,9].
         * @throw InstrumentError.INVALID_DATA
         */
        private static int decode_bcd_nibble(uint8 byte, bool allow) throws Error

            ensures (result >= 0)
            ensures (result <= 9)

        {
            var nibble = byte & 0x0F;

            if (allow && (nibble == BLANK_NIBBLE))
            {
                nibble = 0x00;
            }

            if (nibble > 0x09)
            {
                throw new InstrumentError.INVALID_DATA("");
            }

            return nibble;
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
                decode_t(0, m_channel[0], bytes),
                decode_t(1, m_channel[1], bytes)
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
            var builder = new StringBuilder();

            if (negative)
            {
                builder.append_c('-');
            }

            var allow = true;
            var remaining_digits = 2 * bytes.length;

            foreach (var @byte in bytes)
            {
                var upper_nibble = (@byte >> 4) & 0x0F;
                var upper_decoded = decode_bcd_nibble(upper_nibble, allow);

                if (upper_nibble != BLANK_NIBBLE)
                {
                    builder.append_c((char)('0' + upper_decoded));

                    allow = false;
                }

                remaining_digits--;

                if (remaining_digits == places)
                {
                    builder.append_c('.');
                }

                var lower_nibble = @byte & 0x0F;
                var lower_decoded = decode_bcd_nibble(lower_nibble, allow);

                if (lower_nibble != BLANK_NIBBLE)
                {
                    builder.append_c((char)('0' + lower_decoded));

                    allow = false;
                }

                remaining_digits--;
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
        private Measurement decode_t(int window, Channel channel, uint8[] bytes) throws Error
        {
            return_val_if_fail(
                bytes.length == RESPONSE_LENGTH,
                null
                );

            var time_mode = ((bytes[1] & 0x08) == 0x08);

            if (time_mode)
            {
                return new MeasurementFailure(
                    channel,
                    "N/A"
                    );
            }
            else
            {
                var open_loop_mask = 0x01 << (3 * window);
                var open_loop = (bytes[2] & open_loop_mask) == open_loop_mask;

                if (open_loop)
                {
                    return new MeasurementFailure(
                        channel,
                        "OL"
                        );
                }
                else
                {
                    var negative_mask = 0x01 << (3 * window + 1);
                    var negative = (bytes[2] & negative_mask) == negative_mask;

                    var places_mask = 0x01 << (3 * window + 2);
                    var places = (bytes[2] & places_mask) == places_mask ? 0 : 1;

                    var index0 = 4 * window + 3;
                    var index1 = index0 + 2;

                    var readout_value = decode_readout(
                        negative,
                        bytes[index0:index1],
                        places
                        );

                    var units = decode_units(bytes);

                    var type = decode_thermocouple_type(
                        bytes[index0:index1]
                        );

                    return new Temperature(
                        channel,
                        readout_value,
                        units,
                        type
                        );
                }
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
    }
}
