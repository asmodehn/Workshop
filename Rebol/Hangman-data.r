REBOL [
	title: "Hangman"
	author: "Asmodehn"
	version: 0.2.0
	date: 26-Nov-2008
	copyright: "Freeware"
]

;TOOD : provide a loading interface to be embedded in a view
;if the main program asks for it

a_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGLiFQJjx0t26
PwwMjA88XRxDKua8nXN6U7OCgIti6f//008qhU67viK14aXcbbvVOkpVcyQPsF+7
FlUppP+NccHGDVZiYc8LD9Wvkb0eZW9/4HHS2xv3i9Zk+926+ff/0dzlxr4VMj3f
HmftcN+xtew+Z6a/V/5siXMf3pjW3LhW/7n0tLo66xydz+1LYxuv3dpuvFTvTmbr
RunzCwTfsaS12G/bGrZkW7AUR6qNv2DiErMQi8N/esoqIyRiSxYu//I2e4czw5ue
PoO9PcFfLnlcODSlL6tXec05k4faO73OPzeqfXSx/DKz5xsf7c4nUs+ubDKYZz+h
9ePnCQ4PlSXz5vmL7RPaeNd6hoENn7NCnJPFoVcREbLcq53F6q4dNuESC2tXftPN
LiMWlr7pw1Fxs5rKDmUXi4d3b7YKJP4yvij8jDt9m67kPQaGw++3HGD1F057ymR/
KEFnTV/rVVCAsD1KteGA8AyY9Y9yHzn0aonAtNjqH2djw5el1m3bpOjqpTxToWbx
h2mFD3tz59t8msK7V3B/9YI1791iVVa1Fd+a9tGUv3l+QuS2WHOhqk1pdd3P2/d+
usesyON9J872pYXM9HLJVtbsHTLqZV8+XmjhzjySxhV8IuLwQrAnkhNL4U4JOw71
GVBQTv0P29aYpbdEvk01AiYABk9XP5d1TglNANAY+5wuAgAA
}

b_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMjL88XRxDKua8nXM7r8WAx2Xhq///i35N4FJ8J3DbuPCZzbpdt217HqsqGkwP
Wjbxh2N9Y4bKHFnO9OffD1c/q7Sr2dvd9t/1R8/XxgVTt4vEOWvbb6+ZvfnWPga9
+yp//gvqb914Lk1177UfE2ok9Oy9l4pUvJz38If1mZdvqh85vlhjrFs/bRrbyfod
LapvzgQdW1G3rOX+Zy3tH54zIg/x+z5QT5wxic0qmyf9eLjEvUXfXNR57FkOTy05
oiQn+u3QllWi60tfGj/wZmJLnmFzideX8/vSKM63lz5UzZNq5Wd9cLk5O0r43g7D
1WF7nh1u1zfqqZxtGPP1x+O5JU8V7XddmSQr/fD5W/F7K3R3l4jvmG5ye2OHxOGQ
c9MOiT+enM7esWuLtErr2hZnBr5k1TsH3mqkShzb0BIYunbSOb4c8fMsq14tCPaW
O6AqW9/DcEj53SNGob1Hgk9uzu3cn79zisnmbXs/RN9+sDhZP+b487Vt2/jZH6qe
MRC2ceFMP/406PTqKj69OlWZowu8bT6ejVGdK/tkKvvdHMnGlr+SX5oq7l92fqba
x7srX7NlX7iu+cLYFI7+8qx6sfOH13q93v/mR6TN9U7DJzuP/1Pj/7z9xqWq9Ftx
DcY3WJufZ979w7zJfflO7s0LTzqXgSPJ/dDNiQU4mXPtGy12XXTY4PUJmDQYPF39
XNY5JTQBAGWVEbpIAgAA
}

c_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMjIc8XRxDKua8nXO7r0VBwCV18///p98czukJfKwgUqv5ykYq2SKYt3dywsqt
edofH9syZKuc6Wu5Gen3Q/zfkaBTL71WnAsPWLyzah7Hol7Nl+u39X6XYBDIM+98
YJN6cdVWNs0H2sLhL6Nzv09Yvn1pRuDj1vVty7X3KfZzmffZ+Z0rs167eHPyiR9z
rzFvvRb79UXOzP8Bh1bELkl9cE2ff/t+j76W34+evj8cbxh3wLo10PHmdu0bWn/L
XsTN3fm/9odI0Zy1R43/Fd+Q6CmYVmGueqa/ZbanSX6/RmKZyp+2nssRnPsffvs/
68GKJdIaS1W6vrQ8M7C2PSS5/F2fUJ5y/onFnMuNwz2/T1pqrA3UAPITI8fzW9VA
3RMOaZpFe82Q5dys/FDv2173P61RQCZU0UFu9vvVB1o2/7m4eJKcguuJ06o5VSLv
T+zb9tTiGPORitDv4veC5tv+uZLe3jCzuKPF/obFbs7qrxscOG8/uD9tm87z9vmV
8yb06Uvwqb79bcX6+9al/4/jTt3Qjw3+9aFndmBEzcrUJ2YWDyb1nS+qjTj0xgPs
CqjVEw2shdLc0QSBEcFvxNQLDJfn94BRzODp6ueyzimhCQDVXfuCEAIAAA==
}

