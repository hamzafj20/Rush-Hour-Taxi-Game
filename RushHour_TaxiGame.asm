INCLUDE Irvine32.inc
.STACK 4096           

.data
MazeRows LABEL BYTE 
MazeRow01 DB "########################################", 13, 10
MazeRow02 DB "#                                #     #", 13, 10
MazeRow03 DB "#   #  #   #     #   # #   # #   #     #", 13, 10
MazeRow04 DB "#   #  #   #     #   # #   # #   #     #", 13, 10
MazeRow05 DB "#   #  #####   # #   # ####  #   ###   #", 13, 10
MazeRow06 DB "#   #          #     #       #         #", 13, 10
MazeRow07 DB "#   #      #             ########      #", 13, 10
MazeRow08 DB "#          #                           #", 13, 10
MazeRow09 DB "#    #     #   ###########             #", 13, 10
MazeRow10 DB "#    #     #                           #", 13, 10
MazeRow11 DB "#    #     #               #####       #", 13, 10
MazeRow12 DB "#    #######   ##########      #       #", 13, 10
MazeRow13 DB "#          #                   #       #", 13, 10
MazeRow14 DB "########   #   ########    #######     #", 13, 10
MazeRow15 DB "#          #               #           #", 13, 10
MazeRow16 DB "# #    #####   #####       #           #", 13, 10
MazeRow17 DB "# #    #           #       ########    #", 13, 10
MazeRow18 DB "# #                #                   #", 13, 10
MazeRow19 DB "#                  #                   #", 13, 10
MazeRow20 DB "########################################", 0

mazeWid = 40           
mazeH = 20
rowLeng = 43            
nRows = 20
startX = 2              
startY = 2   
TaxiX DWORD startX 
TaxiY DWORD startY 
peugeot BYTE "T", 0
empty BYTE " ", 0
citizens BYTE "P", 0
dropPoint BYTE "D", 0
mercedes BYTE "M", 0
taxiC DWORD ? 
scoreAch BYTE 0
timeOutput BYTE 120
lastTime DWORD 0
hasPassenger BYTE 0

gameMode BYTE 0        ; 0 is timed and 1 is infinite mode
timedMode BYTE 1       ; bool which is opposite of isUnlimit
isEndless BYTE 0       ; bool where 1 is endless mode and 0 isn't
difficulty BYTE 0      ; 0 is easy, 1 is normal and 3 is tough

p1X DWORD 0
p1Y DWORD 0
pass1Act BYTE 1
p2X DWORD 0
p2Y DWORD 0
pass2Act BYTE 1
p3X DWORD 0
p3Y DWORD 0
pass3Act BYTE 1
p4X DWORD 0
p4Y DWORD 0
pass4Act BYTE 1
p5X DWORD 0
p5Y DWORD 0
pass5Act BYTE 1

dropPointX DWORD 30
dropPointY DWORD 18
npc1X DWORD 0
npc1Y DWORD 0
npc2X DWORD 0
npc2Y DWORD 0
blackOW = 0F0h
blueOW  = 0F1h
redOW   = 0F4h
yellowOW = 0F6h
greenOW = 0F2h
greyOW  = 0F8h
magentaOW = 0F5h
normalColor = 07h

TitleOne   DB "<<< TAXI GAME >>>", 13, 10, 0
jumpStart DB "Press 'S' 2 Start Game", 13, 10, 0
gaveUP DB "Press 'E' 2 Exit Game", 13, 10, 0

modeChoice DB "<<< MODE SELECTION >>>", 13, 10, 0
modeOne DB "Press 'E' for Endless Mode", 13, 10, 0
modeTwo DB "Press 'T' for Timed Mode", 13, 10, 0

diffTitle DB "<<< DIFFICULTY SELECTION >>>", 13, 10, 0
diffOne DB "press 1 for Easy (180 seconds)", 13, 10, 0
diffTwo DB "press 2 for Normal (120 seconds)", 13, 10, 0
diffThree DB "press 3 for Hard (60 seconds)", 13, 10, 0

TitleTwo  DB "<<< TAXI COLOR SELECTION >>>", 13, 10, 0
redOption DB "Press 'R' 4 Red Taxi", 13, 10, 0
yellowOption DB "Press 'Y' 4 Yellow Taxi", 13, 10, 0

