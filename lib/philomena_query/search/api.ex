defmodule PhilomenaQuery.Search.Api do
  @moduledoc """
  Interaction with OpenSearch API by endpoint name.

  See https://opensearch.org/docs/latest/api-reference for a complete reference.
  """

  alias PhilomenaQuery.Search.Client

  @type server_url :: String.t()
  @type index_name :: String.t()

  @type properties :: map()
  @type mapping :: map()
  @type document :: map()
  @type document_id :: integer()

  @doc """
  Create the index named `name` with the given `mapping`.

  https://opensearch.org/docs/latest/api-reference/index-apis/create-index/
  """
  @spec create_index(server_url(), index_name(), mapping()) :: Client.result()
  def create_index(url, name, mapping) do
    url
    |> prepare_url([name])
    |> Client.put(mapping)
  end

  @doc """
  Delete the index named `name`.

  https://opensearch.org/docs/latest/api-reference/index-apis/delete-index/
  """
  @spec delete_index(server_url(), index_name()) :: Client.result()
  def delete_index(url, name) do
    url
    |> prepare_url([name])
    |> Client.delete()
  end

  @doc """
  Update the index named `name` with the given `properties`.

  https://opensearch.org/docs/latest/api-reference/index-apis/put-mapping/
  """
  @spec update_index_mapping(server_url(), index_name(), properties()) :: Client.result()
  def update_index_mapping(url, name, properties) do
    url
    |> prepare_url([name, "_mapping"])
    |> Client.put(properties)
  end

  @doc """
  Index `document` in the index named `name` with integer id `id`.

  https://opensearch.org/docs/latest/api-reference/document-apis/index-document/
  """
  @spec index_document(server_url(), index_name(), document(), document_id()) :: Client.result()
  def index_document(url, name, document, id) do
    url
    |> prepare_url([name, "_doc", Integer.to_string(id)])
    |> Client.put(document)
  end

  @doc """
  Remove document in the index named `name` with integer id `id`.

  https://opensearch.org/docs/latest/api-reference/document-apis/delete-document/
  """
  @spec delete_document(server_url(), index_name(), document_id()) :: Client.result()
  def delete_document(url, name, id) do
    url
    |> prepare_url([name, "_doc", Integer.to_string(id)])
    |> Client.delete()
  end

  @doc """
  Bulk operation.

  https://opensearch.org/docs/latest/api-reference/document-apis/bulk/
  """
  @spec bulk(server_url(), list()) :: Client.result()
  def bulk(url, lines) do
    url
    |> prepare_url(["_bulk"])
    |> Client.post(lines)
  end

  @doc """
  Asynchronous scripted updates.

  Sets `conflicts` to `proceed` and `wait_for_completion` to `false`.

  https://opensearch.org/docs/latest/api-reference/document-apis/update-by-query/
  """
  @spec update_by_query(server_url(), index_name(), map()) :: Client.result()
  def update_by_query(url, name, body) do
    url
    |> prepare_url([name, "_update_by_query"])
    |> append_query_string(%{conflicts: "proceed", wait_for_completion: "false"})
    |> Client.post(body)
  end

  @doc """
  Search for documents in index named `name` with `query`.

  https://opensearch.org/docs/latest/api-reference/search/
  """
  @spec search(server_url(), index_name(), map()) :: Client.result()
  def search(url, name, body) do
    url
    |> prepare_url([name, "_search"])
    |> Client.get(body)
  end

  @doc """
  Search for documents in all indices with specified `lines`.

  https://opensearch.org/docs/latest/api-reference/multi-search/
  """
  @spec msearch(server_url(), list()) :: Client.result()
  def msearch(url, lines) do
    url
    |> prepare_url(["_msearch"])
    |> Client.get(lines)
  end

  @spec prepare_url(String.t(), [String.t()]) :: String.t()
  defp prepare_url(url, parts) when is_list(parts) do
    # Combine path generated by the parts with the main URL
    url
    |> URI.merge(Path.join(parts))
    |> to_string()
  end

  @spec append_query_string(String.t(), map()) :: String.t()
  defp append_query_string(url, params) do
    url <> "?" <> URI.encode_query(params)
  end
end
