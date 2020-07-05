Properties {
    $checksum = Get-Content -Path '.\tools\CHECKSUM.txt' -Raw
    $file = 'flatc_windows_exe'
    $zip = "$file.zip"
    [xml]$xml = Get-Content 'flatc.nuspec' -Raw
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-LatestVersionNumber {
    $api = 'https://api.github.com/repos/google/flatbuffers/releases'
    return (Invoke-WebRequest -Uri $api -UseBasicParsing | ConvertFrom-Json) | Select-Object -First 1 -ExpandProperty tag_name
}

Task Clean {
    Remove-Item '*.zip' -Force -ErrorAction SilentlyContinue
    Remove-Item '*.nupkg' -Force -ErrorAction SilentlyContinue
    Remove-Item -Path 'flatc_windows_exe*' -Recurse -Force -ErrorAction SilentlyContinue
}

Task Download -depends Clean {    
    $latest = Get-LatestVersionNumber
    Invoke-WebRequest -Uri "https://github.com/google/flatbuffers/releases/download/$latest/$zip" -OutFile "$file.zip" -UseBasicParsing -Verbose

    If (-not ($latest.EndsWith($xml.package.metadata.version))) {
        "The latest version '$latest' and the version specified in the nuspec file do not match, manual updates are needed! (CHECKSUM, Version, etc.)" | Write-Warning
        $latest = "v$($xml.package.metadata.version)"
        "Downloading version $latest for manual comparison" | Write-Warning
        Invoke-WebRequest -Uri "https://github.com/google/flatbuffers/releases/download/$latest/$zip" -OutFile "$file.$latest.zip" -UseBasicParsing -Verbose
    }

    Get-ChildItem -Filter *.zip | ForEach-Object { Expand-Archive -Path $_.Name -DestinationPath $_.BaseName -Verbose }
}

Task Checksum -depends Download {
    $latest = Get-LatestVersionNumber
    $hash = Get-FileHash -Path (Join-Path -Path $file -ChildPath 'flatc.exe') -Algorithm SHA256
    if ($checksum -ne $hash.Hash) { throw 'The downloaded flatc checksum does not match the one in CHECKSUM.txt' }
}

Task Pack -depends Checksum {
    choco pack flatc.nuspec

    if (-not $?) { throw 'choco pack failed!' }
}
