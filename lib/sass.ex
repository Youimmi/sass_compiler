defmodule Sass do
  @moduledoc """
  Compiles SASS into CSS using a NIF for Libsass

  ## Currently supported Sass options

  * [output_style](http://sass-lang.com/documentation/file.SASS_REFERENCE.html#output_style) Use the helpers below to assign the style
  * precision `integer` - decimal rounding percision
  * source_comments `true` or `false` - Causes the line number and file where a selector is defined to be emitted into the compiled CSS as a comment
  * soure_map_embed `true` or `false`
  * source_map_contents `true` or `false`
  * omit_source_map_url `true` or `false`
  * is_indented_syntax `true` or `false`
  * indent `:tab` or `:space`
  * linefeed `:unix` or `:windows`
  * include_paths list of directorys for Sass to search for imports ex.

      `["bower_compoents", "../node_modules"]`

  """

  @doc """
    Sass option values for sass output style [nested](https://sass-lang.com/documentation/js-api#outputstyle)
  """
  @sass_styles [
    expanded: 1,
    compressed: 3,
    nested: 0,
    compact: 2
  ]

  @doc """
  Compiles a string of SASS into a string of CSS

  ## Parameters

  * string: Sass String.
  * options: Map of sass options as defined above

  ## Examples

      Sass.compile("$white : #fff; a { color: $white;}")
      #=> "a { color: #fff; }"
      # With Options
      Sass.compile("$white : #fff; a { color: $white;}", %{output_style: Sass.sass_style_compressed})
      #=> "a{color:#fff;}"

  """
  @spec compile(String.t()) :: no_return
  @spec compile(String.t(), map) :: no_return
  def compile(source, options \\ %{output_style: @sass_styles[:nested]}) do
    sass = source |> String.trim()
    Sass.Compiler.compile(sass, options)
  end

  @doc """
  Compiles a file of SASS into a string of CSS

  ## Parameters

  * path: Path to sass file to compile.
  * options: Map of sass options as defined above

  ## Examples

      Sass.compile_file("application.scss")
      #=> "a { color: #fff; }"
      # With Options
      Sass.compile_file("application.scss", %{output_style: Sass.sass_style_compressed})
      #=> "a{color:#fff;}"

  """
  @spec compile_file(String.t()) :: no_return
  @spec compile_file(String.t(), map) :: no_return
  def compile_file(path, options \\ %{output_style: @sass_styles[:nested]}) do
    filename = path |> String.trim()
    Sass.Compiler.compile_file(filename, options)
  end

  @doc """
    Returns current sass version
  """
  @spec version :: no_return
  def version, do: Sass.Compiler.version()
end
