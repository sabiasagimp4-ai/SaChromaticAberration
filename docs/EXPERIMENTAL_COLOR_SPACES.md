# Experimental Color Spaces — Formulae

This document contains only the mathematical definitions used in the color-space experiments.
All transforms are intended to be inverted after the per-component chromatic-aberration operation.

## Common opponent coordinates

\[
L=\frac{r+g+b}{3},\qquad
A=r-g,\qquad
B=\frac{r+g}{2}-b
\]

\[
r=L+\frac{B}{3}+\frac{A}{2},\qquad
g=L+\frac{B}{3}-\frac{A}{2},\qquad
b=L-\frac{2B}{3}
\]

---

## TOS-1 — Twisted Opponent Space

\[
\rho=\sqrt{A^2+B^2},\qquad
\phi=\operatorname{atan2}(B,A)
\]

\[
\rho_w=\rho^\gamma,\qquad
Z=\frac{\operatorname{asinh}(k(L-\frac12))}{\operatorname{asinh}(k/2)}
\]

\[
\theta=\phi+\alpha\sin(\pi Z)+\beta\rho_w^2
\]

\[
X=\rho_w\cos\theta,\qquad
Y=\rho_w\sin\theta
\]

\[
(k,\gamma,\alpha,\beta)=(3,\ 0.65,\ 1.1,\ 1.8)
\]

Inverse:

\[
\rho_w=\sqrt{X^2+Y^2},\qquad
\theta=\operatorname{atan2}(Y,X)
\]

\[
\rho=\rho_w^{1/\gamma}
\]

\[
L=\frac12+\frac{\sinh\!\left(Z\operatorname{asinh}(k/2)\right)}{k}
\]

\[
\phi=\theta-\alpha\sin(\pi Z)-\beta\rho_w^2
\]

\[
A=\rho\cos\phi,\qquad B=\rho\sin\phi
\]

---

## LRS-1 — Log Ratio Space

\[
a=\ln(r+\varepsilon),\qquad
b=\ln(g+\varepsilon),\qquad
c=\ln(b_{\mathrm{rgb}}+\varepsilon)
\]

\[
U=a-b,\qquad
V=\frac{a+b}{2}-c,\qquad
W=\frac{a+b+c}{3}
\]

\[
\varepsilon=10^{-4}
\]

Inverse:

\[
a=W+\frac{V}{3}+\frac{U}{2},\qquad
b=W+\frac{V}{3}-\frac{U}{2},\qquad
c=W-\frac{2V}{3}
\]

\[
r=e^a-\varepsilon,\qquad
g=e^b-\varepsilon,\qquad
b_{\mathrm{rgb}}=e^c-\varepsilon
\]

---

## MOS-1 — Möbius Opponent Space

\[
z=A+iB
\]

\[
w=\frac{z}{1+\kappa z},
\qquad
\kappa=0.45+0.25i
\]

\[
X=\Re(w),\qquad Y=\Im(w),\qquad Z=L
\]

Inverse:

\[
w=X+iY,\qquad
z=\frac{w}{1-\kappa w}
\]

\[
A=\Re(z),\qquad B=\Im(z),\qquad L=Z
\]

---

## RSS-1 — Reversible Sine Shear

\[
X=A+0.35\sin(2\pi L)
\]

\[
Y=B+0.45\sin(\pi X)
\]

\[
Z=L+0.18\sin(2\pi Y)
\]

Inverse:

\[
L=Z-0.18\sin(2\pi Y)
\]

\[
B=Y-0.45\sin(\pi X)
\]

\[
A=X-0.35\sin(2\pi L)
\]

---

## HCS-1 — Hyperbolic Cross Space

\[
\mathbf q=
\begin{bmatrix}
r-\frac12\\
g-\frac12\\
b-\frac12
\end{bmatrix}
\]

\[
M=
\begin{bmatrix}
1.15 & -0.65 & 0.20\\
-0.20 & 1.30 & -0.70\\
0.75 & 0.15 & -0.55
\end{bmatrix}
\]

\[
\mathbf y=M\mathbf q
\]

