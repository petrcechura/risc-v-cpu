

module sys_bus_master(
  // TO CORE
  // .. to Flash Memory
  output wire flash_we,
  output wire[15:0] flash_data,
  input wire flash_ack,
  // .. to Control Unit
	TODO
  
  

  // to perihperals
  sys_bus_if sys_if

  // I2C communication
  i2c_bus_if i2c_if
);

endmodule: sys_bus_master
