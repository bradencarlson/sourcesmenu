vim9script

# find_config.vim
# Author: Braden Carlson
#
# Finds the specified filename in the current directory, any direct parent of
# the current directory, or in some global places. If the file is found, the
# directory is then returned as a string. If the file is not found in any of
# the above locations, the string "NONE" is returned. 

export def FindConfig(filename: string): string
        # Searches up through the directory structure, as well as in the
        # default locations, for a config file named by the parameter
        # filename. 
        #
        # Parameters: 
        #   filename: the name of the file to search for
        #
        # Returns: 
        #   string: the directory in which the config file was found, or
        #           "NONE" if no config file was found. 
        #
        # For Unix environments, the returned string must end in a
        # forward-slash. 
        #
        # Note: Currently, for windows systems, only the current working
        # directory is searched for the config file. 
        
        if g:win32 == 1
                var prefix = ["./"]
                for pre in prefix
                        if filereadable(expand(pre .. filename))
                                return pre
                        endif
                endfor
                
        else
                # Search up the directory tree to see if we are in a
                # subdirectory of a project using this plugin.
                var path = getcwd()
                path = path .. "/"
                while path != ""
                        if filereadable(path .. filename)
                                return path
                        else 
                                path = substitute(path, "\[^/\]*/*$", "", "g")
                        endif
                endwhile

                # Finally, check to see if there is any global configuration. 
                var prefix = ["~/", "~/.config/sourcesmenu/"]
                for pre in prefix
                        if filereadable(pre .. filename)
                                return pre
                        endif
                endfor

        endif

        return "NONE"

enddef


