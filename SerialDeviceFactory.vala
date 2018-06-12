/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
    public abstract class SerialDeviceFactory
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
        public abstract SerialDevice create() throws Error;
    }
}
