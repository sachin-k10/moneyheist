FROM quay.io/keycloak/keycloak:latest as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure database vendor
ENV KC_DB=postgres

# Working directory
WORKDIR /opt/keycloak

# Generate a self-signed certificate for demonstration purposes
# In production, use proper certificates
RUN keytool -genkeypair \
    -storepass password \
    -storetype PKCS12 \
    -keyalg RSA \
    -keysize 2048 \
    -dname "CN=server" \
    -alias server \
    -ext "SAN:c=DNS:localhost,IP:127.0.0.1" \
    -keystore conf/server.keystore

# Build the Keycloak instance
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest

# Copy the built Keycloak instance
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Environment variables for database and Keycloak hostname
ENV KC_DB=postgres
ENV KC_DB_URL=jdbc:postgresql://${KC_DB_HOST}:${KC_DB_PORT}/${KC_DB}
ENV KC_DB_USERNAME=${KC_DB_USERNAME}
ENV KC_DB_PASSWORD=${KC_DB_PASSWORD}
ENV KC_HOSTNAME=keycloak.localhost

# Command to start Keycloak
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", , "--optimized"]