invalid DB "The instructions are straight-forward, Try Again :P", 13, 10, 0
basics DB "arrow keys to move. Q for coward's way out :|", 13, 10, 0
disScore BYTE "Score = ",0
disTimer BYTE "Time Remaining: ", 0
gameOverMsg BYTE "GAME OVER >:)", 13, 10, 0
pickupMsg BYTE "Passenger in the Peugeot :>", 0
dropoffMsg BYTE "Passenger tipped some Euros :D", 0
collisionMsg DB "The Germans are at it again >:[ ", 0
statusMsg BYTE " ", 0

;*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
.code
main PROC
call Randomize
mov eax, blackOW
call SetTextColor
call startMenu
call wat2Pick
call spawnPz
call spawnMercs
call spawnD
call makeMaze
call makePs
call makeMercs
call makeDs
call drawPeugeot
call GetMseconds
mov lastTime, eax

GameLoop:
cmp isEndless, 1
je SkipTimeCheck
mov al, timeOutput
cmp al, 0
je GameOver

SkipTimeCheck:
call GetMseconds
mov ebx, lastTime
sub eax, ebx
cmp eax, 1000
jl SkipTimerUpdate

cmp isEndless, 1
je SkipTimerUpdate
dec timeOutput
call UpdateDisplay
call GetMseconds
mov lastTime, eax

SkipTimerUpdate:
mov eax, 50
call Delay
call ReadKey
jz GameLoop

cmp al, 'q'
je PerformEscape
cmp al, 'Q'
je PerformEscape
cmp al, ' '
je HandleSpacebar

cmp ax, 4800h  
je MoveUp
cmp ax, 5000h 
je MoveDown
cmp ax, 4B00h  
je MoveLeft
cmp ax, 4D00h  
je MoveRight
jmp GameLoop

HandleSpacebar:
call CheckPickupDropoff
jmp GameLoop

MoveUp:
mov esi, 0
mov edi, -1
call ProcessMove
jmp GameLoop

MoveDown:
mov esi, 0
mov edi, 1
call ProcessMove
jmp GameLoop

MoveLeft:
mov esi, -1
mov edi, 0
call ProcessMove
jmp GameLoop

MoveRight:
mov esi, 1
mov edi, 0
call ProcessMove
jmp GameLoop

PerformEscape:
call Crlf                
mov eax, 07h             
call SetTextColor
exit   

GameOver:
call Crlf
call Crlf
mov eax, redOW
call SetTextColor
mov edx, OFFSET gameOverMsg
call WriteString
call Crlf
mov eax, 07h
call SetTextColor
exit

main ENDP

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
introduceNewWindow PROC
call Clrscr
ret
introduceNewWindow ENDP

startMenu PROC
call introduceNewWindow
    
MenuLoop:
push eax                          
mov eax, redOW       
call SetTextColor
    
mov edx, OFFSET TitleOne
call WriteString
call Crlf
    
pop eax                           
call SetTextColor                 
    
mov edx, OFFSET jumpStart
call WriteString
mov edx, OFFSET gaveUP
call WriteString
call Crlf

call ReadChar
    
cmp al, 'A'
jl ignition
cmp al, 'Z'
jg ignition
add al, 20h
    
ignition:
cmp al, 's'
je revEngine
    
cmp al, 'e'
je endd
    
mov edx, OFFSET invalid
call WriteString
call Crlf
jmp MenuLoop

endd:
exit 

revEngine:
ret
startMenu ENDP

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

wat2Pick PROC
call introduceNewWindow
    
ModeLoop:
push eax
mov eax, magentaOW
call SetTextColor
    
mov edx, OFFSET modeChoice
call WriteString
call Crlf
    
pop eax
call SetTextColor
    
mov edx, OFFSET modeOne
call WriteString
mov edx, OFFSET modeTwo
call WriteString
call Crlf

call ReadChar
    
cmp al, 'A'
jl SkipModeConvert
cmp al, 'Z'
jg SkipModeConvert
add al, 20h
    
SkipModeConvert:
cmp al, 'e'
je SetEndless
cmp al, 't'
je SetTimed

mov edx, OFFSET invalid
call WriteString
call Crlf
jmp ModeLoop

SetEndless:
mov isEndless, 1
mov timeOutput, 0
call SelectColor
ret
    
