vim9script

# log.vim
# Author: Braden Carlson

export def Log(msg: string, log_file: string = "./.sourcesmenu.log"): number
        # Writes the message msg to the file specified by log_file, if that
        # file is writable, otherwise the default log file is used. If the
        # default log file is still not writeable, an error message is shown
        # to the user. 
        #
        # Parameters: 
        #   msg: the string to write to the log
        #   log_file: the filename to use
        #
        # Return: 
        #   0: on success
        
        var file = log_file
        if !filewritable(file)
                file = "./.sourcesmenu.log"
        endif
        var current_time = strftime("%H:%M:%S", localtime())
        try
                call writefile([current_time .. ": " .. msg], file, "a")
        catch 
                echo "sourcesmenu plugin: Something went wrong while writing a log messsage."
        endtry

        return 0
enddef
