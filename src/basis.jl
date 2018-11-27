export basis, dbasis, dbasisu

"""
    basis(k, t, n1, x[])

Generate a B-spline basis functions `N[]` for a given open knot vectors `x[]`.

A B-Spline basis is a collection of functions of a parameter `t` wich form
 a basis for the vectorial space of functions. The conformation of this set
 higly depends on the choosing of the knots `x[]` the curve is bound to.
The basis is computed with _Cox-de Boor_ recursive function applied to the
 basis dependency tree in order to optimise the computation.

---

# Arguments
- `k::Int64`: the order of the B-Spline (degree `k-1`).
- `t::Float64`: the parameter value of the parametric curve.
- `n1::Int64`: the number of the points of the controll polygon.
- `x::Array{Float64}`: the knot vector.

---

_By Elia Onofri_
"""

function basis(k::Int64, t::Float64, n1::Int64, x::Array{Float64})::Array{Float64}
    local tmp = Float64[]       # Basis progressive vector
    local N = Float64[]         # Output vector
    local max_N = n1-1+k        # Needs i+(k-1)|i=n+1 = n+k trivial basis
    local ddep::Float64 = 0.0   # Direct Dependency partial sum
    local fdep::Float64 = 0.0   # Forward Dependency partial sum
    
    # Local check of the knot vector correctness
    @assert length(x) == n1+k ("ERROR: incompatibile knot vector with given parameters n+1 = $(n1), k = $(k)")
    
    # Eval N_{i,1} for i = 1:max_B
    for i=1:max_N
        if (t>=x[i]) && (t<x[i+1])
            append!(tmp, 1)
        else
            append!(tmp, 0)
        end
    end
    
    # Eval higher basis N_{i,deg} for deg = 2:k and i = 1:max_B-deg
    for deg = 2:k
        for i = 1:max_N+1-deg
            # Eval of the direct dependency
            if tmp[i]==0
                ddep = 0.0
            else
                ddep = ((t-x[i])*tmp[i])/(x[i+deg-1]-x[i])
            end
            # Eval of the forward dependency
            if tmp[i+1]==0
                fdep = 0.0
            else
                fdep = ((x[i+deg]-t)*tmp[i+1])/(x[i+deg]-x[i+1])
            end
            # Collection of the dependencies
            tmp[i] = ddep+fdep
        end
    end
    
    # Otherwise last point is zero
    if t == x[n1+k]
        tmp[n1] = 1
    end
    
    # Collect N{1,k} to N{n+1,k} in B
    for i=1:n1
        push!(N, tmp[i]);
    end
    return N;
end


#--------------------------------------------------------------------------------------------------------------------------------


"""
	dbasis(c, t, npts, x)

Generate B-spline basis functions and their derivatives for uniform open knot vectors.

---

_By Elia Onofri_
"""

function dbasis(c::Int64, t::Float64, npts::Int64, x::Array{Int64})::Tuple{Array{Float64}, Array{Float64}, Array{Float64}}
    
    #inizialization
    
    temp = zeros(36);    # allows for 35 defining polygon vertices
    temp1 = zeros(36);
    temp2 = zeros(36);
    nplusc = npts+c;
    
    # calculate the first order basis functions n[i]
    
    for i=1:nplusc-1
        if (t>=x[i])&&(t<x[i+1])
            temp[i]=1;
        else
            temp[i]=0;
        end
    end
    
    if t==x[nplusc]    # last(x)
        temp[npts] = 1;
    end
    
    # calculate the higher order basis functions
    for k=2:c
        for i=1:nplusc-k
            if temp[i] != 0    # if the lower order basis function is zero skip the calculation
                b1 = ((t-x[i])*temp[i])/(x[i+k-1]-x[i]);
            else
                b1 = 0;
            end
            if temp[i+1] != 0    # if the lower order basis function is zero skip the calculation
                b2 = ((x[i+k]-t)*temp[i+1])/(x[i+k]-x[i+1]);
            else
                b2 = 0;
            end
            
            # calculate first derivative
            if temp[i] != 0    # if the lower order basis function is zero skip the calculation
                f1 = temp[i]/(x[i+k-1]-x[i]);
            else
                f1 = 0;
            end
            if temp[i+1] != 0    # if the lower order basis function is zero skip the calculation
                f2 = -temp[i+1]/(x[i+k]-x[i+1]);
            else
                f2 = 0;
            end
            if temp1[i] != 0    # if the lower order basis function is zero skip the calculation
                f3 = ((t-x[i])*temp1[i])/(x[i+k-1]-x[i]);
            else
                f3 = 0;
            end
            if temp1[i+1] != 0    # if the lower order basis function is zero skip the calculation
                f4 = ((x[i+k]-t)*temp1[i+1])/(x[i+k]-x[i+1]);
            else
                f4 = 0;
            end
            
            # calculate second derivative
            if temp1[i] != 0    # if the lower order basis function is zero skip the calculation
                s1 = (2*temp1[i])/(x[i+k-1]-x[i]);
            else
                s1 = 0;
            end
            if temp1[i+1] != 0    # if the lower order basis function is zero skip the calculation
                s2 = (-2*temp1[i+1])/(x[i+k]-x[i+1]);
            else
                s2 = 0;
            end
            if temp2[i] != 0    # if the lower order basis function is zero skip the calculation
                s3 = ((t-x[i])*temp2[i])/(x[i+k-1]-x[i]);
            else
                s3 = 0;
            end
            if temp2[i+1] != 0    # if the lower order basis function is zero skip the calculation
                s4 = ((x[i+k]-t)*temp2[i+1])/(x[i+k]-x[i+1]);
            else
                s4 = 0;
            end
            
            temp[i] = b1 + b2;
            temp1[i] = f1 + f2 + f3 + f4;
            temp2[i] = s1 + s2 + s3 + s4;
        end
    end
    
    # prepare output
    for i=1:npts
        push!(n, temp[i]);
        push!(d1, temp1[i]);
        push!(d2, temp2[i]);
    end
    return (n, d1, d2);
