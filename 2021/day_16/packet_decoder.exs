defmodule Header do
  defstruct [:version, :type_id]

  def new(params) do
    struct!(__MODULE__, params)
  end
end

defmodule Packet.Literal do
  defstruct [:header, :value]

  def new(params = %{header: %Header{}}) do
    struct!(__MODULE__, params)
  end
end

defmodule Packet.Operator do
  defstruct [:header, :subpackets]

  def new(params = %{header: %Header{}}) do
    struct!(__MODULE__, params)
  end
end

defmodule PacketDecoder do
  use Bitwise

  def read_input(filename) do
    File.read!(filename)
    |> String.trim_trailing()
    |> hex_to_bitstring()
  end

  def hex_to_bitstring(str) do
    String.to_charlist(str)
    |> Enum.reduce("", fn char, acc ->
      "#{acc}#{hex_char_to_bitstring(char)}"
    end)
  end

  defp hex_char_to_bitstring(char) do
    char_to_decimal(char)
    |> Integer.to_string(2)
    |> String.pad_leading(4, "0")
  end

  defp char_to_decimal(char) when char in ?0..?9 do
    char - ?0
  end

  defp char_to_decimal(char) when char in ?A..?F do
    char - ?A + 10
  end

  def read_packets(bitstring) do
    read_packets(bitstring, [])
  end

  def read_packets(bitstring, acc) do
    # A packet must be composed of at least two hex characters
    if String.length(bitstring) >= 8 do
      {packet, rest} = read_packet(bitstring)
      read_packets(rest, [packet | acc])
    else
      Enum.reverse(acc)
    end
  end

  # Reads a single packet
  def read_packet(bitstring) do
    {header, rest} = read_header(bitstring)
    {packet, rest} = case header.type_id do
      4 ->
        {literal_value, rest} = read_literal_value(rest)
        {Packet.Literal.new(%{header: header, value: literal_value}), rest}
      _ ->
        {subpackets, rest} = read_operator(rest)
        {Packet.Operator.new(%{header: header, subpackets: subpackets}), rest}
    end
    {packet, rest}
  end

  defp read_header(bitstring) do
    <<version::binary-size(3), type_id::binary-size(3), rest::binary>> = bitstring
    header = Header.new(%{
      version: String.to_integer(version, 2),
      type_id: String.to_integer(type_id, 2)
    })
    {header, rest}
  end

  defp read_literal_value(bitstring) do
    read_literal_value(bitstring, "")
  end

  defp read_literal_value(bitstring, acc) do
    <<leading::binary-size(1), literal::binary-size(4), rest::binary>> = bitstring
    case leading do
      "0" -> # Last group
        {String.to_integer("#{acc}#{literal}", 2), rest}
      "1" ->
        read_literal_value(rest, "#{acc}#{literal}")
    end
  end

  defp read_operator(bitstring) do
    <<length_type_id::binary-size(1), rest::binary>> = bitstring
    case length_type_id do
      "0" ->
        <<length::binary-size(15), rest::binary>> = rest
        length = String.to_integer(length, 2)
        <<subpackets_bitstring::binary-size(length), rest::binary>> = rest
        {read_packets(subpackets_bitstring), rest}
      "1" ->
        <<num_subpackets::binary-size(11), rest::binary>> = rest
        num_subpackets = String.to_integer(num_subpackets, 2)
        read_subpackets(rest, 0, num_subpackets, [])
    end
  end

  defp read_subpackets(bitstring, packets_read, stop, acc)
  when packets_read >= stop do
    {Enum.reverse(acc), bitstring}
  end

  defp read_subpackets(bitstring, packets_read, stop, acc) do
    {packet, rest} = read_packet(bitstring)
    read_subpackets(rest, packets_read + 1, stop, [packet | acc])
  end

  def version_sum(packets) do
    version_sum(packets, 0)
  end

  defp version_sum([], acc), do: acc
  defp version_sum([packet | rest], acc) do
    version_sum(rest, acc + packet_version_sum(packet))
  end

  defp packet_version_sum(%Packet.Literal{header: %Header{version: v}}), do: v
  defp packet_version_sum(packet = %Packet.Operator{header: %Header{version: v}}) do
    version_sum(packet.subpackets, v)
  end

  def evaluate([packet]), do: evaluate(packet)

  def evaluate(%Packet.Literal{header: %Header{type_id: 4}, value: v}), do: v

  def evaluate(%Packet.Operator{header: %Header{type_id: 0}, subpackets: subpackets}) do
    Enum.reduce(subpackets, 0, fn packet, acc ->
      acc + evaluate(packet)
    end)
  end

  def evaluate(%Packet.Operator{header: %Header{type_id: 1}, subpackets: subpackets}) do
    Enum.reduce(subpackets, 1, fn packet, acc ->
      acc * evaluate(packet)
    end)
  end

  def evaluate(%Packet.Operator{header: %Header{type_id: 2}, subpackets: subpackets}) do
    subpackets
    |> Stream.map(&evaluate/1)
    |> Enum.min()
  end

  def evaluate(%Packet.Operator{header: %Header{type_id: 3}, subpackets: subpackets}) do
    subpackets
    |> Stream.map(&evaluate/1)
    |> Enum.max()
  end

  def evaluate(%Packet.Operator{header: %Header{type_id: 5}, subpackets: [sub_1, sub_2]}) do
    case evaluate(sub_1) > evaluate(sub_2) do
      true -> 1
      false -> 0
    end
  end

  def evaluate(%Packet.Operator{header: %Header{type_id: 6}, subpackets: [sub_1, sub_2]}) do
    case evaluate(sub_1) < evaluate(sub_2) do
      true -> 1
      false -> 0
    end
  end

  def evaluate(%Packet.Operator{header: %Header{type_id: 7}, subpackets: [sub_1, sub_2]}) do
    case evaluate(sub_1) == evaluate(sub_2) do
      true -> 1
      false -> 0
    end
  end
