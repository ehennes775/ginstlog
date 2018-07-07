/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
    public abstract class InstrumentWorker : Object
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
         *
         */
        public abstract Measurement[] read() throws CommunicationError;


        /**
         * Start the background task and thread
         */
        public abstract void start() throws CommunicationError;


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
