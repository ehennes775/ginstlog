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
         *
         * @param channel Metadata for the measurement channels
         */
        public Thermometer301Worker(Channel[] channel) throws Error
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
            Idle.add(poll_measurement);

            m_thread = new Thread<int>(
                @"Thread.$(m_name)",
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
         * The serial device to communicate with the instrument
         */
        private SerialDevice m_serial_device;


        /**
         *
         */
        private AsyncQueue<Measurement> m_queue;


        private int m_stop;


        /**
         *
         */
        private Thread<int> m_thread;

        /**
         * The interval to wait between polls, in microseconds
         */
        private ulong m_interval;


        /**
         * The name of the instrument
         */
        private string m_name;




        /**
         * The length of the response to the 'A' command in bytes
         */
        private const int MESSAGE_LENGTH = 8;


        /**
         *
         */
        private static const uint8[] READ_COMMAND = { 'A' };


        /**
         * A lookup table for decoding the temperature units
         */
        private static const TemperatureUnits[] TEMPERATURE_UNITS_LOOKUP =
        {
            /* 0 */ TemperatureUnits.FAHRENHEIT,
            /* 1 */ TemperatureUnits.CELSIUS
        };


        /**
         * A lookup table for decoding the thermocouple type
         */
        private static const ThermocoupleType[] THERMOCOUPLE_TYPE_LOOKUP =
        {
            /* 0 */ ThermocoupleType.K,
            /* 1 */ ThermocoupleType.J
        };


        /**
         * Metadata for the measurement channels
         */
        private Channel[] m_channel;


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
         * Decode measurements from a response to the 'A' command
         *
         * @param bytes The response to the 'A' command
         * @return An array of measurements
         */
        private Measurement[] decode_measurements(uint8[] bytes) throws Error
        {
            var measurement = new Measurement[]
            {
                decode_t1(m_channel[0], bytes),
                decode_t2(m_channel[1], bytes)
            };

            return measurement;
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

            var open_loop = (bytes[2] & 0x01) == 0x01;

            if (open_loop)
            {
                return new MeasurementFailure(
                    channel,
                    "OL"
                    );
            }
            else
            {
                var negative = (bytes[2] & 0x02) == 0x02;
                var tenths = (bytes[2] & 0x04) != 0x04;

                var readout_value = decode_readout(
                    negative,
                    bytes[3:5],
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

            var open_loop = (bytes[2] & 0x08) == 0x08;

            if (open_loop)
            {
                return new MeasurementFailure(
                    channel,
                    "OL"
                    );
            }
            else
            {
                var negative = (bytes[2] & 0x10) == 0x10;
                var tenths = (bytes[2] & 0x20) != 0x20;

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
