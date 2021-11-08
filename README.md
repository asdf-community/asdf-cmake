<div align="center">

# asdf-cmake [![Build](https://github.com/amrox/asdf-cmake/actions/workflows/build.yml/badge.svg)](https://github.com/amrox/asdf-cmake/actions/workflows/build.yml) [![Lint](https://github.com/amrox/asdf-cmake/actions/workflows/lint.yml/badge.svg)](https://github.com/amrox/asdf-cmake/actions/workflows/lint.yml)


[cmake](https://cmake.org/documentation) plugin for the [asdf version manager](https://asdf-vm.com).

This plugin will try to install an [official binary release of CMake](https://github.com/Kitware/CMake/releases), but can also build and install from source if necessary or desired.

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.

# Install

Plugin:

```shell
asdf plugin add cmake https://github.com/amrox/asdf-cmake.git
```

cmake:

```shell
# Show all installable versions
asdf list-all cmake

# Install specific version
asdf install cmake latest

# Set a version globally (on your ~/.tool-versions file)
asdf global cmake latest

# Now cmake commands are available
cmake --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

## cmake-gui

Binary installations include `cmake-gui` by default.

If installing from source, and you have Qt installed on your machine you can
get the cmake-gui program built by providing the path to the Qt binary
directory in the QTBINDIR environment variable when invoking asdf install
cmake.

For instance, on a Mac with Qt installed using brew that would be :

QTBINDIR=/usr/local/opt/qt/bin asdf install cmake <version>
# Configuration

A few environment variables can affect this plugin:

- `ASDF_CMAKE_FORCE_SOURCE_INSTALL`: Set to `1` to force a source-based installation instead of using a pre-compiled binary, even if a binary release is available.
- `QTBINDIR`: Set to your Qt installation to build `cmake-gui`, if CMake is being built from source.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/amrox/asdf-cmake/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Andy Mroczkowski](https://github.com/amrox/)
