# SassCompiler
LibSass Nif for elixir

## Installation

Add `sass_compiler` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sass_compiler, "~> 0.1.5"}
  ]
end
```

## Usage

```elixir
sass = "$white : #fff; a { color: $white;}"
Sass.compile(sass)
{:ok, "a {\n  color: #fff;\n}\n"}

Sass.compile(sass, %{output_style: 2})
{:ok, "a { color: #fff; }\n"}

Sass.compile_file("test/sources/source.scss")
{:ok, ".navbar {\n  height: 23px;\n  width: 80%;\n}\n\n.navbar ul {\n  list-style-type: none;\n}\n\n.navbar li {\n  float: left;\n}\n\n.navbar li a {\n  font-weight: bold;\n}\n"}

Sass.compile_file("test/sources/source.scss", %{output_style: 3})
{:ok, ".navbar{height:23px;width:80%}.navbar ul{list-style-type:none}.navbar li{float:left}.navbar li a{font-weight:bold}\n"}
```

## License

SassCompiler is released under [the MIT License](./LICENSE)
