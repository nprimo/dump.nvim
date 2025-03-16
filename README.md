# dump.nvim

A plugin to dump thoughts without leaving nvim.

## Features

Provide the following commands:

- `Dump` - create a new "dump" file;
- `DumpList` - list the current "dump" files with a preview (using
  [`telescope`](https://github.com/nvim-telescope/telescope.nvim));
- `DumpArchive` - list the current "dump" files with a preview and archive the
  selected one (using
  [`telescope`](https://github.com/nvim-telescope/telescope.nvim)).

By default:

- all "dump" files get stored inside the directory `~/dump/`;
- all "dump" files get archived in the directory `~/dump/.archive/`.

## Install

Using [`lazy.vim`](https://github.com/folke/lazy.nvim):

```lua
return {
    "nprimo/dump.nvim"
}
```
