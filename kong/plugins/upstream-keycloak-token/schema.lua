local typedefs = require "kong.db.schema.typedefs"

-- Grab pluginname from module name
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

local schema = {
  name = plugin_name,
  fields = {
    { consumer = typedefs.no_consumer },  -- this plugin cannot be configured on a consumer (typical for auth plugins)
    { protocols = typedefs.protocols_http },
    { config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
          { keycloak_base_url = {
              type = "string",
              required = true
              }},
          { keycloak_realm = {
              type = "string",
              required = true
              }},
          { token_ttl = {
              type = "integer",
              default = 50,
              required = true
            }},
          { client_id = {
              type = "string",
              required = true,
              referenceable = true,
              }},
          { client_secret = {
              type = "string",
              required = true,
              referenceable = true,
              }},
        },
        entity_checks = {
        },
      },
    },
  },
}

return schema