d_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMjF88XRxDKua8nXO6r9lAgOX46r//49P4PTpaHTps+8uWvz6huOhOcnpBx+1N
Ot98/4TcdzATSnM/9ObPrhqv7LcFrGUf82vLy8z2sB+/r/5wuwzbigv7i/n4731c
zvrII93z/++Oe7v1T95MnHps5nx/jj9Rt/iPbNJ5Xqip+UbjYWj+55i7cVnqky9W
vJl7mlPQ7njFicrd8+y5Ajnjv8Y9tWSf9mVq9NriV4edf3alXlxtouB5/7C5SviO
/R/2pld+it/OqJCoHpUdPnnztlXOLad3d0tPivKWyXr2IdHFSNupe5rwhlDZHV7J
VtNVY0xlZh1+4zFDtv7h81iXk3nzQD44/KVUJLO2o98gTfyn0PaW9MJrMn4p7+63
T/y+8duKJbtnqMYFH/oD1MPx8Iwer5OFsK3NBuXEMpU5rqG/17bcvDjvmsGD+swg
z83KD0W2Vc7bf0UTKCnj/5DFTPVMf0vzyrkHlrX8nvmU3UVVhtNJVCOx7FOL4Kub
l+Js5/zLmNXPcLJM9VXFyt+vW0V0orZa32g87p04T2tabZ+75bn1NjFz/ZiSsvWe
Z8raC964dsdb6s61mtaPubpfKiUuXHsUJ39si6n4w86c3JgKvWjpN1sK5jXOW1xu
I7e5v1wMxE/oL9qRuM9azmV2BcjTnJtB7j7T13JzooE1JO4Yy9LO7OcP0mEAAU9X
P5d1TglNAF5NCOdCAgAA
}

e_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMjCs9XRxDKua8nXN7UrOCAGv72r//48vk1yiF5fqEsKVZlNhL+1Tv8FRIvW0W
3Tn/hb6BVMtVxwjZlt/BXpL1l6/fjT72cHv83/pGcX3pw+8f+89jFZV+ED4t+/B5
4Xuvnxy1yWblO79/Je9+L8uLFdE/6j7W5P7oeZKvfC7XYufanRz2GdMaz6sumN63
lvU0r/felsPt843ntF6uCpNp+fz9jHtV6Mst/o1+3rJAK3/Y/Tx+T3nt+8PyOcV9
PnzcDOXCz54mapz21Y18lKm8c+3Ftq9AZ8k//FMb2gpx4VXHHTOfaNvZHQo12rn2
p9qc9Oen2GvMts6I1MxzLT260+t5e1yULEzpDzth3809LbNnKGUJhbEnlu7S+ZjS
BpXMFJ2X9K+mBcIoK21psQ726nz7vI0r/cddm2Ve+oVONic7zk78wfaN536Zt+ej
rYbqRz7fuNVU/LL9eMW+qmu+tjfndfzfudTL7Orcp8umzZO+vC5G7N+mh2FL9f8Z
x1gUvxEvSdlp1rPBimN1Mx6iPn1bFs/5lt9ZwJhk8HT1c1nnlNAEAKSd5Tr3AQAA
}

f_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMjC2eLo4hFXPezjnZx6zIw6o46///1GcNJqeMOqUKev6usCq3iq1I7LTaujXM
79G234x7HCNkW65Giq7bei3KV+5ou5Wtrm1l2sx7ba3tjyQLROr2VX3vXvzYUu/3
7GnFYjzc268xqb0qfTY7THLl83+666//7r87qaCyZEfF6s5+iU0L2/6rbJ9yrHz3
F2uzssa/sbckQUb7masLJ5YKhLEnlvYJb4vxrr+he2zmOl4/XV794gOaS0uValot
th11tJiSG2n/SLP8q+TZt/F9s6cJzFN1tRNXWtO/sWCO6FXrN8oyd25GWNS9XtSm
2zHnqsla0ype93Upv6f05URnRP1SWNPXWPBB7yuLIMgesGVAA/5d2+/cchXsRSDh
/VAkm19pDd+hV0DVvQWL5OU7NlhxrE5WnpMkelfx0OM5X7kcFqW8m3CpeYnH4+o+
648GFfkrl/wyNjTj35xSuMxbf4LSCTNfbcElW4C6mjfgJvZHilbsL/0qCIo9Bk9X
P5d1TglNALIZxivSAQAA
}

g_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMTAaeLo4hFXPezrlddFiBx2Xh5P//U389mMmzdB+D2CWvN5Xd1pN/pbTKMBfq
LV0y98dGO8ZcDRlZLvf2Qxd/duxPPrezrrNsrrjfjo22tkne07weBPKoZO01nFPs
5hFdx3M/2e5QqleUipXsz62c9bICXT8dEni+n2goWbNlS6bpJIVz+a3tWaIHK0MP
hectPn7U8Ide7uzPQoktl/Y+mvrhJcO7jaZ/XLbttm0RuMYTE1Hx6MrU09G/ny08
lqLirWajknB1u8KxDWoi81h/nnbjFQ5zr1zn7faj3va7xZVVWec+F0d91TTLv/RH
8/kdy+uLL3BMW28jo1+4rJHF65Z3vd2E/KgH/77FRknunc0+wTKL9+Hln1Hab09O
ErO/a7F5WobtmTWZlXvl3bg/TNzKyVwnY3zIInu+cM73o8kPg7gTbNX/XnUujrh0
UVKs7O4iYWE55m3Gdw+0LDbWiZm+8TjbsRbrCa9C34kfiTXQvOPj2JTz751jprku
323drSfOeFsXpV02cloreIbbWuux1JSWqw9SNa1E5BhTeqs51GRkpzwNqrdmUGvb
ePJEumf/531Se/+tOnr06Mk1S+a+vVx18uy1x1c58gXe3xHX++T//ILfjZo50v9X
udaLOdo9nM1z9rHvKf+szL4d8VmFhdt3aD28PL+qRnNpxFlGvTsKdVOLV7TL2Zya
4f+uy9b/9fnZ5+x4HBmXHo9quLHMlVP5MGfDiwALK5E+vtbFzg9xMHPU/3CH5T7c
d+zvrqvABMXg6ernss4poQkAGa8jWX4CAAA=
}

