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
        }


        /**
         *
         */
        ~Configuration()
        {
            delete m_document;
        }


        /**
         *
         */
        private Xml.Doc* m_document = null;
    }
}
