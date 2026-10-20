---
name: generate-image
description: Generate images (app icons, store feature graphics, promotional screenshots backgrounds, illustrations) with Replicate's google/nano-banana-pro model. Use whenever an image asset needs to be created unless the user names another model or provider.
---

# Generate images with Replicate

- Model: **`google/nano-banana-pro`** (unless the user says otherwise).
- Token: `$REPLICATE_API_TOKEN` from the environment. **Never** paste the token into a command, script, file or permission rule. If it isn't set, tell the user (see `~/Workspace/claude-config/README.md`, "Replicate token") and stop.
- Output: `screenshots/generated/` in the project (git-ignored), then process into final locations.
- Android apps with the playstore MCP server available can use `mcp__playstore__generate_image` instead.

## Aspect ratios

| Asset | `aspect_ratio` | Final size |
|---|---|---|
| App icon | `1:1` | Play 512×512; iOS 1024×1024 (no transparency, no rounded corners — the OS masks it) |
| Play feature graphic | `16:9` (crop) | 1024×500 |
| Phone screenshot background | `9:16` | per store size |
| iPad / tablet | `3:4` or `4:3` | per store size |

## Call

```bash
curl -s -X POST "https://api.replicate.com/v1/models/google/nano-banana-pro/predictions" \
  -H "Authorization: Bearer $REPLICATE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Prefer: wait" \
  -d @request.json > response.json
```

`request.json`: `{"input": {"prompt": "...", "aspect_ratio": "1:1", "output_format": "png"}}`. If the response status isn't `succeeded`, poll `urls.get` with the same header. Download `output` into `screenshots/generated/`.

## Process

- Resize/crop with `magick` (or `sips` on macOS): e.g. `magick in.png -resize 512x512 out.png`.
- Show the user the result before replacing any existing asset.
- Prompts: describe the app's actual function and brand colours; no text in icons; no other brands' logos.
