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
        # Reads the configuration file, the sources file, and creates all the
        # menus which will be used. Finally, if no errors are caught, it sets
        # the keymappings. 

        # Use the default log file for now
        SetLogFile()

        var parse_pass = toml.Parse(config)

        if parse_pass[0] == -1
                # Plugin not used for current project, quit now.
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

        try
                config_location = parse_pass[1]
        catch 
                echo "sourcesmenu plugin: Error parsing config file."
                g:loaded_sourcesmenu = 0
                return
        endtry

        # Now that the config file has been read, use the specified log file,
        # if any.
        SetLogFile()

        # Parse the options found in the config file
        ReadOptions(config)

        # Read the specified source file. 
        var read_pass = ReadFile(path, offset)


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
        # Parse all options specified in a dictionary obtained by reading a
        # config file. 
        #
        # Parameters: 
        #  config_dict - A dictionary obtained from reading a config file. 
        #
        # Returns:
        #  0: always returns zero. 
        #
        # Note: This function should be called after the config file has been
        # succesfully loaded, since it relies on the value of the variable
        # config_location
        
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

def ReadFile(file: string, off: number): number
        # Read the file specified in the config file, searching for entries
        # of interest, and adding them to a menu for access.  This function
        # only calls the appropriate method based on what type of sources
        # file was specified in the config file. 
        #
        # Parameters: 
        #   file: the file to read
        #   off: the offset to use when inserting a string into the current
        #   line. 
        #
        # Returns: 
        #  -1000: In the event an invalid type is specified in the config
        #         file
        #  number: the value returned from the appropriate called function.
        #
        # Note: The offset value (from the parameter off) is used here
        # becuase currently the Read function from the bib script creates the
        # menu, this will be changed in the future. 

        if type == "bib"
                return bib.Read(file, off)
        endif

        logger.Log("Invalid type in config file.", log)

        return -1000
enddef

def g:Insertatcursor(needle: string, off: number = 0): void
        # Inserts a string into the current cursor offition offset by the
        # value of the parameter off. The current line is first split at the
        # currnt position of the cursor plus the offset, then needle is added
        # to the first portion of the line, which is then stiched back
        # together. 
        #
        # Parameters: 
        #  needle: the string to insert into the current line (haystack)
        #  off: the offset to use when splitting the line. 
        #
        # Returns: 
        #  none
        
        var haystack = getline('.')
        var idx = getcurpos()[2]
        var part_one = strpart(haystack, 0, idx + off)
        var part_two = strpart(haystack, idx + off)
        var new_line = part_one .. needle .. part_two
        call setline('.', new_line)
enddef

def SetLogFile(): void
        # Set the log while which will be used. If the config file has not
        # been read yet, the default is ".sourcesmenu.log" in the current
        # directory. 
        
        if !filewritable(log)
                log = "./.sourcesmenu.log"
        endif
enddef

def SetKeyBindings(): void
        # Set the keybindings used to access the menu. First checks to see if
        # the user has specified what keybindings to use, if no keybindings
        # are specified, the default "<Leader>s" is used. 

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
                
# Finally, actually run the functions here. 
call Run()
