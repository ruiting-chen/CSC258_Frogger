#####################################################################
#
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Ruiting Chen, 1006683000
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

# Demo for painting

.data
displayAddress: .word 0x10008000
waterColor: .word 0x002424a3
roadColor: .word 0x00575757
logColor: .word 0x00824d19
carColor: .word 0x00ad1c0c
startColor: .word 0x00408a29
safeColor: .word 0x00baa625
goalColor: .word 0x00408a29
frogLightColor: .word 0x00b800a8
frogDarkColor: .word 0x00570251
frogPosition: .space 8
logRow1Actual: .space 144
logRow2Actual: .space 144
logRow3Actual: .space 144
logRow1Simple: .space 56
logRow2Simple: .space 56
logRow3Simple: .space 56
carRow1Actual: .space 144
carRow2Actual: .space 144
carRow3Actual: .space 144
carRow1Simple: .space 56
carRow2Simple: .space 56
carRow3Simple: .space 56
carLogRowTotalPixel: .word 96
# frogLocation: .word 0xff0000
.text
j Main
drawRec:
# Draw a full width rectangle on screen with a given color, starting location, and end location
# $a0 stores start location, $a1 stores end location, $a2 stores color
lw $t0, displayAddress		# $t0 stores the base address for display
add $a1, $t0, $a1 		# calculate the end location in memory
add $t0, $t0, $a0 		# initialize $t0 to the start location
drawRecLoop:
beq $t0, $a1, drawRecReturn
sw $a2, 0($t0) 			# paint the unit with $a2 color at the location in $t0
addi $t0, $t0, 4 		# move to the next location to paint
j drawRecLoop
drawRecReturn:
jr $ra


setFrog:
# stores position of frog (position = pixel in the middle of frog) in frog array
# $a0 stores x position of frog, $a1 stores y position of frog
# $a2 stores memory address of frog array
sw $a0, 0($a2)
sw $a1, 4($a2)
jr $ra


updateFrog:
# $a0 stores the memory address of the frog array
# $a1 stores which way to move the frog (UP/DOWN = 0, LEFT/RIGHT = 1)
# $a2 stores move frog by how mush (pixel * 4) 
beq $a2, $zero, updateFrogReturn	# no change to position
add $t0, $zero, $zero			# $t0 = 0
addi $t1, $zero, 1			# $t1 = 1
beq $a1, $t1, updateFrogLR
# update y position
lw $t5, 4($a0)				# load original y position into $t5
add $t5, $t5, $a2			# calculate new y position
bgtz $a2, updateFrogCheckYLow 		# check if y position is too low ($a2 > 0 moved dwon (check too low), $a2 < 0 moved up (check too high)
# handle new y too high (top overflow)
blez $t5, updateFrogYHighAdjust		# if new y too high, jump to high adjust
sw $t5, 4($a0)				# load original y position into $t5
j updateFrogReturn
updateFrogYHighAdjust:
addi $t5, $zero, 4			# new y position = 4
sw $t5, 4($a0)				# write y position into $a0
j updateFrogReturn
# hanlde new y too low (bottom overflow)
updateFrogCheckYLow:
addi $t6, $t5, -120			# new y position - 120
bgtz $t6, updateFrogYLowAdjust		# if new y too low, jump to adjust
sw $t5, 4($a0)				# write y position into $a0
j updateFrogReturn
updateFrogYLowAdjust:
addi $t5, $zero, 120			# new y position = 120
sw $t5, 4($a0)				# write y position into $a0
j updateFrogReturn
# update x position
updateFrogLR:
lw $t5, 0($a0)				# load original x position into $t5
add $t5, $t5, $a2			# calculate new x position
bgtz $a2, updateFrogCheckXRight		# check if x position is too right ($a2 > 0 moved right (check too right), $a2 < 0 moved left (check too left)
# handle new x too left (left overflow)
blez $t5, updateFrogXLeftAdjust		# if new x too left, jump to left adjust
sw $t5, 0($a0)				# write x position into $a0
j updateFrogReturn
updateFrogXLeftAdjust:
addi $t5, $zero, 4			# new x position = 4
sw $t5, 0($a0)				# write x position into $a0
j updateFrogReturn
# hanlde new x too right (right overflow)
updateFrogCheckXRight:
addi $t6, $t5, -120			# new x position - 120
bgtz $t6, updateFrogXRightAdjust	# if new x too right, jump to adjust
sw $t5, 0($a0)				# write x position into $a0
j updateFrogReturn
updateFrogXRightAdjust:
addi $t5, $zero, 120			# new x position = 120
sw $t5, 0($a0)				# write x position into $a0
j updateFrogReturn
updateFrogReturn:
jr $ra


