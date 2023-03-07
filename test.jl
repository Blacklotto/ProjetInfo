using JuMP, GLPK, Images, ImageMagick

#=@enum COULEUR begin
    . = RGB(1.0,1.0,1.0)
    T = RGB(0.0,1.0,0.0)
end=#

mutable struct yolo
    boolvisitable::Bool
    cout::Int64
    boolvisite::Bool
end

cout = [1 5 8]

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

function matrix2Color(matrix::Matrix{Char},it::Int64)
    n = height(matrix)
    m = width(matrix)
    C = Matrix{RGB{Float64}}(undef,n,m)

    for i in 1:n
        for j in 1:m
            if(matrix[i,j] == '.' )
                C[i,j] = RGB(1.0,1.0,1.0)
            elseif(matrix[i,j] == 'T')
                C[i,j] = RGB(0.0,1.0,0.0)
            elseif(matrix[i,j] == 'S')
                C[i,j] = RGB(1.0,1.0,0.0)
            elseif(matrix[i,j] == 'W')
                C[i,j] = RGB(0.0,0.6,1.0)
            elseif(matrix[i,j] == '@')
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

function main(fichier::String)
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
    (matrixCol,it) = matrix2Color(matrixInit,it)
    load("Images/test"*string(it-1)*".png")

    println("Where do you want to start ? Position of the x-axis :")
    tmp = readline()
    debx::Int64 = parse(Int64,tmp)
    println("Where do you want to start ? Position of the y-axis :")
    deby::Int64 = parse(Int64,readline())
    (matrixCol,it) = modifmatrixCol(matrixCol,(debx,deby),RGB(1.0,0.0,0.0),it)
    

    println("Where do you want to end ? Position of the x-axis :")
    finx::Int64 = parse(Int64,readline())
    println("Where do you want to end ? Position of the y-axis :")
    finy::Int64 = parse(Int64,readline())
    (matrixCol,it) = modifmatrixCol(matrixCol,(finx,finy),RGB(0.0,0.0,1.0),it)
    load("Images/test"*string(it-1)*".png")

end

function construct(matrix::Matrix{Char})
n = length(matrix)
m = width(matrix)
matrixbis::yolo = Matrix(undef,n,m)

    for i in 1:n
        for j in 1:m
            if(matrix[i,j] == 'T' || matrix[i,j] == '@')
                matrixbis[i,j].boolvisitable = false
            else
                matrixbis[i,j].boolvisitable = true
                matrixbis[i,j].boolvisite = false
                if(matrix[i,j] = '.')
                    matrixbis[i,j].cout = 1
                elseif(matrix[i,j] = 'S')
                    matrixbis[i,j].cout = 5
                elseif(matrix[i,j] = 'W')
                    matrixbis[i,j].cout = 8
                end
            end
        end
    end
return matrixbis
end

function dijkstraAlgo(deb::Tuple{Int64,Int64},fin::Tuple{Int64,Int64},matrix::Matrix{Char})
    matrixbis::yolo = construct(matrix)

    if(!matrixbis[deb[1],deb[2]].visitable || !matrixbis[fin[1],fin[2]].visitable )
        return "L'algorithme ne peut pas se lancer : Le point initial ou le point final ne sont pas atteignable !"
    end
end 

