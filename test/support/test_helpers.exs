defmodule Support.TestHelpers do
  def fixture_css(path) do
    path
    |> File.read!()
    |> squish()
  end

  def squish(string) do
    string
    |> String.split(~r{\s+})
    |> Enum.join(" ")
  end
end
