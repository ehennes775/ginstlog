/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Ea15
{
    /**
     * Creates workers for an Extech EA15 thermometer
     *
     * || ''Manufacturer'' || ''Model'' || ''Notes'' ||
     * || Extech || EA15 || Used for development ||
     */
    public class Ea15WorkerFactory : InstrumentWorkerFactory
    {
        /**
         * Initialize a new instance
         */
        public Ea15WorkerFactory(Xml.Doc* document) throws Error
        {
            var path_context = new Xml.XPath.Context(document);

            path_context.node = XmlUtility.get_required_node(
                path_context,
                @"/InstrumentFactoryTable/InstrumentFactory[@id='$(FACTORY_ID)']"
                );

            base(path_context);
        }


        /**
         * Create an instance of an instrument worker
         *
         * @param path_context A path context to the instrument element in the
         * configuration file.
         * @return The created instrument worker
         */
        public override InstrumentWorker create(Xml.XPath.Context path_context) throws Error
        {
            var channels = create_channels(path_context);

            var name = XmlUtility.get_optional_string(
                path_context,
                "./Name",
                null
                );

            var serial_device = create_active_device(path_context);

            return new Ea15Worker(
                channels,
                INTERVAL,
                name,
                serial_device
                );
        }


        /**
         * The element ID inside the InstrumentFactoryTable.xml file
         */
        private const string FACTORY_ID = "EA15";


        /**
         * The EA15 continuously transmits, so no delay
         */
        private const ulong INTERVAL = 0;
    }
}
