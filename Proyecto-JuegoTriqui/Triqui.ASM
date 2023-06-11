.data
pedir: .asciiz "\n Ingrese su jugada"
pedircols: .asciiz "\n Ingrese su coordenada de columnas: "
pedirfils: .asciiz "\n Ingrese su coordenada de filas: "
horizontal: .asciiz "\n- - - -\n"
vertical: .asciiz "|"
resultado: .asciiz "\nResultado:"
gano: .asciiz "\ngano"
empate: .asciiz "\nempate" 
space: .asciiz " "
warning: .asciiz "JUGADA NO VALIDA"

contenido:  .word -1,1,2,3
            .word 1,-1,-1,-1
            .word 2,-1,-1,-1 
            .word 3,1,-1,-1

    .eqv tamano 4
    .eqv tamanodato 4

.text

#no utilizar ni t0 ni t9
#t3 VALOR DE LS FILAS
#t2 VALOR COLUMNAS

#----funcion menu-----------------------------------------------------------------------------------------------------------------------
main:
#reservar memoria stack SUPER IMPORTANTE
    addi $sp, $sp, -8
    addi $t0, $zero, 0

	
#funcion para imprimir toda la matriz
	li $v0, 4
	la $a0,resultado
	syscall
	jal imprimir

#funcion para pedirlos valores al usuario	
	li $v0, 4
	la $a0,pedir
	syscall
	jal pedirval
	
	#aqui van todos los primeros ifs
	jal funcion_ifs

#----funcion menu-----------------------------------------------------------------------------------------------------------------------	

#----funcion imprimir-------------------------------------------------------------------------------------------------------------------
imprimir:
	sw $ra, 0($sp)#guardar en stack para devolverse a donde lo llame
	la $s1, contenido #inicializar matriz *hacer arriba antes del menu del while*
	addi $t1,$zero,0 #contador de matriz
#   se imprime linea horizontal		
	li $v0, 4
	la $a0,	horizontal
	syscall
	
	while1:
#si llega hasta 16 se sale
        bgt $t1, 15, exit1   
#se lee el siguinete valor. se suma 4 porque esos son los bits
        lw $s0, 0($s1)
        addi $s1, $s1, 4
#   se imprime el contenido
        jal eval

#   se imprime linea vertical
        li $v0, 4
        la $a0,vertical
        syscall	 
	
#si se cumple alguno deestos se hace el salto de linea
        jal jump 

        addi $t1, $t1, 1

        j while1 #  termina una ejecución y volvemos a while, ciclo o loop

    exit1:
    #aqui pone en ra el valor guardado arriba para devolverse
    lw $ra, 0($sp)
    jr $ra
    
jump:	
	beq $t1, 3, resp
	beq $t1, 7, resp
	beq $t1, 11, resp
	beq $t1, 15, resp
	jr $ra
    resp:
        li $v0, 4
        la $a0,horizontal
        syscall
    jr $ra	

    eval: 
        beq $s0, -1, espacio

        li $v0, 1
        move $a0, $s0
        syscall
        jr $ra

    espacio:
        li $v0, 4
        la $a0, space
        syscall
        jr $ra	
#----funcion imprimir-------------------------------------------------------------------------------------------------------------------

#----funcion pedir----------------------------------------------------------------------------------------------------------------------
pedirval:
    sw $ra, 4($sp)
    #Guardar direccion de esta funcion para volver aqui si hay un error
    sw $ra, 0($sp)
    
    #se imprime el texto
    li $v0, 4
    la $a0, pedirfils
    syscall
    #se pide al usuario la respuesta
    li $v0, 5 
    syscall
    move $t1,$v0
    #t1 es para las filas
    
    li $v0, 4
    la $a0, pedircols
    syscall   
    #se pide al usuario la respuesta
    li $v0, 5 
    syscall
    move $t2,$v0
    #t2 es para las columnas

    #funcion para evaluar si los datos se pueden
    jal evaluar

#----funcion pedir------------------------------------------------------------------------------------------------------------------------	