h_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMjJ88XRxDKua8nX1x0iEFHtfuzf//n/5xwW/55mtcipwnn84zl+2WCXY6EJS1
9rbXnrTyA9Jci50TSzR6zsW/Z1065bX32sw/8ZvF4gtrAsOL+e/uunQjzTv7VWng
/A+FvW7u9WZJIUxexzZ4hc+T3qhdoSpot+6P0KKPhklR97TTX97bV1d3r8pwseac
pIeq4maXtJeanGM1mqZto9Hjp/MwKnuZztymjkMzufp/tAibzW3Z3nDoWkCF2daw
adNmnWhdu7lb0OlhdPTU1r6v72/szd752eCS3X3+rX5iXPm2N5/+2ihWeVneQ0/n
cO7/n9KnUzPPcsQ7i5i1R9+9lPjU9liBRuX7JaWnzhvNn7ZFpqw4b+acpX/nTp89
TUNHNeTgHwZlm6lBT/6Hmwt530iMOSJU1nDoBQ9n+syudQaHgjfWHUj+HC9ndzjT
U172ocvNbkG39kMvAiRkZR++vP36rQGQvWOyi+tTPuUevtaLCw2sRIDy7yyuZ2Ud
igzr+Kz8hqf1IqfKm8ms06yfKP75XrA9tPyedE/FjUtb/B35s5bevnNTsvZYcsxt
S3GWU5fUBY9/0NX8tK2o5bG1Nkf/ncZ/z79dmffxxKQta/myzmY9VG/c9EUond/f
c7tg4j+WKhOmu5fsgE6BxhHC/hcIwXPST35sP/bVd14UMEkweLr6uaxzSmgCAN6Q
CDBAAgAA
}

i_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMjBM8XRxDKua8nXOz77CCAEvi1v//T99r97h4yk+pL/HFltVyxRZ6UidUjl15
bHFq7o+btUw3Fd7wHXqn8MZvQ8Fa028ND688PPR4/+3HCufdp3TPdHz4TeXqE/eW
57/fHgv7cffTyvezdBYq7lLX/Zv50jiYM575Yn6f40PRWv30hHJu/jnXTm+f88vp
lsm2PZeyDE/O2TKdo9xTrd41d93Sz/snlHPla9r/2PoEZJtMY5GrL8hWPhRCpuvW
0YdOh/4hi5/b5qq7W+Fh5pTHug8PPdrWqvf2/C3WR03ljh46emdTdm64xST+b2tM
wxSz5Btzb9+tloiP6rK+vFR5R9sa4Wq3Q1YgDfxTr0mVzHl56fKLlp9CQmXpazeE
nPzY0HJ7xVauZdeZOL9/6FXM97OozzgSX2nBGWOeussu9PWPZf57j+Tom/aft5PT
rflrJ3fqTN/Dy3GZ7+MKHh0+EOd7L0fx0NtdJph+QCX+MNY+azm/1tNjBTDCGDxd
/VzWOSU0AQC5z+xq3gEAAA==
}

j_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMjOc8XRxDKua8nX1w0iEFAZfE0///p36bsCrEx+SQAbPv8vsnnbfUfDkgobhz
yqR5R+6/0TeQ4tysnFimcubc6W/b5nz+9iha+r7+jp1pXDc/5PYZ/eWR6zs+dUvL
TUO9KPdvni+stze/EF0XWbQte9vDGXZW0yb9U/sZ/K/i4Jo40wy+5zkv6wVLOK9f
N+Zzexh0yl3YZK/25NuXfjDO0rRZKuPG8XhNRGaVZ7/7oTceN6S3WHOpvuH1c74V
cOheBp+/G1Bwh/QWuxInzuoGmaIOg6j3totabk40sA48tOFyhcuhgE9amUBX9rXc
7Lx7ndmmQWLGh5fzOJ+IvSpU1X3oIbDKKkDiocQt0akl3JbpLVq5h+61Z1fphMrH
fbyT+GnWYW7RbbcXbe0q/pEZZVIlbGelL7jpV4H89QnL7Z8ULAqXcFksB9RozsrT
nX7o2fFqt0WT1j0LOR9geC9BZJvuOQ7vXf6e64XyL8k8O66050XR1oUt0pHa95a0
3F7RI77w7zuNxLI5+fwfJWcZHJq0bn/FrZ3lbtITD6wVO7PX9fzaadW2LZxz9mzz
zo6I+/E2uO5k841lL5ozG15MF7MWSgOFxQxZaAz0gf2LEPxs8bBe3n3pydJstYnA
6GbwdPVzWeeU0AQAayH22BwCAAA=
}

k_png: load to-binary decompress 64#{
eJwBiQJ2/YlQTkcNChoKAAAADUlIRFIAAABQAAAAeAgCAAAA6ozioQAAAAlwSFlz
AAAOwwAADsMBx2+oZAAAAjtJREFUeJztnNtuhDAMRJ2q///L6cNqI7QLNBhfJmbO
U6u2KKdjcmND673Lk/jJbkA0FK4OhatD4epQuDq/ir9prY2ve++ttavTte0VtgRM
+y63VY6bK9Mtvn8FNcYlfWICgqaknYhZxlgm3HufbPT3r4Ut2jTCu2KrLDPth6XJ
2zjrH/S4cVgvfBLRTMhZ/XlOwt+2Yf4uwuf3Z+5YbS+ss4UelsyJ7LFvCW8bqu6o
gsenzKllylBsWdLnIX/8tMjE48gZxFbMFw+GV3MioqRx4pWAYQnKVmx76X9l0m3F
MOFdGcAdn7iZFkK84ioMGK+EJQwSrzhNLdF65i1mCQ9JzEoeuE8toeKVyMUDCL6d
Flq84ioMaCt+wpi2krJrmUv0rmU6ELuWkaQ9TMuCCVuAHLJXwrDOLGk7MEP2/VAL
oLP7xAPN2WXXEtn5rvDRRBLW2Xd5ePUBcgDuwxKaM8dhZ9JDjhCGWiGzpKtj/+Rh
F5yqZsLVobA/1T5NewRIv8WSrg7KEYAwQoURbmOWdHUoXJ1o4dFvVTiZlr59M4OB
MMJgMw/v4epknmpJuecTEl7+VMsSnfPgcfew5k0tcvsY8MfLbRQNUPO4hCk8h2Ed
tjdWFzzH+LUW+D323SPxa02kxWPxMBPy8gem+5vXt8iFbdxL4zs7fhIP84lx5iGP
FGev93hclXnWq2kiSRaOr2omnMQCc2krXlUdVtvKDYB1yU84GApXh8LVoXB1KFwd
CleHwtWhcHUoXJ0/sPb2sWeMZHIAAAAASUVORK5CYILHNDROiQIAAA==
}

