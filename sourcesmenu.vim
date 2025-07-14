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

def Run(): void
        var parse_pass = ParseToml()

        if parse_pass == -1
                echo "Aborting."
                g:loaded_sourcesmenu = 0
                return
        endif

        var read_pass = ReadSources()

        if read_pass < 0
                echo "Aborting."
                g:loaded_sourcesmenu = 0
                return
        endif

        set wcm=<C-Z>
        map <F4> :emenu Sources.<C-Z>
enddef


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

        var config_file: list<string>
        try 
                config_file = readfile(expand(file_location))
        catch 
                echo "Can't file config file: " .. file_location
                return -1
        endtry

        var key: string
        for line in config_file
                # If the line is the beginning of a table, then add it as a key
                # to the config dictionary. 
                if match(line, '\s*\[\l\+\]\s*') != -1
                        key = substitute(line, '\s*\[\|\]\s*', "", "g")

                        # Make sure the key is something that we expect. key
                        # should match ^[a-z]+$
                        if match(key, '\v^[a-z]+$') != -1
                                config[key] = {}
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
                                endif
                        endif

                endif
        endfor

        echo config

        return 0

enddef

def ReadSources(): number
        var filename = ""

        # Get the filename found in the config file. If this fails, abort.
        try 
                filename = config['bibliography']['path']
        catch 
                echo "Something went wrong getting the path"
                return -1
        endtry

        # Try to get the offset, if it is set by the user, if not, set it to
        # zero.
        var offset: number
        try
                offset = str2nr(config['config']['offset'])
        catch
                offset = 0
        endtry

        if !filereadable(expand(filename))
                echo "Something went wrong reading the sources file"
                return -2
        endif

        var source_file = readfile(expand(filename))

        for line in source_file
                # In BibTeX, each entry starts with a '@', so lines with this
                # are what we are looking for.
                if match(line, '^@') != -1

                        # Strip the beginning @[a-z]+{ part, and just get the
                        # label for the source
                        var source = substitute(line, '\v\@[a-z]+\{|,|\s*$', '', "g")

                        # Currently, the source label should match
                        # ^[a-z\-]+$
                        if match(source, '\v^[a-z\-]+$') != -1
                                execute "menu Sources." .. source .. " :call Insertatcursor(\"" .. source .. "\"," .. offset .. ")<CR>"
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
        

# Read more into this stuff in the help files. See *write-plugin*
map <Leader>r <Plug>ReloadConfig;

noremap <unique> <script> <Plug>ReloadConfig;  <SID>Run
noremap <SID>Run :call <SID>Run()<CR>
