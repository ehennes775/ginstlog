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
    }
}
