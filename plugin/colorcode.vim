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
                \ '89', '137', '90', '41', '48', '77', '144', '102', '51', '177',
                \ '123', '207', '31', '219', '147', '47', '153', '45', '209', '190',
                \ '199', '46', '38', '44', '156', '25', '106', '108', '27', '213',
                \ '96', '146', '184', '95', '126', '171', '22', '186', '130', '75',
                \ '33', '81', '93', '197', '82', '105', '166', '117', '54', '61',
                \ '53', '56', '201', '220', '23', '37', '189', '176', '71', '158',
                \ '94', '149', '113', '118', '91', '120', '59', '30', '34', '36',
                \ '136', '26', '200', '170', '104', '216', '162', '35', '182', '124',
                \ '180', '107', '138', '191', '205', '67', '133', '73', '174', '167',
                \ '210', '24', '98', '64', '128', '127', '50', '159', '29', '161',
                \ '194', '65', '80', '211', '140', '132', '57', '39', '157', '97',
                \ '160', '103', '110', '152', '192', '163', '181', '217', '111', '179',
                \ '69', '155', '55', '215', '62', '173', '195', '86', '222', '135',
                \ '66', '154', '101', '42', '100', '28', '223', '21', '83', '165',
                \ '43', '169', '68', '204', '212', '122', '99', '148', '131', '214',
                \ '134', '188', '143', '114', '187', '115', '139', '208', '84', '150',
                \ '185', '40', '183', '70', '145', '151', '218', '221', '52', '112',
                \ '72', '202', '119', '198', '76', '164', '92', '63', '109', '85',
                \ '49', '60', '79', '87', '172', '193', '178', '168', '203', '196',
                \ '88', '175', '206', '78', '74', '129', '141', '116', '58', '125',
                \ '142', '121', '32']
endif

if !exists("g:colorcode_global")
    let g:colorcode_global = 0
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

            execute 'highlight '.'Colorcode_'.l:count.' cterm=None ctermfg='.l:color.' ctermbg=None'
            call matchadd('Colorcode_'.l:count, l:match, l:priority)

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
