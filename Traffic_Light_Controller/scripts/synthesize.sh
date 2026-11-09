#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v yosys >/dev/null 2>&1; then
    printf 'Error: Yosys is not installed. Install it with: sudo apt install yosys\n' >&2
    exit 127
fi

mkdir -p synthesis

yosys -p 'read_verilog src/traffic_light_controller.v; hierarchy -top traffic_light_controller; proc; opt; fsm; opt; stat; write_verilog synthesis/traffic_light_netlist.v' \
    2>&1 | tee synthesis/synthesis_report.txt