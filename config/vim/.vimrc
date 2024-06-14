" 行号
set number
" 语法高亮
syntax on
" 在底部显示，当前处于命令模式还是插入模式。
set showmode
" 命令模式下，在底部显示，当前键入的指令。
set showcmd
" 开启文件类型检查，并且载入与该类型对应的缩进规则。
filetype indent on
" 按下回车键后，下一行的缩进会自动跟上一行的缩进保持一致。
set autoindent
" 高亮当前行
set cursorline
" 关闭自动折行
set nowrap
" 是否显示状态栏。0 表示不显示，1 表示只在多窗口时显示，2 表示显示。
set laststatus=1
" 光标遇到圆括号、方括号、大括号时，自动高亮对应的另一个圆括号、方括号和大括号。
set showmatch
" 搜索时，高亮显示匹配结果。
set hlsearch
" 打开英语单词的拼写检查。
set spell spelllang=en_us
" 保留撤销历史。
set undofile
" Vim 需要记住多少次历史操作。
set history=1000
" 打开文件监视。如果在编辑过程中文件发生外部改变（比如被别的编辑器编辑了），就会发出提示。
set autoread
" 命令模式下，底部操作指令按下 Tab 键自动补全。第一次按下 Tab，会显示所有匹配的操作指令的清单；第二次按下 Tab，会依次选择各个指令。
set wildmenu
set wildmode=longest:list,full