
$BIN_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
python3 ${BIN_DIR}\hardlink-to-symlink $args
