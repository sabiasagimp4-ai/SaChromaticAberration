# Experimental Color Spaces — Formulae

## Common coordinates

[
L=rac{r+g+b}{3},qquad A=r-g,qquad B=rac{r+g}{2}-b
]

[
r=L+rac{B}{3}+rac{A}{2},qquad
g=L+rac{B}{3}-rac{A}{2},qquad
b=L-rac{2B}{3}
]

---

## TOS-1 — Twisted Opponent Space

[
ho=sqrt{A^2+B^2},qquad
phi=operatorname{atan2}(B,A)
]

[
ho_w=ho^gamma,qquad
Z=rac{operatorname{asinh}(k(L-rac12))}{operatorname{asinh}(k/2)}
]

[
	heta=phi+alphasin(pi Z)+etaho_w^2
]

[
X=ho_wcos	heta,qquad
Y=ho_wsin	heta
]

[
(k,gamma,alpha,eta)=(3, 0.65, 1.1, 1.8)
]

Inverse:

[
ho_w=sqrt{X^2+Y^2},qquad
	heta=operatorname{atan2}(Y,X)
]

[
ho=ho_w^{1/gamma}
]

[
L=rac12+rac{sinhleft(Zoperatorname{asinh}(k/2)ight)}{k}
]

[
phi=	heta-alphasin(pi Z)-etaho_w^2
]

[
A=hocosphi,qquad B=hosinphi
]

---

## LRS-1 — Log Ratio Space

[
a=ln(r+arepsilon),qquad
b=ln(g+arepsilon),qquad
c=ln(b_{mathrm{rgb}}+arepsilon)
]

[
U=a-b,qquad
V=rac{a+b}{2}-c,qquad
W=rac{a+b+c}{3}
]

[
arepsilon=10^{-4}
]

Inverse:

[
a=W+rac{V}{3}+rac{U}{2}
]

[
b=W+rac{V}{3}-rac{U}{2}
]

[
c=W-rac{2V}{3}
]

[
r=e^a-arepsilon,qquad
g=e^b-arepsilon,qquad
b_{mathrm{rgb}}=e^c-arepsilon
]

---

## MOS-1 — Möbius Opponent Space

[
z=A+iB
]

[
w=rac{z}{1+kappa z}
]

[
kappa=0.45+0.25i
]

[
X=Re(w),qquad Y=Im(w),qquad Z=L
]

Inverse:

[
w=X+iY
]

[
z=rac{w}{1-kappa w}
]

[
A=Re(z),qquad B=Im(z),qquad L=Z
]

---

## RSS-1 — Reversible Sine Shear

[
X=A+0.35sin(2pi L)
]

[
Y=B+0.45sin(pi X)
]

[
Z=L+0.18sin(2pi Y)
]

Inverse:

[
L=Z-0.18sin(2pi Y)
]

[
B=Y-0.45sin(pi X)
]

[
A=X-0.35sin(2pi L)
]

---

## HCS-1 — Hyperbolic Cross Space

[
mathbf q=
egin{bmatrix}
r-rac12\
g-rac12\
b-rac12
end{bmatrix}
]

[
M=
egin{bmatrix}
1.15 & -0.65 & 0.20\
-0.20 & 1.30 & -0.70\
0.75 & 0.15 & -0.55
end{bmatrix}
]

[
mathbf y=Mmathbf q
]

[
mathbf c=rac{operatorname{asinh}(kmathbf y)}{k},
qquad k=2.6
]

Inverse:

[
mathbf y=rac{sinh(kmathbf c)}{k}
]

[
mathbf q=M^{-1}mathbf y
]

[
egin{bmatrix}r\g\bend{bmatrix}
=
mathbf q+
egin{bmatrix}rac12\rac12\rac12end{bmatrix}
]

---

## CSL-1 — Complex Spiral Space

[
ho=sqrt{A^2+B^2},qquad
phi=operatorname{atan2}(B,A)
]

[
R=rac{operatorname{asinh}(cho)}{c},
qquad c=2.8
]

[
Z=rac{operatorname{asinh}(k(L-rac12))}{k},
qquad k=2.2
]

