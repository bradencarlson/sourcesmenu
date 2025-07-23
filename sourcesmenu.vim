vim9script noclear

# Vim plugin which allows TeX users to specify where their .bib file is located,
# and provides them a menu to insert a source into their file. 
# Maintainer: Braden Carlson <bradenjcarlson@live.com>

if exists("g:loaded_sourcesmenu")
        finish
endif
g:loaded_sourcesmenu = 1

import autoload "./lib/config/toml.vim" as toml
import autoload "./lib/filetype/bib.vim" as bib
import autoload "./lib/log.vim" as logger

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

        var parse_pass = toml.Parse(config)

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

        var read_pass = bib.Read(config)


        if read_pass == -1
                logger.Log("Something went wrong getting the path from the config file.")
                echo "sourcesmenu plugin: something went wrong, please see "
                                        \ .. log_file .. " for more details."
                g:loaded_sourcesmenu = 0
                return
        elseif read_pass == -2
                logger.Log("Something went wrong reading the file specified by 'path' key.")
                echo "sourcesmenu plugin: something went wrong, please see "
                                        \ .. log_file .. " for more details."
                g:loaded_sourcesmenu = 0
                return
        elseif read_pass == -1000
                logger.Log("Something went wrong reading the file specified by 'path' key.")
                echo "sourcesmenu plugin: something went wrong, please see "
                                        \ .. log_file .. " for more details."
                g:loaded_sourcesmenu = 0
                return
        endif

        set wcm=<C-Z>
        map <Leader>s :emenu Sources.<C-Z>

enddef

def ReadFile(): number
        var type: string
        try
                type = config['bibliography']['type']
        catch 
                type = "bib"
        endtry

        if type == "bib"
                import autoload "../lib/filetype/bib.vim" as bib
                return bib.Read(config)
        endif

        logger.Log("Invalid type in config file.")

        return -1000
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

# Read more into this stuff in the help files. See *write-plugin*
map <Leader>r <Plug>ReloadConfig;

noremap <unique> <script> <Plug>ReloadConfig;  <SID>Run
noremap <SID>Run :call <SID>Run()<CR>

# Finally, actually run the functions here. 
call Run()
