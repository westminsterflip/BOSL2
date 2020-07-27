//////////////////////////////////////////////////////////////////////
// LibFile: math.scad
//   Math helper functions.
//   To use, add the following lines to the beginning of your file:
//   ```
//   use <BOSL2/std.scad>
//   ```
//////////////////////////////////////////////////////////////////////


// Section: Math Constants

PHI = (1+sqrt(5))/2;  // The golden ratio phi.

EPSILON = 1e-9;  // A really small value useful in comparing FP numbers.  ie: abs(a-b)<EPSILON

INF = 1/0;  // The value `inf`, useful for comparisons.

NAN = acos(2);  // The value `nan`, useful for comparisons.



// Section: Simple math

// Function: sqr()
// Usage:
//   sqr(x);
// Description:
//   Returns the square of the given number or entries in list
// Examples:
//   sqr(3);     // Returns: 9
//   sqr(-4);    // Returns: 16
//   sqr([3,4]); // Returns: [9,16]
//   sqr([[1,2],[3,4]]);  // Returns [[1,4],[9,16]]
//   sqr([[1,2],3]);      // Returns [[1,4],9]
function sqr(x) = is_list(x) ? [for(val=x) sqr(val)] : x*x;


// Function: log2()
// Usage:
//   foo = log2(x);
// Description:
//   Returns the logarithm base 2 of the value given.
// Examples:
//   log2(0.125);  // Returns: -3
//   log2(16);     // Returns: 4
//   log2(256);    // Returns: 8
function log2(x) = ln(x)/ln(2);


// Function: hypot()
// Usage:
//   l = hypot(x,y,[z]);
// Description:
//   Calculate hypotenuse length of a 2D or 3D triangle.
// Arguments:
//   x = Length on the X axis.
//   y = Length on the Y axis.
//   z = Length on the Z axis.  Optional.
// Example:
//   l = hypot(3,4);  // Returns: 5
//   l = hypot(3,4,5);  // Returns: ~7.0710678119
function hypot(x,y,z=0) = norm([x,y,z]);


// Function: factorial()
// Usage:
//   x = factorial(n,[d]);
// Description:
//   Returns the factorial of the given integer value, or n!/d! if d is given.  
// Arguments:
//   n = The integer number to get the factorial of.  (n!)
//   d = If given, the returned value will be (n! / d!)
// Example:
//   x = factorial(4);  // Returns: 24
//   y = factorial(6);  // Returns: 720
//   z = factorial(9);  // Returns: 362880
function factorial(n,d=0) =
    assert(n>=0 && d>=0, "Factorial is not defined for negative numbers")
    assert(d<=n, "d cannot be larger than n")
    product([1,for (i=[n:-1:d+1]) i]);


// Function: lerp()
// Usage:
//   x = lerp(a, b, u);
//   l = lerp(a, b, LIST);
// Description:
//   Interpolate between two values or vectors.
//   If `u` is given as a number, returns the single interpolated value.
//   If `u` is 0.0, then the value of `a` is returned.
//   If `u` is 1.0, then the value of `b` is returned.
//   If `u` is a range, or list of numbers, returns a list of interpolated values.
//   It is valid to use a `u` value outside the range 0 to 1.  The result will be a predicted
//   value along the slope formed by `a` and `b`, but not between those two values.
// Arguments:
//   a = First value or vector.
//   b = Second value or vector.
//   u = The proportion from `a` to `b` to calculate.  Standard range is 0.0 to 1.0, inclusive.  If given as a list or range of values, returns a list of results.
// Example:
//   x = lerp(0,20,0.3);  // Returns: 6
//   x = lerp(0,20,0.8);  // Returns: 16
//   x = lerp(0,20,-0.1); // Returns: -2
//   x = lerp(0,20,1.1);  // Returns: 22
//   p = lerp([0,0],[20,10],0.25);  // Returns [5,2.5]
//   l = lerp(0,20,[0.4,0.6]);  // Returns: [8,12]
//   l = lerp(0,20,[0.25:0.25:0.75]);  // Returns: [5,10,15]
// Example(2D):
//   p1 = [-50,-20];  p2 = [50,30];
//   stroke([p1,p2]);
//   pts = lerp(p1, p2, [0:1/8:1]);
//   // Points colored in ROYGBIV order.
//   rainbow(pts) translate($item) circle(d=3,$fn=8);
function lerp(a,b,u) =
    assert(same_shape(a,b), "Bad or inconsistent inputs to lerp")
    is_num(u)? (1-u)*a + u*b :
    assert(!is_undef(u)&&!is_bool(u)&&!is_string(u), "Input u to lerp must be a number, vector, or range.")
    [for (v = u) lerp(a,b,v)];



// Section: Hyperbolic Trigonometry

// Function: sinh()
// Description: Takes a value `x`, and returns the hyperbolic sine of it.
function sinh(x) =
    (exp(x)-exp(-x))/2;


// Function: cosh()
// Description: Takes a value `x`, and returns the hyperbolic cosine of it.
function cosh(x) =
    (exp(x)+exp(-x))/2;


// Function: tanh()
// Description: Takes a value `x`, and returns the hyperbolic tangent of it.
function tanh(x) =
    sinh(x)/cosh(x);


// Function: asinh()
// Description: Takes a value `x`, and returns the inverse hyperbolic sine of it.
function asinh(x) =
    ln(x+sqrt(x*x+1));


// Function: acosh()
// Description: Takes a value `x`, and returns the inverse hyperbolic cosine of it.
function acosh(x) =
    ln(x+sqrt(x*x-1));


// Function: atanh()
// Description: Takes a value `x`, and returns the inverse hyperbolic tangent of it.
function atanh(x) =
    ln((1+x)/(1-x))/2;



// Section: Quantization

