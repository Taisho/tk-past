package require sqlite3

sqlite3 db ./past.db

db eval {
    CREATE TABLE IF NOT EXISTS Page (
        id INTEGER PRIMARY KEY,
        title TEXT,
        text TEXT
    )
}

oo::class create Page {
    constructor { id_ title_ text_ } {
        my variable id
        set id $id_
        my variable title
        set title $title_
        my variable text
        set text $text_
    }

    method getText {} {
        my variable text
        return $text
    }

    method getTitle {} {
        my variable title
        return $title
    }

    method getId {} {
        my variable id 
        return $id
    }

    method setText { in_text } {
        my variable text
        set text $in_text
    }

    method setTitle { in_title } {
        my variable text
        set text $in_title
    }

    method save {} {
        my variable id
        my variable text
        my variable title

        if { $id == 0 } {
            db eval {
                INSERT INTO page
                (text, title)
                VALUES ( $text, $title )
            }
        } else {
            db eval {
                UPDATE page 
                SET text = $text,
                title = $title
                WHERE id == $id
            }

            set id [db last_insert_rowid]
        }
    }
}

proc getPages { list } {
    upvar $list pages

    db eval {SELECT * FROM Page} {
        upvar pages pagess
        lappend pages [Page new $id $title $text]
        puts "from Page: $id $title $text"
    }

    puts "length: [llength $pages]"
}