end

PacketDecoder.hex_to_bitstring("D2FE28")
|> PacketDecoder.read_packets()
|> IO.inspect

PacketDecoder.hex_to_bitstring("38006F45291200")
|> PacketDecoder.read_packets()
|> IO.inspect

PacketDecoder.hex_to_bitstring("EE00D40C823060")
|> PacketDecoder.read_packets()
|> IO.inspect

# Part 1
PacketDecoder.hex_to_bitstring("8A004A801A8002F478")
|> PacketDecoder.read_packets()
|> PacketDecoder.version_sum()
|> IO.inspect

PacketDecoder.hex_to_bitstring("620080001611562C8802118E34")
|> PacketDecoder.read_packets()
|> PacketDecoder.version_sum()
|> IO.inspect

PacketDecoder.hex_to_bitstring("C0015000016115A2E0802F182340")
|> PacketDecoder.read_packets()
|> PacketDecoder.version_sum()
|> IO.inspect

PacketDecoder.hex_to_bitstring("A0016C880162017C3686B18A3D4780")
|> PacketDecoder.read_packets()
|> PacketDecoder.version_sum()
|> IO.inspect

PacketDecoder.read_input("input")
|> PacketDecoder.read_packets()
|> PacketDecoder.version_sum()
|> IO.inspect

# Part 2
PacketDecoder.hex_to_bitstring("C200B40A82")
|> PacketDecoder.read_packets()
|> PacketDecoder.evaluate()
|> IO.inspect

PacketDecoder.hex_to_bitstring("04005AC33890")
|> PacketDecoder.read_packets()
|> PacketDecoder.evaluate()
|> IO.inspect

PacketDecoder.hex_to_bitstring("880086C3E88112")
|> PacketDecoder.read_packets()
|> PacketDecoder.evaluate()
|> IO.inspect

PacketDecoder.hex_to_bitstring("CE00C43D881120")
|> PacketDecoder.read_packets()
|> PacketDecoder.evaluate()
|> IO.inspect

PacketDecoder.hex_to_bitstring("D8005AC2A8F0")
|> PacketDecoder.read_packets()
|> PacketDecoder.evaluate()
|> IO.inspect

PacketDecoder.hex_to_bitstring("F600BC2D8F")
|> PacketDecoder.read_packets()
|> PacketDecoder.evaluate()
|> IO.inspect

PacketDecoder.hex_to_bitstring("9C005AC2F8F0")
|> PacketDecoder.read_packets()
|> PacketDecoder.evaluate()
|> IO.inspect

PacketDecoder.hex_to_bitstring("9C0141080250320F1802104A08")
|> PacketDecoder.read_packets()
|> PacketDecoder.evaluate()
|> IO.inspect

PacketDecoder.read_input("input")
|> PacketDecoder.read_packets()
|> PacketDecoder.evaluate()
|> IO.inspect
