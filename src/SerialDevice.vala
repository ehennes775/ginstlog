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
         * Connect to the instrument
         */
        public abstract void connect() throws CommunicationError;


        /**
         * Disconnect from the instrument
         */
        public abstract void disconnect();


        /**
         * Receive a response from an instrument
         *
         * @param length The size of the expected response in bytes
         */
        public abstract uint8[] receive_response(int length) throws CommunicationError;


        /**
         * Receive a response from an instrument
         *
         * This version of receive discards bytes until the start byte is
         * received.
         *
         * @param length The size of the expected response in bytes
         * @param start The first byte of the expected response
         */
        public abstract uint8[] receive_response_with_start(int length, uint8 start) throws CommunicationError;


        /**
         * Send a command to the thermometer
         *
         * @param command The command to send to the thermometer
         */
        public abstract void send_command(uint8[] command) throws CommunicationError;
    }
}
