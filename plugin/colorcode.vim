if (exists("g:loaded") && g:loaded) || v:version < 700 || &cp
    finish
endif

function g:GetColor(num)
    return (a:num)%256 + 22
endfunction

function g:GetMatch(word, type)
    let l:match = '\<'.a:word.'\>'
    if a:type == "f"
        let l:match = l:match.' *(.*)'
    endif
    return l:match
endfunction

function g:GetPriority(type)
    let l:priority = 50
    if a:type == "l"
        let l:priority = 70
    endif
    return l:priority
endfunction

let g:Colorcode_hi_nr = 5
function g:Colorcode_file()
    for file in tagfiles()
        if filereadable(file)
            for line in readfile(file)
                if line[0] != '!' " if the line is not a comment, parse it
                    let words = split(line, "\t")
                    if words[1] == expand("%")
                        let l:priority = g:GetPriority(words[3])
                        let l:match = g:GetMatch(words[0], words[3])
                        let l:color = g:GetColor(g:Colorcode_hi_nr)
                        execute 'highlight '.g:Colorcode_hi_nr.' cterm=None ctermfg='.l:color.' ctermbg=None'
                        call matchadd(g:Colorcode_hi_nr, l:match, l:priority)
                        let g:Colorcode_hi_nr = g:Colorcode_hi_nr + 1
                    endif
                endif
            endfor
        endif
    endfor
endfunction

call g:Colorcode_file()
