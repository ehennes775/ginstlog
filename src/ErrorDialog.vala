/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
    public class ErrorDialog
    {
        /**
         *
         */
        public static void run(Error error, Gtk.Window? parent = null)
        {
            var document = XmlUtility.document_from_resource(
                get_resource(),
                "/com/github/ehennes775/ginstlog/ErrorTable.xml",
                ResourceLookupFlags.NONE
                );

            try
            {
                var error_index = error.code + 1;
                var quark_name = error.domain.to_string();

                var path_context = new Xml.XPath.Context(document);

                var description = XmlUtility.get_optional_string(
                    path_context,
                    @"(//ErrorTable/ErrorDomain[Quark='$(quark_name)']/Error/Description)[$(error_index)]",
                    "Not Found"
                    );

                var dialog = new Gtk.MessageDialog(
                    parent,
                    Gtk.DialogFlags.MODAL,
                    Gtk.MessageType.ERROR,
                    Gtk.ButtonsType.OK,
                    "%s\n\nDomain: %s\nCode: %d\nMessage: %s",
                    description,
                    quark_name,
                    error.code,
                    error.message
                    );

                dialog.title = XmlUtility.get_optional_string(
                    path_context,
                    @"//ErrorTable/ErrorDomain[Quark='$(quark_name)']/Title",
                    "Error"
                    );

                var result = dialog.run();

                dialog.destroy();
            }
            finally
            {
                delete document;
            }
        }


        /**
         * Get the static resource compiled with the application
         *
         * The applicaiton generates a SIGSEGV if the reference is owned.
         */
        [CCode(cname="ginstlog_get_resource")]
        private extern static unowned Resource get_resource();
    }
}
