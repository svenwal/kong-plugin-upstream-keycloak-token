local plugin = {
    PRIORITY = 1025, -- set the plugin priority, which determines plugin execution order
    VERSION = "1.0",
  }
  
  function plugin:access(plugin_conf)
    -- >>>>>> checking if client token is cached - if not execute fetch_token to fetch it
    local str = require "resty.string"
    local token_cache_key = "upstream_keycloak_token_" .. str.to_hex(plugin_conf.keycloak_base_url .. "_" .. plugin_conf.keycloak_realm .. "_" .. plugin_conf.client_id)
    local opts = { ttl = plugin_conf.token_ttl }
    local token, err = kong.cache:get(token_cache_key, opts, fetch_token, plugin_conf)
    if err then
      kong.log.err(err)
    end
    kong.service.request.add_header("Authorization", "Bearer " .. token)

  end



  -- ******** Apikey code checking starts here
  function fetch_token(plugin_conf)
    local http = require "resty.http"
    local httpc = http.new()
    local res, err = httpc:request_uri(plugin_conf.keycloak_base_url .. "/auth/realms/" .. plugin_conf.keycloak_realm .. "/protocol/openid-connect/token", {
      method = "POST",
      body = "grant_type=client_credentials&client_id=" .. plugin_conf.client_id .. "&client_secret=" .. plugin_conf.client_secret,
       headers = {
         ["Content-Type"] = "application/x-www-form-urlencoded",
       },
     })

    if not res then
      kong.log.warn("Not able to access token endpoint for token creation")
      kong.log.debug("Tried url " .. plugin_conf.keycloak_base_url .. "/auth/realms/" .. plugin_conf.keycloak_realm .. "/protocol/openid-connect/token")
      kong.log.debug("Tried POST body: grant_type=password&client_id=" .. plugin_conf.client_id .. "&client_secret=xxxx") 
      kong.log.err(err)
      return kong.response.exit(403, 'Invalid credentials')
    end 

    local cjson = require("cjson.safe").new()

    local serialized_content, err = cjson.decode(res.body)
    if not serialized_content then
      kong.log.warn("Token creation failed due to non-parsable response from token endpoint")
      return kong.response.exit(403, 'Invalid credentials')
    end
    if not serialized_content.access_token then
      kong.log.warn("Token creation failed due to no token embedded in response")
      return kong.response.exit(403, 'Invalid credentials')
    end
    return serialized_content.access_token
  end

  
  return plugin
