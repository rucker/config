Set-PSReadLineOption -EditMode Emacs -HistoryNoDuplicates:$True -HistorySearchCursorMovesToEnd:$True
Set-PsReadLineKeyHandler -Chord Ctrl+Shift+v -Function Paste
