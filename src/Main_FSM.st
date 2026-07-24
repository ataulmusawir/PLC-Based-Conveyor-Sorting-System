// ==============================================================================
// Conveyor Sorting System: Finite State Machine (FSM)
// Language: Structured Text (IEC 61131-3)
// ==============================================================================

PROGRAM Main_FSM
VAR
    // State Enumerations
    STATE_IDLE : INT := 1;
    STATE_RUNNING : INT := 2;
    STATE_SORTING : INT := 3;
    STATE_FAULT : INT := 4;
    
    Current_State : INT := STATE_IDLE;
    
    // Internal Flags
    b_EStop_Fault : BOOL := FALSE;
    b_Batch_Complete : BOOL := FALSE;
END_VAR

// 1. Safety & Fault Monitoring (Overrides all other logic)
IF NOT(i_EStop_Mon) THEN
    b_EStop_Fault := TRUE;
    Current_State := STATE_FAULT;
END_IF;

// 2. State Machine Transitions
CASE Current_State OF
    
    STATE_IDLE:
        // Transition: Idle -> Running
        IF i_Start_PB AND NOT(i_Stop_PB) AND i_EStop_Mon AND NOT(b_EStop_Fault) THEN
            Current_State := STATE_RUNNING;
        END_IF;
        
    STATE_RUNNING:
        // Transition: Running -> Idle (Normal Stop)
        IF i_Stop_PB THEN
            Current_State := STATE_IDLE;
        END_IF;
        
        // Transition: Running -> Sorting
        IF i_Prox_Sensor AND NOT(b_EStop_Fault) AND NOT(b_Batch_Complete) THEN
            Current_State := STATE_SORTING;
        END_IF;
        
    STATE_SORTING:
        // Transition logic back to running handled in Sorting_Logic block
        // (Ensures race conditions do not occur)
        
    STATE_FAULT:
        // Outputs forced to fail-safe; requires manual hardware reset
        q_Conv_Motor := FALSE;
        q_Reject_Push := FALSE;
        q_Warn_Light := TRUE;
        
END_CASE;

// 3. Physical Output Mapping
q_Conv_Motor := (Current_State = STATE_RUNNING) OR (Current_State = STATE_SORTING);
q_Warn_Light := (Current_State = STATE_FAULT);

END_PROGRAM