l_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMjDc8XRxDKua8nXMw77CCgMvCU///G9mKWOYKCSeVXbv8cU9xymcb7jXKM29F
aYc/ev2GMSU5sVRnTV/r1UjRdVuvRTm3TTqs+0RrtnG9tLDynoP5+6IuVSdtKY1z
XiTxYqOrrHKMmpKqIb/wu+nSWcYW7G8O71eVnHKM5c3hBfLNDmsvbWF5f7j6g434
90vtD+LnmDN5zTr1XFcvs/TBoRzW9y3TE7u/MKrv4XE+bHOAk/1i1OM5Zw60WGZb
L56+jGnqh/PKCmteSTy8dque01In8ZBB/KNcTZFDVuzvDi/Q1m/ynREgvVtX8JGr
tyz36uSHARzXs9RlTrVK8UeBHP9YIWZjl/C144deRUQA5R//X3p14wYrsbDjh7IF
/un/bhAOg0h1GLxdHVR46FdEBeO/fZssEmt1bM4mHDPyf9Z8POqMRuE2+SuqvSum
PGaffqY/bWnHodNPfqh/PO98s5olZP4XFnnfy/q7asQE381Y9Wb70pmdDLFPFDnv
r6/TyHqhmRLxsK7ff8tFd8lUju/WvjJ5kwoKgucV7JevMK72Lntc+Kv9yvOSKPWs
9OlfXjvaXLXMCxHZW/LMebmAXv3chf90Dkm/2KL5rECthHMx1N0Qj8DiZuecD+ZP
5LdvfZsU5wCMeAZPVz+XdU4JTQD2iPgLJgIAAA==
}

m_png: load to-binary decompress 64#{
eJwBlAJr/YlQTkcNChoKAAAADUlIRFIAAABQAAAAeAgCAAAA6ozioQAAAAlwSFlz
AAAOwwAADsMBx2+oZAAAAkZJREFUeJztnMGShCAMRGVr//+X3QNblqWjo5DuNCHv
NIfR4ZEQQEfLuq7LTPx4N4BNCkcnhaOTwtH5bT6ylFI/jDWTl7bmbrYVQ2d0P9qk
9MHf/Tx3P9HckR8b1xOW/Qlxw8S4aJVS2qJEiO3/D3X25VVDX53WPFluaK/S95Ty
qCuZqhWU8PKt3tJy+ABj4XF2u7FFz+qklZZXPM8AU3pDainWG+F7mXVdP37BsQum
2zxghXWG7oZWhAmpriVMIIUpOI7tjLAGuBRwEPadq0QjjAMurLb2sBeW2iqc0Upp
QjpoCW/ZMcxVy8qhufu4uQ9ptwh7DXVj4SsN/tXJK6gRVrj/hhI+K7mP3orDGN73
BT/UbGH3ZYmBsLvDK7QWHgSowgq5ABR+qEfuhUzp6GCF36brGNvDh61UqFgLIaVF
PDfy/nAfbYOQ2SOQlBbZGH3EXrjayjrz9sMiTLfwsK/SsrGt2F/Ekx29FUvhGltx
Z1SVlkVi4WF7hnumq9KMe0ugQ9ownpbE56SlP8LiJeqM0BjmZIeQMAfs/6UFyQhH
R0iYU/CFhDmksB85D0NQFIZWL0VhKCn8knl3S6MsqkVTOtRDHr7oCoOCrCu8YJyl
hRGksBKIqa7lujRnsaHytiXc0wuiLx8aZUV1RcsYRjtDz99YtMzbRHvgpb1K719K
YlXGZnnLA3OPaXarpb/Rw1zE63SuR9GKv01KDzRX9b4TbzgkihaTFI5OCkcnhaOT
wtFJ4eikcHRSODopHJ0Ujk4KR2c64T+0xtjPU5P61AAAAABJRU5ErkJggrpFOYyU
AgAA
}

n_png: load to-binary decompress 64#{
eJwBmAJn/YlQTkcNChoKAAAADUlIRFIAAABQAAAAeAgCAAAA6ozioQAAAAlwSFlz
AAAOwwAADsMBx2+oZAAAAkpJREFUeJztnN12wyAMg8vO3v+V2UW7LidLKBBbUoy/
y60hCDk2kJ9Sa32sxBe7A2hScHRScHRS8CCllFKKQiO95xqtw8+e1Vp3Xdy18/7v
x/a37QAmBZOCh2ifoj1w5gwLfh1mKhtp8qTgv+NHlJ+dC2myYpZ2TWBXHX509G8o
b/UfNYeiw0+cfEYInu66h2YDwfdaUQuF9OHAmZvMFwyeafEFgwEJvhKZtlGdDkti
aLKW4IYwK804wR97jNkD8BJca71eY3aNmIwIP6TPxuX9d9vi/H29if8Dbz5/MGyQ
7/AhflMuqGDY1mQDX8GCCynRkPZDUfBym3iupODouAtWS9S5iRcdG8Fbk8UNT4ev
cWivlOfGghWWB23kQto7HOQEe5OCowMSrJOo02Fn6HUrHY4OTnBP3sonAOxBLB6k
IDjMTdQZ0tHhCwZHOF8wGKhghRxOcJgrm1yW8CUqN/Es6JeND28bwSZRihHPKUvE
yF+uDhs8mLZFodK2QTtMHxFaSLMu4+WuYfsb4uIwHaZENTmkbz+X1sd4arno4qFN
tPWwuMkuZQn5XY5RjOfSj99PfEzELeY1U5drWHkeInpvye+K4NTh9riYvNV2Rk48
2Kz1JB4g282XpcO8MleQkEw67PFm8423aSdmWrC4mBQsHrcN5q/hzo9j9fwGOXwu
c2nzNg3hlyXwAOVjS9EhC77r/eF+6DshTIcp+Zz2lQdW9cqk5YnT12aGUF/NmZMh
HZ0UHJ0UHJ0UHJ0UHJ0UHJ0UHJ0UHJ3lBP8AM4Tn0hcY05YAAAAASUVORK5CYIIP
WTGFmAIAAA==
}

