Service 'centrallog' : https://cacoo.com/diagrams/mTm79GTjCk8HGxsz

VERSION in BUILDING !!!

Centralized :
+ depends : stdlevel
+ broker => indexer => storagesearch => webui
+   /\                         /\        /\
+   ||                         ||        ||
+ shipper                    shipper   shipper

Distributed :
+ depends : stdlevel
+ shipper => broker (Centralized)