// Function: quant()
// Description:
//   Quantize a value `x` to an integer multiple of `y`, rounding to the nearest multiple.
//   If `x` is a list, then every item in that list will be recursively quantized.
// Arguments:
//   x = The value to quantize.
//   y = The multiple to quantize to.
// Example:
//   quant(12,4);    // Returns: 12
//   quant(13,4);    // Returns: 12
//   quant(13.1,4);  // Returns: 12
//   quant(14,4);    // Returns: 16
//   quant(14.1,4);  // Returns: 16
//   quant(15,4);    // Returns: 16
//   quant(16,4);    // Returns: 16
//   quant(9,3);     // Returns: 9
//   quant(10,3);    // Returns: 9
//   quant(10.4,3);  // Returns: 9
//   quant(10.5,3);  // Returns: 12
//   quant(11,3);    // Returns: 12
//   quant(12,3);    // Returns: 12
//   quant([12,13,13.1,14,14.1,15,16],4);  // Returns: [12,12,12,16,16,16,16]
//   quant([9,10,10.4,10.5,11,12],3);      // Returns: [9,9,9,12,12,12]
//   quant([[9,10,10.4],[10.5,11,12]],3);  // Returns: [[9,9,9],[12,12,12]]
function quant(x,y) =
    is_list(x)? [for (v=x) quant(v,y)] :
    floor(x/y+0.5)*y;


// Function: quantdn()
// Description:
//   Quantize a value `x` to an integer multiple of `y`, rounding down to the previous multiple.
//   If `x` is a list, then every item in that list will be recursively quantized down.
// Arguments:
//   x = The value to quantize.
//   y = The multiple to quantize to.
// Examples:
//   quantdn(12,4);    // Returns: 12
//   quantdn(13,4);    // Returns: 12
//   quantdn(13.1,4);  // Returns: 12
//   quantdn(14,4);    // Returns: 12
//   quantdn(14.1,4);  // Returns: 12
//   quantdn(15,4);    // Returns: 12
//   quantdn(16,4);    // Returns: 16
//   quantdn(9,3);     // Returns: 9
//   quantdn(10,3);    // Returns: 9
//   quantdn(10.4,3);  // Returns: 9
//   quantdn(10.5,3);  // Returns: 9
//   quantdn(11,3);    // Returns: 9
//   quantdn(12,3);    // Returns: 12
//   quantdn([12,13,13.1,14,14.1,15,16],4);  // Returns: [12,12,12,12,12,12,16]
//   quantdn([9,10,10.4,10.5,11,12],3);      // Returns: [9,9,9,9,9,12]
//   quantdn([[9,10,10.4],[10.5,11,12]],3);  // Returns: [[9,9,9],[9,9,12]]
function quantdn(x,y) =
    is_list(x)? [for (v=x) quantdn(v,y)] :
    floor(x/y)*y;


// Function: quantup()
// Description:
//   Quantize a value `x` to an integer multiple of `y`, rounding up to the next multiple.
//   If `x` is a list, then every item in that list will be recursively quantized up.
// Arguments:
//   x = The value to quantize.
//   y = The multiple to quantize to.
// Examples:
//   quantup(12,4);    // Returns: 12
//   quantup(13,4);    // Returns: 16
//   quantup(13.1,4);  // Returns: 16
//   quantup(14,4);    // Returns: 16
//   quantup(14.1,4);  // Returns: 16
//   quantup(15,4);    // Returns: 16
//   quantup(16,4);    // Returns: 16
//   quantup(9,3);     // Returns: 9
//   quantup(10,3);    // Returns: 12
//   quantup(10.4,3);  // Returns: 12
//   quantup(10.5,3);  // Returns: 12
//   quantup(11,3);    // Returns: 12
//   quantup(12,3);    // Returns: 12
//   quantup([12,13,13.1,14,14.1,15,16],4);  // Returns: [12,16,16,16,16,16,16]
//   quantup([9,10,10.4,10.5,11,12],3);      // Returns: [9,12,12,12,12,12]
//   quantup([[9,10,10.4],[10.5,11,12]],3);  // Returns: [[9,12,12],[12,12,12]]
function quantup(x,y) =
    is_list(x)? [for (v=x) quantup(v,y)] :
    ceil(x/y)*y;


// Section: Constraints and Modulos

// Function: constrain()
// Usage:
//   constrain(v, minval, maxval);
// Description:
//   Constrains value to a range of values between minval and maxval, inclusive.
// Arguments:
//   v = value to constrain.
//   minval = minimum value to return, if out of range.
//   maxval = maximum value to return, if out of range.
// Example:
//   constrain(-5, -1, 1);   // Returns: -1
//   constrain(5, -1, 1);    // Returns: 1
//   constrain(0.3, -1, 1);  // Returns: 0.3
//   constrain(9.1, 0, 9);   // Returns: 9
//   constrain(-0.1, 0, 9);  // Returns: 0
function constrain(v, minval, maxval) = min(maxval, max(minval, v));


// Function: posmod()
// Usage:
//   posmod(x,m)
// Description:
//   Returns the positive modulo `m` of `x`.  Value returned will be in the range 0 ... `m`-1.
// Arguments:
//   x = The value to constrain.
//   m = Modulo value.
// Example:
//   posmod(-700,360);  // Returns: 340
//   posmod(-270,360);  // Returns: 90
//   posmod(-120,360);  // Returns: 240
//   posmod(120,360);   // Returns: 120
//   posmod(270,360);   // Returns: 270
//   posmod(700,360);   // Returns: 340
//   posmod(3,2.5);     // Returns: 0.5
function posmod(x,m) = (x%m+m)%m;


// Function: modang(x)
// Usage:
//   ang = modang(x)
// Description:
//   Takes an angle in degrees and normalizes it to an equivalent angle value between -180 and 180.
// Example:
//   modang(-700,360);  // Returns: 20
//   modang(-270,360);  // Returns: 90
//   modang(-120,360);  // Returns: -120
//   modang(120,360);   // Returns: 120
//   modang(270,360);   // Returns: -90
//   modang(700,360);   // Returns: -20
function modang(x) =
    let(xx = posmod(x,360)) xx<180? xx : xx-360;


// Function: modrange()
// Usage:
//   modrange(x, y, m, [step])
// Description:
//   Returns a normalized list of values from `x` to `y`, by `step`, modulo `m`.  Wraps if `x` > `y`.
// Arguments:
//   x = The start value to constrain.
//   y = The end value to constrain.
//   m = Modulo value.
//   step = Step by this amount.
// Examples:
//   modrange(90,270,360, step=45);   // Returns: [90,135,180,225,270]
//   modrange(270,90,360, step=45);   // Returns: [270,315,0,45,90]
//   modrange(90,270,360, step=-45);  // Returns: [90,45,0,315,270]
//   modrange(270,90,360, step=-45);  // Returns: [270,225,180,135,90]
function modrange(x, y, m, step=1) =
    let(
        a = posmod(x, m),
        b = posmod(y, m),
        c = step>0? (a>b? b+m : b) : (a<b? b-m : b)
    ) [for (i=[a:step:c]) (i%m+m)%m];