\[
\mathbf c=
\frac{\operatorname{asinh}(k\mathbf y)}{k},
\qquad k=2.6
\]

Inverse:

\[
\mathbf y=\frac{\sinh(k\mathbf c)}{k}
\]

\[
\mathbf q=M^{-1}\mathbf y
\]

\[
\begin{bmatrix}r\\g\\b\end{bmatrix}
=
\mathbf q+
\begin{bmatrix}\frac12\\\frac12\\\frac12\end{bmatrix}
\]

---

## CSL-1 — Complex Spiral Space

\[
\rho=\sqrt{A^2+B^2},\qquad
\phi=\operatorname{atan2}(B,A)
\]

\[
R=\frac{\operatorname{asinh}(c\rho)}{c},
\qquad c=2.8
\]

\[
Z=\frac{\operatorname{asinh}(k(L-\frac12))}{k},
\qquad k=2.2
\]

\[
\theta=
\phi+3.4\ln(1+5\rho^2)+1.7\sin(2\pi L)
\]

\[
X=R\cos\theta,\qquad Y=R\sin\theta
\]

Inverse:

\[
R=\sqrt{X^2+Y^2},\qquad
\theta=\operatorname{atan2}(Y,X)
\]

\[
\rho=\frac{\sinh(cR)}{c}
\]

\[
L=\frac12+\frac{\sinh(kZ)}{k}
\]

\[
\phi=
\theta-3.4\ln(1+5\rho^2)-1.7\sin(2\pi L)
\]

\[
A=\rho\cos\phi,\qquad B=\rho\sin\phi
\]

---

## LBS-1 — Lorentz Boost Space

\[
U=L-\frac12
\]

\[
\eta=1.75\tanh(2.7B)
\]

\[
X=\cosh(\eta)U+\sinh(\eta)A
\]

\[
Y=\sinh(\eta)U+\cosh(\eta)A
\]

\[
Z=B
\]

Inverse:

\[
\eta=1.75\tanh(2.7Z)
\]

\[
U=\cosh(\eta)X-\sinh(\eta)Y
\]

\[
A=-\sinh(\eta)X+\cosh(\eta)Y
\]

\[
L=U+\frac12,\qquad B=Z
\]

---

## PPS-1 — Projective Perspective Space

\[
\mathbf q=
\begin{bmatrix}
r-\frac12\\
g-\frac12\\
b-\frac12
\end{bmatrix},
\qquad
\mathbf c=
\begin{bmatrix}
0.42\\
-0.31\\
0.26
\end{bmatrix}
\]

\[
\mathbf y=
\frac{\mathbf q}{1+\mathbf c^\mathsf T\mathbf q}
\]

Inverse:

\[
\mathbf q=
\frac{\mathbf y}{1-\mathbf c^\mathsf T\mathbf y}
\]

\[
\begin{bmatrix}r\\g\\b\end{bmatrix}
=
\mathbf q+
\begin{bmatrix}\frac12\\\frac12\\\frac12\end{bmatrix}
\]

---

## RRS-1 — Rodrigues Radius Space

\[
\mathbf q=
\begin{bmatrix}
r-\frac12\\
g-\frac12\\
b-\frac12
\end{bmatrix},
\qquad
\mathbf n=
\frac{1}{\sqrt3}
\begin{bmatrix}
1\\1\\1
\end{bmatrix}
\]

\[
m=\|\mathbf q\|,\qquad
p=\mathbf n^\mathsf T\mathbf q
\]

\[
\theta=
5\tanh(1.8m)+2.6\sin(3.2p)
\]

\[
T(\mathbf q)=
\mathbf q\cos\theta+
(\mathbf n\times\mathbf q)\sin\theta+
\mathbf n(\mathbf n^\mathsf T\mathbf q)(1-\cos\theta)
\]

Inverse:

\[
T^{-1}(\mathbf y)=
\mathbf y\cos\theta-
(\mathbf n\times\mathbf y)\sin\theta+
\mathbf n(\mathbf n^\mathsf T\mathbf y)(1-\cos\theta)
\]

with

