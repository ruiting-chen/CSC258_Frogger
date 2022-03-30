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
# - Milestone 3 
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. add a third row of water and road - Easy Feature
# 2. add a death/respawn animation - Easy Feature
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
.data
displayAddress: .word 0x10008000
screen: .space 4096

waterColor: .word 0x002424a3
roadColor: .word 0x00575757
logColor: .word 0x00824d19
carColor: .word 0x00ad1c0c
startColor: .word 0x00408a29
safeColor: .word 0x00baa625
goalColor: .word 0x00408a29
goalBlockColor: .word 0x002a591b

frogLightColor: .word 0x00b800a8
frogDarkColor: .word 0x00570251
frogDieLightColor1: .word 0x00b0e805
frogDieDarkColor1: .word 0x0081ab02
frogDieLightColor2: .word 0x00d97109
frogDieDarkColor2: .word 0x008f4a04
frogLifeColor: .word 0x00d6384f
frogPosition: .space 8
frogDie: .word 1 		# alive = 1, die = 0
frogLifeArray: .word 1:3 	# life remaining array is an array with 3 elements, 1 = life, 0 = no life
frogLifeRemain: .word 3 	# number of life remaining, start with 3
frogPassLevel: .word 0		# Passed = 1, not passed = 0
goalReached: .word 0		# goal reached = 1, goal not reached = 0
frogGoalRemain: .word 3 	# goal position remaining = 3 at the begining

goalStart: .word 0
lifeRowStart: .word 128
goalRowStart: .word 640
safeStart: .word 2176
startStart: .word 3712
logRowStart1: .word 1024
logRowStart2: .word 1408
logRowStart3: .word 1792
carRowStart1: .word 2560
carRowStart2: .word 2944
carRowStart3: .word 3328

goalRow: .word 0:32
logRow1: .space 128
logRow2: .space 128
logRow3: .space 128
carRow1: .space 128
carRow2: .space 128
carRow3: .space 128

carLogSpeed: .word 10 		# how many main loop cycles to update car/log position once
carLogCurrLap: .space 4		# which cycles is car/log currently on

goalRowMiddle: .word 24
logRow1Middle: .word 36
logRow2Middle: .word 48
logRow3Middle: .word 60
carRow1Middle: .word 84
carRow2Middle: .word 96
carRow3Middle: .word 108

retryMessage: .asciiz "Do you want to Retry?"
.text
j Setup
storeRec:
# Store a full width rectangle to screen with a given color, starting location, and end location
# $a0 stores start location, $a1 stores end location, $a2 stores color
la $t0, screen			# $t0 stores the base address for screen
add $a1, $t0, $a1 		# calculate the end location in memory
add $t0, $t0, $a0 		# initialize $t0 to the start location
storeRecLoop:
beq $t0, $a1, storeRecReturn
sw $a2, 0($t0) 			# paint the unit with $a2 color at the location in $t0
addi $t0, $t0, 4 		# move to the next location to paint
j storeRecLoop
storeRecReturn:
jr $ra


setGoalRow:
# $a0 stores the memory address of goal row
addi $t2, $zero, 4		# $t2 stores max width of goal block 
addi $t3, $zero, 1		# $t3 stores indicator for goal region
add $t0, $zero, $zero 		# $t0 is the block index counter
# GOAL 1
setGoalBlock1:
add $t1, $a0, 20		# move $t1 to start of goal block 1
add $t0, $zero, $zero 		# reset block index counter
setGoalBlock1Loop:
beq $t0, $t2, setGoalBlock2
sw $t3, 0($t1)
addi $t1, $t1, 4
addi $t0, $t0, 1
j setGoalBlock1Loop
# GOAL 2
setGoalBlock2:
add $t1, $a0, 56		# move $t1 to start of goal block 1
add $t0, $zero, $zero 		# reset block index counter
setGoalBlock2Loop:
beq $t0, $t2, setGoalBlock3
sw $t3, 0($t1)
addi $t1, $t1, 4
addi $t0, $t0, 1
j setGoalBlock2Loop
# GOAL 3
setGoalBlock3:
add $t1, $a0, 92		# move $t1 to start of goal block 1
add $t0, $zero, $zero 		# reset block index counter
setGoalBlock3Loop:
beq $t0, $t2, setGoalRowReturn
sw $t3, 0($t1)
addi $t1, $t1, 4
addi $t0, $t0, 1
j setGoalBlock3Loop
setGoalRowReturn:
jr $ra


