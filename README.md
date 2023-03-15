# ProjetInfo

Veuillez mettre le dossier contenant la ou les maps voulant être tester dans le dossier "Projet info" et de bien signifier dans les paramètres quelle map vous voulez utiliser.
Les algorithmes ont pour noms "dijkstraAlgo" et "aStarAlgo", elles ont toutes les deux les mêmes paramètres étant (fichier::String,coordDébut::Tuple{Int64,Int64},coordFin::Tuple{Int64,Int64})

Exemple : Nous souhaitons utiliser l'algorithme A* avec la map "arena.map" dans le dossier "dao-map", en ayant pour coordonnées de départ (5,5) et de départ (45,45),
nous devons donc écrire "aStarAlgo("dao-map\\arena.map",(5,5),(45,45))"
