---
description: Save Windows clipboard image into /tmp and read it.
---
<!-- installed by LiangDadada/oc-plugins clipimg -->
Run `clipimg` with the bash tool. It prints one absolute PNG path on stdout.

If `clipimg` exits non-zero, show the error and stop.

If it succeeds, read the printed PNG path as an image, then answer this request using that image:

$ARGUMENTS
