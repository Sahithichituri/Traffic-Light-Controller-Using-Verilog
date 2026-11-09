# Academic Minor Project Report

## Design and Simulation of a Traffic Light Controller Using Finite State Machine (FSM) in Verilog

### Abstract

This minor project designs a synchronous traffic light controller for two
opposing traffic directions, North-South (NS) and East-West (EW), using a
finite state machine described in Verilog HDL. Four states sequence the
directions through green and yellow indications while holding the opposing
direction red. An active-high asynchronous reset initializes the controller
to NS green and EW red. A self-checking testbench verifies the reset, output
decoding, state sequence, legal output combinations, and mutual exclusion of
green indications over two complete cycles. Icarus Verilog and GTKWave support
simulation and waveform review; Yosys is used for synthesis when installed.

### 1. Introduction

An intersection controller must assign right-of-way without simultaneously
granting conflicting approaches a green indication. A finite state machine
provides a structured way to represent the allowed phases and transitions.
This project models the NS and EW directions as four sequential phases. The
design is intended for digital logic coursework and demonstrates RTL coding,
testbench verification, waveform generation, and synthesis workflow.

### 2. Problem Statement

Design a Verilog-2001 controller that continuously cycles through NS green,
NS yellow, EW green, and EW yellow phases. During each phase, the opposing
direction must remain red. The controller must start in the NS-green phase
when an active-high asynchronous reset is asserted, and it must recover to
the initial phase if an unused state encoding is encountered.

### 3. Objectives

1. Define four FSM states using Verilog parameters.
2. Implement a state register with asynchronous active-high reset.
3. Separate next-state and output combinational logic.
4. Verify reset, all state/output combinations, cyclic progression, legal lamp
   values, and green-light mutual exclusion.
5. Produce a VCD waveform and provide an automated synthesis flow.

### 4. Requirements and Tools

The RTL uses Verilog-2001 constructs and is compatible with Icarus Verilog.
Simulation requires Icarus Verilog (`iverilog`, `vvp`); waveform inspection
uses GTKWave; synthesis uses Yosys; and the included shell scripts and Makefile
require Bash and GNU Make. No physical FPGA is required for functional
simulation. For a hardware implementation, an FPGA board, pin constraints, and
device-specific timing analysis would also be needed.

On Ubuntu, the tools can be installed with `sudo apt update` followed by
`sudo apt install iverilog gtkwave yosys make`.

### 5. Design Specification

#### 5.1 Signal encoding

| Two-bit value | Lamp indication |
| --- | --- |
| `2'b00` | RED |
| `2'b01` | YELLOW |
| `2'b10` | GREEN |

#### 5.2 State assignment and transitions

| State encoding | NS | EW | Following state |
| --- | --- | --- | --- |
| `00` (STATE 0) | GREEN | RED | `01` (STATE 1) |
| `01` (STATE 1) | YELLOW | RED | `10` (STATE 2) |
| `10` (STATE 2) | RED | GREEN | `11` (STATE 3) |
| `11` (STATE 3) | RED | YELLOW | `00` (STATE 0) |

The state diagram is provided in [FSM_diagram.md](FSM_diagram.md). Each state
lasts one clock period in this basic controller. Real signal durations would
normally be determined by counters and system clock frequency.

### 6. RTL Architecture

The module `traffic_light_controller` has clock and reset inputs, and two
two-bit lamp outputs. Its state register is sensitive to `posedge clk` and
`posedge reset`, implementing asynchronous reset to STATE 0. If reset is not
asserted, the register captures `next_state` on a rising clock edge.

The next-state combinational block specifies all four legal transitions and
uses STATE 0 as the recovery destination in its default branch. The output
combinational block first assigns both directions RED, then overrides the
appropriate values for each legal state. This default-first structure avoids
latches and leaves both approaches red if the state is invalid.

### 7. Verification Method

The testbench generates a 10 ns clock, asserts reset at startup, and releases
it after 10 ns. It samples just after rising clock edges to avoid observing
nonblocking assignments before they settle. The simulation checks two complete
cycles and emits a VCD file containing the clock, reset, FSM state, and both
lamp outputs.

Eight test categories are reported: asynchronous reset, each of the four
state/output mappings, two-cycle state progression, no simultaneous green
indications, and legal output combinations. Any failed category causes the
testbench to terminate with a nonzero failure status.

### 8. Running the Project

From the project root:

```sh
make simulate
make waveform
make synthesize
make clean
```

`make simulate` compiles the source in Verilog-2001 mode, runs the testbench,
and writes `simulation/traffic_light_tb.vcd`. `make waveform` runs the
simulation if needed by its target dependency and opens the VCD with GTKWave.
`make synthesize` invokes Yosys and saves its generated netlist and log under
`synthesis/`. `make clean` removes generated binaries, waveforms, netlists, and
reports. The equivalent individual commands are in `scripts/`.

### 9. Results and Discussion

The expected simulation result is eight passing test categories and no
failures, with the sequence repeating twice. GTKWave can be used to correlate
the state changes and lamp outputs with the 10 ns clock. The design has no
duration counters: each phase is one clock cycle, which is sufficient for
verifying the state-machine behavior but not for controlling a real roadway.

Icarus Verilog 12.0 and GTKWave 3.3.108 were available in the Windows
development environment used to prepare this project. Yosys and WSL were not
available in that environment, so synthesis could not be run there. The
synthesis script is provided to generate genuine Yosys output when executed in
an environment with Yosys installed; no synthetic netlist or report is
included.

### 10. Limitations and Future Work

This model does not include timing intervals, vehicle sensors, pedestrian
crossings, emergency preemption, or fault monitoring. A practical extension
could add programmable phase timers, demand-based transitions, pedestrian
states, synchronized input handling, and FPGA-specific constraints. Hardware
validation should include timing analysis and a fail-safe review appropriate
to the deployment context.

### 11. Conclusion

The project provides a compact Verilog-2001 FSM that coordinates two opposing
traffic directions with mutually exclusive green phases. Its modular RTL,
self-checking testbench, VCD generation, and documented Yosys flow form a
complete academic example of digital design and verification. Simulation and
synthesis results should be generated by running the supplied scripts with the
corresponding tools installed.