o_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMjK89XRxDKua8nXOx75CCiEvq4///i74fXKK4Nqzl9Jm3Bs9Pzoh9WvJATDP3
5ra3G4Xq37At2LjBSiws3fLh8x5+3aVv1m+e+80roTnrvLHnGeaW9bbnC862t9SH
2joYvheX23KXMdtfM6rf6/Hrwsq/jD67jR/Gvw72Lj9gcXx++/1tu13VsnpimmdU
1LzaMmUR69zM1AI5oTyRFffXxE8PMri7I83DYs9Ohv9P62wEWnYGn/Z4aCe8wX65
t7yX+KfVtm3SHCdbTCfNLWD2vKb3q+DQXpNjfvHflVR65ttfPxP1cUfbix6/GXEf
YrY8+8xVubDTXfN9ON/7XR3fp8b61PtqM8899CXpdq9wHlv9TUOWtEN6URwzDp0u
zeQ6OD3qk7P3jK/cF2Oj5hokvjvka7340N3S1x/6N/x6rre2r/XqRgPmJyKmrQZC
55deBYWF3IL1fHfzk6Pcu8V3KfgdP/RKZ3v3cc7knTd95cpZdH3iz5YeSr7A/KdL
+J1SynsDNnUel5Rg77a6asZ3Yg0q7IeSJVoP1b2Mznk1c9KHyh1y9xTlpPofKrzy
+HzkN4e43X2JOU9ythhv956f+7KV98uSaTY+nj8mF7clG672Tq/QOB2tJC9Yzl0j
Fwa0NyJClnt1cmKpzhqQK0GxhCJ4zr6q8NjSGcUfHwLTAoOnq5/LOqeEJgB1MQVa
OQIAAA==
}

p_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMjNc9XRxDKua8nXN6UrMBD8vbtX//x3+Tu7FIQ1hog2nSDJ/7RR2P3eo8HbKy
19YI25eXK0hzr05OLNVZ09d6VVJk3dZrUdvlm38xL+eT0b3/onTt3P0Cmep3BB8y
cWc2fVvw4f90xlsZzzUfGj3f86/kOscVS88fj9cvsVy8bWlu//kvdRVbd3NdtJvz
2Ea7RmTv1t05olN/cGy/tkhF0LFPnC9ye2HCc4PbFXqBh+7OOlOzha/PINHDumPb
0kmTSlm5yzMfS1xI/NSd/Sto/+VltT4tM8NX8nVZ3onVf/F0scC9ItPXO7jmGlSV
XeBc33DtVcjD2i992zY+F2X4ppOU3rXb/2779jn6SYv5lzs8bHz6/OPLh6pFQv1L
FP/OOyPz2u9hdNHJ6pZ8n9mBh/Sz1/E8Zez4ENfjWNqYMfXcwUOvWDg+nzlv7JC3
tWW7ZEf7FiuxsOOHXkVUSH26rddXwHLGsazlamf9ilYZj5aZf22XXN24wUrv4wpY
kAF5QPX+R6Bh+PoSWKdzh7IMY/GEQMFlpf92PUn81vmDfaWej+uPwm2qT+a2T/8v
5Fr9bdbf6pX7LGdtD+/jEHt2nJ0f2Tyg/RGyiHgBCtZnfVv6qOXvh3nAeGfwdPVz
WeeU0AQAOCwFeyUCAAA=
} 

q_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMTJqeLo4hFXPezrld1GzA4/LW7///6S+Zg9sMjxj2bYnSrr53yzOYb1ejcPD2
XO37R/y/MC6YWFCmMkeWM/359a93s9c+l5dMqyu16nDbqnjhTtyO9VUCT3OUbTQq
Wdf/nfhhy3PJDZvzL9/aqTX3fMjauNon037WfzPb87e8L+tBXPGMRKa7j5Rskm7v
ObZEtsdA846l3a0b7yTcf0zMPbFScde0Yylf93zYlvvkZvXpPzJtWyWjdYKrOhuE
rxY0pvBON2AwTpxcwybSqmRzWsu3OuiG2fcJb2M1edlt9j5u5d72T7NloocFn4+h
O1d7T94ijuQJBnOUN96cXiHmeujwDP+Jf5I1WTjT3Q/5RyQp7mpUPXS6XuHftBWu
9vGJh5b6uD+8u+2a19KzQYcN9rTIu4a+vtR3hIM9bOvSAvfm5fmaS+U33bmqqndI
JVJ2wqWNz1YlKh/Lrr7a773++N65N+oPBxw7dv9jxWqRdzyrEue9XLrsKZvnBNGH
bxxa893FPzF0tRf8ePAyWd/n0py4RAWfvBsLlrU+3fYgdvomwd3e/HEvp/7fxWBi
s6KA/dvedl7u2vvM5u2ezzbv2sKv8lA3UPBd/pWSvZM4b6wo3WP09l/ivBo9v0OP
2yTz+KVvzLN/srV+htmJvunTwp9/+DDtxnKbmh/hxQ/CbNjW7nkaG7Rr5/XkE0+Y
X0zu+zUnv+fvg12VDHNqgQHzoMuAARQSN2HxioU5d73wP+bcTfe25si8mABMSQye
rn4u65wSmgCRNCq+dwIAAA==
} 

