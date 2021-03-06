" util.vim - misc custom functions

" returns the MixedCase version of a word
function! util#MixedCase(word)
  return substitute(util#CamelCase(a:word),'^.','\u&','')
endfunction

" returns the camelCase version of a word
function! util#CamelCase(word)
  let word = substitute(a:word, '-', '_', 'g')
  if word !~# '_' && word =~# '\l'
    return substitute(word, '^.', '\l&', '')
  else
    return substitute(word, '\C\(_\)\=\(.\)', '\=submatch(1)==""?tolower(submatch(2)) : toupper(submatch(2))', 'g')
  endif
endfunction

" returns the snake_case version of a word
function! util#SnakeCase(word)
  let word = substitute(a:word, '::', '/', 'g')
  let word = substitute(word, '\(\u\+\)\(\u\l\)', '\1_\2', 'g')
  let word = substitute(word, '\(\l\|\d\)\(\u\)', '\1_\2', 'g')
  let word = substitute(word, '-', '_', 'g')
  let word = tolower(word)
  return word
endfunction

" replaces all variations of a word
function! util#PowerReplace(from, to) range
  let from_snake = util#SnakeCase(a:from)
  let from_camel = util#CamelCase(a:from)
  let from_mixed = util#MixedCase(a:from)
  let from_upper = toupper(from_snake)

  let to_snake = util#SnakeCase(a:to)
  let to_camel = util#CamelCase(a:to)
  let to_mixed = util#MixedCase(a:to)
  let to_upper = toupper(to_snake)

  execute a:firstline.",".a:lastline."s/".from_snake."/".to_snake."/gec"
  execute a:firstline.",".a:lastline."s/".from_camel."/".to_camel."/gec"
  execute a:firstline.",".a:lastline."s/".from_mixed."/".to_mixed."/gec"
  execute a:firstline.",".a:lastline."s/".from_upper."/".to_upper."/gec"
endfunction

" launch CtrlP as long as it's not the home directory
function! util#BeginFinder()
  if (getcwd() == $HOME)
    echo 'Ooops! Home directory.'
  else
    exec ":CtrlP"
  endif
endfunction

" @see http://stackoverflow.com/questions/5686206/search-replace-using-quickfix-list-in-vim
function! util#QuickfixFilenames()
  " Building a hash ensures we get each buffer only once
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor
  return join(values(buffer_numbers))
endfunction

" begin public interface
let s:keepcpo = &cpo
set cpo&vim

" define commands
" 
" -nargs=
"         1 One argument.
"         * Any number of arguments.
"         ? Zero or one arguments.
"         + One or more argument
"
" -range  defaults to current line
"      =% defaults to the whole file
"
" <q-args> quotes special characters in the argument.

" do power replace on selection 
command! -nargs=+ -range=% UtilPowerReplace <line1>,<line2>call util#PowerReplace(<f-args>)

" pass quickfix to args
command! -nargs=0 -bar UtilQuickfixToArgs execute 'args ' . util#QuickfixFilenames()

" Detects shebang in current file and sets file type appropriately
function! util#DetectNode()
  if getline(1) =~# '^#!.*/bin/env\s\+node\>'
    set ft=javascript
  endif
endfun

let &cpo= s:keepcpo
unlet s:keepcpo
" end public interface
