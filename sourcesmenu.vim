vim9script noclear

# Vim plugin which allows TeX users to specify where their .bib file is located,
# and provides them a menu to insert a source into their file. 
# Maintainer: Braden Carlson <bradenjcarlson@live.com>

if exists("g:loaded_sourcesmenu")
        finish
endif
g:loaded_sourcesmenu = 1

# the dictionary which will hold all the configuration options specified in
# config file.
var config = {}


# Function to read in a toml file and create a dictionary (of dictionaries)
# containing all the table names and key, value pairs in each table. 
def ParseToml(): number 

        # Name of the config file. 
        var filename = ".test.toml"

        # List of places to look for the file, in order of precedence. 
        var prefix = ["./", "~/", "~/.config/sourcesmenu/"]

        var file_location = filename

        for pre in prefix
                if filereadable(expand(pre .. filename))
                        file_location = pre .. filename
                        break
                endif
        endfor

        var config_file = readfile(expand(file_location))

        var key: string
        for line in config_file
                # If the line is the beginning of a table, then add it as a key
                # to the config dictionary. 
                if match(line, '\s*\[\l\+\]\s*') != -1
                        key = substitute(line, '\s*\[\|\]\s*', "", "g")
                        config[key] = {}
                else 
                        # make sure the line is not empty before continuing
                        if match(line, '.') != -1

                                # otherwise, add the key and value to a
                                # subdictionary corresponding to the current
                                # key. 
                                var sub_key = substitute(line, '\v\s*\=.*', '', "g")
                                var value = substitute(line, '\v\s*\l*\s*\=\s*', '', "g")
                                value = substitute(value, '"', '', "g")
                                config[key][sub_key] = value
                        endif

                endif
        endfor

        echo config

        return 0

enddef

# Read more into this stuff in the help files. See *write-plugin*
map <Leader>r <Plug>ReloadConfig;

noremap <unique> <script> <Plug>ReloadConfig;  <SID>ParseToml
noremap <SID>ParseToml :call <SID>ParseToml()<CR>
