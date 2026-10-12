# Coverage-Driven Verification of a Multi-Cycle ALU

## Scope and verification architecture

This project develops a class-based SystemVerilog verification environment for a supplied multi-cycle arithmetic logic unit. It adapts interfaces, transactions, driver, monitors, reference model, scoreboard, coverage and test selection to a packetized operand/result protocol. The environment uses mailboxes and events rather than the UVM library. The supplied RTL and framework headers credit Alireza Abbasian; the verification project and its report are by Reza Sanaee Nezhad.

An input transaction represents a complete operation and two full operands. The driver transmits that transaction as a sequence of bus-width chunks. The input monitor reconstructs accepted chunks independently and passes the complete transaction to the reference model. The output monitor collects result chunks or reset notifications. The scoreboard checks them against the reference queue and distinguishes completed results from operations canceled by a legal reset. Functional covergroups connect the tests to a spreadsheet-style plan.

## Parameters and operation contract

The default operand bus width is eight bits and each complete unsigned operand is 32 bits. The result bus is 16 bits and complete result storage is 64 bits. A complete operand pair therefore uses four accepted input beats. Results are sent least-significant chunk first, using one to four beats as indicated by result_last. A zero or sufficiently small result uses one beat. The monitor reconstructs the complete result in initially zeroed storage, so omitted leading zero chunks do not leave stale data.

The physical rst input is active low. Software reset is opcode 111 with operand_valid asserted, and it is accepted even while ready is low. The normal opcodes are no-op 000, unsigned addition 001, bitwise AND 010, bitwise XOR 011 and unsigned multiplication 100. Opcodes 101 and 110 are excluded by the transaction constraint and classified as illegal coverage bins. No-op does not generate an arithmetic output transaction. Software reset clears result storage, deasserts result_valid, asserts result_rst and returns the unit to IDLE.

The RTL uses IDLE, RECEIVE, EXECUTE and SEND states. ready is asserted in IDLE and RECEIVE. Arithmetic uses the operation captured with the first operand beat. Operand widths must divide the full operand width, result bus width must divide the full result width, and the result width must accommodate the complete unsigned product. Parameter checks reject unsupported configurations. The result bus has one combinational writer driven from the full-result register and chunk index.

## Input and output interfaces

The input interface carries ready, operand_valid, operand_last, op, a and b together with clock and active-low reset. Its DUT modport receives the operand and control signals and produces ready. The driver modport drives operands and control while observing ready, clock and reset. The monitor modport observes all signals without driving them. Distinguishing these directions makes the interaction between the three roles explicit.

The output interface carries result_valid, result_last, result_rst and the result chunk. The DUT drives these signals, and the monitor observes them. The top-level module connects the four width parameters and every input/output control signal to the corresponding DUT port. Both interfaces share the same system clock and physical reset.

## Input transactions, constraints and copying

ALU_in_transaction contains a randomized operation, full-width a and b values, and the four-bit randomized clk_gap. Its legal-operation constraint permits the six defined opcodes. Its gap constraint permits values zero through fourteen inclusive. clk_gap specifies ready idle cycles before starting a normal operand frame; it does not represent the total latency of a previous operation or clocks spent waiting for ready.

The input transaction stores all 32 bits of each operand even though the bus carries eight bits at a time. Serialization belongs to the driver rather than to the generator. do_copy copies op, a, b and clk_gap into a separate object. do_compare compares operation and operand values; timing gap is excluded because two transactions with identical arithmetic inputs can have different idle spacing without changing the mathematical result.

ALU_in_transaction_range extends the base transaction with inclusive minimum and maximum bounds for each operand. Randomization obeys both the inherited legal-operation/gap constraints and the range constraints. Its copy method retains the range bounds and clk_gap as well as arithmetic fields. Range display uses inclusive endpoints, matching the actual greater-than-or-equal and less-than-or-equal constraints.

## Output transactions and interruption state

ALU_out_transaction stores the complete 64-bit result, result_rst, an aborted flag and an issue timestamp. A new object initializes interruption state to false, and complete reconstruction starts with zeroed result storage. The copy method retains result, reset flag and interruption state in a separate object. Its arithmetic comparison checks result and result_rst.

The aborted flag means a pending arithmetic operation was interrupted by a software reset. It is not an alternative successful arithmetic result. In that event the observable reset output must be zero and must have result_rst asserted. The canceled arithmetic operation and the completed reset command are accounted for separately. This prevents a flagged result from being accepted merely because its interruption bit is set.

## Driver scheduling and packet serialization

The generator sends transaction objects through gen2drv. The driver removes one object, transmits it, and signals drv2gen so that generation can continue. Stimulus is driven on falling clock edges and accepted by the DUT on rising edges. This places values on the bus before the DUT's sampling edge rather than changing them in the same active event region as DUT sampling.

