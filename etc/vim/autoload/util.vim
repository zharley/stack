" util.vim - misc custom functions

" returns the MixedCase version of a word
function! util#MixedCase(word)
  return substitute(CamelCase(a:word),'^.','\u&','')
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

  let to_snake = util#SnakeCase(a:to)
  let to_camel = util#CamelCase(a:to)
  let to_mixed = util#MixedCase(a:to)

  execute a:firstline.",".a:lastline."s/".from_snake."/".to_snake."/gec"
  execute a:firstline.",".a:lastline."s/".from_camel."/".to_camel."/gec"
  execute a:firstline.",".a:lastline."s/".from_mixed."/".to_mixed."/gec"

  echo "Done power replace!"
endfunction

" launch CommandT as long as it's not the home directory
function! util#BeginCommandT()
  if (getcwd() == $HOME)
    echo 'Ooops! Home directory.'
  else
    exec ":CommandT"
  endif
endfunction

" do power replace on selection
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
command! -nargs=+ -range=% PowerReplace <line1>,<line2>call util#PowerReplace(<f-args>)
