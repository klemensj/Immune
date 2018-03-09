globals [death-rate reg-repro antibody-movement infected active-color antibody-effectiveness antigen-load vaccine-load]
     ; death-rate = chance of the turtle dying
     ; antibody-movement = how many spaces the antibody has moved
     ; reg-repro = the chance a lymphocyte will reproduce when it is not active or a memory cell
     ; infected = records whether antigens have been inputted
     ; the color of the lymphocyte that responds to the antigen
breed [lymphocytes lymphocyte]  ; creating a set of lymphocytes
breed [antigens antigen]        ; creating a set of antigens
breed [antibodies antibody]     ; creating a set of antibodies
breed [measles measle]          ; creating special measles antigen
breed [vaccines vaccine]        ; creating special vaccine antigen
lymphocytes-own [active active-time reproduction-rate memory]
     ; active = whether the cell is active ( 0 is no ; 1 is yes )
     ; active-time = how much time left the cell has to be active
     ; reproduction-rate = how fast the cell reproduces
antibodies-own [energy]
     ; energy = how many ticks the antibody has left to live
measles-own [measles-duration]
vaccines-own [vaccine-duration]

to setup
  clear-all
  clear-output
  ask patches [ set pcolor white]
  set infected 0      ; at setup, the system is not infected with any antigens
  set death-rate 15   ; values fit to give best response
  set reg-repro 15
  set active-color one-of base-colors        ;set active color to a random lymphocyte color
  set-default-shape lymphocytes "circle"     ; lymphocytes are circles
  set-default-shape antigens "monster"       ; antigens are monsters
  set-default-shape measles "monster"        ; measles are monsters, big red ones
  set-default-shape vaccines "monster"       ; vaccines are greyed-out monsters
  set-default-shape antibodies "Y"           ; antibodies are Y-shaped

  set antibody-effectiveness "low"     ;; for "simple" version for in class demos, reduce visual clutter
  set antigen-load 50                  ;; for "simple" version for in class demos
   set vaccine-load 200                ;; for "simple" version for in class demos



  create-lymphocytes 250  ; create the lymphocytes, then initialize their variables
  [
    set color one-of base-colors
    set active 0 ; all lymphocytes are initially inactive
    set active-time -1
    set reproduction-rate reg-repro ; all lymphocytes are initially inactive, so reproduce at regular rate
    set size 1.5  ; easier to see
    set label-color blue - 2
    setxy random-xcor random-ycor
    set memory 0
  ]
  reset-ticks
end

to go
  if not any? turtles [ stop ]
  replace-extinct
  ask antigens[
    move
    antigen-reproduce
  ]
  ask lymphocytes [
    bind
    activated
    move
    reproduce
    lymph-death
  ]
  ask antibodies [
    antibody-move
    set energy energy - 1
    antibody-death
  ]
  measles-death
  vaccine-death
  antigen-extinct
  tick
 end

to replace-extinct           ; this is a "rescue effect", if any lymphocyte types (colors) go extinct we add one more to the population
  let counter 5
  while [counter < 140]      ; check all the colors
  [
    if count lymphocytes with [color = counter] = 0
  [
      create-lymphocytes 1  ; create the replacement lymphocyte, then initialize its variables
      [
        set color counter
        set active-time -1
        set active 0
        set reproduction-rate reg-repro
        set size 1.5
        set label-color blue - 2
        setxy random-xcor random-ycor
        ask n-of 1 lymphocytes [ die ]   ; kill a random lympohcyte to make up for the replacement
      ]
  ]
  set counter counter + 10
]
end

to move  ; antigen and lymphocyte procedure
  rt random 50
  lt random 50
  fd 1
end

to antigen-reproduce
   if random 100 < 20 and color != grey   ;; and statement keeps grey "vaccine antigens" from reproducing
    [
      hatch 1 [ rt random 360 fd 1]
    ]
end

to bind                                          ; active-color lymphocytes are activated by the antigen
 if color = active-color[
   if (one-of antigens in-radius 1 != nobody) or (one-of vaccines in-radius 1 != nobody)
   [
     set active 1
     set active-time 10   ;; length of typical cell lifespan if death rate is 10
   ]
  ]
