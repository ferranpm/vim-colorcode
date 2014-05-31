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
            let l:match = '\( \|*\|\.\|->\)'.l:match
        else
            let l:match = '\.'.l:match
        endif
    elseif a:item["kind"] == "f"
        if l:extension == "c" || l:extension == "h"
            let l:match = l:match.' *\(.*\)'
        endif
    endif

    return '\m'.l:match
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

function! colorcode#highlight_global(list)
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
endfunction

function! colorcode#highlight_individual(list)
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
endfunction

function! colorcode#highlight(list)
    if g:colorcode_global
        call colorcode#highlight_global(a:list)
    else
        call colorcode#highlight_individual(a:list)
    endif
endfunction

function! colorcode#sort_item(i1, i2)
    return strlen(a:i1["name"]) >= strlen(a:i2["name"]) ? 1 : -1
endfunction

function! colorcode#get_list()
    return sort(taglist('\m.*'), "colorcode#sort_item")
endfunction

function! colorcode#init()
    call colorcode#clear_matches()
    let l:list = colorcode#get_list()
    call colorcode#highlight(l:list)
endfunction
