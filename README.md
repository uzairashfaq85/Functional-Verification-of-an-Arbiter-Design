# Functional Verification of an Arbiter Design

VHDL verification project for a 3-requester arbiter, including RTL, protocol/property checkers, directed/self-running testbenches, PSL properties, and legacy-compatible structural wrappers.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Verification Strategy](#verification-strategy)
3. [Repository Structure](#repository-structure)
4. [Current Engineering Metrics](#current-engineering-metrics)
5. [Implemented Modules](#implemented-modules)
6. [Simulation Flow (ModelSim/Questa)](#simulation-flow-modelsimquesta)
7. [Notes & Assumptions](#notes--assumptions)

---

## Project Overview

This project implements and verifies a multi-request arbiter with the following goals:

- Generate valid one-hot grant outputs (`001`, `010`, or `100`) when requests are issued.
- Enforce request/command protocol consistency.
- Check key safety properties using both VHDL checkers and PSL assertions.
- Support both clean module names and legacy module naming through wrappers.

The primary arbiter (`arb1`) uses a deterministic 2-cycle response pipeline and fairness-oriented internal counters.

---

## Verification Strategy

The repository uses multiple verification layers:

- **Directed testbenching:** explicit test sequences for single and contending requesters.
- **Driver-based structural simulation:** auto-generated request patterns with runtime assertions.
- **Protocol checker:** validates command pulse rules and non-zero request on command.
- **Property checker:** validates one-hot grant and request-to-grant consistency.
- **PSL properties:** declarative constraints and assertions for formalized behavior checks.

---

## Repository Structure

```text
.
├── .gitignore
├── README.md
├── src/
│   ├── arb.vhd                     # Legacy wrapper entity -> arb1
│   ├── arb1.vhd                    # Main arbiter RTL
│   ├── arb_seu.vhd                 # SEU-injection arbiter variant
│   └── simple_arb.vhd              # Fixed-priority reference arbiter
└── verification/
   ├── checkers/
   │   ├── property_checker.vhd    # Functional property monitor
   │   ├── protocol_checker.vhd    # Protocol monitor
   │   └── protocol_checker1.vhd   # Legacy wrapper entity -> protocol_checker
   ├── drivers/
   │   └── driver.vhd              # Stimulus driver (request sequencing)
   ├── psl/
   │   └── arb_tb.psl              # PSL constraints/assertions
   └── tb/
      ├── arb_seu_tb.vhd          # SEU scenario testbench
      ├── arb_tb.vhd              # Legacy-compatible structural top TB
      ├── arbtb1.vhd              # Directed contention scenarios
      ├── arbtb2.vhd              # DUT + checker integration TB
      └── arbtb3.vhd              # Self-running integration TB
```

---

## Current Engineering Metrics

| Metric | Current Status |
| --- | --- |
| Core RTL implementations | 3 (`arb1`, `simple_arb`, `arb_seu`) |
| Compatibility wrappers | 2 (`arb`, `protocol_checker1`) |
| Verification testbenches | 5 |
| Runtime checker modules | 2 |
| PSL property file | 1 |
| Testbench self-checking | Enabled (`assert` + controlled `stop`) |
| Repository cleanliness | Duplicates/legacy artifacts removed |

> Note: Full simulator execution (`vcom`/`vsim`) depends on your local EDA tool installation.

---

## Implemented Modules

### RTL

- `arb1`: main arbitration logic with pipelined response behavior.
- `simple_arb`: compact fixed-priority reference arbiter.
- `arb_seu`: SEU fault-injection variant with one-hot error signaling.

### Verification

- `property_checker`: one-hot grant + request/grant relation checks.
- `protocol_checker`: command pulse and non-zero request checks.
- `driver`: cyclical request generation for structural integration testing.

### Compatibility

- `arb`: allows legacy flows expecting entity name `arb`.
- `protocol_checker1`: allows legacy flows expecting `protocol_checker1`.
- `arb_tb`: structural top TB for immediate compile/run with legacy naming.

---

## Simulation Flow (ModelSim/Questa)

From repository root:

### Create Work Library

`vlib work`

### Compile (Clean Integration Flow)

`vcom src/arb1.vhd verification/drivers/driver.vhd verification/checkers/property_checker.vhd verification/checkers/protocol_checker.vhd verification/tb/arbtb3.vhd`

### Run (Clean Integration TB)

`vsim work.arbtb3`

`run -all`

### Compile (Legacy-Compatible Structural Flow)

`vcom src/arb1.vhd src/arb.vhd verification/drivers/driver.vhd verification/checkers/property_checker.vhd verification/checkers/protocol_checker.vhd verification/checkers/protocol_checker1.vhd verification/tb/arb_tb.vhd`

### Run (Legacy-Compatible Structural TB)

`vsim work.arb_tb`

`run -all`

### One-shot run (all testbenches)

From repository root (PowerShell in a ModelSim/Questa-enabled shell):

`./run_all_tb.ps1`

This script recreates the `work` library, compiles all VHDL files in dependency order, then runs:

- `arbtb1`
- `arbtb2`
- `arbtb3`
- `arb_tb`
- `arb_seu_tb`

---

## Notes & Assumptions

- `cmd` is expected as a one-cycle pulse.
- `req` is expected non-zero when `cmd = '1'`.
- Requests are assumed stable through the intended grant latency window.
- The cleaned `src/` and `verification/` folders are the authoritative implementation.

---

**Author:** Uzair Ashfaq  
**Date:** November 2025
