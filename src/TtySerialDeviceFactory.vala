/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
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
         * Create a new TtySerialDevice
         *
         * @param path_context
         * @return
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
         *
         */
        private string m_baud_rate;


        /**
         *
         */
        private string m_data_bits;


        /**
         *
         */
        private string m_parity;


        /**
         *
         */
        private string m_stop_bits;
    }
}