end


#--------------------------------------------------------------------------------------------------------------------------------


"""
	dbasisu(c, t, npts, x)

Generate B-spline basis functions and their derivatives for uniform periodic knot vectors.

---

_By Elia Onofri_
"""

function dbasisu(c::Int64, t::Float64, npts::Int64, x::Array{Int64})::tuple{Array{Float64}, Array{Float64}, Array{Float64}}

    #inizialization
    
    temp = zeros(36);    # allows for 35 defining polygon vertices
    temp1 = zeros(36);
    temp2 = zeros(36);
    nplusc = npts+c;
    
    # calculate the first order basis functions n[i]
    
    for i=1:nplusc-1
        if (t>=x[i])&&(t<x[i+1])
            temp[i]=1;
        else
            temp[i]=0;
        end
    end
    
    if t==x[npts+1]    # handle the end specially
        temp[npts] = 1;    # resetting the first order basis functions.
        temp[npts+1]=0;
    end
    
    # calculate the higher order basis functions
    for k=2:c
        for i=1:nplusc-k
            if temp[i] != 0    # if the lower order basis function is zero skip the calculation
                b1 = ((t-x[i])*temp[i])/(x[i+k-1]-x[i]);
            else
                b1 = 0;
            end
            if temp[i+1] != 0    # if the lower order basis function is zero skip the calculation
                b2 = ((x[i+k]-t)*temp[i+1])/(x[i+k]-x[i+1]);
            else
                b2 = 0;
            end
            
            # calculate first derivative
            if temp[i] != 0    # if the lower order basis function is zero skip the calculation
                f1 = temp[i]/(x[i+k-1]-x[i]);
            else
                f1 = 0;
            end
            if temp[i+1] != 0    # if the lower order basis function is zero skip the calculation
                f2 = -temp[i+1]/(x[i+k]-x[i+1]);
            else
                f2 = 0;
            end
            if temp1[i] != 0    # if the lower order basis function is zero skip the calculation
                f3 = ((t-x[i])*temp1[i])/(x[i+k-1]-x[i]);
            else
                f3 = 0;
            end
            if temp1[i+1] != 0    # if the lower order basis function is zero skip the calculation
                f4 = ((x[i+k]-t)*temp1[i+1])/(x[i+k]-x[i+1]);
            else
                f4 = 0;
            end
            
            # calculate second derivative
            if temp1[i] != 0    # if the lower order basis function is zero skip the calculation
                s1 = (2*temp1[i])/(x[i+k-1]-x[i]);
            else
                s1 = 0;
            end
            if temp1[i+1] != 0    # if the lower order basis function is zero skip the calculation
                s2 = (-2*temp1[i+1])/(x[i+k]-x[i+1]);
            else
                s2 = 0;
            end
            if temp2[i] != 0    # if the lower order basis function is zero skip the calculation
                s3 = ((t-x[i])*temp2[i])/(x[i+k-1]-x[i]);
            else
                s3 = 0;
            end
            if temp2[i+1] != 0    # if the lower order basis function is zero skip the calculation
                s4 = ((x[i+k]-t)*temp2[i+1])/(x[i+k]-x[i+1]);
            else
                s4 = 0;
            end
            
            temp[i] = b1 + b2;
            temp1[i] = f1 + f2 + f3 + f4;
            temp2[i] = s1 + s2 + s3 + s4;
        end
    end
    
    # prepare output
    for i=1:npts
        push!(n, temp[i]);
        push!(d1, temp1[i]);
        push!(d2, temp2[i]);
    end
    return (n, d1, d2);
end
