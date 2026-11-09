# FSM State Diagram

```mermaid
stateDiagram-v2
    direction TB
    [*] --> STATE0: asynchronous reset
    STATE0: NS GREEN, EW RED
    STATE1: NS YELLOW, EW RED
    STATE2: NS RED, EW GREEN
    STATE3: NS RED, EW YELLOW
    STATE0 --> STATE1
    STATE1 --> STATE2
    STATE2 --> STATE3
    STATE3 --> STATE0
```

The reset transition is asynchronous and selects STATE 0 independently of the
clock. Once reset is released, each rising clock edge advances the controller
to the next state in the repeating sequence.