SetTimed:
mov isEndless, 0
call selectDiff
ret

wat2Pick ENDP

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
selectDiff PROC
call introduceNewWindow
    
DiffLoop:
push eax
mov eax, magentaOW
call SetTextColor
    
mov edx, OFFSET diffTitle
call WriteString
call Crlf
    
pop eax
call SetTextColor
    
mov edx, OFFSET diffOne
call WriteString
mov edx, OFFSET diffTwo
call WriteString
mov edx, OFFSET diffThree
call WriteString
call Crlf

call ReadChar
    
cmp al, '1'
je SetEasy
cmp al, '2'
je SetNormal
cmp al, '3'
je SetHard

mov edx, OFFSET invalid
call WriteString
call Crlf
jmp DiffLoop

SetEasy:
mov timeOutput, 180
jmp GoToColor

SetNormal:
mov timeOutput, 120
jmp GoToColor

SetHard:
mov timeOutput, 60
jmp GoToColor
    
GoToColor:
call SelectColor
ret

selectDiff ENDP

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SelectColor PROC
call introduceNewWindow
    
ColorLoop:
push eax                          
mov eax, redOW       
call SetTextColor
    
mov edx, OFFSET TitleTwo
call WriteString
call Crlf
    
pop eax                           
call SetTextColor                 
push eax                          

mov eax, redOW       
call SetTextColor
mov edx, OFFSET redOption
call WriteString
    
mov eax, yellowOW    
call SetTextColor
mov edx, OFFSET yellowOption
call WriteString
    
pop eax                           
call SetTextColor
call Crlf
    
call ReadChar
    
cmp al, 'A'
jl SkipColorConvert
cmp al, 'Z'
jg SkipColorConvert
add al, 20h
    
SkipColorConvert:
cmp al, 'r'
je SetRed
    
cmp al, 'y'
je SetYellow

mov edx, OFFSET invalid
call WriteString
call Crlf
jmp ColorLoop

SetRed:
mov eax, redOW
mov taxiC, eax
call introduceNewWindow
ret
    
SetYellow:
mov eax, yellowOW
mov taxiC, eax
call introduceNewWindow
ret
SelectColor ENDP

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
makeMaze PROC
mov eax, blackOW
call SetTextColor
mov ecx, 1
mov esi, OFFSET MazeRows 
    
L1:
mov edx, esi           
call WriteString       
add esi, rowLeng      
loop L1     

call Crlf
mov edx, OFFSET basics
call WriteString
mov edx, OFFSET disScore
call WriteString
mov eax, 0
mov al, scoreAch
call WriteDec
call Crlf

cmp isEndless, 1
je SkipTimerDisplay
mov edx, OFFSET disTimer
call WriteString
mov eax, 0
mov al, timeOutput
call WriteDec
call Crlf

SkipTimerDisplay:
mov edx, OFFSET statusMsg
call WriteString

ret
makeMaze ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

spawnPz PROC
push eax
push ebx
push ecx
push edx

call getFares
mov p1X, eax
mov p1Y, edx

call getFares
mov p2X, eax
mov p2Y, edx

call getFares
mov p3X, eax
mov p3Y, edx

call getFares
mov p4X, eax
mov p4Y, edx

call getFares
mov p5X, eax
mov p5Y, edx

pop edx
pop ecx
pop ebx
pop eax
ret
spawnPz ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

getFares PROC
push ebx
push ecx

SpawnPassengerLoop:
mov eax, mazeWid - 4
call RandomRange
add eax, 2
mov ebx, eax

mov eax, mazeH - 4
call RandomRange
add eax, 2
mov ecx, eax

push ebx
mov eax, ecx
mov ebx, rowLeng
mul ebx
pop ebx
add eax, ebx

push ebx
mov ebx, OFFSET MazeRows
add ebx, eax
mov al, BYTE PTR [ebx]
pop ebx

cmp al, '#'
je SpawnPassengerLoop

mov eax, ebx
mov edx, ecx

pop ecx
pop ebx
ret
getFares ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

spawnMercs PROC
push eax
push ebx
push ecx
push edx

call getW140s
mov npc1X, eax
mov npc1Y, edx

call getW140s
mov npc2X, eax
mov npc2Y, edx

