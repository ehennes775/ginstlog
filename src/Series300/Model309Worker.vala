/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Series300
{
    /**
     * Background and thread for an unknown OEM thermometer
     *
     * Multple manufacturers provide a variant of this instrument. When queried
     * over RS-232 for the model number, this instrument returns 309.
     *
     * || ''Manufacturer'' || ''Model'' || ''Notes'' ||
     * || Omega Engineering || HH309A || Used for development ||
     */
    public class Model309Worker : Series300Worker
    {
        /**
         * When a name is not provided in the configuration file
         */
        public const string DEFAULT_NAME = "Dual Thermometer";


        /**
         * Initialize a new instance
         */
        public Model309Worker(
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

            m_read = new ReadMeasurements45(channels);
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