// Section: Random Number Generation

// Function: rand_int()
// Usage:
//   rand_int(min,max,N,[seed]);
// Description:
//   Return a list of random integers in the range of min to max, inclusive.
// Arguments:
//   min = Minimum integer value to return.
//   max = Maximum integer value to return.
//   N = Number of random integers to return.
//   seed = If given, sets the random number seed.
// Example:
//   ints = rand_int(0,100,3);
//   int = rand_int(-10,10,1)[0];
function rand_int(min, max, N, seed=undef) =
    assert(max >= min, "Max value cannot be smaller than min")
    let (rvect = is_def(seed) ? rands(min,max+1,N,seed) : rands(min,max+1,N))
    [for(entry = rvect) floor(entry)];


// Function: gaussian_rands()
// Usage:
//   gaussian_rands(mean, stddev, [N], [seed])
// Description:
//   Returns a random number with a gaussian/normal distribution.
// Arguments:
//   mean = The average random number returned.
//   stddev = The standard deviation of the numbers to be returned.
//   N = Number of random numbers to return.  Default: 1
//   seed = If given, sets the random number seed.
function gaussian_rands(mean, stddev, N=1, seed=undef) =
    let(nums = is_undef(seed)? rands(0,1,N*2) : rands(0,1,N*2,seed))
    [for (i = list_range(N)) mean + stddev*sqrt(-2*ln(nums[i*2]))*cos(360*nums[i*2+1])];


// Function: log_rands()
// Usage:
//   log_rands(minval, maxval, factor, [N], [seed]);
// Description:
//   Returns a single random number, with a logarithmic distribution.
// Arguments:
//   minval = Minimum value to return.
//   maxval = Maximum value to return.  `minval` <= X < `maxval`.
//   factor = Log factor to use.  Values of X are returned `factor` times more often than X+1.
//   N = Number of random numbers to return.  Default: 1
//   seed = If given, sets the random number seed.
function log_rands(minval, maxval, factor, N=1, seed=undef) =
    assert(maxval >= minval, "maxval cannot be smaller than minval")
    let(
        minv = 1-1/pow(factor,minval),
        maxv = 1-1/pow(factor,maxval),
        nums = is_undef(seed)? rands(minv, maxv, N) : rands(minv, maxv, N, seed)
    ) [for (num=nums) -ln(1-num)/ln(factor)];



// Section: GCD/GCF, LCM

// Function: gcd()
// Usage:
//   gcd(a,b)
// Description:
//   Computes the Greatest Common Divisor/Factor of `a` and `b`.  
function gcd(a,b) =
    assert(is_int(a) && is_int(b),"Arguments to gcd must be integers")
    b==0 ? abs(a) : gcd(b,a % b);


// Computes lcm for two scalars
function _lcm(a,b) =
    assert(is_int(a), "Invalid non-integer parameters to lcm")
    assert(is_int(b), "Invalid non-integer parameters to lcm")
    assert(a!=0 && b!=0, "Arguments to lcm must be nonzero")
    abs(a*b) / gcd(a,b);


// Computes lcm for a list of values
function _lcmlist(a) =
    len(a)==1 ? a[0] :
    _lcmlist(concat(slice(a,0,len(a)-2),[lcm(a[len(a)-2],a[len(a)-1])]));


// Function: lcm()
// Usage:
//   lcm(a,b)
//   lcm(list)
// Description:
//   Computes the Least Common Multiple of the two arguments or a list of arguments.  Inputs should
//   be non-zero integers.  The output is always a positive integer.  It is an error to pass zero
//   as an argument.  
function lcm(a,b=[]) =
    !is_list(a) && !is_list(b) ? _lcm(a,b) : 
    let(
        arglist = concat(force_list(a),force_list(b))
    )
    assert(len(arglist)>0,"invalid call to lcm with empty list(s)")
    _lcmlist(arglist);



// Section: Sums, Products, Aggregate Functions.

// Function: sum()
// Description:
//   Returns the sum of all entries in the given list.
//   If passed an array of vectors, returns a vector of sums of each part.
//   If passed an empty list, the value of `dflt` will be returned.
// Arguments:
//   v = The list to get the sum of.
//   dflt = The default value to return if `v` is an empty list.  Default: 0
// Example:
//   sum([1,2,3]);  // returns 6.
//   sum([[1,2,3], [3,4,5], [5,6,7]]);  // returns [9, 12, 15]
function sum(v, dflt=0) =
    is_vector(v) ? [for(i=v) 1]*v :
    assert(is_consistent(v), "Input to sum is non-numeric or inconsistent")
    is_vector(v[0]) ? [for(i=v) 1]*v :
    len(v) == 0 ? dflt :
                  _sum(v,v[0]*0);

function _sum(v,_total,_i=0) = _i>=len(v) ? _total : _sum(v,_total+v[_i], _i+1);


// Function: cumsum()
// Description:
//   Returns a list where each item is the cumulative sum of all items up to and including the corresponding entry in the input list.
//   If passed an array of vectors, returns a list of cumulative vectors sums.
// Arguments:
//   v = The list to get the sum of.
// Example:
//   cumsum([1,1,1]);  // returns [1,2,3]
//   cumsum([2,2,2]);  // returns [2,4,6]
//   cumsum([1,2,3]);  // returns [1,3,6]
//   cumsum([[1,2,3], [3,4,5], [5,6,7]]);  // returns [[1,2,3], [4,6,8], [9,12,15]]
function cumsum(v,_i=0,_acc=[]) =
    _i==len(v) ? _acc :
    cumsum(
        v, _i+1,
        concat(
            _acc,
            [_i==0 ? v[_i] : select(_acc,-1)+v[_i]]
        )
    );


// Function: sum_of_squares()
// Description:
//   Returns the sum of the square of each element of a vector.
// Arguments:
//   v = The vector to get the sum of.
// Example:
//   sum_of_squares([1,2,3]);  // Returns: 14.
//   sum_of_squares([1,2,4]);  // Returns: 21
//   sum_of_squares([-3,-2,-1]);  // Returns: 14
function sum_of_squares(v) = sum(vmul(v,v));


