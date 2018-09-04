$tools_dir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

$hash = Get-FileHash -Path (Join-Path -Path $tools_dir -ChildPath 'flatc.exe') -Algorithm SHA256
$checksum = Get-Content -Path (Join-Path -Path $tools_dir -ChildPath 'CHECKSUM.txt') -Raw

If ($hash.Hash -ne $checksum) {
    # For good measure, if someone manually packs instead of using the psakefile
    throw 'The embedded checksum does not match the checksum of the flatc.exe binary!'
}
