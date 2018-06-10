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
        public Instrument create_instrument(Xml.Node* node) throws Error

            requires(m_lookup != null)
            requires(node != null)

        {
            var name = node->name;

            var factory = m_lookup[name];

            if (factory == null)
            {
                throw new ConfigurationError.GENERIC(@"");
            }

            var instrument = factory.create_instrument(node);

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
