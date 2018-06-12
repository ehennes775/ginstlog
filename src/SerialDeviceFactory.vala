/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
    public abstract class SerialDeviceFactory : Object
    {
        /**
         *
         */
        public string name
        {
            get;
            construct;
        }


        /**
         *
         */
        public abstract SerialDevice create(Xml.XPath.Context path_context) throws Error;
    }
}
