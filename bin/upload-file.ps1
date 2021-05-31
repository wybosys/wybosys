
$BIN_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
python3 ${BIN_DIR}\upload-file $args
