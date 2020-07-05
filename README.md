# Readme for third party flatc chocolatey package

Note: see [the contributing file](CONTRIBUTING.md) to see instructions for helping me out on a new version of flatc!

This is a chocolatey package definition that packages the flatbuffer compiler `flatc.exe` for windows for easier consumption on the command line.

The `psakefile.ps1` file gets the version of the executable specified in the `flatc.nuspec` file as well as verifying the checksum, and generates a new chocolatey package `flatc.nupkg`.

I bundled the [license](tools/LICENSE.txt) that was in the google [flatbuffer repo](https://github.com/google/flatbuffers/blob/master/LICENSE.txt) at the time of creation since it seemed like the right thing to do.
