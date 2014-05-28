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

if !exists("g:colorcode_global") | let g:colorcode_global = 1 | endif
if !exists("g:colorcode_enable") | let g:colorcode_enable = 1 | endif

if g:colorcode_enable
    call colorcode#init()
    colorscheme colorcode
endif