r_png: load to-binary decompress 64#{
eJwBbAKT/YlQTkcNChoKAAAADUlIRFIAAABQAAAAeAgCAAAA6ozioQAAAAlwSFlz
AAAOwwAADsMBx2+oZAAAAh5JREFUeJztnNuOwyAMRMOq///L7EOkqku7hIDtGdw5
b42aKgeDw62UWuvxTfygHyAaCWdHwtmRcHYkPEwppfnYXOHksXLzFoYNxlWavwjK
XF/6Uoy2i35b+G4M2czvCZvUWGwRLCWtOd5LLbIIJtvwn58wSlQx2gZZ+nxQnoLr
49LTqrU6Jf913Nvwu3nfqhSDVtbBIMIfH7FjNR1/E2CDB5SzvfClCbb76Rvh/+T7
Fd7tcY4D0vHYvqdVa+UfJD2xr9Lk8javpcsrPDgmrYm2GtC8NYmXHQnj2GY8vBcS
jgL1rlaEY3lNVBvPaV0C7HuazVoO0iwyxpt7RfhjKTAMKoImAEZUd+p49J+Vx/bw
jjCV6omXMO0CMua1lHkini1d+07xWC0sGmIjjF3jvoXXcunlFRQu07TMaHjoRlOr
N54A4GmfI0T0pakIXRBnKBclrUAgeUsRXqYfN3gzVoSzAxCOn3x/RRHOjoSzgxcO
zluaps2OhLND8ReAyLylCGcHKQx5OSnCFkwkobC8RbQxLQZV6exIGEfmzaVAJDwL
fElhEHyEg0sKLxwMl3BAouYSDmDpDAnDldHnT513+R1uYXZi2scvzB2jdt7iVL3n
hZ0i4N2MlzaIj+w1Y3s/W+6It3Wja8ObImEQYU2dRbjBz59U2A8JZ0fC2ZEwAeyn
Hu6FhLMj4exIGI33ONH3qF9C6CLsjYSzI+HsfJ3wL+iF1dTQ5GQCAAAAAElFTkSu
QmCCA9MfC2wCAAA=
}

s_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMTNaeLo4hFXPezrlZ1GzA4/rW7///6XfbfWKXNQhOunDM1n+mmqqMt1uFYm3P
xXtHpn/njGB++Mphh5XAunPfnY+/3Xv++kKv2utWs9c+lBQ8I9qiuUq4PD1T3m6z
rfDrvfezFEqn/P5w7fPnWSuu7456vuuH0sPrPvO/Fn67dfu8MP+iJo2lL09aHotQ
+fmn50lKx4sriY925m3dW/UpuHRGU/fmw3On5ac+4s5/XGweVp2+Oczg7WHBAmmb
iq0XX7t5+yTev+3MqaiUM/Ne3qE4y0UKc14I3W1askVVJnFqjk/8tE0x26+2HJfQ
nCOYaLRT75xw68VJH6e0Cpzn2G0y4VwP+27m29avfRjm/FVV2HF5FZ97xcWPfOFB
Tkutip86vngQcWCG5tqtDsn90bJ+lowbIgyl9svsU/0ZpDire8r8BbJyH+Jtnl84
FRdXnJtZ+G37tS75o8v53rPLpc3gcpfws7yfmSplo8J66GrjhgaO1G9CTzNv/bgt
MPGSjtDZK0qHmB61b1c8JBMUsphTKcf1mizDzk87NfME/As7814c/noxRs+XUclH
ObNCWilG/l+R5uIPbi84Ll11flw/pXnKMyHFWE0J2y7x5ZY6QVZ9uYc3tys5uX7i
WVkwLfHDEaWlzqZcrz4wt7y6ferQdGvvu5elNXXdPq3Yw2gVzd+Z9O7nHZ16ZoWm
XOPXhx1zZr/b3N6z/U1ljaPNlNzLd/X/lgcs33tBpKfuqBbfjo8r+FpWw+IZO/Pc
65Z6Bk3+VwcrPi+cA0xbDJ6ufi7rnBKaAP7kLdKJAgAA
}

t_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMjKs8XRxDKua8nXM6r8VAgKVwyv//qUURnIpzNhw50zP73qrP6wovPp7usKU0
drr/o+wy9lWON2Rb7jremJvw8FpUtu62sxFKrUdD43s4vif9Tji6PS93Qf31yXtu
/Nh38M1vU6U9d1bcu/7U79883T9zb1Wd/zlXS4JPx3vrlfMFzckVO7dzyOpFWR5m
V9nz/umudfnWf6/zZ13q03zpHP//6tdHb0/tKMgv7aja8TTkndqezliTOdHnT8s+
dH8zp3qVuZzt0aPxu/i0ed6c8HwteMfrR+e5N0ubXzwvmFjkIRgWt3GTkNjJze2G
b/zmbjhxQO2hgsunN4oPTVzEtIT6HFTOxCsmlguUqYdHFHw7JSp2J3/p9C1RJ14e
ylIstuFxWjvJPGLaosDuXUoPp2/uqFz04Xb4pmUHJPwctFKEytovT7Lm2H048yQ4
EKDE4kBrxUkbgOLNIOLw6aXvFN7wHQISfndXtyudn3Zs/5Wiay9Mt2tGT5ypaqv6
ecp6mzeLhVc+6Z0yyW73vTf6J0O5/dtTUYxEJ35aPJS3ujNzy0lH45nAqGTwdPVz
WeeU0AQAWBf0MvgBAAA=
} 

