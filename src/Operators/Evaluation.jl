export Evaluation,ivp

## Evaluation constructors

abstract AbstractEvaluation{T}<:Functional{T}

# M = Bool if endpoint
immutable Evaluation{S<:FunctionSpace,M<:Union(Number,Bool),T<:Number} <: AbstractEvaluation{T}
    space::S
    x::M
    order::Int
end
Evaluation(sp::AnySpace,x::Bool,k::Integer)=Evaluation{AnySpace,Bool,Float64}(sp,x,k)
Evaluation{M,T<:Number}(sp::FunctionSpace{T},x::M,order::Integer)=Evaluation{typeof(sp),M,T}(sp,x,order)

#Evaluation(sp::AnySpace,x::Bool)=Evaluation(sp,x,0)
Evaluation(d::FunctionSpace,x::Union(Number,Bool))=Evaluation(d,x,0)



## default getindex
function getindex{S,M,T}(D::Evaluation{S,M,T},kr::Range)   
    # Default is to convert to Canonical and d
    sp=domainspace(D)
    csp=canonicalspace(sp)
    getindex(TimesFunctional(Evaluation(csp,D.x,D.order),Conversion(sp,csp)),kr)
end


## EvaluationWrapper

immutable EvaluationWrapper{S<:FunctionSpace,M<:Union(Number,Bool),FS<:Functional,T<:Number} <: AbstractEvaluation{T}
    space::S
    x::M
    order::Int
    functional::FS
end

EvaluationWrapper{S<:FunctionSpace,M<:Union(Number,Bool),FS<:Functional}(sp::S,x::M,order::Integer,func::FS)=EvaluationWrapper{S,M,FS,Float64}(sp,x,order,func)
getindex(E::EvaluationWrapper,kr::Range)=getindex(E.functional,kr)

domainspace(E::AbstractEvaluation)=E.space
domain(E::AbstractEvaluation)=domain(E.space)
promotedomainspace(E::AbstractEvaluation,sp::FunctionSpace)=Evaluation(sp,E.x,E.order)

## Convenience routines


evaluate(d::Domain,x)=Evaluation(d,x)
ldirichlet(d)=Evaluation(d,false)
rdirichlet(d)=Evaluation(d,true)
lneumann(d)=Evaluation(d,false,1)
rneumann(d)=Evaluation(d,true,1)


ldiffbc(d,k) = Evaluation(d,false,k)
rdiffbc(d,k) = Evaluation(d,true,k)


ivp(d)=[ldirichlet(d),lneumann(d)]
dirichlet(d)=[ldirichlet(d),rdirichlet(d)]
neumann(d)=[lneumann(d),rneumann(d)]
diffbcs(d,k) = [ldiffbc(d,k),rdiffbc(d,k)]
periodic(d,k) = [Evaluation(d,false,i)-Evaluation(d,true,i) for i=0:k]



for op in (:rdirichlet,:ldirichlet,:dirichlet,:lneumann,:rneumann,:neumann,:ivp)
    @eval begin
        $op()=$op(AnySpace())
        $op(::PeriodicDomain)=[] 
    end
end

for op in (:ldiffbc,:rdiffbc,:diffbcs,:periodic)
    @eval $op(k::Integer)=$op(AnySpace(),k)
end

