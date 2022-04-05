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
frogPosition: .space 8			# (x, y)

goalRow: .word 0:32
logRow1: .space 128
logRow2: .space 128
logRow3: .space 128
carRow1: .space 128
carRow2: .space 128
carRow3: .space 128

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
goalRowMiddle: .word 24
logRow1Middle: .word 36
logRow2Middle: .word 48
logRow3Middle: .word 60
carRow1Middle: .word 84
carRow2Middle: .word 96
carRow3Middle: .word 108

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

displayAddress: .word 0x10008000
screen: .space 4096

currLevel: .word 0		# (current level - 1) * 4 that the game is in 
maxLevel: .word 4 		# (maximum level - 1) * 4 of the game
goalRemain: .word 3 		# goal position remaining = 3 at the begining
frogReachedGoal: .word 0	# 0 = not reached, 1 = reached 
frogDied: .word 0 		# 0 = not die, 1 = die
frogLifeRemain: .word 3 	# number of life remaining, start with 3
frogLifeArray: .word 1:3 	# life remaining array is an array with 3 elements, 0 = no life, 1 = life

# carLogSpeed: .word 10 		# how many main loop cycles to update car/log position once
# carLogCurrLap: .space 4		# which cycles is car/log currently on
logRow1Speed: .word 10, 4	# speed of logRow1 in each level
logRow2Speed: .word 10, 8	# speed of logRow2 in each level
logRow3Speed: .word 10, 6	# speed of logRow3 in each level
carRow1Speed: .word 10, 6	# speed of carRow1 in each level
carRow2Speed: .word 10, 4	# speed of carRow2 in each level
carRow3Speed: .word 10, 8	# speed of carRow3 in each level
logRow1CurrentLap: .word 0	# which cycles is logRow1 currently on, if cycle(lap) == speed, update log position
logRow2CurrentLap: .word 0	# which cycles is logRow2 currently on, if cycle(lap) == speed, update log position
logRow3CurrentLap: .word 0	# which cycles is logRow3 currently on, if cycle(lap) == speed, update log position
carRow1CurrentLap: .word 0	# which cycles is carRow1 currently on, if cycle(lap) == speed, update car position
carRow2CurrentLap: .word 0	# which cycles is carRow2 currently on, if cycle(lap) == speed, update car position
carRow3CurrentLap: .word 0	# which cycles is carRow3 currently on, if cycle(lap) == speed, update car position

retryMessage: .asciiz "Do you want to Retry?"
nextLevelMessage: .asciiz "Do you want to play the next level?"

.text
j resetFrogLife
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
blt $t1, $a1, updateLifeIsLife
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


#####################################################################################################################################################################
Main:
# CHECK CURRENT LEVEL == MAX LEVEL
checkNoMoreLevel:
lw $t0, currLevel ########################################################################################################################################
lw $t1, maxLevel
beq $t0, $t1, Exit				# if currLevel == maxLevel (game ended), jump to Exit

# CHECK IF GOAL REMAIN == 0
checkLevelPassed:
lw $t1, goalRemain
bne $t1, $zero, checkGoalReachedLastCycle	# if goalRemain != 0 (frog didn't pass level), jump to checkGoalReachedLastCycle

# DISPLAY VICTORY DRAWING
displayVictory:
# victory screen: store frog (die color 2)
la $a0, frogPosition
lw $a1, frogDieLightColor2 		# load light color of frog into $a1
lw $a2, frogDieDarkColor2 		# load dark color of frog into $a2
jal storeFrog
# draw screen
jal drawScreen
li $v0, 32
li $a0, 1000
syscall

# ASK IF CONTINUE TO PLAY
askContinue:
li $v0, 50
la $a0, nextLevelMessage
syscall
bne $a0, $zero, Exit			# if $a0 != 0 (user didn't choose yes), jump to Exit

# RESET goalRemain, frogReachedGoal, frogDied, (frogLifeRemain, frogLifeArray,) UPDATE currLevel
resetForNextLevel:
addi $t0, $zero, 3
sw, $t0, goalRemain			# reset goalRemain to 3
sw $zero, frogReachedGoal		# reset frogReachedGoal to 0 (not reached)
sw $zero, frogDied			# reset frogDied to 0 (not die)
lw $t0, currLevel			
addi $t0, $t0, 4
sw $t0, currLevel			# update currLevel
j resetFrogLife				# jump to resetFrogLife

