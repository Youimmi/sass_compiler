defmodule SassTest do
  use ExUnit.Case

  def scss_string,
    do:
      "/* sample_scss.scss */#navbar {width: 80%;height: 23px;ul { list-style-type: none; }; li {float: left; a { font-weight: bold; } } }"

  test "Sass.compile/1 compiles a SCSS string to CSS" do
    {:ok, expected_css} = File.read("test/sample_scss.css")
    {:ok, result_css} = scss_string() |> Sass.compile()

    assert expected_css == result_css
  end

  test "Sass.compile/1 compiles a SCSS string to CSS with output style expanded" do
    {:ok, expected_css} = File.read("test/expanded.css")
    {:ok, result_css} = Sass.compile(scss_string(), %{output_style: Sass.sass_style_expanded()})

    assert expected_css == result_css
  end

  test "Sass.compile/1 compiles a SCSS string to CSS with output style compact" do
    {:ok, expected_css} = File.read("test/compact.css")
    {:ok, result_css} = Sass.compile(scss_string(), %{output_style: Sass.sass_style_compact()})

    assert expected_css == result_css
  end

  test "Sass.compile/1 compiles a sass file to CSS" do
    {:ok, expected_css} = File.read("test/sample_sass.css")
    {:ok, result_css} = Sass.compile_file("./test/sample_sass.sass")

    assert expected_css == result_css
  end

  test "Sass.compile/1 compiles a SCSS file to CSS" do
    {:ok, expected_css} = File.read("test/sample_scss.css")
    {:ok, result_css} = Sass.compile_file("./test/sample_scss.scss")

    assert expected_css == result_css
  end

  test "@import works as expected with load path" do
    {:ok, result} =
      Sass.compile_file("./test/samples/app.scss", %{
        include_paths: ["#{System.cwd()}/test/samples/folder"]
      })

    assert Regex.match?(~r/background-color: #eee;/, result)
    assert Regex.match?(~r/height: 100%;/, result)
    assert Regex.match?(~r/bar: baz;/, result)
  end

  test "version" do
    assert Sass.version() == "3.6.3-4-gd91105"
  end
end
