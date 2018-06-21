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
            Channel[] channel,
            ulong interval,
            string? name,
            SerialDevice serial_device
            ) throws Error
        {
            Object(
                channel_count : CHANNEL.COUNT,
                name : name ?? DEFAULT_NAME
                );

            if (channel.length != CHANNEL.COUNT)
            {
                throw new ConfigurationError.CHANNEL_COUNT(
                    @"$(this.name) should have $(CHANNEL.COUNT) channel(s), but $(channel.length) are specified in the configuration file"
                    );
            }

            m_channel = channel;
            m_interval = interval;
            m_queue = new AsyncQueue<Measurement>();
            m_serial_device = serial_device;
            AtomicInt.set(ref m_stop, 0);
        }


        /**
         * {@inheritDoc}
         */
        public override void start()
        {
            Idle.add(poll_measurement);

            m_thread = new Thread<int>(
                @"Thread.$(name)",
                read_measurements
                );

            m_serial_device.connect();
        }


        /**
         * {@inheritDoc}
         */
        public override void stop()
        {
            AtomicInt.set(ref m_stop, 1);
            Idle.remove_by_data(this);
        }


        /**
         *
         */
        private static uint8 BLANK_NIBBLE = 0x0B;


        /**
         * The length of the response to the 'A' command in bytes
         */
        private const int MESSAGE_LENGTH = 10;


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
         * Metadata for the measurement channels
         */
        private Channel[] m_channel;


        /**
         * The interval to wait between polls, in microseconds
         */
        private ulong m_interval;


        /**
         * A queue to send measurements from the communications thread to the
         * GUI thread
         */
        private AsyncQueue<Measurement> m_queue;


        /**
         * The serial device to communicate with the instrument
         */
        private SerialDevice m_serial_device;


        /**
         * Signals the communications thread to terminate
         */
        private int m_stop;


        /**
         * A thread for blocking communications with the instrument
         */
        private Thread<int> m_thread;


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
                bytes.length == MESSAGE_LENGTH,
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
                bytes.length == MESSAGE_LENGTH,
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
                bytes.length == MESSAGE_LENGTH,
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
                bytes.length == MESSAGE_LENGTH,
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


        /**
         * Poll for recent measurements
         *
         * Called by the GUI thread to check if another measurement is
         * available.
         *
         * @return
         */
        private bool poll_measurement()
        {
            var measurement = m_queue.try_pop();

            if (measurement != null)
            {
                update_readout(measurement);
            }

            return Source.CONTINUE;
        }


        /**
         * Read measurements from the instrument
         *
         * @return A dummy value
         */
        private int read_measurements()
        {
            while (AtomicInt.get(ref m_stop) == 0)
            {
                Thread.usleep(m_interval);

                try
                {
                    m_serial_device.send_command(READ_COMMAND);

                    var response = m_serial_device.receive_response(MESSAGE_LENGTH);

                    var measurements = decode_measurements(response);

                    foreach (var measurement in measurements)
                    {
                        m_queue.push(measurement);
                    }
                }
                catch (Error error)
                {
                    stderr.printf(@"Error: $(error.message)\n");
                }
            }

            return 0;
        }
    }
}