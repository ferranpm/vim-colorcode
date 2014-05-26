if (exists("g:loaded") && g:loaded) || v:version < 700 || &cp
    finish
endif

" TODO: Improve this shitty solution
if !exists("g:colorcode_type_to_index")
    let g:colorcode_type_to_index = {
                \ 'a': 0, 'b': 1, 'c': 2, 'd': 3, 'e': 4,
                \ 'f': 5, 'g': 6, 'h': 7, 'i': 8, 'j': 9,
                \ 'k': 10, 'l': 11, 'm': 12, 'n': 13, 'o': 14,
                \ 'p': 15, 'q': 16, 'r': 17, 's': 18, 't': 19,
                \ 'u': 20, 'v': 21, 'w': 22, 'x': 23, 'y': 24, 'z': 25
                \ }
endif

if !exists("g:colorcode_colors")
    let g:colorcode_colors = [
                \ '18', '20', '22', '23', '26', '40', '41', '44', '52', '53', '55',
                \ '58', '61', '74', '84', '89', '97', '105', '132', '136', '157', '166',
                \ '190', '196', '201', '213', '214', '227', '228', '231'
                \ ]
endif

if !exists("g:colorcode_global")
    let g:colorcode_global = 1
endif

function! colorcode#get_extension(file)
    let l:ar = split(a:file, '\.')
    return l:ar[len(l:ar)-1]
endfunction

function! colorcode#get_item_color(item)
    let l:index = get(g:colorcode_type_to_index, a:item["kind"], 0)
    return g:colorcode_colors[l:index]
endfunction

function! colorcode#get_color(idx)
    let l:len = len(g:colorcode_colors)
    return g:colorcode_colors[a:idx%l:len]
endfunction

function! colorcode#get_match(item)
    let l:extension = colorcode#get_extension(a:item["filename"])
    let l:match = '\<'.escape(a:item["name"], "~").'\>'

    if a:item["kind"] == "m"
        if l:extension == "c" || l:extension == "h"
            let l:match = '\( \|\.\|->\)'.l:match
        else
            let l:match = '\.'.l:match
        endif
    elseif a:item["kind"] == "f"
        if l:extension == "c" || l:extension == "h"
            let l:match = l:match.' *(.*)'
        endif
    endif

    return l:match
endfunction

function! colorcode#get_priority(item)
    let l:priority = 50
    if a:item["kind"] == "l"
        let l:priority = 70
    elseif a:item["kind"] == "m"
        let l:priority = 80
    endif
    return l:priority
endfunction

function! colorcode#clear_matches()
    for m in getmatches()
        if match(m['group'], '^Colorcode_\d\+$') != -1
            call matchdelete(m['id'])
        endif
    endfor
endfunction

function! colorcode#highlight(list)
    if g:colorcode_global
        for key in keys(g:colorcode_type_to_index)
            let l:num = get(g:colorcode_type_to_index, key, 0)
            let l:color = colorcode#get_color(l:num)
            execute 'highlight '.'Colorcode_'.l:num.' cterm=None ctermfg='.l:color.' ctermbg=None'
        endfor
        for item in a:list
            let l:num = get(g:colorcode_type_to_index, item["kind"], 0)
            let l:match = colorcode#get_match(item)
            let l:priority = colorcode#get_priority(item)
            call matchadd('Colorcode_'.l:num, l:match, l:priority)
        endfor
    else
        let l:count = 0
        for item in a:list
            let l:match = colorcode#get_match(item)
            let l:priority = colorcode#get_priority(item)
            let l:color = colorcode#get_color(l:count)
            let l:group = l:count%len(g:colorcode_colors)

            execute 'highlight '.'Colorcode_'.l:group.' cterm=None ctermfg='.l:color.' ctermbg=None'
            call matchadd('Colorcode_'.l:group, l:match, l:priority)

            let l:count = l:count + 1
        endfor
    endif
endfunction

function! colorcode#sort_item(i1, i2)
    return strlen(a:i1["name"]) >= strlen(a:i2["name"]) ? 1 : -1
endfunction

function! colorcode#get_list()
    return sort(taglist('.*'), "colorcode#sort_item")
endfunction

function! colorcode#init()
    call colorcode#clear_matches()
    let l:list = colorcode#get_list()
    call colorcode#highlight(l:list)
endfunction

call colorcode#init()