drawFrog:
# Draw frog given memory address of frog array 
# $a0 address to frog array, $a1 stores one color of frog, $a2 stores the other color of frog
lw $t0, displayAddress		# $t0 stores the base address for display
# get x, y position of frog from frog array
lw $t8, 0($a0)			# $t8 stores x position	
lw $t9, 4($a0)			# $t9 stores y position	
add $t7, $zero, $zero		# $t7 is (height) loop counter
add $t1, $t8, $zero		# $t1 is the result location
# calculate actual frog location
drawFrogCalculate:
beq $t7, $t9, drawFrogStart
addi $t1, $t1, 128
addi $t7, $t7, 4
j drawFrogCalculate
# draw middle row of frog
drawFrogStart:
add $t0, $t0, $t1
sw $a1, 0($t0) 
addi $t0, $t0, 4 
sw $a1, 0($t0)
addi $t0, $t0, -8
sw $a1, 0($t0)
# drawing upper row of frog
addi $t0, $t0, -128
sw $a2, 0($t0) 
addi $t0, $t0, 8
sw $a2, 0($t0) 
# drawing bottom row of frog
addi $t0, $t0, 256
sw $a1, 0($t0) 
addi $t0, $t0, -4
sw $a2, 0($t0) 
addi $t0, $t0, -4
sw $a1, 0($t0) 
# set $t0 back to location 0
# lw $t0, displayAddress
jr $ra


setLogCar2:
# Set the Log or Car row array
# $a0 stores address of Row, $a1 width of car/log, 
# $a2 stores start pixel of car/log 1, $a3 stores start pixel of car/log 2
add $t4, $zero, $zero # $t4 stores curr horizontal count
add $t5, $zero, $zero # $t5 stores curr vertical count
addi $t6, $zero, 3 # $t6 stores height of car/log 
addi $t7, $zero, 6 # $t7 stores height of 2 cars/logs (total iteration of setlgLoop1)
# setlgLoop2 starts:
setlgLoop2:
beq $t4, $a1, setlgLoop1 # if (horizontal count == width), jump to setlgLoop1
sw $a2, 0($a0) # store current pixel of car/log into array
addi $a2, $a2, 4 # curr pixel of car move horizontally by 1 unit
addi $a0, $a0, 4 # array location move down 4 byte
addi $t4, $t4, 4 # horizontal count + 4 byte
j setlgLoop2
# setlgLoop1 starts:
setlgLoop1:
addi $t5, $t5, 1 # curr vertical count
beq $t5, $t7, setlgReturn
beq $t5, $t6, setlgLoop1If
# move curr pixel to next row
addi $a2, $a2, 128
sub $a2, $a2, $a1
j setlgLoop1Cont
# If finished car/log 1:
setlgLoop1If:
add $a2, $a3, $zero # change curr pixel to start of car/log 2
setlgLoop1Cont:
# reset horizontal count
add $t4, $zero, $zero
j setlgLoop2
# setLogCar returns
setlgReturn:
jr $ra


