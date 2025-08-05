vim9script

import autoload "../log.vim" as logger
import autoload "./find_config.vim" as find

export def Parse(config: dict<any>): list<any>

        var errno = 0

        var file_location = find.FindConfig(".sourcesmenu.toml")

        var config_location = file_location
        file_location = config_location .. ".sourcesmenu.toml"

        if file_location == "NONE"
                # Plugin not used currently
                return [-1]
        endif


        var config_file: list<string>
        try 
                config_file = readfile(expand(file_location))
        catch 
                # This code indicates that something went wrong with reading the
                # config file.
                return [-2]
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
                                logger.Log("Invalid table name: " .. key)
                                errno = -1000
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
                                        logger.Log("Invalid key or value: " .. sub_key .. " = " .. value)
                                        errno = -1000
                                endif
                        endif

                endif
        endfor

        return [errno, config_location]

enddef