[
	heta=
phi+
3.4ln(1+5ho^2)
+
1.7sin(2pi L)
]

[
X=Rcos	heta,qquad Y=Rsin	heta
]

Inverse:

[
R=sqrt{X^2+Y^2},qquad
	heta=operatorname{atan2}(Y,X)
]

[
ho=rac{sinh(cR)}{c}
]

[
L=rac12+rac{sinh(kZ)}{k}
]

[
phi=
	heta-
3.4ln(1+5ho^2)
-
1.7sin(2pi L)
]

[
A=hocosphi,qquad B=hosinphi
]

---

## LBS-1 — Lorentz Boost Space

[
U=L-rac12
]

[
eta=1.75	anh(2.7B)
]

[
X=cosh(eta)U+sinh(eta)A
]

[
Y=sinh(eta)U+cosh(eta)A
]

[
Z=B
]

Inverse:

[
eta=1.75	anh(2.7Z)
]

[
U=cosh(eta)X-sinh(eta)Y
]

[
A=-sinh(eta)X+cosh(eta)Y
]

[
L=U+rac12,qquad B=Z
]

---

## PPS-1 — Projective Perspective Space

[
mathbf q=
egin{bmatrix}
r-rac12\
g-rac12\
b-rac12
end{bmatrix}
]

[
mathbf c=
egin{bmatrix}
0.42\
-0.31\
0.26
end{bmatrix}
]

[
mathbf y=
rac{mathbf q}{1+mathbf c^mathsf Tmathbf q}
]

Inverse:

[
mathbf q=
rac{mathbf y}{1-mathbf c^mathsf Tmathbf y}
]

[
egin{bmatrix}r\g\bend{bmatrix}
=
mathbf q+
egin{bmatrix}rac12\rac12\rac12end{bmatrix}
]

---

## RRS-1 — Rodrigues Radius Space

[
mathbf q=
egin{bmatrix}
r-rac12\
g-rac12\
b-rac12
end{bmatrix},
qquad
mathbf n=rac{1}{sqrt3}
egin{bmatrix}
1\1\1
end{bmatrix}
]

[
m=|mathbf q|,
qquad
p=mathbf n^mathsf Tmathbf q
]

[
	heta=
5	anh(1.8m)+2.6sin(3.2p)
]

[
T(mathbf q)=
mathbf qcos	heta+
(mathbf n	imesmathbf q)sin	heta+
mathbf n(mathbf n^mathsf Tmathbf q)(1-cos	heta)
]

Inverse:

[
T^{-1}(mathbf y)=
mathbf ycos	heta-
(mathbf n	imesmathbf y)sin	heta+
mathbf n(mathbf n^mathsf Tmathbf y)(1-cos	heta)
]

[
	heta=
5	anh(1.8|mathbf y|)
+
2.6sin(3.2,mathbf n^mathsf Tmathbf y)
]

---

## SDS-1 — Stereographic Disk Space

[
ho=sqrt{A^2+B^2},
qquad
phi=operatorname{atan2}(B,A)
]

[
r_d=
rac{ho}{1+sqrt{1+ho^2}}
]

[
	heta=
phi+7r_d+2sin(2pi L)(1-r_d)
]

[
X=r_dcos	heta,qquad
Y=r_dsin	heta,qquad
Z=L-rac12
]

Inverse:

[
r_d=sqrt{X^2+Y^2}
]

[
ho=
rac{2r_d}{1-r_d^2}
]

[
L=Z+rac12
]

[
phi=
operatorname{atan2}(Y,X)
-
7r_d
-
2sin(2pi L)(1-r_d)
]

[
A=hocosphi,qquad B=hosinphi
]

---

## FSS-1 — Golden Shear Space

[
arphi=rac{1+sqrt5}{2}
]

[
a=r-rac12,qquad
b=g-rac12,qquad
c=b_{mathrm{rgb}}-rac12
]

[
X=a+arphi b
]

[
Y=b+arphi^2c
]

[
Z=c+rac{X}{arphi}
]

Inverse:

