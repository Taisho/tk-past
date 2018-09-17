#!/usr/bin/env wish

source db.tcl

#currentPage hold the object of currently edited page

#the index of "Delete Page" item in the Page menu
set men_delete_page 0

#menu .mb
#.mb add cascade -label System -menu .mb.system
#. configure -menu .mb
#
#.mb add command -label "File"
#
#menu .mb.system
#.mb.system add command -label "foo"

#proc open-file {} {
#    set filename [tk_getOpenFile \
#                  -title "Select File..." ]
#    #set filename [::tk::dialog::file:: open]
#}

proc new-page {} {
    global men_delete_page

    set page [Page new 0 "" ""]
    puts "object name is $page"
    setCurrentPage $page
    .menubar.pagemenu entryconfigure $men_delete_page -state disabled
}

proc open-page {} {
    global currentPage
    global men_delete_page

    set selection [.tree selection]
    if {[llength [list [split $selection { }]]] == 1} {
        set values [.tree item $selection -values]
        set id [lindex $values 0]

        #set currentPage [getPage $id]
        setCurrentPage [getPage $id]

        .menubar.pagemenu entryconfigure $men_delete_page -state normal
    }
}

proc save-page {} {
    global currentPage

    if {![info exists currentPage]} {
        tk_messageBox -message "Please create new page first"
    } else {
        $currentPage setTitle "[.frame.title get]"
        $currentPage setText "[.frame.text get 0.0 end]"
        $currentPage save
        list-pages
    }
}

proc setCurrentPage { page } {
    global currentPage
    puts "setting as $page"
    set currentPage $page

    .frame.text delete 0.0 end
    .frame.text insert 0.0 [$page getText]

    .frame.title delete 0 end
    .frame.title insert 0 [$page getTitle]

}

proc list-pages {} {
    global currentPage

    # Remove current items in the grid

    .tree delete [.tree children {}]

    set diaryPages [list]
    getPages diaryPages 
    puts "length: [llength $diaryPages]"

#    puts "diaryPages: $diaryPages"
#    if {[info exists currentPage] && [$currentPage getId] == 0 } {
#        lappend diaryPages $currentPage    
#    }
    puts "length: [llength $diaryPages]"
    for {set i 0} {$i < [llength $diaryPages]} {incr i} {
        set elem [lindex $diaryPages $i]
        puts "elem... $elem"
        set item [.tree insert {} end -values [list [$elem getId] [$elem getTitle]]]

        puts "getTitle: [$elem getTitle]"
        #.tree item $item -values [list wow lol tri]
    }
}

proc deletePageGUI {} {
    global currentPage

    if {[winfo exists currentPage]} {
        messageBox -message {Please select a page first}
    } else {
        deletePage [$currentPage getId]
        list-pages
        new-page
    }
}

namespace eval ::kbd {
    variable ctrlPressed 0
    variable s_Pressed 0
    
    variable lock_Ctrl_s 0
    variable handler_Ctrl_s {}

    proc setHandler { seq script } {
        variable handler_Ctrl_s

        eval "set handler_$seq {$script} "
    }

    proc handle {} {
        variable ctrlPressed
        variable s_Pressed
        variable lock_Ctrl_s
        variable handler_Ctrl_s

        if { $ctrlPressed == 1 && $s_Pressed == 1 && $lock_Ctrl_s == 0} {
            set lock_Ctrl_s 1
            puts {eval $handler_Ctrl_s}
            eval $handler_Ctrl_s
        }
    }

    proc key-press { n k } {
        variable ctrlPressed
        variable s_Pressed
        variable lock_Ctrl_s

        switch -- $k Control_L {
            set ctrlPressed 1
        } s {
            set s_Pressed 1
        } 

        handle
        puts "press:$k"
    }

    proc key-release { n k } {
        variable ctrlPressed
        variable s_Pressed
        variable lock_Ctrl_s

        switch -- $k Control_L {
            set ctrlPressed 0
        } s {
            set s_Pressed 0
        } 

        if { $s_Pressed == 0 && $ctrlPressed == 0} {
            set lock_Ctrl_s 0
        }

        puts "release:$k"
    }
}

 #     
 ## 
 ### Create standart menus (at the top of the window)
 ##
 #

menu .menubar
. configure -menu .menubar

# File
menu .menubar.filemenu -tearoff 0
.menubar.filemenu add command -label "Create new Top level page" -command { new-page }
.menubar.filemenu add command -label "Save" -command { save-page }
.menubar.filemenu add separator
.menubar.filemenu add command -label "Exit" -command { exit }
.menubar add cascade -label "File" -menu .menubar.filemenu

# Page
menu .menubar.pagemenu -tearoff 0
.menubar.pagemenu add command -label "Delete selected page" -command { deletePageGUI }
.menubar.pagemenu add command -label "Refresh Pages" -command { list-pages }
.menubar add cascade -label "Page" -menu .menubar.pagemenu

# Format
menu .menubar.formatmenu -tearoff 0
.menubar.formatmenu add command -label "Bold" -state disabled 
.menubar.formatmenu add command -label "Italics" -state disabled 
.menubar.formatmenu add separator
.menubar.formatmenu add command -label "Font Size" -state disabled
.menubar add cascade -label "Format" -menu .menubar.formatmenu

 #     
 ## 
 ### Assembling our window
 ##
 #

panedwindow .pw -orient vertical
frame .frame
text .frame.text
label .frame.label_title -text "Title" -anchor nw
label .frame.label_text -text "Contents" -anchor nw
entry .frame.title
pack .frame.label_title -fill x -expand no 
pack .frame.title -fill x -expand no 
pack .frame.label_text -fill x -expand no 
pack .frame.text -fill both -expand yes
#StatusBar .status

 #     
 ## 
 ### Binding keyboard events to the text widget
 ##
 #

bind .frame.text <<Selection>> { }


 #     
 ## 
 ### Now working on the treview widget
 ##
 #

ttk::treeview .tree -columns {id Title}
.tree heading id -text Id
.tree heading Title -text Title
.tree column #0 -width 10 -stretch 0
.tree column id -width 30 -stretch 0


bind .tree <<TreeviewSelect>> { open-page }

 #     
 ## 
 ### Pack the treeview and the frame in the PanedWindow
 ##
 #

bind . <KeyPress> { ::kbd::key-press %N %K }
bind . <KeyRelease> { ::kbd::key-release %N %K }
::kbd::setHandler Ctrl_s { save-page }

.pw add .tree -minsize 20
.pw add .frame -minsize 30
pack .pw -fill both -expand yes

list-pages
new-page
