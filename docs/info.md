# Stone-Paper-Scissors FSM

This project implements a digital **Stone-Paper-Scissors game** using a **Finite State Machine (FSM)** in Verilog.  
It takes two players' moves as inputs and determines the winner based on the classic game rules.

---

## How it works

The design uses four main states to control the game:

| **State Name** | **Binary Code** | **Description** |
|----------------|-----------------|-----------------|
| `S_IDLE`       | `000`           | Waiting for the `start` signal. |
| `S_EVALUATE`   | `001`           | Evaluates the moves of both players. |
| `S_RESULT`     | `010`           | Displays the result (Winner, Tie, or Invalid). |
| `S_RESET`      | `011`           | Resets the game back to the idle state. |

The module continuously monitors player inputs.  
- When **`start` = 1**, the FSM moves from `S_IDLE` → `S_EVALUATE` → `S_RESULT`.  
- The output `winner` shows the game result.  
- The FSM stays in `S_RESULT` until **`start` = 0**, which returns it to `S_IDLE`.

---

## Inputs

| **Signal**   | **Width** | **Description** |
|--------------|-----------|-----------------|
| `clk`        | 1-bit     | Clock signal for synchronous state transitions. |
| `reset`      | 1-bit     | Asynchronous reset to return to `S_IDLE`. |
| `p1_move`    | 2-bit     | Player 1 move: `00=Stone`, `01=Paper`, `10=Scissors`, `11=Invalid`. |
| `p2_move`    | 2-bit     | Player 2 move: `00=Stone`, `01=Paper`, `10=Scissors`, `11=Invalid`. |
| `start`      | 1-bit     | Triggers evaluation of moves. |
| `mode`       | 1-bit     | Debug mode toggle (optional). |

---

## Outputs

| **Signal**  | **Width** | **Description** |
|-------------|-----------|-----------------|
| `winner`    | 2-bit     | `00=Tie`, `01=Player 1 wins`, `10=Player 2 wins`, `11=Invalid move`. |
| `state`     | 3-bit     | Current FSM state for debugging and visualization. |
| `debug`     | 3-bit     | Shows recent moves and internal signals for debug. |

---

## Game Logic

1. If **either player enters `11`**, the output is **Invalid (11)**.  
2. If **both players select the same move**, the result is a **Tie (00)**.  
3. Standard rules apply:  
   - **Stone (`00`) beats Scissors (`10`)**  
   - **Paper (`01`) beats Stone (`00`)**  
   - **Scissors (`10`) beats Paper (`01`)**

---

## How to test

### Setup
1. Load the Verilog design into a simulator such as:
   - **Icarus Verilog**, **ModelSim**, or **Vivado**.
2. Connect appropriate clock and reset signals.

---

### Steps
1. Apply `reset = 1` for at least one clock cycle to initialize the FSM.  
2. Set `reset = 0`.  
3. Provide valid moves to `p1_move` and `p2_move`.  
4. Set `start = 1` to evaluate moves.  
5. Observe `winner` and `debug` outputs.  
6. Set `start = 0` to return to `S_IDLE`.

---

### Example Test Cases

| **P1 Move** | **P2 Move** | **Expected Winner** |
|-------------|-------------|----------------------|
| `00` (Stone) | `10` (Scissors) | `01` (Player 1 wins) |
| `01` (Paper) | `00` (Stone) | `01` (Player 1 wins) |
| `10` (Scissors) | `01` (Paper) | `01` (Player 1 wins) |
| `00` (Stone) | `00` (Stone) | `00` (Tie) |
| `11` (Invalid) | `01` (Paper) | `11` (Invalid) |

---

## External hardware

This project does **not require external hardware**, but it can be demonstrated with the following components:

| **Hardware** | **Usage** |
|--------------|-----------|
| LEDs         | Indicate FSM state or winner. |
| Switches     | Player move selection. |
| Push Button  | Used as `start` signal. |
| Seven-Segment Display *(optional)* | Display winner or FSM state numerically. |