u_png: load to-binary decompress 64#{
eJwBSgK1/YlQTkcNChoKAAAADUlIRFIAAABQAAAAeAgCAAAA6ozioQAAAAlwSFlz
AAAOwwAADsMBx2+oZAAAAfxJREFUeJztnNuuwiAQRcGc//9lfCBpmp5eYJhbt3s9
GU21yxmGKWJra638Ep/oE/CGwuhQGB0K21NrrbX6f25HX/jeZ3spyllBeG/4qLHv
c0Kc/8RHHk5Xdva1VudWTxLhx0F47xDbzE4LTyXtyDs4J7Zy0ZJFz9PZZFoSCLg5
Twu//XLSJMKZE1siPOIjnqUER00hnJZOn1fJdmtnqwinhVdLGvg3jOMIha98etc5
2Fq21k4fm6IZ4V5vFs/bWlu/tRwss6diDkFeFU47Vq9glUZHLnyazLI+yXNcrEZY
3An2A/2XtWJSOrDUcQxrELjO/khkhEO+F/1Oq4/PtEFeEr6qPbMrtZ6waC3wir6a
CwDoUHiSqOt4Meyl0YkXfsEOgFfDq6VJ/rtlti2pfh/2QU04s+QeNeHkmbyhHOH8
2pyWlkk+mFNsTPOEKe0CF/H8oLAv/kWOEUaHwuhQGJ1I4ZDGmxF2BGHLwxS/ktKx
y0Acw1LyL991GGF0KOxF1Pom//NgTHgx1//fUnK4i8eSDCmgLDyi9LLbWojJEN5S
is6214PM4T33r4ZPYzoRvjKMvbHSKZobm9dv4uIAe+kFMt9zaEN/r/59AQvHdlNL
NttiEeHksGihQ2F0KIwOhdGhMDoURofC6FAYHQqjQ2F0KIwOhdGhMDoURucLa4PA
5YO6zDcAAAAASUVORK5CYIJSshCkSgIAAA==
}

v_png: load to-binary decompress 64#{
eJwBPwLA/YlQTkcNChoKAAAADUlIRFIAAABQAAAAeAgCAAAA6ozioQAAAAlwSFlz
AAAOwwAADsMBx2+oZAAAAfFJREFUeJztnMFugzAQRHHV//9l94BUIQjEMbszy2Te
rVKT+DG7tgNuW+99+SZ+2ANAY2F1LKyOhW/QWmutcd/h/UdErcPbgc695041aYMw
n/A2jd1YJ1I6viQp6t+br8+uwHBKT1oZV7O0cAaTwm+vfVQ44SE74QHAE1Xsxznh
OGquWDPC6x6o9w64WxL+KZMJ/w8iZDRntZBxQXN7+E5Vl9tLP5QA4bMoat4PzU24
915trk4v6Wo5u4fViREOr9u8RnDCcMDTOF8YTEXh1JWshDByrS4hjMTCbLLLO0y4
2p75jOCEt9ojC+z6O8il+O6zpR3jQ2d9bYxM+FjVn1oB+qLcpJWNhdVJmaUHW5Gy
kqUkPPIw9WiL8eeUNHGXEi9cfMvFnLQoe4904TMrzKmsI16WIhiJi9XqTlgdC6tj
YRQKdzweQQlh/ScPxIMfWcJlvzOVKGkkBGHuQSYnnMB1pOBuRydMP5iXKFxzonYP
q0MWxpd9+vHh7Y/0GWuBJbyqYv4u5Bqfl1aHKazzuPQlFWasBSNcqo2Djy1dUyFk
Wg/72RIIC6tjYQhSp3heUmcpdkmrQxDmljdamN7MLml1cML0Yl4J+594T8ElrY6F
1bGwOhZWx8LqWFgdC6tjYXUsrI6F1bGwOhZWx8LqfJ3wH2CVotZFdu+PAAAAAElF
TkSuQmCCcu4Jdj8CAAA=
}

w_png: load to-binary decompress 64#{
eJwBbQKS/YlQTkcNChoKAAAADUlIRFIAAABQAAAAeAgCAAAA6ozioQAAAAlwSFlz
AAAOwwAADsMBx2+oZAAAAh9JREFUeJztm8FuhDAMRJOq///L9ECFkNgFkszYE8fv
1EMV8TKOyQao27aVlfjxvgBrUjg6ywn/ogaqte5/oLogfMD/YSHDHRe3wxgTNTig
pK9X9u1aIQwOPipMdWOg3rQ+FvDILLOEgcljndUTvqHPWVf4TTeutbZq6wrvfPQ5
z0XrXQq28QDyJrTuu7F6wgW9qyEKa96iJ0gYy5DwTYayBymTJTw+j6LChxi8UkSF
eQ2vX/j+mmrF/NKGI5rwATxqdeEzkJJhCWvWc+neS19P2Nj7KtQMzlHSwHoZEmbU
Lbu9z5EwEDlhdrfrbFqyTfgRWMKzTIFcSbNJ4ei4CXudePkc097YsidigpLG9n9P
YZeqdhBuepdhmjMtzVP4MsUaxoIUnmJ3aZ3w41kn+wKypJm0xstYI5nwGOdMWhek
Tc8jJtwqwHh/8UpuLaNjJ+x+B94RTZjXwPDC4htMh4S3bTN7BHdFpaTN6iJfTOPw
uE9eqEvb/GY4sBb+JnPuZFT8EzYmhQk8fnK1/4NN31ouYe6zJZufuE1QEu4QI31a
eWW5knYWti9yO2GFBVzcE7YnhaNjJCyygEsmHB9/YeNqX+6bB4uE38sbTJN/SRuT
wh5YLngJYUtSmIDUMxet25IBdGEp20I9tVRT3RH9jptHdunopHB0Ujg6KRydFI5O
CkcnhaOTwtFJ4eikcHRSODopHJ0Ujk4KRyeFo7Oc8B9CXL3bCo+4SQAAAABJRU5E
rkJggnLhHUltAgAA
} 

