using JuMP, GLPK, Images

#=@enum COULEUR begin
    . = RGB(1.0,1.0,1.0)
    T = RGB(0.0,1.0,0.0)
end=#

function fichier2Matrix(nomFichier::String)
    # Ouverture d'un fichier en lecture
    f::IOStream = open(nomFichier,"r")
    s::String = readline(f) #enleve la premiere ligne
   
    s = readline(f)
    height::Int64 = parse(Int64,s[8]*s[9]) #def la hauteur de la map
    
    s = readline(f)
    width::Int64 = parse(Int64,s[7]*s[8]) #def la longueur de la map

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

    # Retour de la matrice de coûts
    return C
end

function matrix2Color(matrix::Matrix{Char})
    n = height(matrix)
    m = width(matrix)
    C = Matrix{RGB{Float64}}(undef,n,m)

    for i in 1:n
        for j in 1:m
            if(matrix[i,j] == '.' )
                C[i,j] = RGB(1.0,1.0,1.0)
            elseif(matrix[i,j] == 'T')
                C[i,j] = RGB(0.0,1.0,0.0) 
            end
        end
    end

    @show C

end 