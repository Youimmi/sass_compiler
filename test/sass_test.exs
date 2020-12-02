defmodule SassTest do
  @moduledoc false

  use ExUnit.Case, async: true
  import ExUnit.Callbacks, only: [setup_all: 1]

  import Support.TestHelpers,
    only: [
      assert_async: 3,
      compile: 2,
      compile_file: 2,
      fixture_css: 1,
      perform_async: 2,
      style_options: 2
    ]

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
    perform_async(extensions, fn ext_name ->
      perform_async(styles, fn {style, code} ->
        {prefix, options} = style_options(ext_name, code)

        assert_async(
          [
            compile(sources[ext_name] |> File.read!(), options),
            compile_file(@fixtures_path <> "source.#{ext_name}", options)
          ],
          fixture_css(@fixtures_path <> "#{prefix}.#{style}.css"),
          &({ext_name, style, &2} == {ext_name, style, &1})
        )
      end)
    end)
  end

  test "Sass.compile/1 returns error if an empty string is passed", %{
    extensions: extensions,
    styles: styles
  } do
    perform_async(extensions, fn ext_name ->
      assert_async(
        styles,
        "Internal Error: Data context created with empty source string\n",
        fn expected, {style, code} ->
          {_, options} = style_options(ext_name, code)
          {ext_name, style, expected} == {ext_name, style, compile("", options)}
        end
      )
    end)
  end

  test "Sass.compile_file/1 returns \"\" if an empty file is passed", %{
    extensions: extensions,
    styles: styles
  } do
    perform_async(extensions, fn ext_name ->
      assert_async(styles, "", fn expected, {style, code} ->
        {_, options} = style_options(ext_name, code)
        result = compile_file(@fixtures_path <> "blank.#{ext_name}", options)
        {ext_name, style, expected} == {ext_name, style, result}
      end)
    end)
  end

  test "@import works as expected with load path" do
    assert_async(
      [~r/background-color: #eee;/, ~r/height: 100%;/, ~r/bar: baz;/],
      compile_file(@fixtures_path <> "app.scss", %{include_paths: [@fixtures_path <> "import"]}),
      &Regex.match?(&2, &1)
    )
  end
end
