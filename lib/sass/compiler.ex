defmodule Sass.Compiler do
  @moduledoc """
  Connection to the NIF for sass
  """

  @compile {:autoload, false}
  @on_load {:init, 0}

  @doc false
  def init do
    case load_nif() do
      :ok ->
        :ok

      _ ->
        raise """
        An error occurred when loading LibSass.
        Make sure you have a C compiler and Erlang 20 installed.
        If you are not using Erlang 20, either upgrade to Erlang 20.
        """
    end
  end

  @doc """
  Compiles a Sass to CSS
  """
  def compile(_, _) do
    {:error, :nif_library_not_loaded}
  end

  @doc """
  Compiles a Sass file to CSS
  """
  def compile_file(_, _) do
    {:error, :nif_library_not_loaded}
  end

  @doc """
  LibSass version
  """
  def version do
    {:error, :nif_library_not_loaded}
  end

  @doc false
  defp load_nif do
    :filename.join(:code.priv_dir(:sass_compiler), 'sass_nif')
    |> :erlang.load_nif(0)
  end
end
