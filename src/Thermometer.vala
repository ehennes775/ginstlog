/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Supports thermometers by an unknown OEM
     */
    public class Thermometer : Instrument
    {
        /**
         * Construct the thermometer
         */
        public Thermometer(
            string name,
            InstrumentWorker worker
            ) throws Error
        {
            Object(
                channel_count : worker.channel_count,
                name : name
                );

            m_worker = worker;
            m_worker.update_readout.connect(on_update_readout);

            try
            {
                m_worker.start();
            }
            catch (Error error)
            {
                stderr.printf(@"$(error.message)\n");
            }
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
        public override Measurement[] read() throws CommunicationError
        {
            return m_worker.read();
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
        private InstrumentWorker? m_worker;


        /**
         *
         */
        private void on_update_readout(Measurement measurement)
        {
            update_readout(measurement);
        }
    }
}
