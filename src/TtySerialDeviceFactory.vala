/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Creates SerialDevice objects that communucate with TTY serial devices
     *
     * Data specific to the insrument is located in the
     * InstrumentFactoryTable.xml file.
     *
     * Data specific to the configuration is located in the XML configuration
     * file passed in on the command line.
     *
     * This factory takes data from both locations, configures, and creates
     * properly initialized SerialDevice objects.
     */
    public class TtySerialDeviceFactory : SerialDeviceFactory
    {
        /**
         * Initialize a new instance
         *
         * @param path_context A path context to the DeviceTable element
         * inside the InstrumentFactoryTable.xml file.
         */
        public TtySerialDeviceFactory(Xml.XPath.Context path_context)
        {
            Object(
                name : "TtySerialDevice"
                );

            m_baud_rate = XmlUtility.get_optional_string(
                path_context,
                "./TtySerialDevice/BaudRate",
                "9600"
                );

            m_data_bits = XmlUtility.get_optional_string(
                path_context,
                "./TtySerialDevice/DataBits",
                "8"
                );

            m_parity = XmlUtility.get_optional_string(
                path_context,
                "./TtySerialDevice/Parity",
                "N"
                );

            m_stop_bits = XmlUtility.get_optional_string(
                path_context,
                "./TtySerialDevice/StopBits",
                "1"
                );
        }


        /**
         * {@inheritDoc}
         */
        public override SerialDevice create(Xml.XPath.Context path_context) throws Error

            requires(path_context.node != null)

        {
            if (path_context.node->name != name)
            {
                return_val_if_reached(null);
            }

            var device_file = XmlUtility.get_required_string(
                path_context,
                "./DeviceFile"
                );

            var timeout = XmlUtility.get_required_string(
                path_context,
                "./Timeout"
                );

            return new TtySerialDevice(device_file, timeout);
        }


        /**
         * The baud rate
         *
         * (String format is temporary.)
         */
        private string m_baud_rate;


        /**
         * The number of data bits
         *
         * (String format is temporary.)
         */
        private string m_data_bits;


        /**
         * The parity
         *
         * (String format is temporary.)
         */
        private string m_parity;


        /**
         * The number of stop bits
         *
         * (String format is temporary.)
         */
        private string m_stop_bits;
    }
}
