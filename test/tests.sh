#!/bin/bash

generate_good_toml_file() {
        cat > .sourcesmenu.toml <<EOF
[bibliography]
path = "sources.bib"
[config]
offset = 0
popup = 1
EOF
}

generate_bad_toml_file() {
        cat > .sourcesmenu.toml <<EOF
[bibliography]
path = "sources.bib"
[config]
offset = 0
popup = 1
[badtable123]
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

generate_vimrc_file() {
        cat > vimrc <<EOF
source \$VIMRUNTIME/defaults.vim
let mapleader=","
EOF
# map <leader>c :popup Sources<CR>
}

generate_good_test_files() {
        generate_tex_file
        generate_vimrc_file
        generate_bib_file
        generate_good_toml_file
}

generate_config_test_files() {
        generate_tex_file
        generate_vimrc_file
        generate_bib_file
        generate_bad_toml_file
}

start_good_test() {
        echo "Starting good test, everything should load and function as usual."
        read -p "Press any key to continue"

        generate_good_test_files
        vim --noplugin -u ./vimrc -S ../sourcesmenu.vim main.tex
}

start_config_error_test() {
        echo "Starting config error test, plugin should show an error, then vim should load as usual"
        echo "No key bindings from the plugin should be loaded."
        read -p "Press any key to continue"

        generate_config_test_files
        vim --noplugin -u ./vimrc -S ../sourcesmenu.vim main.tex
}

for opt in $@; do
        if [[ "$opt" == "full" ]]; then
                start_good_test
                start_config_error_test
        elif [[ "$opt" == "config" ]]; then
                start_config_error_test
        elif [[ "$opt" == "good" ]]; then 
                start_good_test
        fi
done

