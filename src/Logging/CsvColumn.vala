/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     * Contains the metadata for a column in a CSV file
     */
    public class CsvColumn : Object
    {
        /**
         * The name of the column in the CSV file
         */
        public string name
        {
            get;
            construct;
        }


        /**
         * Initialize the instance
         *
         * @param name The name of the column in the CSV file
         */
        public CsvColumn(string name)
        {
            Object(
                name : name
                );
        }
    }
}
