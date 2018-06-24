/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
    public class TcpSerialServerFactory : SerialDeviceFactory
    {
        /**
         * Initialize a new instance
         */
        public TcpSerialServerFactory()
        {
            Object(
                name : "TcpSerialServer"
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

            var address = XmlUtility.get_required_string(
                path_context,
                "./Address"
                );

            var port = XmlUtility.get_required_string(
                path_context,
                "./Port"
                );

            // fixme
            var temp = (uint16) uint64.parse(port);

            return new TcpSerialServer(address, temp);
        }
    }
}
