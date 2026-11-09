#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
mkdir -p simulation

iverilog -g2001 -o simulation/traffic_light_tb.vvp \
    src/traffic_light_controller.v testbench/tb_traffic_light.v
vvp simulation/traffic_light_tb.vvp