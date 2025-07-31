vim9script

export def Read(filename: string, offset: number): number

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
                        endif
                endif
        endfor

        return 0
enddef
