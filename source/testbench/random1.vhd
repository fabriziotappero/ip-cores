-- Random number generators (RNG)
-- Author: Gnanasekaran Swaminathan

-- Random number generator algorithm is due to D. E. Knuth as
-- given in W. H. Press et al., "Numerical Recipes in C: The Art
-- of Scientific Computing," New York: Cambridge Univ. Press, 1988.
-- Translated into VHDL by Gnanasekaran Swaminathan <gs4t@virginia.edu>

-- Other algorithms are from libg++ by Dirk Grunwald <grunwald@cs.uiuc.edu>
-- Translated into VHDL by Gnanasekaran Swaminathan <gs4t@virginia.edu>

--  math functions factorial, "**", exp, ln, and sqrt are from
--  math_functions package due to Tom Ashworth <ashworth@ERC.MsState.Edu>

--  USAGE:
--  Following 10 random variables are supported:
--  	Uniform, Negative Exponential, Poisson, Normal, Log Normal,
--	Erlang, Geometric, Hyper Geometric, Binomial, Weibull.
--  
--  Each random variable has its own copy of random number generator.
--  Hence, you can have as many random variables of any type as you
--  want only limited by the amount of memory your system has.
--  
--  First a random variable must be initialized using the corresponding
--  Init function. Thenceforth, the new value of the random variable can
--  can be obtained by a call to GenRnd.
--
--  EXAMPLES:
--  Uniform random number in [-50, 100] with seed 7
--  process
--  	variable unf:	Uniform := InitUniform(7, -50.0, 100.0);
--  	variable rnd:	real := 0;
--  begin
--  	GenRnd(unf);
--  	rnd := unf.rnd;			 -- -50 <= rnd <= 100
--  end;
--
--  Negative exponential distribution with mean 25 and seed 13
--   variable nexp: NegExp := InitNegExp(13, 25.0);
--   GenRnd(nexp)
--   rnd := nexp.rnd;			 --  0 <= rnd <= real'High
--
--
--  Please send bug reports and additions and subtractions
--  to me at gs4t@virginia.edu
--
--  Enjoy!
--  Gnanasekaran Swaminathan

