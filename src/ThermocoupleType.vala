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
         * Indicates type E thermocouple
         */
        E,


        /**
         * Indicates type J thermocouple
         */
        J,


        /**
         * Indicates type K thermocouple
         */
        K,


        /**
         * Indicates type N thermocouple
         */
        N,


        /**
         * Indicates type R thermocouple
         */
        R,


        /**
         * Indicates type S thermocouple
         */
        S,


        /**
         * Indicates type T thermocouple
         */
        T,


        /**
         * The number of thermocouple types
         */
        COUNT;


        /**
         * Return a string representation of the thermocouple type
         *
         * The string returned by this function is suitable for both debugging
         * and display.
         *
         * @return The string representation of the thermocouple type
         */
        public string to_string()

            requires(this < COUNT)

        {
            switch (this)
            {
                case UNKNOWN:
                    return "UNKNOWN";

                case E:
                    return "E";

                case J:
                    return "J";

                case K:
                    return "K";

                case N:
                    return "N";

                case R:
                    return "R";

                case S:
                    return "S";

                case T:
                    return "T";

                default:
                    return_val_if_reached("UNKNOWN");
            }
        }
    }
}
