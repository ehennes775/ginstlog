/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
    public class SerialDeviceFactoryLookup
    {
        /**
         * Initialize a new instance
         */
        public SerialDeviceFactoryLookup()
        {
            m_factory = new Gee.HashMap<string,SerialDeviceFactory>();
        }


        /**
         * Add a factory to the factories
         */
        public void add(SerialDeviceFactory factory) throws Error
        {
            var name = factory.name;

            if (m_factory.has_key(name))
            {
                return_if_reached();
            }

            m_factory[name] = factory;
        }


        /**
         * Create a new SerialDevice
         *
         * Checks the name of the element referenced in the path_context and
         * instantiates the correct serial device.
         *
         * @param path_context
         * @return
         */
        public SerialDevice create(Xml.XPath.Context path_context) throws Error

            requires(path_context.node != null)

        {
            var name = path_context.node->name;

            var factory = m_factory[name];

            if (factory == null)
            {
                stderr.printf(@"Could not find $(name)\n");

                return_val_if_reached(null);
            }

            return factory.create(path_context);
        }


        /**
         *
         */
        private Gee.Map<string,SerialDeviceFactory> m_factory;
    }
}
