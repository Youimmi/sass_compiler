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

  def compile(path, options) do
    {:ok, css} = Sass.compile(File.read!(path), options)
    css |> squish
  end

  def compile_file(path, options) do
    {:ok, css} = Sass.compile_file(path, options)
    css |> squish
  end
end