# CHECK IF GOAL REACHED LAST ROUND
checkGoalReachedLastCycle:
lw $t0, frogReachedGoal
beq $t0, $zero, checkFrogDiedLastCycle		# if $t0 == 0 (frog did not reached goal), jump to checkFrogDiedLastCycle

# RESET frogReachedGoal
resetForGoalReach:
sw $zero, frogReachedGoal			# if goal is reached, reset frogReachedGoal to 0
j resetFrogLogCar				# jump to resetFrogLogCar

# CHECK IF FROG DIED
checkFrogDiedLastCycle:
lw $t0, frogDied 			# store the status(alove/dead) of frog in $t1
beq $t0, $zero, checkKeyPressed		# if status == 0 (frog is did not die), jump to checkKeyPressed

# UPDATE frogLifeRemain, frogLifeArray, RESET frogDied
updateForFrogDeath:
# reset frogDied
sw $zero, frogDied			# reset frogDied to 0 (not die)

# DISPLAY FROG DEATH ANIMATION
displayDeath:
# die screen 1: store frog (die color 1)
la $a0, frogPosition
lw $a1, frogDieLightColor1 		# load light color of frog into $a1
lw $a2, frogDieDarkColor1 		# load dark color of frog into $a2
jal storeFrog
# draw screen
jal drawScreen
li $v0, 32
li $a0, 300
syscall
# die screen 2: store frog (die color 2)
la $a0, frogPosition
lw $a1, frogDieLightColor2 		# load light color of frog into $a1
lw $a2, frogDieDarkColor2 		# load dark color of frog into $a2
jal storeFrog
# draw screen
jal drawScreen
li $v0, 32
li $a0, 300
syscall
# die screen 3: store frog (die color 1)
la $a0, frogPosition
lw $a1, frogDieLightColor1 		# load light color of frog into $a1
lw $a2, frogDieDarkColor1 		# load dark color of frog into $a2
jal storeFrog
# draw screen
jal drawScreen
li $v0, 32
li $a0, 300
syscall

# CHECK IF FROG LOFE REMAIM == 0 (LOST ALL 3 LIVES)
checkLostAllLife:
lw $t0, frogLifeRemain			# load frog life remain into $t1
bne $t0, $zero, resetFrogLogCar		# if life remaining != 0 (frog have not lost all lives), jump to resetFrogLogCar

# ASK IF RETRY LEVEL
askRetry:
li $v0, 50
la $a0, retryMessage
syscall
bne $a0, $zero, Exit			# if $z0 != 0 (user didn't choose yes), jump to Exit

# RESET frogLifeRemain, frogLifeArray
resetFrogLife:
addi $t1, $zero, 3
sw $t1, frogLifeRemain			# change frog life remain back to 3
la $a0, frogLifeArray
lw $a1, frogLifeRemain
jal updateLife				# update frog life remaining array 

# RESET goalRow
resetGoalRegion:
la $a0, goalRow
jal setGoalRow

# RESET logRow, carRow, log/carRowLap, frogPosition
resetFrogLogCar:
# logRow1
la $a0, logRow1
lw $a1, logRowStart1
addi $a2, $zero, 0 		# store start pixel of car/log 1 in $a1
addi $a3, $zero, 64 		# store start pixel of car/log 2 in $a2
addi $t3, $zero, 32
addi $sp, $sp, -4
sw, $t3, 0($sp)			# store width (num pixel * 4) of log.car in $sp
jal setLogCar 
# logRow2
la $a0, logRow2
lw $a1, logRowStart2
addi $a2, $zero, 24 		# store start pixel of car/log 1 in $a1
addi $a3, $zero, 88 		# store start pixel of car/log 2 in $a2
addi $t3, $zero, 32
addi $sp, $sp, -4
sw, $t3, 0($sp)			# store width (num pixel * 4) of log.car in $sp
jal setLogCar
# logRow3
la $a0, logRow3
lw $a1, logRowStart3
addi $a2, $zero, 12 		# store start pixel of car/log 1 in $a1
addi $a3, $zero, 76 		# store start pixel of car/log 2 in $a2
addi $t3, $zero, 32
addi $sp, $sp, -4
sw, $t3, 0($sp)			# store width (num pixel * 4) of log.car in $sp
jal setLogCar
# carRow1
la $a0, carRow1
lw $a1, carRowStart1
addi $a2, $zero, 0 		# store start pixel of car/log 1 in $a1
addi $a3, $zero, 64 		# store start pixel of car/log 2 in $a2
addi $t3, $zero, 24
addi $sp, $sp, -4
sw, $t3, 0($sp)			# store width (num pixel * 4) of log.car in $sp
jal setLogCar
# carRow2
la $a0, carRow2
lw $a1, carRowStart2
addi $a2, $zero, 24 		# store start pixel of car/log 1 in $a1
addi $a3, $zero, 88 		# store start pixel of car/log 2 in $a2
addi $t3, $zero, 24
addi $sp, $sp, -4
sw, $t3, 0($sp)			# store width (num pixel * 4) of log.car in $sp
jal setLogCar
# carRow3
la $a0, carRow3
lw $a1, carRowStart3
addi $a2, $zero, 12 		# store start pixel of car/log 1 in $a1
addi $a3, $zero, 76 		# store start pixel of car/log 2 in $a2
addi $t3, $zero, 24
addi $sp, $sp, -4
sw, $t3, 0($sp)			# store width (num pixel * 4) of log.car in $sp
jal setLogCar
# log/carRowLap
sw $zero, logRow1CurrentLap	
sw $zero, logRow2CurrentLap
sw $zero, logRow3CurrentLap
sw $zero, carRow1CurrentLap
sw $zero, carRow2CurrentLap
sw $zero, carRow3CurrentLap
# frogPosition
addi $a0, $zero, 68
addi $a1, $zero, 120
la $a2, frogPosition
jal setFrog
j storeDraw