// Function: sum_of_sines()
// Usage:
//   sum_of_sines(a,sines)
// Description:
//   Gives the sum of a series of sines, at a given angle.
// Arguments:
//   a = Angle to get the value for.
//   sines = List of [amplitude, frequency, offset] items, where the frequency is the number of times the cycle repeats around the circle.
// Examples:
//   v = sum_of_sines(30, [[10,3,0], [5,5.5,60]]);
function sum_of_sines(a, sines) =
    sum([
        for (s = sines) let(
            ss=point3d(s),
            v=ss.x*sin(a*ss.y+ss.z)
        ) v
    ]);


// Function: deltas()
// Description:
//   Returns a list with the deltas of adjacent entries in the given list.
//   Given [a,b,c,d], returns [b-a,c-b,d-c].
// Arguments:
//   v = The list to get the deltas of.
// Example:
//   deltas([2,5,9,17]);  // returns [3,4,8].
//   deltas([[1,2,3], [3,6,8], [4,8,11]]);  // returns [[2,4,5], [1,2,3]]
function deltas(v) = [for (p=pair(v)) p.y-p.x];


// Function: product()
// Description:
//   Returns the product of all entries in the given list.
//   If passed an array of vectors, returns a vector of products of each part.
//   If passed an array of matrices, returns a the resulting product matrix.
// Arguments:
//   v = The list to get the product of.
// Example:
//   product([2,3,4]);  // returns 24.
//   product([[1,2,3], [3,4,5], [5,6,7]]);  // returns [15, 48, 105]
function product(v, i=0, tot=undef) = i>=len(v)? tot : product(v, i+1, ((tot==undef)? v[i] : is_vector(v[i])? vmul(tot,v[i]) : tot*v[i]));


// Function: outer_product()
// Description:
//   Compute the outer product of two vectors, a matrix.  
// Usage:
//   M = outer_product(u,v);
function outer_product(u,v) =
  assert(is_vector(u) && is_vector(v))
  assert(len(u)==len(v))
  [for(i=[0:len(u)-1]) [for(j=[0:len(u)-1]) u[i]*v[j]]];


// Function: mean()
// Description:
//   Returns the arithmatic mean/average of all entries in the given array.
//   If passed a list of vectors, returns a vector of the mean of each part.
// Arguments:
//   v = The list of values to get the mean of.
// Example:
//   mean([2,3,4]);  // returns 3.
//   mean([[1,2,3], [3,4,5], [5,6,7]]);  // returns [3, 4, 5]
function mean(v) = sum(v)/len(v);


// Function: median()
// Usage:
//   x = median(v);
// Description:
//   Given a list of numbers or vectors, finds the median value or midpoint.
//   If passed a list of vectors, returns the vector of the median of each part.
function median(v) =
    assert(is_list(v))
    assert(len(v)>0)
    is_vector(v[0])? (
        assert(is_consistent(v))
        [
            for (i=idx(v[0]))
            let(vals = subindex(v,i))
            (min(vals)+max(vals))/2
        ]
    ) : (min(v)+max(v))/2;


// Section: Matrix math

// Function: linear_solve()
// Usage: linear_solve(A,b)
// Description:
//   Solves the linear system Ax=b.  If A is square and non-singular the unique solution is returned.  If A is overdetermined
//   the least squares solution is returned.  If A is underdetermined, the minimal norm solution is returned.
//   If A is rank deficient or singular then linear_solve returns [].  If b is a matrix that is compatible with A
//   then the problem is solved for the matrix valued right hand side and a matrix is returned.  Note that if you 
//   want to solve Ax=b1 and Ax=b2 that you need to form the matrix transpose([b1,b2]) for the right hand side and then
//   transpose the returned value.  
function linear_solve(A,b) =
    assert(is_matrix(A))
    let(
        m = len(A),
        n = len(A[0])
    )
    assert(is_vector(b,m) || is_matrix(b,m),"Incompatible matrix and right hand side")
    let (
        qr = m<n? qr_factor(transpose(A)) : qr_factor(A),
        maxdim = max(n,m),
        mindim = min(n,m),
        Q = submatrix(qr[0],[0:maxdim-1], [0:mindim-1]),
        R = submatrix(qr[1],[0:mindim-1], [0:mindim-1]),
        zeros = [for(i=[0:mindim-1]) if (approx(R[i][i],0)) i]
    )
    zeros != [] ? [] :
    m<n ? Q*back_substitute(R,b,transpose=true) :
    back_substitute(R, transpose(Q)*b);


// Function: matrix_inverse()
// Usage:
//    matrix_inverse(A)
// Description:
//    Compute the matrix inverse of the square matrix A.  If A is singular, returns undef.
//    Note that if you just want to solve a linear system of equations you should NOT
//    use this function.  Instead use linear_solve, or use qr_factor.  The computation
//    will be faster and more accurate.  
function matrix_inverse(A) =
    assert(is_matrix(A,square=true),"Input to matrix_inverse() must be a square matrix")
    linear_solve(A,ident(len(A)));


// Function: submatrix()
// Usage: submatrix(M, ind1, ind2)
// Description:
//   Returns a submatrix with the specified index ranges or index sets.  
function submatrix(M,ind1,ind2) =
    [for(i=ind1) [for(j=ind2) M[i][j] ] ];


// Function: qr_factor()
// Usage: qr = qr_factor(A)
// Description:
//   Calculates the QR factorization of the input matrix A and returns it as the list [Q,R].  This factorization can be
//   used to solve linear systems of equations.  
function qr_factor(A) =
    assert(is_matrix(A))
    let(
      m = len(A),
      n = len(A[0])
    )
    let(
        qr =_qr_factor(A, column=0, m = m, n=n, Q=ident(m)),
        Rzero = [
            for(i=[0:m-1]) [
                for(j=[0:n-1])
                i>j ? 0 : qr[1][i][j]
            ]
        ]
    ) [qr[0],Rzero];

function _qr_factor(A,Q, column, m, n) =
    column >= min(m-1,n) ? [Q,A] :
    let(
        x = [for(i=[column:1:m-1]) A[i][column]],
        alpha = (x[0]<=0 ? 1 : -1) * norm(x),
        u = x - concat([alpha],repeat(0,m-1)),
        v = alpha==0 ? u : u / norm(u),
        Qc = ident(len(x)) - 2*outer_product(v,v),
        Qf = [for(i=[0:m-1]) [for(j=[0:m-1]) i<column || j<column ? (i==j ? 1 : 0) : Qc[i-column][j-column]]]
    )
    _qr_factor(Qf*A, Q*Qf, column+1, m, n);


