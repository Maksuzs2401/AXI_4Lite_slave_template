Design and Implementation of an AXI4-Lite Slave Peripheral

Abstract

This repository documents the design, verification, and hardware implementation of a synthesized AXI4-Lite Slave peripheral targeting Xilinx Artix-7 Field-Programmable Gate Arrays (FPGAs). The module functions as a memory-mapped input/output (MMIO) controller, bridging a host processor's AXI interface with external board peripherals, specifically Light Emitting Diodes (LEDs) and Dual Inline Package (DIP) switches. The design ensures strict adherence to the AMBA AXI4-Lite protocol specifications for reliable system integration.

Figure 1: RTL Simulation Waveform demonstrating valid Read/Write channel handshakes.

1. Architectural Specification

The peripheral is designed as a slave node on the AXI4-Lite interconnect, supporting a 32-bit data width and a 4-bit address width.

Interface Standard: AMBA AXI4-Lite (Memory Mapped).

Bus Arbitration: Implements compliant READY/VALID handshake logic for Write Address, Write Data, Write Response, Read Address, and Read Data channels.

I/O Configuration:

Output Path: 4-bit parallel drive for external LEDs.

Input Path: 4-bit parallel capture for external DIP switches.

Verification: Functional correctness was validated using a self-checking SystemVerilog testbench covering all transaction types.

2. Register Map Specification

The peripheral exposes a 16-byte address space containing four 32-bit registers. The base address is configurable via the system address map (e.g., 0x44A00000).

Offset

Register Name

Access

Bit Definition

Description

0x00

REG0_LED

R/W

[3:0]

Output control for external LEDs.

0x04

REG1_SW

R

[3:0]

Input status of external Switches.

0x08

REG2_RES

R/W

[31:0]

Reserved for general-purpose storage.

0x0C

REG3_RES

R/W

[31:0]

Reserved for general-purpose storage.

3. Synthesis and Implementation Results

The design was synthesized and implemented using Xilinx Vivado targeting the xc7a100t-csg324-1 device (Artix-7) within a MicroBlaze soft-processor system context running at 100 MHz.

3.1 Resource Utilization

The table below presents the post-implementation resource utilization on the target Artix-7 device.

Resource Type

Count

Utilization (%)

Slice LUTs

9

< 0.01%

Slice Registers

8

< 0.01%

F7 Muxes

0

0.00%

Block RAM

0

0.00%

3.2 Timing Analysis

Static timing analysis confirms that the design meets all setup and hold time requirements at a system clock frequency of 100 MHz.

Metric

Measured Value

Status

Worst Negative Slack (WNS)

0.714 ns

Met

Worst Hold Slack (WHS)

0.065 ns

Met

Failing Endpoints

0

Passed

3.3 Power Analysis

Post-implementation power estimation indicates that the dynamic power consumption of the IP logic is minimal relative to the static device leakage and clock management overhead.

Category

Power (Watts)

Share

Total On-Chip Power

0.208 W

100%

Device Static

0.084 W

41%

Dynamic

0.124 W

59%

IP Logic Contribution

< 0.005 W

Negligible

4. Integration Methodology

The core is packaged in IP-XACT format to facilitate integration within the Vivado IP Integrator environment.

Repository Setup: Clone the repository to the local development environment.

IP Catalog Update: In Vivado, navigate to Settings > IP > Repository and add the packaged_ip/ directory path.

Instantiation: The peripheral is accessible via the IP Catalog under the designation axi_4_lite.

Pin Planning: Map the LED and SW ports to the appropriate physical package pins via the constraints file (.xdc).

Address Assignment: Configure the base address within the Address Editor to ensure proper memory mapping.

5. Repository Organization

The repository is structured as follows:

docs/: Contains verification artifacts, including simulation waveforms and detailed utilization reports.

hdl/: Contains the synthesizable Verilog source code (axi_4_lite.v).

tb/: Contains the SystemVerilog testbench (axi_4_lite_tb.v) used for verification.

packaged_ip/: Contains the generated IP-XACT files required for Vivado integration.