### Storing secrets
It is recommended to use [external secrets](https://github.com/external-secrets/external-secrets), [helm secrets](https://github.com/jkroepke/helm-secrets) or a similar tool to store secrets encrypted and use them in the values file.

#### External secrets

ExternalSecrets integration https://external-secrets.io/

Prerequisites: 
1. Install ExternalSecrets 

Preferred option is to use helm chart: https://external-secrets.io/v0.8.1/introduction/getting-started/

2. Create secret in cloud provider vault

Create secret in cloud provider (e.g. AWS ParameterStore) with preferred name, e.g. `/prod/umbrella/secrets`. The same name must be used in ExternalSecret manifest `kind: ExternalSecret` `remoteRef.key`. Secret values must be in JSON format, e.g `{"AWS_ACCESS_KEY_ID": "MySecretKeyId", "AWS_SECRET_ACCESS_KEY": "MySecretAccessKey"}`. Single cloud provider secret can contain many key,value pairs.

3. Ensure Kubernetes cluster has permissions to get secrets from cloud provider vault.

4. Apply SecretStore and ExternalSecret manifests

SecretStore is used to connect to cloud provider secrets, e.g. https://external-secrets.io/v0.8.1/provider/aws-secrets-manager/

ExternalSecret is used to generate Kubernetes Secret fetched from cloud provider secret. Generated Kubernetes Secret will be used further by k8s-metrics-collector after upgrade/installation.

External-secrets example for AWS ParameterStore integration:

```yaml
cat <<EOF | kubectl apply -f -
 apiVersion: external-secrets.io/v1beta1
 kind: SecretStore
 metadata:
   name: umbrella
   namespace: monitoring
 spec:
   provider:
     aws:
       service: ParameterStore                  # cloud provider name
       # define a specific role to limit access
       # to certain secrets.
       # role is a optional field that
       # can be omitted for test purposes
       region: us-east-1
---
 apiVersion: external-secrets.io/v1beta1
 kind: ExternalSecret
 metadata:
   name: umbrella
   namespace: monitoring
 spec:
   refreshInterval: 1h                          # rate secrets sync interval
   secretStoreRef:
     kind: SecretStore
     name: umbrella                             # name of SecretStore
   target:
    # Kubernetes Secret will be generated with target name
    # Consider the same name is used in chart k8s-metrics-collector in environmentExternalSecrets.name 
     name: umbrella-cost-secrets                # Kubernetes Secret name to be created
     creationPolicy: Owner
   data:
   - secretKey: AWS_ACCESS_KEY_ID               # Kubernetes Secret key name 
     remoteRef:
       key: /prod/umbrella/secrets              # secret name created in cloud vault
       # secrets must be stored in JSON format in cloud provider vault
       # for this secret example  {"AWS_ACCESS_KEY_ID": "MySecretKeyId", "AWS_SECRET_ACCESS_KEY": "MySecretAccessKey"} 
       # value MySecretKeyId will be fetched based on key AWS_ACCESS_KEY_ID and added to Kubernetes Secret
       property: AWS_ACCESS_KEY_ID              
   - secretKey: AWS_SECRET_ACCESS_KEY
     remoteRef:
       key: /prod/umbrella/secrets
       property: AWS_SECRET_ACCESS_KEY
EOF
```

5. In chart k8s-metrics-collector set `environmentExternalSecrets.enabled` to true

4. Install/Upgrade k8s-metrics-collector helm chart 
```
helm upgrade --install --create-namespace -n monitoring \
k8s-metrics-collector anodot-cost/k8s-metrics-collector -f values.yaml
```