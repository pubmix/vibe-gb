param(
    [Parameter(Mandatory = $true)]
    [string]$Rom
)

$ErrorActionPreference = "Stop"

$path = Resolve-Path -LiteralPath $Rom
$bytes = [IO.File]::ReadAllBytes($path)
if ($bytes.Length -lt 0x150) {
    throw "File is too small to be a valid Game Boy ROM header: $path"
}

$title = [Text.Encoding]::ASCII.GetString($bytes[0x134..0x143]).Trim([char]0)
$info = [pscustomobject]@{
    Path = $path.Path
    Bytes = $bytes.Length
    Title = $title
    CgbFlag = ('0x{0:X2}' -f $bytes[0x143])
    CartType = ('0x{0:X2}' -f $bytes[0x147])
    RomSizeFlag = ('0x{0:X2}' -f $bytes[0x148])
    RamSizeFlag = ('0x{0:X2}' -f $bytes[0x149])
}

$info | Format-List