updateGoalRow:
# $a0 stores the memory address of goal row, $a1 stores the x position frog is in
addi $t0, $zero, 4		# $t0 stores max width of goal block 
addi $t1, $zero, 24		# frog is in region of first goal
addi $t2, $zero, 28		# frog is in region of first goal
addi $t3, $zero, 60		# frog is in region of second goal
addi $t4, $zero, 64		# frog is in region of second goal
addi $t5, $zero, 96		# frog is in region of third goal
addi $t6, $zero, 100		# frog is in region of third goal
add $t7, $zero, $zero 		# $t7 is block index counter
beq $a1, $t1, updateGoalBlock1
beq $a1, $t2, updateGoalBlock1
beq $a1, $t3, updateGoalBlock2
beq $a1, $t4, updateGoalBlock2
beq $a1, $t5, updateGoalBlock3
beq $a1, $t6, updateGoalBlock3
# UPDATE GOAL BLOCK 1
updateGoalBlock1:
addi, $a0, $a0, 20		# move index in goal row to first goal block
updateGoalBlock1Loop:
beq $t7, $t0, updateGoalRowReturn
sw $zero, 0($a0)
addi $a0, $a0, 4
addi $t7, $t7, 1
j updateGoalBlock1Loop
# UPDATE GOAL BLOCK 2
updateGoalBlock2:
addi, $a0, $a0, 56		# move index in goal row to second goal block
updateGoalBlock2Loop:
beq $t7, $t0, updateGoalRowReturn
sw $zero, 0($a0)
addi $a0, $a0, 4
addi $t7, $t7, 1
j updateGoalBlock2Loop
# UPDATE GOAL BLOCK 3
updateGoalBlock3:
addi, $a0, $a0, 92		# move index in goal row to second goal block
updateGoalBlock3Loop:
beq $t7, $t0, updateGoalRowReturn
sw $zero, 0($a0)
addi $a0, $a0, 4
addi $t7, $t7, 1
j updateGoalBlock3Loop
updateGoalRowReturn:
jr $ra


updateLife:
# $a0 stores the address to frogLifeArray, $a1 stores number of frog life remaining
add $t1, $zero, $zero 		# $t1 is index counter to life remain array
addi $t2, $zero, 3		# $t2, is max index for life remain array
addi $t3, $zero, 1		# $t3 stores indicator value for to indicate there is a life
updateLifeLoop:
beq $t1, $t2, updateLifeReturn
ble $t1, $a1, updateLifeIsLife
sw $zero, 0($a0)
addi $t1, $t1, 1		# increment index counter
addi $a0, $a0, 4		# move to next stored value in array
j updateLifeLoop
updateLifeIsLife:
sw $t3, 0($a0)
addi $t1, $t1, 1		# increment index counter
addi $a0, $a0, 4		# move to next stored value in array
j updateLifeLoop
updateLifeReturn:
jr $ra


storeLife:
# $a0 stores the address to frogLifeRemain array, $a1 stores color of frog life
la $t0, screen
lw $t4, lifeRowStart
add $t0, $t0, $t4		# move $t0 to start of life row
addi $t0, $t0, 4		# move $t0 to first life position
add $t1, $zero, $zero 		# $t1 is index counter to life remain array
addi $t2, $zero, 3		# $t2, is max index for life remain array
storeLifeLoop:
beq $t1, $t2, storeLifeReturn
lw $t3, 0($a0)			# $t3 stores indicator value from life remain array
beq $t3, $zero, storeLifeMoveToNext
sw $a1, 0($t0)
storeLifeMoveToNext:
addi $t0, $t0, 8		# move $t0 to the next life position
addi $t1, $t1, 1		# increment index counter
addi $a0, $a0, 4		# move to next stored value in array
j storeLifeLoop
storeLifeReturn:
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


storeFrog:
# Store frog to screen given memory address of frog array 
# $a0 address to frog array, $a1 stores one color of frog, $a2 stores the other color of frog
la $t0, screen			# $t0 stores the base address for screen
# get x, y position of frog from frog array
lw $t8, 0($a0)			# $t8 stores x position	
lw $t9, 4($a0)			# $t9 stores y position	
add $t7, $zero, $zero		# $t7 is (height) loop counter
add $t1, $t8, $zero		# $t1 is the result location
# calculate actual frog location
storeFrogCalculate:
beq $t7, $t9, storeFrogStart
addi $t1, $t1, 128
addi $t7, $t7, 4
j storeFrogCalculate
# store middle row of frog
storeFrogStart:
add $t0, $t0, $t1
sw $a1, 0($t0) 
addi $t0, $t0, 4 
sw $a1, 0($t0)
addi $t0, $t0, -8
sw $a1, 0($t0)
# store upper row of frog
addi $t0, $t0, -128
sw $a2, 0($t0) 
addi $t0, $t0, 8
sw $a2, 0($t0) 
# store bottom row of frog
addi $t0, $t0, 256
sw $a1, 0($t0) 
addi $t0, $t0, -4
sw $a2, 0($t0) 
addi $t0, $t0, -4
sw $a1, 0($t0) 
jr $ra


