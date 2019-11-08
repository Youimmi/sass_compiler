# SassCompiler
LibSass Nif for elixir

## Installation

```elixir
# Add sass_compiler to your list of dependencies in mix.exs:
def deps do
  [{:sass_compiler, "~> 0.1.0"}]
end
```

```elixir
Sass.compile "#navbar {width: 80%;height: 23px;ul { list-style-type: none; } li {float: left; a { font-weight: bold; } } }"
{:ok, "#navbar {\n  width: 80%;\n  height: 23px; }\n  #navbar ul {\n    list-style-type: none; }\n  #navbar li {\n    float: left; }\n    #navbar li a {\n      font-weight: bold; }\n"}

Sass.compile_file "test/sample_scss.scss"
{:ok, "/* sample_scss.scss */\n#navbar {\n  width: 80%;\n  height: 23px; }\n  #navbar ul {\n    list-style-type: none; }\n  #navbar li {\n    float: left; }\n    #navbar li a {\n      font-weight: bold; }\n"}
```

## License

SassCompiler is released under [the MIT License](./LICENSE)
