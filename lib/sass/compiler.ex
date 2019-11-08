defmodule Sass.Compiler do
  @moduledoc """
    Connection to the NIF for sass
  """

  @compile {:autoload, false}
  @on_load {:init, 0}

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
    A noop that gets overwritten by the NIF compile
  """
  def compile(_, _) do
    exit(:nif_library_not_loaded)
  end

  @doc """
    A noop that gets overwritten by the NIF compile_file
  """
  def compile_file(_, _) do
    exit(:nif_library_not_loaded)
  end

  @doc """
    A noop that gets overwritten by the NIF compile_file
  """
  def version() do
    exit(:nif_library_not_loaded)
  end

  defp load_nif do
    path = :filename.join(:code.priv_dir(:sass_compiler), 'sass_nif')
    :erlang.load_nif(path, 0)
  end
end
