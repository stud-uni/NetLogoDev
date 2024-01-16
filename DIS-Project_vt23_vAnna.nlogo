; DIS-Project_vt23 (temporary name-please find a better one!!)
; test of a change to see if this works with github
;
;
;
; Version History: (set date, changes and by whom everytime you add or change something)
; 2023-04-10 Initial Template by Gion K Svedberg (gks)
; 2023-04-13 Added belief can-work, Group 8 (Ingvar Pétursson, Hampus Oxenholt, Adam Makowski)
; 2023-04-14 Added update time function, Group 8 (Ingvar Pétursson, Hampus Oxenholt, Adam Makowski)
; 2023-04-27 Added template beliefs, Group 8 (Ingvar Pétursson, Hampus Oxenholt, Adam Makowski)
; 2023-05-11 Added town-square-matrix in setup and matrix in extension, Group 7(Anton Satow, Zainab Alfredji, Ted Ljungsten)
; 2023-05-18 Group10 (Felix B, Lucas H, Johan Ay)
; - Added method find-frustrated
; - Added settings for flagManger in update-time-flags


; ************ INCLUDED FILES *****************
__includes [
    "ODD.nls" ; contains all the the breeds of the agents, with the global and local variables. Use this file as the ODD (Overview, Design concepts and Details) protocol to syncronize the development
    "bdimod.nls" ; modified version of the BDI (beliefs, desires, intentions) -extension. Allows certain intentions to pass values along
    "communicationmod.nls" ; describe
    "setupenvironment.nls" ; setup-functions for setting up the environment with houses town-square, work-places, prison, police-station, restaurants, ....
    "setupagents.nls"; creates the agents with their setup initializations
    "citizens.nls"
    "cops.nls"
]
; ********************end included files ********

; ************ EXTENSIONS *****************
extensions [
; vid ; used for recording of the simulation
; array ; uncomment if you need to use arrays
; table ; uncomment if you need to use tables
 matrix ; uncomment if you need to use matrices
]
; ********************end extensions ********


; ******************* SETUP PART *****************
; setup of the environment, the different agents and time
to setup
  clear-all

  ; Set all global variables
  set factory-workers-current-max 10

  setup-agents ; setup of citizen and cop - agents
  setup-environment ; setup of houses, town-square, work-places, prison, police-station, restaurants, but also environment variables, such as time, ....
  set town-square-matrix matrix:make-constant 3 3 0

  ; set-up of debug flags
  set debug-general true
  set debug-time true ; Prints the time in the terminal
  ;set debug-xxx true ; specific debug flags, replace xxx with a specifier

  ; must be last in the setup-part:
  reset-ticks
  ;setup-plots
end

; **************************end setup part *******


; ******************* TO GO/ STARTING PART ********
;;
to go
  ;---- Basic functions, like setting the time
  ;
  update-time-flags ;- update time
  clear-links

  ;---- Agents to-go part -------------
  ; Cyclic execution of what the agents are supposed to do
  ; Trying to implement a Hybrid-Agent architecture with a ractive part running the intentions on
  ; the intention stack and the proactive part with a deliberation of states based on beliefs
  ;
  ask turtles [
    ; Reactive part based on the type of agent
    if (breed = citizens) [
      process-citizen-msg
      perceive-citizen-env
      ]
    if (breed = cops) [
      process-cop-msg
      perceive-cop-env
      ]
    ; Execute all of the intentions on the intention-stack as reactive behaviors
    while [not empty? intentions] [execute-intentions] ; while loop that executes all of the intentions on the stack, make sure intentions are removed from stack!

    ; Proactive part based on finite state machine, contained in the include-files "citizens.nls" and "cops.nls"
    run current_state
    ; test if the following loop is needed or not
    ; while [not empty? intentions] [execute-intentions] ; while loop that executes all of the intentions on the stack
    set current_state next_state
  ]

end ; - to go part