For a normal transaction, the driver waits until the physical reset is released and ready is asserted. It waits the requested number of ready idle clocks, then sends four successive eight-bit portions from a and b. The indexed slice for beat i begins at bit i*OPERAND_BUS_WIDTH. operand_valid is asserted for each beat, and operand_last is asserted only for the final beat. After the last accepted beat, the control signals are deasserted on a falling edge. The full operand object is not modified by serialization.

For software reset, the driver waits for physical reset release but does not wait for ready. It asserts operand_valid with rst_op for one accepted cycle. This enables a reset command during calculation or result collection, when the unit is busy. Consecutive software-reset commands remain separate accepted commands even when result_rst is asserted in consecutive cycles. Generator/driver event synchronization prevents two threads from driving competing operand frames.

## Input monitor and observed idle gap

The input monitor samples at rising edges, when the driver values are stable. An ordinary accepted beat requires operand_valid and ready while physical reset is released. A reset command can be recognized with operand_valid and rst_op even when ready is low. The monitor creates a new transaction at the start of an accepted frame and records the operation from the bus rather than from the driver's object.

For an ordinary frame, each accepted eight-bit a and b chunk is placed at its corresponding position in the 32-bit transaction. The monitor continues until operand_last and checks that the frame cannot exceed the declared maximum number of beats. A gap between beats is not filled with unaccepted bus data. The reconstructed object is copied into the model mailbox only after the frame has completed.

Idle-cycle counting includes ready clocks without a valid new operand, and excludes busy clocks and physical-reset time. The observed gap is checked against the zero-to-fourteen stimulus contract before assignment to the four-bit field. A software-reset input produces a reset transaction directly. Input functional coverage is sampled from monitored transactions, so it reflects accepted bus behavior rather than requested generator values.

## Output monitor and reset event capture

The output monitor samples on falling edges, after the DUT's rising-edge updates have settled. It waits until the physical reset is released and either result_valid or result_rst is asserted. A result transaction is reconstructed from successive 16-bit chunks in 64-bit storage. result_last identifies the final chunk, and the monitor checks the maximum beat count.

If result_valid disappears before result_last without a reset notification, the monitor reports a protocol failure. If result_rst arrives during reconstruction, the partial numeric value is not treated as a valid completed answer; the record contains a zero reset result and is marked as interrupted. A reset arriving before the first result beat is also emitted as a reset record and is associated with the pending arithmetic reference by the scoreboard.

One software-reset record is emitted per active reset cycle. The next monitor call starts at the next falling edge. This allows two back-to-back accepted reset commands to be observed separately. Physical-reset cycles are excluded while rst is low. The stream is therefore not collapsed into one event merely because result_rst remains high across adjacent command cycles.

## Reference model

The model receives independently monitored full input transactions. Addition produces an unsigned extended sum in result-width storage, AND and XOR produce their bitwise results, and multiplication produces the complete unsigned product. Ordinary arithmetic results have result_rst equal to zero. rst_op produces a zero result with result_rst equal to one. No-op produces no expected arithmetic result and is not enqueued into the output reference stream.

The model does not use the randomized idle gap in calculation. Time spacing influences protocol execution and coverage, but not arithmetic. A mailbox carries expected result objects to the scoreboard in accepted transaction order. The operation/result mapping is shown in the table and reference-model implementation.

## Scoreboard ordering and legal cancellation

The scoreboard consumes expected and actual records in order. A complete ordinary result must match both numeric result and reset flag. A clean reset result must match the reset reference. A mismatch increments the failed count and prints both objects; a nonzero failed count terminates the test as a failure.

When an actual reset arrives while the next expected record is an arithmetic result, the reset legally cancels that pending operation. The observable result must still be zero. The scoreboard increments a separate aborted counter and consumes the following reset reference to check the actual reset notification. It does not count the canceled arithmetic operation as a passed result. Unexpected reset behavior cannot silently pass because the following expected record must also compare as a reset.

Output functional coverage is sampled after this classification, so interruption coverage includes a reset before the first result beat as well as during result collection. The canceled operation and completed reset command are represented separately for coverage accounting without placing duplicate physical output records in the mailbox. The final summary reports passed, aborted and failed counts, and both remaining queue sizes. The automated runner requires zero failures and no pending records.

## Testbench integration and test profiles

The top-level testbench starts with physical reset asserted, releases it after 200 ns, and generates a clock that toggles every 5 ns, for a 10 ns period. Interfaces and the DUT share that clock. Compile-time test selection chooses random_test, test_mid, test_high or test_mix. The selected name is also recorded in the coverage database so that labels agree with the instantiated test.

random_test uses the complete legal operand space. test_mid uses explicit width-safe bounds from the midpoint through the maximum unsigned operand. test_high restricts operands to the largest two representable values. test_mix successively uses unrestricted, mid-range, high-range and low-range profiles. Range endpoints are inclusive. A selected blueprint is installed before generation begins. Reset/no-op operand defaults are not counted as numeric operand coverage.