package RNG is
	subtype rn is Real range 0.0 to 1.0;
	subtype PositiveReal is Real range 0.0 to Real'High;
	type IntA0to98 is array (0 to 98) of Integer;
	type distribution is (  UniformDist,
				NegExpDist,
				PoissonDist,
				BinomialDist,
				GeomDist,
				HypGeomDist,
				NormalDist,
				LogNormalDist,
				ErlangDist,
				WeibullDist
				);
	type	realParams	is array (0 to 10) of Real;
	subtype intParams	is Integer;
	subtype booleanParams	is Boolean;

	type RndNum is
	record
		rnd		: rn;
		init		: Integer;
		iy		: Integer;
		ir		: IntA0to98;
		status		: Boolean;
	end record;

	type random is record
		rnd:		Real;
		r:		RndNum;
		a:		realParams;
		b:		intParams;
		c:		booleanParams;
		dist:		distribution;
	end record;

	type Uniform is
	record
		rnd		: Real;
		pHigh		: Real;
		pLow		: Real;
		delta		: Real;
		r		: RndNum;
	end record;

	type NegExp is
	record
		rnd		: Real;
		pMean		: PositiveReal;
		r		: RndNum;
	end record;

	type Poisson is
	record
		rnd		: Real;
		pMean		: PositiveReal;
		r		: RndNum;
	end record;

	type Normal is
	record
		rnd		: Real;
		pMean		: Real;
		pStdDev		: Real;
		pVariance	: Real;
		CachedNormal	: Real;
		haveCachedNormal: Boolean;
		r		: RndNum;
	end record;

	type LogNormal is
	record
		rnd		: Real;
		pLogMean	: Real;
		pLogVariance	: Real;
		n		: Normal;
	end record;

	type Erlang is
	record
		rnd		: Real;
		pMean		: Real;
		pVariance	: Real;
		a		: Real;
		k		: Integer;
		r		: RndNum;
	end record;

	type Binomial is
	record
		rnd		: Real;
		pU		: Real;
		pN		: Integer;
		r		: RndNum;
	end record;

	type Geom is
	record
		rnd		: Real;
		pMean		: Real;
		r		: RndNum;
	end record;

	type HypGeom is
	record
		rnd		: Real;
		pMean		: Real;
		pVariance	: Real;
		pP		: Real;
		r		: RndNum;
	end record;

	type Weibull is
	record
		rnd		: Real;
		pAlpha		: Real;
		pInvAlpha	: Real;
		pBeta		: Real;
		r		: RndNum;
	end record;
		
	constant LN2: real := 0.693147181;
	
	function factorial (n: integer) return real;
	function "**"(z: Real; y: Real) return Real;
	function ln  (z: Real) return Real;
	function ln1p(z: Real) return Real;
	function exp (z: Real) return Real;
	function sqrt(z: Real) return Real;

	procedure GenRnd(r: inout RndNum; seed: in Integer := 13);
	procedure GenRnd(r: inout Uniform);
	procedure GenRnd(r: inout NegExp);
	procedure GenRnd(r: inout Poisson);
	procedure GenRnd(r: inout Normal);
	procedure GenRnd(r: inout LogNormal);
	procedure GenRnd(r: inout Erlang);
	procedure GenRnd(r: inout Binomial);
	procedure GenRnd(r: inout Geom);
	procedure GenRnd(r: inout HypGeom);
	procedure GenRnd(r: inout Weibull);
	procedure GenRnd(r: inout random);

	--  Initialization functions
	function InitRndNum (seed: in Integer := 13) return RndNum;
	function InitUniform (seed: Integer := 13;
			      low: Real := 0.0;
			      high: Real := 100.0) return Uniform;
	function InitNegExp (seed: Integer := 13;
			     mean: PositiveReal := 50.0) return NegExp;
	function InitPoisson (seed: Integer := 13;
			      mean: PositiveReal := 50.0) return Poisson;
	function InitNormal (seed: Integer := 13;
			     mean: Real := 0.0;
			     var: Real := 100.0) return Normal;
	function InitLogNormal (seed: Integer := 13;
				mean: Real := 50.0;
				var: Real := 100.0) return LogNormal;
	function InitErlang (seed: Integer := 13;
			     mean: Real := 50.0;
			     var: Real := 100.0) return Erlang;
	function InitBinomial (seed: Integer := 13;
			       n: Integer := 0;
			       u: Real := 0.0) return Binomial;
	function InitGeom (seed: Integer := 13;
			   mean: Real := 0.0) return Geom;
	function InitHypGeom (seed: Integer := 13;
			      mean: Real := 0.0;
			      var:  Real := 0.0) return HypGeom;
	function InitWeibull (seed: Integer := 13;
			      alpha: Real := 0.0;
			      beta:  Real := 0.0) return Weibull;
		
	function InitUniform (low: Real := 0.0;
			      high: Real := 100.0;
			      seed: Integer := 13) return random;
	function InitNegExp (mean: PositiveReal := 50.0;
			     seed: Integer := 13) return random;
	function InitPoisson (mean: PositiveReal := 50.0;
			      seed: Integer := 13) return random;
	function InitNormal (mean: Real := 0.0;
			     var: Real := 100.0;
			     seed: Integer := 13) return random;
	function InitLogNormal (mean: Real := 50.0;
				var: Real := 100.0;
				seed: Integer := 13) return random;
	function InitErlang (mean: Real := 50.0;
			     var: Real := 100.0;
			     seed: Integer := 13) return random;
	function InitBinomial (n: Integer := 0;
			       u: Real := 0.0;
			       seed: Integer := 13) return random;
	function InitGeom (mean: Real := 0.0;
			   seed: Integer := 13) return random;
	function InitHypGeom (mean: Real := 0.0;
			      var:  Real := 0.0;
			      seed: Integer := 13) return random;
	function InitWeibull (alpha: Real := 0.0;
			      beta:  Real := 0.0;
			      seed: Integer := 13) return random;
		
	--  conversion functions
	function CvtRandom (uni: in Uniform) return random;
	function CvtRandom (nex: in NegExp) return random;
	function CvtRandom (poi: in Poisson) return random;
	function CvtRandom (nom: in Normal) return random;
	function CvtRandom (lnom: in LogNormal) return random;
	function CvtRandom (erl: in Erlang) return random;
	function CvtRandom (bin: in Binomial) return random;
	function CvtRandom (geo: in Geom) return random;
	function CvtRandom (hypg: in HypGeom) return random;
	function CvtRandom (wei: in Weibull) return random;

	function CvtUniform (r: in random) return Uniform;
	function CvtNegExp  (r: in random) return NegExp;
	function CvtPoisson (r: in random) return Poisson;
	function CvtNormal  (r: in random) return Normal;
	function CvtLogNormal (r: in random) return LogNormal;
	function CvtErlang  (r: in random) return Erlang;
	function CvtBinomial (r: in random) return Binomial;
	function CvtGeom    (r: in random) return Geom;
	function CvtHypGeom (r: in random) return HypGeom;
	function CvtWeibull (r: in random) return Weibull;
		
