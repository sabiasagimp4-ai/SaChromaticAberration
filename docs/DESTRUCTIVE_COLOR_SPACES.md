# Destructive Color Spaces v5

These are formula/reference definitions only. The intended use is

\[
E_T = T^{-1}\circ E\circ T
\]

where \(E\) is the existing SaChromaticAberration spectral/spatial effect.

## ANO-1 — Anosov Torus

Treat RGB as a point on \(\mathbb T^3=\mathbb R^3/\mathbb Z^3\).

\[
\mathbf x' = A\mathbf x \pmod 1,
\qquad
A=
\begin{bmatrix}
2&1&1\\
1&1&1\\
1&1&0
\end{bmatrix}
\]

\[
\mathbf x=A^{-1}\mathbf x' \pmod 1
\]

---

## KSM-1 — Kicked Standard Map

\[
p' = p+\frac{K}{2\pi}\sin(2\pi x)\pmod1
\]

\[
x' = x+p'\pmod1
\]

\[
z'=z+0.42\sin(2\pi x')-0.34\sin(2\pi(x'+p'))\pmod1
\]

with

\[
K=8.8
\]

Inverse:

\[
x=x'-p'\pmod1
\]

\[
p=p'-\frac{K}{2\pi}\sin(2\pi x)\pmod1
\]

\[
z=z'-0.42\sin(2\pi x')+0.34\sin(2\pi(x'+p'))\pmod1
\]

---

## MOB-2 — Pole Möbius

Use opponent coordinates

\[
L=\frac{r+g+b}{3},\quad A=r-g,\quad B=\frac{r+g}{2}-b
\]

and

\[
z=A+iB
\]

Compress to the unit disk:

\[
u=\frac{z}{1+\sqrt{1+|z|^2}}
\]

then apply the disk automorphism

\[
v=\frac{u-a}{1-\bar a u},
\qquad
a=0.82+0.10i
\]

Output:

\[
X=\Re(v),\quad Y=\Im(v),\quad Z=L-\frac12
\]

Inverse:

\[
u=\frac{v+a}{1+\bar a v}
\]

\[
\rho=\frac{2|u|}{1-|u|^2},
\qquad
z=\rho e^{i\arg u}
\]

then recover \(A,B,L\) and RGB.

---

## BRD-2 — Braid Catastrophe

Start with

\[
x=r-\frac12,\quad y=g-\frac12,\quad z=b-\frac12
\]

Let

\[
R(\theta)=
\begin{bmatrix}
\cos\theta&-\sin\theta\\
\sin\theta&\cos\theta
\end{bmatrix}
\]

First braid:

\[
a=3.6\sin(2\pi z)+0.9\sin(6\pi z)
\]

\[
\begin{bmatrix}x_1\\y_1\end{bmatrix}
=
R(a)
\begin{bmatrix}x\\y\end{bmatrix}
\]

Second:

\[
b=3.2\sin(2\pi x_1)-0.8\cos(4\pi x_1)
\]

\[
\begin{bmatrix}y_2\\z_2\end{bmatrix}
=
R(b)
\begin{bmatrix}y_1\\z\end{bmatrix}
\]

Third:

\[
c=3.8\sin(2\pi y_2)+1.1\sin(4\pi y_2)
\]

\[
\begin{bmatrix}z_3\\x_3\end{bmatrix}
=
R(c)
\begin{bmatrix}z_2\\x_1\end{bmatrix}
\]

Output \((x_3,y_2,z_3)\). Invert by applying the three rotations in reverse order with angles \(-c,-b,-a\).

---

## GFT-2 — GF(2) Bit Storm

Pack 8-bit RGB into

\[
v\in GF(2)^{24}
\]

Forward bit transform:

\[
v_1=v\oplus(v\ll5)
\]

\[
v_2=\operatorname{rotl}_{24}(v_1,7)
\]

\[
v_3=v_2\oplus(v_2\gg11)
\]

\[
v_4=\operatorname{rotl}_{24}(v_3,3)
\]

\[
v_5=v_4\oplus(v_4\ll9)
\]

All operations are 24-bit masked. Invert in exact reverse order using inverse xor-shifts and inverse rotations.

---

## CFE-2 — Gauss Continued-Fraction Extension

First squeeze each channel slightly away from 0 and 1:

\[
s(x)=\varepsilon+(1-2\varepsilon)x,
\qquad \varepsilon=10^{-3}
\]

Let

\[
x=s(r),\quad y=s(g),\quad z=s(b)
\]

\[
n=\left\lfloor\frac1x\right\rfloor
\]

\[
X=\frac1x-n
\]

\[
Y=\frac1{n+y}
\]

\[
Z=z+0.24\sin(2\pi X)+0.19\sin(2\pi Y)\pmod1
\]

Inverse:

\[
n=\left\lfloor\frac1Y\right\rfloor
\]

\[
x=\frac1{n+X}
\]

\[
y=\frac1Y-n
\]

\[
z=Z-0.24\sin(2\pi X)-0.19\sin(2\pi Y)\pmod1
\]

then apply \(s^{-1}\).

---

## CAS-1 — Caustic Shear

\[
x=r-\frac12,\quad y=g-\frac12,\quad z=b-\frac12
\]

\[
X=x+0.90y^3+0.22\sin(4\pi y)
\]

\[
Y=y+0.95z^3+0.25\sin(2\pi X)
\]

\[
Z=z+0.80X^3-0.34Y
\]

Inverse:

\[
z=Z-0.80X^3+0.34Y
\]

\[
y=Y-0.95z^3-0.25\sin(2\pi X)
\]

\[
x=X-0.90y^3-0.22\sin(4\pi y)
\]
