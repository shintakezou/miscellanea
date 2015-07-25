#! /usr/bin/python

# Usage:
#    ./emulecollector.py COLLECTION_FILE
# a quick&dirty GUI for `ed2k -l` and `ed2k`.

import pygtk
import sys
import subprocess
#pygtk.require("2.0")

import gtk
import gobject


class Interface:
    def __init__(self):
        self.linklist = []
        
        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.window.set_title("Emule collector")
        self.window.connect("delete_event", self.delete_event)
        send_list = gtk.Button("Send to Amule")
        send_list.connect("clicked", self.sendFilesToAmule)
        quit_button = gtk.Button("Quit")
        self.ht = quit_button.size_request()[1]
        quit_button.connect("clicked", lambda w: gtk.main_quit())
        buttons = gtk.HBox()
        buttons.add(send_list)
        buttons.add(quit_button)
        
        self.list_store = gtk.ListStore(gobject.TYPE_BOOLEAN, gobject.TYPE_STRING)
        self.the_list = gtk.TreeView(model=self.list_store)
        sel_rend = gtk.CellRendererToggle()
        col0 = gtk.TreeViewColumn("Selected", sel_rend, active=0)
        self.the_list.append_column(col0)
        link_rend = gtk.CellRendererText()
        col1 = gtk.TreeViewColumn("Link", link_rend, text=1)
        self.the_list.append_column(col1)
        self.the_list.get_selection().connect("changed", self.change_me)
        
        scrolla = gtk.ScrolledWindow()
        scrolla.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_ALWAYS)
        scrolla.add_with_viewport(self.the_list)

        container = gtk.VBox()
        container.add(scrolla)
        container.pack_start(buttons, expand=False, fill=False)
        self.window.add(container)

        
    def list_render(self):
        for t in titles:
            cell = gtk.CellRendererText()
            col = gtk.TreeViewColumn(t, cell)
            self.the_list.append_column(col)


    def addLinksFrom(self, theFile):
        self.linklist = subprocess.check_output(["ed2k", "-l", theFile]).split("\n")
        self.add_links()

    def add_links(self):
        for a_link in self.linklist:
            v = self.list_store.append()
            self.list_store.set_value(v, 0, False)
            self.list_store.set_value(v, 1, a_link)
            

    def delete_event(self, widget, event, data=None):
        gtk.main_quit()
        return False

    def sendFilesToAmule(self, widget, data=None):
        selected_list = []
        self.list_store.foreach(lambda m, p, i, u: selected_list.append(m[i][1]) if m[i][0] else False, 0)
        for lnk in selected_list:
            r = subprocess.call(["ed2k", lnk])
            if r != 0:
                break
            #if r != 0:
            #   warning cannot send link...
        msg = ""
        if r == 0:
            msg_type = gtk.MESSAGE_INFO
            msg = "Everything should be alright"
        else:
            msg = "Something went wrong"
            msg_type = gtk.MESSAGE_ERROR
        dia = gtk.MessageDialog(self.window, type=msg_type, buttons=gtk.BUTTONS_OK)
        dia.set_markup(msg)
        dia.set_default_response(gtk.RESPONSE_OK)
        dia.run()
        dia.destroy()

    def change_me(self, selection):
        (model, it) = selection.get_selected()
        model.set_value(it, 0, not model[it][0])

    def open_up(self):
        s = self.the_list.size_request()
        scr = self.window.get_screen()
        ps = [scr.get_width(), scr.get_height()]
        self.window.set_geometry_hints(None, 300, 10*self.ht, ps[0], ps[1], -1, -1, -1, -1, -1, -1)
        self.window.set_default_size(s[0], 25*self.ht)
        self.window.show_all();



def main():
    gtk.main()
    return 0


if __name__ == "__main__":
    if len(sys.argv) > 1:
        o = Interface()
        o.addLinksFrom(sys.argv[1])
        o.open_up()
        main()
    else:
        print "first argument missing"
        
