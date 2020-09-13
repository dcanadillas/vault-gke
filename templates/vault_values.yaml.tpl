global:
  enabled: true
  tlsDisable: true
injector:
  # True if you want to enable vault agent injection.
  enabled: false
server:
  image:
    repository: "${vault_repo}"
    tag: "${vault_version}"
    pullPolicy: IfNotPresent
  updateStrategyType: "OnDelete"

  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      # kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/backend-protocol: HTTPS
      nginx.ingress.kubernetes.io/ssl-passthrough: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
    hosts:
      - host: ${hostname}
        paths: []
    # tls: []
    #  - secretName: chart-example-tls
    #    hosts:
    #      - chart-example.local

  readinessProbe:
    # ready if unsealed, either active or standby or performancestandby
    enabled: true
    path: /v1/sys/health?standbycode=204&performancestandbycode=204&drsecondarycode=204

  livenessProbe:
    # alive if vault is successfully responding to requests
    enabled: true
    path: /v1/sys/health?standbyok=true&perfstandbyok=true&sealedcode=204&uninitcode=204&drsecondarycode=204
    initialDelaySeconds: 30

  postStart: []
  # - /bin/sh
  # - -c
  # - /vault/userconfig/myscript/run.sh

  extraEnvironmentVars:
    GOOGLE_REGION: "${gcp_region}"
    GOOGLE_PROJECT: "${gcp_project}"
    GOOGLE_APPLICATION_CREDENTIALS: "/vault/userconfig/${kms_creds}/credentials.json"
  # VAULT_CACERT: /vault/userconfig/vault-server-tls/vault.ca

  # extraVolumes is a list of extra volumes to mount. These will be exposed
  # to Vault in the path `/vault/userconfig/<name>/`. The value below is
  # an array of objects, examples are shown below.
  extraVolumes:
    - type: 'secret'
      name: '${kms_creds}'
    - type: 'secret'
      name: 'vault-server-tls'
    #   path: null # default is `/vault/userconfig`

  affinity: |
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              app.kubernetes.io/name: {{ template "vault.name" . }}
              app.kubernetes.io/instance: "{{ .Release.Name }}"
              component: server
          topologyKey: kubernetes.io/hostname

  # Enables a headless service to be used by the Vault Statefulset
  service:
    enabled: true
    # clusterIP: None
    type: "NodePort"
    # nodePort: 30000
    # port: 8200
    # targetPort: 8200
    # annotations: {}

  # dataStorage:
  #   enabled: true
  #   # Size of the PVC created
  #   size: 10Gi
  #   storageClass: null
  #   accessMode: ReadWriteOnce

  # auditStorage:
  #   enabled: false
  #   # Size of the PVC created
  #   size: 10Gi
  #   storageClass: null
  #   accessMode: ReadWriteOnce

  ha:
    enabled: true
    replicas: ${vault_nodes}

    # If set to null, this will be set to the Pod IP Address
    apiAddr: null

    raft:
      enabled: true
      setNodeId: true
      config: |
        ui = true
        listener "tcp" {
          # tls_disable = 1
          address = "[::]:8200"
          cluster_address = "[::]:8201"
%{ if tls == "enabled" ~}
          tls_cert_file = "/vault/userconfig/vault-server-tls/vault.crt"
          tls_key_file = "/vault/userconfig/vault-server-tls/vault.key"
          tls_ca_cert_file = "/vault/userconfig/vault-server-tls/vault.ca"
%{ endif ~}
        }
        storage "raft" {
          path = "/vault/data"
%{ for leader_host in hosts ~}
          retry_join {
            leader_api_addr = "${http}://${leader_host}.vault-internal:8200"
%{ if tls == "enabled" ~}
            leader_ca_cert_file = "/vault/userconfig/vault-server-tls/vault.ca"
            leader_client_cert_file = "/vault/userconfig/vault-server-tls/vault.crt"
            leader_client_key_file = "/vault/userconfig/vault-server-tls/vault.key"
%{ endif ~}
          }
%{ endfor ~}
        }
        service_registration "kubernetes" {}
        # Using GCP KMP
        seal "gcpckms" {
          project     = "${gcp_project}"
          region      = "${gcp_region}"
          key_ring    = "${key_ring}"
          crypto_key  = "${crypto_key}"
        }
        replication {
          resolver_discover_servers = false
        } 

# Vault UI
ui:
  enabled: false
  serviceType: "LoadBalancer"
  # serviceNodePort: null
  externalPort: 8200
