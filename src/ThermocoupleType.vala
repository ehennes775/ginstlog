/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Represents the type of a thermocouple
     */
    public enum ThermocoupleType
    {
        /**
         * Indicates an unknown thermocouple
         */
        UNKNOWN,


        /**
         * Indicates J type thermocouple
         */
        J,


        /**
         * Indicates K type thermocouple
         */
        K,


        /**
         * The number of thermocouple types
         */
        COUNT;
    }
}
