# Weather Station with Elixir and Nerves

Exploring Nerves and Elixir together in a rasped-up weather station.

Following along form the Pragprog book [Build a weather station with Elixir and Nerves](https://pragprog.com/titles/passweather/build-a-weather-station-with-elixir-and-nerves/)

Uk based, components sourced from [CoolComponents](https://coolcomponents.co.uk/) & [The PiHut](https://thepihut.com/). Don't forget a 4Gb MicroSD, I raided an ageing stash of Raspberry Pi's from the old days.


## Some interesting findings

The SGP30 from the book wasn't available locally, the SGP40 was suggested as alternative.
However it's not detected in the early phases of the book, so:

```elixir
iex(1)> Circuits.I2C.detect_devices()
Devices on I2C bus "i2c-1":
 * 72  (0x48)
 * 119  (0x77)

2 devices detected on 1 I2C buses
```

As the book progresses it introduces some HEX packages for wrapping the calls to the sensor. Oddly the SGP40 package works. There are notes that the I2C does not always detect the sensor. Thus this works:

```elixir
iex(2)> {:ok, sgp} = SGP40.start_link(bus_name: "i2c-1")
{:ok, #PID<0.1281.0>}
iex(3)> SGP40.measure(sgp)
{:ok, %SGP40.Measurement{timestamp_ms: 1857933, voc_index: 101}}
```

Need to clean my air! 5k is the ax, with low to high being great to dire air quality.

Playing with the SGP40 & BMP280 wrapper:

```elixir
iex(4)> BMP280.start_link([i2c_address: 0x77, name: BMP280])
{:ok, #PID<0.1285.0>}
iex(5)> {:ok, measurement} = BMP280.read(BMP280)
{:ok,
 %BMP280.Measurement{
   altitude_m: -40.517261111829896,
   dew_point_c: 14.671734203334344,
   gas_resistance_ohms: 29924.627510953054,
   humidity_rh: 58.80326617457506,
   pressure_pa: 100481.23762953299,
   temperature_c: 23.17593733009635,
   timestamp_ms: 1930053
 }}
 iex(6)> SGP40.update_rht(sgp, measurement.humidity_rh, measurement.temperature_c)
:ok
iex(7)> SGP40.measure(sgp)
{:ok, %SGP40.Measurement{timestamp_ms: 2045008, voc_index: 99}}
 ```

Not a huge improvement, but proof enough the sensors work.


### Chapter3 Sensor.measure

As I wasn't using the SGP30, some additional notes on the SGP40 which is a different interface. It's similar to the BMP280.

```elixir
iex(1)> {:ok, sgp} = SGP40.start_link(bus_name: "i2c-1", name: SGP40)
{:ok, #PID<0.1281.0>}
iex(2)> voc = Sensor.new(SGP40)
%SensorHub.Sensor{
  convert: #Function<2.9234919/1 in SensorHub.Sensor.convert_fn/1>,
  fields: [:voc_index],
  name: SGP40,
  read: #Function<5.9234919/0 in SensorHub.Sensor.read_fn/1>
}
iex(3)> Sensor.measure(voc)
%{voc_index: 108}
```
