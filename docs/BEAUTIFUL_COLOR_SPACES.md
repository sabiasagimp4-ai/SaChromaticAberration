# Beautiful Experimental Color Spaces — Formulae

These transforms are designed to remain smooth and reversible while producing softer, more luminous chromatic-aberration behavior.

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

## HOP-1 — Hopf Phase Space

First center and scale RGB:

\[
\mathbf x=1.35
\left(
\begin{bmatrix}r\\g\\b\end{bmatrix}
-
\begin{bmatrix}\frac12\\\frac12\\\frac12\end{bmatrix}
\right)
\]

Lift \(\mathbf x\in\mathbb R^3\) to \(S^3\subset\mathbb R^4\) by stereographic projection:

\[
\mathbf q=
\left(
\frac{2\mathbf x}{1+\|\mathbf x\|^2},
\frac{\|\mathbf x\|^2-1}{1+\|\mathbf x\|^2}
\right)
=
(a,b,c,d)
\]

Identify

\[
z_1=a+ib,\qquad
z_2=c+id
\]

and define the invariant

\[
\nu=|z_1|^2-|z_2|^2
\]

\[
\theta=1.05\nu+0.38\sin(3\nu)
\]

Apply opposite phase rotations:

\[
z_1'=z_1e^{i\theta},\qquad
z_2'=z_2e^{-i\theta}
\]

Then inverse-stereographically project back to \(\mathbb R^3\).

Inverse:

\[
z_1=z_1'e^{-i\theta},\qquad
z_2=z_2'e^{i\theta}
\]

with the same \(\nu\), because \(|z_1|\) and \(|z_2|\) are preserved.

---

## HMF-1 — Hamiltonian Flower Space

Let

\[
W=L-\frac12
\]

Then apply reversible sine shears:

\[
X=
A+
0.22\sin(2\pi B)
+
0.07\sin(6\pi B)
\]

\[
Y=
B+
0.20\sin(2\pi X)
-
0.06\sin(4\pi X)
\]

\[
Z=
W+
0.10\sin\left(2\pi(X+Y)\right)
\]

Inverse:

\[
W=
Z-
0.10\sin\left(2\pi(X+Y)\right)
\]

\[
B=
Y-
0.20\sin(2\pi X)
+
0.06\sin(4\pi X)
\]

\[
A=
X-
0.22\sin(2\pi B)
-
0.07\sin(6\pi B)
\]

\[
L=W+\frac12
\]

---

## CPF-1 — Complex Phase Flow Space

Use the opponent plane as a complex coordinate

\[
z=A+iB
\]

with

\[
\rho=|z|,
\qquad
\phi=\arg z
\]

Compress the radius and luminance smoothly:

\[
R=\frac{\operatorname{asinh}(1.8\rho)}{1.8}
\]

\[
Z=\frac{\operatorname{asinh}(2(L-\frac12))}{2}
\]

Rotate phase by

\[
\theta=
\phi
+
1.45\tanh(2.2\rho)
+
0.55\sin\left(\pi(L-\frac12)\right)
\]

and define

\[
X=R\cos\theta,\qquad
Y=R\sin\theta
\]

Inverse:

\[
R=\sqrt{X^2+Y^2}
\]

\[
\rho=\frac{\sinh(1.8R)}{1.8}
\]

\[
L=\frac12+\frac{\sinh(2Z)}{2}
\]

\[
\phi=
\operatorname{atan2}(Y,X)
-
1.45\tanh(2.2\rho)
-
0.55\sin\left(\pi(L-\frac12)\right)
\]

\[
A=\rho\cos\phi,\qquad
B=\rho\sin\phi
\]

---

## GEA-1 — Geodesic Arc Space

\[
\rho=\sqrt{A^2+B^2},
\qquad
\phi=\operatorname{atan2}(B,A)
\]

Radial compression:

\[
u=
\frac{\arctan(1.6\rho)}{1.6}
\]

Luminance-dependent arc rotation:

\[
\theta=
\phi+
0.85\sin(2\pi L)
\left(
1-\tanh(1.5\rho)
\right)
\]

Luminance coordinate:

\[
Z=\tanh\left(1.5(L-\frac12)\right)
\]