#----funcion evaluar---------------------------------------------------------------------------------------------------------------------- 	
evaluar:
    add $t3, $t1, 0 #para guardar el valor de las filas
    mul $t1, $t1, tamano
    add $t1, $t1, $t2
    mul $t1, $t1, tamanodato
    lw $a0, contenido($t1)
    syscall

    beq $a0, -1, modificar
    bne $a0, -1, error
    
    modificar:  
        sw $zero, contenido($t1)
        #se devuelve al main 
        syscall
        lw $ra, 0($sp)
        jr $ra	
    error:
	# Informarle al usuario que no fue posible realizar la jugada
	li $v0, 4
        la $a0, warning
        syscall
        #volver a pedirval  
        lw $ra, 4($sp)
        #move $ra, $t3
	jr $ra	
#----funcion evaluar---------------------------------------------------------------------------------------------------------------------- 	

#----funcion ifs---------------------------------------------------------------------------------------------------------------------- 	
funcion_ifs:

    #si el valor de las filas fue igual a 1 
    beq $t3, 1, fils1
    #si el valor de las filas fue igual a 2
    beq $t3, 2, fils2
    #si el valor de las filas fue igual a 3 
    beq $t3, 3, fils3
#---------------------------------------------------------------------------------------------------------------------------------------						 						 						
    fils1:
        #si el valor de las columnas fue igual a 1 
        #juega en (1,1)
        beq $t2, 1, lau1
        #si el valor de la columna fue igual a 2
        #juega en (1,2)
        beq $t2, 2, sophie
        #si el valor de la columna fue igual a 3 
        #juega en (1,3)
        beq $t2, 3, lau2
#---------------------------------------------------------------------------------------------------------------------------------------						 						 						
    fils2:
        #si el valor de la columna fue igual a 1
        #juega en (2,1)
        beq $t2, 1, sophie
        #si el valor de la columna fue igual a 2
        #juega en (2,2)
        #beq $t2, 2, mapu
        #si el valor de la columna fue igual a 3
        #juega en (2,3) 
        #beq $t2, 3, sophie
#---------------------------------------------------------------------------------------------------------------------------------------						 						 						
    fils3:
        #si el valor de la columna fue igual a 2
        #juega en (3,2)
        beq $t2, 2, sophie2
        #si el valor de la columna fue igual a 3 
        #juega en (3,3)
        beq $t2, 3, lau3
        
        
        sophie:
            jal sophs
	
        sophie2:
            jal sophs2
	
	
#----funcion ifs------------------------------------------------------------------------------------------------------------------------
#----funcion sophs---------------------------------------------------------------------------------------------------------------------- 	
    sophs:	
	#el programa juega en la coordenada (3,3)
	addi $t1, $zero, 3
	mul $t1, $t1, tamano
        add $t1, $t1, 3
        mul $t1, $t1, tamanodato
        #se guarda un 1 en la coordenada (3,3)
        addi $t2,$zero,1
        sw $t2, contenido($t1)
        syscall
	
    li $v0, 4
    la $a0,resultado
    syscall		
    jal imprimir

    li $v0, 4
    la $a0,pedir
    syscall
    jal pedirval

    #(3,2) es la unica posible jugada en la fila 2 asi que con solo saber que puso fila 3 ya se hace el siguinete movimiento
    beq $t3, 3, jugadasoph
    #si no es igual a 3, ya se sabe que en la siguiente jugada se gana
    bne $t3, 3, jugadasoph2

