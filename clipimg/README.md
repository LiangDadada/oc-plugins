# clipimg

Export the current Windows clipboard image to a PNG file from WSL, then print the absolute PNG path.

This is intended for OMP workflows where a WSL terminal cannot paste image clipboard data directly.

The installer creates both:

- `~/.local/bin/clipimg`
- `~/.omp/agent/commands/clipimg.md` for the OMP `/clipimg` slash command

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/clipimg/install.sh | sh
```

By default, the installer writes the binary to `~/.local/bin/clipimg` and the OMP command to `~/.omp/agent/commands/clipimg.md`.

If `~/.local/bin` is not in `PATH`, add this to your shell config:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

If your OMP agent directory is not `~/.omp/agent`, set `PI_CODING_AGENT_DIR` while installing:

```bash
curl -fsSL https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/clipimg/install.sh | PI_CODING_AGENT_DIR="/path/to/agent" sh
```

## Usage in OMP

Copy or screenshot an image on Windows, then run in OMP:

```text
/clipimg 现在呢
```

The slash command runs `clipimg`, reads the generated PNG, then answers using that image.

## CLI usage

You can also run the CLI directly from WSL:

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

The uninstaller removes the binary and the managed OMP slash command. If `clipimg.md` exists but does not contain the install marker, it is left in place.
