defmodule SassTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import Support.TestHelpers

  @fixtures_path "test/fixtures/"

  setup_all do
    extensions = ~w[css sass scss]a

    {:ok,
     sources: Enum.map(extensions, &{&1, @fixtures_path <> "source.#{&1}"}),
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
          compile(sources[ext_name] |> File.read!(), options),
          compile_file(@fixtures_path <> "source.#{ext_name}", options)
        ]

        expected = fixture_css(@fixtures_path <> "#{prefix}.#{style}.css")

        Stream.each(compiled, fn result ->
          assert {ext_name, style, expected} == {ext_name, style, result}
        end)
        |> Enum.to_list()
      end)
      |> Enum.to_list()
    end)
    |> Enum.to_list()
  end

  test "Sass.compile/1 returns error if an empty string is passed", %{
    extensions: extensions,
    styles: styles
  } do
    Stream.each(extensions, fn ext_name ->
      Stream.each(styles, fn {style, code} ->
        {_, options} = style_options(ext_name, code)
        expected = "Internal Error: Data context created with empty source string\n"
        result = compile("", options)
        assert {ext_name, style, expected} == {ext_name, style, result}
      end)
      |> Enum.to_list()
    end)
    |> Enum.to_list()
  end

  test "Sass.compile_file/1 returns \"\" if an empty file is passed", %{
    extensions: extensions,
    styles: styles
  } do
    Stream.each(extensions, fn ext_name ->
      Stream.each(styles, fn {style, code} ->
        {_, options} = style_options(ext_name, code)
        result = compile_file(@fixtures_path <> "blank.#{ext_name}", options)
        assert {ext_name, style, ""} == {ext_name, style, result}
      end)
      |> Enum.to_list()
    end)
    |> Enum.to_list()
  end

  test "@import works as expected with load path" do
    result =
      compile_file(@fixtures_path <> "app.scss", %{include_paths: [@fixtures_path <> "import"]})

    assert result =~ ~r/background-color: #eee;/
    assert result =~ ~r/height: 100%;/
    assert result =~ ~r/bar: baz;/
  end

  test "version" do
    assert "3.6.3-57-g9515" =~ Sass.version()
  end
end
