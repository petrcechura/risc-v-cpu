# RISC-V MICROPROCESSOR
This repository aims to develop fully usable RISC-V architecture based procesor, using Verilog HDL.

## WORKFLOW
    [x] Define architecture
    [ ] Define microarchitecture
    [ ] Define system bus
        [ ] Implement System Bus Master
        [ ] Implmenet Sysmte Bus Slave
    [ ] Implement microarchitecture
    [ ] Implement PORT A/B drivers
    [x] Implement RAM
    [ ] Implement I2C slave
    [ ] Assemble whole design

## DESIGN ARCHITECTURE
The architecture of RISC-V CPU aims to be simple, yet extendable. Architecture is **Harward-based**, hence
using separate memory for program and data. The program memory is placed directly inside CPU, while RAM (data)
memory is managed as one the peripherals. 

Communication between peripherals is managed by **system bus**, which is **master-slave** based. CPU is the master 
and each of the peripherals has uniq ID that CPU can use to send/receive data to/from.

### SYSTEM BUS 
**definition of system bus is under consideration**
Required aspects are:
    * parallel (ideally allowing to sample 16bit in one clock)
    * supporting addressing (so every peripheral can be addressed)
    * master-slave topology (CPU is the master, peripherals slaves)
Candidates are:
    * SPI16
    * PCI

### PERIPHERALS
Inside microprocessor, there are many peripherals, separating design into multiple subsystems that communicate via
system bus.
Peripherals:
    * Core: The RISC-V core is bigger design unit, serving as hearth of the microprocessor. The core shall be able to 
            perform every RISC-V instruction from RV32I set. Core communicates with System Bus master, to access 
            other peripherals like RAM or PORTs. 
            Further microarchitecture is under consideration but following subcomponents are expected:
                - ALU: Arithmetical logic unit
                - FLASH memory: memory that contains program to be executed
                - Control Unit: State machine, decodes an instruction and drives corr. signals to execute it 
                - Register file: Register pack for RISC-V processor
    * (System Bus Master): Directly communicates with Core and allows it to access other peripherals. Can be "backdoor"
            accessed by I2C communication from certain pins, making CPU a slave for a while, allowing it to be re-programmed.
    * System Bus Slave: Every perihperals has its System Bus Slave to communicate with Core.
    * I2C Slave: Directly communicates with System Bus Master and has the ability to "overwrite" its behavior, to temporaly
            set CPU into different mode (programming, setting, stop...). Does not have SB slave.
    * PORT A/B: Allows Core to read/write I/O from outside of chip.

### MICROARCHITECTURE 
TODO

## I/O 
Inputs and outputs of procesor can be divided into several categories by their purpose and implementation
in architecture.
Categories are:
    * **System Bus Backdoor Interface**: microprocessor has certain pins that allows him to be controlled as 
        somewhat slave via separated I2C bus. This communication is one-side only, microprocessor does not 
        answer, just listens and does as is said to do.
        Possible commands:
            - STOP: This command forces CPU to stop its execution, while keeping its state as is
            - START: Starts stopped CPU again.
            - FLASH: Immediately stop the cpu and starts to write following bytes into flash memory, thus
                     re-programs a CPU
            - SETUP: Stops a CPU, following bytes are used to set up system registers (for CPU and peripherals)
            - RESET: Clears all registers inside CPU, while keeping FLASH memory
            - *TODO*
    * **Port A I/O**: Simple 8bit interface for I/O in a A group, managed by one, separate module (PORT A)
    * **Port B I/O**: Simple 8bit interface for I/O in a A group, managed by one, separate module (PORT B)
    * **Clock and reset**: Reset is asynchronous, logic-one active

