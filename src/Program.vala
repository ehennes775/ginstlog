/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
    public class Program : Gtk.Application
    {
        /**
         * Construct the program
         */
        public Program()
        {
            Object(
                application_id: "com.github.ehennes775.ginstlog",
                flags: ApplicationFlags.HANDLES_OPEN
                );
        }


        /**
         * The program entry point
         */
        public static void main(string[] args)
        {
            try
            {
                new Program().run(args);
            }
            catch (Error error)
            {
                stderr.printf("%s\n", error.message);
            }
        }


        /**
         * Create a new main window
         */
        protected override void activate()
        {
            try
            {
            }
            catch (Error error)
            {
                stderr.printf("%s\n", error.message);
            }
        }


        /**
         * Open files along with a new window for each file.
         *
         * @param files The files to open
         * @param hint unused
         */
        protected override void open(File[] files, string hint)
        {
            foreach (var file in files)
            {
                try
                {
                }
                catch (Error error)
                {
                    stderr.printf("%s\n", error.message);
                }
            }
        }


        /**
         * Called after the applicaton is registered
         */
        protected override void startup()
        {
            base.startup();

            try
            {
            }
            catch (Error error)
            {
                stderr.printf("%s\n", error.message);
            }
        }
    }
}
