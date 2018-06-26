/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Background and thread for an unknown OEM thermometer
     *
     * Multple manufacturers provide a variant of this instrument. When queried
     * over RS-232 for the model number, this instrument returns 304 or 309.
     *
     * || ''Manufacturer'' || ''Model'' || ''Notes'' ||
     * || Omega || HH309A || Used for development ||
     */
    public class Thermometer304Worker : Series300Worker
    {
        /**
         * This instrument has four temperature channels
         */
        public const int CHANNEL_COUNT = 4;


        /**
         * When a name is not provided in the configuration file
         */
        public const string DEFAULT_NAME = "Four Channel Thermometer";


        /**
         * Initialize a new instance
         */
        public Thermometer304Worker(
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

            if (channels.length != CHANNEL_COUNT)
            {
                throw new ConfigurationError.CHANNEL_COUNT(
                    @"$(name ?? DEFAULT_NAME) should have $(CHANNEL_COUNT) channel(s), but $(channels.length) are specified in the configuration file"
                    );
            }

            m_read = new ReadMeasurements8(channels);
        }

        public override Measurement[] read_measurements_inner(SerialDevice device) throws Error
        {
            return m_read.execute(device);
        }

        /**
         *
         */
        private ReadMeasurements m_read;
    }
}