checkFrogOnLog:
# given a row that the frog is in, check if frog is on a log in that row, returns 0 if frog not on log, 1 if frog on log
# $a0 stores the address of the log row, $a1 stores x position of frog
add $a0, $a0, $a1			# move index in array to position of frog
lw $t7, 0($a0)				
bne $t7, $zero, frogOnLog		# if x position is not 0 (there is log), frog on log
addi $a0, $a0, 4			# move 1 pixel right from x position
lw $t7, 0($a0)				
bne $t7, $zero, frogOnLog		# if x position + 4 is not 0 (there is log),but x position is 0, frog on log
addi $a0, $a0, -8			# move 1 pixel left from x position
lw $t7, 0($a0)				
bne $t7, $zero, frogOnLog		# if x position - 4 is not 0 (there is log),but x position is 0, frog on log
addi $sp, $sp, -4
sw $zero, 0($sp)			# if all above positions equal 0, frog is not on log, return 0
jr $ra
frogOnLog:				# if frog is on log, return 1
addi $t7, $t7, 1
addi $sp, $sp, -4
sw $t7, 0($sp)
jr $ra


checkFrogHitCar:
# given a row that the frog is in, check if frog hits car on that row, returns 0 if frog hit car, 1 if frog not hit car
# $a0 stores the address of the car  row, $a1 stores x position of frog
add $a0, $a0, $a1			# move index in array to position of frog
lw $t7, 0($a0)				
bne $t7, $zero, frogHitCar		# if x position is not 0 (there is log), frog hit car
addi $a0, $a0, 4			# move 1 pixel right from x position
lw $t7, 0($a0)				
bne $t7, $zero, frogHitCar		# if x position + 4 is not 0 (there is log),but x position is 0, frog hit car
addi $a0, $a0, -8			# move 1 pixel left from x position
lw $t7, 0($a0)				
bne $t7, $zero, frogHitCar		# if x position - 4 is not 0 (there is log),but x position is 0, frog hit car
addi $t7, $t7, 1			# if all above positions equal 0, frog is does not hit car, return 1
addi $sp, $sp, -4
sw $t7, 0($sp)			
jr $ra
frogHitCar:				# if frog hit car, return 0
addi $sp, $sp, -4
sw $zero, 0($sp)
jr $ra


checkFrogReachGoal:
# given a row that the frog is in, check if frog reached goal, returns 0 if frog did not reach goal(dies), 1 if frog reached goal
# $a0 stores the address of the goal row, $a1 stores x position of frog
add $a0, $a0, $a1			# move index in array to position of frog
lw $t7, 0($a0)				
beq $t7, $zero, frogNotReach		# if x position is not 0 (there is log), frog not reach goal
addi $a0, $a0, 4			# move 1 pixel right from x position
lw $t7, 0($a0)				
beq $t7, $zero, frogNotReach		# if x position + 4 is not 0 (there is log),but x position is 0, frog not reach goal
addi $a0, $a0, -8			# move 1 pixel left from x position
lw $t7, 0($a0)				
beq $t7, $zero, frogNotReach		# if x position - 4 is not 0 (there is log),but x position is 0, frog not reach goal
addi $t7, $t7, 1			# if all above positions not equal 0, frog is reached goal, return 1
addi $sp, $sp, -4
sw $t7, 0($sp)			
jr $ra
frogNotReach:				# if frog hit car, return 0
addi $sp, $sp, -4
sw $zero, 0($sp)
jr $ra


setLogCar: 
# set one log/car array
# $a0 stores the address of the log/car row that is being set, $a1 stores start location of the log/car row that is being set
# $a2 stores the start location of first log/car, $a3 stores the start location of the second log/car
# $sp stores the width * 4 of log/car
add $t1, $zero, $zero		# $t1 is the index in the log/car array
add $t2, $zero, $zero		# $t2 is the width counter
addi $t3, $zero, 128		# $t3 is the max index + 4 in log/car array
lw $t4, 0($sp)			# $t4 stores max width			
addi $sp, $sp, 4
setlgLoop:
beq $t1, $t3, setLogCarReturn
beq $t2, $t4, setlgWidthReset
beq $t1, $a2, setlgStore1
add $t6, $zero, $zero
sw $t6 0($a0)			# not car/log: store 0
addi $t1, $t1, 4		# increment log/car array index
addi $a0, $a0, 4		# increment memory address for storing x position indicator
j setlgLoop
setlgStore1:
addi $t6, $zero, 1
sw $t6 0($a0)			# is car/log: store 1
addi $a2, $a2, 4		# go to next x position
addi $t2, $t2, 4		# increment width
addi $t1, $t1, 4		# increment log/car array index
addi $a0, $a0, 4		# increment memory address for storing x position indicator
j setlgLoop
setlgWidthReset:
add $t2, $zero, $zero		# $t2 is the width counter
add $t7, $t4, $a3		# last x position
beq $a2, $t7, setlgStopReset	# stop increment if reached max x position
add $a2, $a3, $zero		# go to fist x position of second log/car
j setlgLoop
setlgStopReset:
addi $a2, $zero, -4		# make $a2 go to -4 ($t1 can never equal $a2)
j setlgLoop
setLogCarReturn:
jr $ra


