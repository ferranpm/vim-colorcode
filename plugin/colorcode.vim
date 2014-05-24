if (exists("g:loaded") && g:loaded) || v:version < 700 || &cp
    finish
endif

let g:Colorcode_colors = [
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

function! g:GetExtension(file)
    let l:ar = split(a:file, '\.')
    return l:ar[len(l:ar)-1]
endfunction

function! g:GetColor(num)
    let l:len = len(g:Colorcode_colors)
    return g:Colorcode_colors[a:num%l:len]
endfunction

function! g:GetMatch(name, type, file)
    let l:extension = g:GetExtension(a:file)
    let l:match = '\<'.a:name.'\>'

    if a:type == "m"
        if l:extension == "c" || l:extension == "h"
            let l:match = '\(\.\|->\)'.l:match
        else
            let l:match = '\.'.l:match
        endif
    elseif a:type == "f"
        if l:extension == "c" || l:extension == "h"
            let l:match = l:match.' *(.*)'
        endif
    endif

    return l:match
endfunction

function! g:GetPriority(type)
    let l:priority = 50
    if a:type == "l"
        let l:priority = 70
    endif
    return l:priority
endfunction

function! g:ColorcodeClearMatches()
    for m in getmatches()
        if match(m['group'], 'Colorcode_') != -1
            call matchdelete(m['id'])
        endif
    endfor
endfunction

function! g:Colorcode()
    call g:ColorcodeClearMatches()
    let l:hi_nr = 0
    for file in tagfiles()
        if filereadable(file)
            for line in readfile(file)
                if line[0] != '!' " if the line is not a comment, parse it
                    let l:split = split(line, "\t")
                    let l:tagname = l:split[0]
                    let l:tagfile = l:split[1]
                    let l:tagaddress = l:split[2]
                    let l:tagfield = l:split[3]
                    let l:match = g:GetMatch(l:tagname, l:tagfield, l:tagfile)

                    let l:priority = g:GetPriority(l:tagfield)
                    let l:color = g:GetColor(l:hi_nr)

                    execute 'highlight '.'Colorcode_'.l:hi_nr.' cterm=None ctermfg='.l:color.' ctermbg=None'
                    call matchadd('Colorcode_'.l:hi_nr, l:match, l:priority)
                    let l:hi_nr = l:hi_nr + 1
                endif
            endfor
        endif
    endfor
endfunction

call g:Colorcode()
