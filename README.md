
Command to run to setup cluster initially
- kubectl exec -it redis-cluster-xxxxxxx-xxxxx  -- redis-cli --cluster create --cluster-replicas 1 $(kubectl get pods -l app=redis-cluster -o jsonpath='{range.items[*]}{.status.podIP}:6379 ')

Get ip of pods
- kubectl get pods -o wide

Commands to run afterwards to add new nodes to cluster

Cluster meet IP address and port
- kubectl exec -it redis-cluster-xxxxxxx-xxxxx  -- redis-cli cluster meet (node ip) (node port)

Cluster nodes
- kubectl exec -it redis-cluster-xxxxxxx-xxxxx  -- redis-cli cluster nodes

Cluster replicate node id
- kubectl exec -it redis-cluster-xxxxxxx-xxxxx  -- redis-cli cluster replicate (node id of master to replicate from)

Remove failed node
- kubectl exec -it redis-cluster-xxxxxxx-xxxxx  -- redis-cli cluster forget (node id of node to remove)
