set nocompatible
let s:cpo_save=&cpo
set cpo&vim
map! <xHome> <Home>
map! <xEnd> <End>
map! <S-xF4> <S-F4>
map! <S-xF3> <S-F3>
map! <S-xF2> <S-F2>
map! <S-xF1> <S-F1>
map! <xF4> <F4>
map! <xF3> <F3>
map! <xF2> <F2>
map! <xF1> <F1>
nnoremap <SNR>6_Paste "=@+.'xy'gPFx"_2x:echo
map <xHome> <Home>
map <xEnd> <End>
map <S-xF4> <S-F4>
map <S-xF3> <S-F3>
map <S-xF2> <S-F2>
map <S-xF1> <S-F1>
map <xF4> <F4>
map <xF3> <F3>
map <xF2> <F2>
map <xF1> <F1>
let &cpo=s:cpo_save
unlet s:cpo_save
set background=dark
set iskeyword=@,48-57,_,192-255,+,-,?
set mouse=a
if &syntax != 'verilog'
set syntax=verilog
endif
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/bender_cores/wb_conmax
set shortmess=aoO
badd +16 ~/bender_cores/wb_conmax/rtl/verilog/wb_conmax_defines.v
badd +180 ~/bender_cores/wb_conmax/rtl/verilog/wb_conmax_top.v
badd +18 ~/bender_cores/wb_conmax/sim/rtl_sim/bin/Makefile
badd +96 ~/bender_cores/wb_conmax/rtl/verilog/wb_conmax_arb.v
badd +3 ~/bender_cores/wb_conmax/rtl/verilog/wb_conmax_master_if.v
badd +103 ~/bender_cores/wb_conmax/rtl/verilog/wb_conmax_slave_if.v
badd +389 ~/bender_cores/wb_conmax/bench/verilog/test_bench_top.v
badd +51 ~/bender_cores/wb_conmax/bench/verilog/wb_model_defines.v
badd +1 ~/bender_cores/wb_conmax/bench/verilog/wb_slv_model.v
badd +6 ~/bender_cores/wb_conmax/bench/verilog/wb_mast_model.v
badd +73 ~/bender_cores/wb_conmax/bench/verilog/tests.v
badd +106 ~/bender_cores/wb_conmax/rtl/verilog/wb_conmax_msel.v
badd +3 ~/bender_cores/wb_conmax/rtl/verilog/wb_conmax_pri_dec.v
badd +119 ~/bender_cores/wb_conmax/rtl/verilog/wb_conmax_pri_enc.v
badd +0 ~/bender_cores/wb_conmax/rtl/verilog/wb_conmax_rf.v
silent! argdel *
set splitbelow splitright
set nosplitbelow
set nosplitright
normal t
set winheight=1 winwidth=1
argglobal
edit ~/bender_cores/wb_conmax/rtl/verilog/wb_conmax_rf.v
setlocal noautoindent
setlocal autoread
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-
setlocal commentstring=/*%s*/
setlocal complete=.,w,b,u,t,i
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal noexpandtab
if &filetype != 'verilog'
setlocal filetype=verilog
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatoptions=tcq
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=0
setlocal include=^#\\s*include
setlocal includeexpr=
setlocal indentexpr=
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255,+,-,?
setlocal nolinebreak
setlocal nolisp
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=octal,hex
setlocal nonumber
setlocal path=
setlocal nopreviewwindow
setlocal noreadonly
setlocal noscrollbind
setlocal shiftwidth=8
setlocal noshortname
setlocal nosmartindent
setlocal softtabstop=0
setlocal suffixesadd=
setlocal swapfile
if &syntax != 'verilog'
setlocal syntax=verilog
endif
setlocal tabstop=8
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal wrap
setlocal wrapmargin=0
silent! normal zE
let s:l = 10 - ((0 * winheight(0) + 29) / 58)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal zt
10
normal 0
set winheight=1 winwidth=20 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . s:sx
endif
let &so = s:so_save | let &siso = s:siso_save
