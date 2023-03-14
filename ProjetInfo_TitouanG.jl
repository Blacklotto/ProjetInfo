using Images, ImageMagick

#=@enum cout begin
    . = 1
    S = 5
    W = 8
end=#

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

mutable struct preced
    actuel::Node
    parent::Node

    function preced(n::Node) 
        x = new()
        x.actuel = n
        return x
    end
end

function voisin(mat::Matrix{Node},coord::Tuple{Int64,Int64})
    n = height(mat)
    m = width(mat)
    if(mat[coord[1],coord[2]].type != 'T')
        if(coord[1] >1)
            a = mat[coord[1]-1,coord[2]]
            if(coord[1] < n)
                b = mat[coord[1]+1,coord[2]]
                if(coord[2] > 1)
                    c = mat[coord[1],coord[2]-1]
                    if(coord[2] < m)
                        d = mat[coord[1],coord[2]+1]
                        return voisin = [a b c d]
                    else
                        return voisin = [a b c]
                    end
                else
                    if(coord[2] < m)
                        d = mat[coord[1],coord[2]+1]
                        return voisin = [a b d]
                    else
                        return voisin = [a b]
                    end
                end
            else
                if(coord[2] > 1)
                    c = mat[coord[1],coord[2]-1]
                    if(coord[2] < m)
                        d = mat[coord[1],coord[2]+1]
                        return voisin = [a c d]
                    else
                        return voisin = [a c]
                    end
                else
                    if(coord[2] < m)
                        d = mat[coord[1],coord[2]+1]
                        return voisin = [a  d]
                    else
                        return voisin = [a]
                    end
                end
            end
        else
            if(coord[1] < n)
                b = mat[coord[1]+1,coord[2]]
                if(coord[2] > 1)
                    c = mat[coord[1],coord[2]-1]
                    if(coord[2] < m)
                        d = mat[coord[1],coord[2]+1]
                        return voisin = [b c d]
                    else
                        return voisin = [b c]
                    end
                else
                    if(coord[2] < m)
                        d = mat[coord[1],coord[2]+1]
                        return voisin = [b d]
                    else
                        return voisin = [b]
                    end
                end
            else
                if(coord[2] > 1)
                    c = n[coord[1],coord[2]-1]
                    if(coord[2] < m)
                        d = n[coord[1],coord[2]+1]
                        return voisin = [c d]
                    else
                        return voisin = [c]
                    end
                else
                    if(coord[2] < m)
                        d = n[coord[1],coord[2]+1]
                        return voisin = [d]
                    else
                        return voisin = []
                    end
                end
            end
        end
    end
end

function fichier2Matrix(nomFichier::String)
    # Ouverture d'un fichier en lecture
    f::IOStream = open(nomFichier,"r")
    s::String = readline(f) #enleve la premiere ligne
    #println("The selectionned map is a(n) "*s)

    s = readline(f)
    sep = split(s," ")
    #println("Its height is "*sep[2])
    height::Int64 = parse(Int64,sep[2]) #def la hauteur de la map

    s = readline(f)
    sep2 = split(s," ")
    #println("Its width is "*sep2[2])
    width::Int64 = parse(Int64,sep2[2]) #def la longueur de la map

    #=tab::Vector{Int64} = parse.(Int64,split(s," ",keepempty = false)) # Segmentation de la ligne en plusieurs entiers, à stocker dans un tableau (qui ne contient ici qu'un entier)
    n::Int64 = tab[1]=#

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

function matrixNode2matPreced(matrix::Matrix{Node})
    n = height(matrix)
    m = width(matrix)
    C = Matrix{preced}(undef,n,m)

    for i in 1:n
        for j in 1:m
            C[i,j] = preced(matrix[i,j])
        end
    end

    return C
end

function matrix2Color(matrix::Matrix{Char},it::Int64)
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

    save("Images/test"*string(it)*".png",C)
    
    it+=1
    return (C,it)
end 

function modifmatrixCol(matrix::Matrix{RGB{Float64}},point::Tuple{Int64,Int64},coul::RGB{Float64},it::Int64)

    matrix[point[1],point[2]] = coul
    save("Images/test"*string(it)*".png",matrix)

    it+=1
    return (matrix,it)
end

function main(fichier::String,deb::Tuple{Int64,Int64},fin::Tuple{Int64,Int64})
   it::Int64 = 0
    #Crée le dossier Images vide, ou le détruit puis le crée si il existait déjà
        temp = readdir()
        for i in temp
            if(i == "Images")
                rm("Images", force=true, recursive=true)
            end
        end
    mkdir("Images")

    matrixInit = fichier2Matrix(fichier)
    matrix = matrix2matNode(matrixInit)
    #(matrixCol,it) = matrix2Color(matrixInit,it)

    #=println("Where do you want to start ? Position of the x-axis :")
    tmp = readline()
    debx::Int64 = parse(Int64,tmp)
    println("Where do you want to start ? Position of the y-axis :")
    deby::Int64 = parse(Int64,readline())
    (matrixCol,it) = modifmatrixCol(matrixCol,(debx,deby),RGB(1.0,0.0,0.0),it)
    

    println("Where do you want to end ? Position of the x-axis :")
    finx::Int64 = parse(Int64,readline())
    println("Where do you want to end ? Position of the y-axis :")
    finy::Int64 = parse(Int64,readline())
    (matrixCol,it) = modifmatrixCol(matrixCol,(finx,finy),RGB(0.0,0.0,1.0),it)=#

    dijkstraAlgo(deb,fin,matrix)

