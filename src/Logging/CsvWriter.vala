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
         *
         */
        public FileMode file_mode
        {
            get;
            construct;
        }


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
        public CsvWriter(File file, FileMode file_mode, CsvColumn[] columns, string separator)
        {
            Object(
                file_mode : file_mode,
                separator : separator
                );

            m_column = columns;
            m_file = file;

            if (file_mode == FileMode.APPEND)
            {
                m_stream = new DataOutputStream(file.append_to(
                    FileCreateFlags.NONE,
                    null
                    ));
            }
            else if (file_mode == FileMode.CREATE)
            {
                m_stream = new DataOutputStream(file.create(
                    FileCreateFlags.NONE,
                    null
                    ));

                write_headers();
            }
            else if (file_mode == FileMode.REPLACE)
            {
                m_stream = new DataOutputStream(file.replace(
                    null,
                    false,
                    FileCreateFlags.REPLACE_DESTINATION,
                    null
                    ));

                write_headers();
            }
            else
            {

            }
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

            requires(m_column != null)
            requires(m_stream != null)

        {
            var builder = new StringBuilder();
            var index = 0;

            builder.append(m_column[index++].get_value(entry));

            while (index < m_column.length)
            {
                builder.append(separator);
                builder.append(m_column[index++].get_value(entry));
            }

            builder.append("\n");

            m_stream.put_string(builder.str);
            m_stream.flush();
        }


        /**
         * The columns in the CSV file
         */
        private CsvColumn[] m_column;


        /**
         *
         */
        private File m_file;


        /**
         *
         */
        private DataOutputStream m_stream;


        /**
         *
         */
        private void write_headers()

            requires(m_column != null)
            requires(m_stream != null)

        {
            var builder = new StringBuilder();
            var index = 0;

            builder.append(m_column[index++].name);

            while (index < m_column.length)
            {
                builder.append(separator);
                builder.append(m_column[index++].name);
            }

            builder.append("\n");

            m_stream.put_string(builder.str);
            m_stream.flush();
        }
    }
}