#---------------------------------------------------------------------------------------------------------------------------------------	 
	#para la siguiente, en esta no se gana de una y es para ponerla en (2,2)
    jugadasoph:
        #se pone jugada en (2,2)
        addi $t1, $zero, 2
        mul $t1, $t1, tamano
            add $t1, $t1, 2
            mul $t1, $t1, tamanodato
            addi $t2,$zero, 1
            sw $t2, contenido($t1)
            syscall
            
            #se imprime resultado
            li $v0, 4
        la $a0,resultado
            syscall		
        jal imprimir

        #se pide otra jugada
        li $v0, 4
        la $a0,pedir
        syscall
        jal pedirval
        
            #si guega en la fila 1
            beq $t3, 1, fils1soph
        #si no juega en la fila 1
        bne $t3, 1, jugadasoph3 

    fils1soph:
        #si juega en la columna 1
        #(1,1)
        beq $t2, 1, cols1soph
        #si juega en (1,x) que no sea (1,1)
        bne $t2, 1, jugadasoph3       

    jugadasoph3:           
            #si no juega en la (1,1)
            #el programa juega en la (1,1) y gana
            addi $t1, $zero, 1
        mul $t1, $t1, tamano
            add $t1, $t1, 1
            mul $t1, $t1, tamanodato
            addi $t2,$zero, 1
            sw $t2, contenido($t1)
            syscall 

        li $v0, 4
        la $a0,resultado
            syscall
        jal imprimir
        
        li $v0, 4
        la $a0, gano 
        syscall
        
        addi $sp, $sp, 8
        li $v0, 10
        syscall		 
#---------------------------------------------------------------------------------------------------------------------------------------						 						 						                  
        cols1soph:        
            #juega en la parte (1,3) porque la (1,1) esta ocupada
            addi $t1, $zero, 1
        mul $t1, $t1, tamano
            add $t1, $t1, 3
            mul $t1, $t1, tamanodato
            addi $t2,$zero, 1
            sw $t2, contenido($t1)
            syscall  
            
            #imprime resultado
        li $v0, 4
        la $a0,resultado
            syscall
        jal imprimir

        #dice que gano 
        li $v0, 4
        la $a0, gano 
        syscall
        
        #se termina		
        addi $sp, $sp, 8
        li $v0, 10
        syscall 		     
#--------------------------------------------------------------------------------------------------------------------------------------	     	     
#jugada dos del prog mio, aqui se gana de una porque no jugo en (3,2)        
jugadasoph2:
            
            addi $t1, $zero, 3
        mul $t1, $t1, tamano
            add $t1, $t1, 2
            mul $t1, $t1, tamanodato
            #se guarda el contenido de t2 1 y este se pone en la coordenada de la matriz
            addi $t2,$zero, 1
            sw $t2, contenido($t1)
            syscall  
        
        #se imprime elresultado final y dice que gano
        li $v0, 4
        la $a0,resultado
            syscall
        jal imprimir
        
        # y dice que gano  
        li $v0, 4
        la $a0, gano 
        syscall
        
        #se acaba el programa 		
        addi $sp, $sp, 8
        li $v0, 10
        syscall																													
				
#----funcion sophs-----------------------------------------------------------------------------------------------------------------------
#----funcion sophs2----------------------------------------------------------------------------------------------------------------------
sophs2:
#el programa juega en la coordenada (1,1)
    addi $t1, $zero, 1
    mul $t1, $t1, tamano
        add $t1, $t1, 1
        mul $t1, $t1, tamanodato
    
        #se guarda un 1 en la coordenada (1,1)
        addi $t2,$zero,1
        sw $t2, contenido($t1)
        syscall					

    li $v0, 4
    la $a0,resultado
    syscall		
    jal imprimir

    li $v0, 4
    la $a0,pedir
    syscall
    jal pedirval
    
    #(2,1) es la unica posible jugada en la fila 2 asi que con solo saber que puso col 1 ya se hace el siguinete movimiento
    beq $t2, 1, jugadasoph.2
    #si no es igual a 1, ya se sabe que en la siguiente jugada se gana
    bne $t2, 1, jugadasoph2.2

#---------------------------------------------------------------------------------------------------------------------------------------	 
#jugada dos del prog mio, aqui se gana de una porque no jugo en (2,1)        
jugadasoph2.2:
            
            addi $t1, $zero, 2
        mul $t1, $t1, tamano
            add $t1, $t1, 1
            mul $t1, $t1, tamanodato
            #se guarda el contenido de t2 1 y este se pone en la coordenada de la matriz
            addi $t2,$zero, 1
            sw $t2, contenido($t1)
            syscall  
        
        #se imprime elresultado final y dice que gano
        li $v0, 4
        la $a0,resultado
            syscall
        jal imprimir
        
        # y dice que gano  
        li $v0, 4
        la $a0, gano 
        syscall
        
        #se acaba el programa 		
        addi $sp, $sp, 8
        li $v0, 10
        syscall	