updateLogCar:
# update the position of a row of log/car
# $a0 stores the address of the row of log/car being updated 
# $a1 stores information of moving left or right (right = 1, left = 0)
addi $t7, $zero, 1		# $t7 is used to compare whether move left or right
beq $a1, $t7, updatelcRight	# if ($a1 == 1), jump to right branch
# move left update branch
add $t1, $zero, $zero 		# $t1 is the index counter for log/car array
lw $t0, 0($a0)			# information of first spot of log/car array
addi $t2, $zero, 124		# $t2 stores max index + 4 of log/car array
updatelcLeftLoop:
beq $t1, $t2, updatelcLeftLast
lw $t5, 4($a0)			# $t5 temporarily stores old log/car indicator information at $a0 + 4
sw $t5, 0($a0)			# store new value into $a0
add $t1, $t1, 4			# move $t1 to next spot
add $a0, $a0, 4			# move $a0 to next spot
j updatelcLeftLoop
updatelcLeftLast:
sw $t0, 0($a0)			# store new value into $a0
j updateLogCarReturn
# move right update branch
updatelcRight:
add $t1, $zero, $zero 		# $t1 is the index counter for log/car array
add $t0, $a0, $zero		# store a copy of head of log/car array in $t0
addi $t2, $zero, 128		# $t2 stores max index + 4 of log/car array
lw $t4, 0($a0)			# load information of first position in array into $t4
add $t1, $t1, 4			# move $t1 to next spot
add $a0, $a0, 4			# move $a0 to next spot
updatelcRightLoop:
beq $t1, $t2, updatelcRightLast
lw $t5, 0($a0)			# $t5 temporarily stores old log/car indicator information at $a0
sw $t4, 0($a0)			# store new value into $a0
add $t4, $t5, $zero		# change $t4 to the old log/car indicator information at $a0 (value to load at next round)
add $t1, $t1, 4			# move $t1 to next spot
add $a0, $a0, 4			# move $a0 to next spot
j updatelcRightLoop
updatelcRightLast:
sw $t4, 0($t0)			# store last value at first position
updateLogCarReturn:
jr $ra


storeLogCar:
# store a row of log/car according to given information
# $a0 stores the memory address of the row of log/car being drawn
# $a1 stores the start location offset of that row
# $a2 stores color of water/road, $a3 stores color of log/car
la $t0, screen			# $t0 stores the base address of screen
add $t0, $t0, $a1		# move $t0 to start location of row
add $t1, $zero, $zero 		# $t1 is the row (width) counter
add $t2, $zero, $zero		# $t2 is the height counter
addi $t3, $zero, 128		# $t3 is the max width of a row
addi $t4, $zero, 12		# $t4 is the max height
addi $t7, $zero, 1		# $t7 is used to check whether there is a car/log pixel at index
storelcLoop:
beq $t2, $t4, storelcReturn
beq $t1, $t3, storelcWidthReset
lw $t6, 0($a0)			# load information at $a0 into $t6
beq $t6, $t7, storelcObj	# if there is a car/log pixel at index, jump to draw log/car
sw $a2, 0($t0)
addi $t0, $t0, 4		# increment bitmap index
addi $a0, $a0, 4		# increment row array index
addi $t1, $t1, 4		# increment width counter
j storelcLoop
storelcObj:
sw $a3, 0($t0)
addi $t0, $t0, 4		# increment bitmap index
addi $a0, $a0, 4		# increment row array index
addi $t1, $t1, 4		# increment width counter
j storelcLoop
storelcWidthReset:
add $t1, $zero, $zero 		# $t1 is the row (width) counter
addi $a0, $a0, -128		# reset addtess index in row array
addi $t2, $t2, 4		# increment height counter
j storelcLoop
storelcReturn:
jr $ra


drawScreen:
# Draw the whole screen
lw $t8, displayAddress		# $t8 stores bitmap base address
la $t9, screen			# $t9 stores screen baes address
add $t1, $zero, $zero		# $t1 stores current index (index counter)
addi $t2, $zero, 4096		# $t2 stores max index
drawScreenLoop:
beq $t1, $t2, drawScreenReturn
lw $t6, 0($t9)			# load color into $t6 from screen
sw $t6, 0($t8)			# store color onto bitmap
addi $t1, $t1, 4 		# increment index counter
addi $t8, $t8, 4 		# increment bitmap position
addi $t9, $t9, 4 		# increment screen position
j drawScreenLoop
drawScreenReturn:
jr $ra

Setup:
# SET GOALROW
la $a0, goalRow
jal setGoalRow

Main:
# CHECK IF PASSED LEVEL
lw $t1, frogGoalRemain
beq $t1, $zero, Exit		# if frogGoalRemain == 0, frog have passed level