\[
\theta=
5\tanh(1.8\|\mathbf y\|)
+
2.6\sin(3.2\,\mathbf n^\mathsf T\mathbf y)
\]

---

## SDS-1 — Stereographic Disk Space

\[
\rho=\sqrt{A^2+B^2},\qquad
\phi=\operatorname{atan2}(B,A)
\]

\[
r_d=
\frac{\rho}{1+\sqrt{1+\rho^2}}
\]

\[
\theta=
\phi+7r_d+2\sin(2\pi L)(1-r_d)
\]

\[
X=r_d\cos\theta,\qquad
Y=r_d\sin\theta,\qquad
Z=L-\frac12
\]

Inverse:

\[
r_d=\sqrt{X^2+Y^2}
\]

\[
\rho=\frac{2r_d}{1-r_d^2}
\]

\[
L=Z+\frac12
\]

\[
\phi=
\operatorname{atan2}(Y,X)
-
7r_d
-
2\sin(2\pi L)(1-r_d)
\]

\[
A=\rho\cos\phi,\qquad B=\rho\sin\phi
\]

---

## FSS-1 — Golden Shear Space

\[
\varphi=\frac{1+\sqrt5}{2}
\]

\[
a=r-\frac12,\qquad
b=g-\frac12,\qquad
c=b_{\mathrm{rgb}}-\frac12
\]

\[
X=a+\varphi b
\]

\[
Y=b+\varphi^2c
\]

\[
Z=c+\frac{X}{\varphi}
\]

Inverse:

\[
c=Z-\frac{X}{\varphi}
\]

\[
b=Y-\varphi^2c
\]

\[
a=X-\varphi b
\]

\[
r=a+\frac12,\qquad
g=b+\frac12,\qquad
b_{\mathrm{rgb}}=c+\frac12
\]

---

## PHS-1 — Prime Harmonic Space

\[
W=L-\frac12
\]

\[
X=
A+
0.30\sin(4\pi B)
+
0.15\sin(10\pi W)
\]

\[
Y=
B+
0.36\sin(6\pi X)
\]

\[
Z=
W+
0.24\sin(10\pi Y)
\]

Inverse:

\[
W=
Z-
0.24\sin(10\pi Y)
\]

\[
B=
Y-
0.36\sin(6\pi X)
\]

\[
A=
X-
0.30\sin(4\pi B)
-
0.15\sin(10\pi W)
\]

\[
L=W+\frac12
\]

---

## BBS-1 — Braid Rotation Space

\[
R(\theta)=
\begin{bmatrix}
\cos\theta & -\sin\theta\\
\sin\theta & \cos\theta
\end{bmatrix}
\]

\[
x=r-\frac12,\qquad
y=g-\frac12,\qquad
z=b-\frac12
\]

\[
\begin{bmatrix}x_1\\y_1\end{bmatrix}
=
R\!\left(2.5\sin(2\pi z)\right)
\begin{bmatrix}x\\y\end{bmatrix}
\]

\[
\begin{bmatrix}y_2\\z_2\end{bmatrix}
=
R\!\left(2.1\sin(2\pi x_1)\right)
\begin{bmatrix}y_1\\z\end{bmatrix}
\]

\[
\begin{bmatrix}z_3\\x_3\end{bmatrix}
=
R\!\left(2.8\sin(2\pi y_2)\right)
\begin{bmatrix}z_2\\x_1\end{bmatrix}
\]

Inverse: apply the three rotations in reverse order with negated angles.

---

## RQS-1 — Rational Quotient Space

\[
W=L-\frac12
\]

\[
X=\frac{A}{1+0.68B}
\]

\[
Y=\frac{B}{1+0.58W}
\]

\[
Z=\frac{\operatorname{asinh}(2.8W)}{2.8}
\]

Inverse:

\[
W=\frac{\sinh(2.8Z)}{2.8}
\]

\[
B=Y(1+0.58W)
\]

\[
A=X(1+0.68B)
\]

\[
L=W+\frac12
\]

---

## HLS-1 — Hadamard Logit Space

\[
\ell_\varepsilon(x)=
\ln\!\left(
\frac{x+\varepsilon}{1-x+\varepsilon}
\right),
\qquad
\varepsilon=10^{-3}
\]

