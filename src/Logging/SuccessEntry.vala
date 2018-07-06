/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     *
     */
    public class SuccessEntry : Entry
    {
        /**
         *
         *
         * @param time
         */
        public SuccessEntry(int64 time)
        {
        }


        /**
         *
         */
        public override void write_to(Writer writer)
        {
            writer.write_success(this);
        }
    }
}
