/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    [GtkTemplate(ui="/com/github/ehennes775/ginstlog/MainWindow.ui.xml")]
    public class MainWindow : Gtk.ApplicationWindow
    {
        /**
         * The name of the program as it appears in the title bar
         */
        [CCode(cname = "PACKAGE_NAME")]
        private static extern const string PROGRAM_TITLE;


        /**
         * Initialize the class
         */
        static construct
        {
        }


        /**
         * Initialize the instance
         */
        construct
        {
            delete_event.connect(on_delete_event);

            var t = new Thermometer();

            var t1 = new ThermometerWidget();
            t1.instrument = t;

            m_instrument_rack.add(t1);
            m_instrument_rack.add(new ThermometerWidget());
            m_instrument_rack.add(new ThermometerWidget());
        }


        /**
         * Construct the main window
         */
        public MainWindow()
        {
        }


        /**
         * Construct the main window using a configuration
         *
         * @param configuration The configuration to use for constructing the
         * MainWindow.
         */
        public MainWindow.with_configuration(Configuration configuration)
        {
        }


        /**
         * The grid widget containing the instruments
         */
        [GtkChild(name="instrument-rack-grid")]
        private Gtk.Grid m_instrument_rack;


        /**
         * An event handler when the user selects the delete button
         *
         * @return true Abort the destruction process
         * @return false Continue with the destruction process
         */
        private bool on_delete_event(Gdk.EventAny event)
        {
            return false;
        }

    }
}
