.PHONY: all simulate synthesize waveform clean

all: simulate synthesize

simulate:
	bash scripts/simulate.sh

synthesize:
	bash scripts/synthesize.sh

waveform: simulate
	gtkwave simulation/traffic_light_tb.vcd

clean:
	bash scripts/clean.sh