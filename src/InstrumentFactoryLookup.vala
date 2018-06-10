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
                throw new ConfigurationError.GENERIC(@"");
            }

            var instrument = factory.create_instrument(path_context);

            if (instrument == null)
            {
                throw new ConfigurationError.GENERIC(@"");
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
        private Gee.Map<string,InstrumentFactory> create_lookup()

            ensures(result != null)

        {
            var lookup = new Gee.HashMap<string,InstrumentFactory>();

            lookup["Thermometer"] = new ThermometerFactory();

            return lookup;
        }
    }
}
