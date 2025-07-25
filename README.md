# Sources Menu

This Vim plugin allows TeX users to view their sources (listed in a .bib file)
in a menu and paste them under the cursor (or to the right of the cursor, you
decide). See the demo video below to see the menu in action!

[![Watch the
demo.](https://img.youtube.com/vi/dZwgT1yUgkA/0.jpg)](https://youtube.com/watch?v=dZwgT1yUgkA)

## Installation

Currently, the easiest way to install this project is to run the following
commands: 
```
cd .vim/plugin/
git clone https://github.com/bradencarlson/sourcesmenu.git
mv ~/.vim/plugin/sourcesmenu/sourcesmenu.txt ~/.vim/doc/
```
Once the above has been run, don't forget to start vim and run 
`:helptags ~/.vim/doc` to install the help page for this plugin. 

## Getting Help

After a succesful installation, you may run `:help sourcesmenu.txt` or `:help
sourcesmenu` to read the help page for this plugin. You can also run 
`:help sourcesmenu-config` and `:help sourcesmenu-keymappings` for more specific
information. 

## Configuration

Configuring this plugin is done with a TOML file and can be performed on a project 
by project basis (i.e. if
there are several directories in which you have TeX files, and each has it's own
BibTeX file) or on a per user basis. This plugin looks for a sourcesmenu.toml
file in the following order
1. `./.sourcesmenu.toml` (working directory where Vim was started)
2. `~/.sourcesmenu.toml`
3. `~/.config/sourcesmenu/sourcesmenu.toml`

The first one of these which is found is used. See the `sourcesmenu.txt` file
for valid table names, as well as what key/value pairs are expected and
accepted. 
