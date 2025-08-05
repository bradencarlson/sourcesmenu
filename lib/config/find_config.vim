vim9script

def FindConfig(filename: string): string
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


