using Images, ImageMagick

#=@enum cout begin
    . = 1
    S = 5
    W = 8
end=#

mutable struct Node
    pos::Tuple{Int64,Int64}
    type::Char
    cost::Int64
    boolvisitable::Bool
    boolvisite::Bool
    Node() = new()
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
    println("The selectionned map is a(n) "*s)

    s = readline(f)
    sep = split(s," ")
    println("Its height is "*sep[2])
    height::Int64 = parse(Int64,sep[2]) #def la hauteur de la map

    s = readline(f)
    sep2 = split(s," ")
    println("Its width is "*sep2[2])
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
        for i in 1:length(temp)
            if(temp[i] == "Images")
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

    dijkstraAlgo((5,3),(10,3),matrix)

end

function minCout(mat::Set{Node})
    n::Int64 = length(mat)
    tmpbis::Bool = false
    tmp::Node = Node()
    for i in mat
        if(!tmpbis)
            if(i.cost >= 0 && i.type != 'T')
                tmp = i
            end
        else
            if(i.cost >= 0 && i.type != 'T')
                if( tmp.cost > i.cost )
                  tmp = i
                end
            end
        end
    end
    return tmp
end

function maj_dist(parent::Node,mat::Matrix{Node},pos::Tuple{Int64,Int64},pre::Matrix{preced})
    enfant = mat[pos[1],pos[2]]
    if(enfant.cost == -1)
        if(enfant.type == '.' || enfant.type == 'G')
            
            mat[pos[1],pos[2]].cost = parent.cost + 1
            pre[enfant.pos[1],enfant.pos[2]].parent = parent                      #warning, pas fini

        elseif(enfant.type == 'S')
            
            mat[pos[1],pos[2]].cost = parent.cost + 5
            pre[enfant.pos[1],enfant.pos[2]].parent = parent                      #warning, pas fini
            
        elseif(enfant.type == 'W')

            mat[pos[1],pos[2]].cost = parent.cost + 8
            pre[enfant.pos[1],enfant.pos[2]].parent = parent                      #warning, pas fini
        
        end
    else
        if(enfant.type == '.' || enfant.type == 'G')
            if(enfant.cost > parent.cost + 1)
                mat[pos[1],pos[2]].cost = parent.cost + 1
                pre[enfant.pos[1],enfant.pos[2]].parent = parent                      #warning, pas fini
            end
        elseif(enfant.type == 'S')
            if(enfant.cost > parent.cost + 5)
                mat[pos[1],pos[2]].cost = parent.cost + 5
                pre[enfant.pos[1],enfant.pos[2]].parent = parent                      #warning, pas fini
            end
        elseif(enfant.type == 'W')
            if(enfant.cost > parent.cost + 8)
                mat[pos[1],pos[2]].cost = parent.cost + 8
                pre[enfant.pos[1],enfant.pos[2]].parent = parent                      #warning, pas fini
                
            end
        end
    end
    mat[pos[1],pos[2]].boolvisite = true
 
    return mat

end

function init(deb::Tuple{Int64,Int64},matrix::Matrix{Node})
    matrix[deb[1],deb[2]].cost = 0
    matrix[deb[1],deb[2]].boolvisite = true
end



function dijkstraAlgo(deb::Tuple{Int64,Int64},fin::Tuple{Int64,Int64},matrix::Matrix{Node})
    n = height(matrix)
    m = width(matrix)
    NodeD = matrix[deb[1],deb[2]]
    NodeF = matrix[fin[1],fin[2]]
    pre = matrixNode2matPreced(matrix)

    if(!NodeD.boolvisitable || !NodeF.boolvisitable )
        return "L'algorithme ne peut pas se lancer : Le point initial ou le point final ne sont pas atteignable !"
    else
        init(deb,matrix)

        Q = Set(matrix)
        

        while length(Q) != 0 || !bool
            tmp::Node = minCout(Q)
            Q = setdiff(Q,[tmp])
        
            println(tmp)
            println(length(Q))

            for i in voisin(matrix,tmp.pos)
                matrix = maj_dist(tmp,matrix,i.pos,pre)
            end
            for i in voisin(matrix,NodeF.pos)
            bool = i  && bool

        end

        ################################################################################################################################################################################################################
        ################################################################################################################################################################################################################

        A = set([])
        s::Node = NodeF
        i::Int64 = 0
        while s != NodeD
            i += 1
            A = union(A,[s])
            s =preced[s]
        end

        A = union(A,NodeD)
        println("La distance entre le début (en "*string(deb)*") et la fin (en "*string(fin)*" est "*string(NodeF.cost))
        println("Il y a "*string(length(A))*" case.s entre le début et la fin.")

    end
end 

