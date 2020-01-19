defmodule SassTest do
  use ExUnit.Case, async: true

  setup_all do
    {:ok,
     sources: [css: read_source_css(), sass: read_source_sass(), scss: read_source_scss()],
     extensions: ~w[css sass scss]a,
     styles: Sass.styles()}
  end

  test "Sass.compile/1 and Sass.compile_file/1 compile CSS, Sass and SCSS to CSS", %{
    extensions: extensions,
    sources: sources,
    styles: styles
  } do
    for ext <- extensions, {style, code} <- styles do
      {prefix, options} =
        case ext do
          :sass -> {"sass", %{is_indented_syntax: true, output_style: code}}
          :scss -> {"sass", %{output_style: code}}
          :css -> {"css", %{output_style: code}}
        end

      {:ok, raw_expected} = File.read("test/results/#{prefix}.#{style}.css")
      {:ok, raw_result} = Sass.compile(sources[ext], options)
      {:ok, raw_file_result} = Sass.compile_file("test/sources/source.#{ext}", options)

      expected = raw_expected |> squish
      result = raw_result |> squish
      file_result = raw_file_result |> squish

      assert {ext, style, expected} == {ext, style, result}
      assert {ext, style, expected} == {ext, style, file_result}
    end
  end

  test "@import works as expected with load path" do
    {:ok, result} =
      Sass.compile_file("test/imports/app.scss", %{
        include_paths: ["test/imports/folder"]
      })

    assert Regex.match?(~r/background-color: #eee;/, result)
    assert Regex.match?(~r/height: 100%;/, result)
    assert Regex.match?(~r/bar: baz;/, result)
  end

  test "version" do
    assert Sass.version() == "3.6.3-48-g6e7a"
  end

  defp read_source_css do
    {:ok, file} = File.read("test/sources/source.css")
    file
  end

  defp read_source_sass do
    {:ok, file} = File.read("test/sources/source.sass")
    file
  end

  defp read_source_scss do
    {:ok, file} = File.read("test/sources/source.scss")
    file
  end

  defp squish(string) do
    string |> String.split(~r{\s+}) |> Enum.join(" ")
  end
end