// Function: back_substitute()
// Usage: back_substitute(R, b, [transpose])
// Description:
//   Solves the problem Rx=b where R is an upper triangular square matrix.  No check is made that the lower triangular entries
//   are actually zero.  If transpose==true then instead solve transpose(R)*x=b.
//   You can supply a compatible matrix b and it will produce the solution for every column of b.  Note that if you want to
//   solve Rx=b1 and Rx=b2 you must set b to transpose([b1,b2]) and then take the transpose of the result.  If the matrix
//   is singular (e.g. has a zero on the diagonal) then it returns [].  
function back_substitute(R, b, x=[],transpose = false) =
    assert(is_matrix(R, square=true))
    let(n=len(R))
    assert(is_vector(b,n) || is_matrix(b,n),str("R and b are not compatible in back_substitute ",n, len(b)))
    !is_vector(b) ? transpose([for(i=[0:len(b[0])-1]) back_substitute(R,subindex(b,i),transpose=transpose)]) :
    transpose?
        reverse(back_substitute(
            [for(i=[0:n-1]) [for(j=[0:n-1]) R[n-1-j][n-1-i]]],
            reverse(b), x, false
        )) :
    len(x) == n ? x :
    let(
        ind = n - len(x) - 1
    )
    R[ind][ind] == 0 ? [] :
    let(
        newvalue =
            len(x)==0? b[ind]/R[ind][ind] : 
            (b[ind]-select(R[ind],ind+1,-1) * x)/R[ind][ind]
    ) back_substitute(R, b, concat([newvalue],x));


// Function: det2()
// Description:
//   Optimized function that returns the determinant for the given 2x2 square matrix.
// Arguments:
//   M = The 2x2 square matrix to get the determinant of.
// Example:
//   M = [ [6,-2], [1,8] ];
//   det = det2(M);  // Returns: 50
function det2(M) = M[0][0] * M[1][1] - M[0][1]*M[1][0];


// Function: det3()
// Description:
//   Optimized function that returns the determinant for the given 3x3 square matrix.
// Arguments:
//   M = The 3x3 square matrix to get the determinant of.
// Example:
//   M = [ [6,4,-2], [1,-2,8], [1,5,7] ];
//   det = det3(M);  // Returns: -334
function det3(M) =
    M[0][0] * (M[1][1]*M[2][2]-M[2][1]*M[1][2]) -
    M[1][0] * (M[0][1]*M[2][2]-M[2][1]*M[0][2]) +
    M[2][0] * (M[0][1]*M[1][2]-M[1][1]*M[0][2]);


// Function: determinant()
// Description:
//   Returns the determinant for the given square matrix.
// Arguments:
//   M = The NxN square matrix to get the determinant of.
// Example:
//   M = [ [6,4,-2,9], [1,-2,8,3], [1,5,7,6], [4,2,5,1] ];
//   det = determinant(M);  // Returns: 2267
function determinant(M) =
    assert(len(M)==len(M[0]))
    len(M)==1? M[0][0] :
    len(M)==2? det2(M) :
    len(M)==3? det3(M) :
    sum(
        [for (col=[0:1:len(M)-1])
            ((col%2==0)? 1 : -1) *
            M[col][0] *
            determinant(
                [for (r=[1:1:len(M)-1])
                    [for (c=[0:1:len(M)-1])
                        if (c!=col) M[c][r]
                    ]
                ]
            )
        ]
    );


// Function: is_matrix()
// Usage:
//   is_matrix(A,[m],[n],[square])
// Description:
//   Returns true if A is a numeric matrix of height m and width n.  If m or n
//   are omitted or set to undef then true is returned for any positive dimension.
//   If `square` is true then the matrix is required to be square.  Note if you
//   specify m != n and require a square matrix then the result will always be false.
// Arguments:
//   A = matrix to test
//   m = optional height of matrix
//   n = optional width of matrix
//   square = set to true to require a square matrix.  Default: false        
function is_matrix(A,m,n,square=false) =
    is_vector(A[0],n) && is_vector(A*(0*A[0]),m) &&
    (!square || len(A)==len(A[0]));


// Section: Comparisons and Logic

// Function: approx()
// Usage:
//   approx(a,b,[eps])
// Description:
//   Compares two numbers or vectors, and returns true if they are closer than `eps` to each other.
// Arguments:
//   a = First value.
//   b = Second value.
//   eps = The maximum allowed difference between `a` and `b` that will return true.
// Example:
//   approx(-0.3333333333,-1/3);  // Returns: true
//   approx(0.3333333333,1/3);    // Returns: true
//   approx(0.3333,1/3);          // Returns: false
//   approx(0.3333,1/3,eps=1e-3);  // Returns: true
//   approx(PI,3.1415926536);     // Returns: true
function approx(a,b,eps=EPSILON) =
    a==b? true :
    a*0!=b*0? false :
    is_list(a)? ([for (i=idx(a)) if(!approx(a[i],b[i],eps=eps)) 1] == []) :
    (abs(a-b) <= eps);


function _type_num(x) =
    is_undef(x)?  0 :
    is_bool(x)?   1 :
    is_num(x)?    2 :
    is_nan(x)?    3 :
    is_string(x)? 4 :
    is_list(x)?   5 : 6;


// Function: compare_vals()
// Usage:
//   compare_vals(a, b);
// Description:
//   Compares two values.  Lists are compared recursively.
//   Returns <0 if a<b.  Returns >0 if a>b.  Returns 0 if a==b.
//   If types are not the same, then undef < bool < num < str < list < range.
// Arguments:
//   a = First value to compare.
//   b = Second value to compare.
function compare_vals(a, b) =
    (a==b)? 0 :
    let(t1=_type_num(a), t2=_type_num(b)) (t1!=t2)? (t1-t2) :
    is_list(a)? compare_lists(a,b) :
    is_nan(a)? 0 :
    (a<b)? -1 : (a>b)? 1 : 0;


// Function: compare_lists()
// Usage:
//   compare_lists(a, b)
// Description:
//   Compare contents of two lists using `compare_vals()`.
//   Returns <0 if `a`<`b`.
//   Returns 0 if `a`==`b`.
//   Returns >0 if `a`>`b`.
// Arguments:
//   a = First list to compare.
//   b = Second list to compare.
function compare_lists(a, b) =
    a==b? 0 : let(
        cmps = [
            for(i=[0:1:min(len(a),len(b))-1]) let(
                cmp = compare_vals(a[i],b[i])
            ) if(cmp!=0) cmp
        ]
    ) cmps==[]? (len(a)-len(b)) : cmps[0];


