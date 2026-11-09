# Design and Simulation of a Traffic Light Controller Using FSM in Verilog

## Abstract

This project implements a two-direction traffic light controller as a
four-state finite state machine (FSM). The North-South (NS) and East-West (EW)
approaches receive green and yellow indications in sequence while the opposing
direction remains red. A Verilog-2001 design, a self-checking testbench, an
Icarus Verilog simulation flow, a GTKWave waveform flow, and a Yosys synthesis
flow are provided.

## Introduction

Traffic controllers coordinate right-of-way to prevent conflicting vehicle
movements. An FSM is a natural model for this behavior: the current state
determines the signal outputs, and each active clock edge advances the
controller. This educational controller models two opposing direction groups;
it does not model sensors, pedestrian crossings, or real-world timing policy.

## Objectives

- Implement the specified four-state sequence using Verilog-2001.
- Provide an active-high asynchronous reset to the NS-green state.
- Verify outputs, state progression, legal signal values, and green-light
  mutual exclusion in a self-checking testbench.
- Generate a VCD waveform and a synthesizable netlist using the documented
  tools.

## Requirements

### Software

- Icarus Verilog (`iverilog` and `vvp`) for compilation and simulation.
- GTKWave for waveform inspection.
- Yosys for synthesis and statistics.
- GNU Make and Bash for the supplied Makefile and scripts.

The project targets Ubuntu/Linux. On Ubuntu, install the tools with:

```sh
sudo apt update
sudo apt install iverilog gtkwave yosys make
```

### Hardware

No FPGA board is required to run the simulation. The RTL can be adapted to a
target FPGA after selecting device-specific clocking, pin assignments, and
signal timing requirements.

## FSM Working Principle

The controller stores a two-bit state. Asynchronous assertion of `reset`
selects STATE 0. Otherwise, each rising edge of `clk` registers the next state.
Combinational next-state logic defines the repeating sequence
STATE 0 -> STATE 1 -> STATE 2 -> STATE 3 -> STATE 0. Combinational output logic
decodes the current state into NS and EW lamp values. A default branch returns
the next-state logic to STATE 0 and assigns safe red outputs for an invalid
state encoding.

## Traffic Light Encoding

| Value | Meaning |
| --- | --- |
| `2'b00` | RED |
| `2'b01` | YELLOW |
| `2'b10` | GREEN |

## State Transition Table

| Current state | NS light | EW light | Next state |
| --- | --- | --- | --- |
| STATE 0 (`2'b00`) | GREEN | RED | STATE 1 (`2'b01`) |
| STATE 1 (`2'b01`) | YELLOW | RED | STATE 2 (`2'b10`) |
| STATE 2 (`2'b10`) | RED | GREEN | STATE 3 (`2'b11`) |
| STATE 3 (`2'b11`) | RED | YELLOW | STATE 0 (`2'b00`) |

## Verilog Implementation

The synthesizable module is in `src/traffic_light_controller.v`. It uses
Verilog parameter declarations for the four state encodings, a positive-edge
clocked state register with `posedge reset`, and separate combinational blocks
for next-state and output decoding. The lamp outputs are Moore-style outputs:
they depend only on the current FSM state.

The testbench in `testbench/tb_traffic_light.v` checks reset, every state/output
pair, the transition sequence over two complete cycles, mutual exclusion of
green indications, and legal output encodings. It reports eight PASS/FAIL test
categories and exits with a nonzero status on failure.

## Simulation

From the project root, run:

```sh
make simulate
```

This compiles with `iverilog -g2001`, runs the testbench with `vvp`, prints the
monitor and self-check summary, and writes
`simulation/traffic_light_tb.vcd`. The expected summary is 8 passed and 0
failed.

Alternatively, run `bash scripts/simulate.sh`.

## Synthesis

Run:

```sh
make synthesize
```

The Yosys script reads the Verilog source, selects the top module, runs process
lowering and FSM optimization, prints statistics, and writes
`synthesis/traffic_light_netlist.v`. The complete tool output is saved to
`synthesis/synthesis_report.txt`. Synthesis requires Yosys to be installed.

## Waveform Visualization

After simulation, open the VCD directly in GTKWave:

```sh
make waveform
```

Or run `gtkwave simulation/traffic_light_tb.vcd`. The VCD includes `clk`,
`reset`, the hierarchical FSM state (also aliased as `state`), `NS_light`, and
`EW_light`. It shows two full state cycles.

## Expected Results

The reset state is NS GREEN / EW RED. After reset is released, the sequence is
NS YELLOW / EW RED, NS RED / EW GREEN, NS RED / EW YELLOW, then back to NS
GREEN / EW RED. The self-checking testbench should report all eight categories
passing. Icarus Verilog and GTKWave are available in the original Windows
workspace environment. Yosys was not installed there; therefore, no synthesis
netlist or report is claimed until `make synthesize` is run where Yosys is
installed.

## Conclusion

The project demonstrates a clocked, synthesizable FSM for coordinated
two-direction traffic indications, with asynchronous reset, explicit
state/output decoding, automated behavioral checks, and tool flows for
simulation, waveform inspection, and synthesis.

## Future Enhancements

- Add configurable green and yellow durations using a clock divider and
  counters.
- Add vehicle-demand sensors and safe transition policies.
- Add pedestrian-request inputs and crossing states.
- Add FPGA constraints, board-level I/O, and hardware validation.
- Add parameterized timing and reset-release synchronization for a specific
  deployment target.