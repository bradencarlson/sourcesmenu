vim9script

# toml.vim
# Author: Braden Carlson
#
# For the parsing of TOML files. Currently this only supports a very small
# subset of the TOML language, namely tables and key/value pairs in those
# tables. 

import autoload "../log.vim" as logger
import autoload "./find_config.vim" as find

export def Parse(config: dict<any>): list<any>
        # Parse the toml file.  Currently this only supports a very small
        # portion of the toml language, namely table names, and key/value pairs. 
        # For this project so far, this seems like it will be enough. 
        #
        # All table names and keys in the toml file should match [a-z]+.
        # All values in the toml file should match [a-z.]+|-?[0-9]+, that is
        # keys should either be a string consisting of chars a-z or a ., or a
        # number (positive or negative). Any table names, keys, or values which
        # do not match these will result in errno to be set to -1000. 
        #
        # Parameters: 
        #   config: the dictionary into which all options will be stored.
        #
        # Returns: 
        #   the list [errno, config_location], where
        #
        #   errno: 
        #          0: no error occured
        #         -1: no config file found
        #         -2: config file found, but unable to be read
        #      -1000: invalid table name, key name, or value in config file
        #   config_location: the location of the configuration file, if found. 

        var errno = 0

        # Try to find a toml config file.
        # The FindConfig method checks all the default locations for the
        # specified filename.
        var file_location = find.FindConfig(".sourcesmenu.toml")

        var config_location = file_location

        if file_location == "NONE"
                # Plugin not used currently
                return [-1, "NONE"]
        endif

        file_location = config_location .. ".sourcesmenu.toml"

        var config_file: list<string>
        try 
                config_file = readfile(expand(file_location))
        catch 
                # This code indicates that something went wrong with reading the
                # config file.
                return [-2, "NONE"]
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
