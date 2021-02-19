defmodule SassCompiler.Mixfile do
  @moduledoc false

  use Mix.Project

  @version "0.1.16"

  @description """
  A C/C++ implementation of a Sass compiler for Elixir
  """

  def project do
    [
      app: :sass_compiler,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      compilers: [:elixir_make] ++ Mix.compilers(),
      make_clean: ["clean"],
      description: @description,
      package: package(),
      deps: deps(),
      aliases: aliases(),
      source_url: "https://github.com/Youimmi/sass_compiler"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      exclude_patterns: [".o", "libsass/lib", "libsass/.git"],
      files: ["c_src", "lib", "libsass", "LICENSE", "Makefile", "mix.exs", "README.md"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Youimmi/sass_compiler"},
      maintainers: ["Yuri S.", "Roman S."]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:elixir_make, "~> 0.6", runtime: false},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix update
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      update: [
        "cmd rm -rf _build deps mix.lock",
        "cmd cd libsass && make clean && git pull https://github.com/sass/libsass",
        "deps.get"
      ]
    ]
  end
end
