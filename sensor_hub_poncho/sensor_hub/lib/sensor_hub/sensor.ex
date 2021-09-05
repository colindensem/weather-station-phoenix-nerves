defmodule SensorHub.Sensor do
  defstruct [:name, :fields, :read, :convert]

  def new(name, server) do
    %__MODULE__{
      read: read_fn(name),
      convert: convert_fn(name),
      fields: fields(name),
      name: name
    }
  end

  def fields(SGP40), do: [:voc_index]
  def fields(BMP280), do: [:altitude_m, :pressure_pa, :temperature_c, :humidity_rh]
  def fields(VEML6030), do: [:light_in_lumens]

  def read_fn(SGP40),
    do: fn ->
      SGP40.measure(SGP40)
    end

  def read_fn(BMP280),
    do: fn ->
      BMP280.measure(BMP280)
    end

  def read_fn(VEML6030),
    do: fn ->
      VEML6030.get_measurement()
    end

  def convert_fn(SGP40) do
    fn reading ->
      case reading do
        {:ok, reading} ->
          Map.take(reading, [:voc_index])

        _ ->
          %{}
      end
    end
  end

  def convert_fn(BMP280) do
    fn reading ->
      case reading do
        {:ok, measurement} ->
          Map.take(measurement, [:altitude_m, :pressure_pa, :temperature_c, :humidity_rh])

        _ ->
          %{}
      end
    end
  end

  def convert_fn(VEML6030) do
    fn data -> %{light_in_lumens: data} end
  end

  def measure(sensor) do
    sensor.read.()
    |> sensor.convert.()
  end
end