pop edx
pop ecx
pop ebx
pop eax
ret
spawnMercs ENDP

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
getW140s PROC
push ebx
push ecx

SpawnNPCLoop:
mov eax, mazeWid - 4
call RandomRange
add eax, 2
mov ebx, eax

mov eax, mazeH - 4
call RandomRange
add eax, 2
mov ecx, eax

push ebx
mov eax, ecx
mov ebx, rowLeng
mul ebx
pop ebx
add eax, ebx

push ebx
mov ebx, OFFSET MazeRows
add ebx, eax
mov al, BYTE PTR [ebx]
pop ebx

cmp al, '#'
je SpawnNPCLoop

mov eax, ebx
mov edx, ecx

pop ecx
pop ebx
ret
getW140s ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

spawnD PROC
push eax
push ebx
push edx

SpawnLoop:
mov eax, mazeWid - 4
call RandomRange
add eax, 2
mov dropPointX, eax
mov ebx, eax

mov eax, mazeH - 4
call RandomRange
add eax, 2
mov dropPointY, eax
mov edx, eax

push ebx
mov eax, edx
mov ebx, rowLeng
mul ebx
pop ebx
add eax, ebx

mov ebx, OFFSET MazeRows
add ebx, eax
mov cl, BYTE PTR [ebx]
cmp cl, '#'
je SpawnLoop

pop edx
pop ebx
pop eax
ret
spawnD ENDP

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

makePs PROC
push eax
    
mov eax, greenOW
call SetTextColor
    
cmp pass1Act, 1
jne SkipP1
mov dl, BYTE PTR p1X
mov dh, BYTE PTR p1Y
call Gotoxy
mov edx, OFFSET citizens
call WriteString
    
SkipP1:
cmp pass2Act, 1
jne SkipP2
mov dl, BYTE PTR p2X
mov dh, BYTE PTR p2Y
call Gotoxy
mov edx, OFFSET citizens
call WriteString
    
SkipP2:
cmp pass3Act, 1
jne SkipP3
mov dl, BYTE PTR p3X
mov dh, BYTE PTR p3Y
call Gotoxy
mov edx, OFFSET citizens
call WriteString
    
SkipP3:
cmp pass4Act, 1
jne SkipP4
mov dl, BYTE PTR p4X
mov dh, BYTE PTR p4Y
call Gotoxy
mov edx, OFFSET citizens
call WriteString
    
SkipP4:
cmp pass5Act, 1
jne SkipP5
mov dl, BYTE PTR p5X
mov dh, BYTE PTR p5Y
call Gotoxy
mov edx, OFFSET citizens
call WriteString
    
SkipP5:
mov eax, blackOW
call SetTextColor
    
pop eax
ret
makePs ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

makeDs PROC
push eax
    
mov eax, blueOW
call SetTextColor
    
mov dl, BYTE PTR dropPointX
mov dh, BYTE PTR dropPointY
call Gotoxy
mov edx, OFFSET dropPoint
call WriteString
    
mov eax, blackOW
call SetTextColor
    
pop eax
ret
makeDs ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

makeMercs PROC
push eax
    
mov eax, greyOW
call SetTextColor
    
mov dl, BYTE PTR npc1X
mov dh, BYTE PTR npc1Y
call Gotoxy
mov edx, OFFSET mercedes
call WriteString
    
mov dl, BYTE PTR npc2X
mov dh, BYTE PTR npc2Y
call Gotoxy
mov edx, OFFSET mercedes
call WriteString
    
mov eax, blackOW
call SetTextColor
    
pop eax
ret
makeMercs ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

checkCollide PROC
push eax
push ebx

mov eax, TaxiX
cmp eax, npc1X
jne CheckNPC2          
mov eax, TaxiY
cmp eax, npc1Y
jne CheckNPC2          
call crashInstance
jmp CollisionEnd

CheckNPC2:
mov eax, TaxiX
cmp eax, npc2X
jne CollisionEnd      
mov eax, TaxiY
cmp eax, npc2Y
jne CollisionEnd      
call crashInstance

CollisionEnd:
pop ebx
pop eax
ret
checkCollide ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

crashInstance PROC
push eax

; Deduct points based on taxi color
mov eax, taxiC
cmp eax, redOW
je RedCollision
cmp eax, yellowOW
je YellowCollision
jmp CollisionDone