[
c=Z-rac{X}{arphi}
]

[
b=Y-arphi^2c
]

[
a=X-arphi b
]

[
r=a+rac12,qquad
g=b+rac12,qquad
b_{mathrm{rgb}}=c+rac12
]

---

## PHS-1 — Prime Harmonic Space

[
W=L-rac12
]

[
X=
A+
0.30sin(4pi B)
+
0.15sin(10pi W)
]

[
Y=
B+
0.36sin(6pi X)
]

[
Z=
W+
0.24sin(10pi Y)
]

Inverse:

[
W=
Z-
0.24sin(10pi Y)
]

[
B=
Y-
0.36sin(6pi X)
]

[
A=
X-
0.30sin(4pi B)
-
0.15sin(10pi W)
]

[
L=W+rac12
]

---

## BBS-1 — Braid Rotation Space

[
R(	heta)=
egin{bmatrix}
cos	heta & -sin	heta\
sin	heta & cos	heta
end{bmatrix}
]

[
x=r-rac12,qquad
y=g-rac12,qquad
z=b-rac12
]

[
egin{bmatrix}x_1\y_1end{bmatrix}
=
Rleft(2.5sin(2pi z)ight)
egin{bmatrix}x\yend{bmatrix}
]

[
egin{bmatrix}y_2\z_2end{bmatrix}
=
Rleft(2.1sin(2pi x_1)ight)
egin{bmatrix}y_1\zend{bmatrix}
]

[
egin{bmatrix}z_3\x_3end{bmatrix}
=
Rleft(2.8sin(2pi y_2)ight)
egin{bmatrix}z_2\x_1end{bmatrix}
]

[
T(r,g,b)=
left(
x_3, y_2, z_3
ight)
]

Inverse:

[
egin{bmatrix}z_2\x_1end{bmatrix}
=
Rleft(-2.8sin(2pi y_2)ight)
egin{bmatrix}z_3\x_3end{bmatrix}
]

[
egin{bmatrix}y_1\zend{bmatrix}
=
Rleft(-2.1sin(2pi x_1)ight)
egin{bmatrix}y_2\z_2end{bmatrix}
]

[
egin{bmatrix}x\yend{bmatrix}
=
Rleft(-2.5sin(2pi z)ight)
egin{bmatrix}x_1\y_1end{bmatrix}
]

[
r=x+rac12,qquad
g=y+rac12,qquad
b=z+rac12
]

---

## RQS-1 — Rational Quotient Space

[
W=L-rac12
]

[
X=rac{A}{1+0.68B}
]

[
Y=rac{B}{1+0.58W}
]

[
Z=rac{operatorname{asinh}(2.8W)}{2.8}
]

Inverse:

[
W=rac{sinh(2.8Z)}{2.8}
]

[
B=Y(1+0.58W)
]

[
A=X(1+0.68B)
]

[
L=W+rac12
]

---

## HLS-1 — Hadamard Logit Space

[
ell_arepsilon(x)=
lnleft(
rac{x+arepsilon}{1-x+arepsilon}
ight),
qquad
arepsilon=10^{-3}
]

[
H=
egin{bmatrix}
rac1{sqrt3} & rac1{sqrt3} & rac1{sqrt3}\
rac1{sqrt2} & 0 & -rac1{sqrt2}\
rac1{sqrt6} & -rac2{sqrt6} & rac1{sqrt6}
end{bmatrix}
]

[
mathbf q=
egin{bmatrix}
ell_arepsilon(r)\
ell_arepsilon(g)\
ell_arepsilon(b)
end{bmatrix}
]

[
mathbf y=Hmathbf q
]

Inverse:

[
mathbf q=H^mathsf Tmathbf y
]

[
ell_arepsilon^{-1}(q)=
rac{e^q(1+arepsilon)-arepsilon}{1+e^q}
]

[
r=ell_arepsilon^{-1}(q_1),qquad
g=ell_arepsilon^{-1}(q_2),qquad
b=ell_arepsilon^{-1}(q_3)
]

---

[
T^{-1}(T(mathbf c))=mathbf c
]
