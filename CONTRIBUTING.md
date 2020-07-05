# Contributing

To add a pull request for a new version of `flatc`, execute the following steps:

1. Manually download the release you'd like to package
2. Unzip the package and run `.\flatc.exe --version` to verify the version matches the download
3. Run the command `Get-FileHash -Path flatc.exe -Algorithm SHA256` on the new version of flatc
4. Update `CHECKSUM.txt` with the new sha
5. Update `flatc.nuspec` with the new version
6. Send the pull request and I'll merge it, build the package, and publish it to chocolatey.org!
