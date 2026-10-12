# Execution and reproduction

## Environment and entry point

Use Python 3 and a licensed Questa installation with `vlib`, `vlog`, `vopt`, `vsim`, and `vcover` on PATH. The recorded runs use Questa 2021.1. From this directory:

```sh
python run.py --test all --seed 42
python run.py --test test_high --seed 42
```

Choose `random_test`, `test_mid`, `test_high`, `test_mix`, or `all`. `run.py` selects the matching top-level test at compile time and labels its UCDB with the matching test name. A failed diagnostic, nonzero failure count, or remaining scoreboard records causes an error. It creates `build/<test>_<seed>/work` and `results/<test>_<seed>/`. Compiled libraries can be regenerated from source.

## Source structure

- `hdl/alu_multi_cycle.sv`: supplied ALU RTL and width parameters.
- `hvl/parameter_packages/parameters.sv`: bus widths and opcodes.
- `hvl/interface_packages/`: interfaces, transactions, coverage, driver and monitors.
- `hvl/environment_packages/`: generator, reference model, scoreboard and environment.
- `hvl/tests/`: four profiles; `hvl/top.sv`: clock, reset and DUT connections.
- `test_plan/test_plan.csv`, `sim/test_plan.xml`: spreadsheet-style requirement links and workbook data.
- `results/`: seed-42 summaries, compile/elaboration/simulation logs, UCDBs, coverage and ranking.

## Coverage and ranking

Running all tests merges their databases and reports functional covergroups. Iterative ranking uses the individual databases with `-cvg`; it avoids treating a heterogeneous merged code view as an exact ranking source. Twenty-one bins require at least ten hits each. Reset/no-op values are excluded from arithmetic operand coverage, and reset/aborted values are excluded from numeric-result coverage. Passed comparisons and legal cancellations are separate counters.

The auxiliary Tcl simulation script is for a Questa session started in `code/sim`; the Python runner is the primary batch entry point. `wave.tcl` can be used in an interactive waveform session. Generated work libraries and waveform files are not required for reading the recorded results.
