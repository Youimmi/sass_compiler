defmodule SassTest do
  @moduledoc false

  use ExUnit.Case, async: true
  import ExUnit.Assertions, only: [assert: 1]

  import Support.TestHelpers,
    only: [
      compile: 2,
      compile_file: 2,
      fixture_css: 1,
      perform_async: 2,
      style_options: 2
    ]

  ExUnit.Case.register_describe_attribute(__MODULE__, :describe_fixtures)

  @fixtures_path "test/fixtures/"

  perform_async([css: "CSS", sass: "Sass", scss: "SCSS"], fn {ext, ext_name} ->
    source_file_path = @fixtures_path <> "source.#{ext}"
    blank_file_path = @fixtures_path <> "blank.#{ext}"

    perform_async([compact: 2, compressed: 3, expanded: 1, nested: 0], fn {style, code} ->
      describe "Compile the #{ext_name} file into CSS (#{style})" do
        {prefix, options} = style_options(ext, code)
        expected_css = fixture_css(@fixtures_path <> "#{prefix}.#{style}.css")

        test "Sass.compile/2 compiles #{ext_name} into CSS (#{style})" do
          result = unquote(compile(File.read!(source_file_path), options))

          assert(result == unquote(expected_css))
        end

        test "Sass.compile_file/2 compiles #{ext_name} into CSS (#{style})" do
          result = unquote(compile_file(source_file_path, options))

          assert(result == unquote(expected_css))
        end

        test "Sass.compile/2 returns error if a blank #{ext_name} string is passed (#{style})" do
          result = unquote(compile("", options))

          assert(result == "Internal Error: Data context created with empty source string\n")
        end

        test "Sass.compile_file/2 returns \"\" if a blank #{ext_name} file is passed (#{style})" do
          result = unquote(compile_file(blank_file_path, options))

          assert(result == "")
        end
      end
    end)
  end)

  describe "Compile imported files" do
    @result compile_file(@fixtures_path <> "app.scss", %{
              include_paths: [@fixtures_path <> "import"]
            })

    perform_async(
      ["background-color: #eee;", "height: 100%;", "bar: baz;"],
      fn expected_string ->
        test "@import works as expected with load path (#{expected_string})" do
          expected = ~r/#{unquote(Regex.escape(expected_string))}/

          assert(Regex.match?(expected, @result))
        end
      end
    )
  end
end
