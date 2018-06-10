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
         *
         *
         * @param node
         * @return
         */
        public abstract Instrument create_instrument(Xml.Node* node) throws Error;
    }
}
