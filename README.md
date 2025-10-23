# SPI-Protocol
This Verilog code implements a 16-bit SPI master transmitter using a finite state machine (FSM) that shifts out data serially (MSB first) with an active-low chip select and clock control.

1.16-bit Data Transmission: The module sends a 16-bit parallel input (datain) serially bit-by-bit (MSB first) over the SPI bus.

2.Finite State Machine (FSM): Uses three states—IDLE, SHIFT, and CLOCK—to control data transfer timing and sequencing.

3.Active-Low Chip Select (spi_cs_1): The chip select signal goes low during data transmission, enabling the slave device.

4.SPI Clock Generation (spi_sclk): The clock toggles at each state transition to synchronize data shifting on the MOSI line.
