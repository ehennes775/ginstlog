/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     *
     */
    public class LoggerFactory : Object
    {
        /**
         *
         */
        static construct
        {
            var writer_lookup = new Gee.HashMap<string,WriterCreator>();

            writer_lookup.set("CsvWriter", CsvWriterFactory.create);

            s_writer_lookup = writer_lookup;
        }


        /**
         *
         * @throw
         */
        public LoggerFactory() // throws ConfigurationError
        {
        }


        /**
         *
         *
         * @param
         * @return
         * @throw
         */
        public Logger create(Xml.XPath.Context path_context) throws ConfigurationError

            requires(path_context.node != null)
            requires(path_context.node->name == ELEMENT_NAME)

        {
            var worker = create_worker(path_context);

            return new Logger(worker);
        }


        /**
         *
         */
        private const string ELEMENT_NAME = "Logger";


        /**
         *
         */
        private static delegate Writer WriterCreator(Xml.XPath.Context path_context) throws ConfigurationError;


        /**
         *
         */
        private static Gee.Map<string,WriterCreator> s_writer_lookup;


        /**
         *
         *
         * @return
         * @throw
         */
        private Trigger create_trigger(Xml.XPath.Context path_context) throws ConfigurationError

            requires(path_context.node != null)

        {

            var active_id = XmlUtility.get_required_string(
                path_context,
                "./TriggerTable/@activeId"
                );

            var triggger_path_context = new Xml.XPath.Context(path_context.doc);

            triggger_path_context.node = XmlUtility.get_required_node(
                path_context,
                @"./TriggerTable/*[@id='$(active_id)']"
                );

            var name = triggger_path_context.node->name;

            var trigger = new TimeoutTrigger(500);

            return trigger;
        }


        /**
         *
         *
         * @return
         * @throw
         */
        private Writer create_writer(Xml.XPath.Context path_context) throws ConfigurationError

            requires(path_context.node != null)

        {
            var active_id = XmlUtility.get_required_string(
                path_context,
                "./WriterTable/@activeId"
                );

            var writer_path_context = new Xml.XPath.Context(path_context.doc);

            writer_path_context.node = XmlUtility.get_required_node(
                path_context,
                @"./WriterTable/*[@id='$(active_id)']"
                );

            var writer_name = writer_path_context.node->name;

            var writer_creator = s_writer_lookup[writer_name];

            if (writer_creator == null)
            {
                throw new ConfigurationError.GENERIC(
                    @"Unknown writer type $(writer_name)"
                    );
            }

            var writer = writer_creator(writer_path_context);

            return writer;
        }


        /**
         *
         *
         * @return
         * @throw
         */
        private LoggerWorker create_worker(Xml.XPath.Context path_context) throws ConfigurationError

            requires(path_context.node != null)
            requires(path_context.node->name == ELEMENT_NAME)

        {
            var trigger = create_trigger(path_context);
            var writer = create_writer(path_context);

            stdout.printf("Creating worker %s\n", path_context.node->name);

            return new LoggerWorker(trigger, writer);
        }
    }
}
