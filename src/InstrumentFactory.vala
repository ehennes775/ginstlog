/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * An abstract base class for creating mesaurement devices
     */
    public abstract class InstrumentFactory : Object
    {
        /**
         * The name of the XML element, for this instrument, in the
         * configuration file
         */
        public string element_name
        {
            get;
            private set;
        }


        /**
         * The name of the manufacturer
         */
        public string manufacturer
        {
            get;
            private set;
        }


        /**
         * The model of the instrument
         */
        public string model
        {
            get;
            private set;
        }


        /**
         * A description of the instrument
         */
        public string description
        {
            get;
            private set;
        }


        /**
         * A link to the manufacturer's web page for the instrument
         */
        public string link
        {
            get;
            private set;
        }


        /**
         * Indicates the level of support for the instrument
         */
        public string support
        {
            get;
            private set;
        }


        /**
         * Initialize a new instance
         *
         * @param path_context A path context to the instrument element in the
         * InstrumentTable.xml resource.
         */
        public InstrumentFactory(Xml.XPath.Context path_context) throws Error
        {
            element_name = XmlUtility.get_required_string(
                path_context,
                "./ElementName"
                );

            manufacturer = XmlUtility.get_required_string(
                path_context,
                "./Manufacturer"
                );

            model = XmlUtility.get_required_string(
                path_context,
                "./Model"
                );

            description = XmlUtility.get_required_string(
                path_context,
                "./Description"
                );

            link = XmlUtility.get_required_string(
                path_context,
                "./Link"
                );

            support = XmlUtility.get_required_string(
                path_context,
                "./Support"
                );
        }


        /**
         * Create an instance of an instrument
         *
         * @param path_context A path context to the instrument element in the
         * configuration file.
         * @return The created instrument
         */
        public abstract Instrument create_instrument(Xml.XPath.Context path_context) throws Error;
    }
}