#####################################################################################################################################################################
# CHECK IF THERE IS KEYBOARD EVENT
checkKeyPressed:
lw $t8, 0xffff0000			# load whether there is a keyboard event into $t8 (yes = 1, no = 0)
beq $t8, $zero, moveLogCar		# if $t8 == 0 (key is not pressed), jump to moveLogCar

# CHECK IF (W/S/A/D) WAS PRESSED
checkWhichKey:
lw $t2, 0xffff0004		# load which key was pressed into $t2
beq $t2, 0x77, respondUp	# 'w' pressed
beq $t2, 0x73, respondDown	# 's' pressed
beq $t2, 0x61, respondLeft	# 'a' pressed
beq $t2, 0x64, respondRight	# 'd' pressed
j moveLogCar			# if key pressed was not w/a/s/d, jump to moveLogCar

# UPDATE frogPosition
# frog up
respondUp:
la $a0, frogPosition
addi $a1, $zero, 0
addi $a2, $zero, -12 
jal updateFrog
j moveLogCar
# frog down
respondDown:
la $a0, frogPosition
addi $a1, $zero, 0
addi $a2, $zero, 12 
jal updateFrog
j moveLogCar
# frog left
respondLeft:
la $a0, frogPosition
addi $a1, $zero, 1
addi $a2, $zero, -12 
jal updateFrog
j moveLogCar
# frog right
respondRight:
la $a0, frogPosition
addi $a1, $zero, 1
addi $a2, $zero, 12 
jal updateFrog
j moveLogCar

