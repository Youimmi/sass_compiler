defmodule SassTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import Support.TestHelpers

  setup_all do
    extensions = ~w[css sass scss]a

    {:ok,
     sources: Enum.map(extensions, &{&1, "test/fixtures/source.#{&1}"}),
     extensions: extensions,
     styles: [compact: 2, compressed: 3, expanded: 1, nested: 0]}
  end

  test "Sass.compile/1 and Sass.compile_file/1 compile CSS, Sass and SCSS to CSS", %{
    extensions: extensions,
    sources: sources,
    styles: styles
  } do
    Stream.each(extensions, fn ext_name ->
      Stream.each(styles, fn {style, code} ->
        {prefix, options} = style_options(ext_name, code)

        compiled = [
          compile(sources[ext_name], options),
          compile_file("test/fixtures/source.#{ext_name}", options)
        ]

        expected = {ext_name, style, fixture_css("test/fixtures/#{prefix}.#{style}.css")}

        Stream.each(compiled, fn result ->
          assert expected == {ext_name, style, result}
        end)
        |> Enum.to_list()
      end)
      |> Enum.to_list()
    end)
    |> Enum.to_list()
  end

  test "@import works as expected with load path" do
    {:ok, result} =
      Sass.compile_file("test/fixtures/app.scss", %{include_paths: ["test/fixtures/folder"]})

    patterns = [
      ~r/background-color: #eee;/,
      ~r/height: 100%;/,
      ~r/bar: baz;/
    ]

    Stream.each(patterns, fn pattern ->
      assert Regex.match?(pattern, result)
    end)
    |> Enum.to_list()
  end

  test "version" do
    assert Sass.version() == "3.6.3-55-g8f59b"
  end
end