end RNG;

package body RNG is
-------------------------------------------------------------------------------
    function factorial(n : integer) return real is
        variable result : Integer;
    begin
        result := 1;
        if (n > 1) then
            for i in 2 to n loop
                result := result * i;
            end loop;
        end if;
        return Real(result);
    end factorial;
-------------------------------------------------------------------------------
	function "**" (z: Real; y: Real) return Real is
	begin
		return exp(y * ln(z));
	end;
-------------------------------------------------------------------------------
    function ln (z : real) return real is
        variable Result : real;
        variable tmpx   : real;
        variable n      : integer;
        variable acc    : integer;
    begin
        assert not (z <= 0.0)
            report "ERROR : Can't take the ln of a negative number"
                severity error;
 
        tmpx := z;
        n := 0;
        --reduce z to a number less than one in order
        --to use a more accurate model that converges
        --much faster. This will render the log function
        --to ln(z) = ln(tmpx) + n * ln(2) where ln(2) is
        --defined as a constant.
        while (tmpx >= 1.0) loop
            tmpx := tmpx / 2.0;
            n    := n +1;
        end loop;
 
        --acc determines the number of iterations of the series
        --these values are results from comparisons with the SUN
        --log() C function at a accuracy of at least 0.00001.
        if (tmpx < 0.5) then
            acc := 100;
        else
            acc := 20;
        end if;
 
        tmpx   := tmpx - 1.0;
        result := real(n) * LN2;
        n := 1;
 
        while (n < acc) loop
            result := result + (tmpx**n)/real(n) - (tmpx**(n+1))/real(n+1);
            n := n +2;
        end loop;
 
        return Result;
    end ln;
-------------------------------------------------------------------------------
	function ln1p(z: Real) return Real is
	begin
		assert false
			report "ln1p is not implemented"
			severity error;
		return ln(z);
	end;
-------------------------------------------------------------------------------
    function exp (z : real) return real is
        variable result,tmp : real;
        variable i : integer;
    begin
        if (z = 0.0) then
            result := 1.0;
        else
            result := z + 1.0;
            i      := 2;
            tmp    := z*z/2.0;
            result := result + tmp;
 
            while (abs(tmp) > 0.000005) loop
                i      := i +1;
                tmp    := tmp * z / Real(i);
                result := result + tmp;
            end loop;
        end if;
        return result;
    end exp;
-------------------------------------------------------------------------------
	function sqrt(z: Real) return Real is
	begin
		assert z >= 0.0
			report "sqrt (negative number) is undefined"
			severity error;
		return z ** 0.5;
	end;
-------------------------------------------------------------------------------
	procedure GenRnd(r: inout RndNum; seed: in Integer := 13) is
		constant RN_M : Integer := 714025;
		constant RN_IA: Integer := 1366;
		constant RN_IC: Integer := 150889;
		variable j : Integer := 0;
	begin
		if (not r.status) then
			r.status := True;
			r.init := seed;
			r.init := abs ( (RN_IC - r.init) mod RN_M );
			for i in 0 to 1 loop for j in 1 to 97 loop
				r.init  := (RN_IA * r.init + RN_IC) mod RN_M;
				r.ir(j) := r.init;
			end loop; end loop;
			r.init := (RN_IA * r.init + RN_IC) mod RN_M;
			r.iy := r.init;
			r.rnd := REAL(r.iy) / REAL(RN_M);
			return;
		end if;

		j := 1 + 97 * r.iy / RN_M;
		assert (1 <= j and j <= 97)
			report "this cannon happen in GenRnd(RndNum)"
			severity error;
		r.iy	:= r.ir(j);
		r.init	:= (RN_IA * r.init + RN_IC) mod RN_M;
		r.ir(j) := r.init;
		r.rnd := REAL(r.iy) / REAL(RN_M);
	end GenRnd; -- RndNum