# UPDATE LOG CAR ROW IF NEEDED
moveLogCar:
# update logRow1 and frog if needed
checkSpeedLogRow1:
lw $t0, logRow1CurrentLap
la $t1, logRow1Speed
lw $t2, currLevel
add $t1, $t1, $t2 			
lw $t1, 0($t1)				# $t1 = speed of logRow1 accrding to level
beq $t0, $t1, updateFrogOnLogRow1	# if $t0 == $t1, jump to updateFrogOnLogRow1
addi $t0, $t0, 1 				
sw $t0, logRow1CurrentLap		# else ($t0 != $t1), increment logRow1CurrentLap by 1
j checkSpeedLogRow2			# jump to checkSpeedLogRow12
updateFrogOnLogRow1:			# update Frog On Log Row 1 if needed
la $t0, frogPosition			
lw $t1, logRow1Middle
lw $t2, 4($t0)				# $t2 = current y position of frog
bne $t1, $t2, updateLogRow1		# if $t1 != $t2 (frog not on this row), jump to updateLogRow1
la $a0 logRow1				# else (frog on this row), check if frog on log
lw $a1, 0($t0)				# $a0 = address of log row 1 array, $a1 = x position of frog
jal checkFrogOnLog			# check if frog on log
lw $t5, 0($sp)				
addi $sp, $sp, 4			# $t5 = return value of checkFrogOnLog (0 = not on log, 1 = on log)
beq $t5, $zero, updateLogRow1		# if $t5 == 0 (frog not on log), jump to updateLogRow1
la $a0, frogPosition			# else (frog on log), update frog position
addi $a1, $zero, 1
addi $a2, $zero, 4 
jal updateFrog				# update frog right with log
updateLogRow1:
la $a0, logRow1
addi $a1, $zero, 1
jal updateLogCar  			# update log
sw $zero, logRow1CurrentLap		# reset logRow1CurrentLap to 0
# update logRow2 and frog if needed
checkSpeedLogRow2:
lw $t0, logRow2CurrentLap
la $t1, logRow2Speed
lw $t2, currLevel
add $t1, $t1, $t2 			
lw $t1, 0($t1)				# $t1 = speed of logRow2 accrding to level
beq $t0, $t1, updateFrogOnLogRow2	# if $t0 == $t1, jump to updateFrogOnLogRow2
addi $t0, $t0, 1 				
sw $t0, logRow2CurrentLap		# else ($t0 != $t1), increment logRow2CurrentLap by 1
j checkSpeedLogRow3			# jump to checkSpeedLogRow13
updateFrogOnLogRow2:			# update Frog On Log Row 2 if needed
la $t0, frogPosition			
lw $t1, logRow2Middle
lw $t2, 4($t0)				# $t2 = current y position of frog
bne $t1, $t2, updateLogRow2		# if $t1 != $t2 (frog not on this row), jump to updateLogRow1
la $a0 logRow2				# else (frog on this row), check if frog on log
lw $a1, 0($t0)				# $a0 = address of log row 2 array, $a1 = x position of frog
jal checkFrogOnLog			# check if frog on log
lw $t5, 0($sp)				
addi $sp, $sp, 4			# $t5 = return value of checkFrogOnLog (0 = not on log, 1 = on log)
beq $t5, $zero, updateLogRow2		# if $t5 == 0 (frog not on log), jump to updateLogRow2
la $a0, frogPosition			# else (frog on log), update frog position
addi $a1, $zero, 1
addi $a2, $zero, -4 
jal updateFrog				# update frog left with log
updateLogRow2:
la $a0, logRow2
addi $a1, $zero, 0
jal updateLogCar  			# update log
sw $zero, logRow2CurrentLap		# reset logRow2CurrentLap to 0
# update logRow3 and frog if needed
checkSpeedLogRow3:
lw $t0, logRow3CurrentLap
la $t1, logRow3Speed
lw $t2, currLevel
add $t1, $t1, $t2 			
lw $t1, 0($t1)				# $t1 = speed of logRow3 accrding to level
beq $t0, $t1, updateFrogOnLogRow3	# if $t0 == $t1, jump to updateFrogOnLogRow3
addi $t0, $t0, 1 				
sw $t0, logRow3CurrentLap		# else ($t0 != $t1), increment logRow3CurrentLap by 1
j checkSpeedCarRow1			# jump to checkSpeedCarRow1
updateFrogOnLogRow3:			# update Frog On Log Row 3 if needed
la $t0, frogPosition			
lw $t1, logRow3Middle
lw $t2, 4($t0)				# $t2 = current y position of frog
bne $t1, $t2, updateLogRow3		# if $t1 != $t2 (frog not on this row), jump to updateLogRow3
la $a0 logRow3				# else (frog on this row), check if frog on log
lw $a1, 0($t0)				# $a0 = address of log row 2 array, $a1 = x position of frog
jal checkFrogOnLog			# check if frog on log
lw $t5, 0($sp)				
addi $sp, $sp, 4			# $t5 = return value of checkFrogOnLog (0 = not on log, 1 = on log)
beq $t5, $zero, updateLogRow3		# if $t5 == 0 (frog not on log), jump to updateLogRow3
la $a0, frogPosition			# else (frog on log), update frog position
addi $a1, $zero, 1
addi $a2, $zero, 4 
jal updateFrog				# update frog right with log
updateLogRow3:
la $a0, logRow3
addi $a1, $zero, 1
jal updateLogCar  			# update log
sw $zero, logRow3CurrentLap		# reset logRow3CurrentLap to 0
# update carRow1 if needed
checkSpeedCarRow1:
lw $t0, carRow1CurrentLap
la $t1, carRow1Speed
lw $t2, currLevel
add $t1, $t1, $t2 			# get speed of carRow1 (stored in $t1) accrding to level
beq $t0, $t1, updateCarRow1		# if $t0 == $t1, jump to updateCarRow1
addi $t0, $t0, 1				
sw $t0, carRow1CurrentLap		# else ($t0 != $t1), increment carRow1CurrentLap by 1
j checkSpeedCarRow2			# jump to checkSpeedCarRow12
updateCarRow1:				# update carRow1
la $a0, carRow1
addi $a1, $zero, 0
jal updateLogCar  
sw $zero, carRow1CurrentLap		# reset carRow1CurrentLap to 0
# update carRow2 if needed
checkSpeedCarRow2:
lw $t0, carRow2CurrentLap
la $t1, carRow2Speed
lw $t2, currLevel
add $t1, $t1, $t2 			# get speed of carRow2 (stored in $t1) accrding to level
beq $t0, $t1, updateCarRow2		# if $t0 == $t1, jump to updateCarRow2
addi $t0, $t0, 1
sw $t0, carRow2CurrentLap		# else ($t0 != $t1), increment carRow2CurrentLap by 1
j checkSpeedCarRow3			# jump to checkSpeedCarRow13
updateCarRow2:				# update carRow2
la $a0, carRow2
addi $a1, $zero, 1
jal updateLogCar  
sw $zero, carRow2CurrentLap		# reset carRow2CurrentLap to 0
# update carRow3 if needed
checkSpeedCarRow3:
lw $t0, carRow3CurrentLap
la $t1, carRow3Speed
lw $t2, currLevel
add $t1, $t1, $t2 			# get speed of carRow3 (stored in $t1) accrding to level
beq $t0, $t1, updateCarRow3		# if $t0 == $t1, jump to updateCarRow2
addi $t0, $t0, 1
sw $t0, carRow3CurrentLap		# else ($t0 != $t1), increment carRow3CurrentLap by 1
j detectFrogDieReachGoal		# jump to detectFrogDieReachGoal
updateCarRow3:				# update carRow3
la $a0, carRow3
addi $a1, $zero, 0
jal updateLogCar  
sw $zero, carRow3CurrentLap		# reset carRow3CurrentLap to 0

