# Additional Mathematical Color Spaces v6

Formula/reference definitions only.

## QRO-2 — Quaternion Ribbon

Let

\[
\mathbf q=
\begin{bmatrix}
r-\frac12\\g-\frac12\\b-\frac12
\end{bmatrix},
\qquad
\mathbf n=\frac1{\sqrt3}(1,1,1)
\]

\[
\rho=\|\mathbf q\|,
\qquad
p=\mathbf n\cdot\mathbf q
\]

\[
\theta=4.2\tanh(2\rho)+2.4\sin(4p)
\]

Apply Rodrigues rotation about \(\mathbf n\):

\[
T(\mathbf q)=
\mathbf q\cos\theta+
(\mathbf n\times\mathbf q)\sin\theta+
\mathbf n(\mathbf n\cdot\mathbf q)(1-\cos\theta)
\]

Because both \(\rho\) and \(p\) are invariants of this rotation, invert with the same \(\theta\) and angle \(-\theta\).

---

## LOR-3 — Lorentz Lattice

Using opponent coordinates \(L,A,B\), set

\[
U=L-\frac12
\]

\[
\eta=2.5\tanh(2.8B)+0.7\sin(2\pi B)
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
U=\cosh(\eta)X-\sinh(\eta)Y
\]

\[
A=-\sinh(\eta)X+\cosh(\eta)Y
\]

with \(\eta\) recomputed from \(Z\).

---

## HBP-2 — Hyperbolic Prism

Use the orthonormal basis

\[
Q=
\begin{bmatrix}
1/\sqrt3&1/\sqrt3&1/\sqrt3\\
1/\sqrt2&0&-1/\sqrt2\\
1/\sqrt6&-2/\sqrt6&1/\sqrt6
\end{bmatrix}
\]

\[
(x,y,z)^T=Q(r-\tfrac12,g-\tfrac12,b-\tfrac12)^T
\]

Then

\[
X=\frac{\operatorname{asinh}(1.6x)}{1.6}
\]

\[
Y_0=y+0.32\sin(\pi X)
\]

\[
Y=\frac{\operatorname{asinh}(2.1Y_0)}{2.1}
\]

\[
Z_0=z-0.28\cos(\pi Y)+0.14\sin(\pi X)
\]

\[
Z=\frac{\operatorname{asinh}(1.8Z_0)}{1.8}
\]

Invert in reverse order using \(\sinh\), then multiply by \(Q^T\).

---

## TWS-2 — Twisted Shell

\[
\rho=\sqrt{A^2+B^2},
\qquad
\phi=\operatorname{atan2}(B,A)
\]

\[
R=\frac{\arctan(2.2\rho)}{2.2}
\]

\[
Z=\frac{\operatorname{asinh}(2.5(L-\frac12))}{2.5}
\]

\[
\theta=
\phi+5R+1.2\sin(\pi Z)+0.8\sin(4\pi R)
\]

\[
X=R\cos\theta,\qquad Y=R\sin\theta
\]

Inverse:

\[
\rho=\frac{\tan(2.2R)}{2.2}
\]

\[
L=\frac12+\frac{\sinh(2.5Z)}{2.5}
\]

\[
\phi=\theta-5R-1.2\sin(\pi Z)-0.8\sin(4\pi R)
\]

---

## BRD-3 — Triple Braid

\[
x=r-\frac12,\quad y=g-\frac12,\quad z=b-\frac12
\]

\[
a=3.1\sin(2\pi z)+1.0\sin(6\pi z)
\]

\[
(x_1,y_1)=R(a)(x,y)
\]

\[
b=2.9\sin(2\pi x_1)-0.9\cos(4\pi x_1)
\]

\[
(y_2,z_2)=R(b)(y_1,z)
\]

\[
c=3.4\sin(2\pi y_2)+1.2\sin(4\pi y_2)
\]

\[
(z_3,x_3)=R(c)(z_2,x_1)
\]

Output \((x_3,y_2,z_3)\). Invert by reversing the three rotations.

---

## TOR-2 — Integer Torus

\[
\mathbf x' = A\mathbf x\pmod1
\]

with

\[
A=
\begin{bmatrix}
1&1&1\\
1&2&1\\
1&1&2
\end{bmatrix},
\qquad
\det A=1
\]

Inverse:

\[
\mathbf x=A^{-1}\mathbf x'\pmod1
\]

---

## STD-2 — Double Standard

\[
p'=p+\frac{7.6}{2\pi}\sin(2\pi x)\pmod1
\]

\[
x'=x+p'\pmod1
\]

\[
z'=z+0.30\sin(2\pi x')-0.27\sin(2\pi p')\pmod1
\]

Inverse:

\[
x=x'-p'\pmod1
\]

\[
p=p'-\frac{7.6}{2\pi}\sin(2\pi x)\pmod1
\]

\[
z=z'-0.30\sin(2\pi x')+0.27\sin(2\pi p')\pmod1
\]

---

## MOB-3 — Dual Möbius

Opponent complex coordinate:

\[
z=A+iB
\]

Disk compression:

\[
u=\frac{z}{1+\sqrt{1+|z|^2}}
\]

Luminance-dependent phase:

\[
\theta=1.7\sin(2\pi L)
\]

\[
u_2=u e^{i\theta}
\]

Möbius transform:

\[
v=\frac{u_2-a}{1-\bar a u_2},
\qquad
a=0.56+0.18i
\]

Inverse:

\[
u_2=\frac{v+a}{1+\bar a v}
\]

\[
u=u_2e^{-i\theta}
\]

then inverse disk compression.

---

## BIT-2 — Gray Cascade

Pack RGB into a 24-bit word \(v\).

Gray encode:

\[
g=v\oplus(v\gg1)
\]

Then:

\[
g_1=g\oplus(g\ll7)
\]

\[
g_2=\operatorname{rotl}_{24}(g_1,5)
\]

\[
g_3=g_2\oplus(g_2\gg9)
\]

\[
g_4=\operatorname{rotl}_{24}(g_3,3)
\]

Invert in reverse order, then Gray-decode.

---

## CAT-2 — Optical Catastrophe

\[
x=r-\frac12,\quad y=g-\frac12,\quad z=b-\frac12
\]

\[
X=x+0.70y^3+0.18\sin(6\pi y)
\]

\[
Y=y+0.80z^3+0.24\sin(4\pi X)
\]

\[
Z=z+0.75X^3-0.28Y+0.12\sin(2\pi X)
\]

Inverse:

\[
z=Z-0.75X^3+0.28Y-0.12\sin(2\pi X)
\]

\[
y=Y-0.80z^3-0.24\sin(4\pi X)
\]

\[
x=X-0.70y^3-0.18\sin(6\pi y)
\]