end

to activated
  if active-time = 0                                 ; kills activated after time is up
    [
       die
      ]

  if active = 1
  [
    set reproduction-rate (reproduction-multiplier-when-active * reg-repro) ; start rapid reproduction
    set size 2               ; increase size
    set shape "bold-circle"  ; outline circle
    hatch-antibodies 2       ; create antibodies
    [
      set color black
      rt random-float 360 fd 1  ; randomly pick a direction and move forward
      if antibody-effectiveness = "high"
      [
          set energy 8
      ]

      if antibody-effectiveness = "low"
      [
        set energy 4 ; for antibodies, energy tracks how many ticks the antibodies have left to live
      ]
    ]
   set active-time active-time - 1    ;; counts back down to inactivity
  ]
end

to reproduce  ; determine if the lymphocyte reproduces

 if random 100 < reproduction-rate
  [ ifelse memory = 1
    [
      hatch 1 [
        set shape "M-circle"
        rt random-float 360 fd 1]
    ]
    [
       ifelse active = 1 ; if active, produce both a memory cell and an active cell ; else, produce regular cell
        [
                  hatch-lymphocytes 1 [ set shape "M-circle"
                  set color active-color
                  set active 0
                  set reproduction-rate 2
                  set size 2.5  ; easier to see
                  set label-color blue - 2
                  set memory 1
                  rt random-float 360 fd 1 ]

                  hatch 1 [ rt random-float 360 fd 1]
        ]
        [
            ifelse count lymphocytes < 400
               [
                        hatch 2 [ rt random-float 360 fd 1]
               ]
                [
                        hatch 1 [ rt random-float 360 fd 1]
                 ]
        ]
    ]
  ]
end

to lymph-death  ; determine if the lymphocyte dies
  if memory = 0 and random 100 < death-rate  ; and active = 0
      [
        die
      ]
  if memory = 1 and random 100 < 2
  [
    die
  ]
end

to antibody-move  ; the speed (distance moved each time step) ends up being a measure of potency of each activated cell
  set antibody-movement 0
  if antibody-effectiveness = "high"
  [
     while [antibody-movement < 10]
     [fd 1
     kill-antigen  ; check to see if it is on the same spot as an antigen and if so, kill it
     set antibody-movement antibody-movement + 1
     ]
  ]

  if antibody-effectiveness = "low"
  [
     while [antibody-movement < 5]
     [fd 1
     kill-antigen
     set antibody-movement antibody-movement + 1
     ]
  ]
end

to antibody-death
  if energy < 1
  [ die ]
end

to kill-antigen
  let prey one-of antigens-here
  if prey != nobody
  [ask prey[die]]
end

to measles-death
  ask measles
  [
    if measles-duration < 1
     [  die  ]
     set measles-duration measles-duration - 1
  ]
end

to vaccine-death
  ask vaccines
  [
    move
    if vaccine-duration < 1 [die]
    set vaccine-duration vaccine-duration - 1
  ]
end

to antigen-extinct
  if (count antigens = 0) and (infected = 1)
  [
     output-type "antigen clearance time "  output-print ticks
    set infected 0
  ]
end

to insert-antigens                               ; create an infection every button push
  output-type "antigen infection time "  output-print ticks
  set infected 1 ; noting that antigens have been put into the cell
    create-antigens antigen-load
    [
     set color black
     set size 2  ; easier to see
     set label-color blue - 2
     setxy random-xcor random-ycor
    ]

end

to infect-measles
  output-type "measles infection time "  output-print ticks
   create-measles 1
    [
     set color red
     set size 50
     set label-color blue - 2
     setxy 0 0
     set measles-duration 5
    ]

  ask lymphocytes
      [
        if random 100 < 95
        [ die ]
      ]

end

to insert-vaccine
  output-type "vaccine injection time "  output-print ticks
  create-vaccines vaccine-load
    [
     set color grey
     set size 2  ; easier to see
     set label-color blue - 2
     setxy random-xcor random-ycor
     set vaccine-duration 10
    ]
end
@#$#@#$#@
GRAPHICS-WINDOW
786
10
1274
499
-1
-1
9.412
1
14
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
30.0