The mid and high tests run for 20000 ns; the mixed profile runs through its successive timed phases, and the random test runs for approximately 100000 ns. Each environment includes generator, driver, model, input monitor, output monitor and scoreboard threads. Tests terminate with a scoreboard summary rather than relying on an infinite background clock to stop by itself.

## Functional coverage and complete test plan

The input operation coverpoint has six legal bins and default illegal bins for undefined opcodes. Each legal bin requires at least ten hits. Operand coverpoints are sampled only for add, AND, XOR and multiply operations. For 32-bit unsigned operands, low covers zero through 0x7fffffff, mid covers 0x80000000 through 0xfffffffd, and high covers 0xfffffffe through 0xffffffff. These three ranges are disjoint and include both endpoint values.

The idle-gap coverpoint excludes reset commands and has three bins: zero, one through eight, and nine through fourteen. The three groups match the constrained input domain. Fifteen is not a legal requested gap. The input group contains fifteen bins: six operation bins, three a bins, three b bins and three gap bins.

The output numeric result is covered only when the record is neither a reset nor an aborted operation. Its two bins span zero through 0x7fffffffffffffff and 0x8000000000000000 through 0xffffffffffffffff. result_rst has zero and one bins. reset_during_calculation has noninterrupted and interrupted bins. The output group contains six bins, giving twenty-one defined functional bins in total. Each bin uses an at-least-ten hit goal.

The test-plan CSV links operation, a, b, gap, result, reset notification and interruption coverpoints. The input section has weight three, the output section weight one, and the operation requirement weight five. Every requirement's goal is 100 percent. The supplied workbook representation and the native plan table preserve all of these links and weights. Coverage measures exercised definitions, not the correctness of every possible input or the completeness of the definitions themselves.

## Recorded academic coverage and ranking figures

The recorded classroom report contains a Questa HTML summary with two tests marked OK, a weighted test-plan total of 100 percent, and twenty-one bins shown as covered. The output result, result_rst and reset_during_calculation displays each show two covered bins and no missing bins. These figures are retained as the academic experiment record, together with the original spreadsheet and rank summaries.

One captured ranking lists test_mid42 with total coverage 88.06 percent and test-plan coverage 93.75 percent. The other lists test_high42 with total coverage 87.46 percent and test-plan coverage 100 percent. Both captured summaries report 0.06 seconds of CPU time; their simulation-time entries are 20050000 ps and 20000000 ps respectively. These are different reported metrics and captured views. A 100-percent test-plan goal is not the same quantity as the total-coverage percentage, and the two screenshots do not demonstrate monotonic aggregate coverage between two database merges.

Zero operand values associated with reset/no-op transactions do not establish that a numeric low-range test has been exercised. The arithmetic operand coverpoints therefore use the operation qualification described above. The ranking objective is to identify a small useful set of tests against defined coverage goals, rather than infer correctness from a high percentage alone.

## Reproducible simulation results

The distributed runner compiles and elaborates each selected test using Questa 2021.1, runs it with seed 42, captures the scoreboard and saves its UCDB. Compilation and elaboration report zero errors and zero warnings for the four test profiles. The results table gives completed comparisons, legal cancellations, failures, queue sizes and functional covergroup coverage for each execution.

All four runs have zero failed comparisons and empty expected/actual queues at the end. Together they contain 1164 completed comparisons and 189 separately classified legal cancellations. Merging their functional coverage covers all twenty-one defined bins and reports 100 percent covergroup coverage. This statement is limited to the explicit functional model and hit goals; it is not a claim of complete RTL code coverage or a formal proof.

Iterative functional-coverage ranking uses the four individual databases. random_test42 contributes a reported aggregate functional metric of 91.66 percent; adding test_high42 reaches 100 percent. Two tests contribute and two do not add coverage under that ranking goal. The ranking summary reports 0.02 seconds of CPU time and 120050000 ps of simulation time. The decimal value printed by the ranking tool is retained rather than interpreted as an exact count fraction.

## Execution and engineering limits

run.py locates Questa tools on PATH, creates a separate build library and results directory for each test/seed, compiles sources in dependency order, elaborates top, and loads the elaborated design directly in command-line mode. Relative library paths avoid legacy simulator parsing of spaces in a Windows parent directory. The runner checks diagnostic messages as well as process return codes, because a simulator can finish with a successful process code after reporting a fatal testbench failure.

The package includes the full RTL, interfaces, class environment, tests, test plan, compiled-result summaries, UCDBs and functional-coverage/ranking output. The build libraries are regenerable and are not required to inspect the project. The report does not establish FPGA placement, timing closure, power or area improvement. Verification uses a finite test set and a model; additional assertions, directed protocol cases and formal methods could expand assurance beyond the stated experiments.
