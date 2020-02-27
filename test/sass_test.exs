defmodule SassTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import Support.TestHelpers

  setup_all do
    {:ok,
     sources: [
       css: File.read!("test/fixtures/source.css"),
       sass: File.read!("test/fixtures/source.sass"),
       scss: File.read!("test/fixtures/source.scss")
     ],
     extensions: ~w[css sass scss]a,
     styles: [compact: 2, compressed: 3, expanded: 1, nested: 0]}
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

      {:ok, compiled_css} = Sass.compile(sources[ext], options)
      {:ok, compiled_css_from_file} = Sass.compile_file("test/fixtures/source.#{ext}", options)
      css = compiled_css |> squish
      css_from_file = compiled_css_from_file |> squish
      expected_css = {ext, style, fixture_css("test/fixtures/#{prefix}.#{style}.css")}

      assert expected_css == {ext, style, css}
      assert expected_css == {ext, style, css_from_file}
    end
  end

  test "@import works as expected with load path" do
    {:ok, result} =
      Sass.compile_file("test/fixtures/app.scss", %{include_paths: ["test/fixtures/folder"]})

    assert Regex.match?(~r/background-color: #eee;/, result)
    assert Regex.match?(~r/height: 100%;/, result)
    assert Regex.match?(~r/bar: baz;/, result)
  end

  test "version" do
    assert Sass.version() == "3.6.3-48-g6e7a"
  end
end
