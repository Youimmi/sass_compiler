defmodule SassCompiler.Mixfile do
  @moduledoc false

  use Mix.Project

  @version "0.1.9"

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
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
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
      maintainers: [],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Youimmi/sass_compiler"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.4.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:elixir_make, "~> 0.6", runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.12.3", only: :test}
    ]
  end
end
