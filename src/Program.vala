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
                var window = new MainWindow();

                return_if_fail(window != null);

                this.add_window(window);

                window.show_all();
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
                    var configuration = new Configuration(file);

                    var window = new MainWindow.with_configuration(configuration);

                    return_if_fail(window != null);

                    this.add_window(window);

                    window.show_all();
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
                var provider = new Gtk.CssProvider();

                provider.load_from_resource("/com/github/ehennes775/ginstlog/ginstlog.css");

                Gtk.StyleContext.add_provider_for_screen(
                    Gdk.Screen.get_default(),
                    provider,
                    600
                    );
            }
            catch (Error error)
            {
                stderr.printf("%s\n", error.message);
            }
        }
    }
}
