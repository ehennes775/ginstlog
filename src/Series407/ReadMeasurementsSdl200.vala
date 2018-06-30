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
         */
        public const int CHANNEL_COUNT = 4;


        /**
         * When operating in T1-T2 mode, include T1-T2 as measurement T4.
         * Otherwise, include not available.
         */
        public bool include_delta
        {
            get;
            construct;
            default = false;
        }


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
         *
         * Needs to be changed to handle T1-T2 mode, where only three
         * measurements are sent from the instrument.
         *
         * Needs to be changed to handle hold mode, where the instrument stops
         * sending data.
         */
        public override Measurement[] execute(SerialDevice device) throws Error
        {
            var delta_mode = true;
            var measurement = new Measurement[CHANNEL_COUNT] { null };

            for (var count = 0; count < CHANNEL_COUNT; count++)
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

                if (channel_index == 2)
                {
                    delta_mode = false;
                }

                measurement[channel_index] = decode_measurement(
                    channel_index,
                    response
                    );
            }

            if (delta_mode)
            {
                measurement[2] = new MeasurementFailure(
                    m_channel[2],
                    "N/A"
                    );

                if (!include_delta)
                {
                    measurement[3] = new MeasurementFailure(
                        m_channel[3],
                        "N/A"
                        );
                }
            }

            return measurement;
        }


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

                var units = decode_temperature_units(bytes);

                return new Temperature(
                    m_channel[index],
                    readout,
                    units,
                    ThermocoupleType.UNKNOWN
                    );
            }
        }
    }
}
