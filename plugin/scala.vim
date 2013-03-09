"
" Sort imports
"
" 1. Java/Scala imports like java.util.UUID
" 2. Third party libraries
" 3. First party libraries
"
" author: Leonard Ehrenfried <leonard.ehrenfried@gmail.com>
"

function! SortScalaImports()
  let curr = 0
  let first_line = -1
  let last_line = -1
  let trailing_newlines = 0
  let java_scala_imports = []
  let first_party_imports = []
  let third_party_imports = []

  " loop over lines in buffer
  while curr < line('$')

    let line = getline(curr)

    if line =~ "^import"
      if first_line == -1
        let first_line = curr
      endif

      if line =~ '^import \(java\(x\)\?\|scala\)\.'
        call add(java_scala_imports, line)
      elseif line =~ '^import \(de.\|controller\|util\|views\)'
        call add(first_party_imports, line)
      else
        call add(third_party_imports, line)
      endif

      let trailing_newlines = 0
    elseif empty(line)
      let trailing_newlines = trailing_newlines + 1
    elseif first_line != -1
      let last_line = curr - trailing_newlines - 1
      " break out when you have found the first non-import line
      break
    endif

    let curr = curr + 1
  endwhile

  call cursor(first_line - 1, 0)
  let to_delete = last_line - first_line + 2
  execute 'd'to_delete

  call s:sortAndPrint(first_party_imports)
  call s:sortAndPrint(third_party_imports)
  call s:sortAndPrint(java_scala_imports)

endfunction

function! s:sortAndPrint(imports)
  if len(a:imports) > 0
    call sort(a:imports, "s:sortIgnoreCase")
    call append(line("."), "")
    call append(line("."), a:imports)
  endif
endfunction

" this useless function exists purely so the sort() ignores case
" case ignoring is needed to scalaz/Scalaz appears next
" to each other
function! s:sortIgnoreCase(i1, i2)
  return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? 1 : -1
endfunction

command SortScalaImports call SortScalaImports()
