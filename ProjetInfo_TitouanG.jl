using Images, ImageMagick


#Une structure Noeud dont ses valeurs peuvent changer
mutable struct Node
    pos::Tuple{Int64,Int64}
    type::Char
    cost::Float64
    boolvisitable::Bool
    boolvisite::Bool
    heuristique::Float64
    function Node()
        x = new()
        x.cost = -1
        x.heuristique = -1
        return x
    end   
    function Node(char::Char,pos::Tuple{Int64,Int64}) 
        x = new()
        if(char == 'T' || char == '@'|| char == 'O')
            x.boolvisitable = false
        else
            x.boolvisitable = true
        end    
        x.pos = pos
        x.type = char
        x.boolvisite = false
        x.cost = -1
        x.heuristique = -1
        return x
    end
    
end

#Une structure parent qui permet d'avoir acces facilement au noeud parent du noeud actuel
mutable struct parent
    actuel::Node
    parent::Node

    function parent(n::Node) 
        x = new()
        x.actuel = n
        return x
    end
end

#Une fonction permettant de transformer un fichier .map en une matrice de caractères 
function fichier2Matrix(nomFichier::String)
    # Ouverture d'un fichier en lecture
    f::IOStream = open(nomFichier,"r")
    s::String = readline(f) #enleve la premiere ligne

    s = readline(f)
    sep = split(s," ")

    height::Int64 = parse(Int64,sep[2]) #def la hauteur de la map

    s = readline(f)
    sep2 = split(s," ")
    width::Int64 = parse(Int64,sep2[2]) #def la longueur de la map

    # Allocation mémoire pour le distancier
    C = Matrix{Char}(undef,height,width)
    s = readline(f) #enleve le "map" 
    # Lecture du distancier
    for i in 1:height
        s = readline(f)
        tab = split(s,"")
        for j in 1:width
            C[i,j] = only(tab[j])
        end
    end

    # Fermeture du fichier
    close(f)

    println()
    # Retour de la matrice de coûts
    return C
end

#=Une fonction permettant de transformer une matrice de caractères en une matrice de noeud, 
 chaque noeud étant initialisé avec son type via le caractère choisi et ses coordonnées via les coordonnées du caractère dans sa matrice=#
function matrix2matNode(matrix::Matrix{Char})
    n = height(matrix)
    m = width(matrix)
    C = Matrix{Node}(undef,n,m)

    for i in 1:n
        for j in 1:m
            C[i,j] = Node(matrix[i,j],(i,j))
        end
    end

    return C

end
#Une fonction permettant de transformer une matrice de noeuds en une matrice de Parent, chaque parent étant initialisé avec son noeud actuel via le noeud choisi  
function matrixNode2matParent(matrix::Matrix{Node})
    n = height(matrix)
    m = width(matrix)
    C = Matrix{parent}(undef,n,m)

    for i in 1:n
        for j in 1:m
            C[i,j] = parent(matrix[i,j])
        end
    end

    return C
