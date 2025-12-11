# **Design and Implementation of an AXI4-Lite Slave Peripheral**

This repository documents the design, verification, and hardware implementation of a synthesized **AXI4-Lite Slave peripheral** targeting **Xilinx Artix-7 FPGAs**. The module functions as a **memory-mapped I/O (MMIO) controller**, providing an interface between a host processor's AXI bus and external board peripherals such as **LEDs** and **DIP switches**.

The design adheres strictly to the **AMBA AXI4-Lite protocol** to ensure reliable system integration.

---

## **Figure 1: RTL Simulation Waveform**
<img width="1819" height="747" alt="wave-1" src="https://github.com/user-attachments/assets/53c27f4d-204c-49c0-87bc-deb6956f960c" />
<img width="1839" height="445" alt="wave-2" src="https://github.com/user-attachments/assets/321dc98d-25ad-4d50-b5be-93d1b5896345" />

---

# **1. Architectural Specification**

The peripheral is implemented as a slave node on the AXI4-Lite interconnect with:

- **32-bit data width**
- **4-bit address width**

### **Interface Standard**
- AMBA AXI4-Lite (Memory-Mapped)

### **Bus Arbitration**
Implements fully compliant READY/VALID handshake logic for:
- Write Address (AW)
- Write Data (W)
- Write Response (B)
- Read Address (AR)
- Read Data (R)

### **I/O Configuration**
- **Output:** 4-bit parallel drive for LEDs  
- **Input:** 4-bit parallel capture from DIP switches  

### **Verification**
- Self-checking SystemVerilog testbench  
- Covers all AXI4-Lite read/write transaction types  

---

# **2. Register Map Specification**

The peripheral exposes a **16-byte address space** consisting of **four 32-bit registers**.  
The base address is configurable (e.g., `0x44A0_0000`).

| Offset | Register Name | Access | Bit Definition | Description |
|--------|----------------|--------|----------------|-------------|
| `0x00` | `REG0_LED`     | R/W    | `[3:0]`        | Output control for LEDs |
| `0x04` | `REG1_SW`      | R      | `[3:0]`        | Input status of DIP switches |
| `0x08` | `REG2_RES`     | R/W    | `[31:0]`       | General-purpose storage |
| `0x0C` | `REG3_RES`     | R/W    | `[31:0]`       | General-purpose storage |

---

# **3. Synthesis and Implementation Results**

The design was synthesized in **Xilinx Vivado** for the **xc7a100t-csg324-1 (Artix-7)** device, operating at **100 MHz** within a MicroBlaze processing subsystem.

---

## **3.1 Resource Utilization**

| Resource Type | Count | Utilization (%) |
|---------------|--------|-----------------|
| Slice LUTs    | 9      | < 0.01% |
| Slice Registers | 8    | < 0.01% |
| F7 Muxes      | 0 | 0.00% |
| Block RAM     | 0 | 0.00% |

---

## **3.2 Timing Analysis**

| Metric | Measured Value | Status |
|--------|----------------|--------|
| Worst Negative Slack (WNS) | 0.714 ns | Met |
| Worst Hold Slack (WHS) | 0.065 ns | Met |
| Failing Endpoints | 0 | Passed |

---

## **3.3 Power Analysis**

| Category | Power (W) | Share |
|----------|-----------|--------|
| Total On-Chip Power | 0.208 W | 100% |
| Device Static | 0.084 W | 41% |
| Dynamic | 0.124 W | 59% |
| IP Logic Contribution | < 0.005 W | Negligible |

---

# **4. Integration Methodology**

The AXI-Lite core is packaged using **IP-XACT** for direct import into Vivado IP Integrator.

### **Steps to Integrate**
1. **Clone** this repository.
2. In Vivado:  
   - Go to **Settings → IP → Repository**  
   - Add the path to the `packaged_ip/` directory  
3. Instantiate the core (**axi_4_lite**) from **IP Catalog**  
4. **Pin Planning**  
   - Map LED and SW ports in the `.xdc` constraints  
5. **Address Assignment**  
   - Set the base address in the Address Editor  

---

# **5. Repository Structure**

```
.
├── docs/           # Verification artifacts, waveforms, reports
├── hdl/            # Synthesizable Verilog source (axi_4_lite.v)
├── tb/             # SystemVerilog testbench (axi_4_lite_tb.v)
├── packaged_ip/    # IP-XACT packaged peripheral for Vivado
└── README.md
```

---