# DETECT WHETHER FROG DIES OR REACH GOAL
detectFrogDieReachGoal:
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
j storeDraw				# if frog is not in any of the above rows, frog is not in the water or road or goal region
# detect whether frog die with logRow1
checkFrogDieLogRow1:
lw $a1, 0($t0)					# $a1 stores x position of frog
la $a0 logRow1					# $a0 stores address of log row 1 array
jal checkFrogOnLog
lw $t9, 0($sp)					# $t9 = return value from checkFrogOnLog
addi $sp, $sp, 4
beq $t9, $zero, updateFrogDieRelatedInfo	# return = 0, frog not on log, frog dies
j storeDraw	
# detect whether frog die with logRow2
checkFrogDieLogRow2:
lw $a1, 0($t0)					# $a1 stores x position of frog
la $a0 logRow2					# $a0 stores address of log row 2 array
jal checkFrogOnLog
lw $t9, 0($sp)					# $t9 = return value from checkFrogOnLog
addi $sp, $sp, 4
beq $t9, $zero, updateFrogDieRelatedInfo	# return = 0, frog not on log, frog dies
j storeDraw	
# detect whether frog die with logRow3
checkFrogDieLogRow3:
lw $a1, 0($t0)					# $a1 stores x position of frog
la $a0 logRow3					# $a0 stores address of log row 3 array
jal checkFrogOnLog
lw $t9, 0($sp)					# $t9 = return value from checkFrogOnLog
addi $sp, $sp, 4
beq $t9, $zero, updateFrogDieRelatedInfo	# return = 0, frog not on log, frog dies
j storeDraw	
# detect whether frog die with carRow1
checkFrogDieCarRow1:
lw $a1, 0($t0)					# $a1 stores x position of frog
la $a0 carRow1					# $a0 stores address of car row 1 array
jal checkFrogHitCar
lw $t9, 0($sp)					# $t9 = return value from checkFrogHitCar
addi $sp, $sp, 4
beq $t9, $zero, updateFrogDieRelatedInfo	# return = 0, frog hit car, frog dies
j storeDraw	
# detect whether frog die with carRow2
checkFrogDieCarRow2:
lw $a1, 0($t0)					# $a1 stores x position of frog
la $a0 carRow2					# $a0 stores address of car row 2 array
jal checkFrogHitCar
lw $t9, 0($sp)					# $t9 = return value from checkFrogHitCar
addi $sp, $sp, 4
beq $t9, $zero, updateFrogDieRelatedInfo	# return = 0, frog hit car, frog dies
j storeDraw	
# detect whether frog die with carRow3
checkFrogDieCarRow3:
lw $a1, 0($t0)					# $a1 stores x position of frog
la $a0 carRow3					# $a0 stores address of car row 3 array
jal checkFrogHitCar
lw $t9, 0($sp)					# $t9 = return value from checkFrogHitCar
addi $sp, $sp, 4
beq $t9, $zero, updateFrogDieRelatedInfo	# return = 0, frog hit car, frog dies
j storeDraw	
# detect whether frog die or reach goal in goalRow
checkFrogOnGoalBlock:	
lw $a1, 0($t0)					# $a1 stores x position of frog
la $a0 goalRow					# $a0 stores address of goal Row array
jal checkFrogReachGoal
lw $t9, 0($sp)					# $t9 = return value from checkFrogReachGoal
addi $sp, $sp, 4
beq $t9, $zero, updateFrogDieRelatedInfo	# return = 0, frog not reach goal, frog dies
j updateGoalReachRelatedInfo

