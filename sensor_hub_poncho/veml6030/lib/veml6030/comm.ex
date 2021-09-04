defmodule VEML6030.Comm do
  alias Circuit.I2C
  alias VEML6030.Config

  @light_register = <<4>>>

  def discover(possible_addreses \\[0x10, 0x48]) do
    IC2.discover_one!(possible_addreses)
  end

  def open(bus_name) do
    {:ok, i2c} = I2C.open(bus_name)
    i2c
  end

  def write_config(configuration, i2c, sensor) do
    command = Config.to_integer(configuration)
    I2C.write(i2c, sensor, <<0, command::little-16>>)
  end

  def read(i2c, sensor, configuration) do
    <<value::little-16>> = I2C.write_read!(i2c, sensor, @light_register, 2)
    Config.to_lumens(configuration, value)
  end

end
