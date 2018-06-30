/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
    namespace InstrumentFactoryLookup
    {
        /**
         *
         *
         * @param name
         * @param factory
         * @return
         */
        public void add_instrument_factory(string name, InstrumentFactory factory) throws Error
        {
            if (m_lookup == null)
            {
                m_lookup = create_lookup();

                return_if_fail(m_lookup != null);
            }

            if (m_lookup.has_key(name))
            {
                throw new ConfigurationError.GENERIC(@"");
            }

            m_lookup[name] = factory;
        }


        /**
         *
         *
         * @param node
         * @return
         */
        public static Instrument create_instrument(Xml.XPath.Context path_context) throws Error

            //requires(m_lookup != null)
            requires(path_context.node != null)

        {
            if (m_lookup == null)
            {
                m_lookup = create_lookup();

                return_if_fail(m_lookup != null);
            }

            var name = path_context.node->name;

            var factory = m_lookup[name];

            if (factory == null)
            {
                throw new ConfigurationError.UKNOWN_INSTRUMENT(
                    @"Uknown instrument '$(name)'"
                    );
            }

            var instrument = factory.create_instrument(path_context);

            if (instrument == null)
            {
                throw new ConfigurationError.GENERIC(
                    @"Could not create $(name)"
                    );
            }

            return instrument;
        }


        /**
         *
         */
        private Gee.Map<string,InstrumentFactory> m_lookup = null;


        /**
         *
         */
        private InstrumentFactory create_factory()
        {
            return null;
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
        private Gee.Map<string,InstrumentFactory> create_lookup()

            ensures(result != null)

        {
            var document = XmlUtility.document_from_resource(
                get_resource(),
                "/com/github/ehennes775/ginstlog/InstrumentTable.xml",
                ResourceLookupFlags.NONE
                );

            var lookup = new Gee.HashMap<string,InstrumentFactory>();

            try
            {
                var path_context = new Xml.XPath.Context(document);

                var path_result = path_context.eval_expression(
                    "/InstrumentTable/Instrument"
                    );

                try
                {
                    var count = path_result->nodesetval->length();

                    for (var index = 0; index < count; index++)
                    {
                        try
                        {
                            var node = path_result->nodesetval->item(index);

                            path_context.node = node;

                            var element_name = XmlUtility.get_required_string(
                                path_context,
                                "./ElementName"
                                );

                            lookup[element_name] = new ThermometerFactory(path_context);
                        }
                        catch (Error error)
                        {
                            stderr.printf(@"$(error.message)\n");
                        }
                    }
                }
                finally
                {
                    delete path_result;
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