-------------------------------------------------------------------------------
	procedure GenRnd(r: inout Uniform) is
	begin
		assert r.r.status
			report "Uniform variable is not initialized"
			severity error;
		
		GenRnd(r.r);
		r.rnd  := r.pLow + r.delta * r.r.rnd;
	end GenRnd; -- Uniform
-------------------------------------------------------------------------------
	procedure GenRnd(r: inout NegExp) is
	begin
		assert r.r.status
			report "NegExp variable is not initialized"
			severity error;
		
		GenRnd(r.r);
		r.rnd := - r.pMean * ln(1.0 - r.r.rnd);
					--  ln1p will be better here
	end GenRnd; -- NegExp
-------------------------------------------------------------------------------
	procedure GenRnd(r: inout Poisson) is
		variable product: Real := 1.0;
		variable bound: Real := 0.0;
	begin
		assert r.r.status
			report "Poisson variable is not initialized"
			severity error;
		
		bound := exp(-1.0 * r.pMean);
		r.rnd := -1.0;

		while (product >= bound) loop
			r.rnd := r.rnd + 1.0;
			GenRnd(r.r);
			product := product * r.r.rnd;
		end loop;
	end GenRnd; -- Poisson
-------------------------------------------------------------------------------
	procedure GenRnd(r: inout Normal) is
		variable v1: Real := 0.0;
		variable v2: Real := 0.0;
		variable w : Real := 0.0;
		variable x1: Real := 0.0;
		variable x2: Real := 0.0;
	begin
		assert r.r.status
			report "Normal variable is not initialized"
			severity error;
		
		if (r.haveCachedNormal) then
			r.haveCachedNormal := False;
			r.rnd := r.cachedNormal * r.pStdDev + r.pMean;
			return;
		end if;

		while (True) loop
			GenRnd(r.r);	v1 := 2.0 * r.r.rnd - 1.0;
			GenRnd(r.r);	v2 := 2.0 * r.r.rnd - 1.0;
			w := v1 * v1 + v2* v2;

			if ( w <= 1.0 ) then
				w  := sqrt(-2.0 * ln (w) / w);
				x1 := v1 * w;
				x2 := v2 * w;

				r.haveCachedNormal := True;
				r.CachedNormal     := x2;
				r.rnd := x1 * r.pStdDev + r.pMean;
				return;
			end if;
		end loop;
	end GenRnd; -- Normal

-------------------------------------------------------------------------------

	procedure GenRnd(r: inout LogNormal) is
	begin
		assert r.n.r.status
			report "LogNormal variable is not initialized"
			severity error;
		
		GenRnd(r.n);
		r.rnd := exp(r.n.rnd);
	end GenRnd; -- LogNormal
			
-------------------------------------------------------------------------------

	procedure GenRnd(r: inout Erlang) is
		variable prod : Real := 1.0;
	begin
		assert r.r.status
			report "Erlang variable is not initialized"
			severity error;

		for i in 1 to r.k loop
			GenRnd(r.r);
			prod := prod * r.r.rnd;
		end loop;
		r.rnd := - ln( prod ) / r.a;
	end GenRnd; -- Erlang
-------------------------------------------------------------------------------
	procedure GenRnd(r: inout Binomial) is
	begin
		assert r.r.status
			report "Binomial variable is not initialized"
			severity error;
		
		r.rnd := 0.0;
		for i in 1 to r.pN loop
			GenRnd(r.r);
			if (r.r.rnd < r.pU) then
				r.rnd := r.rnd + 1.0;
			end if;
		end loop;
	end GenRnd; -- Binomial

-------------------------------------------------------------------------------

	procedure GenRnd(r: inout Geom) is
	begin
		assert r.r.status
			report "Geom variable is not initialized"
			severity error;
		
		r.rnd := 1.0;
		GenRnd(r.r);
		while (r.r.rnd < r.pMean) loop
			r.rnd := r.rnd + 1.0;
			GenRnd(r.r);
		end loop;
	end GenRnd; -- Geom

-------------------------------------------------------------------------------

	procedure GenRnd(r: inout HypGeom) is
		variable z: Real := 0.0;
	begin
		assert r.r.status
			report "HypGeom variable is not initialized"
			severity error;
		
		GenRnd(r.r);
		if (r.r.rnd > r.pP) then
			z := 1.0 - r.pP;
		else
			z := r.pP;
		end if;
		GenRnd(r.r);
		r.rnd := -r.pMean * ln( r.r.rnd )/ (2.0*z);
	end GenRnd; -- HypGeom