// Function: any()
// Description:
//   Returns true if any item in list `l` evaluates as true.
//   If `l` is a lists of lists, `any()` is applied recursively to each sublist.
// Arguments:
//   l = The list to test for true items.
// Example:
//   any([0,false,undef]);  // Returns false.
//   any([1,false,undef]);  // Returns true.
//   any([1,5,true]);       // Returns true.
//   any([[0,0], [0,0]]);   // Returns false.
//   any([[0,0], [1,0]]);   // Returns true.
function any(l, i=0, succ=false) =
    (i>=len(l) || succ)? succ :
    any(
        l, i=i+1, succ=(
            is_list(l[i])? any(l[i]) :
            !(!l[i])
        )
    );


// Function: all()
// Description:
//   Returns true if all items in list `l` evaluate as true.
//   If `l` is a lists of lists, `all()` is applied recursively to each sublist.
// Arguments:
//   l = The list to test for true items.
// Example:
//   all([0,false,undef]);  // Returns false.
//   all([1,false,undef]);  // Returns false.
//   all([1,5,true]);       // Returns true.
//   all([[0,0], [0,0]]);   // Returns false.
//   all([[0,0], [1,0]]);   // Returns false.
//   all([[1,1], [1,1]]);   // Returns true.
function all(l, i=0, fail=false) =
    (i>=len(l) || fail)? (!fail) :
    all(
        l, i=i+1, fail=(
            is_list(l[i])? !all(l[i]) :
            !l[i]
        )
    );


// Function: count_true()
// Usage:
//   count_true(l)
// Description:
//   Returns the number of items in `l` that evaluate as true.
//   If `l` is a lists of lists, this is applied recursively to each
//   sublist.  Returns the total count of items that evaluate as true
//   in all recursive sublists.
// Arguments:
//   l = The list to test for true items.
//   nmax = If given, stop counting if `nmax` items evaluate as true.
// Example:
//   count_true([0,false,undef]);  // Returns 0.
//   count_true([1,false,undef]);  // Returns 1.
//   count_true([1,5,false]);      // Returns 2.
//   count_true([1,5,true]);       // Returns 3.
//   count_true([[0,0], [0,0]]);   // Returns 0.
//   count_true([[0,0], [1,0]]);   // Returns 1.
//   count_true([[1,1], [1,1]]);   // Returns 4.
//   count_true([[1,1], [1,1]], nmax=3);  // Returns 3.
function count_true(l, nmax=undef, i=0, cnt=0) =
    (i>=len(l) || (nmax!=undef && cnt>=nmax))? cnt :
    count_true(
        l=l, nmax=nmax, i=i+1, cnt=cnt+(
            is_list(l[i])? count_true(l[i], nmax=nmax-cnt) :
            (l[i]? 1 : 0)
        )
    );



// Section: Calculus

// Function: deriv()
// Usage: deriv(data, [h], [closed])
// Description:
//   Computes a numerical derivative estimate of the data, which may be scalar or vector valued.
//   The `h` parameter gives the step size of your sampling so the derivative can be scaled correctly. 
//   If the `closed` parameter is true the data is assumed to be defined on a loop with data[0] adjacent to
//   data[len(data)-1].  This function uses a symetric derivative approximation
//   for internal points, f'(t) = (f(t+h)-f(t-h))/2h.  For the endpoints (when closed=false) the algorithm
//   uses a two point method if sufficient points are available: f'(t) = (3*(f(t+h)-f(t)) - (f(t+2*h)-f(t+h)))/2h.
//   .
//   If `h` is a vector then it is assumed to be nonuniform, with h[i] giving the sampling distance
//   between data[i+1] and data[i], and the data values will be linearly resampled at each corner
//   to produce a uniform spacing for the derivative estimate.  At the endpoints a single point method
//   is used: f'(t) = (f(t+h)-f(t))/h.  
function deriv(data, h=1, closed=false) =
    is_vector(h) ? _deriv_nonuniform(data, h, closed=closed) :
    let( L = len(data) )
    closed? [
        for(i=[0:1:L-1])
        (data[(i+1)%L]-data[(L+i-1)%L])/2/h
    ] :
    let(
        first =
            L<3? data[1]-data[0] : 
            3*(data[1]-data[0]) - (data[2]-data[1]),
        last =
            L<3? data[L-1]-data[L-2]:
            (data[L-3]-data[L-2])-3*(data[L-2]-data[L-1])
    ) [
        first/2/h,
        for(i=[1:1:L-2]) (data[i+1]-data[i-1])/2/h,
        last/2/h
    ];


function _dnu_calc(f1,fc,f2,h1,h2) =
    let(
        f1 = h2<h1 ? lerp(fc,f1,h2/h1) : f1 , 
        f2 = h1<h2 ? lerp(fc,f2,h1/h2) : f2
    )
    (f2-f1) / 2 / min([h1,h2]);


function _deriv_nonuniform(data, h, closed) =
    assert(len(h) == len(data)-(closed?0:1),str("Vector valued h must be length ",len(data)-(closed?0:1)))
    let(
      L = len(data)
    )
    closed? [for(i=[0:1:L-1])
    	        _dnu_calc(data[(L+i-1)%L], data[i], data[(i+1)%L], select(h,i-1), h[i]) ]
    : [
        (data[1]-data[0])/h[0],
        for(i=[1:1:L-2]) _dnu_calc(data[i-1],data[i],data[i+1], h[i-1],h[i]),
        (data[L-1]-data[L-2])/h[L-2]                            
      ];