# CHECK FROG LIFE REMAIN
lw $t1, frogLifeRemain		# load frog life remain into $t1
bne $t1, $zero, initialize	# if life remaining != 0, jump to initialize (restart the game)
li $v0, 50
la $a0, retryMessage
syscall
bne $a0, $zero, Exit		# if didn't choose yes, exit the game
addi $t1, $zero, 3
sw $t1, frogLifeRemain		# change frog life remain back to 3

# LOG, CAR, FROG POSITION SET UP
initialize:
# SET LOGROW1
la $a0, logRow1
lw $a1, logRowStart1
addi $a2, $zero, 0 		# store start pixel of car/log 1 in $a1
addi $a3, $zero, 64 		# store start pixel of car/log 2 in $a2
# store width (num pixel * 4) of log.car in $sp
addi $t3, $zero, 32
addi $sp, $sp, -4
sw, $t3, 0($sp)
jal setLogCar 

# SET LOGROW2
la $a0, logRow2
lw $a1, logRowStart2
addi $a2, $zero, 24 		# store start pixel of car/log 1 in $a1
addi $a3, $zero, 88 		# store start pixel of car/log 2 in $a2
# store width (num pixel * 4) of log.car in $sp
addi $t3, $zero, 32
addi $sp, $sp, -4
sw, $t3, 0($sp)
jal setLogCar

# SET LOGROW3
la $a0, logRow3
lw $a1, logRowStart3
addi $a2, $zero, 12 		# store start pixel of car/log 1 in $a1
addi $a3, $zero, 76 		# store start pixel of car/log 2 in $a2
# store width (num pixel * 4) of log.car in $sp
addi $t3, $zero, 32
addi $sp, $sp, -4
sw, $t3, 0($sp)
jal setLogCar

# SET CARROW1
la $a0, carRow1
lw $a1, carRowStart1
addi $a2, $zero, 0 		# store start pixel of car/log 1 in $a1
addi $a3, $zero, 64 		# store start pixel of car/log 2 in $a2
# store width (num pixel * 4) of log.car in $sp
addi $t3, $zero, 24
addi $sp, $sp, -4
sw, $t3, 0($sp)
jal setLogCar

# SET CARROW2
la $a0, carRow2
lw $a1, carRowStart2
addi $a2, $zero, 24 		# store start pixel of car/log 1 in $a1
addi $a3, $zero, 88 		# store start pixel of car/log 2 in $a2
# store width (num pixel * 4) of log.car in $sp
addi $t3, $zero, 24
addi $sp, $sp, -4
sw, $t3, 0($sp)
jal setLogCar

# SET CARROW3
la $a0, carRow3
lw $a1, carRowStart3
addi $a2, $zero, 12 		# store start pixel of car/log 1 in $a1
addi $a3, $zero, 76 		# store start pixel of car/log 2 in $a2
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

# SET CAR LOG CURR LAP
la $t0, carLogCurrLap 		# load carLogCurrLap address
sw $zero, 0($t0)		# carLogCurrLap = 0

# STORE GOAL REGION
add $a0, $zero, $zero 		# put start location of goal region into $a0
addi $a1, $zero, 640 		# put end location of goal region into $a1
lw $a2, goalColor  		# load color of goal region into $a2
jal storeRec

# STORE GOALROW
la $a0, goalRow
lw $a1, goalRowStart
lw $a2 goalColor
lw $a3 goalBlockColor
jal storeLogCar

# STORE LOGROW1
la $a0 logRow1
lw $a1 logRowStart1
lw $a2 waterColor
lw $a3 logColor
jal storeLogCar

# STORE LOGROW2
la $a0 logRow2
lw $a1 logRowStart2
lw $a2 waterColor
lw $a3 logColor
jal storeLogCar

# STORE LOGROW3
la $a0 logRow3
lw $a1 logRowStart3
lw $a2 waterColor
lw $a3 logColor
jal storeLogCar

# STORE SAFE REGION
addi $a0, $zero, 2176 		# put start location of safe region into $a0
addi $a1, $zero, 2560		# put end location of safe region into $a1
lw $a2, safeColor  		# load color of safe region into $a2
jal storeRec

# STORE CARROW1
la $a0 carRow1
lw $a1 carRowStart1
lw $a2 roadColor
lw $a3 carColor
jal storeLogCar

# STORE CARROW2
la $a0 carRow2
lw $a1 carRowStart2
lw $a2 roadColor
lw $a3 carColor
jal storeLogCar

# STORE CARROW3
la $a0 carRow3
lw $a1 carRowStart3
lw $a2 roadColor
lw $a3 carColor
jal storeLogCar

# STORE START REGION
addi $a0, $zero, 3712 		# put start location of start region into $a0
addi $a1, $zero, 4096 		# put end location of start region into $a1
lw $a2, startColor  		# load color of start region into $a2
jal storeRec

