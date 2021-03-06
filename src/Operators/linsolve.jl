## Linear Solve



function linsolve{T<:Operator,N<:Number}(A::Vector{T},b::Array{N};tolerance=0.01eps(),maxlength=1000000)
    Ad=promotedomainspace(A)

    r=adaptiveqr(Ad,b,tolerance,maxlength)

    #all rows of Ad should have same domain space     
    ds=domainspace(Ad[end])     
    # If ds is a ArraySpace and r is a matrix, then 
    # the constructor in ArraySpace converts to matrix
    isa(ds,AnySpace)?r:Fun(r,ds)
end

function linsolve{T<:Operator}(A::Vector{T},b::Array{Any};tolerance=0.01eps(),maxlength=1000000)
 #TODO: depends on ordering of A
    for k=1:length(A)-1
        @assert isa(A[k],Functional)
    end
    
    for k=1:min(length(A)-1,size(b,1)),j=1:size(b,2)
        @assert isa(b[k,j],Number)
    end    
    
    
    
    
    #TODO: Use information from b to promote range space if necessary
    if size(b,1)<size(A,1)
        # the ... converts b to a tuple of numbers so that r is a number Vec    
        r=reshape([b...],size(b))
    elseif size(b,1)==size(A,1)
        if isa(b[end,1],Fun)
            bend=b[end,:]
            m=mapreduce(length,max,bend)
            typ=mapreduce(eltype,promote_type,bend)
            r=isa(b,Vector)?Array(typ,size(b,1)-1+m):zeros(typ,size(b,1)-1+m,size(b,2))
            r[1:size(b,1)-1,:]=b[1:end-1,:]
            
            for k=2:size(b,2)
                @assert space(b[end,k])==space(b[end,1])
            end
            
            A,be=promotedomainspace(A,b[end,1])
            rs=rangespace(A[end])
            @assert space(be)==rs
            r[size(b,1):size(b,1)+length(be)-1,1]=coefficients(be)
            for k=2:size(b,2)
                cfs=coefficients(b[end,k],rs)
                r[size(b,1):size(b,1)+length(cfs)-1,k]=cfs
            end
        else
            #TODO: matrix
            @assert size(b,2)==1
            r=[b[1:end-1]...,b[end]...]  #b[end] is probably a vector or a number
        end
    else 
        @assert size(b,2)==1    
        # we have list of possible funs, devec
        rhs=b[size(A,1):end]
        if all(f->isa(f,Fun),rhs)
            A,be=promotedomainspace(A,devec(rhs))
            @assert space(be)==rangespace(A[end])
        
            r=[b[1:size(A,1)-1]...,coefficients(be)]
        else
            #TODO: Don't remember what this case is for
            r=[b[1:size(A,1)-1]...,interlace(rhs)]
        end
    end
    
    linsolve(A,r;tolerance=tolerance,maxlength=maxlength) 
end


function linsolve{T<:Operator,F<:Fun}(A::Vector{T},b::Array{F};kwds...)
    r=Array(Any,size(b))
    
    # convert constant funs to constants
    # this undoes the effect of [0.,f]
    for k=1:size(A,1)-1,j=1:size(b,2)
        # we only allow constants
        @assert length(b[k,j])==1
        #TODO: 1,1 entry may not be zero
        r[k,j]=b[k,j].coefficients[1]
    end
    
    r[size(A,1):end,:]=b[size(A,1):end,:]
    
    linsolve(A,r;kwds...)
end

linsolve(A::Operator,b::Number;kwds...)=linsolve([A],[b];kwds...)
linsolve{S,T}(A::Operator,b::Fun{S,T};kwds...)=linsolve([A],[b];kwds...)
linsolve{T<:Operator}(A::Vector{T},b::Number;kwds...)=linsolve(A,[b];kwds...)
linsolve{S,Q,T<:Operator}(A::Vector{T},b::Fun{S,Q};kwds...)=linsolve(A,[b];kwds...)
linsolve{T<:Operator}(A::Array{T,2},b;kwds...)=linsolve(interlace(A),b;kwds...)
linsolve(A::Operator,b::Array;kwds...)=linsolve([A],b;kwds...)



\{T<:Operator}(A::Array{T,2},b::Array)=linsolve(A,b)
\{T<:Operator}(A::Vector{T},b::Array)=linsolve(A,b)
\(A::Operator,b)=linsolve(A,b)

