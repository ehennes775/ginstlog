/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Represents units for temperature measurements
     */
    public enum TemperatureUnits
    {
        /**
         * Indicates the temperature units are not known
         */
        UNKNOWN,


        /**
         * Indicates measurements made in Celsius
         */
        CELSIUS,


        /**
         * Indicates measurements made in Fahrenheit
         */
        FAHRENHEIT,


        /**
         * Indicates measurements made in Kelvin
         */
        KELVIN,


        /**
         * The number of temperature units
         */
        COUNT;


        /**
         * Return a string representation of the units
         *
         * The string returned by this function is suitable for both debugging
         * and display.
         *
         * @return The string representation of the units
         */
        public string to_string()
        {
            return_val_if_fail(this < COUNT, "\u00B0");

            switch (this)
            {
                case UNKNOWN:
                    return "\u00B0";

                case CELSIUS:
                    return "\u00B0C";

                case FAHRENHEIT:
                    return "\u00B0F";

                case KELVIN:
                    return "K";

                default:
                    return_val_if_reached("\u00B0");
            }
        }
    }
}
