vim9script

export def Parse(): number 

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
