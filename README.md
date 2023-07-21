# Kong plugin to inject a Keycloak issued token to the upstream request

## About

A Kong 🦍 plugin to inject a Keycloak issued token to the upstream request

This plugin will initiate a client credentials request to a Keycloak server and inject the received token into the request.

The idea behind this is Kong having authenticated / authorized using the standard plugins (like for example key-auth or mTLS) but the backend needs a JWT from a technical user

## Configuration parameters

|FORM PARAMETER|DEFAULT|DESCRIPTION|
|:----|:------|:------|
|config.token_ttl|50|Time in seconds we cache the token. Must be lower than the setting in Keycloak for this token|
|config.keycloak_base_url||Base URL of Keycloak like https://my.keycloak.example.com. NOTE: If using a SSL endpoint make sure the certificate is trusted in the Kong setting `lua_ssl_trusted_certificate`|
|config.keycloak_realm||The realm the plugin should use to look up the client|
|config.client_id||The client being used to create an admin token (*referencable*)|
|config._client_secret||The secret of the client being used to create an admin token (*referencable*)|

## Security notice

Sensitive information on the admin account for token creation can be securely stored in a vault: https://docs.konghq.com/gateway/latest/pdk/kong.vault/. See the (*referencable*) notice on the paramaters

