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
         */
        public TtySerialDeviceFactory()
        {
            Object(
                name : "SerialDevice"
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
    }
}