##################### Set LogCar array: starting location of Lar/Car row; (width of 2 log/car) * 4; x position of first log/car; x position of second log/car #######################
setLogCar:
# $a0 stores start location of row (locations in first row: 0, 4, 8, ... , 124)
# $a1 stores start x position of car/log 1, $a2 stores start x position for car/log 2
# $a3 stores memory address of a row/car array
# $sp stores width * 4 of each car/log (if width = 6, $sp stores 24)
# store begining locatin of the in bitmap of a single car/log row
sw $a0, 0($a3)			
addi $a3, $a3, 4		# $a3 is at the spot to store width * 4 of 2 car/log
# load width * 4 of each car/log from stack into $t1
lw $t1, 0($sp)			
addi $sp, $sp, 4
add $t2, $t1, $t1
sw $t2, 0($a3)			# stores total width * 4 of 2 car/log in $a3
addi $a3, $a3, 4		# $a3 is at the begining spot for accepting x positions of car/log 1
# stores x positions of first car/log
add $t4, $zero, $zero 		# initialize index counter
setlg2Loop1:
beq $t4, $t1, setlg2Loop1End
sw $a1, 0($a3)
addi $a1, $a1, 4
addi $t4, $t4, 4
addi $a3, $a3, 4
j setlg2Loop1
# stores x positions of second car/log
setlg2Loop1End:
add $t4, $zero, $zero 
add $a1, $a2, $zero
setlg2Loop2:
beq $t4, $t1, setlg2Return
sw $a1, 0($a3)
addi $a1, $a1, 4
addi $t4, $t4, 4
addi $a3, $a3, 4
j setlg2Loop2
setlg2Return:
jr $ra


#################### Update LogCar array: starting location of Lar/Car row; (width of 2 log/car) * 4; x position of first log/car; x position of second log/car ######################
updateLogCar:
# $a0 stores the memory address of a log/car row, $a1 stores move left(0) or right(1)
addi $t7, $zero, 1 			# $t7 is used to test whether move left or right
addi $a0, $a0, 4			# move $a0 to total width of 2 log/car (also the length of the rest of x position data) * 4 
lw $t1, 0($a0) 				# $t1 stores the max iteration to go to (iteraation increment by 4)
add $t2, $zero, $zero 			# $t2 is iteration counter
addi $a0, $a0, 4			# move $a0 to the first x position
beq $a1, $t7, updatelcRightLoop
updatelcLeftLoop:
beq $t2, $t1, updatelcReturn
lw $t6, 0($a0)
addi $t6, $t6, -4 			# move the x position left by 1 pixel
bgtz $t6, updatelcLeftStore		# if calculated position > 0 jump to store the position
beq $t6, $zero, updatelcLeftStore	# if calculated position = 0 jump to store the position
addi $t6, $t6, 128			# make the position wrap the the right side
updatelcLeftStore:
sw $t6, 0($a0)				# store the updated x position
addi $a0, $a0, 4			# increment index in row array
addi $t2, $t2, 4			# increment iteration counter
j updatelcLeftLoop
updatelcRightLoop:
beq $t2, $t1, updatelcReturn
lw $t6, 0($a0)
addi $t6, $t6, 4 			# move the x position right by 1 pixel
addi $t5, $t6, -128			# shift position up by 1 row (handle wrapping)
bgtz $t5, updatelcRightStore		# if shifted position > 0 jump to store the position
beq $t5, $zero, updatelcRightStore	# if shifted position = 0 jump to store the position
add $t5, $t6, $zero			# make the $t5 = the original calculated position
updatelcRightStore:
sw $t5, 0($a0)				# store the updated x position
addi $a0, $a0, 4			# increment index in row array
addi $t2, $t2, 4			# increment iteration counter
j updatelcRightLoop
updatelcReturn:
jr $ra


