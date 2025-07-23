vim9script noclear

# Vim plugin which allows TeX users to specify where their .bib file is located,
# and provides them a menu to insert a source into their file. 
# Maintainer: Braden Carlson <bradenjcarlson@live.com>

if exists("g:loaded_sourcesmenu")
        finish
endif
g:loaded_sourcesmenu = 1

if has("win32") || has("win64")
        g:win32 = 1
else 
        g:win32 = 0
endif

# the dictionary which will hold all the configuration options specified in
# config file.
var config = {}

var log_file: string

def Run(): void

        # Use the default log file for now
        SetLogFile()

        import autoload "../lib/config/toml.vim" as toml
        var parse_pass = toml.Parse()

        if parse_pass == -1
                g:loaded_sourcesmenu = 0
                return
        endif

        if parse_pass == -2
                echo "sourcesmenu plugin: Found but could not open config file."
                g:loaded_sourcesmenu = 0
                return 
        endif

        # Retry the log file now that the config file has been read. 
        SetLogFile()

        import autoload "../lib/filetype/bib.vim" as bib
        var read_pass = bib.ReadSources()


        if read_pass == -1
                Log("Something went wrong getting the path from the config file.")
                echo "sourcesmenu plugin: something went wrong, please see "
                                        \ .. log_file .. " for more details."
                g:loaded_sourcesmenu = 0
                return
        elseif read_pass == -2
                Log("Something went wrong reading the file specified by 'path' key.")
                echo "sourcesmenu plugin: something went wrong, please see "
                                        \ .. log_file .. " for more details."
                g:loaded_sourcesmenu = 0
                return
        endif

        set wcm=<C-Z>
        map <Leader>s :emenu Sources.<C-Z>

enddef

def g:Insertatcursor(needle: string, offset: number = 0): void
        var haystack = getline('.')
        var idx = getcurpos()[2]
        var part_one = strpart(haystack, 0, idx + offset)
        var part_two = strpart(haystack, idx + offset)
        var new_line = part_one .. needle .. part_two
        call setline('.', new_line)
enddef

def SetLogFile(): void
        try
                log_file = config['config']['log'] 
        catch
                log_file = "./.sourcesmenu.log"
        endtry
enddef

def Log(msg: string): number
        var current_time = strftime("%H:%m:%s", localtime())
        call writefile([current_time .. ": " .. msg], log_file, "a")
        return 0
enddef

        

# Read more into this stuff in the help files. See *write-plugin*
map <Leader>r <Plug>ReloadConfig;

noremap <unique> <script> <Plug>ReloadConfig;  <SID>Run
noremap <SID>Run :call <SID>Run()<CR>

# Finally, actually run the functions here. 
call Run()
