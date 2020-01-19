defmodule SassTest do
  use ExUnit.Case, async: true

  setup_all do
    {:ok,
     sources: [
       css: File.read!("test/sources/source.css"),
       sass: File.read!("test/sources/source.sass"),
       scss: File.read!("test/sources/source.scss")
     ],
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
          :css -> {"css", %{output_style: code}}
          :sass -> {"sass", %{is_indented_syntax: true, output_style: code}}
          :scss -> {"sass", %{output_style: code}}
        end

      {:ok, raw_result} = Sass.compile(sources[ext], options)
      {:ok, raw_file_result} = Sass.compile_file("test/sources/source.#{ext}", options)

      result = squish(raw_result)
      file_result = squish(raw_file_result)
      expected = {ext, style, fixture_css("test/results/#{prefix}.#{style}.css")}

      assert expected == {ext, style, result}
      assert expected == {ext, style, file_result}
    end
  end

  test "@import works as expected with load path" do
    {:ok, result} =
      Sass.compile_file("test/imports/app.scss", %{include_paths: ["test/imports/folder"]})

    assert Regex.match?(~r/background-color: #eee;/, result)
    assert Regex.match?(~r/height: 100%;/, result)
    assert Regex.match?(~r/bar: baz;/, result)
  end

  test "version" do
    assert Sass.version() == "3.6.3-48-g6e7a"
  end

  defp fixture_css(path) do
    css =
      File.read!(path)
      |> squish
  end

  defp squish(string) do
    string |> String.split(~r{\s+}) |> Enum.join(" ")
  end
end
