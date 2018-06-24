/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
    public abstract class InstrumentWorkerFactory : Object
    {
        /**
         * The value of the id XML attribute, for this instrument worker
         * factory.
         */
        public string id
        {
            get;
            private set;
        }


        /**
         * Initialize the instance
         */
        construct
        {
            m_serial_device_factory_lookup = new SerialDeviceFactoryLookup();

            m_serial_device_factory_lookup.add(
                new TcpSerialServerFactory()
                );

            m_serial_device_factory_lookup.add(
                new TtySerialDeviceFactory()
                );
        }


        /**
         * Initialize a new instance
         *
         * @param path_context A path context to the instrument worker element
         * in the InstrumentTable.xml resource.
         */
        public InstrumentWorkerFactory(Xml.XPath.Context path_context) throws Error
        {
            id = XmlUtility.get_required_string(
                path_context,
                "./@id"
                );
        }


        /**
         * Create an instance of an instrument worker
         *
         * @param path_context A path context to the instrument element in the
         * configuration file.
         * @return The created instrument worker
         */
        public abstract InstrumentWorker create(Xml.XPath.Context path_context) throws Error;


        /**
         *
         */
        protected SerialDeviceFactoryLookup m_serial_device_factory_lookup;


        /**
         *
         */
        protected virtual Channel create_channel(Xml.Node* node) throws Error

            requires(node != null)
            requires(node->doc != null)

        {
            var path_context = new Xml.XPath.Context(node->doc);

            path_context.node = node;

            var index = XmlUtility.get_required_int(
                path_context,
                "./@index"
                );

            var default_name = make_default_channel_name(index);

            var name = XmlUtility.get_optional_string(
                path_context,
                "./Name",
                default_name
                );

            return new Channel(index, default_name, name);
        }


        /**
         *
         */
        protected virtual Channel[] create_channels(Xml.XPath.Context path_context) throws Error
        {
            var path_result = path_context.eval_expression(
                @"./ChannelTable/Channel"
                );

            try
            {
                return_val_if_fail(
                    path_result != null,
                    null
                    );

                return_val_if_fail(
                    path_result->type == Xml.XPath.ObjectType.NODESET,
                    null
                    );

                return_val_if_fail(
                    path_result->nodesetval != null,
                    null
                    );

                var count = path_result->nodesetval->length();

                var channel_table = new Channel[count];

                for (int node_index = 0; node_index < count; node_index++)
                {
                    var node = path_result->nodesetval->item(node_index);

                    var channel = create_channel(node);

                    if ((channel.index < 0) || (channel.index >= count))
                    {
                        throw new ConfigurationError.GENERIC(
                            @"Channel index $(channel.index) out of range [0,$(count))"
                            );
                    }

                    if (channel_table[channel.index] != null)
                    {
                        throw new ConfigurationError.GENERIC(
                            @"Duplicate channel index $(channel.index)"
                            );
                    }

                    channel_table[channel.index] = channel;
                }

                return channel_table;
            }
            finally
            {
                delete path_result;
            }
        }


        /**
         *
         */
        protected virtual SerialDevice create_device(Xml.XPath.Context path_context) throws Error

            requires(m_serial_device_factory_lookup != null)
            requires(path_context.node != null)

        {
            return m_serial_device_factory_lookup.create(path_context);
        }


        /**
         *
         */
        protected virtual SerialDevice create_active_device(Xml.XPath.Context path_context) throws Error
        {
            var active_id = XmlUtility.get_required_string(
                path_context,
                "./DeviceTable/@activeId"
                );

            var device_node = XmlUtility.get_required_node(
                path_context,
                @"./DeviceTable/*[@id=$(active_id)]"
                );

            var device_path_context = new Xml.XPath.Context(device_node->doc);
            device_path_context.node = device_node;

            return create_device(device_path_context);
        }


        /**
         * Create a default name for a thermometer channel
         *
         * @param node The zero based channel index
         * @return A default name for the channel
         */
        private string make_default_channel_name(int index)

            requires(index >= 0)

        {
            return @"T$(index + 1)";
        }
    }
}
