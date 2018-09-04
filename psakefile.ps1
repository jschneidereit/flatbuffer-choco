Properties {
    $checksum = Get-Content -Path '.\tools\CHECKSUM.txt' -Raw
    $file = 'flatc_windows_exe'
    $zip = "$file.zip"
    [xml]$xml = Get-Content 'flatc.nuspec' -Raw
}

Task Clean {
    Remove-Item '*.zip' -Force -ErrorAction SilentlyContinue
    Remove-Item '*.nupkg' -Force -ErrorAction SilentlyContinue
    remove-item -Path 'flatc_windows_exe' -Recurse -Force -ErrorAction SilentlyContinue
}

Task Download -depends Clean {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $api = 'https://api.github.com/repos/google/flatbuffers/releases'
    $latest = (Invoke-WebRequest -Uri $api -UseBasicParsing | ConvertFrom-Json) | Select-Object -First 1 -ExpandProperty tag_name

    If (-not ($latest.EndsWith($xml.package.metadata.version))) {
        'The latest version and the version specified in the nuspec file do not match, manual updates are needed! (CHECKSUM, Version, etc.)' | Write-Warning
        $latest = "v$($xml.package.metadata.version)"
        "Downloading version $latest instead" | Write-Warning
    }

    Invoke-WebRequest -Uri "https://github.com/google/flatbuffers/releases/download/$latest/$zip" -OutFile $zip -UseBasicParsing -Verbose
    Expand-Archive -Path $zip -DestinationPath $file -Verbose
}

Task Checksum -depends Download {
    $hash = Get-FileHash -Path (Join-Path -Path $file -ChildPath 'flatc.exe') -Algorithm SHA256
    if ($checksum -ne $hash.Hash) { throw 'The downloaded flatc checksum does not match the one in CHECKSUM.txt' }
}

Task Pack -depends Checksum {
    choco pack flatc.nuspec

    if (-not $?) { throw 'choco pack failed!' }
}