to update-time-flags
  ; The time is measured in ticks where one tick is an hour.
  ; The time is tracked in the time variable and this variable is
  ; reset every week (or every 168 hours).

  ; Increase time one step
  tick

  ; Set the time
  set time (time + 1)
  set time time mod 168

  ; -------------------- ADDED FOR TASK 8.11 /GROUP 10 ----------------
  if time = 0 [
    ask citizens [
      set flagManager 0
      ;DEBUG print
      ;print("RESETING MANAGERS")
      if ( exist-beliefs-of-type "manager" ) and (( belief-content read-first-belief-of-type "manager" ) = true )[
        remove-belief read-first-belief-of-type "manager"
        set color white
      ]
    ]

  ]
  ; -------------------------------------------------------------------

  ; Determine if it is morning, evening or weekend
  let hour-of-day time mod 24

  ifelse (6 <= hour-of-day and hour-of-day <= 10)[
    set flagMorning true
  ] [
  set flagMorning false
  ]



  ; Check if it is evening
  ifelse (16 <= hour-of-day and hour-of-day <= 22)[
    set flagEvening true
  ; -------------------- ADDED FOR TASK 8.11 /GROUP 10 ----------------
    if flagManager = 0 and (time >= 110)[
      ;print("PRE-FINDING")
      set flagManager 1
      find-frustrated
    ]
  ; -------------------------------------------------------------------

  ] [
    set flagEvening false
  ]

  ; Check if it is weekend
  ifelse (time >= 120) [
    set flagWeekend true
  ] [
    set flagWeekend false
  ]

  if debug-time = true [
    print word "Time: " time
  ]
end


; -------------------- ADDED FOR TASK 8.11 /GROUP 10 ----------------
; Finds the 3 most frustrated citizens and gives them the belief of being managers of demonstrations (task 8.11)
to find-frustrated
  ;print("ENTERED FINDER")
  let angryValue []
  let angryId []
  let value 0
  ask citizens[
    let angryVal frustration ;belief-content read-first-belief-of-type "Frust"
    set angryValue lput angryVal angryValue
    set angryValue sort angryValue
    set angryValue reverse angryValue
  ]
  let index 0
  while [ index < 3 ] [
    set value item index angryValue
    ask citizens[
      let angryVal frustration ;belief-content read-first-belief-of-type "Frust"
      if angryVal = value [
        let id [who] of self
        set angryId lput id angryId
        ask turtle id [
          add-belief create-belief "manager" true
          print (word who ": i am a manager." )
          set color red]
      ]
    ]
    set index index + 1
  ]
  set angryValue []
  set angryId []
end
; -------------------------------------------------------------------
@#$#@#$#@
GRAPHICS-WINDOW
225
15
1404
618
-1
-1
17.48
1
10
1
1
1
0
1
1
1
0
66
0
33
0
0
1
ticks
30.0

SWITCH
23
169
156
202
show-intentions
show-intentions
1
1
-1000

SLIDER
23
81
211
114
num-agents
num-agents
5
100
100.0
1
1
NIL
HORIZONTAL

BUTTON
23
25
86
58
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
147
25
210
58
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
23
213
156
246
show_messages
show_messages
1
1
-1000

SWITCH
22
256
156
289
show_beliefs
show_beliefs
1
1
-1000

SWITCH
22
298
155
331
show_lines
show_lines
1
1
-1000

SLIDER
23
121
211
154
perc-cops
perc-cops
0
90
6.0
1
1
NIL
HORIZONTAL

SWITCH
22
343
155
376
showPatchLabels
showPatchLabels
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person police
false
0
Polygon -1 true false 124 91 150 165 178 91
Polygon -13345367 true false 134 91 149 106 134 181 149 196 164 181 149 106 164 91
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -13345367 true false 120 90 105 90 60 195 90 210 116 158 120 195 180 195 184 158 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Polygon -13345367 true false 150 26 110 41 97 29 137 -1 158 6 185 0 201 6 196 23 204 34 180 33
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Rectangle -16777216 true false 109 183 124 227
Rectangle -16777216 true false 176 183 195 205
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Polygon -1184463 true false 172 112 191 112 185 133 179 133
Polygon -1184463 true false 175 6 194 6 189 21 180 21
Line -1184463 false 149 24 197 24
Rectangle -16777216 true false 101 177 122 187
Rectangle -16777216 true false 179 164 183 186

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
