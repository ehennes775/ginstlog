/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
     /**
      * An inner class to separate reference counting
      *
      * The threads and idle process add reference counts to the inner
      * class. The lifespan of an instance of the inner class lasts
      * until the idle process and thread are finished.
      *
      * The rest of the system adds reference counts to the outer class.
      * The lifespan of an instance of the outer class lasts until clients
      * no longer needs the outer class.
      *
      * If reference counting occured on an instance of the same class, then
      * an alternate mechanism would be requred to force garbage collection.
      */
    public abstract class Thermometer3xxWorker : Object
    {
        /**
         * Update UI readouts with a new measurement
         *
         * @param measurement The recent measurement
         */
        public signal void update_readout(Measurement measurement);


        /**
         * The number of channels on the instrument
         */
        public int channel_count
        {
            get;
            construct;
            default = 0;
        }


        /**
         * Provides a user friendly name for the instrument
         */
        public string name
        {
            get;
            construct;
            default = "Instrument";
        }


        /**
         * Start the background task an thread
         */
        public abstract void start();


        /**
         * Stop the background task and thread
         *
         * This function must be called to ensure garbage collection. The
         * object will be freed when the idle background task and thread
         * no longer reference it.
         */
        public abstract void stop();
    }
}