end

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

function maj_distDij(parent::Node,mat::Matrix{Node},pos::Tuple{Int64,Int64},pre::Matrix{preced})
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

function maj_distAStar(parent::Node,mat::Matrix{Node},pos::Tuple{Int64,Int64},pre::Matrix{preced},nodeF::Node)
    enfant = mat[pos[1],pos[2]]
    if(enfant.cost == -1 )
        if(enfant.type == '.' || enfant.type == 'G')
            mat[pos[1],pos[2]].heuristique = maj_heurist(mat[pos[1],pos[2]],nodeF.pos)
            mat[pos[1],pos[2]].cost = parent.cost + 1 
            pre[enfant.pos[1],enfant.pos[2]].parent = parent                     

        elseif(enfant.type == 'S')
            mat[pos[1],pos[2]].heuristique = maj_heurist(mat[pos[1],pos[2]],nodeF.pos)
            mat[pos[1],pos[2]].cost = parent.cost + 5
            pre[enfant.pos[1],enfant.pos[2]].parent = parent                      
            
        elseif(enfant.type == 'W')
            mat[pos[1],pos[2]].heuristique = maj_heurist(mat[pos[1],pos[2]],nodeF.pos)
            mat[pos[1],pos[2]].cost = parent.cost + 8 
            pre[enfant.pos[1],enfant.pos[2]].parent = parent                      
        
        end
    else
        if(enfant.type == '.' || enfant.type == 'G')
            if(enfant.cost > parent.cost + 1)
                mat[pos[1],pos[2]].heuristique = maj_heurist(mat[pos[1],pos[2]],nodeF.pos)
                mat[pos[1],pos[2]].cost = parent.cost + 1 
                pre[enfant.pos[1],enfant.pos[2]].parent = parent                      
            end
        elseif(enfant.type == 'S')
            if(enfant.cost > parent.cost + 5)
                mat[pos[1],pos[2]].heuristique = maj_heurist(mat[pos[1],pos[2]],nodeF.pos)
                mat[pos[1],pos[2]].cost = parent.cost + 5 
                pre[enfant.pos[1],enfant.pos[2]].parent = parent                      
            end
        elseif(enfant.type == 'W')
            if(enfant.cost > parent.cost + 8)
                mat[pos[1],pos[2]].heuristique = maj_heurist(mat[pos[1],pos[2]],nodeF.pos)
                mat[pos[1],pos[2]].cost = parent.cost + 8 
                pre[enfant.pos[1],enfant.pos[2]].parent = parent                      
                
            end
        end
    end
    
 
    return mat

end

function maj_heurist(node::Node,posFin::Tuple{Int64,Int64})
    return sqrt((posFin[1] - node.pos[1]) * (posFin[1] - node.pos[1]) + (posFin[2] - node.pos[2]) * (posFin[2] - node.pos[2]))
end

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

function init(deb::Tuple{Int64,Int64},matrix::Matrix{Node})
    matrix[deb[1],deb[2]].cost = 0
    matrix[deb[1],deb[2]].heuristique = 0
    matrix[deb[1],deb[2]].boolvisite = true
end

function testBool(mat::Matrix{Node})
    bool::Bool = true
    for i in mat
        bool = i.boolvisite && bool 
    end
    return bool
end

function findPreced(mat::Matrix{preced},node::Node)
    for i in mat
        if i.actuel == node
            return i
        end
    end
end

