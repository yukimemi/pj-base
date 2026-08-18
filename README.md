# pj-base

Language-agnostic [kata](https://github.com/yukimemi/kata) template
— the LICENSE / repo-hygiene boilerplate every consumer project
shares.

## Layered with

- [`pj-rust`](https://github.com/yukimemi/pj-rust) — Rust language layer
- [`pj-rust-cli`](https://github.com/yukimemi/pj-rust-cli) — Rust CLI extras
- (planned) `pj-go`, `pj-bun`, ...

Compose via [`pj-presets`](https://github.com/yukimemi/pj-presets):

```sh
kata init github.com/yukimemi/pj-presets:rust-cli ./your-new-pj
```

## What this layer applies

| File | how | when |
|---|---|---|
| `LICENSE` | overwrite | once |

`once` means: laid down on `kata init`; never re-applied. Edit it
freely after init.

## Renovate: one rule per layer

Renovate config is chained, not centralised. Two rules every pj-\*
layer follows:

1. **A layer disables only the workflows it renders itself.** pj-base
   owns `kata-apply.yml`, `apm-bump.yml`, `claude-review.yml` and
   `claude.yml`, so only those four are listed in its `default.json`.
   `ci.yml` belongs to pj-rust / pj-denops / pj-nvim, `release.yml` to
   the three Rust leaf layers, `deploy.yml` to pj-firebase — each
   disables its own in its own `default.json`.

   pj-base used to list all of them. That inverted the dependency
   (the bottom layer naming files only upper layers produce) and it
   blocked any project on the bare `base` preset from hand-writing a
   workflow with one of those names — a Lume blog wanting its own
   `ci.yml`, for instance.

2. **Every layer ships the same `extends` sync**, naming itself:

   ```toml
   [[file]]
   src = "renovate.json"
   how = "merge-json"
   when = "always"
   paths = ["extends"]
   ```

   Each layer's `default.json` extends the layer below it, so the
   consumer's single `extends` entry pulls in the whole chain. kata's
   compose rule (last layer wins on file conflicts) makes the topmost
   *applied* layer the winner automatically — no layer has to know
   what sits above it, and no preset variable is involved.

   Preset-level `[vars]` would look like the natural home for "which
   layer is on top", but it does not survive: `kata apply` passes an
   empty preset-vars table (`kata/src/cmd/apply.rs`) and
   `.kata/applied.toml` does not persist them, so a preset var is
   silently init-only and every later apply reverts to the template
   default.

   Adding a new layer therefore means: give it a `default.json` that
   extends its parent, and copy the block above into its
   `template.toml`.

## License

MIT.
