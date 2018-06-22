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
    public class Model301Worker : Thermometer3xxWorker
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
         * When a name is not provided in the configuration file
         */
        public const string DEFAULT_NAME = "Dual Thermometer";


        /**
         * Initialize a new instance
         *
         * @param channel Metadata for the measurement channels
         */
        public Model301Worker(
            Channel[] channels,
            ulong interval,
            string? name,
            SerialDevice serial_device
            ) throws Error
        {
            Object(
                channel_count : CHANNEL.COUNT,
                name : name ?? DEFAULT_NAME
                );

            m_name = name ?? DEFAULT_NAME;

            if (channels.length != CHANNEL.COUNT)
            {
                throw new ConfigurationError.CHANNEL_COUNT(
                    @"$(m_name) should have $(CHANNEL.COUNT) channel(s), but $(channels.length) are specified in the configuration file"
                    );
            }

            m_channel = channels;
            m_interval = interval;
            m_queue = new AsyncQueue<Measurement>();
            m_serial_device = serial_device;
            AtomicInt.set(ref m_stop, 0);

            m_read = new ReadMeasurements8(channels);
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
         *
         */
        private static uint8 BLANK_NIBBLE = 0x0B;


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


        private ReadMeasurements8 m_read;


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
                    var measurements = m_read.execute(m_serial_device);

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
