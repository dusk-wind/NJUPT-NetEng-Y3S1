CODE SEGMENT
          ASSUME  CS:CODE
BEG: MOV DL, 1
        MOV AH, 2
        INT 21H       
        MOV AH, 4CH
        INT 21H
;------------------------------
CODE ENDS
          END BEG 