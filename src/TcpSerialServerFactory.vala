/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Creates SerialDevice objects that communucate with TCP serial servers
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
    public class TcpSerialServerFactory : SerialDeviceFactory
    {
        /**
         * The XML element name related to this object
         */
        public const string ELEMENT_NAME = "TcpSerialServer";


        /**
         * Initialize a new instance
         *
         * Currently, the TcpSerialServer element inside the
         * InstrumentFactoryTable.xml file has no children. But, the element
         * must be present to indicate the instrument supports serial server
         * connections.
         *
         * @param path_context A path context to the DeviceTable element
         * inside the InstrumentFactoryTable.xml file.
         */
        public TcpSerialServerFactory(Xml.XPath.Context path_context)
        {
            Object(
                name : ELEMENT_NAME
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
