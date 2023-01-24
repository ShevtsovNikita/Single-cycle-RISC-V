li t0, 0 # результат
li t1, 1 # первый множитель
li t2, 256 # второй множитель
li t3, 1 # единичка для фокусов
li t4, 0 # счетчик
li t5, 15 # количество итераций
slli a1, t1, 1 # флаг

multiply:
srli a1, a1, 1
beq t4, t5, done
and t6, t3, a1
sll a0, t2, t4
addi t4, t4, 1
beqz t6, multiply
add t0, t0, a0
j multiply

done:
nop
