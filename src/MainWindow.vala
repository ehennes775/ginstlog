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
            var t = typeof(LoggerWidget);
            stdout.printf(@"static construct $(t)\n");
        }


        /**
         * Initialize the instance
         */
        construct
        {
            var t = typeof(LoggerWidget);
            stdout.printf(@"construct $(t)\n");

            delete_event.connect(on_delete_event);
        }


        /**
         * Construct the main window
         */
        public MainWindow()
        {
            //var sd = new SerialDevice("/dev/ttyUSB0", "2000 ms");
            //var t = new Thermometer(sd);

            var t1 = new ThermometerWidget();
            //t1.instrument = t;

            m_instrument_rack.add(t1);
            m_instrument_rack.add(new ThermometerWidget());
            m_instrument_rack.add(new ThermometerWidget());
        }


        /**
         * Construct the main window using a configuration
         *
         * @param configuration The configuration to use for constructing the
         * MainWindow.
         */
        public MainWindow.with_configuration(Configuration configuration)
        {
            try
            {
                var instruments = configuration.create_instruments();

                foreach (var instrument in instruments)
                {
                    if (instrument.channel_count == 4)
                    {
                        var widget = new FourChannelInstrumentWidget();
                        widget.instrument = instrument;
                        m_instrument_rack.add(widget);
                    }
                    else if (instrument.channel_count == 3)
                    {
                        var widget = new TripleThermometerWidget();
                        widget.instrument = instrument;
                        m_instrument_rack.add(widget);
                    }
                    else
                    {
                        var widget = new ThermometerWidget();
                        widget.instrument = instrument;
                        m_instrument_rack.add(widget);
                    }
                }

                var logger = configuration.create_logger(instruments);
                m_data_logger_widget.logger = logger;
            }
            catch (Error error)
            {
                stderr.printf(@"$(error.message)\n");
            }
        }


        /**
         * The grid widget containing the instruments
         */
        [GtkChild(name="data-logger-widget")]
        private LoggerWidget m_data_logger_widget;


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
