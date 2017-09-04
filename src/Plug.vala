// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2014-2017 elementary LLC. (https://launchpad.net/switchboard-plug-security-privacy)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Corentin Noël <tintou@mailoo.org>
 */

namespace SecurityPrivacy {

    public static Plug plug;
    public static Gtk.LockButton lock_button;
    public static Blacklist blacklist;
    public static LocationPanel location;
    public static FirewallPanel firewall;
    public static TrackPanel tracking;

    public class Plug : Switchboard.Plug {
        Gtk.Grid main_grid;
        Gtk.Stack stack;

        ServiceList service_list;

        bool location_agent_installed = false;

        public Plug () {
            Object (category: Category.PERSONAL,
                    code_name: Build.PLUGCODENAME,
                    display_name: _("Security & Privacy"),
                    description: _("Configure firewall, screen lock, and activity information"),
                    icon: "preferences-system-privacy",
                    supported_settings: new Gee.TreeMap<string, string?> (null, null));

            location_agent_installed = SecurityPrivacy.LocationPanel.location_agent_installed ();
            supported_settings.set ("security", null);
            supported_settings.set ("security/privacy", "tracking");
            supported_settings.set ("security/firewall", "firewall");
            supported_settings.set ("security/screensaver", "locking");
            
            if (location_agent_installed) {
                supported_settings.set ("security/privacy/location", "location");
            }
            plug = this;
        }

        public override Gtk.Widget get_widget () {
            if (main_grid == null) {
                main_grid = new Gtk.Grid ();
            }

            if (blacklist == null) {
                blacklist = new Blacklist ();
            }

            return main_grid;
        }

        public override void shown () {
            if (main_grid.get_children ().length () > 0) {
                return;
            }

            stack = new Gtk.Stack ();

            var grid = new Gtk.Grid ();
            grid.attach (stack, 0, 3, 1, 1);

            try {
                var permission = new Polkit.Permission.sync ("org.pantheon.security-privacy", new Polkit.UnixProcess (Posix.getpid ()));

                var label = new Gtk.Label (_("Some settings require administrator rights to be changed"));

                var infobar = new Gtk.InfoBar ();
                infobar.message_type = Gtk.MessageType.INFO;
                infobar.no_show_all = true;
                infobar.get_content_area ().add (label);

                grid.attach (infobar, 0, 0, 1, 1);

                lock_button = new Gtk.LockButton (permission);

                var area = infobar.get_action_area () as Gtk.Container;
                area.add (lock_button);

                stack.notify["visible-child-name"].connect (() => {
                    if (permission.allowed == false && stack.visible_child_name == "firewall") {
                        infobar.no_show_all = false;
                        infobar.show_all ();
                    } else {
                        infobar.no_show_all = true;
                        infobar.hide ();
                    }
                });

                permission.notify["allowed"].connect (() => {
                    if (permission.allowed == false && stack.visible_child_name == "firewall") {
                        infobar.no_show_all = false;
                        infobar.show_all ();
                    } else {
                        infobar.no_show_all = true;
                        infobar.hide ();
                    }
                });
            } catch (Error e) {
                critical (e.message);
            }

            tracking = new TrackPanel ();
            var locking = new LockPanel ();
            firewall = new FirewallPanel ();

            stack.add_titled (tracking, "tracking", _("Privacy"));
            stack.add_titled (locking, "locking", _("Locking"));
            stack.add_titled (firewall, "firewall", _("Firewall"));

            if (location_agent_installed) {
                location = new LocationPanel ();
                stack.add_titled (location, "location", _("Location Services"));
            }                

            service_list = new ServiceList ();

            var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            paned.position = 200;
            paned.add1 (service_list);
            paned.add2 (grid);

            main_grid.add (paned);
            main_grid.show_all ();

            service_list.row_selected.connect ((row) => {
                var title = ((ServiceItem)row).title;
                stack.visible_child_name = title;
            });
        }

        public override void hidden () {
            
        }

        public override void search_callback (string location) {
            if (main_grid.get_children ().length () == 0)
                shown ();

            switch (location) {
                case "privacy":
                    stack.set_visible_child_name ("tracking");
                    service_list.select_service_name ("tracking");
                    break;
                case "locking":
                    stack.set_visible_child_name ("locking");
                    service_list.select_service_name ("locking");
                    break;
                case "locking<sep>privacy-mode":
                    stack.set_visible_child_name ("locking");
                    service_list.select_service_name ("locking");
                    break;
                case "firewall":
                    stack.set_visible_child_name ("firewall");
                    service_list.select_service_name ("firewall");
                    break;
                case "location":
                    stack.set_visible_child_name ("location");
                    service_list.select_service_name ("location");
                    break;
            }
        }

        // 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior")
        public override async Gee.TreeMap<string, string> search (string search) {
            var map = new Gee.TreeMap<string, string> (null, null);
            map.set ("%s → %s".printf (display_name, _("Privacy")), "privacy");
            map.set ("%s → %s".printf (display_name, _("Locking")), "locking");
            map.set ("%s → %s → %s".printf (display_name, _("Locking"), _("Privacy Mode")), "locking<sep>privacy-mode");
            map.set ("%s → %s".printf (display_name, _("Firewall")), "firewall");
            if (location_agent_installed) {
                map.set ("%s → %s".printf (display_name, _("Location Services")), "location");
            }
            return map;
        }
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Security & Privacy plug");
    var plug = new SecurityPrivacy.Plug ();
    return plug;
}
