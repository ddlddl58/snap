# Compilation guide to SNAP

This codebase uses makefiles for compilation. To use the correct template for your platform, link or copy the `*.mk` most appropriate to your platform to `current.mk`.

## Features

### Fimex
To include fimex support, the `FIMEXINC` and `FIMEXLIB` variables must be set in the selected `current.mk`. See `ubuntuBionic.mk` for an example on how to set this.
