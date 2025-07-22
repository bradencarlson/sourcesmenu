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

        var parse_pass = ParseToml()

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

        var read_pass = g:bib#ReadSources(config)

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


# Function to read in a toml file and create a dictionary (of dictionaries)
# containing all the table names and key, value pairs in each table. 
def ParseToml(): number 

        # Name of the config file. 
        var filename = "sourcesmenu.toml"

        # List of places to look for the file, in order of precedence. 
        var prefix: list<string>
        if g:win32 == 1
                prefix = [""]
        else
                prefix = ["./.", "~/.", "~/.config/sourcesmenu/"]
        endif

        var file_location = filename

        var found = 0

        for pre in prefix
                if filereadable(expand(pre .. filename))
                        file_location = pre .. filename
                        found = 1
                        break
                endif
        endfor

        if found == 0
                # This error code indicates that this plugin is not currently
                # being used. 
                return -1
        endif

        var config_file: list<string>
        try 
                config_file = readfile(expand(file_location))
        catch 
                # This code indicates that something went wrong with reading the
                # config file.
                return -2
        endtry

        var key: string
        for line in config_file
                # If the line is the beginning of a table, then add it as a key
                # to the config dictionary.
                if match(line, '\s*\[.\+\]\s*') != -1
                        key = substitute(line, '\s*\[\|\]\s*', "", "g")

                        # Make sure the key is something that we expect. key
                        # should match ^[a-z]+$
                        if match(key, '\v^[a-z]+$') != -1
                                config[key] = {}
                        else 
                                Log("Invalid table name: " .. key)
                        endif
                else 
                        # make sure the line is not empty before continuing
                        if match(line, '.') != -1

                                # otherwise, add the key and value to a
                                # subdictionary corresponding to the current
                                # key. 
                                var sub_key = substitute(line, '\v\s*\=.*', '', "g")
                                var value = substitute(line, '\v\s*\l*\s*\=\s*', '', "g")
                                value = substitute(value, '"', '', "g")

                                # Check to make sure the sub_key and value are
                                # what we expect them to be. sub_key should
                                # match ^[a-z]+$ and value should match 
                                # ^[a-z.]+$ (This is subject to change, since
                                # there could be other chars in a filename)
                                if match(sub_key, '\v^[a-z]+$') != -1 && match(value, '\v^[a-z.]+$|^-?[0-9]+$') != -1
                                        config[key][sub_key] = value
                                else 
                                        Log("Invalid key or value: " .. sub_key .. " = " .. value)
                                endif
                        endif

                endif
        endfor

        return 0

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
