# 设置快捷方式
Set-PSReadLineOption -EditMode Emacs

# 引入 posh-git
Import-Module posh-git

# 引入 oh-my-posh
Import-Module oh-my-posh

# 设置 PowerShell 主题
Set-PoshPrompt -Theme robbyrussel

# 设置 Tab 键补全
# Set-PSReadlineKeyHandler -Key Tab -Function Complete

# 设置 Ctrl+d 为菜单补全和 Intellisense
Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete

# 设置 Ctrl+d 为退出 PowerShell
Set-PSReadlineKeyHandler -Key "Ctrl+d" -Function ViExit

# 设置 Ctrl+z 为撤销
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo

# 设置向上键为后向搜索历史记录
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward

# 设置向下键为前向搜索历史纪录
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Python 直接执行
$env:PATHEXT += ";.py"

# 查看目录 ls & ll
function ListDirectory {
    foreach ($e in (Get-ChildItem).Name) {
        Write-Host $e '  ' -NoNewLine
    }
}
Set-Alias -Name ls -Value ListDirectory
Set-Alias -Name ll -Value Get-ChildItem