# STORE FROG
la $a0, frogPosition
lw $a1, frogLightColor 		# load light color of frog into $a1
lw $a2, frogDarkColor 		# load dark color of frog into $a2
jal storeFrog

# STORE FROG LIFE
la $a0, frogLifeArray
lw $a1, frogLifeColor
jal storeLife

# DRAW SCREEN
jal drawScreen

MainLoop: 
# CHECK IF GOAL REACHED
lw $t1, goalReached 			# store if goal reached in $t1
beq $t1, $zero, checkFrogDie		# if goalReached == 0, goal not reached
sw $zero, goalReached			# if goal is reached, reset goal reach and jump to Main
j Main

# CHECK IF FROG DIED
checkFrogDie:
lw $t1, frogDie 			# store the status(alove/dead) of frog in $t1
bne $t1, $zero, alive			# if status != 0, frog is alive

# UPDATE FROG LIFE
lw $t1, frogLifeRemain			# load frog life remaining
addi $t1, $t1, -1			# decrease life by 1
sw $t1, frogLifeRemain			# store updated life reaming 
la $a0, frogLifeArray
lw $a1, frogLifeRemain
jal updateLife				# update frog life remaining array 

# STORE FROG LIFE
la $a0, frogLifeArray
lw $a1, frogLifeColor
jal storeLife

# STORE FROG (DIE COLOR 1)
la $a0, frogPosition
lw $a1, frogDieLightColor1 		# load light color of frog into $a1
lw $a2, frogDieDarkColor1 		# load dark color of frog into $a2
jal storeFrog
# DRAW SCREEN
jal drawScreen
li $v0, 32
li $a0, 300
syscall

# STORE FROG (DIE COLOR 2)
la $a0, frogPosition
lw $a1, frogDieLightColor2 		# load light color of frog into $a1
lw $a2, frogDieDarkColor2 		# load dark color of frog into $a2
jal storeFrog
# DRAW SCREEN
jal drawScreen
li $v0, 32
li $a0, 300
syscall

# STORE FROG (DIE COLOR 1)
la $a0, frogPosition
lw $a1, frogDieLightColor1 		# load light color of frog into $a1
lw $a2, frogDieDarkColor1 		# load dark color of frog into $a2
jal storeFrog
# DRAW SCREEN
jal drawScreen
li $v0, 32
li $a0, 300
syscall

addi $t1, $zero, 1			# change frog to alive
sw $t1, frogDie

j Main

########################################################################################################################################################
alive:
# CHECK KEYBOARD INPUT
lw $t8, 0xffff0000		# load whether there is a keyboard event into $t8 (yes = 1, no = 0)
beq $t8, 0, checkUpdateRest
# CHECK WHICH KEY IS PRESSED
lw $t2, 0xffff0004		# load which key was pressed into $t2
beq $t2, 0x77, respondUp	# 'w' pressed
beq $t2, 0x73, respondDown	# 's' pressed
beq $t2, 0x61, respondLeft	# 'a' pressed
beq $t2, 0x64, respondRight	# 'd' pressed
# UPDATE FROG UP
respondUp:
la $a0, frogPosition
addi $a1, $zero, 0
addi $a2, $zero, -12 
jal updateFrog
j checkUpdateRest
# UPDATE FROG DOWN
respondDown:
la $a0, frogPosition
addi $a1, $zero, 0
addi $a2, $zero, 12 
jal updateFrog
j checkUpdateRest
# UPDATE FROG LEFT
respondLeft:
la $a0, frogPosition
addi $a1, $zero, 1
addi $a2, $zero, -12 
jal updateFrog
j checkUpdateRest
# UPDATE FROG RIGHT
respondRight:
la $a0, frogPosition
addi $a1, $zero, 1
addi $a2, $zero, 12 
jal updateFrog
j checkUpdateRest

# CHECK WHETHER NEED TO UPDATE THE OTHER OBJECTS
checkUpdateRest:
lw $t1, carLogSpeed
lw $t2, carLogCurrLap
la $t3, carLogCurrLap
bne $t2, $t1, updateclLap		# if carLogCurrLap have not reached carLogSpeed, don't update
sw $zero, 0($t3)			# reset carLogCurrLap to 0

