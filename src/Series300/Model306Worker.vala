/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Series300
{
    /**
     * Background and thread for an unknown OEM thermometer
     *
     * Multple manufacturers provide a variant of this instrument. When queried
     * over RS-232 for the model number, this instrument returns 306.
     *
     * || ''Manufacturer'' || ''Model'' || ''Notes'' ||
     * || B&amp;K Precision || Model 715 || Used for development ||
     * || Omega Engineering || HH306A || Not tested ||
     */
    public class Thermometer306Worker : Series300Worker
    {
        /**
         * When a name is not provided in the configuration file
         */
        public const string DEFAULT_NAME = "Dual Thermometer";


        /**
         * Initialize a new instance
         */
        public Thermometer306Worker(
            Channel[] channels,
            ulong interval,
            string? name,
            SerialDevice serial_device
            )
        {
            base(
                channels,
                interval,
                name ?? DEFAULT_NAME,
                serial_device
                );

            m_read = new ReadMeasurements10(channels);
        }


        /**
         * {@inheritDoc}
         */
        protected override Measurement[] read_measurements_inner(SerialDevice device) throws Error
        {
            return m_read.execute(device);
        }


        /**
         *
         */
        private ReadMeasurements m_read;
    }
}