#---------------------------------------------------------------------------------------------------------------------------------------						 						 						
    jugadasoph.2:
        #se pone jugada en (2,2)
        addi $t1, $zero, 2
        mul $t1, $t1, tamano
            add $t1, $t1, 2
            mul $t1, $t1, tamanodato
            addi $t2,$zero, 1
            sw $t2, contenido($t1)
            syscall
            
            #se imprime resultado
            li $v0, 4
        la $a0,resultado
            syscall		
        jal imprimir
    
        #se pide otra jugada
        li $v0, 4
        la $a0,pedir
        syscall
        jal pedirval
        
            #si guega en la columna 3
            beq $t2, 3, fils1soph.2
        #si no juega en la columna 3
        bne $t2, 3, jugadasoph3.2
#---------------------------------------------------------------------------------------------------------------------------------------						 						 						

    fils1soph.2:
        #si juega en la fila 1
        #(1,3)
        beq $t3, 1, cols1soph.2
        #si juega en (1,x) que no sea (1,3)
        bne $t3, 1, jugadasoph3.2       
#---------------------------------------------------------------------------------------------------------------------------------------						 						 						
    jugadasoph3.2:           
            #si no juega en la (1,3)
            #el programa juega en la (1,3) y gana
            addi $t1, $zero, 1
        mul $t1, $t1, tamano
            add $t1, $t1, 3
            mul $t1, $t1, tamanodato
            addi $t2,$zero, 1
            sw $t2, contenido($t1)
            syscall 
            
        li $v0, 4
        la $a0,resultado
            syscall
        jal imprimir
        
        li $v0, 4
        la $a0, gano 
        syscall
        
        addi $sp, $sp, 8
        li $v0, 10
        syscall		 

#---------------------------------------------------------------------------------------------------------------------------------------						 						 						
        cols1soph.2:        
            #juega en la parte (3,3) porque la (1,3) esta ocupada
            addi $t1, $zero, 3
        mul $t1, $t1, tamano
            add $t1, $t1, 3
            mul $t1, $t1, tamanodato
            addi $t2,$zero, 1
            sw $t2, contenido($t1)
            syscall  
            
            #imprime resultado
        li $v0, 4
        la $a0,resultado
            syscall
        jal imprimir
    
        #dice que gano 
        li $v0, 4
        la $a0, gano 
        syscall
        
        #se termina		
        addi $sp, $sp, 8
        li $v0, 10
        syscall 	
#----funcion sophs2-------------------------------------------------------------------------------------------------------------------------

#----funcion lau1 --------------------------------------------------------------------------------------------------------------------------
lau1:
#se pone jugada en (3,3)
        addi $t1, $zero, 3
        mul $t1, $t1, tamano
            add $t1, $t1, 3
            mul $t1, $t1, tamanodato
            addi $t2,$zero, 1
            sw $t2, contenido($t1)
            syscall
                
