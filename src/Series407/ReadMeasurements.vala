/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Series407
{
    /**
     *
     */
    public abstract class ReadMeasurements : Object
    {
        /**
         * The last byte in a response, used to detect framing errors
         */
        public const uint8 END_BYTE = 0x0D;


        /**
         * The length of the expected response from the instrument
         *
         * The response length of a single measurement. Insruments with
         * multiple cannels will send multiple messages.
         */
        public const int RESPONSE_LENGTH = 16;


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
         * Read measurements from the device
         *
         * @param device The serial device to read the measurements from
         * @return The measurements from the device
         */
        public abstract Measurement[] execute(SerialDevice device) throws Error;


        /**
         * Decode a single measurement from a series 407 response
         *
         * This function needs to be more robust.
         *
         * This function throws a CommunicationError if there are errors in the
         * data, making the assumption the error was introduced during
         * communication.
         *
         * @parma bytes The 16 byte response from the instrument
         */
        protected string decode_readout(uint8[] bytes) throws CommunicationError
        {
            var builder = new StringBuilder();

            var negative = (bytes[5] & 0x01) == 0x01;

            if (negative)
            {
                builder.append_c('-');
            }

            var digits = bytes[7:15];
            var place = digits.length - (bytes[6] & 0x0F);
            var strip = true;

            for (var index = 0; index < digits.length; index++)
            {
                if (index == place)
                {
                    builder.append(Posix.nl_langinfo(Posix.NLItem.RADIXCHAR));
                    strip = false;
                }

                var nibble = digits[index] & 0x0F;

                if (nibble > 9)
                {
                    throw new CommunicationError.UNKNOWN(
                        @"Illegal value if $(nibble) for digit"
                        );
                }

                if (nibble != 0x00)
                {
                    strip = false;
                }

                if (nibble != 0x00 || !strip)
                {
                    builder.append_c((char)('0' + nibble));
                }
            }

            return builder.str;
        }


        /**
         * Decode the temperature units from the response
         *
         * @param bytes The 16 byte response from the instrument
         * @return The temperature units
         */
        protected TemperatureUnits decode_temperature_units(uint8[] bytes)
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
