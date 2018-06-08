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
            m_document = Xml.Parser.parse_file(configurationFile.get_path());

            if (m_document == null)
            {
                throw new InstrumentError.GENERIC("Unknown");
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
                    var node = path_result->nodesetval->item(index);

                    var instrument = create_instrument(node);

                    instrument_list.add(instrument);
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
            stdout.printf(@"$(node->name)\n");

            return new Thermometer();
        }
    }
}
