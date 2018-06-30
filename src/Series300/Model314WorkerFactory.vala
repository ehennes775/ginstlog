/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Series300
{
    /**
     * Creates workers for a model 314 thermometer
     *
     * The model may require an A or B suffix, but will not know for sure until
     * additional equipment arrives.
     */
    public class Model314WorkerFactory : InstrumentWorkerFactory
    {
        /**
         *
         */
        public const string FACTORY_ID = "Model314";


        /**
         * Initialize a new instance
         */
        public Model314WorkerFactory(Xml.Doc* document) throws Error
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

            return new HumidityTempMeter314BWorker(
                channels,
                500000,
                name,
                serial_device
                );
        }
    }
}
