scaleway-demo-chatbot
=====================

Simple first demo of a Chatbot based on Kapsule + L4 + Ollama

Setup
-----

1) **Deploy infrastructure using terraform**


```
terraform init && terraform apply -auto-approve
```

Needed environment variables:

```
SCW_ACCESS_KEY
SCW_SECRET_KEY
SCW_DEFAULT_ORGANIZATION_ID
SCW_DEFAULT_PROJECT_ID
```

NB: the infrastructure will be deployed on FR-PAR/FR-PAR-2

Sample output:

```
Outputs:

lb_ip = "X.X.X.X"
```

2) **Collect resulting IP address for LB and create a DNS entry**

Example using Scaleway CLI and a Scaleway Managed DNS:

```
scw dns record add my-domain.fr type=A name=chatbot data=X.X.X.X ttl=60
```

3) **Add LB IP and DNS entry in deployment**

Edit `deploy.yaml` and insert the value for the LB IP and DNS entry:

```
(...)
        command:
        - caddy
        args:
        - reverse-proxy
        - -f
        - <your-dns-entry>:443
        - -t
        - chatbot:8080
(...)
  - name: https
    port: 443
    protocol: TCP
    targetPort: 443
  loadBalancerIP: <your-lb-ip>
  selector:
    app: caddy
(...)
```

4) **Deploy the chatbot in Kapsule**

We will use the created `kubeconfig.yaml` file to access the cluster, but you can also use the console to generate this file. 

On linux or Mac OSX
```
export KUBECONFIG=kubeconfig.yaml
```

On windows
```
set KUBECONFIG=kubeconfig.yaml
```

Deploy the chat bot:

```
kubectl apply -f deploy.yaml
```


Credits
-------

The initial code is built via [create-llama](https://www.npmjs.com/package/create-llama). The frontend part is available in the folder `frontend` but has been compiled as a static JS+HTML and integrated in the FastAPI chatbot via root mount.