-------------------------------------------------------------------------------

	procedure GenRnd(r: inout Weibull) is
	begin
		assert r.r.status
			report "Weibull variable r is not initialized"
			severity error;
		
		GenRnd(r.r);
		r.rnd := ( -r.pBeta * ln(1.0 - r.r.rnd) ) ** r.pInvAlpha;
	end GenRnd; -- Weibull

-------------------------------------------------------------------------------
	function InitRndNum (seed: in Integer := 13) return RndNum is
		constant RN_M : Integer := 714025;
		constant RN_IA: Integer := 1366;
		constant RN_IC: Integer := 150889;
		variable j : Integer := 0;
		variable r : RndNum;
	begin
		r.status := True;
		r.init := seed;
		r.init := abs ( (RN_IC - r.init) mod RN_M );
		for i in 0 to 1 loop for j in 1 to 97 loop
			r.init  := (RN_IA * r.init + RN_IC) mod RN_M;
			r.ir(j) := r.init;
		end loop; end loop;
		r.init := (RN_IA * r.init + RN_IC) mod RN_M;
		r.iy := r.init;
		return r;
	end InitRndNum;
-------------------------------------------------------------------------------
	function InitUniform (seed:	Integer := 13;
			      low:	Real := 0.0;
			      high:	Real := 100.0) return Uniform is
		variable r : Uniform;
	begin
		r.r.status := False;
		if (low < high) then
			r.pLow	:= low;
			r.pHigh	:= high;
		else
			r.pLow  := high;
			r.pHigh := low;
		end if;
		r.delta	:= high-low;
		GenRnd(r.r, seed);
		return r;
	end InitUniform;
-------------------------------------------------------------------------------
	function InitNegExp (seed:	Integer := 13;
			     mean:	PositiveReal := 50.0) return NegExp is
		variable r : NegExp;
	begin
		r.r.status := False;
		r.pMean := mean;
		GenRnd(r.r, seed);
		return r;
	end InitNegExp;
-------------------------------------------------------------------------------
	function InitPoisson (seed:	Integer := 13;
			      mean:	PositiveReal := 50.0) return Poisson is
		variable r : Poisson;
	begin
		r.r.status := False;
		r.pMean := mean;
		GenRnd(r.r, seed);
		return r;
	end InitPoisson;     
-------------------------------------------------------------------------------
	function InitNormal (seed:	Integer := 13;
			     mean:	Real := 0.0;
			     var:	Real := 100.0) return Normal is
		variable r : Normal;
	begin
		r.r.status := False;
		r.haveCachedNormal := False;
		r.pMean     := mean;
		r.pVariance := var;
		r.pStdDev   := sqrt(r.pVariance);
		GenRnd(r.r, seed);
		return r;
	end InitNormal;
-------------------------------------------------------------------------------
	function InitLogNormal (seed:	Integer := 13;
				mean:	Real := 50.0;
				var:	Real := 100.0) return LogNormal is
		variable m2: Real := 0.0;
		variable mn: Real := 0.0;
		variable sd: Real := 0.0;
		variable r : LogNormal;
	begin
		r.n.r.status := False;
		r.pLogMean     := mean;
		r.pLogVariance := var;
		m2 := r.pLogMean * r.pLogMean;
		mn := ln( m2 / sqrt(r.pLogVariance + m2) );
		sd := sqrt( ln( (r.pLogVariance + m2) / m2 ) );
		r.n := InitNormal(seed, mn, sd);
		return  r;
	end InitLogNormal;
-------------------------------------------------------------------------------
	function InitErlang (seed:	Integer := 13;
			     mean:	Real := 50.0;
			     var:	Real := 100.0) return Erlang is
		variable r : Erlang;
	begin
		r.r.status := False;
		r.pMean	    := mean;
		r.pVariance := var;
		r.k := Integer(r.pMean*r.pMean/r.pVariance+0.5);
		if (r.k <= 0) then
			r.k := 1;
		end if;
		r.a := Real(r.k) / r.pMean;
		GenRnd(r.r, seed);
		return  r;
	end InitErlang;
-------------------------------------------------------------------------------
	function InitBinomial (seed:	Integer := 13;
			       n:	Integer := 0;
			       u:	Real := 0.0) return Binomial is
		variable r : Binomial;
	begin
		r.r.status := False;
		r.pN := n;
		r.pU := u;
		GenRnd(r.r, seed);
		return r;
	end InitBinomial;
