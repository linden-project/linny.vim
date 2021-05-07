" Copyright (c) Pim Snel 2019-2021

function! linny_util#initVariable(var, value)
  if !exists(a:var)
    exec 'let ' . a:var . ' = ' . "'" . a:value . "'"
    return 1
  endif
  return 0
endfunction