# UPDATE frogDied, frogLifeRemain, frogLifeArray (frog life -1)
updateFrogDieRelatedInfo:
# update frogDied
addi $t0, $zero, 1
sw $t0, frogDied 			# change frogDied to 1 (indicate frog dies)
# update frogLifeRemain
lw $t1, frogLifeRemain			# load frog life remaining
addi $t1, $t1, -1			# decrease life by 1
sw $t1, frogLifeRemain			# store updated life reaming 
# update frogLifeArray
la $a0, frogLifeArray
lw $a1, frogLifeRemain
jal updateLife				# update frog life remaining array 
j storeDraw

# UPDATE frogReachedGoal, goalRemain, goalRow
updateGoalReachRelatedInfo:
# update frogReachedGoal
addi $t0, $zero, 1				
sw $t0, frogReachedGoal			# change frogReachedGoal to 1 (indicate goal reached)
# update goalRemain
lw $t0, goalRemain			# decrease avaliable goal block by 1
addi $t0, $t0, -1			
sw $t0, goalRemain	
# update goalRow
la $t0, frogPosition			
la $a0, goalRow
lw $a1, 0($t0)				# $a1 stores x position of frog
jal updateGoalRow

########################################################################################################################################################
# STORE AND DRAW ALL OBJECTS AND SLEEP
storeDraw:
# unaffected goal area at the top
add $a0, $zero, $zero 		# put start location of goal region into $a0
addi $a1, $zero, 640 		# put end location of goal region into $a1
lw $a2, goalColor  		# load color of goal region into $a2
jal storeRec
# goalRow
la $a0, goalRow
lw $a1, goalRowStart
lw $a2 goalColor
lw $a3 goalBlockColor
jal storeLogCar
# logRow1
la $a0 logRow1
lw $a1 logRowStart1
lw $a2 waterColor
lw $a3 logColor
jal storeLogCar
# logRow2
la $a0 logRow2
lw $a1 logRowStart2
lw $a2 waterColor
lw $a3 logColor
jal storeLogCar
# logRow3
la $a0 logRow3
lw $a1 logRowStart3
lw $a2 waterColor
lw $a3 logColor
jal storeLogCar
# safe area
addi $a0, $zero, 2176 		# put start location of safe region into $a0
addi $a1, $zero, 2560		# put end location of safe region into $a1
lw $a2, safeColor  		# load color of safe region into $a2
jal storeRec
# carRow1
la $a0 carRow1
lw $a1 carRowStart1
lw $a2 roadColor
lw $a3 carColor
jal storeLogCar
# carRow2
la $a0 carRow2
lw $a1 carRowStart2
lw $a2 roadColor
lw $a3 carColor
jal storeLogCar
# carRow3
la $a0 carRow3
lw $a1 carRowStart3
lw $a2 roadColor
lw $a3 carColor
jal storeLogCar
# start area
addi $a0, $zero, 3712 		# put start location of start region into $a0
addi $a1, $zero, 4096 		# put end location of start region into $a1
lw $a2, startColor  		# load color of start region into $a2
jal storeRec
# frog
la $a0, frogPosition
lw $a1, frogLightColor 		# load light color of frog into $a1
lw $a2, frogDarkColor 		# load dark color of frog into $a2
jal storeFrog
# frog life array
la $a0, frogLifeArray
lw $a1, frogLifeColor
jal storeLife
# draw screen
jal drawScreen
# sleep
li $v0, 32
li $a0, 17
syscall

j Main

Exit:
li $v0, 10 # terminate the program gracefully
syscall