-------------------------------------------------------------------------------
	function InitGeom (seed:	Integer := 13;
			   mean:	Real := 0.0) return Geom is
		variable r : Geom;
	begin
		r.r.status := False;
		r.pMean := mean;
		GenRnd(r.r, seed);
		return r;
	end InitGeom;
-------------------------------------------------------------------------------
	function InitHypGeom (seed:	Integer := 13;
			  mean:	Real := 0.0;
			  var:	Real := 0.0) return HypGeom is
		variable z: Real := 0.0;
		variable r : HypGeom;
	begin
		r.r.status := False;
		r.pMean     := mean;
		r.pVariance := var;
		z    := r.pVariance / (r.pMean * r.pMean);
		z    := sqrt( (z-1.0) / (z+1.0) );
		r.pP := 0.5 * ( 1.0 - z );
		GenRnd(r.r, seed);
		return r;
	end InitHypGeom;
-------------------------------------------------------------------------------
	function InitWeibull (seed:	Integer := 13;
			      alpha:	Real := 0.0;
			      beta:	Real := 0.0) return Weibull is
	    	variable r : Weibull;
	begin
		r.r.status := False;
		r.pAlpha    := alpha;
		r.pBeta     := beta;
		r.pInvAlpha := 1.0 / r.pAlpha;
		GenRnd(r.r, seed);
		return r;
	end InitWeibull;
-------------------------------------------------------------------------------
	function InitUniform (low: Real := 0.0;
			      high: Real := 100.0;
			      seed: Integer := 13) return random is
	begin
	   return CvtRandom (InitUniform (seed, low, high));
	end InitUniform;
-------------------------------------------------------------------------------
	function InitNegExp (mean: PositiveReal := 50.0;
			     seed: Integer := 13) return random is
	begin
	   return CvtRandom (InitNegExp (seed, mean));
	end InitNegExp;
-------------------------------------------------------------------------------
	function InitPoisson (mean: PositiveReal := 50.0;
			      seed: Integer := 13) return random is
	begin
	   return CvtRandom (InitPoisson (seed, mean));
	end InitPoisson;
-------------------------------------------------------------------------------
	function InitNormal (mean: Real := 0.0;
			     var:  Real := 100.0;
			     seed: Integer := 13) return random is
	begin
	   return CvtRandom (InitNormal (seed, mean, var));
	end InitNormal;
-------------------------------------------------------------------------------
	function InitLogNormal (mean: Real := 50.0;
				var:  Real := 100.0;
				seed: Integer := 13) return random is
	begin
	   return CvtRandom (InitLogNormal (seed, mean, var));
	end InitLogNormal;
-------------------------------------------------------------------------------
	function InitErlang (mean: Real := 50.0;
			     var:  Real := 100.0;
			     seed: Integer := 13) return random is
	begin
	   return CvtRandom (InitErlang (seed, mean, var));
	end InitErlang;
-------------------------------------------------------------------------------
	function InitBinomial (n: Integer := 0;
			       u: Real := 0.0;
			       seed: Integer := 13) return random is
	begin
	   return CvtRandom (InitBinomial (seed, n, u));
	end InitBinomial;
-------------------------------------------------------------------------------
	function InitGeom (mean: Real := 0.0;
			   seed: Integer := 13) return random is
	begin
	   return CvtRandom (InitGeom (seed, mean));
	end InitGeom;
-------------------------------------------------------------------------------
	function InitHypGeom (mean: Real := 0.0;
			      var:  Real := 0.0;
			      seed: Integer := 13) return random is
	begin
	   return CvtRandom (InitHypGeom (seed, mean, var));
	end InitHypGeom;
-------------------------------------------------------------------------------
	function InitWeibull (alpha: Real := 0.0;
			      beta:  Real := 0.0;
			      seed: Integer := 13) return random is
	begin
	   return CvtRandom (InitWeibull (seed, alpha, beta));
	end InitWeibull;
