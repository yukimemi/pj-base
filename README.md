# pj-base

Language-agnostic [kata](https://github.com/yukimemi/kata) template
— the LICENSE / repo-hygiene boilerplate every yukimemi/* project
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

## License

MIT.
