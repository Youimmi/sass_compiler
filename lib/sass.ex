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
  * include_paths list of directorys for Sass to search for imports ex

      `["bower_compoents", "../node_modules"]`

  """

  alias Sass.Compiler, as: Compiler

  @typedoc "The type describes a tuple of the form {:ok, String.t() } or {:error, :nif_library_not_loaded}"
  @type compiled :: {:ok, String.t()} | {:error, :nif_library_not_loaded}
  @typedoc "The type describes a String.t() with version or tuple {:error, :nif_library_not_loaded}"
  @type version :: String.t() | {:error, :nif_library_not_loaded}

  # Sass option values for sass [output style](https://sass-lang.com/documentation/js-api#outputstyle)
  @sass_styles [
    nested: 0,
    expanded: 1,
    compact: 2,
    compressed: 3
  ]

  @doc """
  Compiles a string of CSS/SCSS/Sass into a string of CSS

  ## Parameters

  * string: CSS/SCSS/Sass String
  * options: Map of sass options as defined above

  ## Examples

      iex> sass = "$white : #fff; a { color: $white;}"
      iex> Sass.compile(sass)
      {:ok, "a {\n  color: #fff; }\n"}

      # With options
      iex> Sass.compile(sass, %{output_style: 2})
      {:ok, "a { color: #fff; }\n"}

  """
  @spec compile(String.t()) :: compiled
  @spec compile(String.t(), map) :: compiled
  def compile(source, options \\ %{output_style: @sass_styles[:expanded]}) do
    source |> String.trim() |> Compiler.compile(options)
  end

  @doc """
  Compiles a file with CSS/SCSS/Sass into a string of CSS

  ## Parameters

  * path: Path to CSS/SCSS/Sass file to compile
  * options: Map of sass options as defined above

  ## Examples

      iex> Sass.compile_file("application.scss")
      {:ok, "a {\n  color: #fff; }\n"}

      # With options
      iex> Sass.compile_file("application.scss", %{output_style: 3})
      {:ok, "a{color:#fff}\n"}

  """
  @spec compile_file(String.t()) :: compiled
  @spec compile_file(String.t(), map) :: compiled
  def compile_file(path, options \\ %{output_style: @sass_styles[:expanded]}) do
    path |> String.trim() |> Compiler.compile_file(options)
  end

  @doc "Returns style codes"
  @spec styles :: keyword(integer)
  def styles, do: @sass_styles

  @doc "Returns current sass version"
  @spec version :: version
  def version, do: Compiler.version()
end
