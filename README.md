# Coverage-Driven Verification of a Multi-Cycle ALU

A class-based SystemVerilog environment extends a supplied ALU/framework with serialized transactions, randomized idle gaps, protocol monitors, a reference model, and a reset-aware scoreboard.

## Technical highlights

- Covered all 21 defined functional bins at their hit goals over four seed-42 Questa profiles, with 1,164 completed comparisons, 189 checked legal cancellations, and zero failures.
- Retains the supplied RTL/framework attribution and MIT license. The environment is class-based and does not use the UVM library.

## Explore the project

- [Source and execution guide](code/RUNNING.md)
- [Technical report (PDF)](report/Report_EN.pdf)
- [Technical report (Markdown)](report/Report_EN.md)
- [Assignment/specification (PDF)](assignment/Assignment_EN.pdf)

## Reproduction and attribution

Read the execution guide and report before running the code. Dependencies, input data, licensed tools, and hardware requirements vary by project. Recorded results are distinguished from rerun results in the accompanying documentation. Team and third-party source attribution in the reports and source headers is retained. This portfolio does not claim independent authorship of supplied frameworks or dependencies.