##################### Draw LogCar array: starting location of Lar/Car row; (width of 2 log/car) * 4; x position of first log/car; x position of second log/car #######################
############ Draw by comparing first bitmap memory location of the row with calculated bitmap memory location of first x postion of first car/log, second with second ...#############
################################################################################### !!! FLAWED !!! ###################################################################################
drawLogCar:
# takes in memory address from one of the log/car simplyfied array and converts into an 
# actual array of locations 
# $a0 stores memory address of a log/car row, $a1 stores base bitmap address
# $a2 stores color of road/water, $a3 stores color of log/car
lw $t0, 0($a0)			# load start location offset into $t0
add $t0, $t0, $a1		# $t0 stores index in bitmap
addi $t8, $t0, 384 		# $t9 stores the max index in bitmap to loop to
add $t1, $zero, $zero 		# $t1 is the width loop iteratin counter
add $t2, $zero, $zero 		# $t3 is the height loop iteratin counter
addi $t9, $a0, 4 		# $t9 stores log/car simplyfied index in array
lw $t3, 0($t9) 			# $t3 stores total width * 4 of a 2 car/log
add $t4, $zero, 3		# $t4 stores the height * 4 of car/log
add $t5, $zero, $zero 		# $t5 stores the current height increase
lw $t7, 0($a0) 			# load start location offset into $t7
addi $t9,$t9, 4 		# $t9 is moved to the first x positions
lcDraw:
beq $t0, $t8, lcDrawReturn
lcConvertLoop1:
beq $t2, $t4,lcNoObj
lcConvertLoop2:
beq $t1, $t3, lcConvertWidthReset
lw $t6, 0($t9) 			# load x position into $t6 (width adjustment)
add $t6, $t6, $t7 		# add the width adjustment to offset
add $t6, $t6, $t5 		# add the height adjustment to offset
add $t6, $t6, $a1 		# add the calculated position to base bitmap position
bne $t6, $t0, lcNoObj		# if current index in bitmap != calculated car/log location (current pixel is not a car/log), jump to draw water/road
sw $a3, 0($t0)			# store log/car color at this location
addi $t0, $t0, 4 		# increment index in bitmap
addi $t1, $t1, 4 		# increment width count
addi $t9, $t9, 4 		# increment x position index $t9
j lcDraw
lcConvertWidthReset:
add $t1, $zero, $zero		# reset witdh counter
sub $t9, $t9, $t3		# reset x positions (array index)
addi $t2, $t2, 1		# increment height count
addi $t5, $t5, 128		# increment height increase number
j lcDraw
lcNoObj:
sw $a2, 0($t0)			# store road/water color at this location
addi $t0, $t0, 4 		# increment index in bitmap
j lcDraw
lcDrawReturn:
jr $ra


################# Redraw LogCar array Right: starting location of Lar/Car row; (width of 2 log/car) * 4; x position of first log/car; x position of second log/car ###################
###################### Redraw by painting right most column of new car/log and repainting left most column of old car/log back to road/water for both cars/logs ######################
redrawLogCarRight:
# $a0 stores the memory address of the aray that stores a row of log.car
# $a2 stores color of water/road, $a3 stores color of log/car
lw $t0, displayAddress
lw $t9, 0($a0)			# load start address of row into $t9
add $t9, $t9, $t0		# $t9 stores the start memeory location for first row
add $t8, $t9, 128		# $t9 stores the start memeory location for second row
add $t7, $t8, 128		# $t9 stores the start memeory location for third row
addi $a0, $a0, 4
lw $t1, 0($a0) 			# $t1 stores the total width of 2 ractngles
srl $t1, $t1, 1			# $t1 = $t1/2 (width of 1 car/log)
# redraw water/road
addi $a0, $a0, 4		# move $a0 to the first x position of fist log/car
lw $t3, 0($a0)			# load first x position first log/car into $t3
add $a0, $a0, $t1		# move $a0 to the first x position of second log/car
lw $t6, 0($a0)			# load first x position of second log/car into $t6
addi $t3, $t3, -4		# calculate the x position to the left the first x position of fist log/car
addi $t6, $t6, -4		# calculate the x position to the left the first x position of fist log/car
# draw water/road for first log/car
bgtz $t3, drawWaterRoad1 
beq $t3, $zero, drawWaterRoad1
addi $t3, $t3, 128 		# wrap around
drawWaterRoad1:
add $t4, $t9, $t3		# $t4 stores the memeory location of water/road pixel to draw
sw $a2, 0($t4)
add $t4, $t8, $t3
sw $a2, 0($t4)
add $t4, $t7, $t3
sw $a2, 0($t4)
# draw water/road for second log/car
bgtz $t6, drawWaterRoad2 
beq $t6, $zero, drawWaterRoad2
addi $t6, $t6, 128 		# wrap around
drawWaterRoad2:
add $t4, $t9, $t6		# $t4 stores the memeory location of water/road pixel to draw
sw $a2, 0($t4)
add $t4, $t8, $t6
sw $a2, 0($t4)
add $t4, $t7, $t6
sw $a2, 0($t4)
# redraw log/car
addi $a0, $a0, -4		# move $a0 to the last x position of fist log/car
lw $t3, 0($a0)			# load last x position first log/car into $t3
add $a0, $a0, $t1		# move $a0 to the last x position of second log/car
lw $t6, 0($a0)			# load last x position of second log/car into $t6
# draw water/road for first log/car
add $t4, $t9, $t3		# $t4 stores the memeory location of water/road pixel to draw
sw $a3, 0($t4)
add $t4, $t8, $t3
sw $a3, 0($t4)
add $t4, $t7, $t3
sw $a3, 0($t4)
# draw water/road for second log/car
add $t4, $t9, $t6		# $t4 stores the memeory location of water/road pixel to draw
sw $a3, 0($t4)
add $t4, $t8, $t6
sw $a3, 0($t4)
add $t4, $t7, $t6
sw $a3, 0($t4)
jr $ra


