// ==============================================================================
// Sorting Mechanics: Edge Detection & Pneumatic Transit Timing
// Language: Structured Text (IEC 61131-3)
// ==============================================================================

PROGRAM Sorting_Logic
VAR
    // Edge Detection Variables
    Prox_Previous_State : BOOL := FALSE;
    Prox_R_TRIG : BOOL := FALSE; // Rising Edge Pulse
    
    // Counters and Timers
    Box_Counter : CTU; // Up-Counter for Batching
    Transit_Timer : TON; // On-Delay Timer for Pneumatics
END_VAR

// 1. Positive Edge Detection (R_TRIG)
// Prevents spatial-temporal mismatch (40 false counts for 1 box)
Prox_R_TRIG := i_Prox_Sensor AND NOT(Prox_Previous_State);
Prox_Previous_State := i_Prox_Sensor;

// 2. Batch Counting
// Accumulates exactly one discrete event occurrence per physical item
Box_Counter(CU := Prox_R_TRIG, PV := 50, RESET := (Current_State = STATE_IDLE));
IF Box_Counter.Q THEN
    b_Batch_Complete := TRUE;
END_IF;

// 3. Transit Timing Physics Calculation
// Distance (d) = 0.75m | Velocity (v) = 0.5m/s | Time (t) = 1.5s
// Goal: Measures elapsed physical duration to actuate diverter accurately
Transit_Timer(
    IN := (Current_State = STATE_SORTING) AND i_Tall_Sensor,
    PT := T#1500MS // 1.5 Second precise delay
);

// Actuate Solenoid Valve
IF Transit_Timer.Q THEN
    q_Reject_Push := TRUE;
    // Reset state after sorting action
    Current_State := STATE_RUNNING; 
ELSE
    q_Reject_Push := FALSE;
END_IF;

END_PROGRAM
