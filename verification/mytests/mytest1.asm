lbi r5, 114
slbi r4, 36
slbi r5, 44
lbi r6, 230
add r0, r0, r5
andni r1, r2, 7
rori r5, r6, 6
stu r2, r5, 13
sub r5, r4, r0
xor r6, r2, r3
sll r2, r4, r7
slli r4, r7, 2
st r5, r2, 2
ld r2, r0, 4
seq r2, r0, r2
sle r6, r2, r4
nop
jr r5, 4
jal 2
jalr r6, 3
rol r4, r3, r1
andn r0, r5, r1
btr r7, r0
sco r1, r2, r7
subi r2, r5, 3
xori r4, r2 5
sle r2, r3, r5
slli r6, r2, 3
halt
halt
halt
