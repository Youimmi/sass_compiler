defmodule SassCompiler.Mixfile do
  use Mix.Project

  @version "0.1.0"

  @description """
  A C/C++ implementation of a Sass compiler for Elixir
  """

  def project do
    [
      app: :sass_compiler,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      compilers: [:elixir_make] ++ Mix.compilers(),
      make_clean: ["clean"],
      description: @description,
      package: package(),
      deps: deps(),
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
      exclude_patterns: ["*.o", "libsass/lib", "libsass/.git"],
      files: ["c_src", "lib", "libsass", "LICENSE", "Makefile", "mix.exs", "README.md"],
      maintainers: [],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Youimmi/sass_compiler"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:elixir_make, "~> 0.5", runtime: false}
    ]
  end
end
