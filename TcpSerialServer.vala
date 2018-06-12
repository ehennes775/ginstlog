/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Provides serial communications with an instrument
     */
    public abstract class SerialDevice : Object
    {
        /**
         *
         */
        public abstract void connect();


        /**
         *
         */
        public abstract void disconnect();


        /**
         * Receive a response from the thermometer
         *
         * @param size The size of the expected response in characters
         */
        public abstract uint8[] receive_response(int length) throws Error;


        /**
         * Send a command to the thermometer
         *
         * @param command The command to send to the thermometer
         */
        public abstract void send_command(uint8[] command) throws Error;
    }
}
