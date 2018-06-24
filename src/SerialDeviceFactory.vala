/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Creates fully configured SerialDevice objects
     */
    public abstract class SerialDeviceFactory : Object
    {
        /**
         * The XML element name related to this object
         *
         * This element appears in the DeviceTable found in both the
         * InstrumentFactoryTable.xml file and the XML configuration file.
         */
        public string name
        {
            get;
            construct;
        }


        /**
         * Create a new SerialDevice
         *
         * @param path_context A path context to the DeviceTable element inside
         * the XML configuration file.
         * @return An initialized SerialDevice matching the configuration
         */
        public abstract SerialDevice create(Xml.XPath.Context path_context) throws Error;
    }
}
