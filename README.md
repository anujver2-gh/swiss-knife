# swiss-knife
Docker image having almost every tool and k8s manifests to deploy


swiss-knife-cisco : based on 'containers.cisco.com/sto-ccc-cloud9/hardened_ubuntu:22.04'

swiss-knife-ubuntu : based on public 'ubuntu:22.04'

# Mockserver

*mockserver* : Mockservcer based on https://github.com/mock-server/mockserver

Docker image :

 `114040874283.dkr.ecr.cn-northwest-1.amazonaws.com.cn/china/generic:mockserver`

## To add new routes and mock responses

Edit the configmap `expectationInitialiser.json` to add new routes and responses.