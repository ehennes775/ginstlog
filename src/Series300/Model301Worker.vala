/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Series300
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
    public class Model301Worker : Series300Worker
    {
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
            base(
                channels,
                interval,
                name ?? DEFAULT_NAME,
                serial_device
                );

            m_read = new ReadMeasurements8(channels);
        }


        /**
         * {@inheritDoc}
         */
        protected override Measurement[] read_measurements_inner(SerialDevice device) throws Error
        {
            m_mutex.@lock();

            try
            {
                return m_read.execute(device);
            }
            finally
            {
                m_mutex.unlock();
            }
        }


        /**
         *
         */
        private Mutex m_mutex = new Mutex();


        /**
         *
         */
        private ReadMeasurements m_read;
    }
}
