/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
    public class Configuration : Object
    {
        /**
         *
         *
         * @param configurationFile
         */
        public Configuration(File configurationFile) throws Error
        {
            var path = configurationFile.get_path();

            m_document = Xml.Parser.parse_file(path);

            if (m_document == null)
            {
                throw new ConfigurationError.FILE_NOT_FOUND(
                    @"Unable to locate file '$(path)'"
                    );
            }

            m_path_context = new Xml.XPath.Context(m_document);
        }


        /**
         *
         */
        ~Configuration()
        {
            delete m_document;
        }


        /**
         * Create the instruments in this configuration
         *
         * @return The instruments in this configuration
         */
        public Gee.List<Instrument> create_instruments() throws Error

            requires(m_document != null)
            requires(m_path_context != null)

        {
            var path_result = m_path_context.eval_expression(
                "/Configuration/InstrumentTable/*"
                );

            try
            {
                var instrument_list = new Gee.ArrayList<Instrument>();

                return_val_if_fail(
                    path_result != null,
                    instrument_list
                    );

                return_val_if_fail(
                    path_result->type == Xml.XPath.ObjectType.NODESET,
                    instrument_list
                    );

                return_val_if_fail(
                    path_result->nodesetval != null,
                    instrument_list
                    );

                var count = path_result->nodesetval->length();

                for (var index = 0; index < count; index++)
                {
                    try
                    {
                        var node = path_result->nodesetval->item(index);

                        var instrument = create_instrument(node);

                        instrument_list.add(instrument);
                    }
                    catch (Error error)
                    {
                        stderr.printf(@"$(error.message)\n");
                    }
                }

                return instrument_list;
            }
            finally
            {
                delete path_result;
            }
        }


        /**
         *
         */
        public Logging.Logger create_logger() throws ConfigurationError
        {
            var path_context = new Xml.XPath.Context(m_document);

            var active_id = XmlUtility.get_required_string(
                path_context,
                "/Configuration/LoggerTable/@activeId"
                );

            path_context.node = XmlUtility.get_required_node(
                path_context,
                @"/Configuration/LoggerTable/Logger[@id='$(active_id)']"
                );

            return s_logger_factory.create(path_context);
        }


        /**
         *
         */
        private static Logging.LoggerFactory s_logger_factory = new Logging.LoggerFactory();


        /**
         *
         */
        private Xml.Doc* m_document = null;


        /**
         *
         */
        private Xml.XPath.Context m_path_context = null;


        /**
         *
         */
        private Instrument create_instrument(Xml.Node* node) throws Error

            requires(node != null)

        {
            var path_context = new Xml.XPath.Context(m_document);

            path_context.node = node;

            return InstrumentFactoryLookup.create_instrument(path_context);
        }
    }
}
