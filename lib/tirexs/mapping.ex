defmodule Tirexs.Mapping do
  @moduledoc false

  use Tirexs.DSL.Logic
  import Tirexs.ElasticSearch


  def transpose(block) do
    case block do
      {:indexes, _, [params]} -> Tirexs.Mapping.indexes(params[:do])
      {:indexes, _, options}  -> Tirexs.Mapping.indexes(options)
      {:index, _, [params]}   -> Tirexs.Mapping.indexes(params[:do])
      {:index, _, options}    -> Tirexs.Mapping.indexes(options)
    end
  end


  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(Tirexs.Mapping), only: [mappings: 1, indexes: 1]
    end
  end

  @doc false
  defmacro mappings([do: block]) do
    mappings =  [properties: extract(block)]
    quote do
      var!(index) = var!(index) ++ [mapping: unquote(mappings)]
    end
  end

  @doc false
  def indexes(options) do
    case options do
      [name, options] ->
        if options[:do] != nil do
          block = options
          options = [type: "object"]
          Dict.put([], to_atom(name), options ++ [properties: extract(block[:do])])
        else
          Dict.put([], to_atom(name), options)
        end
      [name, options, block] ->
        Dict.put([], to_atom(name), options ++ [properties: extract(block[:do])])
    end
  end

  @doc false
  def create_resource(definition, opts) do
    if definition[:type] do
      create_resource_settings(definition, opts)

      url  = "#{definition[:index]}/#{definition[:type]}/_mapping"
      json = to_resource_json(definition)

      put(url, json, opts)
    else
      url  = "#{definition[:index]}/_mapping"
      json = to_resource_json(definition, definition[:index])

      put(url, json, opts)
    end
  end

  @doc false
  def create_resource_settings(definition, opts) do
    unless exist?(definition[:index], opts), do: put(definition[:index], opts)
  end

  @doc false
  def to_resource_json(definition), do: to_resource_json(definition, definition[:type])

  @doc false
  def to_resource_json(definition, type) do
    json_dict = Dict.put([], type, definition[:mapping])
    JSON.encode(json_dict)
  end
end