################## Redraw LogCar array Left: starting location of Lar/Car row; (width of 2 log/car) * 4; x position of first log/car; x position of second log/car ###################
###################### Redraw by painting left most column of new car/log and repainting right most column of old car/log back to road/water for both cars/logs ######################
redrawLogCarLeft:
# $a0 stores the memory address of the aray that stores a row of log.car
# $a2 stores color of water/road, $a3 stores color of log/car
lw $t0, displayAddress
lw $t9, 0($a0)			# load start address of row into $t9
add $t9, $t9, $t0		# $t9 stores the start memeory location for first row
add $t8, $t9, 128		# $t9 stores the start memeory location for second row
add $t7, $t8, 128		# $t9 stores the start memeory location for third row
addi $a0, $a0, 4
lw $t1, 0($a0) 			# $t1 stores the total width of 2 ractngles
srl $t1, $t1, 1			# $t1 = $t1/2 (width of 1 car/log)
# redraw log/car
addi $a0, $a0, 4		# move $a0 to the first x position of fist log/car
lw $t3, 0($a0)			# load first x position first log/car into $t3
add $a0, $a0, $t1		# move $a0 to the first x position of second log/car
lw $t6, 0($a0)			# load first x position of second log/car into $t6
# draw log/car for first log/car
add $t4, $t9, $t3		# $t4 stores the memeory location of water/road pixel to draw
sw $a3, 0($t4)
add $t4, $t8, $t3
sw $a3, 0($t4)
add $t4, $t7, $t3
sw $a3, 0($t4)
# draw log/car for second log/car
add $t4, $t9, $t6		# $t4 stores the memeory location of water/road pixel to draw
sw $a3, 0($t4)
add $t4, $t8, $t6
sw $a3, 0($t4)
add $t4, $t7, $t6
sw $a3, 0($t4)
# redraw water/road
addi $a0, $a0, -4		# move $a0 to the last x position of fist log/car
lw $t3, 0($a0)			# load last x position first log/car into $t3
add $a0, $a0, $t1		# move $a0 to the last x position of second log/car
lw $t6, 0($a0)			# load last x position of second log/car into $t6
addi $t3, $t3, 4		# calculate the x position to the right the first x position of fist log/car
addi $t6, $t6, 4		# calculate the x position to the rigth the first x position of fist log/car
# draw water/road for first log/car
addi $t5, $t3, -128		# wrap around handle
bgtz $t5, drawWaterRoadL1 
beq $t5, $zero, drawWaterRoadL1
add $t5, $t3, $zero 		
drawWaterRoadL1:
add $t4, $t9, $t5		# $t4 stores the memeory location of water/road pixel to draw
sw $a2, 0($t4)
add $t4, $t8, $t5
sw $a2, 0($t4)
add $t4, $t7, $t5
sw $a2, 0($t4)
# draw water/road for second log/car
addi $t5, $t6, -128		# wrap around handle
bgtz $t5, drawWaterRoadL2 
beq $t5, $zero, drawWaterRoadL2
add $t5, $t6, $zero 		
drawWaterRoadL2:
add $t4, $t9, $t5		# $t4 stores the memeory location of water/road pixel to draw
sw $a2, 0($t4)
add $t4, $t8, $t5
sw $a2, 0($t4)
add $t4, $t7, $t5
sw $a2, 0($t4)
jr $ra