BUTTON
4
10
81
43
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
81
51
185
110
go/pause
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
281
12
695
263
Lymphocyte populations
time
pop.
0.0
100.0
0.0
100.0
true
false
"" ""
PENS
"pen5" 1.0 0 -7500403 true "" "plot count lymphocytes with [color = 5]"
"pen-1" 1.0 0 -2674135 true "" "plot count lymphocytes with [color = 15]"
"pen-2" 1.0 0 -955883 true "" "plot count lymphocytes with [color = 25]"
"pen-3" 1.0 0 -6459832 true "" "plot count lymphocytes with [color = 35]"
"pen-4" 1.0 0 -1184463 true "" "plot count lymphocytes with [color = 45]"
"pen-5" 1.0 0 -10899396 true "" "plot count lymphocytes with [color = 55]"
"pen-6" 1.0 0 -13840069 true "" "plot count lymphocytes with [color = 65]"
"pen-7" 1.0 0 -14835848 true "" "plot count lymphocytes with [color = 75]"
"pen-8" 1.0 0 -11221820 true "" "plot count lymphocytes with [color = 85]"
"pen-9" 1.0 0 -13791810 true "" "plot count lymphocytes with [color = 95]"
"pen-10" 1.0 0 -13345367 true "" "plot count lymphocytes with [color = 105]"
"pen-11" 1.0 0 -8630108 true "" "plot count lymphocytes with [color = 115]"
"pen-12" 1.0 0 -5825686 true "" "plot count lymphocytes with [color = 125]"
"pen-13" 1.0 0 -2064490 true "" "plot count lymphocytes with [color = 135]"

PLOT
280
265
695
446
Antibody Population
time
pop.
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"antibodies" 1.0 0 -16777216 true "" "plot count antibodies"

PLOT
280
449
696
638
Antigen Population
time
pop.
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"antigens" 1.0 0 -16777216 true "" "plot count antigens"

BUTTON
94
206
174
246
MEASLES
infect-measles
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
18
370
253
565
13

SLIDER
15
273
255
306
reproduction-multiplier-when-active
reproduction-multiplier-when-active
2
5
3.0
0.5
1
NIL
HORIZONTAL

BUTTON
95
120
174
160
ANTIGENS
insert-antigens
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
94
163
173
203
VACCINE
insert-vaccine
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
20
347
170
365
Output Window:
12
0.0
1

@#$#@#$#@
## WHAT IS IT?

This model is designed to demonstrate the process by which adaptive immunity arises as a result of clonal selection on B-lymphocytes. The model also includes functions for simulating vaccination and the loss of adaptive immunity provoked by measles infection. It is intended to be used as an active learning activity in a college or high-school biology course.

## HOW IT WORKS

The model consists of five classes of agents: Lymphocytes, Antigens, Antibodies, Vaccine particles, and a Measles pathogen. 

### Lymphocytes 

Lympohcytes in the model represent B-lymphocytes, and are depicted by "circle" turtle shapes.
 
 * The diversity of of lymphocyte colors included in the model corresponds to diversity of B-lymphocte clones within the immune system - lymphocytes with different antigen receptors.
 * Yellow lymphocytes possess antigen receptors specific to the antigen
 * Lymphocytes move randomly around the world
 * Lymphocytes have equal birth and death rates. Birth and death are calculated probabastically for each lymphocyte at each time step, such that the population of each clone will exhibit stochastic variation (a random walk)
 * There is a "rescue effect" in place for each lymphocyte clone, so if one color goes extinct two more lymphocytes of that color will be added to the world

### Antigens 

Antigens are any foreign body that causes an immune response, in this model they are assumed to be pathogenic organisms or viruses that are capable of reproducing. They are depicted by black "monster" turtle shapes. 

 *  Antigens are introduced by the antigen button, which will introduce the number specified by the antigen-load slider
 * Lymphocytes move randomly around the world
 * Antigens reproduce probabalistically each time step
 * Antigens only die when they come into contact with an antibody

### Antigen-Lymphocyte interactions