# Imprime el resultado			 					
        li $v0, 4
        la $a0,resultado
            syscall
        jal imprimir	
        
    # Pide otra jugada
        li $v0, 4
        la $a0,pedir
        syscall
        jal pedirval		 					 					
                                                                            
    #si juega en la fila 3 ->  sigue jugando
            beq $t3, 3, jugada2
    #si no juega en la fila 3 -> gana el compu
        bne $t3, 3, jugada1		 					 					 					 					 					

    jugada1:
        #se pone jugada en (3,2)
            addi $t1, $zero, 3
            mul $t1, $t1, tamano
                add $t1, $t1, 2
                mul $t1, $t1, tamanodato
                addi $t2,$zero, 1
                sw $t2, contenido($t1)
                syscall
                
                # Imprime el resultado			 					
            li $v0, 4
            la $a0,resultado
                syscall
            jal imprimir
                
                #dice que gano 
            li $v0, 4
            la $a0, gano 
            syscall
        
            #se termina		
            addi $sp, $sp, 8
            li $v0, 10
            syscall     
		
		jugada2:
			#se pone jugada en (1,3)
            addi $t1, $zero, 1
            mul $t1, $t1, tamano
                add $t1, $t1, 3
                mul $t1, $t1, tamanodato
                addi $t2,$zero, 1
                sw $t2, contenido($t1)
                syscall
			
			# Imprime el resultado			 					
            li $v0, 4
            la $a0,resultado
                syscall
            jal imprimir
            
            #se pide otra jugada
            li $v0, 4
            la $a0,pedir
            syscall
            jal pedirval
		
			#Si juega en la col 2 -> gana con la col3
			beq $t2, 2, jugada2.2
			#Si no juega en la col 2 -> Gana con la diagonal
			bne $t2, 2, jugada2.1

			jugada2.1:
				#se pone jugada en (2,2)
                    addi $t1, $zero, 2
                    mul $t1, $t1, tamano
                    add $t1, $t1, 2
                    mul $t1, $t1, tamanodato
                    addi $t2,$zero, 1
                    sw $t2, contenido($t1)
                    syscall
                
                # Imprime el resultado			 					
                    li $v0, 4
                    la $a0,resultado
                    syscall
                    jal imprimir
                
                #dice que gano 
                    li $v0, 4
                    la $a0, gano 
                    syscall

                #se termina		
                    addi $sp, $sp, 8
                    li $v0, 10
                    syscall 
			
			jugada2.2:
				#se pone jugada en (2,3)
                    addi $t1, $zero, 2
                    mul $t1, $t1, tamano
                    add $t1, $t1, 3
                    mul $t1, $t1, tamanodato
                    addi $t2,$zero, 1
                    sw $t2, contenido($t1)
                    syscall

                # Imprime el resultado			 					
                    li $v0, 4
                    la $a0,resultado
                        syscall
                    jal imprimir
                    
                        #dice que gano 
                    li $v0, 4
                    la $a0, gano 
                    syscall

                #se termina		
                    addi $sp, $sp, 8
                    li $v0, 10
                    syscall 

#----funcion lau2 --------------------------------------------------------------------------------------------------------------------------
	lau2:
	#se pone jugada en (3,3)
        addi $t1, $zero, 3
        mul $t1, $t1, tamano
        add $t1, $t1, 3
        mul $t1, $t1, tamanodato
        addi $t2,$zero, 1
        sw $t2, contenido($t1)
        syscall

    # Imprime el resultado			 					
        li $v0, 4
        la $a0,resultado
            syscall
        jal imprimir	

    # Pide otra jugada
        li $v0, 4
        la $a0,pedir
        syscall
        jal pedirval		 					 					

    #si juega en la fila 3 ->  sigue jugando
            beq $t3, 3, jugada3
    #si no juega en la fila 3 -> gana el compu
        bne $t3, 3, jugada1   
            
		jugada3:
			#se pone jugada en (1,1)
                addi $t1, $zero, 1
                mul $t1, $t1, tamano
                add $t1, $t1, 1
                mul $t1, $t1, tamanodato
                addi $t2,$zero, 1
                sw $t2, contenido($t1)
                syscall

			# Imprime el resultado			 					
                li $v0, 4
                la $a0,resultado
                    syscall
                jal imprimir
                
            #se pide otra jugada
                li $v0, 4
                la $a0,pedir
                syscall
                jal pedirval
		
			#Si juega en la columna 1 -> gana el compu con diagonal
			beq $t2, 1, jugada3.1
			#Si no juega en la columna 1 -> Gana el compu con columna
			bne $t2, 1, jugada3.2
			
			jugada3.1:
				#se pone jugada en (2,2)
                    addi $t1, $zero, 2
                    mul $t1, $t1, tamano
                    add $t1, $t1, 2
                    mul $t1, $t1, tamanodato
                    addi $t2,$zero, 1
                    sw $t2, contenido($t1)
                    syscall

				# Imprime el resultado			 					
                    li $v0, 4
                    la $a0,resultado
                    syscall
                    jal imprimir
                    
                    #dice que gano 
                    li $v0, 4
                    la $a0, gano 
                    syscall

                #se termina		
                    addi $sp, $sp, 8
                    li $v0, 10
                    syscall 
			
			
			jugada3.2:
				#se pone jugada en (2,1)
                    addi $t1, $zero, 2
                    mul $t1, $t1, tamano
                    add $t1, $t1, 1
                    mul $t1, $t1, tamanodato
                    addi $t2,$zero, 1
                    sw $t2, contenido($t1)
                    syscall

				# Imprime el resultado			 					
                    li $v0, 4
                    la $a0,resultado
                    syscall
                    jal imprimir
                    
                #dice que gano 
                    li $v0, 4
                    la $a0, gano 
                    syscall

            #se termina		
                addi $sp, $sp, 8
                li $v0, 10
                syscall 