Main:
# lw $t0, displayAddress # $t0 stores the base address for display
# li $t1, 0xff0000 # $t1 stores the red colour code
# li $t2, 0x00ff00 # $t2 stores the green colour code
# li $t3, 0x0000ff # $t3 stores the blue colour code
# sw $t1, 0($t0) # paint the first (top-left) unit red.
# sw $t2, 4($t0) # paint the second unit on the first row green. Why $t0+4?
# sw $t3, 128($t0) # paint the first unit on the second row blue. Why +128?

# LOG, CAR, FROG POSITION SET UP
# SET LOGROW1
addi $a0, $zero, 1024 		# store start location of logRow1 in $a0
addi $a1, $zero, 0 		# store start pixel of car/log 1 in $a1
addi $a2, $zero, 64 		# store start pixel of car/log 2 in $a2
la $a3, logRow1Simple 		# load memory address of logRow1
# store width (num pixel * 4) of log.car in $sp
addi $t3, $zero, 24
addi $sp, $sp, -4
sw, $t3, 0($sp)
jal setLogCar

# SET LOGROW2
addi $a0, $zero, 1408 		# store start location of logRow1 in $a0
addi $a1, $zero, 24 		# store start pixel of car/log 1 in $a1
addi $a2, $zero, 88 		# store start pixel of car/log 2 in $a2
la $a3, logRow2Simple 		# load memory address of logRow1
# store width (num pixel * 4) of log.car in $sp
addi $t3, $zero, 24
addi $sp, $sp, -4
sw, $t3, 0($sp)
jal setLogCar

# SET LOGROW3
addi $a0, $zero, 1792 		# store start location of logRow1 in $a0
addi $a1, $zero, 12 		# store start pixel of car/log 1 in $a1
addi $a2, $zero, 76 		# store start pixel of car/log 2 in $a2
la $a3, logRow3Simple 		# load memory address of logRow1
# store width (num pixel * 4) of log.car in $sp
addi $t3, $zero, 24
addi $sp, $sp, -4
sw, $t3, 0($sp)
jal setLogCar

# SET CARROW1
addi $a0, $zero, 2560 		# store start location of logRow1 in $a0
addi $a1, $zero, 0 		# store start pixel of car/log 1 in $a1
addi $a2, $zero, 64 		# store start pixel of car/log 2 in $a2
la $a3, carRow1Simple 		# load memory address of logRow1
# store width (num pixel * 4) of log.car in $sp
addi $t3, $zero, 24
addi $sp, $sp, -4
sw, $t3, 0($sp)
jal setLogCar

# SET CARROW2
addi $a0, $zero, 2944 		# store start location of logRow1 in $a0
addi $a1, $zero, 24 		# store start pixel of car/log 1 in $a1
addi $a2, $zero, 88 		# store start pixel of car/log 2 in $a2
la $a3, carRow2Simple 		# load memory address of logRow1
# store width (num pixel * 4) of log.car in $sp
addi $t3, $zero, 24
addi $sp, $sp, -4
sw, $t3, 0($sp)
jal setLogCar

# SET CARROW3
addi $a0, $zero, 3328 		# store start location of logRow1 in $a0
addi $a1, $zero, 12 		# store start pixel of car/log 1 in $a1
addi $a2, $zero, 76 		# store start pixel of car/log 2 in $a2
la $a3, carRow3Simple 		# load memory address of logRow1
# store width (num pixel * 4) of log.car in $sp
addi $t3, $zero, 24
addi $sp, $sp, -4
sw, $t3, 0($sp)
jal setLogCar

# SET FROG
addi $a0, $zero, 68
addi $a1, $zero, 120
la $a2, frogPosition
jal setFrog

# DRAW GOAL REGION
add $a0, $zero, $zero 		# put start location of goal region into $a0
addi $a1, $zero, 1024 		# put end location of goal region into $a1
lw $a2, goalColor  		# load color of goal region into $a2
jal drawRec