// Function: deriv2()
// Usage: deriv2(data, [h], [closed])
// Description:
//   Computes a numerical esimate of the second derivative of the data, which may be scalar or vector valued.
//   The `h` parameter gives the step size of your sampling so the derivative can be scaled correctly. 
//   If the `closed` parameter is true the data is assumed to be defined on a loop with data[0] adjacent to
//   data[len(data)-1].  For internal points this function uses the approximation 
//   f''(t) = (f(t-h)-2*f(t)+f(t+h))/h^2.  For the endpoints (when closed=false) the algorithm
//   when sufficient points are available the method is either the four point expression
//   f''(t) = (2*f(t) - 5*f(t+h) + 4*f(t+2*h) - f(t+3*h))/h^2 or if five points are available
//   f''(t) = (35*f(t) - 104*f(t+h) + 114*f(t+2*h) - 56*f(t+3*h) + 11*f(t+4*h)) / 12h^2
function deriv2(data, h=1, closed=false) =
    let( L = len(data) )
    closed? [
        for(i=[0:1:L-1])
        (data[(i+1)%L]-2*data[i]+data[(L+i-1)%L])/h/h
    ] :
    let(
        first = L<3? undef : 
            L==3? data[0] - 2*data[1] + data[2] :
            L==4? 2*data[0] - 5*data[1] + 4*data[2] - data[3] :
            (35*data[0] - 104*data[1] + 114*data[2] - 56*data[3] + 11*data[4])/12, 
        last = L<3? undef :
            L==3? data[L-1] - 2*data[L-2] + data[L-3] :
            L==4? -2*data[L-1] + 5*data[L-2] - 4*data[L-3] + data[L-4] :
            (35*data[L-1] - 104*data[L-2] + 114*data[L-3] - 56*data[L-4] + 11*data[L-5])/12
    ) [
        first/h/h,
        for(i=[1:1:L-2]) (data[i+1]-2*data[i]+data[i-1])/h/h,
        last/h/h
    ];


// Function: deriv3()
// Usage: deriv3(data, [h], [closed])
// Description:
//   Computes a numerical third derivative estimate of the data, which may be scalar or vector valued.
//   The `h` parameter gives the step size of your sampling so the derivative can be scaled correctly. 
//   If the `closed` parameter is true the data is assumed to be defined on a loop with data[0] adjacent to
//   data[len(data)-1].  This function uses a five point derivative estimate, so the input must include five points:
//   f'''(t) = (-f(t-2*h)+2*f(t-h)-2*f(t+h)+f(t+2*h)) / 2h^3.  At the first and second points from the end
//   the estimates are f'''(t) = (-5*f(t)+18*f(t+h)-24*f(t+2*h)+14*f(t+3*h)-3*f(t+4*h)) / 2h^3 and
//   f'''(t) = (-3*f(t-h)+10*f(t)-12*f(t+h)+6*f(t+2*h)-f(t+3*h)) / 2h^3.
function deriv3(data, h=1, closed=false) =
    let(
        L = len(data),
        h3 = h*h*h
    )
    assert(L>=5, "Need five points for 3rd derivative estimate")
    closed? [
        for(i=[0:1:L-1])
        (-data[(L+i-2)%L]+2*data[(L+i-1)%L]-2*data[(i+1)%L]+data[(i+2)%L])/2/h3
    ] :
    let(
        first=(-5*data[0]+18*data[1]-24*data[2]+14*data[3]-3*data[4])/2,
        second=(-3*data[0]+10*data[1]-12*data[2]+6*data[3]-data[4])/2,
        last=(5*data[L-1]-18*data[L-2]+24*data[L-3]-14*data[L-4]+3*data[L-5])/2,
        prelast=(3*data[L-1]-10*data[L-2]+12*data[L-3]-6*data[L-4]+data[L-5])/2
    ) [
        first/h3,
        second/h3,
        for(i=[2:1:L-3]) (-data[i-2]+2*data[i-1]-2*data[i+1]+data[i+2])/2/h3,
        prelast/h3,
        last/h3
    ];


// Section: Complex Numbers

// Function: C_times()
// Usage: C_times(z1,z2)
// Description:
//   Multiplies two complex numbers.  
function C_times(z1,z2) = [z1.x*z2.x-z1.y*z2.y,z1.x*z2.y+z1.y*z2.x];

// Function: C_div()
// Usage: C_div(z1,z2)
// Description:
//   Divides z1 by z2.  
function C_div(z1,z2) = let(den = z2.x*z2.x + z2.y*z2.y)
   [(z1.x*z2.x + z1.y*z2.y)/den, (z1.y*z2.x-z1.x*z2.y)/den];


// Section: Polynomials

// Function: polynomial()
// Usage:
//   polynomial(p, z)
// Description:
//   Evaluates specified real polynomial, p, at the complex or real input value, z.
//   The polynomial is specified as p=[a_n, a_{n-1},...,a_1,a_0]
//   where a_n is the z^n coefficient.  Polynomial coefficients are real.

// Note: this should probably be recoded to use division by [1,-z], which is more accurate
// and avoids overflow with large coefficients, but requires poly_div to support complex coefficients.  
function polynomial(p, z, k, zk, total) =
   is_undef(k) ? polynomial(p, z, len(p)-1, is_num(z)? 1 : [1,0], is_num(z) ? 0 : [0,0]) :
   k==-1 ? total :
   polynomial(p, z, k-1, is_num(z) ? zk*z : C_times(zk,z), total+zk*p[k]);


// Function: poly_mult()
// Usage:
//   polymult(p,q)
//   polymult([p1,p2,p3,...])
// Description:
//   Given a list of polynomials represented as real coefficient lists, with the highest degree coefficient first, 
//   computes the coefficient list of the product polynomial.  
function poly_mult(p,q) = 
  is_undef(q) ?
     assert(is_list(p) && (is_vector(p[0]) || p[0]==[]), "Invalid arguments to poly_mult")
     len(p)==2 ? poly_mult(p[0],p[1]) 
               : poly_mult(p[0], poly_mult(select(p,1,-1)))
  :
  _poly_trim(
  [
  for(n = [len(p)+len(q)-2:-1:0])
      sum( [for(i=[0:1:len(p)-1])
           let(j = len(p)+len(q)- 2 - n - i)
           if (j>=0 && j<len(q)) p[i]*q[j]
               ])
   ]);        


// Function: poly_div()
// Usage:
//    [quotient,remainder] = poly_div(n,d)
// Description:
//    Computes division of the numerator polynomial by the denominator polynomial and returns
//    a list of two polynomials, [quotient, remainder].  If the division has no remainder then
//    the zero polynomial [] is returned for the remainder.  Similarly if the quotient is zero
//    the returned quotient will be [].  
function poly_div(n,d,q=[]) =
    assert(len(d)>0 && d[0]!=0 , "Denominator is zero or has leading zero coefficient")
    len(n)<len(d) ? [q,_poly_trim(n)] : 
    let(
      t = n[0] / d[0],
      newq = concat(q,[t]),
      newn =  [for(i=[1:1:len(n)-1]) i<len(d) ? n[i] - t*d[i] : n[i]]
    )  
    poly_div(newn,d,newq);


