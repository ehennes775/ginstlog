/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Stores channel metadata for measurements
     */
    public class Channel : Object
    {
        /**
         * The channel name given by the instrument (e.g. T1)
         */
        public string default_name
        {
            get;
            construct;
        }


        /**
         * The zero based index of the channel
         */
        public int index
        {
            get;
            construct;
        }


        /**
         * A name for the channel given by the user (e.g. Ambient)
         */
        public string name
        {
            get;
            construct;
        }


        /**
         * Initialize a new channel
         *
         * @param index The zero based index of the channel
         * @param default_name The channel name given by the instrument
         * @param name A name for the channel given by the user
         */
        public Channel(int index, string default_name, string? name = null)

            requires(default_name.length > 0)
            requires(index >= 0)

        {
            Object(
                index : index,
                default_name : default_name,
                name : name ?? default_name
                );
        }
    }
}