RedCollision:
mov al, scoreAch
sub al, 3
cmp al, 0
jge StoreRedScore

mov al, 0
StoreRedScore:
mov scoreAch, al
call outputCollision
call UpdateDisplay
jmp CollisionDone

YellowCollision:
mov al, scoreAch
sub al, 2
cmp al, 0
jge StoreYellowScore

mov al, 0
StoreYellowScore:
mov scoreAch, al
call outputCollision
call UpdateDisplay

CollisionDone:
pop eax
ret
crashInstance ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

outputCollision PROC
push eax
push edx
mov dl, 0
mov dh, 23
call Gotoxy
mov eax, redOW
call SetTextColor
mov edx, OFFSET collisionMsg
call WriteString
mov ecx, 20
ClearCollisionLoop:
mov al, ' '
call WriteChar
loop ClearCollisionLoop
mov eax, blackOW
call SetTextColor
pop edx
pop eax
ret
outputCollision ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

drawPeugeot PROC    
push eax
mov eax, taxiC
call SetTextColor
pop eax
    
mov dl, BYTE PTR TaxiX 
mov dh, BYTE PTR TaxiY
call Gotoxy
    
mov edx, OFFSET peugeot
call WriteString
    
push eax
mov eax, blackOW
call SetTextColor
pop eax
ret
drawPeugeot ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

UpdateTaxi PROC
push eax
mov eax, blackOW
call SetTextColor
    
mov dl, BYTE PTR TaxiX
mov dh, BYTE PTR TaxiY
call Gotoxy
mov al, " "
call WriteChar
    
pop eax
ret
UpdateTaxi ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CheckPickupDropoff PROC
push eax
push ebx
push ecx
push edx

cmp hasPassenger, 1
je TryDropoff

cmp pass1Act, 1
jne CheckP2
mov eax, TaxiX
mov ebx, p1X
mov ecx, TaxiY
mov edx, p1Y
call proximity
cmp al, 1
jne CheckP2
mov pass1Act, 0
mov hasPassenger, 1
call serviceOneDone
call DisplayPickupMsg
jmp CheckDone

CheckP2:
cmp pass2Act, 1
jne CheckP3
mov eax, TaxiX
mov ebx, p2X
mov ecx, TaxiY
mov edx, p2Y
call proximity
cmp al, 1
jne CheckP3
mov pass2Act, 0
mov hasPassenger, 1
call serviceTwoDone
call DisplayPickupMsg
jmp CheckDone

CheckP3:
cmp pass3Act, 1
jne CheckP4
mov eax, TaxiX
mov ebx, p3X
mov ecx, TaxiY
mov edx, p3Y
call proximity
cmp al, 1
jne CheckP4
mov pass3Act, 0
mov hasPassenger, 1
call serviceThreeDone
call DisplayPickupMsg
jmp CheckDone

CheckP4:
cmp pass4Act, 1
jne CheckP5
mov eax, TaxiX
mov ebx, p4X
mov ecx, TaxiY
mov edx, p4Y
call proximity
cmp al, 1
jne CheckP5
mov pass4Act, 0
mov hasPassenger, 1
call serviceFourDone
call DisplayPickupMsg
jmp CheckDone

CheckP5:
cmp pass5Act, 1
jne CheckDone
mov eax, TaxiX
mov ebx, p5X
mov ecx, TaxiY
mov edx, p5Y
call proximity
cmp al, 1
jne CheckDone
mov pass5Act, 0
mov hasPassenger, 1
call serviceFiveDone
call DisplayPickupMsg
jmp CheckDone

TryDropoff:
mov eax, TaxiX
mov ebx, dropPointX
mov ecx, TaxiY
mov edx, dropPointY
call proximity
cmp al, 1
jne CheckDone
mov hasPassenger, 0
mov al, scoreAch
add al, 10
mov scoreAch, al
call DisplayDropoffMsg
call UpdateDisplay
call spawnD
call makeDs

CheckDone:
pop edx
pop ecx
pop ebx
pop eax
ret
CheckPickupDropoff ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

proximity PROC
push ebx
push ecx
push edx

sub eax, ebx
cmp eax, 0
jge AbsX
neg eax
AbsX:
cmp eax, 1
jg NotNearby