x_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMTHGeLo4hFXPezrmdd0RBwNn56v//qb8aWhbFbOO8YZxWdu6y121XQzNmVcWl
13bVCtvfE0/w5erz45JbNCXIa+PPqyoe7fGxtf+Tk29qTTS7HBPwuWD/o+e8cV0p
67k/8PlXHfXbEb3k7enQZqWKOJ711iFd1yQnpXUlVCiyKEllugX3xucU81caKXq6
zyosXMI5M3TLvbKDS/dEacdsy5uq9lDhR86+p2bCgRuuR70yZjg469C7Bl9v22kT
io4eruLZfZxR4cfhJx/X2/yO/Thn2jLB/VMdyyvmv3I+FLtLTbn3QXPpX+31T6It
7kx6Y6do2qOku6iM+Z13vEmt/qWNk9IvHlpoqWht8ea2oGSmRtPKbWU39nIbXbr4
kOtaZELppUSjd/OWH7540pq/psa6Se9GbWZpQ3X9jmu37OfsLz34TpJfcLWuGYPL
EjOf6dO4Tj2dtzXlcNGPc2ce3j6h8YKbv1Xi/cmlqkym4d8r8h7t5Ene8ODvRd6c
0xpFynLHJ+8+8s0i/OVW/qzSeSc6/rA0iFzz9i63kc2bm2TTU7zUtPFNUnJ/8cVN
/qV22ZanhCrvPeDjvyH9p/OH9RmmRdVGvSyXEj8WXZ3QseXpky+lz6epyGxzcd0Q
uSqxafqKiNl9h2W3nSxqutnDoTYzwViDTdYuZ8d6o4bthgf3Llpnymwuctxgq/zx
/o88e/xfhW7+ME16c7LEuTiV5Cs8XHErvGQP/Pl8oPpn34Vubx4fManDKjzPdq68
HhXgG/fmqTPzBvUlbRMe8JlaAM3fOqEiIUrYsv3mkgcv8KCauQ/suWWv8Rpd7QUm
OQYGT1c/l3VOCU0A0itEfawCAAA=
}

y_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMjC89XRxDKua8nXMw77CCgIvz1f//U6s6QiILH6m0zZTl/7wuVEN/tw731ttV
77dP/bFyHsNsjt3CieVKb/i8dmy9FsXMa3fo/YPn78P47562vPp3uYBvoLTkF+GN
2x/L8xvd/VnjJZwjyNB9bcfaAC//+drpjPdLtqneWvh2yYePf/zO7/veZ2Yvn3jo
iYBDUNWSb4tef1vx4Y6CcJnm1EWuyU0ftoYZffjAIFUpMHVK3Y+mgkhj9x8v/5g0
rxF6qHth0QINHle/iO1b92hEHWrRrZ31wWNh2rXihRzFVtsuRp92XPNuyzsZjdz6
JXWPPyqyS4XWSoRFbNidIrJ2r9nbFRvSl31Q5Tv29bbQz+xZOn+yvt2WWRd747Py
n9AjP1YzTLp06jvjFb/VGyz+N2tFbaqfvmL9pZRTUadX/VA/JMI1vbyxINewmXv1
1VdPrxls+yjwct02HfGH4ECROBQUXXjz4UKuIK/XM9J5QUJFNkcWFOd4ee2efOzw
XLCiikNKrVaCZeqH3rncmMuUuF3945FOA6HWNG1Bt0UFU8MlHwr9X1hv9+WrfnVi
xdVyuXufQt7cWs/wIlgn5xNXg9HU25OuajNsmsK5/qvLHyH+Du0vU83rlofWJaya
zzgzJBMYL34tdzs3WMMsgEbWuaJD9Tace9cd35+0GJgSGDxd/VzWOSU0AQAq/Qrs
NwIAAA==
}

z_png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMTMyeLo4hFXPezrm9rslAwHX5sf//n/5yuCTAejnz+bm4fjWl7p1FfZeq3n9R
ibunnsDbspr54as9X/nuRv2uvVirYXLQeIfJnsOna1xnqB5z/e204nrB+7lPF1SZ
egb8OLdq67K3B5wWZMquCgq7pamrMMf1q0OhztnkmxtDZ4mtDpQ8r17W8l/9w883
qdnRXBunlMUvVBN8fcns/a3nheb8uw/tPOQ9+1Dkq289zl6/45aVPpz5ed8cz323
TWddkzmdWbnnouHqm8UVn2PuiusfnVJWvvvIujb3rJS3lzwvCv079dxCu8u15fz3
znfPPDI5z/18I3dJv0dJRmW+p7PFsx+yL9x+fPePebcg821hub3Gb01rDTeLBLvJ
awr+fJj0dJkoi+HDjIl7nLUPJdfzicZtmnPYcYLguUnnl3x/H9R7uKvBt9t/UY2a
S0TDCVafoEMHVc+/4XqulSDUWXBm9yLrC1tWNV+ddH5Db/yBlinr+FvCPQMPtHB8
9jDpZev4IBTJNUMgkU2Se4bAQ1EhUQPFQ5tVdBOcWl4zJ6r91r31Q11A+1CltZji
0tePdXLiZXMeXmH1eSe4jd1+m8mRpVYTLl1t3CAa9/is+43CGdw2/tn/OOptzqrF
dLTzR54rbm/n/7lOOzr+wbzO3C25OnfMr209KLOODxxhDjusBHAwzz1usU9sPHBy
z05rNmAaYfB09XNZ55TQBACwgReWUQIAAA==
}

__png: load to-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtIBQFzBwQQkX/U8WgikOAs8IosZGPgOgzDj8fwV
KQwMjHyeLo4hFXPe3jnI12QgwBB47cf//XvieNTaprDOYjq8Z7OJ9VoldSXj5eqV
c20PZLBdlvRJN5h7sIQmjO92RYUuIXGzJASnXj22p74w9dGjNcklNyeGfVia9frW
703PtW3XVxyX1fzLsV9+r3+cctbhWCtjxveldwsO7c++1lf1elbt+29vJb+x+D8V
ZF9z7UbrUdPqc7W79v84usWZXy48+Odvh7kFRx/PW8q7zHjGuQSr5pc8qIxd/BfT
PS76H3OrBAYXg6ern8s6p4QmAAIvkrdcAQAA
}
