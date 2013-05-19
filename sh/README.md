Service 'centrallog' : https://cacoo.com/diagrams/mTm79GTjCk8HGxsz

Centralized :
+ depends : stdlevel
+ broker -> indexer
+ indexer -> storagesearch
+ indexer -> webui
+ shipper -> broker
+ shipper -> webui

Distributed :
+ depends : stdlevel
+ shipper -> broker (Centralized)