mov eax, ecx
sub eax, edx
cmp eax, 0
jge AbsY
neg eax
AbsY:
cmp eax, 1
jg NotNearby

mov al, 1
jmp proximityDone

NotNearby:
mov al, 0

proximityDone:
pop edx
pop ecx
pop ebx
ret
proximity ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

serviceOneDone PROC
push eax
mov eax, blackOW
call SetTextColor
mov dl, BYTE PTR p1X
mov dh, BYTE PTR p1Y
call Gotoxy
mov al, " "
call WriteChar
pop eax
ret
serviceOneDone ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

serviceTwoDone PROC
push eax
mov eax, blackOW
call SetTextColor
mov dl, BYTE PTR p2X
mov dh, BYTE PTR p2Y
call Gotoxy
mov al, " "
call WriteChar
pop eax
ret
serviceTwoDone ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

serviceThreeDone PROC
push eax
mov eax, blackOW
call SetTextColor
mov dl, BYTE PTR p3X
mov dh, BYTE PTR p3Y
call Gotoxy
mov al, " "
call WriteChar
pop eax
ret
serviceThreeDone ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

serviceFourDone PROC
push eax
mov eax, blackOW
call SetTextColor
mov dl, BYTE PTR p4X
mov dh, BYTE PTR p4Y
call Gotoxy
mov al, " "
call WriteChar
pop eax
ret
serviceFourDone ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

serviceFiveDone PROC
push eax
mov eax, blackOW
call SetTextColor
mov dl, BYTE PTR p5X
mov dh, BYTE PTR p5Y
call Gotoxy
mov al, " "
call WriteChar
pop eax
ret
serviceFiveDone ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DisplayPickupMsg PROC
push eax
push edx
mov dl, 0
mov dh, 23
call Gotoxy
mov eax, greenOW
call SetTextColor
mov edx, OFFSET pickupMsg
call WriteString
mov ecx, 10
ClearPickupLoop:
mov al, ' '
call WriteChar
loop ClearPickupLoop
mov eax, blackOW
call SetTextColor
pop edx
pop eax
ret
DisplayPickupMsg ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DisplayDropoffMsg PROC
push eax
push edx
mov dl, 0
mov dh, 23
call Gotoxy
mov eax, blueOW
call SetTextColor
mov edx, OFFSET dropoffMsg
call WriteString
mov ecx, 10
ClearDropoffLoop:
mov al, ' '
call WriteChar
loop ClearDropoffLoop
mov eax, blackOW
call SetTextColor
pop edx
pop eax
ret
DisplayDropoffMsg ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ProcessMove PROC
    
CheckMove:
mov eax, TaxiX
add eax, esi         ; esi and edi already contain the direction differences
mov edx, TaxiY
add edx, edi
    
cmp eax, 1
jl InvalidMove
cmp eax, mazeWid - 2
jg InvalidMove
cmp edx, 1
jl InvalidMove
cmp edx, mazeH - 2
jg InvalidMove
    
push eax
push edx
    
push eax
mov eax, edx
mov ebx, rowLeng
mul ebx
pop ebx
add eax, ebx
    
mov ebx, OFFSET MazeRows
add ebx, eax
mov cl, BYTE PTR [ebx]
cmp cl, '#'
je InvalidMove
    
call UpdateTaxi
    
pop edx
pop eax
mov TaxiX, eax
mov TaxiY, edx
    
call makePs
call makeMercs
call makeDs
call drawPeugeot
call checkCollide

jmp ProcessMove_End

InvalidMove:
pop edx
pop eax
    
ProcessMove_End:
ret
ProcessMove ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

UpdateDisplay PROC
push eax
push edx
    
push eax
mov eax, blackOW
call SetTextColor
    
mov dl, 8
mov dh, 21
call Gotoxy
mov eax, 0
mov al, scoreAch
call WriteDec
    
mov al, ' '
call WriteChar
call WriteChar

cmp isEndless, 1
je SkipTimerUpd
    
mov dl, 16
mov dh, 22
call Gotoxy
mov eax, 0
mov al, timeOutput
call WriteDec
    
mov al, ' '
call WriteChar
call WriteChar
call WriteChar

SkipTimerUpd:
    
pop eax
call SetTextColor
    
pop edx
pop eax
ret
UpdateDisplay ENDP

END main