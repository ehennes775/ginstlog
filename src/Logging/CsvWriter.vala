/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     * Logs measurements to a CSV file
     */
    public class CsvWriter : Writer
    {
        /**
         * The delimiter to separate columns when not specified in the
         * configuration file
         */
        public const string DEFAULT_SEPARATOR = ",";


        /**
         * The delimiter used to separate columns
         */
        public string separator
        {
            get;
            construct;
            default = DEFAULT_SEPARATOR;
        }


        /**
         * Initialize the instance
         *
         * @param columns The columns in the CSV file
         * @param separator The delimiter used to separate columns
         */
        public CsvWriter(CsvColumn[] columns, string separator)
        {
            Object(
                separator : separator
                );

            m_column = columns;
        }


        /**
        * Write an unsuccessful measurement to the log
         *
         * Writes a log entry when unable to make a single successful
         * measurement.
         *
         * @param entry
         */
        public override void write_failure(FailureEntry entry)
        {

        }


        /**
         * Write a successful measurement to the log
         *
         * Writes a log entry when at least one measurement was successful.
         *
         * @param entry
         */
        public override void write_success(SuccessEntry entry)
        {
            var builder = new StringBuilder();
            var index = 0;

            builder.append(entry.get_value(m_column[index++].name));

            while (index < m_column.length)
            {
                builder.append(separator);
                builder.append(entry.get_value(m_column[index++].name));
            }

            stdout.printf("%s\n", builder.str);
        }


        /**
         * The columns in the CSV file
         */
        private CsvColumn[] m_column;


        /**
         *
         */
        private void write_headers()
        {
            var builder = new StringBuilder();
            var index = 0;

            builder.append(m_column[index++].name);

            while (index < m_column.length)
            {
                builder.append(separator);
                builder.append(m_column[index++].name);
            }

            stdout.printf("%s\n", builder.str);
        }
    }
}
