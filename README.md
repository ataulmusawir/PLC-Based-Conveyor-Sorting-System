# PLC-Based Conveyor Sorting System 🏭⚙️

![PLC](https://img.shields.io/badge/Architecture-PLC_Control-blue)
![Language](https://img.shields.io/badge/Language-IEC__61131__3-green)
![Status](https://img.shields.io/badge/Status-Validated-orange)

**Developed by:** Ata Ul Musawir  
**Program:** BS Electrical Engineering, GIK Institute (GIKI)

## 📌 Project Overview
This repository contains the industrial control logic for an automated conveyor sorting system. Unlike high-level operating systems, this architecture is designed for a Programmable Logic Controller (PLC) utilizing a highly deterministic cyclic scan (1ms-100ms) to guarantee real-time responsiveness and fail-safe operation on a physical factory floor[cite: 4].

## 🏗️ Control Architecture & Logic

### 1. Finite State Machine (FSM) Topology
To completely eliminate physical output race conditions, all logic is routed through mutually exclusive machine states[cite: 4]:
*   **Idle:** Motor off, system awaiting start command[cite: 4].
*   **Running:** Main motor energized (`%Q1.0 = TRUE`); actively monitoring optic sensors[cite: 4].
*   **Sorting:** Triggered by box detection; evaluates height and executes pneumatic transit timing[cite: 4].
*   **Fault:** Outputs forced into a fail-safe state with the warning beacon active[cite: 4].

### 2. Edge Detection & Counting
A spatial-temporal mismatch occurs because a PLC scans a sensor dozens of times while a single box physically passes it[cite: 4]. To prevent 40 false counts for a single item, this system utilizes **Positive Edge Detection (R_TRIG)**[cite: 4]. The logic `Input_current AND NOT(Input_previous)` guarantees exactly one digital pulse per physical item[cite: 4]. 
*   **CTU (Up-Counter):** Utilized to accumulate these discrete edge-trigger events for batching[cite: 4].

### 3. Transit Timing (Physics to Logic)
Pneumatic diverters must strike a moving object precisely. Transit time ($t$) is mapped via physics:
*   Distance ($d$) = $0.75\text{m}$[cite: 4]
*   Velocity ($v$) = $0.5\text{m/s}$[cite: 4]
*   Time ($t$) = $1.5\text{ seconds}$[cite: 4]
An **On-Delay Timer (TON)** is programmed for `T#1500MS` to measure this elapsed physical duration, firing the solenoid at the exact moment of arrival[cite: 4].

## 🛑 Strict Hardware Safety Mandates
This architecture enforces strict adherence to industrial safety standards (NFPA 79 / IEC 60204-1)[cite: 4]. Software-only safety is prohibited[cite: 4]. 
*   **Hardware Cutoff:** The Emergency Stop (E-Stop) utilizes dual-contact blocks[cite: 4]. The primary NC contact is wired directly to a Safety Relay to physically cut motor power, bypassing the PLC entirely (Stop Category 0)[cite: 4].
*   **Software Monitoring:** The secondary contact is wired to a discrete PLC input (`%I0.2`) to monitor the hardware status[cite: 4]. This cross-zone coordination prevents product pile-ups and requires a manual HMI reset before the system can restart[cite: 4].

## 🚀 Virtual Commissioning
This codebase is designed to be deployed into 3D physics emulators (such as Siemens S7-PLCSIM)[cite: 4]. This virtual handshake allows engineers to validate FSM transitions, edge-detection fidelity, and safety interlocks in a 100% risk-free environment before physical deployment[cite: 4].
