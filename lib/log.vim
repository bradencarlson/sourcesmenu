vim9script

export def Log(msg: string, log_file: string = "./.sourcesmenu.log"): number
        var file = log_file
        if !filewritable(file)
                file = "./.sourcesmenu.log"
        endif
        var current_time = strftime("%H:%M:%S", localtime())
        call writefile([current_time .. ": " .. msg], file, "a")
        return 0
enddef
