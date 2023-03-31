" Standard settings
set number
set autoindent
syntax on
colorscheme slate
set laststatus=2

" Keyboard shortcuts
nnoremap <C-l> :tabnext<CR>
nnoremap <C-a> :tabprevious<CR>

" Git Commands
nnoremap "+ga :call GitAdd()<CR>
nnoremap "+gc :call GitCommit()<CR>
nnoremap "+gp :call GitCmd('push')<CR>
nnoremap "+gs :call GitCmd('status')<CR>
nnoremap "+gbl :call GitCmd('branch')<CR>
nnoremap "+gbc :call GitNewBranch()<CR>
nnoremap "+gbx :call GitCheckout()<CR>
nnoremap "+gbm :call GitMerge()<CR>

" File Operations
nnoremap "+ls :call RunCommand('ls -alF')<CR>
nnoremap "+cm :call RunCommandInput()<CR>
nnoremap "+cd :chdir 
nnoremap "+rm :!rm 
nnoremap "+nf :call OpenNewFile()<CR>
nnoremap "+of :tabnew 

" Rsyslog File Monitor
nnoremap "+slf :call RsyslogMonitorToFile()<CR>
nnoremap "+slh :call RsyslogMonitorToHost()<CR>

" Data Formatting
nnoremap "+px :call XmlPretty()<CR>
nnoremap "+pj :call JsonPretty()<CR>

function! AppendLine(line)
  call append(line('$'),a:line)
endfunction

function! RsyslogMonitorToFile()
  let monitorfile = input('monitor file: ')
  let targetfile = input('target file: ')
  let monitortag = substitute(system('basename ' . monitorfile),'[^0-9a-zA-Z]','','g')
  call AppendLine("$InputFileName " . monitorfile)
  call AppendLine("$InputFileTag " . monitortag)
  call AppendLine("$InputFileStateFile " . monitortag)
  call AppendLine("$InputRunFileMonitor")
  call AppendLine("if $syslogtag == '" . monitortag . "' " . targetfile)
endfunction

function! RsyslogMonitorToHost()
  let monitorfile = input('monitor file: ')
  let targethost = input('target (host:port): ')
  let monitortag = substitute(system('basename ' . monitorfile),'[^0-9a-zA-Z]','','g')
  call AppendLine("$InputFileName " . monitorfile)
  call AppendLine("$InputFileTag " . monitortag)
  call AppendLine("$InputFileStateFile " . monitortag)
  call AppendLine("$InputRunFileMonitor")
  call AppendLine("if $syslogtag == '" . monitortag . "' " . targethost)
endfunction

function! OpenNewFile()
  let newfile = input('new file: ')
  call system('touch ' . newfile)
  execute 'edit' newfile
endfunction

function! RunCommandInput()
  let cmd = input('cmd: ')
  redraw
  call RunCommand(cmd)
endfunction

function! RunCommand(cmd)
  let result = system(a:cmd)
  echo result
endfunction

function! PwdIsGit()
  let isgit = stridx(system('ls -a'),'.git')
  if isgit > -1
    return "yes"
  else
    return "no"
  endif
endfunction

function! GitAdd()
  if PwdIsGit() == "yes"
    let filemsg = system('git add -v ' . expand('%:p'))
    echo filemsg
  else
    echo "Current directory not repository"
  endif
endfunction

function! GitCommit()
  if PwdIsGit() == "yes"
    let commitmsg = input('commit msg: ')
    let commitresult = system('git commit -m "' . commitmsg . '"')
    echo commitresult
  else
    echo "Current directory not repository"
  endif
endfunction

function! GitCmd(cmd)
  if PwdIsGit() == "yes"
    let cmdresult = system('git ' . a:cmd)
    echo cmdresult
  else
    echo "Current directory not repository"
  endif
endfunction

function! GitNewBranch()
  if PwdIsGit() == "yes"
    let newbranch = input("new branch name: ")
    let cmdresult = GitCmd('branch -c ' . newbranch)
    echo cmdresult
  else
    echo "Current directory not repository"
  endif
endfunction

function! GitCheckout()
  if PwdIsGit() == "yes"
    call GitCmd('branch')
    let branch = input("checkout branch: ")
    let cmdresult = GitCmd('checkout ' . branch)
    echo cmdresult
  else
    echo "Current directory not repository"
  endif
endfunction

function! GitMerge()
  if PwdIsGit() == "yes"
    call GitCmd('branch')
    let srcbranch = input("merge source: ")
    let cmdresult = GitCmd('merge ' . srcbranch)
    echo cmdresult
  else
    echo "Current directory not repository"
  endif
endfunction

function! XmlPretty()
  %s/\(<[\/]*[^>]\+>\)/\r\1\r/g
  g/^$/d
endfunction

function! JsonPretty()
  %s/{/\r{\r/g
  %s/}/\r}\r/g
  %s/\[/\[\r/g
  %s/\(\][^,]\)/\r\1\r/g
  %s/\(\],\)/\r\1\r/g
  %s/,/,\r/g
  g/^$/d
endfunction

" ***************************
" Startup functions
" ***************************

set statusline={pwd:\'%{trim(system('pwd'))}\',filedir:\'%{expand('%:p:h')}\'}