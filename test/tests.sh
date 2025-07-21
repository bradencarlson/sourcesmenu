#!/bin/bash

generate_toml_file() {
        cat > .sourcesmenu.toml <<EOF
[bibliography]
path = "sources.bib"
[config]
offset = 0
popup = 1
EOF
}

generate_bib_file() {
        cat > sources.bib <<EOF
@book{title-one,
    author="Nobody",
    year = 2000
}

@article{article-one,
    author="Someone important"
    year=2018
}

@article{article-two,
    author="Someone else"
    year=2019,
    publisher="Some publishing company"
}
EOF
}

generate_tex_file() {
        cat > main.tex <<EOF
\documentclass{article}

\\begin{document}

\\end{document}
EOF

}

generate_test_files() {
        generate_tex_file
        generate_bib_file
        generate_toml_file
}

start_vim() {
        if [[ $# < 2 ]]; then 
                generate_test_files
                vim --noplugin -S ../sourcesmenu.vim main.tex
        else
                vim --noplugin -S ../sourcesmenu.vim $1
        fi
}

start_vim

