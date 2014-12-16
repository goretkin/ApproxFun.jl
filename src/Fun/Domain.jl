

export Domain,tocanonical,fromcanonical,Circle,PeriodicInterval,Interval
export chebyshevpoints


abstract Domain

immutable AnyDomain <: Domain
end




##General routines








## Interval Domains

abstract IntervalDomain <: Domain
##TODO: Should fromcanonical be fromcanonical!?
chebyshevroots(n::Integer)=[cos(π*k) for k=-1.+1/(2n):1/n:-1./(2n)]
chebyshevpoints(n::Integer)= n==1?[0.]:[cos(1.π*k/(n-1)) for k = n-1:-1:0]
points(d::IntervalDomain,n::Integer) = points(d,n,Float64)

function points(d::IntervalDomain,n::Integer,numbertype::Type) 
    T = numbertype

    if n==1
        return [fromcanonical(d,zero(T))]
    else
        _π = convert(T,π)
        return [fromcanonical(d,cos(_π*k/(n-1))) for k = n-1:-1:0]  #TODO should ensure this array is of type T, but causes InexactError in tests
    end
end

points(d::Vector,n::Integer)=points(Interval(d),n)
bary(v::Vector{Float64},d::IntervalDomain,x::Float64)=bary(v,tocanonical(d,x))


Base.first(d::IntervalDomain)=fromcanonical(d,-1.0)
Base.last(d::IntervalDomain)=fromcanonical(d,1.0)


function Base.in(x,d::IntervalDomain)
    y=tocanonical(d,x)
    abs(imag(y))<10eps() && -1.0-10eps()/length(d)<real(y)<1.0+10eps()/length(d)
end

###### Periodic domains

abstract PeriodicDomain <: Domain

points(d::PeriodicDomain,n::Integer) = points(d,n,Float64) 
points(d::PeriodicDomain,n::Integer,numbertype::Type) = fromcanonical(d, fourierpoints(n,numbertype))

fourierpoints(n::Integer) = fourierpoints(n,Float64)
fourierpoints(n::Integer,numbertype::Type)= convert(numbertype,π)*[-1.:2/n:1. - 2/n]


function Base.in(x,d::PeriodicDomain)
    y=tocanonical(d,x)
    isapprox(imag(y),0.) && -π-2eps()<=real(y)<=π+2eps()
end


Base.first(d::PeriodicDomain)=fromcanonical(d,-π)
Base.last(d::PeriodicDomain)=fromcanonical(d,π)

## conveninece routines

Base.ones(d::Domain)=Fun(one,d)
Base.zeros(d::Domain)=Fun(zero,d)





function commondomain(P::Vector)
    ret = AnyDomain()
    
    for op in P
        d = domain(op)
        @assert ret == AnyDomain() || d == AnyDomain() || ret == d
        
        if d != AnyDomain()
            ret = d
        end
    end
    
    ret
end

commondomain{T<:Number}(P::Vector,g::Array{T})=commondomain(P)
commondomain(P::Vector,g)=commondomain([P,g])


domain(::Number)=AnyDomain()




## rand

Base.rand(d::IntervalDomain)=fromcanonical(d,2rand()-1)
Base.rand(d::PeriodicDomain)=fromcanonical(d,2π*rand()-π)



## boundary


∂(d::IntervalDomain)=[first(d),last(d)]
∂(d::PeriodicDomain)=[]




## map domains


mappoint(d1::Domain,d2::Domain,x)=fromcanonical(d2,tocanonical(d1,x))