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
var config_location: string
var path: string
var type: string
var offset: number
var pop_up: number
var log: string

def Run(): void

        # Use the default log file for now
        SetLogFile()

        var parse_pass = toml.Parse(config)

        if parse_pass[0] == -1
                g:loaded_sourcesmenu = 0
                return
        elseif parse_pass[0] == -2
                echo "sourcesmenu plugin: Found but could not open config file."
                g:loaded_sourcesmenu = 0
                return 
        elseif parse_pass[0] == -1000
                echo "sourcesmenu plugin: Error parsing config file."
                g:loaded_sourcesmenu = 0
                return 
        endif

        config_location = parse_pass[1]

        # Retry the log file now that the config file has been read. 
        SetLogFile()

        # Parse the options found in the config file
        ReadOptions(config)

        # Read the sources file found in the config file.
        var read_pass = ReadFile()


        if read_pass == -1
                logger.Log("Something went wrong getting the path from the config file.", log)
                echo "sourcesmenu plugin: something went wrong, please see "
                                        \ .. log .. " for more details."
                g:loaded_sourcesmenu = 0
                return
        elseif read_pass == -2
                logger.Log("Something went wrong reading the file specified by 'path' key.", log)
                echo "sourcesmenu plugin: something went wrong, please see "
                                        \ .. log .. " for more details."
                g:loaded_sourcesmenu = 0
                return
        elseif read_pass == -1000
                logger.Log("Something went wrong reading the file specified by 'path' key.", log)
                echo "sourcesmenu plugin: something went wrong, please see "
                                        \ .. log .. " for more details."
                g:loaded_sourcesmenu = 0
                return
        endif

        # Set keybindings, if user has not already done so. 
        SetKeyBindings()

enddef

def ReadOptions(config_dict: dict<any>): number
        try 
                path = config_location .. config_dict['bibliography']['path']
        catch 
                path = config_location .. ".sources.bib"
        endtry

        try 
                type = config_dict['bibliography']['type']
        catch 
                type = "bib"
        endtry

        try 
                offset = str2nr(config_dict['config']['offset'])
        catch 
                offset = 0
        endtry

        try 
                log = config_location .. config_dict['config']['log']
        catch 
                log = config_location .. ".sourcesmenu.log"
        endtry

        try 
                pop_up = str2nr(config_dict['config']['popup'])
        catch 
                pop_up = 0
        endtry

        return 0

enddef

def ReadFile(): number

        if type == "bib"
                return bib.Read(path, offset)
        endif

        logger.Log("Invalid type in config file.", log)

        return -1000
enddef



def g:Insertatcursor(needle: string, pos: number = 0): void
        var haystack = getline('.')
        var idx = getcurpos()[2]
        var part_one = strpart(haystack, 0, idx + pos)
        var part_two = strpart(haystack, idx + pos)
        var new_line = part_one .. needle .. part_two
        call setline('.', new_line)
enddef

def SetLogFile(): void
        if !filewritable(log)
                log = "./.sourcesmenu.log"
        endif
enddef


def SetKeyBindings(): void

        # Read more into this stuff in the help files. See *write-plugin*
        if !hasmapto("<Plug>ReloadConfig;")
                map <Leader>r <Plug>ReloadConfig;
        endif

        noremap <unique> <script> <Plug>ReloadConfig;  <SID>Run
        noremap <SID>Run :call <SID>Run()<CR>

        if pop_up > 0
                if !hasmapto(":popup Sources<CR>")
                        map <leader>s :popup Sources<CR>
                endif
        else
                set wcm=<C-Z>

                if !hasmapto(":emenu Sources")
                        map <leader>s :emenu Sources.<C-Z>
                endif
        endif
enddef
                
def Log(msg: string): number
        var current_time = strftime("%H:%m:%s", localtime())
        call writefile([current_time .. ": " .. msg], log, "a")
        return 0
enddef

# Finally, actually run the functions here. 
call Run()