end
#=Une fonction permettant d'initialiser d'une matrice en couleur à partir une matrice de caractères,
 associant le vert clair avec le 'T' ('T' pour "Tree", donc un arbre), le blanc avec le '.' ou 'G' ('G' pour "Ground", donc un terrain normal),
 le noir avec le '@' ou 'O' ('O' pour "Out of Bound" donc du vide ne pouvant pas être selectionné), le vert foncé avec le 'S' ('S' pour "Swamp", donc un marécage)
 et finalement le bleu foncé avec 'W' ('W' pour "Water", donc de l'eau), de plus les noeuds choisis en tant que début et fin sont respectivement associé au rouge et bleu =# 
function initMatrix2Color(matrix::Matrix{Char},posD::Tuple{Int64,Int64}, posF::Tuple{Int64,Int64})
    n = height(matrix)
    m = width(matrix)
    C = Matrix{RGB{Float64}}(undef,n,m)

    for i in 1:n
        for j in 1:m
            if(matrix[i,j] == '.' || matrix[i,j] == 'G' )
                C[i,j] = RGB(1.0,1.0,1.0)
            elseif(matrix[i,j] == 'T')
                C[i,j] = RGB(0.0,1.0,0.0)
            elseif(matrix[i,j] == 'S')
                C[i,j] = RGB(0.0,0.25,0.0)
            elseif(matrix[i,j] == 'W')
                C[i,j] = RGB(0.0,0.6,1.0)
            elseif(matrix[i,j] == '@' || matrix[i,j] == 'O')
                C[i,j] = RGB(0.0,0.0,0.0)
            end
        end
    end

    C[posD[1],posD[2]] = RGB(1,0,0)
    C[posF[1],posF[2]] = RGB(0,0,1)

    save("Images/Deb.png",C)
    
    return C
end 
#Une fonction permettant de modifier la couleur aux coordonnées passé en paramètre dans la matrice en couleur passé elle aussi en paramètre  
function modifmatrixCol(matrix::Matrix{RGB{Float64}},point::Tuple{Int64,Int64},coul::RGB{Float64},NodeD::Node,NodeF::Node)
    if(point != NodeD.pos && point != NodeF.pos)
        matrix[point[1],point[2]] = coul
    end
    return matrix
end

#Une fonction qui détermine les voisins du noeud situé en coordonnées coord dans la matrice mat 
function voisin(mat::Matrix{Node},coord::Tuple{Int64,Int64})
    n = height(mat)
    m = width(mat)
    if(mat[coord[1],coord[2]].type != 'T')
        if(coord[1] >1 && mat[coord[1]-1,coord[2]].type !='T')
            a = mat[coord[1]-1,coord[2]]
            if(coord[1] < n && mat[coord[1]+1,coord[2]].type !='T')
                b = mat[coord[1]+1,coord[2]]
                if(coord[2] > 1 && mat[coord[1],coord[2]-1].type !='T')
                    c = mat[coord[1],coord[2]-1]
                    if(coord[2] < m && mat[coord[1],coord[2]+1].type !='T')
                        d = mat[coord[1],coord[2]+1]
                        return voisin = [a b c d]
                    else
                        return voisin = [a b c]
                    end
                else
                    if(coord[2] < m && mat[coord[1],coord[2]+1].type !='T')
                        d = mat[coord[1],coord[2]+1]
                        return voisin = [a b d]
                    else
                        return voisin = [a b]
                    end
                end
            else
                if(coord[2] > 1 && mat[coord[1],coord[2]-1].type !='T')
                    c = mat[coord[1],coord[2]-1]
                    if(coord[2] < m && mat[coord[1]-1,coord[2]+1].type !='T')
                        d = mat[coord[1],coord[2]+1]
                        return voisin = [a c d]
                    else
                        return voisin = [a c]
                    end
                else
                    if(coord[2] < m && mat[coord[1],coord[2]+1].type !='T')
                        d = mat[coord[1],coord[2]+1]
                        return voisin = [a  d]
                    else
                        return voisin = [a]
                    end
                end
            end
        else
            if(coord[1] < n && mat[coord[1]+1,coord[2]].type !='T')
                b = mat[coord[1]+1,coord[2]]
                if(coord[2] > 1 && mat[coord[1],coord[2]-1].type !='T')
                    c = mat[coord[1],coord[2]-1]
                    if(coord[2] < m && mat[coord[1],coord[2]+1].type !='T')
                        d = mat[coord[1],coord[2]+1]
                        return voisin = [b c d]
                    else
                        return voisin = [b c]
                    end
                else
                    if(coord[2] < m && mat[coord[1],coord[2]+1].type !='T')
                        d = mat[coord[1],coord[2]+1]
                        return voisin = [b d]
                    else
                        return voisin = [b]
                    end
                end
            else
                if(coord[2] > 1 && mat[coord[1],coord[2]-1].type !='T')
                    c = mat[coord[1],coord[2]-1]
                    if(coord[2] < m && mat[coord[1],coord[2]+1].type !='T')
                        d = mat[coord[1],coord[2]+1]
                        return voisin = [c d]
                    else
                        return voisin = [c]
                    end
                else
                    if(coord[2] < m && mat[coord[1],coord[2]+1].type !='T')
                        d = mat[coord[1],coord[2]+1]
                        return voisin = [d]
                    else
                        return voisin = []
                    end
                end
            end
        end
    end
end

#Une fonction qui détermine le noeud ayant le coût le plus faible parmis l'ensemble donné en paramètre
function minCout(mat::Set{Node})
    tmpbis::Bool = false
    tmp::Node = Node()
    
    for i in mat
        if(!tmpbis)
            if(i.cost >= 0 && i.type != 'T')
                tmp = i
                tmpbis = true
            end
        else
            if(i.cost >= 0 && i.type != 'T')
                if( tmp.cost > i.cost )
                  tmp = i
                end
            end
        end
    end
    tmp.boolvisite = true
    return tmp
end

#Une fonction qui met a jour le cout ainsi que le parent du noeud situé aux coordonnées donné en paramètre dans la matrice de noeuds donnée en paramètre
function maj_distDij(parent::Node,mat::Matrix{Node},pos::Tuple{Int64,Int64},pre::Matrix{parent})
    enfant = mat[pos[1],pos[2]]
    if(enfant.cost == -1 )
        if(enfant.type == '.' || enfant.type == 'G')
            
            mat[pos[1],pos[2]].cost = parent.cost + 1
            pre[enfant.pos[1],enfant.pos[2]].parent = parent                      

        elseif(enfant.type == 'S')
            
            mat[pos[1],pos[2]].cost = parent.cost + 5
            pre[enfant.pos[1],enfant.pos[2]].parent = parent                     
            
        elseif(enfant.type == 'W')

            mat[pos[1],pos[2]].cost = parent.cost + 8
            pre[enfant.pos[1],enfant.pos[2]].parent = parent                      
        
        end
    else
        if(enfant.type == '.' || enfant.type == 'G')
            if(enfant.cost > parent.cost + 1)
                mat[pos[1],pos[2]].cost = parent.cost + 1
                pre[enfant.pos[1],enfant.pos[2]].parent = parent                      
            end
        elseif(enfant.type == 'S')
            if(enfant.cost > parent.cost + 5)
                mat[pos[1],pos[2]].cost = parent.cost + 5
                pre[enfant.pos[1],enfant.pos[2]].parent = parent                      
            end
        elseif(enfant.type == 'W')
            if(enfant.cost > parent.cost + 8)
                mat[pos[1],pos[2]].cost = parent.cost + 8
                pre[enfant.pos[1],enfant.pos[2]].parent = parent                      
                
            end
        end
    end
    
 
    return mat

end

#Une fonction qui met a jour le cout, l'heuristique ainsi que le parent du noeud situé aux coordonnées donné en paramètre dans la matrice de noeuds donnée en paramètre
function maj_distAStar(parent::Node,mat::Matrix{Node},pos::Tuple{Int64,Int64},pre::Matrix{parent},nodeF::Node)
    enfant = mat[pos[1],pos[2]]
    if(enfant.cost == -1 )
        if(enfant.type == '.' || enfant.type == 'G')
            mat[pos[1],pos[2]].heuristique = heurist(mat[pos[1],pos[2]],nodeF.pos)
            mat[pos[1],pos[2]].cost = parent.cost + 1 
            pre[enfant.pos[1],enfant.pos[2]].parent = parent                     

        elseif(enfant.type == 'S')
            mat[pos[1],pos[2]].heuristique = heurist(mat[pos[1],pos[2]],nodeF.pos)
            mat[pos[1],pos[2]].cost = parent.cost + 5
            pre[enfant.pos[1],enfant.pos[2]].parent = parent                      
            
        elseif(enfant.type == 'W')
            mat[pos[1],pos[2]].heuristique = heurist(mat[pos[1],pos[2]],nodeF.pos)
            mat[pos[1],pos[2]].cost = parent.cost + 8 
            pre[enfant.pos[1],enfant.pos[2]].parent = parent                      
        
        end
    else
        if(enfant.type == '.' || enfant.type == 'G')
            if(enfant.cost > parent.cost + 1)
                mat[pos[1],pos[2]].heuristique = heurist(mat[pos[1],pos[2]],nodeF.pos)
                mat[pos[1],pos[2]].cost = parent.cost + 1 
                pre[enfant.pos[1],enfant.pos[2]].parent = parent                      
            end
        elseif(enfant.type == 'S')
            if(enfant.cost > parent.cost + 5)
                mat[pos[1],pos[2]].heuristique = heurist(mat[pos[1],pos[2]],nodeF.pos)
                mat[pos[1],pos[2]].cost = parent.cost + 5 
                pre[enfant.pos[1],enfant.pos[2]].parent = parent                      
            end
        elseif(enfant.type == 'W')
            if(enfant.cost > parent.cost + 8)
                mat[pos[1],pos[2]].heuristique = heurist(mat[pos[1],pos[2]],nodeF.pos)
                mat[pos[1],pos[2]].cost = parent.cost + 8 
                pre[enfant.pos[1],enfant.pos[2]].parent = parent                      
                
            end
        end
    end
    
 
    return mat

end

#Une fonction qui calcule l'heuristique du noeud donné en paramètre avec la position du noeud de fin
function heurist(node::Node,posFin::Tuple{Int64,Int64})
    return sqrt((posFin[1] - node.pos[1]) * (posFin[1] - node.pos[1])) + sqrt((posFin[2] - node.pos[2]) * (posFin[2] - node.pos[2]))
end

#Une fonction qui détermine le noeud ayant l'heuristique la plus faible parmis l'ensemble donné en paramètre
function minHeur(set::Set{Node})
    tmpbis::Bool = false
    tmp::Node = Node()
    
    for i in set
        if(!tmpbis)
            if(i.heuristique >= 0 && i.type != 'T')
                tmp = i
                tmpbis = true
            end
        else
            if(i.heuristique >= 0 && i.type != 'T')
                if( tmp.heuristique > i.heuristique )
                  tmp = i
                end
            end
        end
    end
    tmp.boolvisite = true
    return tmp
end

#Une fonction qui initialise le cout et l'heuristique a 0 ainsi que le booléen déterminant si le programme a déjà visité ce neud a vrai 
function init(deb::Tuple{Int64,Int64},matrix::Matrix{Node})
    matrix[deb[1],deb[2]].cost = 0
    matrix[deb[1],deb[2]].heuristique = 0
    matrix[deb[1],deb[2]].boolvisite = true
end

#Une fonction qui test si les noeuds de la matrice donnée en paramètre sont visités ou pas
function testBool(mat::Matrix{Node})
    bool::Bool = true
    for i in mat
        bool = i.boolvisite && bool 
    end
    return bool
end

#Une fonction qui cherche le parent de la node donné en paramètre dans la matrice des parents donné en paramètre
function findParent(mat::Matrix{parent},node::Node)
    for i in mat
        if i.actuel == node
            return i.parent
        end
    end
end

#Une fonction modifiant la matrice en couleur en mettant le trajet déterminé par l'algorithme choisi en gris (on laisse les noeuds de départ et de fin dans leurs couleurs)
function affichChemin(set::Set{Any},matrix::Matrix{RGB{Float64}},NodeD::Node,NodeF::Node)
    for i in set
        matrix = modifmatrixCol(matrix,i.pos,RGB(0.5,0.5,0.5),NodeD,NodeF) 
    end
    save("Images/TrajetOptim.png",matrix)
end

#L'algorithme Dijkstra demandé pour le projet
function dijkstraAlgo(fichier::String,deb::Tuple{Int64,Int64},fin::Tuple{Int64,Int64})

    #=L'algorithme regarde s'il existe un dossier "Images", et si c'est le cas il le supprime. 
     Cela évite d'avoir des images mélangées si plusieurs algorithmes sont lancés les uns a la suite des autres=#
    temp = readdir()
    for i in temp
        if(i == "Images")
            rm("Images", force=true, recursive=true)
        end
    end
    mkdir("Images")

    #Initialise la matrice de caractères, la matrice de noeuds, la matrice de parents et la matrice en couleur
    matrixInit = fichier2Matrix(fichier)
    matrix = matrix2matNode(matrixInit)
    pre = matrixNode2matParent(matrix)
    matrixCol = initMatrix2Color(matrixInit,deb, fin)

    #Initialise le noeud de début dans la matrice de noeuds
    init(deb,matrix)

    #Initialise les noeuds de début, de fin ainsi que le nombre d'états l'algorithme va évalué
    NodeD = matrix[deb[1],deb[2]]
    NodeF = matrix[fin[1],fin[2]]
    it::Int64 = 0

    #L'algorithme test si les noeuds de début et fin sont visitables, car il est évident que si ceux ci ne le sont pas alors il n'y aura pas de chemin possible entre eux
    if(!NodeD.boolvisitable || !NodeF.boolvisitable )
        println("L'algorithme ne peut pas se lancer : Le point initial ou le point final ne sont pas atteignable !")
    else

        #L'algorithme suppose ici que le chemin est possible et que les voisins du noeud de fin ne sont pas visite
        cheminpos::Bool = true
        boolVoisinsFvisite = false

        #L'algorithme initialise un ensemble contenant tous les noeuds de la matrice, ainsi qu'un ensemble contenant tous les noeuds visités 
        EnsembleNode = Set(matrix)
        EnsembleNodeVisite = Set([])

        #L'algorithme boucle tant que l'ensemble contenant tous les noeuds de la matrice n'est pas vide et que les voisins du noeud de fin n'ont pas été visité
        while length(EnsembleNode) != 0 && !boolVoisinsFvisite

            #L'algorithme choisit le noeud avec le coût le plus faible possible, et augmente son nombre d'évaluations d'état
            tmp::Node = minCout(EnsembleNode)
            it +=1

            #Si le noeud est un noeud possible, ainsi que son coût n'est pas négatif
            if(tmp.cost != -1)

                #L'algorithme ajoute le noeud choisit dans l'ensemble des noeuds qui ont été visité
                EnsembleNodeVisite = union(EnsembleNodeVisite,[tmp])

                #L'algorithme détermine les voisins du noeud choisit et met a jour leurs coûts et leurs parents
                for i in voisin(matrix,tmp.pos)
                   
                    matrix = maj_distDij(tmp,matrix,i.pos,pre)
                    
                end

                #L'algorithme détermine si tous les voisins du noeud de fin ont été visité durant cette boucle et redétermine l'ensemble des noeuds choisissables 
                boolVoisinsFvisite = testBool(voisin(matrix,NodeF.pos))
                EnsembleNode = setdiff(Set(matrix),EnsembleNodeVisite)
                
            else #=si le noeud n'est pas "possible", alors cela veut dire qu'il n'y a pas d'autre noeuds possible pouvant être selectionné 
                ainsi il n'y a pas de chemin possible entre le noeud de début et le noeud de fin=#
                boolVoisinsFvisite = true
                println("Il n'y a pas de chemin possible entre les deux coordonnées saisies !")
                cheminpos = false
                break
            end

        end

        #Le chemin est donc déterminé, il reste plus qu'a l'afficher, donner son coût et le nombre d'états évalué

        ################################################################################################################################################################################################################
        ################################################################################################################################################################################################################

        #Si le chemin entre le noeud de début et de fin est possible alors on initialise un ensemble contenant les noeuds du dit chemin optimal et l'algorithme y ajoute des noeuds via la matrice des parents
        if(cheminpos)
            CheminOpt = Set([])
            s::Node = NodeF
            while s != NodeD
                CheminOpt = union(CheminOpt,[s])
                s = findParent(pre,s)
            end
            CheminOpt = union(CheminOpt,[NodeD])

            #L'algorithme affiche le coût du chemin, le nombre d'état évalué et crée une image avec le chemin en gris
            println("Le coût du chemin entre le début en "*string(deb)*" et la fin en "*string(fin)*" est "*string(NodeF.cost))
            print("L'algorithme a évalué ")
            print(it)
            print(" état.s")
            affichChemin(CheminOpt,matrixCol,NodeD,NodeF)

        end
    end

end 

#L'algorithme A* demandé pour le projet
function aStarAlgo(fichier::String,deb::Tuple{Int64,Int64},fin::Tuple{Int64,Int64})

    #=L'algorithme regarde s'il existe un dossier "Images", et si c'est le cas il le supprime. 
     Cela évite d'avoir des images mélangées si plusieurs algorithmes sont lancés les uns a la suite des autres=#
    temp = readdir()
    for i in temp
        if(i == "Images")
            rm("Images", force=true, recursive=true)
        end
    end
    mkdir("Images")

    #Initialise la matrice de caractères, la matrice de noeuds, la matrice de parents et la matrice en couleur
    matrixInit = fichier2Matrix(fichier)
    matrix = matrix2matNode(matrixInit)
    pre = matrixNode2matParent(matrix)
    matrixCol = initMatrix2Color(matrixInit,deb, fin)
 
    #Initialise le noeud de début dans la matrice de noeuds
    init(deb,matrix)
 
    #Initialise les noeuds de début, de fin ainsi que le nombre d'états l'algorithme va évalué
    NodeD = matrix[deb[1],deb[2]]
    NodeF = matrix[fin[1],fin[2]]
    it::Int64 = 0

    #L'algorithme test si les noeuds de début et fin sont visitables, car il est évident que si ceux ci ne le sont pas alors il n'y aura pas de chemin possible entre eux
    if(!NodeD.boolvisitable || !NodeF.boolvisitable )
        println("L'algorithme ne peut pas se lancer : Le point initial ou le point final ne sont pas atteignable !")
    else
        #L'algorithme suppose ici que le chemin est possible
        cheminpos::Bool = true


        #L'algorithme initialise un ensemble contenant tous les noeuds de la matrice, ainsi qu'un ensemble contenant tous les noeuds visités 
        EnsembleNode = Set(matrix)
        EnsembleNodeVisite = Set([])

        #L'algorithme boucle tant que l'ensemble contenant tous les noeuds de la matrice n'est pas vide et que le noeud de fin n'a pas été visité
        while length(EnsembleNode) != 0 && !NodeF.boolvisite

            #L'algorithme choisit le noeud avec l'heuristique la plus faible possible, et augmente son nombre d'évaluations d'état
            tmp::Node = minHeur(EnsembleNode)
            it +=1
            
            #Si le noeud est un noeud possible, ainsi que son coût n'est pas négatif
            if(tmp.cost != -1)

                #L'algorithme ajoute le noeud choisit dans l'ensemble des noeuds qui ont été visité
                EnsembleNodeVisite = union(EnsembleNodeVisite,[tmp])
                
                for i in voisin(matrix,tmp.pos)
                    
                    #L'algorithme détermine les voisins du noeud choisit et met a jour leurs coûts, leurs heuristiques et leurs parents
                    matrix = maj_distAStar(tmp,matrix,i.pos,pre,NodeF)
                   
                end
               
                #L'algorithme redétermine l'ensemble des noeuds choisissables 
                EnsembleNode = setdiff(Set(matrix),EnsembleNodeVisite)
              
            else #=si le noeud n'est pas "possible", alors cela veut dire qu'il n'y a pas d'autre noeuds possible pouvant être selectionné 
                ainsi il n'y a pas de chemin possible entre le noeud de début et le noeud de fin=#
                println("Il n'y a pas de chemin possible entre les deux coordonnées saisies !")
                cheminpos = false
                break
            end

        end

        #Le chemin est donc déterminé, il reste plus qu'a l'afficher, donner son coût et le nombre d'états évalué

        ################################################################################################################################################################################################################
        ################################################################################################################################################################################################################

        #Si le chemin entre le noeud de début et de fin est possible alors on initialise un ensemble contenant les noeuds du dit chemin optimal et l'algorithme y ajoute des noeuds via la matrice des parents
        if(cheminpos)
            CheminOpt = Set([])
            s::Node = NodeF
            while s != NodeD
                CheminOpt = union(CheminOpt,[s])
                s = findParent(pre,s)
            end
            CheminOpt = union(CheminOpt,[NodeD])

            #L'algorithme affiche le coût du chemin, le nombre d'état évalué et crée une image avec le chemin en gris
            println("Le poids entre le début en "*string(deb)*" et la fin en "*string(fin)*" est "*string(NodeF.cost))
            print("L'algorithme a évalué ")
            print(it)
            print(" état.s")
            
            affichChemin(CheminOpt,matrixCol,NodeD,NodeF)

        end
    end
end