\[
H=
\begin{bmatrix}
\frac1{\sqrt3} & \frac1{\sqrt3} & \frac1{\sqrt3}\\
\frac1{\sqrt2} & 0 & -\frac1{\sqrt2}\\
\frac1{\sqrt6} & -\frac2{\sqrt6} & \frac1{\sqrt6}
\end{bmatrix}
\]

\[
\mathbf q=
\begin{bmatrix}
\ell_\varepsilon(r)\\
\ell_\varepsilon(g)\\
\ell_\varepsilon(b)
\end{bmatrix}
\]

\[
\mathbf y=H\mathbf q
\]

Inverse:

\[
\mathbf q=H^\mathsf T\mathbf y
\]

\[
\ell_\varepsilon^{-1}(q)=
\frac{e^q(1+\varepsilon)-\varepsilon}{1+e^q}
\]

---

# Deep-math set v3

## S3SO4-1 — \(S^3\) + \(SO(4)\) Space

First center and scale RGB:

\[
\mathbf x=
1.65
\left(
\begin{bmatrix}r\\g\\b\end{bmatrix}
-
\begin{bmatrix}\frac12\\\frac12\\\frac12\end{bmatrix}
\right)
\in\mathbb R^3
\]

Lift \(\mathbb R^3\) to the unit three-sphere \(S^3\subset\mathbb R^4\) by inverse stereographic projection:

\[
\Phi(\mathbf x)=
\left(
\frac{2\mathbf x}{1+\|\mathbf x\|^2},
\frac{\|\mathbf x\|^2-1}{1+\|\mathbf x\|^2}
\right)
=
\mathbf q
\]

Apply an \(SO(4)\) rotation

\[
\mathbf q'=Q\mathbf q
\]

with

\[
Q=
R_{24}(0.58)\,
R_{13}(0.72)\,
R_{34}(-1.15)\,
R_{12}(0.95)
\]

where \(R_{ij}(\theta)\) denotes a four-dimensional plane rotation in the \(i,j\) plane.

Project back to \(\mathbb R^3\):

\[
T(\mathbf x)=
\frac{\mathbf q'_{1:3}}{1-q'_4}
\]

Inverse:

\[
\mathbf q=Q^\mathsf T\mathbf q'
\]

followed by the same stereographic projection back to \(\mathbb R^3\), then

\[
\begin{bmatrix}r\\g\\b\end{bmatrix}
=
\frac{\mathbf x}{1.65}
+
\begin{bmatrix}\frac12\\\frac12\\\frac12\end{bmatrix}
\]

---

## PBC-1 — Poincaré Ball Color Space

Use the same centered/scaled \(\mathbf x\in\mathbb R^3\).

Map it radially into the open unit ball:

\[
\mathbf u=
\tanh(\lambda\|\mathbf x\|)
\frac{\mathbf x}{\|\mathbf x\|},
\qquad
\lambda=1.55
\]

with the continuous limit at \(\mathbf x=0\).

Choose

\[
\mathbf a=
\begin{bmatrix}
0.46\\
-0.31\\
0.28
\end{bmatrix},
\qquad
\|\mathbf a\|<1
\]

and apply Möbius addition:

\[
\mathbf a\oplus\mathbf u=
\frac{
(1+2\langle\mathbf a,\mathbf u\rangle+\|\mathbf u\|^2)\mathbf a
+
(1-\|\mathbf a\|^2)\mathbf u
}{
1+2\langle\mathbf a,\mathbf u\rangle
+\|\mathbf a\|^2\|\mathbf u\|^2
}
\]

\[
T(\mathbf x)=\mathbf a\oplus\mathbf u
\]

Inverse Möbius translation:

\[
\mathbf u=(-\mathbf a)\oplus T(\mathbf x)
\]

Then

\[
\mathbf x=
\frac{\operatorname{artanh}(\|\mathbf u\|)}
{\lambda\|\mathbf u\|}
\mathbf u
\]

---

## CSM-1 — Chirikov Standard Map Color Space

Treat RGB as coordinates on the three-torus

