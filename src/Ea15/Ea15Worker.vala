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
         *
         * @param channels The metadata on the channels
         * @param interval The interval in between polls
         * @param name The name of the instrument to appear in the GUI
         * @param serial_device The serial device to communicate with the instrument
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

            m_read_command = new ReadMeasurementsEa15(channels);
        }


        /**
         * {@inheritDoc}
         */
        protected override Measurement[] read_measurements_inner(SerialDevice device) throws Error
        {
            return m_read_command.execute(device);
        }


        /**
         * The command to read measurments from the instrument
         */
        private ReadMeasurements m_read_command;
    }
}
