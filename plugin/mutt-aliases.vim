" my mutt aliases complete function(s)
" 
" To install this, add it to ~/.vim/scripts/ or somewhere
" and add something like the following:
"
"   au BufRead /tmp/mutt-* source ~/.vim/scripts/mutt-aliases.vim
"   au BufRead ./example.file source ./mutt-aliases.vim
"
" Invoke the completion in insert mode with either i_CTRL-X_CTRL-U, or with
" macro: imap macro: @@ inserted by this .vim script.
"
" The aliases file is assumed to be ~/.aliases, or whatever your ~/.muttrc file
" says.  " You can override by setting: let g:mutt_aliases_file="~/.blarg"
"
" Author: Paul Miller <jettero@cpan.org>
" Copyright: Paul Miller
" License: Public Domain
" Repository: http://github.com/jettero/mutt-vim/
" Issue Tracking: http://github.com/jettero/mutt-vim/issues
" VERSION: 0.93
"

fun! Read_Aliases()
    let lines = readfile(s:aliases_file)
    for line in lines
        if line =~? "^[ ]*alias "
            let tokens  = split(line)
            let alias   = tokens[1]
            let address = join(tokens[2:])

            let s:address_dictionary[alias] = address
        endif
    endfor
endfun

fun! Complete_Emails(findstart, base)
    if a:findstart
        let line = getline('.')
        let start = col('.') - 1

        while start > 0 && line[start - 1] =~ '\S'
            let start -= 1
        endwhile

        echo "start: " start

        return start

    else
        let res = []

        for alias in keys(s:address_dictionary)
            let address = s:address_dictionary[alias]

            if alias =~? '^' . a:base    ||    address =~? '\<' . a:base

                call add(res, {'word': address, 'menu': "[" . alias . "]"})

            endif
        endfor

        return res
    endif
endfun

let s:aliases_file = "~/.aliases"
let s:address_dictionary = {}
let s:muttrc_file = expand("~/.muttrc")

if filereadable(s:muttrc_file)
    let lines = readfile(s:muttrc_file)
    for l in lines
        if l =~ '\s*set\s\+alias_file\s*='  " strictly speaking, this is just the append point...
            let ll = split(l, "=")          " how would you detect a matching source .string location?
            let le = eval(ll[1])

            let s:aliases_file = le
            break
        endif
    endfor
endif

if exists("g:mutt_aliases_file")
    let s:aliases_file = g:mutt_aliases_file
endif

let s:aliases_file = expand(s:aliases_file)
if filereadable(s:aliases_file)
    call Read_Aliases()
    set completefunc=Complete_Emails
    imap @@ <C-X><C-U>

else
    echo "could not read aliases file: " s:aliases_file

endif
