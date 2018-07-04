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

            var trigger = new TimeoutTrigger(2000);

            return trigger;
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

            stdout.printf("Creating worker %s\n", path_context.node->name);

            return new LoggerWorker(trigger);
        }
    }
}
