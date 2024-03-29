# bgwinch.nvim

iTerm 3.5 sends the SIGWINCH signal when macOS changes appearance from light or dark mode.
Neovim 0.7 added the ability to run an autcommand on SIGWINCH.
This plugin combines those two features to automatically toggle vim's light and dark mode in sync with the overall system.

![bgwinch](https://user-images.githubusercontent.com/1973/163689626-a1d037f3-dfc4-4aea-b6f6-085bdc8f0c89.gif)

It depends on [plenary.nvim](https://github.com/nvim-lua/plenary.nvim).

## Packer

```lua
use {
  "will/bgwinch.nvim",
  config = function() require("bgwinch").setup() end,
}
```

## Usage

Outside of calling the `setup` function to create the autocommand, there is nothing else you have to do.


You can call the functions `disable_and_toggle_bg` to stop automatically changing and `reenable` to start again.
These can be used for example in whichkey:

```lua
local bgwinch = require "bgwinch"
local mappings = {
  b = { bgwinch.disable_and_toggle_bg, "Toggle background" },
  B = { bgwinch.reenable, "Auto background" },
}
```

### Other platforms

If any terminal emulators non-mac platforms also send SIGWINCH on appearance change, you can give a custom `set_bg` function in `setup({set_bg = function()...end})`.

The wiki has some guides to other platforms such as Gnome. PRs welcome to add support for these other platforms as needed.