# DRAW LOGROW1
la $a0 logRow1Simple
lw $a1 displayAddress
lw $a2 waterColor
lw $a3 logColor
jal drawLogCar

# DRAW LOGROW2
la $a0 logRow2Simple
lw $a1 displayAddress
lw $a2 waterColor
lw $a3 logColor
jal drawLogCar

# DRAW LOGROW3
la $a0 logRow3Simple
lw $a1 displayAddress
lw $a2 waterColor
lw $a3 logColor
jal drawLogCar

# DRAW SAFE REGION
addi $a0, $zero, 2176 		# put start location of safe region into $a0
addi $a1, $zero, 2560		# put end location of safe region into $a1
lw $a2, safeColor  		# load color of safe region into $a2
jal drawRec

# DRAW CARROW1
la $a0 carRow1Simple
lw $a1 displayAddress
lw $a2 roadColor
lw $a3 carColor
jal drawLogCar

# DRAW CARROW2
la $a0 carRow2Simple
lw $a1 displayAddress
lw $a2 roadColor
lw $a3 carColor
jal drawLogCar

# DRAW CARROW3
la $a0 carRow3Simple
lw $a1 displayAddress
lw $a2 roadColor
lw $a3 carColor
jal drawLogCar

# DRAW START REGION
addi $a0, $zero, 3712 		# put start location of start region into $a0
addi $a1, $zero, 4096 		# put end location of start region into $a1
lw $a2, startColor  		# load color of start region into $a2
jal drawRec

# DRAW FROG
la $a0, frogPosition
lw $a1, frogLightColor 		# load light color of frog into $a1
lw $a2, frogDarkColor 		# load dark color of frog into $a2
jal drawFrog

MainLoop:
# UPDATE LOGROW1 
la $a0, logRow1Simple
addi $a1, $zero, 1
jal updateLogCar

# UPDATE LOGROW2
la $a0, logRow2Simple
addi $a1, $zero, 0
jal updateLogCar

# UPDATE LOGROW3
la $a0, logRow3Simple
addi $a1, $zero, 1
jal updateLogCar

# UPDATE CARROW1 
la $a0, carRow1Simple
addi $a1, $zero, 0
jal updateLogCar

# UPDATE CARROW2
la $a0, carRow2Simple
addi $a1, $zero, 1
jal updateLogCar

# UPDATE CARROW3
la $a0, carRow3Simple
addi $a1, $zero, 0
jal updateLogCar

# UPDATE FROG
la $a0, frogPosition
addi $a1, $zero, 0
addi $a2, $zero, -12 
jal updateFrog

# REDRAW LOGROW1
# la $a0 logRow1Simple
# lw $a2 waterColor
# lw $a3 logColor
# jal redrawLogCarRight
la $a0 logRow1Simple
lw $a1 displayAddress
lw $a2 waterColor
lw $a3 logColor
jal drawLogCar # *******************************************************************

# REDRAW LOGROW2
la $a0 logRow2Simple
lw $a2 waterColor
lw $a3 logColor
jal redrawLogCarLeft

# REDRAW LOGROW3
la $a0 logRow3Simple
lw $a2 waterColor
lw $a3 logColor
jal redrawLogCarRight

# REDRAW CARROW1
la $a0 carRow1Simple
lw $a2 roadColor
lw $a3 carColor
jal redrawLogCarLeft

# REDRAW CARROW2
la $a0 carRow2Simple
lw $a2 roadColor
lw $a3 carColor
jal redrawLogCarRight

# REDRAW CARROW3
la $a0 carRow3Simple
lw $a2 roadColor
lw $a3 carColor
jal redrawLogCarLeft

# DRAW FROG
la $a0, frogPosition
lw $a1, frogLightColor 		# load light color of frog into $a1
lw $a2, frogDarkColor 		# load dark color of frog into $a2
jal drawFrog

li $v0, 32
li $a0, 500
syscall

j MainLoop

Exit:
li $v0, 10 # terminate the program gracefully
syscall
