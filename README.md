<div align="center">

# asdf-cmake [![Build](https://github.com/amrox/asdf-cmake/actions/workflows/build.yml/badge.svg)](https://github.com/amrox/asdf-cmake/actions/workflows/build.yml) [![Lint](https://github.com/amrox/asdf-cmake/actions/workflows/lint.yml/badge.svg)](https://github.com/amrox/asdf-cmake/actions/workflows/lint.yml)


[cmake](https://cmake.org/documentation) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Why?](#why)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add cmake
# or
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

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/amrox/asdf-cmake/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Andy Mroczkowski](https://github.com/amrox/)
