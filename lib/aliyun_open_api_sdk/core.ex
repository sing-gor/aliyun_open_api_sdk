defmodule AliyunOpenApiSdk.Core do
  @moduledoc """
  alias AliyunOpenApiSdk.CloudAPI.DescribeApi
  req_data = %{
    "REGIONS"=> "cn-shenzhen",
    "ALIYUN_ACCESS_KEY" => "<YOUR ALIYUN_ACCESS_KEY>",
    "ALI_YUN_ACCESS_SECRET"=> "<YOUR ALI_YUN_ACCESS_SECRET>",
  }

  {:ok, data} = CreateApp.changeset(%{AppName: "Sing8", Description: "test",Tag: [%{"teat1" => "teat1"}]})
  AliyunOpenApiSdk.Core2.aliyun_api_request(data)

  AliyunOpenApiSdk.Core2.aliyun_api_request(data, req_data)

  """

  def client(body, req_data, now_time, endpoint_regional) do
    header = [
      {"Date", Calendar.DateTime.Format.httpdate(now_time)},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    host = gen_host(body, req_data, endpoint_regional)

    middleware = [
      {Tesla.Middleware.BaseUrl, host},
      {Tesla.Middleware.Headers, header},
      Tesla.Middleware.FormUrlencoded,
      Tesla.Middleware.Logger
    ]

    Tesla.client(middleware)
  end

  def gen_host(body, req_data, true) do
    "https://#{body["PRODUCT"]}.#{req_data["REGIONS"]}.aliyuncs.com"
  end

  def gen_host(body, _, false) do
    "https://#{body["PRODUCT"]}.aliyuncs.com"
  end

  def aliyun_api_request(data) do
    req_data = %{
      "REGIONS" => Application.get_env(:aliyun_open_api_sdk, AliyunOpenApiSdk)[:regions],
      "ALIYUN_ACCESS_KEY" =>
        Application.get_env(:aliyun_open_api_sdk, AliyunOpenApiSdk)[:aliyun_access_key],
      "ALI_YUN_ACCESS_SECRET" =>
        Application.get_env(:aliyun_open_api_sdk, AliyunOpenApiSdk)[:aliyun_access_secret]
    }

    aliyun_api_request(data, req_data)
  end

  def aliyun_api_request(
        %{body: body, method: method},
        req_data
      ) do
    now_time = Calendar.DateTime.now_utc()
    endpoint_regional = body["EndpointRegional"]
    body = gen_body(body, now_time, req_data)
    gen_body_sign_encode(method, body, req_data)
    sign_body = Map.put(body, "Signature", gen_body_sign_str(method, body, req_data))

    client(body, req_data, now_time, endpoint_regional)
    |> api_request(String.upcase(method), "", sign_body, req_data)
    |> case do
      {:ok, %{status: 200, body: body, headers: headers}} ->
        {:ok, %{:body => body, :headers => headers}}

      {:error, %{status: status, body: body, headers: headers}} ->
        {:error, %{:body => body, :headers => headers, :status => status}}

      other ->
        other
    end
  end

  defp api_request(client, "POST", path, body, _) do
    Tesla.post(client, path, body)
    # Tesla.post(client, "?#{URI.encode_query(body)}", body)
  end

  defp api_request(client, "GET", _path, body, _) do
    Tesla.get(client, "?#{URI.encode_query(body)}")
  end

  def hmac_sha(data, key) do
    :crypto.mac(:hmac, :sha, key <> "\&", data)
  end

  def gen_body(body, now_time, req_data) do
    body
    |> Map.put("Format", "json")
    |> Map.put("AccessKeyId", req_data["ALIYUN_ACCESS_KEY"])
    |> Map.put("SignatureNonce", UUID.uuid4())
    |> Map.put("Timestamp", Calendar.Strftime.strftime!(now_time, "%Y-%m-%dT%H:%M:%SZ"))
    |> Map.put("SignatureMethod", "HMAC-SHA1")
    |> Map.put("SignatureVersion", "1.0")
    |> handle_array
  end

  def gen_body_sign_str(method, body, req_data) do
    body
    |> URI.encode_query(:rfc3986)
    |> URI.encode_www_form()
    |> sign_body(method)
    |> hmac_sha(req_data["ALI_YUN_ACCESS_SECRET"])
    |> Base.encode64()
  end

  def sign_body(data, method) do
    "#{String.upcase(method)}\&%2F\&" <> data
  end

  def gen_body_sign_encode(method, body, _) do
    body
    |> URI.encode_query(:rfc3986)
    |> URI.encode_www_form()
    |> sign_body(method)
  end

  def handle_array(body) do
    array_body =
      Map.filter(body, fn {_key, val} -> is_list(val) end)
      |> Enum.map(fn {k, v} -> handle_array(k, v) end)
      |> List.flatten()
      |> merge_dict(%{})
      |> Map.filter(fn {_, val} -> String.length(val) != 0 end)

    str_body = Map.filter(body, fn {_key, val} -> is_bitstring(val) end)
    Map.merge(str_body, array_body)
  end

  def handle_array(key, value) do
    handle_array_key_value(key, value, 0)
  end

  def handle_array_key_value(_, [], _), do: []

  def handle_array_key_value(key, [item | tail], index) do
    {k, v} =
      item
      |> Map.to_list()
      |> List.first()

    new_dict = %{
      "#{key}.#{index + 1}.Key" => k,
      "#{key}.#{index + 1}.Value" => v
    }

    [new_dict | handle_array_key_value(key, tail, index + 1)]
  end

  def merge_dict([], data), do: data

  def merge_dict([item | tail], data) do
    new_data = Map.merge(item, data)
    merge_dict(tail, new_data)
  end
end