When an antigen and a yellow lymphocyte occupy the same or adjacent patches in the model the lymphocyte becomes activated. Activated lympohcytes are depicted by the custom "bold-circle" turtle shape, which is the same as a lymphocyte but with a bold black outline.  Activated lymphocytes increase their reproduction rate by a factor determined by the user.

![Blymphocyte developmental stages lymphocytes](file:///Users/klemensj/Dropbox/Projects/Immune%20system%20model/Images/Lymphocytes.png)

In the immune system, activated lymphocytes then further develop into two types of cells. Memory lymphocytes are depicted with the custom "m-circle" turtle shape, which is the same as lympocyte but bearing the letter "M". Memory lymphocytes are long-lived cells, and in the model their birth and death rates are set to an order of magnitude lower than those of typical lymphocytes. 

The other cell type is the plasma cell (the effector cell of the B-lympohcyte). The logic of the model does not distinguish between plasma cells and activated lymphocytes. The short-lived plasma cells produce antibodies for the duration of their activiation, and then die.     

### Antibodies

Antibodies are produced by activated lymphocytes. 

 * Lymphocytes move in a straight line in a random direction away from the activated lympohcyte
 * Antibodies live for a fixed time and then die
 * If an antibody and an antigen occupy the same space patch at any time, the antigen dies
 * Antibodies effectiveness can be adjusted with the "XXX" switch. In the high setting, antibodies travel "XXX" patches each time step and live for "XXX" timesteps, while in the low setting, antibodies travel "XXX" patches each time step and live for "XXX" timesteps.

### Vaccines

Vaccines function by stimulating a secondary immune response, often using killed or inactivated viral particles. Vaccine particles are depicted by grey "monster" turtle shapes. Pushing the vaccine button introduces a number of vaccine particles determined by the "vaccine load" slider. 

 * Vaccine particles do not reproduce
 * Vaccine particles persist for "XXX" time steps and then die
 * Antibodies have no effect on vaccine particles
 * Vaccine particles do not count towards the values shown in the antigen plot
 * Lymphocytes respond to the vaccine particles in the same way as they respond to an antigen, producing activated lymphocytes, memory cells, and antibodies

### Measles

To be written - Measles induced immunosupression demonstration.


## HOW TO USE IT

### The "setup" and <b>"go/pause"</b> buttons 

<b>setup</b> clears all data and start a new simulation. Setup will create a population of 500 lymphocytes representing 14 different <i>clones</i> - or lymphocytes that have the same antigen receptors. <b>go/pause</b> will begin the simulation. Without any other input, each lymphocyte population will undergo a random walk that will be different each time you run the model. Pressing the <b>go/pause</b> button during the simulation will pause the simulation. Other buttons are active at this time, so the user could, for example, pause the simulation, press the <b>VACCINES</b> button, and then restart the simulation from that point with the vaccine particles now introduced. 

### antibody-effectiveness  

A swith that controls how effective antibodies are at clearing infections. In the <b>low</b> position antibodies move 3 spaces per round, and last for 4 rounds before dying. In the <b>high</b> position, antibodies move 10 spaces per round and last for 8 rounds. You should start with antibody-effectiveness it in the low position.

### antigen-load

A slider that determines the number of antigens that are added to the system each time the <b>ANTIGENS</b> button is pressed.

### vaccine-load

A slider that determines the number of vaccine particles are added to the system each time the <b>VACCINE</b> button is pressed.

### reproduction-multiplier-when-active

Lymphocytes have a default 10% probability of reproducing or dying at any time step. When activated, the reproductive rate (but not the death rate) will be increased by a factor determined by this slider. 
Example: when this slider is set to 3.0, the reproductive rate will triple.

### ANTIGENS button

Pressing the <b>ANTIGENS</b> button at any point during the simulation introduces antigens to the system. The time at which the antigen infection occurs will be recorded in the <b>Output Window</b>. When the population of antigens has been reduced to 0 by the antibodies, the time will be recorded as the "clearance time" in the  <b>Output Window</b>.

### VACCINE button

Pressing the <b>VACCINE</b> button at any point during the simulation will introduce the vaccine particles to the system. The time at which the vaccine is introduced will be recorded in the <b>Output Window</b>. Pressing the vaccine button when there is already a very large population of memory cells may lead to slow run times due to the very large number of antibodies that are likely to be generated. 

### MEASLES button

Pressing the <b>MEASLES</b> button will introduce a measles infection, which will cause 95% of the lympocytes in the simulation, selected randomly across all clones, to die immediately. A large red measles monster will appear for 5 time steps once the measles button is pressed; this turtle does not interact with any of the other agents in the simulation. The time at which the measles infection is introduced will be recorded in the <b>Output Window</b>

## THINGS TO NOTICE

Your textbook probably demonstrates secondary immunity with something that looks like this:

![Antibody production in primary and secondary response](file:///Users/klemensj/Dropbox/Projects/Immune%20system%20model/Images/Antibody_curve.png)

Make sure to pay attention to the Y axis, which is variable on the antigen graphs when comparing model runs. 

The timing of certain events (infection, vaccination, measles) are recorded in the output area of the model. 

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the  Mention here and link detailed asignment once written.  model)

## EXTENDING THE MODEL

A curve smoothing function for the plots might help students compare the graphs generated with conceptual versions presented in textbooks. 

The model does not include the distinction between IgG and IgM antibodies, which could easily be modelled in Netlogo. This was intentional to keep the model focused on the process of clonal selection. 

In the immune system the dynamics of memory cell generation depend on activated cells forming "germinal centers" that produce XXX

A more spatially explicit and accurate view of the immune system would distinguish between dynamics in secondary "  XXX " such as lymph nodes, where lymphocytes XXX and the fact that antibody antigen interactoins released into the blood and lymph. 



## CREDITS AND REFERENCES

Thanks to Diana Cundell for reviewing the model. Madeline Conway helped generate the figures included in this Info document. 

### References

(Mina, Metcalf, Swart, Osterhaus, & Grenfell, 2015)

Doucleff, M. (2015, May 7). Scientists Crack A 50-Year-Old Mystery About The Measles Vaccine. Retrieved August 3, 2017, from http://www.npr.org/sections/goatsandsoda/2015/05/07/404963436/scientists-crack-a-50-year-old-mystery-about-the-measles-vaccine

Mina, M. J., Metcalf, C. J. E., Swart, R. L. de, Osterhaus, A. D. M. E., & Grenfell, B. T. (2015). Long-term measles-induced immunomodulation increases overall childhood infectious disease mortality. Science, 348(6235), 694–699. https://doi.org/10.1126/science.aaa3662





## HOW TO CITE

Adaptive Immunity 1.0 Created by Sarah Gift and Jeffrey A. Klemens

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Gift, S. and J.A. Klemens. (2017). Netlogo Adaptive Immunity Model 1.0. <<url>>. 

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

XXX is there value to a creative commons license here?
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

bold-circle
false
0
Circle -16777216 true false 0 0 300
Circle -7500403 true true 30 30 240

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

m-circle
true
0
Circle -7500403 true true 45 45 210
Polygon -16777216 true false 120 120 120 180 135 180 135 120 120 120
Polygon -16777216 true false 135 120 150 135 150 150 135 135
Polygon -16777216 true false 150 135 165 120 165 135 150 150
Polygon -16777216 true false 165 120 180 120 180 180 165 180

monster
false
0
Polygon -7500403 true true 75 150 90 195 210 195 225 150 255 120 255 45 180 0 120 0 45 45 45 120
Circle -16777216 true false 165 60 60
Circle -16777216 true false 75 60 60
Polygon -7500403 true true 225 150 285 195 285 285 255 300 255 210 180 165
Polygon -7500403 true true 75 150 15 195 15 285 45 300 45 210 120 165
Polygon -7500403 true true 210 210 225 285 195 285 165 165
Polygon -7500403 true true 90 210 75 285 105 285 135 165
Rectangle -7500403 true true 135 165 165 270

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

y
true
0
Line -7500403 true 60 60 150 150
Line -7500403 true 150 150 225 60
Line -7500403 true 150 150 150 255
@#$#@#$#@
NetLogo 6.0.1
@#$#@#$#@
set grass? true
setup
repeat 75 [ go ]
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
