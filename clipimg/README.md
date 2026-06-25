# clipimg

Export the current Windows clipboard image to a PNG file from WSL, then print the absolute PNG path.

This is intended for OMP / opencode workflows where a WSL terminal cannot paste image clipboard data directly.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/clipimg/install.sh | sh
```

By default, the installer writes to `~/.local/bin/clipimg`.

If `~/.local/bin` is not in `PATH`, add this to your shell config:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

Copy or screenshot an image on Windows, then run from WSL:

```bash
clipimg
```

On success, `clipimg` prints one absolute PNG path:

```text
/tmp/omp-clipboard/clip-20260625-120000-12345.png
```

On failure, it exits non-zero and prints the reason, for example:

```text
Clipboard does not contain an image.
```

## Output directory

Set `CLIPIMG_DIR` to choose where PNG files are written:

```bash
CLIPIMG_DIR="$HOME/Pictures/clipimg" clipimg
```

Default:

```text
/tmp/omp-clipboard
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/clipimg/uninstall.sh | sh
```