function dijkstraAlgo(fichier::String,deb::Tuple{Int64,Int64},fin::Tuple{Int64,Int64})

    temp = readdir()
    for i in temp
        if(i == "Images")
            rm("Images", force=true, recursive=true)
        end
    end
    mkdir("Images")

    matrix = matrix2matNode(fichier2Matrix(fichier))

    n = height(matrix)
    m = width(matrix)
    NodeD = matrix[deb[1],deb[2]]
    NodeF = matrix[fin[1],fin[2]]
    pre = matrixNode2matPreced(matrix)
    itbis::Int64 = 0
    

    if(!NodeD.boolvisitable || !NodeF.boolvisitable )
        println("L'algorithme ne peut pas se lancer : Le point initial ou le point final ne sont pas atteignable !")
    else
        init(deb,matrix)
        cheminpos::Bool = true

        Q = Set(matrix)
        B = Set([])

        it::Int64 = 10
        bool = false

        while length(Q) != 0 && !bool
            tmp::Node = minCout(Q)
            itbis +=1
            if(tmp.cost != -1)
                B = union(B,[tmp])
                #it -= 1

                #=println("La node choisit est :")
                println(tmp)
                println("Ses voisins sont : ")
                println(voisin(matrix,tmp.pos))
                println("")=#

                for i in voisin(matrix,tmp.pos)
                    #println("Voici la node prise avant la maj :")
                    #println(i)
                    matrix = maj_distDij(tmp,matrix,i.pos,pre)
                    #println("Voici la node prise après la maj :")
                    #println(i)
                end
                #=println("")
                println("Voici les nodes après la maj :")
                println(voisin(matrix,tmp.pos))
                println("")=#

                bool = testBool(voisin(matrix,NodeF.pos))

                #=if(bool)
                    print(voisin(matrix,NodeF.pos))
                else
                    println(voisin(matrix,NodeF.pos))
                end=#
                Q = setdiff(Set(matrix),B)
                #println("Il reste tant de nodes : ")
                #println(length(Q))

                #=if(it == 0)
                    println("Continue ? 1/2")
                    yolo = parse(Int64,readline())
                    it = 10
                    if(yolo == "2")
                        bool = true
                    end
                end=#
            else
                bool = true
                println("Il n'y a pas de chemin possible entre les deux coordonnées saisies !")
                cheminpos = false
                break
            end

        end

        #println("La node finale est : ")
        #println(NodeF)

        ################################################################################################################################################################################################################
        ################################################################################################################################################################################################################

        if(cheminpos)
            A = Set([])
            s::Node = NodeF
            i::Int64 = 0
            while s != NodeD
                i += 1
                A = union(A,[s])
                s = findPreced(pre,s).parent
            end

            A = union(A,[NodeD])
            println("Le poids entre le début en "*string(deb)*" et la fin en "*string(fin)*" est "*string(NodeF.cost))
            print("L'algorithme a évalué ")
            print(itbis)
            print(" état.s")
            #println(A)
        end
    end

end 

function aStar(fichier::String,deb::Tuple{Int64,Int64},fin::Tuple{Int64,Int64})

    temp = readdir()
    for i in temp
        if(i == "Images")
            rm("Images", force=true, recursive=true)
        end
    end
    mkdir("Images")

    matrix = matrix2matNode(fichier2Matrix(fichier))

    n = height(matrix)
    m = width(matrix)
    NodeD = matrix[deb[1],deb[2]]
    NodeF = matrix[fin[1],fin[2]]
    pre = matrixNode2matPreced(matrix)
    itbis::Int64 = 0
    

    if(!NodeD.boolvisitable || !NodeF.boolvisitable )
        println("L'algorithme ne peut pas se lancer : Le point initial ou le point final ne sont pas atteignable !")
    else
        init(deb,matrix)
        cheminpos::Bool = true

        Q = Set(matrix)
        B = Set([])

        it::Int64 = 10
        bool = false

        while length(Q) != 0 && !NodeF.boolvisite
            tmp::Node = minHeur(Q)
            itbis +=1
            
            if(tmp.cost != -1)
                B = union(B,[tmp])
                #=it -= 1

                println("La node choisit est :")
                println(tmp)
                println("Ses voisins sont : ")
                println(voisin(matrix,tmp.pos))
                println("")=#

                for i in voisin(matrix,tmp.pos)
                    #println("Voici la node prise avant la maj :")
                    #println(i)
                    matrix = maj_distAStar(tmp,matrix,i.pos,pre,NodeF)
                    #println("Voici la node prise après la maj :")
                    #println(i)
                    #println("")
                end
                #println("Voici les nodes après la maj :")
                #println(voisin(matrix,tmp.pos))
                #println("")

                #bool = testBool(voisin(matrix,NodeF.pos))

                #=if(bool)
                    print(voisin(matrix,NodeF.pos))
                else
                    println(voisin(matrix,NodeF.pos))
                end=#
                Q = setdiff(Set(matrix),B)
                #println("Il reste tant de nodes : ")
                #println(length(Q))

                #=if(it == 0)
                    println("Continue ? 1/2")
                    yolo = parse(Int64,readline())
                    it = 10
                    if(yolo == "2")
                        bool = true
                    end
                end=#
            else
                bool = true
                println("Il n'y a pas de chemin possible entre les deux coordonnées saisies !")
                cheminpos = false
                break
            end

        end

        #println("La node finale est : ")
        #println(NodeF)

        ################################################################################################################################################################################################################
        ################################################################################################################################################################################################################

        if(cheminpos)
            A = Set([])
            s::Node = NodeF
            i::Int64 = 0
            while s != NodeD
                i += 1
                A = union(A,[s])
                s = findPreced(pre,s).parent
            end

            A = union(A,[NodeD])
            println("Le poids entre le début en "*string(deb)*" et la fin en "*string(fin)*" est "*string(NodeF.cost))
            print("L'algorithme a évalué ")
            print(itbis)
            print(" état.s")
            #println(A)
        end
    end
end