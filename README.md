# lazyasdf

Experimental TUI for [asdf](https://asdf-vm.com/)

<img width="1115" alt="image" src="https://user-images.githubusercontent.com/5523984/222877102-f76cb0cf-4f05-4b93-8db0-636cc8e6494d.png">

## Installation

### Using brew

`brew install mhanberg/tap/lazyasdf`

### Using git

You need a `python` executable on your path.

```bash
git clone https://github.com/mhanberg/lazyasdf.git
cd lazyasdf
# asdf plugin add <missing plugins>
asdf install
mix deps.get
mix run --no-halt
```

## Usage

- `h`, `j`, `k`, `l` or arrows for navigation
- `i` to install a version
- `u` to uninstall a version
- `L` to set a local version
- `G` to set a local version

## License

The MIT License (MIT)

Copyright © 2023 Mitchell A. Hanberg

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