\[
X=u\cos\theta,\qquad
Y=u\sin\theta
\]

Inverse:

\[
u=\sqrt{X^2+Y^2}
\]

\[
\rho=
\frac{\tan(1.6u)}{1.6}
\]

\[
L=
\frac12+
\frac{\operatorname{atanh}(Z)}{1.5}
\]

\[
\phi=
\operatorname{atan2}(Y,X)
-
0.85\sin(2\pi L)
\left(
1-\tanh(1.5\rho)
\right)
\]

\[
A=\rho\cos\phi,\qquad
B=\rho\sin\phi
\]

---

## ORT-1 — Orthonormal Prism Space

Center RGB:

\[
\mathbf q=
\begin{bmatrix}
r-\frac12\\
g-\frac12\\
b-\frac12
\end{bmatrix}
\]

Use the orthonormal basis

\[
Q=
\begin{bmatrix}
\frac1{\sqrt3} & \frac1{\sqrt3} & \frac1{\sqrt3}\\
\frac1{\sqrt2} & 0 & -\frac1{\sqrt2}\\
\frac1{\sqrt6} & -\frac2{\sqrt6} & \frac1{\sqrt6}
\end{bmatrix}
\]

\[
\mathbf u=Q\mathbf q
\]

Apply signed powers:

\[
v_i=
\operatorname{sgn}(u_i)|u_i|^{p_i}
\]

with

\[
(p_1,p_2,p_3)=(0.92,\ 0.72,\ 1.18)
\]

Inverse:

\[
u_i=
\operatorname{sgn}(v_i)|v_i|^{1/p_i}
\]

\[
\mathbf q=Q^\mathsf T\mathbf u
\]

---

## LSP-1 — Lissajous Shear Prism

Let

\[
W=L-\frac12
\]

\[
X=
A+
0.16\sin(2\pi B)
+
0.08\sin(4\pi W)
\]

\[
Y=
B+
0.14\sin(4\pi X)
+
0.05\sin(6\pi W)
\]

\[
Z=
W+
0.08\sin(2\pi X+4\pi Y)
\]

Inverse:

\[
W=
Z-
0.08\sin(2\pi X+4\pi Y)
\]

\[
B=
Y-
0.14\sin(4\pi X)
-
0.05\sin(6\pi W)
\]

\[
A=
X-
0.16\sin(2\pi B)
-
0.08\sin(4\pi W)
\]

\[
L=W+\frac12
\]

---

## FIB-1 — Fibonacci Eigenbasis Space

Start from the symmetric Fibonacci-like matrix

\[
M=
\begin{bmatrix}
1&1&0\\
1&0&1\\
0&1&1
\end{bmatrix}
\]

Let \(E\) be its orthonormal eigenvector matrix:

\[
E^\mathsf T E=I
\]

For centered RGB

\[
\mathbf q=
\begin{bmatrix}
r-\frac12\\
g-\frac12\\
b-\frac12
\end{bmatrix}
\]

transform into the eigenbasis:

\[
\mathbf u=E^\mathsf T\mathbf q
\]

Then

\[
v_i=
\frac{\operatorname{asinh}(k_i u_i)}{k_i}
\]

with

\[
(k_1,k_2,k_3)=(1.4,\ 2.0,\ 1.7)
\]

Inverse:

\[
u_i=
\frac{\sinh(k_i v_i)}{k_i}
\]

\[
\mathbf q=E\mathbf u
\]

---

## CYC-1 — Cyclic Softmix Space

Center RGB:

\[
x=r-\frac12,\qquad
y=g-\frac12,\qquad
z=b-\frac12
\]

Apply smooth cyclic shears:

\[
X=x+0.15\tanh(2y)
\]

\[
Y=y+0.15\tanh(2z)
\]

\[
Z=z+0.15\tanh(2X)
\]

Inverse:

\[
z=Z-0.15\tanh(2X)
\]

\[
y=Y-0.15\tanh(2z)
\]

\[
x=X-0.15\tanh(2y)
\]

\[
r=x+\frac12,\qquad
g=y+\frac12,\qquad
b=z+\frac12
\]

---

All eight transforms are intended to satisfy

\[
T^{-1}(T(\mathbf c))=\mathbf c
\]

up to floating-point error.
