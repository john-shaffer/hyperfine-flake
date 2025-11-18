# hyperfine-flake

A Nix flake for [hyperfine](https://github.com/sharkdp/hyperfine) and its scripts. Requires [Nix](https://determinate.systems/nix-installer/).

## Usage

```bash
nix develop github:john-shaffer/hyperfine-flake

# Run an example benchmark.
# You can replace 'sleep 0.1' with any shell command
# or executable.
hyperfine 'sleep 0.1' --export-json bench.json

# Plot the results on an image.
hyperfine-plot-histogram -o histogram.png bench.json

# See advanced statistics.
hyperfine-advanced-statistics bench.json
```

All scripts require exported JSON files as input.
The scripts included are:
- **hyperfine-advanced-statistics**
  - Prints advanced statistics such as the stddev and  
    percentiles
- **hyperfine-plot-benchmark-comparison**
  - Shows benchmark results as a bar plot grouped by command.
- **hyperfine-plot-histogram**
  - Shows benchmark results as a histogram.
- **hyperfine-plot-parametrized**
  - Shows parameterized benchmark results as an errorbar plot.
- **hyperfine-plot-progression**
  - Shows benchmark results in a sequential way
    in order to debug possible background interference,
    caching effects, thermal throttling and similar effects.
- **hyperfine-plot-whisker**
  - Shows benchmark results as a box and whisker plot.
- **hyperfine-welch-ttest**
  - Performs Welch's t-test on a file with two
    benchmark results to test whether or not the two distributions are the same.

## Install

```bash
nix profile add github:john-shaffer/hyperfine-flake
nix profile add github:john-shaffer/hyperfine-flake#scripts
```
