#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
rm -f simulation/traffic_light_tb.vvp simulation/traffic_light_tb.vcd
rm -f synthesis/traffic_light_netlist.v synthesis/synthesis_report.txt