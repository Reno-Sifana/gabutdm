/*
* Copyright (c) {2024} torikulhabib (https://github.com/gabutakut)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: torikulhabib <torik.habib@Gmail.com>
*/

namespace Gabut {
    public class QrCode : Gtk.Dialog {
        public signal string get_host (bool reboot);
        private Gtk.Image imageqr;
        private Gtk.Image icon_badge;
        private Gtk.LinkButton linkbutton;
        private Gtk.Button host_button;
        private bool local_server;

        public QrCode (Gtk.Application application) {
            Object (application: application,
                    resizable: false,
                    use_header_bar: 1
            );
        }

        construct {
            var icon_image = new Gtk.Image () {
                valign = Gtk.Align.START,
                halign = Gtk.Align.END,
                pixel_size = 64,
                gicon = new ThemedIcon ("com.github.gabutakut.gabutdm.gohome")
            };

            icon_badge = new Gtk.Image () {
                halign = Gtk.Align.END,
                valign = Gtk.Align.END,
                pixel_size = 24
            };

            var overlay = new Gtk.Overlay () {
                child = icon_image
            };
            overlay.add_overlay (icon_badge);

            var primary = new Gtk.Label (_("Scan QR Code")) {
                ellipsize = Pango.EllipsizeMode.END,
                max_width_chars = 35,
                use_markup = true,
                wrap = true,
                xalign = 0,
                attributes = set_attribute (Pango.Weight.ULTRABOLD, 1.6)
            };

            var secondary = new Gtk.Label (_("Address Gabut Server")) {
                ellipsize = Pango.EllipsizeMode.END,
                max_width_chars = 35,
                use_markup = true,
                wrap = true,
                xalign = 0,
                attributes = set_attribute (Pango.Weight.SEMIBOLD, 1.1)
            };

            var header_grid = new Gtk.Grid () {
                halign = Gtk.Align.START,
                valign = Gtk.Align.CENTER,
                column_spacing = 0,
                hexpand = true
            };
            header_grid.attach (overlay, 0, 0, 1, 2);
            header_grid.attach (primary, 1, 0, 1, 1);
            header_grid.attach (secondary, 1, 1, 1, 1);

            var header = get_header_bar ();
            header.title_widget = header_grid;
            header.decoration_layout = "none";

            imageqr = new Gtk.Image () {
                halign = Gtk.Align.START,
                valign = Gtk.Align.START,
                pixel_size = 256,
                margin_start = 10,
                margin_end = 10
            };

            linkbutton = new Gtk.LinkButton ("");
            var link_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER
            };
            link_box.append (linkbutton);

            var close_button = new Gtk.Button.with_label (_("Close")) {
                width_request = 120,
                height_request = 25
            };
            ((Gtk.Label) close_button.get_last_child ()).attributes = set_attribute (Pango.Weight.SEMIBOLD);
            close_button.clicked.connect (()=> {
                close ();
            });

            host_button = new Gtk.Button.with_label (_("Share Host")) {
                width_request = 120,
                height_request = 25
            };
            ((Gtk.Label) host_button.get_last_child ()).attributes = set_attribute (Pango.Weight.SEMIBOLD);
            host_button.clicked.connect (share_server);

            var box_action = new Gtk.Grid () {
                margin_top = 10,
                margin_bottom = 10,
                column_spacing = 10,
                column_homogeneous = true,
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER
            };
            box_action.attach (host_button, 0, 0);
            box_action.attach (close_button, 1, 0);

            get_content_area ().append (imageqr);
            get_content_area ().append (link_box);
            get_content_area ().append (box_action);
        }

        public override void show () {
            base.show ();
            local_server = bool.parse (get_dbsetting (DBSettings.IPLOCAL));
        }

        private void share_server () {
            local_server = !local_server;
            set_dbsetting (DBSettings.IPLOCAL, local_server.to_string ());
            load_host (true);
        }

        public void load_host (bool reboot) {
            if (local_server) {
                host_button.label =_("Share Address");
                ((Gtk.Label) linkbutton.get_last_child ()).attributes = color_attribute (60000, 0, 0);
                icon_badge.gicon = new ThemedIcon ("com.github.gabutakut.gabutdm.pause");
            } else {
                host_button.label = _("Stop Share");
                ((Gtk.Label) linkbutton.get_last_child ()).attributes = color_attribute (60000, 37000, 0);
                icon_badge.gicon = new ThemedIcon ("com.github.gabutakut.gabutdm.active");
            }
            string host = get_host (reboot);
            create_qrcode (host);
            linkbutton.uri = host;
            if (host.contains ("0.0.0.0")) {
                linkbutton.label = _("No Network Connected");
            } else if (host.contains ("127.0.0.1")) {
                linkbutton.label = _("Localhost");
            } else {
                linkbutton.label = host.up ();
            }
        }

        private void create_qrcode (string strinput) {
            var qrencode = new Qrencode.QRcode.encodeData (strinput.length, strinput.data, 1, Qrencode.EcLevel.M);
            int qrenwidth = qrencode.width;
            int sizeqrcode = 200 + qrenwidth * 40;
            var grect = Graphene.Rect ();
            grect.init (0, 0, sizeqrcode, sizeqrcode);
            var snapshot = new Gtk.Snapshot ();
            Cairo.Context context = snapshot.append_cairo (grect);
            context.set_source_rgb (1.0, 1.0, 1.0);
            context.rectangle (0, 0, sizeqrcode, sizeqrcode);
            context.fill ();
            char* qrentdata = qrencode.data;
            for (int y = 0; y < qrenwidth; y++) {
                for (int x = 0; x < qrenwidth; x++) {
                    int rectx = 100 + x * 40;
                    int recty = 100 + y * 40;
                    int digit_ornot = 0;
                    digit_ornot += (*qrentdata & 1);
                    if (digit_ornot == 1) {
                        context.set_source_rgb (0.0, 0.0, 0.0);
                    } else {
                        context.set_source_rgb (1.0, 1.0, 1.0);
                    }
                    context.rectangle (rectx, recty, 40, 40);
                    context.fill ();
                    qrentdata++;
                }
            }
            var grapinsize = Graphene.Size ();
            grapinsize.init ( sizeqrcode, sizeqrcode);
            imageqr.paintable = snapshot.free_to_paintable (grapinsize);
        }
    }
}