#----funcion lau3 --------------------------------------------------------------------------------------------------------------------------
	lau3:
	#se pone jugada en (1,1)
        addi $t1, $zero, 1
        mul $t1, $t1, tamano
        add $t1, $t1, 1
        mul $t1, $t1, tamanodato
        addi $t2,$zero, 1
        sw $t2, contenido($t1)
        syscall

    # Imprime el resultado			 					
        li $v0, 4
        la $a0,resultado
        syscall
        jal imprimir	

    # Pide otra jugada
        li $v0, 4
        la $a0,pedir
        syscall
        jal pedirval		 					 					

    #si juega en la columna 1 ->  sigue jugando
        beq $t2, 1, jugada4
    #si no juega en la columna 1 -> gana el compu
        bne $t2, 1, jugada5  	     			

        jugada4: 
            #se pone jugada en (1,3)
                addi $t1, $zero, 1
                mul $t1, $t1, tamano
                add $t1, $t1, 3
                mul $t1, $t1, tamanodato
                addi $t2,$zero, 1
                sw $t2, contenido($t1)
                syscall

            # Imprime el resultado			 					
                li $v0, 4
                la $a0,resultado
                syscall
                jal imprimir	

            # Pide otra jugada
                li $v0, 4
                la $a0,pedir
                syscall
                jal pedirval	

            #si juega en la fila 1 ->  gana el compu con diagonal
                beq $t3, 1, jugada4.1
            #si no juega en la fila 1 -> gana el compu la fila 1
                bne $t3, 1, jugada4.2

            jugada4.1:
                #se pone jugada en (2,2)
                    addi $t1, $zero, 2
                    mul $t1, $t1, tamano
                    add $t1, $t1, 2
                    mul $t1, $t1, tamanodato
                    addi $t2,$zero, 1
                    sw $t2, contenido($t1)
                    syscall

                # Imprime el resultado			 					
                    li $v0, 4
                    la $a0,resultado
                    syscall
                    jal imprimir

                #dice que gano 
                    li $v0, 4
                    la $a0, gano 
                    syscall

                #se termina		
                    addi $sp, $sp, 8
                    li $v0, 10
                    syscall 

            jugada4.2:
                #se pone jugada en (1,2)
                    addi $t1, $zero, 1
                    mul $t1, $t1, tamano
                    add $t1, $t1, 2
                    mul $t1, $t1, tamanodato
                    addi $t2,$zero, 1
                    sw $t2, contenido($t1)
                    syscall

                # Imprime el resultado			 					
                    li $v0, 4
                    la $a0,resultado
                    syscall
                    jal imprimir

                #dice que gano 
                    li $v0, 4
                    la $a0, gano 
                    syscall

                #se termina		
                    addi $sp, $sp, 8
                    li $v0, 10
                    syscall 

		jugada5:
			#se pone jugada en (2,1)
                addi $t1, $zero, 2
                mul $t1, $t1, tamano
                add $t1, $t1, 1
                mul $t1, $t1, tamanodato
                addi $t2,$zero, 1
                sw $t2, contenido($t1)
                syscall

			# Imprime el resultado			 					
                li $v0, 4
                la $a0,resultado
                syscall
                jal imprimir

            #dice que gano 
                li $v0, 4
                la $a0, gano 
                syscall

            #se termina		
                addi $sp, $sp, 8
                li $v0, 10
                syscall 	     

