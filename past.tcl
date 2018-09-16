#!/usr/bin/env wish

source db.tcl

#currentPage hold the object of currently edited page

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
    set page [Page new 0 "" ""]
    puts "object name is $page"
    setCurrentPage $page
}

proc save-page { cup } {
    global currentPage

    if {![info exists currentPage]} {
        tk_messageBox -message "Please create new page first"
    } else {
        $currentPage setTitle "[.frame.title get]"
        $currentPage setText "[.frame.text get 0.0 end]"
        $currentPage save
    }
}

proc setCurrentPage { page } {
    global currentPage
    puts "setting as $page"
    set currentPage $page

    .frame.text delete 0.0 end
    .frame.text insert 0.0 [$page getText]
}

proc list-pages {} {
    global currentPage
    set diaryPages [list]
    getPages diaryPages 
    puts "length: [llength $diaryPages]"

    puts "diaryPages: $diaryPages"
    if {[info exists currentPage] && [$currentPage getId] == 0 } {
        lappend diaryPages $currentPage    
    }
    puts "length: [llength $diaryPages]"
    for {set i 0} {$i < [llength $diaryPages]} {incr i} {
        set elem [lindex $diaryPages $i]
        puts "elem... $elem"
        set item [.tree insert {} end]

        .tree item $item -values [list [$elem getTitle] [$elem getText]]

        puts "getTitle: [$elem getTitle]"
        #.tree item $item -values [list wow lol tri]
    }
}


menu .menubar
. configure -menu .menubar

menu .menubar.filemenu -tearoff 0
.menubar.filemenu add command -label "Create new Top level page" -command { new-page }
.menubar.filemenu add command -label "Save" -command { save-page currentPage}
.menubar add cascade -label "File" -menu .menubar.filemenu

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

ttk::treeview .tree -columns {id Title}
.tree heading id -text Id
.tree heading Title -text Title

.pw add .tree -minsize 20
.pw add .frame -minsize 30
pack .pw -fill both -expand yes

list-pages
