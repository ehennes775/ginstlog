/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Creates workers for a model 309 thermometer
     *
     * Multple manufacturers provide a variant of this instrument. When queried
     * over RS-232 for the model number, this instrument returns 309.
     *
     * || ''Manufacturer'' || ''Model'' || ''Notes'' ||
     * || Omega Engineering || HH309A || Used for development ||
     */
    public class Model309WorkerFactory : InstrumentWorkerFactory
    {
        /**
         *
         */
        public const string FACTORY_ID = "Model309";


        /**
         * Initialize a new instance
         */
        public Model309WorkerFactory(Xml.Doc* document) throws Error
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

            return new Model309Worker(
                channels,
                500000,
                name,
                serial_device
                );
        }
    }
}
