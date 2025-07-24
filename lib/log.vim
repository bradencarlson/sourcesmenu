vim9script

export def Log(msg: string, log_file: string = "./.sourcesmenu.log"): number
        if !filewritable(log_file)
                log_file = "./.sourcesmenu.log"
        endif
        var current_time = strftime("%H:%m:%s", localtime())
        call writefile([current_time .. ": " .. msg], log_file, "a")
        return 0
enddef