\[
\mathbb T^3=(\mathbb R/\mathbb Z)^3
\]

and write

\[
x=r,\qquad p=g,\qquad z=b
\]

with all coordinates taken modulo \(1\).

For

\[
K=5.8,\qquad
c_1=0.37,\qquad
c_2=-0.29
\]

define

\[
p_1=
p+
\frac{K}{2\pi}\sin(2\pi x)
\pmod1
\]

\[
x_1=
x+p_1
\pmod1
\]

\[
z_1=
z+
c_1\sin(2\pi x_1)
+
c_2\sin(2\pi p_1)
\pmod1
\]

Thus

\[
T(x,p,z)=(x_1,p_1,z_1)
\]

Inverse:

\[
x=
x_1-p_1
\pmod1
\]

\[
p=
p_1-
\frac{K}{2\pi}\sin(2\pi x)
\pmod1
\]

\[
z=
z_1-
c_1\sin(2\pi x_1)
-
c_2\sin(2\pi p_1)
\pmod1
\]

---

## GF2-1 — \(GF(2)^{24}\) Bit Color Space

Quantize RGB to three 8-bit integers and pack them as

\[
v=(R\ll16)\lor(G\ll8)\lor B,
\qquad
v\in GF(2)^{24}
\]

All operations below are over the 24-bit vector space over \(GF(2)\).

Define the reversible xorshift maps

\[
L_s(v)=v\oplus(v\ll s)
\]

\[
R_s(v)=v\oplus(v\gg s)
\]

with all bits outside the lowest 24 discarded.

The transform used is

\[
v_1=L_7(v)
\]

\[
v_2=R_9(v_1)
\]

\[
v_3=L_8(v_2)
\]

followed by a cyclic 24-bit left rotation by five positions:

\[
T(v)=\operatorname{rotl}_{24}(v_3,5)
\]

Inverse:

\[
v_3=\operatorname{rotr}_{24}(T(v),5)
\]

then apply

\[
L_8^{-1},\qquad R_9^{-1},\qquad L_7^{-1}
\]

in that order.

For a \(24\)-bit word, the inverse left-xorshift can be written as the finite composition

\[
L_s^{-1}
=
L_sL_{2s}L_{4s}\cdots
\]

keeping only shifts \(<24\). Likewise

\[
R_s^{-1}
=
R_sR_{2s}R_{4s}\cdots
\]

for shifts \(<24\).

The transform is exactly bijective on the \(2^{24}\) discrete RGB colors.

---

## CFE-1 — Continued-Fraction Natural Extension Space

First move each RGB coordinate away from the singular endpoints:

\[
S_\varepsilon(t)
=
\varepsilon+(1-2\varepsilon)t,
\qquad
\varepsilon=10^{-3}
\]

\[
x=S_\varepsilon(r),\qquad
y=S_\varepsilon(g),\qquad
z=S_\varepsilon(b)
\]

Let

\[
n=
\left\lfloor\frac1x\right\rfloor
\]

The natural extension of the Gauss map is

\[
X=
\frac1x-n
\]

\[
Y=
\frac1{n+y}
\]

and the third axis is given an additional reversible shear:

\[
Z=
z+
0.23\sin(2\pi X)
+
0.17\sin(2\pi Y)
\pmod1
\]

Inverse: the branch index is recovered from \(Y\):

\[
n=
\left\lfloor\frac1Y\right\rfloor
\]

then

\[
x=
\frac1{n+X}
\]

\[
y=
\frac1Y-n
\]

\[
z=
Z-
0.23\sin(2\pi X)
-
0.17\sin(2\pi Y)
\pmod1
\]

Finally,

\[
S_\varepsilon^{-1}(t)
=
\frac{t-\varepsilon}{1-2\varepsilon}
\]

is applied to recover RGB.

---

## Conjugated effect

For any invertible color transform \(T\) and an existing component-wise/spatial effect \(E\), the transformed effect is

\[
E_T=T^{-1}\circ E\circ T
\]

and, before the effect is inserted,

\[
T^{-1}(T(\mathbf c))=\mathbf c
\]

up to floating-point or discrete quantization error.
