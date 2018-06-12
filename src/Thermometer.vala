/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Supports thermometers by an unknown OEM
     *
     * Models Supported
     * * B&K Precision Model 715
     */
    public class Thermometer : Instrument
    {
        /**
         * The default name for this class of thermometer
         */
        public const string DEFAULT_NAME = "Dual Thermometer";


        /**
         * The interval to wait between polls, in microseconds
         */
        public ulong interval
        {
            get;
            construct;
            default = 500000;
        }


        /**
         * Construct the thermometer
         */
        public Thermometer(
            Channel[] channels,
            string name,
            SerialDevice serial_device
            ) throws Error
        {
            Object(
                channel_count : 2,
                interval : 500000,
                name : name
                );

            m_worker = new Thermometer306Worker(
                channels,
                interval,
                name,
                serial_device
                );

            m_worker.update_readout.connect(on_update_readout);

            m_worker.start();
        }


        /**
         *
         */
        ~Thermometer()
        {
            if (m_worker != null)
            {
                m_worker.update_readout.disconnect(on_update_readout);
                m_worker.stop();
                m_worker = null;
            }
        }


        /**
         *
         */
        public void toggle_hold() throws Error
        {
            //m_serial_device.send_command(TOGGLE_HOLD_COMMAND);
        }


        /**
         *
         */
        public void toggle_time() throws Error
        {
            //m_serial_device.send_command(TOGGLE_TIME_COMMAND);
        }


        /**
         *
         */
        public void change_units() throws Error
        {
            //m_serial_device.send_command(CHANGE_UNITS_COMMAND);
        }


        /**
         *
         */
        private Thermometer3xxWorker? m_worker;


        /**
         *
         */
        private void on_update_readout(Measurement measurement)
        {
            update_readout(measurement);
        }
    }
}