# UPDATE FROG WITH LOG 
la $t0, frogPosition
lw $t1, 4($t0)				# load y position of frog into $t2
lw $t2, logRow1Middle			# $t2 stores middle height of log row 1
lw $t3, logRow2Middle			# $t3 stores middle height of log row 2
lw $t4, logRow3Middle			# $t4 stores middle height of log row 3
beq $t1, $t2, updateFrogRLogRow1	# move frog right with log (log row 1)
beq $t1, $t3, updateFrogLLogRow2	# move frog left with log (log row 2)
beq $t1, $t4, updateFrogRLogRow3	# move frog right with log (log row 3)
j updateRest				# if frog is not in any of the above rows, frog is not at the water region
# UPDATE FROG RIGHT WITH LOG ROW 1
updateFrogRLogRow1:
lw $a1, 0($t0)				# $a1 stores x position of frog
la $a0 logRow1				# $a0 stores address of log row 1 array
jal checkFrogOnLog
lw $t5, 0($sp)				# load return value from $sp
addi $sp, $sp, 4
bne $t5, $zero, updateFrogRightWithLog
j updateRest				# return = 0, frog is not on log, frog dies
# UPDATE FROG LEFT WITH LOG ROW 2
updateFrogLLogRow2:
lw $a1, 0($t0)				# $a1 stores x position of frog
la $a0 logRow2				# $a0 stores address of log row 2 array
jal checkFrogOnLog
lw $t5, 0($sp)				# load return value from $sp
addi $sp, $sp, 4
bne $t5, $zero, updateFrogLeftWithLog
j updateRest				# if all above positions equal 0, frog is not on log, frog dies
# UPDATE FROG RIGHT WITH LOG ROW 3
updateFrogRLogRow3:
lw $a1, 0($t0)				# $a1 stores x position of frog
la $a0 logRow3				# $a0 stores address of log row 3 array
jal checkFrogOnLog
lw $t5, 0($sp)				# load return value from $sp
addi $sp, $sp, 4
bne $t5, $zero, updateFrogRightWithLog
j updateRest				# if all above positions equal 0, frog is not on log, frog dies
updateFrogRightWithLog:
la $a0, frogPosition
addi $a1, $zero, 1
addi $a2, $zero, 4 
jal updateFrog
j updateRest
updateFrogLeftWithLog:
la $a0, frogPosition
addi $a1, $zero, 1
addi $a2, $zero, -4 
jal updateFrog
j updateRest

# UPDATE REST OF OBJECTS (LOGS, CARS)
updateRest:
# UPDATE LOGROW1 
la $a0, logRow1
addi $a1, $zero, 1
jal updateLogCar  

# UPDATE LOGROW2
la $a0, logRow2
addi $a1, $zero, 0
jal updateLogCar

# UPDATE LOGROW3
la $a0, logRow3
addi $a1, $zero, 1
jal updateLogCar

# UPDATE CARROW1 
la $a0, carRow1
addi $a1, $zero, 0
jal updateLogCar

# UPDATE CARROW2
la $a0, carRow2
addi $a1, $zero, 1
jal updateLogCar

# UPDATE CARROW3
la $a0, carRow3
addi $a1, $zero, 0
jal updateLogCar
j frogDieCheck				# jump to frogDieCheck

updateclLap:
addi $t2, $t2, 1
sw $t2, 0($t3)				# increment carLogCurrLap by 1