-------------------------------------------------------------------------------
	procedure GenRnd (r: inout random) is
		variable unf : Uniform;
		variable nex : NegExp;
		variable poi : Poisson;
		variable nom : Normal;
		variable lnom : LogNormal;
		variable erl : Erlang;
		variable geo : Geom;
		variable hypg : HypGeom;
		variable bin : Binomial;
		variable wei : Weibull;
	begin
		case r.dist is
			when UniformDist =>
				unf := (r.rnd, r.a(2), r.a(1), r.a(3), r.r);
				GenRnd(unf);
				r.rnd := unf.rnd;
				r.r   := unf.r;
				return;
			when NegExpDist =>
				nex := (r.rnd, PositiveReal'(r.a(1)), r.r);
				GenRnd(nex);
				r.rnd := nex.rnd;
				r.r   := nex.r;
				return;
			when PoissonDist =>
				poi := (r.rnd, PositiveReal'(r.a(1)), r.r);
				GenRnd(poi);
				r.rnd := poi.rnd;
				r.r   := poi.r;
				return;
			when NormalDist =>
				nom := (r.rnd, r.a(1), r.a(3), r.a(2),
					r.a(4), r.c, r.r);
				GenRnd(nom);
				r.rnd := nom.rnd;
				r.r   := nom.r;
				r.a(4):= nom.CachedNormal;
				r.c   := nom.haveCachedNormal;
				return;
			when LogNormalDist =>
				nom := (r.rnd, r.a(1), r.a(3), r.a(2),
					r.a(4), r.c, r.r);
				lnom := (r.rnd, r.a(5), r.a(6), nom);
				GenRnd(lnom);
				r.rnd := lnom.rnd;
				r.r   := lnom.n.r;
				r.a(4):= lnom.n.CachedNormal;
				r.c   := lnom.n.haveCachedNormal;
				return;
			when ErlangDist =>
				erl := (r.rnd, r.a(1), r.a(2), r.a(3),
					r.b, r.r);
				GenRnd(erl);
				r.rnd := erl.rnd;
				r.r   := erl.r;
				return;
			when BinomialDist =>
				bin := (r.rnd, r.a(1), r.b, r.r);
				GenRnd(bin);
				r.rnd := bin.rnd;
				r.r   := bin.r;
				return;
			when GeomDist =>
				geo := (r.rnd, r.a(1), r.r);
				GenRnd(geo);
				r.rnd := geo.rnd;
				r.r   := geo.r;
				return;
			when HypGeomDist =>
				hypg := (r.rnd, r.a(1), r.a(2), r.a(3), r.r);
				GenRnd(hypg);
				r.rnd := hypg.rnd;
				r.r   := hypg.r;
				return;
			when WeibullDist =>
				wei := (r.rnd, r.a(1), r.a(3), r.a(2), r.r);
				GenRnd(wei);
				r.rnd := wei.rnd;
				r.r   := wei.r;
				return;
		end case;
	end GenRnd;
-------------------------------------------------------------------------------
	function CvtRandom (uni: in Uniform) return random is
		variable r : random;
	begin
		r.dist	:= UniformDist;
		r.rnd	:= uni.rnd;
		r.a(1)	:= uni.pLow;
		r.a(2)	:= uni.pHigh;
		r.a(3)	:= uni.delta;
		r.r	:= uni.r;
		return r;
	end CvtRandom;
-------------------------------------------------------------------------------
	function CvtRandom (nex: in NegExp) return random is
		variable r : random;
	begin
		r.dist	:= NegExpDist;
		r.rnd	:= nex.rnd;
		r.a(1)	:= nex.pMean;
		r.r	:= nex.r;
		return r;
	end CvtRandom;
-------------------------------------------------------------------------------
	function CvtRandom (poi: in Poisson) return random is
		variable r : random;
	begin
		r.dist	:= PoissonDist;
		r.rnd	:= poi.rnd;
		r.a(1)	:= poi.pMean;
		r.r	:= poi.r;
		return r;
	end CvtRandom;
-------------------------------------------------------------------------------
	function CvtRandom (nom: in Normal) return random is
		variable r : random;
	begin
		r.dist	:= NormalDist;
		r.rnd	:= nom.rnd;
		r.a(1)	:= nom.pMean;
		r.a(2)	:= nom.pVariance;
		r.a(3)	:= nom.pStdDev;
		r.a(4)	:= nom.CachedNormal;
		r.c	:= nom.haveCachedNormal;
		r.r	:= nom.r;
		return r;
	end CvtRandom;
-------------------------------------------------------------------------------
	function CvtRandom (lnom: in LogNormal) return random is
		variable r : random := CvtRandom(lnom.n);
	begin
		r.dist	:= LogNormalDist;
		r.a(5)	:= lnom.pLogMean;
		r.a(6)	:= lnom.pLogVariance;
		return r;
	end CvtRandom;
-------------------------------------------------------------------------------
	function CvtRandom (erl: in Erlang) return random is
		variable r : random;
	begin
		r.dist	:= ErlangDist;
		r.rnd	:= erl.rnd;
		r.a(1)	:= erl.pMean;
		r.a(2)	:= erl.pVariance;
		r.a(3)	:= erl.a;
		r.b	:= erl.k;
		r.r	:= erl.r;
		return r;
	end CvtRandom;
-------------------------------------------------------------------------------
	function CvtRandom (bin: in Binomial) return random is
		variable r : random;
	begin
		r.dist	:= BinomialDist;
		r.rnd	:= bin.rnd;
		r.a(1)	:= bin.pU;
		r.b	:= bin.pN;
		r.r	:= bin.r;
		return r;
	end CvtRandom;
-------------------------------------------------------------------------------
	function CvtRandom (geo: in Geom) return random is
		variable r : random;
	begin
		r.dist	:= GeomDist;
		r.a(1)	:= geo.pMean;
		r.r	:= geo.r;
		return r;
	end CvtRandom;
-------------------------------------------------------------------------------
	function CvtRandom (hypg: in HypGeom) return random is
		variable r : random;
	begin
		r.dist	:= HypGeomDist;
		r.a(1)	:= hypg.pMean;
		r.a(2)	:= hypg.pVariance;
		r.a(3)	:= hypg.pP;
		r.r	:= hypg.r;
		return r;
	end CvtRandom;
-------------------------------------------------------------------------------
	function CvtRandom (wei: in Weibull) return random is
		variable r : random;
	begin
		r.dist	:= WeibullDist;
		r.a(1)	:= wei.pAlpha;
		r.a(2)	:= wei.pBeta;
		r.a(3)	:= wei.pInvAlpha;
		r.r	:= wei.r;
		return r;
	end CvtRandom;
-------------------------------------------------------------------------------
	function CvtUniform (r: in random) return Uniform is
		variable uni : Uniform := (r.rnd, r.a(2), r.a(1), r.a(3), r.r);
	begin
		return uni;
	end CvtUniform;
-------------------------------------------------------------------------------
	function CvtNegExp (r: in random) return NegExp is
		variable nex : NegExp := (r.rnd, PositiveReal'(r.a(1)), r.r);
	begin
		return nex;
	end CvtNegExp;
-------------------------------------------------------------------------------
	function CvtPoisson (r: in random) return Poisson is
		variable poi : Poisson := (r.rnd, PositiveReal'(r.a(1)), r.r);
	begin
		return poi;
	end CvtPoisson;
-------------------------------------------------------------------------------
	function CvtNormal (r: in random) return Normal is
		variable nom : Normal := (r.rnd, r.a(1), r.a(3),
					  r.a(2), r.a(4), r.c, r.r);
	begin
		return nom;
	end CvtNormal;
-------------------------------------------------------------------------------
	function CvtLogNormal (r: in random) return LogNormal is
		variable nom : Normal := (r.rnd, r.a(1), r.a(3), r.a(2),
					  r.a(4), r.c, r.r);
		variable lnom : LogNormal := (r.rnd, r.a(5), r.a(6), nom);
	begin
		return lnom;
	end CvtLogNormal;
-------------------------------------------------------------------------------
	function CvtErlang (r: in random) return Erlang is
		variable erl : Erlang := (r.rnd, r.a(1), r.a(2),
					  r.a(3), r.b, r.r);
	begin
		return erl;
	end CvtErlang;
-------------------------------------------------------------------------------
	function CvtBinomial (r: in random) return Binomial is
		variable bin : Binomial := (r.rnd, r.a(1), r.b, r.r);
	begin
		return bin;
	end CvtBinomial;
-------------------------------------------------------------------------------
	function CvtGeom (r: in random) return Geom is
		variable geo : Geom := (r.rnd, r.a(1), r.r);
	begin
		return geo;
	end CvtGeom;
-------------------------------------------------------------------------------
	function CvtHypGeom (r: in random) return HypGeom is
		variable hypg : HypGeom := (r.rnd, r.a(1), r.a(2),
					    r.a(3), r.r);
	begin
		return hypg;
	end CvtHypGeom;
-------------------------------------------------------------------------------
	function CvtWeibull (r: in random) return Weibull is
		variable wei : Weibull := (r.rnd, r.a(1), r.a(3),
					   r.a(2), r.r);
	begin
	       return wei;
	end CvtWeibull;
-------------------------------------------------------------------------------
end RNG;

