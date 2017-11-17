# ELEC374 MiniSRC 3-Bus CPU

The MiniSRC is an architecture and instruction set spec for the ELEC374 course project at Queen's University. The complete system includes RAM and I/O ports for data transfer.

# Implementation
* This version of the MiniSRC uses a 3 bus architecture for performance enhancements
* An Altera Cyclone V FPGA on a DE1 board was used to implement the system.
* An assembler for the MiniSRC was written in C#, it is available here: [MiniSRC Assembler](https://github.com/mitchellwaite/MiniSRC-Assembler)
* [Download the MiniSRC ISA spec here](https://github.com/mitchellwaite/MiniSRC-Assembler/raw/master/CPU_Spec.pdf)

# Testing Results
* Initial implementation on an Altera Cyclone V (without optimization) yeilded a stable frequency of around 10MHz.
* Further optimization and compiler tweaks allowed for a stable frequency of ~30MHz

# Video
[240fps Slow motion demonstration video](https://www.youtube.com/watch?v=wTNoSJAovwI)
