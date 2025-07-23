vim9script

export def Log(msg: string): number
        var current_time = strftime("%H:%m:%s", localtime())
        call writefile([current_time .. ": " .. msg], log_file, "a")
        return 0
enddef