# CHECK WHETHER FROG DIES/REACH GOAL
frogDieCheck:
la $t0, frogPosition
lw $t1, 4($t0)				# load y position of frog into $t1
lw $t2, logRow1Middle			# $t2 stores middle height of log row 1
lw $t3, logRow2Middle			# $t3 stores middle height of log row 2
lw $t4, logRow3Middle			# $t4 stores middle height of log row 3
lw $t5, carRow1Middle			# $t5 stores middle height of car row 1
lw $t6, carRow2Middle			# $t6 stores middle height of car row 2
lw $t7, carRow3Middle			# $t7 stores middle height of car row 3
lw $t8, goalRowMiddle			# $t8 stores middle height of goal row
beq $t1, $t2, checkFrogDieLogRow1
beq $t1, $t3, checkFrogDieLogRow2	
beq $t1, $t4, checkFrogDieLogRow3	
beq $t1, $t5, checkFrogDieCarRow1	
beq $t1, $t6, checkFrogDieCarRow2	
beq $t1, $t7, checkFrogDieCarRow3	
beq $t1, $t8, checkFrogOnGoalBlock	
j store					# if frog is not in any of the above rows, frog is not in the water or road region
# CHECK FROG DIE WITH LOG ROW 1
checkFrogDieLogRow1:
lw $a1, 0($t0)				# $a1 stores x position of frog
la $a0 logRow1				# $a0 stores address of log row 1 array
jal checkFrogOnLog
lw $t9, 0($sp)				# load return value from $sp
addi $sp, $sp, 4
beq $t9, $zero, updateFrogDie		# return = 0, frog hit car, frog dies
j store	
# CHECK FROG DIE WITH LOG ROW 2
checkFrogDieLogRow2:
lw $a1, 0($t0)				# $a1 stores x position of frog
la $a0 logRow2				# $a0 stores address of log row 2 array
jal checkFrogOnLog
lw $t9, 0($sp)				# load return value from $sp
addi $sp, $sp, 4
beq $t9, $zero, updateFrogDie		# return = 0, frog hit car, frog dies
j store	
# CHECK FROG DIE WITH LOG ROW 3
checkFrogDieLogRow3:
lw $a1, 0($t0)				# $a1 stores x position of frog
la $a0 logRow3				# $a0 stores address of log row 3 array
jal checkFrogOnLog
lw $t9, 0($sp)				# load return value from $sp
addi $sp, $sp, 4
beq $t9, $zero, updateFrogDie		# return = 0, frog hit car, frog dies
j store	
# CHECK FROG DIE WITH CAR ROW 1
checkFrogDieCarRow1:
lw $a1, 0($t0)				# $a1 stores x position of frog
la $a0 carRow1				# $a0 stores address of car row 1 array
jal checkFrogHitCar
lw $t9, 0($sp)				# load return value from $sp
addi $sp, $sp, 4
beq $t9, $zero, updateFrogDie		# return = 0, frog hit car, frog dies
j store	
# CHECK FROG DIE WITH CAR ROW 2
checkFrogDieCarRow2:
lw $a1, 0($t0)				# $a1 stores x position of frog
la $a0 carRow2				# $a0 stores address of car row 2 array
jal checkFrogHitCar
lw $t9, 0($sp)				# load return value from $sp
addi $sp, $sp, 4
beq $t9, $zero, updateFrogDie		# return = 0, frog hit car, frog dies
j store	
# CHECK FROG DIE WITH CAR ROW 3
checkFrogDieCarRow3:
lw $a1, 0($t0)				# $a1 stores x position of frog
la $a0 carRow3				# $a0 stores address of car row 3 array
jal checkFrogHitCar
lw $t9, 0($sp)				# load return value from $sp
addi $sp, $sp, 4
beq $t9, $zero, updateFrogDie		# return = 0, frog hit car, frog dies
j store	
# CHECK FROG REACH GOAL
checkFrogOnGoalBlock:	
lw $a1, 0($t0)				# $a1 stores x position of frog
la $a0 goalRow				# $a0 stores address of goal Row array
jal checkFrogReachGoal
lw $t9, 0($sp)				# load return value from $sp
addi $sp, $sp, 4
beq $t9, $zero, updateFrogDie		# return = 0, frog not reach goal, frog dies
la $t0, frogPosition			# return = 1, update goal row
la $a0, goalRow
lw $a1, 0($t0)				# $a1 stores x position of frog
jal updateGoalRow
lw $t0, frogGoalRemain			# decrease avaliable goal block by 1
addi $t0, $t0, -1			
sw $t0, frogGoalRemain	
addi $t0, $t0, 1			# update goal reached		
sw $t0, goalReached		
j store			
updateFrogDie:
sw $zero, frogDie 			# store the status(alove/dead) of frog in $t1

########################################################################################################################################################
store:
# STORE GOAL REGION
add $a0, $zero, $zero 		# put start location of goal region into $a0
addi $a1, $zero, 640 		# put end location of goal region into $a1
lw $a2, goalColor  		# load color of goal region into $a2
jal storeRec

# STORE GOALROW
la $a0, goalRow
lw $a1, goalRowStart
lw $a2 goalColor
lw $a3 goalBlockColor
jal storeLogCar

# STORE LOGROW1
la $a0 logRow1
lw $a1 logRowStart1
lw $a2 waterColor
lw $a3 logColor
jal storeLogCar

# STORE LOGROW2
la $a0 logRow2
lw $a1 logRowStart2
lw $a2 waterColor
lw $a3 logColor
jal storeLogCar

# STORE LOGROW3
la $a0 logRow3
lw $a1 logRowStart3
lw $a2 waterColor
lw $a3 logColor
jal storeLogCar

# STORE SAFE REGION
addi $a0, $zero, 2176 		# put start location of safe region into $a0
addi $a1, $zero, 2560		# put end location of safe region into $a1
lw $a2, safeColor  		# load color of safe region into $a2
jal storeRec

# STORE CARROW1
la $a0 carRow1
lw $a1 carRowStart1
lw $a2 roadColor
lw $a3 carColor
jal storeLogCar

# STORE CARROW2
la $a0 carRow2
lw $a1 carRowStart2
lw $a2 roadColor
lw $a3 carColor
jal storeLogCar

# STORE CARROW3
la $a0 carRow3
lw $a1 carRowStart3
lw $a2 roadColor
lw $a3 carColor
jal storeLogCar

# STORE START REGION
addi $a0, $zero, 3712 		# put start location of start region into $a0
addi $a1, $zero, 4096 		# put end location of start region into $a1
lw $a2, startColor  		# load color of start region into $a2
jal storeRec

# STORE FROG
la $a0, frogPosition
lw $a1, frogLightColor 		# load light color of frog into $a1
lw $a2, frogDarkColor 		# load dark color of frog into $a2
jal storeFrog

# STORE FROG LIFE
la $a0, frogLifeArray
lw $a1, frogLifeColor
jal storeLife

# DRAW SCREEN
jal drawScreen

li $v0, 32
li $a0, 17
syscall

j MainLoop

Exit:
li $v0, 10 # terminate the program gracefully
syscall
