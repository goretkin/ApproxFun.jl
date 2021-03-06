export ConstantOperator, BasisFunctional


type ConstantOperator{T<:Union(Float64,Complex{Float64})} <: BandedOperator{T}
    c::T
end

ConstantOperator(c::Complex{Float64})=ConstantOperator{Complex{Float64}}(c)
ConstantOperator(c::Float64)=ConstantOperator{Float64}(c)
ConstantOperator(c::Complex)=ConstantOperator{Complex{Float64}}(1.0c)
ConstantOperator(c::Real)=ConstantOperator{Float64}(1.0c)
ConstantOperator(L::UniformScaling)=ConstantOperator(L.λ)
IdentityOperator()=ConstantOperator(1.0)

bandinds(T::ConstantOperator)=0,0

addentries!(C::ConstantOperator,A::ShiftArray,kr::Range1)=laurent_addentries!([.5C.c],A,kr)

==(C1::ConstantOperator,C2::ConstantOperator)=C1.c==C2.c


## Algebra

for op in (:+,:-,:*)
    @eval ($op)(A::ConstantOperator,B::ConstantOperator)=ConstantOperator($op(A.c,B.c))
end


## Basis Functional

type BasisFunctional <: Functional{Float64}
    k::Integer
end


Base.getindex(op::BasisFunctional,k::Integer)=(k==op.k)?1.:0.
Base.getindex(op::BasisFunctional,k::Range1)=convert(Vector{Float64},k.==op.k)

## Zero is a special operator: it makes sense on all spaces, and between all spaces

type ZeroOperator{T,S,V} <: BandedOperator{T}
    domainspace::S
    rangespace::V
end

ZeroOperator{T<:Number,S,V}(::Type{T},d::S,v::V)=ZeroOperator{T,S,V}(d,v)
ZeroOperator{S,V}(d::S,v::V)=ZeroOperator(Float64,d,v)
ZeroOperator()=ZeroOperator(AnySpace(),AnySpace())
ZeroOperator{T<:Number}(::Type{T})=ZeroOperator(T,AnySpace(),AnySpace())

domainspace(Z::ZeroOperator)=Z.domainspace
rangespace(Z::ZeroOperator)=Z.rangespace

bandinds(T::ZeroOperator)=0,0

addentries!(C::ZeroOperator,A::ShiftArray,kr::Range1)=A

promotedomainspace(Z::ZeroOperator,sp::AnySpace)=Z
promoterangespace(Z::ZeroOperator,sp::AnySpace)=Z
promotedomainspace(Z::ZeroOperator,sp::FunctionSpace)=ZeroOperator(sp,rangespace(Z))
promoterangespace(Z::ZeroOperator,sp::FunctionSpace)=ZeroOperator(domainspace(Z),sp)
promotedomainspace(Z::ZeroOperator,sp::FunctionSpace)=ZeroOperator(sp,rangespace(Z))
promoterangespace(Z::ZeroOperator,sp::FunctionSpace)=ZeroOperator(domainspace(Z),sp)


type ZeroFunctional{S} <: Functional{Float64}
    domainspace::S
end
ZeroFunctional()=ZeroFunctional(AnySpace())

domainspace(Z::ZeroFunctional)=Z.domainspace
promotedomainspace(Z::ZeroFunctional,sp::FunctionSpace)=ZeroFunctional(sp)

Base.getindex(op::ZeroFunctional,k::Integer)=0.
Base.getindex(op::ZeroFunctional,k::Range1)=zeros(length(k))




## Promotion: Zero operators are the only operators that also make sense as functionals
promoterangespace(op::ZeroOperator,::ConstantSpace)=ZeroFunctional(domainspace(op))
