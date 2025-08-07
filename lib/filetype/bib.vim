vim9script

# bib.vim
# Author: Braden Carlson 

export def Read(filename: string, offset: number): number
        # Read the specified bib file, adding each found entry to the menu.
        # If an entry is to be included in the menu, it must meet the
        # following criterion: 
        #   - The line must start with @, no blank spaces
        #   - The reference label must be on the same line as the @book (or
        #     article or whatever it is), for example 
        #       @article{label-one,
        #           title="Title Here"
        #       }
        #
        # Returns: 
        #   errno: 
        #       0: no errors occured
        #      -1: Invalid label found in file
        #      -2: bib file is not readable
        #
        # Note: In the event that -1 is returned, the rest of the file is
        # still parsed, meaning that there are potentially menu items
        # available to the user, but there was one or more that failed. 

        var errno = 0

        if !filereadable(expand(filename))
                # Something went wrong reading the sources file
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
                        if match(source, '\v^[a-z0-9\-]+$') != -1
                                execute "menu Sources." .. source .. " :call Insertatcursor(\"" .. source .. "\"," .. offset .. ")<CR>"
                        else
                                errno = -1
                        endif
                endif
        endfor

        return errno
enddef
