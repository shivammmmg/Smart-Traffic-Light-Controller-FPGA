# 🚦 Smart Traffic Light Controller (FPGA – Verilog)

A **Smart Traffic Light Controller** implemented on the **Intel DE10-Lite FPGA** using **Verilog HDL** and **Intel Quartus Prime Lite**.  
The system manages vehicular and pedestrian traffic using a **Moore-type Finite State Machine**, real-time hardware timers, and mode-based control logic.

The project was fully demonstrated on hardware and received **15/15** in EECS 3201 – Digital Logic Design.

---

🎯 **Objective**  
To design and implement a reliable **FPGA-based traffic control system** that integrates **combinational and sequential logic**, safely handles pedestrian requests, and adapts to different traffic conditions — demonstrating real-world digital system design.

---

## 🧩 Features
- 🚥 Automatic **Green → Yellow → Red** traffic light sequencing  
- 🚶 Pedestrian request button with **debouncing and safe buffering**  
- ⏱️ Hardware-accurate timing using synchronous counters  
- 🔢 Walk countdown displayed on **7-segment HEX display**  
- 🌙 **Night Mode** with continuous blinking yellow light  
- 🔀 Low-traffic / High-traffic modes using hardware switches  
- 🧱 Modular Verilog design (FSM, timers, debouncer, blink generator)

---

## ⚙️ Hardware Components
| Component | Description |
|------------|-------------|
| **Intel DE10-Lite FPGA** | Main hardware platform |
| **On-board LEDs** | Vehicle & pedestrian signals |
| **Push Buttons (KEY)** | Reset and pedestrian request |
| **Slide Switches (SW)** | Night mode & traffic mode selection |
| **HEX Display** | Pedestrian walk countdown |
| **50 MHz On-board Clock** | System clock source |

---

## 💻 Design & Software Overview
**Languages & Tools**
- **Verilog HDL** – Digital design and control logic  
- **Intel Quartus Prime Lite** – FPGA synthesis & programming  

**Key Modules**
| Module | Description |
|-------|--------------|
| `traffic_fsm.v` | Moore FSM controlling traffic phases |
| `phase_timer.v` | Parameterized hardware timers |
| `walk_countdown_timer.v` | Pedestrian countdown logic |
| `debounce_button.v` | Push-button debouncing |
| `blink_generator.v` | Night-mode blinking logic |
| `sevenseg_decoder.v` | HEX display driver |
| `traffic_top.v` | Top-level system integration |

---

## 🧠 System Logic (FSM Overview)
1. System starts in **Green** state after reset.  
2. Traffic lights cycle **Green → Yellow → Red** using hardware timers.  
3. Pedestrian button press is **latched** and serviced safely during the Red phase.  
4. During **Walk**:
   - Pedestrian LED turns ON  
   - Countdown appears on HEX display  
5. After countdown completes, system returns to **Green**.  
6. **Night Mode** overrides all states with blinking yellow light.  
7. Traffic duration adjusts automatically in **Low / High traffic modes**.

---

## 🎥 Hardware Demonstration
YouTube Demo:  
https://www.youtube.com/watch?v=zH9PwKlnD2A

---

## 🎓 Learning Outcomes
- ✔ Strong understanding of **Moore FSM design**  
- ✔ Practical experience with **FPGA timing & synchronization**  
- ✔ Modular Verilog system architecture  
- ✔ Hardware debugging and live demonstration  
- ✔ Real-world digital logic application

---

## 🧑‍💻 Author
**Shivam Gupta**  
🎓 B.Eng. Software Engineering @ York University  
🔗 [LinkedIn](https://linkedin.com/in/shivammmmg) • [Portfolio](https://shivammmmg.com)

---

## 📚 References
- EECS 3201 – Digital Logic Design, York University  
- Intel DE10-Lite User Manual  
- Intel Quartus Prime Lite Documentation  
