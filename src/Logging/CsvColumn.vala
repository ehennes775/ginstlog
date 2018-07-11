/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     * Contains the metadata for a column in a CSV file
     */
    public abstract class CsvColumn : Object
    {
        /**
         * The name of the column in the CSV file
         */
        public int index
        {
            get;
            construct;
        }


        /**
         * The name of the column in the CSV file
         */
        public string name
        {
            get;
            construct;
        }


        /**
         *
         */
        public abstract string get_value(SuccessEntry entry);
    }
}