// Internal Function: _poly_trim()
// Usage:
//    _poly_trim(p,[eps])
// Description:
//    Removes leading zero terms of a polynomial.  By default zeros must be exact,
//    or give epsilon for approximate zeros.  
function _poly_trim(p,eps=0) =
  let(  nz = [for(i=[0:1:len(p)-1]) if (!approx(p[i],0,eps)) i])
  len(nz)==0 ? [] : select(p,nz[0],-1);


// Function: poly_add()
// Usage:
//    sum = poly_add(p,q)
// Description:
//    Computes the sum of two polynomials.  
function poly_add(p,q) = 
  let(  plen = len(p),
        qlen = len(q),
        long = plen>qlen ? p : q,
        short = plen>qlen ? q : p
     )
   _poly_trim(long + concat(repeat(0,len(long)-len(short)),short));


// Function: poly_roots()
// Usage:
//   poly_roots(p,[tol])
// Description:
//   Returns all complex roots of the specified real polynomial p.
//   The polynomial is specified as p=[a_n, a_{n-1},...,a_1,a_0]
//   where a_n is the z^n coefficient.  The tol parameter gives
//   the stopping tolerance for the iteration.  The polynomial
//   must have at least one non-zero coefficient.  Convergence is poor
//   if the polynomial has any repeated roots other than zero.  
// Arguments:
//   p = polynomial coefficients with higest power coefficient first
//   tol = tolerance for iteration.  Default: 1e-14

// Uses the Aberth method https://en.wikipedia.org/wiki/Aberth_method
//
// Dario Bini. "Numerical computation of polynomial zeros by means of Aberth's Method", Numerical Algorithms, Feb 1996.
// https://www.researchgate.net/publication/225654837_Numerical_computation_of_polynomial_zeros_by_means_of_Aberth's_method

function poly_roots(p,tol=1e-14,error_bound=false) =
  assert(p!=[], "Input polynomial must have a nonzero coefficient")
  assert(is_vector(p), "Input must be a vector")
  p[0] == 0 ? poly_roots(slice(p,1,-1),tol=tol,error_bound=error_bound) :    // Strip leading zero coefficients
  p[len(p)-1] == 0 ?                                       // Strip trailing zero coefficients
      let( solutions = poly_roots(select(p,0,-2),tol=tol, error_bound=error_bound))
      (error_bound ? [ [[0,0], each solutions[0]], [0, each solutions[1]]]
                  : [[0,0], each solutions]) :
  len(p)==1 ? (error_bound ? [[],[]] : []) :               // Nonzero constant case has no solutions
  len(p)==2 ? let( solution = [[-p[1]/p[0],0]])            // Linear case needs special handling
              (error_bound ? [solution,[0]] : solution)
  : 
  let(
      n = len(p)-1,   // polynomial degree
      pderiv = [for(i=[0:n-1]) p[i]*(n-i)],
         
      s = [for(i=[0:1:n]) abs(p[i])*(4*(n-i)+1)],  // Error bound polynomial from Bini

      // Using method from: http://www.kurims.kyoto-u.ac.jp/~kyodo/kokyuroku/contents/pdf/0915-24.pdf
      beta = -p[1]/p[0]/n,
      r = 1+pow(abs(polynomial(p,beta)/p[0]),1/n),
      init = [for(i=[0:1:n-1])                // Initial guess for roots       
               let(angle = 360*i/n+270/n/PI)
               [beta,0]+r*[cos(angle),sin(angle)]
             ],
      roots = _poly_roots(p,pderiv,s,init,tol=tol),
      error = error_bound ? [for(xi=roots) n * (norm(polynomial(p,xi))+tol*polynomial(s,norm(xi))) /
                                abs(norm(polynomial(pderiv,xi))-tol*polynomial(s,norm(xi)))] : 0
    )
    error_bound ? [roots, error] : roots;

// p = polynomial
// pderiv = derivative polynomial of p
// z = current guess for the roots
// tol = root tolerance
// i=iteration counter
function _poly_roots(p, pderiv, s, z, tol, i=0) =
    assert(i<45, str("Polyroot exceeded iteration limit.  Current solution:", z))
    let(
        n = len(z),
        svals = [for(zk=z) tol*polynomial(s,norm(zk))],
        p_of_z = [for(zk=z) polynomial(p,zk)],
        done = [for(k=[0:n-1]) norm(p_of_z[k])<=svals[k]],
        newton = [for(k=[0:n-1]) C_div(p_of_z[k], polynomial(pderiv,z[k]))],
        zdiff = [for(k=[0:n-1]) sum([for(j=[0:n-1]) if (j!=k) C_div([1,0], z[k]-z[j])])],
        w = [for(k=[0:n-1]) done[k] ? [0,0] : C_div( newton[k],
                                                     [1,0] - C_times(newton[k], zdiff[k]))]
    )
    all(done) ? z : _poly_roots(p,pderiv,s,z-w,tol,i+1);


// Function: real_roots()
// Usage:
//   real_roots(p, [eps], [tol])
// Description:
//   Returns the real roots of the specified real polynomial p.
//   The polynomial is specified as p=[a_n, a_{n-1},...,a_1,a_0]
//   where a_n is the x^n coefficient.  This function works by
//   computing the complex roots and returning those roots where
//   the imaginary part is closed to zero.  By default it uses a computed
//   error bound from the polynomial solver to decide whether imaginary
//   parts are zero.  You can specify eps, in which case the test is
//   z.y/(1+norm(z)) < eps.  Because
//   of poor convergence and higher error for repeated roots, such roots may
//   be missed by the algorithm because their imaginary part is large.  
// Arguments:
//   p = polynomial to solve as coefficient list, highest power term first
//   eps = used to determine whether imaginary parts of roots are zero
//   tol = tolerance for the complex polynomial root finder

function real_roots(p,eps=undef,tol=1e-14) =
   let( 
       roots_err = poly_roots(p,error_bound=true),
       roots = roots_err[0],
       err = roots_err[1]
   )
   is_def(eps) ? [for(z=roots) if (abs(z.y)/(1+norm(z))<eps) z.x]
               : [for(i=idx(roots)) if (abs(roots[i].y)<=err[i]) roots[i].x];

// vim: expandtab tabstop=4 shiftwidth=4 softtabstop=4 nowrap
