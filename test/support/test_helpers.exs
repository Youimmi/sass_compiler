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

  def style_options(:css, code), do: {"css", %{output_style: code}}
  def style_options(:sass, code), do: {"sass", %{is_indented_syntax: true, output_style: code}}
  def style_options(:scss, code), do: {"sass", %{output_style: code}}

  def compile("", options),
    do: with({:error, error} <- Sass.compile("", options), do: error)

  def compile(content, options),
    do: with({:ok, css} <- Sass.compile(content, options), do: css |> squish)

  def compile_file(path, options),
    do: with({:ok, css} <- Sass.compile_file(path, options), do: css |> squish)
end
