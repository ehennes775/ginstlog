/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Ea15
{
    /**
     * Background and thread for an Extech EA15 thermometer
     *
     * || ''Manufacturer'' || ''Model'' || ''Notes'' ||
     * || Extech || EA15 || Used for development ||
     */
    public class Ea15Worker : EaWorker
    {
        /**
         * When a name is not provided in the configuration file
         */
        public const string DEFAULT_NAME = "Dual Thermometer";


        /**
         * Initialize a new instance
         */
        public Ea15Worker(
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

            m_read = new ReadMeasurementsEa15(channels);
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
