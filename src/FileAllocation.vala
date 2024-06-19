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
    public class FileAllocation : Gtk.FlowBoxChild {
        public FileAllocations fileallocation { get; private set; }

        public FileAllocation (FileAllocations fileallocation) {
            this.fileallocation = fileallocation;
            halign = Gtk.Align.CENTER;
            var title = new Gtk.Label (fileallocation.to_string ()) {
                halign = Gtk.Align.CENTER,
                wrap_mode = Pango.WrapMode.WORD_CHAR,
                attributes = set_attribute (Pango.Weight.BOLD),
                tooltip_text = fileallocation.to_tooltip (),
                margin_top = 6,
                margin_bottom = 6,
                margin_start = 12,
                margin_end = 12,
                width_request = 100
            };
            child = title;
            show ();
        }
    }
}
