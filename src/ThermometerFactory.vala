/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * A class for creating thermometers
     */
    public class ThermometerFactory : InstrumentFactory
    {
        /**
         *
         */
        public string factory_id
        {
            get;
            private set;
        }


        /**
         *
         */
        public InstrumentWorkerFactory factory
        {
            get;
            private set;
        }


        /**
         * Initialize the class
         */
        static construct
        {
            s_lookup = create_lookup();
        }


        /**
         * Initialize a new instance
         *
         * @param path_context A path context to the instrument element in the
         * InstrumentTable.xml resource.
         */
        public ThermometerFactory(Xml.XPath.Context path_context) throws Error
        {
            base(path_context);

            factory_id = XmlUtility.get_required_string(
                path_context,
                "./InstrumentFactoryId"
                );

            factory = s_lookup[factory_id];

            if (factory == null)
            {
                throw new ConfigurationError.GENERIC(
                    @"Unknown device $(factory_id)"
                    );
            }
        }


        /**
         * {@inheritDoc}
         */
        public override Instrument create_instrument(Xml.XPath.Context path_context) throws Error

            requires(path_context.node != null)

        {
            var worker = create_worker(path_context);

            return new Thermometer(worker.name, worker);
        }


        /**
         *
         */
        private InstrumentWorker create_worker(Xml.XPath.Context path_context) throws Error
        {
            if (factory == null)
            {
                throw new InternalError.UNKNOWN("NULL");
            }

            var worker = factory.create(path_context);

            if (worker == null)
            {
                throw new InternalError.UNKNOWN("NULL");
            }

            return worker;
        }


        /**
         * Get the static resource compiled with the application
         *
         * The applicaiton generates a SIGSEGV if the reference is owned.
         */
        [CCode(cname="ginstlog_get_resource")]
        private extern static unowned Resource get_resource();


        /**
         *
         */
        private static Gee.Map<string,InstrumentWorkerFactory> s_lookup = null;


        /**
         *
         */
        private static Gee.Map<string,InstrumentWorkerFactory> create_lookup()
        {
            var document = XmlUtility.document_from_resource(
                get_resource(),
                "/com/github/ehennes775/ginstlog/InstrumentFactoryTable.xml",
                ResourceLookupFlags.NONE
                );

            var lookup = new Gee.HashMap<string,InstrumentWorkerFactory>();

            try
            {
                var factories = new InstrumentWorkerFactory[]
                {
                    new Model301WorkerFactory(document),
                    new Model306WorkerFactory(document),
                    new Model309WorkerFactory(document),
                    new Model314WorkerFactory(document)
                };

                foreach (var factory in factories)
                {
                    lookup[factory.id] = factory;
                }
            }
            finally
            {
                delete document;
            }

            return lookup;
        }
    }
}
