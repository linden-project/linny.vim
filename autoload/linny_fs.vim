" Copyright (c) Pim Snel 2019-2023

function! linny_fs#dir_create_if_path_not_exist(path)
  if !filereadable(a:path)
    call job_start(["mkdir","-p",a:path])
  endif
endfunction

function! linny_fs#os_open_with_filemanager(path)
  if has("unix")
    call job_start( ["xdg-open", a:path])
  else
    call job_start( ["open" ,a:path])
  endif
endfunction

