using ApproxFun, Base.Test
f = Fun(exp,[-1,1])

@test_approx_eq f[.1] exp(.1)

fp = differentiate(f)		

@test norm(fp-f)<200eps()

g = cumsum(f)
g = g + f[-1]
@test norm(f - g)<20eps()

@test norm(Fun(exp)*Fun(cos)-Fun(x->exp(x)*cos(x)))<10eps()
@test norm((Fun(exp)+Fun(cos))-Fun(x->exp(x)+cos(x)))<10eps()


	
		f = FFun(cos)
@test norm(differentiate(f) + FFun(sin))<eps()
@test norm(cumsum(f) - FFun(sin))	<10eps()

    d=Interval()^2          					# Defines a rectangle
    
    u=[dirichlet(d),lap(d)+100I]\ones(4)		# First four entries of rhs are 