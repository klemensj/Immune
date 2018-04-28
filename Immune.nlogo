globals [death-rate reg-repro antibody-movement infected active-color]
     ; death-rate = chance of the turtle dying
     ; antibody-movement = how many spaces the antibody has moved
     ; reg-repro = the chance a lymphocyte will reproduce when it is not active or a memory cell
     ; infected = records whether antigens have been inputted
     ; active-color = the color of the lymphocyte that responds to the antigen
breed [lymphocytes lymphocyte]  ; creating a set of lymphocytes
breed [antigens antigen]        ; creating a set of antigens
breed [antibodies antibody]     ; creating a set of antibodies
breed [measles measle]          ; creating special measles antigen
breed [vaccines vaccine]        ; creating special vaccine antigen
lymphocytes-own [active active-time reproduction-rate memory]
     ; active = whether the cell is active ( 0 is no ; 1 is yes )
     ; active-time = how much time left the cell has to be active
     ; reproduction-rate = how fast the cell reproduces
     ; memory = records whether the lymphocyte is a memory cell (0 is no ; 1 is yes)
antibodies-own [energy]
     ; energy = how many ticks the antibody has left to live
measles-own [measles-duration]
vaccines-own [vaccine-duration]
     ; vaccine-duration = for how many ticks will the vaccines persist in the system

to setup
  clear-all
  clear-output
  ask patches [set pcolor white]
  set infected 0      ; at setup, the system is not infected with any antigens
  set death-rate 15   ; values fit to give best response, no inherent meaning to these rates
  set reg-repro 15
  set active-color one-of base-colors        ;set active color to a random lymphocyte color
  set-default-shape lymphocytes "circle"     ; lymphocytes are circles
  set-default-shape antigens "monster"       ; antigens are monsters
  set-default-shape measles "monster"        ; measles are monsters, big red ones
  set-default-shape vaccines "monster"       ; vaccines are greyed-out monsters
  set-default-shape antibodies "Y"           ; antibodies are Y-shaped
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
            ifelse count lymphocytes < 235
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
  if memory = 0 and random 100 < death-rate
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
613
10
1101
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
11
10
88
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
90
10
170
43
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
273
10
596
172
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
273
176
596
335
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
273
339
597
497
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
181
231
265
271
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
11
299
264
432
13

SLIDER
10
113
265
146
antigen-load
antigen-load
5
100
50.0
5
1
NIL
HORIZONTAL

SLIDER
11
192
266
225
reproduction-multiplier-when-active
reproduction-multiplier-when-active
1
5
3.0
0.5
1
NIL
HORIZONTAL

BUTTON
11
231
90
271
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

SLIDER
11
153
266
186
vaccine-load
vaccine-load
5
400
200.0
5
1
NIL
HORIZONTAL

BUTTON
92
231
179
271
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

CHOOSER
11
62
177
107
antibody-effectiveness
antibody-effectiveness
"low" "high"
0

TEXTBOX
11
284
161
302
Output Window:
12
0.0
1

@#$#@#$#@
## WHAT IS IT?

This model is designed to demonstrate the process by which adaptive immunity arises as a result of clonal selection. The model also includes functions for simulating the dynamics of vaccination and the loss of adaptive immunity provoked by measles infection. It is intended to be used as an active learning activity in a college or high-school biology course.

## HOW IT WORKS

The model consists of five classes of agents: Lymphocytes, Antigens, Antibodies, Vaccine particles, and a Measles pathogen. 

### Lymphocytes 

Lympohcytes in the model represent B-lymphocytes, and are depicted by `circle` turtle shapes.
 
 * The diversity of lymphocyte colors included in the model corresponds to the diversity of B-lymphocte clones, or lymphocytes that bear the same antigen receptors, within the system. Each clone is represented by one of the 14 `base-colors` in Netlogo.
 * Each time that **setup** is run, one color of lymphocytes is randomly selected to be the active color. The active color lymphocyte possesses antigen receptors specific to the antigen that will be introduced in this model run.
 * Lymphocytes move randomly around the world, which represents a human body.
 * Lymphocytes have equal birth and death rates. Births and deaths are calculated probabastically for each lymphocyte each tick, such that the population of each clone will exhibit stochastic variation (a random walk).
 * There is a "rescue effect" in place for each lymphocyte color, so if one color goes extinct another lymphocytes of that color will be added to the world and a random lymphocyte will be killed to offset it.
 * If the total population of lympohcytes falls below 235 the reproduction rate will temporarily be doubled until the lymphocyte total returns to 250.

### Antigens 

Antigens are any foreign body that causes an immune response. In this model they are assumed to be pathogenic organisms or viruses that are capable of reproducing. They are depicted by black `monster` turtle shapes. 

 *  Antigens are introduced into the world by the **ANTIGENS** button. The number of antigens introduced is determined by the **antigen-load** slider.
 * Antigens move randomly around the world.
 * Antigens reproduce probabalistically each tick.
 * Antigens only die when they come into contact with an antibody.

### Antigen-Lymphocyte interactions

When an antigen and a lymphocyte of the active color occupy the same or adjacent patches in the model the lymphocyte becomes activated. Activated lympohcytes are depicted by the custom `bold-circle` turtle shape (same as a lymphocyte but with a bold black outline).  Activated lymphocytes increase their reproduction rate by a factor determined by the user.

![B lymphocyte developmental stages ](https://raw.githubusercontent.com/klemensj/Immune/master/Images/Lymphocytes.png)

In the immune system, activated lymphocytes then further develop into two types of cells:

  * Memory lymphocytes are depicted with the custom `M-circle` turtle shape, which is the same as lympocyte but bearing the letter "M". Memory lymphocytes are relatively long-lived cells. In the model their birth and death rates are set to an order of magnitude lower than those of typical lymphocytes. 

 * Plasma cells (the effector cell of the B-lympohcyte) are short-lived. Plasma cells produce antibodies for the duration of their activiation, and then die.     

### Antibodies

Antibodies are produced by activated lymphocytes. 

 * Antibodies move in a straight line in a random direction away from the activated lympohcyte.
 * Antibodies live for a fixed time and then die.
 * If an antibody and an antigen occupy the same space patch at any time, the antigen dies.
 * Antibodies' effectiveness in clearing antigens can be adjusted with the **antibody-effectiveness** switch. In the high setting, antibodies travel 10 patches each tick and live for 8 ticks. In the low setting, antibodies travel 5 patches each tick and live for 4 ticks. 

### Vaccines

Vaccines function by stimulating a secondary immune response, often using killed or inactivated viral particles. Vaccine particles in the model are depicted by grey `monster` turtle shapes. Pushing the **VACCINE** button introduces a number of vaccine particles determined by the **vaccine-load** slider. 

 * Vaccine particles do not reproduce.
 * Vaccine particles persist for 10 ticks and then die.
 * Antibodies have no effect on vaccine particles.
 * Vaccine particles do not count towards the values shown in the antigen plot.
 * Lymphocytes respond to the vaccine particles in the same way as they respond to an antigen, producing activated lymphocytes, memory cells, and antibodies.

### Measles

Measles has been demonstrated to cause long-term "immune memory loss" by depleting the overall lymphocyte population, including memory cells for non-measles diseases (Mina et al. 2015). The introduction of a measles vaccine has thus resulted in a drop in mortality rates that is larger than what can be explained by the drop in measles cases alone.

Pressing the **MEASLES** button causes the appearance of a large red `monster` turtle. This turtle does not interact with any of the other turtles in the model, but causes an immediate 95% drop in lymphocyte populations. This function is most useful to demonstrate what happens to the secondary immune response when measles intervenes between the primary and secondary response. It should be paired with a discussion of the results of Mina et al.'s (2015) study. I suggest showing students the data from Figure 1 of that paper or reading the news item about the study by Doucleff (2015). 

## HOW TO USE IT

### The "setup" and "go/pause" buttons 

**setup** clears all data and start a new simulation. Setup will create a population of 250 lymphocytes representing 14 different clones - lymphocytes that have the same antigen receptors. **go/pause** will begin the simulation. Without any other input, each lymphocyte population will undergo a random walk that will be different each time you run the model. Pressing the **go/pause** button during the simulation will pause the simulation. Other buttons are active at this time, so the user could, for example, pause the simulation, press the **VACCINE** button, and then restart the simulation from that point with the vaccine particles now introduced. 

### antibody-effectiveness  

A switch that controls how effective antibodies are at clearing infections. In the **low** position, antibodies move 3 spaces per tick and last for 4 ticks before dying. In the **high** position, antibodies move 10 spaces per tick and last for 8 ticks. You should start with antibody-effectiveness in the low position, which is the default value.

### antigen-load

A slider that determines the number of antigens that are added to the system each time the **ANTIGENS** button is pressed. The default value is 50.

### vaccine-load

A slider that determines the number of vaccine particles that will be added to the system each time the **VACCINE** button is pressed. The default value is 200.

### reproduction-multiplier-when-active

Lymphocytes have a default 15% probability of reproducing or dying each tick. When a lymphocyte is activated, the reproductive rate (but not the death rate) will be increased by a factor determined by this slider. 
_Example: when this slider is set to 3.0, the default value, the reproductive rate will triple for the duration of activation._

### ANTIGENS button

Pressing the **ANTIGENS** button at any point during the simulation introduces antigens to the system. The time at which the antigen infection occurs will be recorded in the **Output Window**. When the population of antigens has been reduced to 0 by the antibodies, the time will be recorded as the "clearance time" in the  **Output Window**.

### VACCINE button

Pressing the **VACCINE** button at any point during the simulation will introduce vaccine particles to the system. The time at which the vaccine is introduced will be recorded in the **Output Window**. Pressing the vaccine button when there is already a very large population of memory cells may lead to slow run times due to the very large number of antibodies that are likely to be generated. 

### MEASLES button

Pressing the **MEASLES** button will introduce a measles infection, which will cause 95% of the lympocytes in the simulation, selected randomly across all clones, to die immediately. A large red measles monster will appear for 5 ticks once the measles button is pressed; this turtle does not interact with any of the other agents in the simulation. The time at which the measles infection is introduced will be recorded in the **Output Window**.

## THINGS TO NOTICE

Most biology textbooks demonstrate secondary immunity with something that looks like this:

![Antibody production in primary and secondary response](https://raw.githubusercontent.com/klemensj/Immune/master/Images/Antibody_curve.png)

This graph is a static version of the **Antibody Population** graph that forms during this simulation. Can you recreate something that resembles this graph? From any of the line graphs in this model, you can obtain X and Y values at any point on the display by hovering over the graph with your cursor. Make sure to pay attention to the Y axes on all of these graphs, because the axis will vary dynamically within and between model runs.

Note that the timing of certain events (infection and clearance of an antigen, time of vaccination, time of measles infection) are recorded in the **Output Window** of the model. The difference between infection and clearance times for antigens can be used to compare the rapidity of primary and secondary immune responses. 

## LESSON PLAN

For using this model in the classroom, you might create a data table that looks something like this. The table can be drawn on a whiteboard if done as an instructor-guided demonstration or handed out as a worksheet for lab or activity use.

![Example Data sheet for classroom use ](https://raw.githubusercontent.com/klemensj/Immune/master/Images/Datasheet.png)

###Before you start

 1. Set the **speed** system slider to a rate that is slow enough to observe the dynamics of lymphocyte activation and the production of antibodies and memory cells. Somewhere around 200 ticks per minute is about right. 

 2. In order to understand the stochastic dynamics of the lymphocytes in the model, press **setup** and **go/pause**, but don't push any other buttons. 

####Study question:

 * Why do the populations of lymphocytes fluctuate if all clones have the same birth and death rates?

###Adaptive Immunity

 1. Press **setup**, press **ANTIGENS** and then press **go/pause**. Press **go/pause** again to pause the model once the infection has cleared. As the model is running identify antigens, activated lymphocytes, antibodies, and memory cells.

 2. While the model is paused, review the data displayed in the three graphs and in the output window. 

 3. Record on the data sheet the duration of the antigen infection under "Clearance Time Primary" in the row "Adaptive Trial 1."

 4. Measure the peak of the antigen and antibody populations on their respective graphs by hovering over the line graph with your cursor. Record these numbers under "Antibody Peak Primary" and "Antigen Peak Primary" in the row "Adaptive Trial 1."

 5. Press the **ANTIGENS** button, and then press **go/pause** to restart the model. Wait until the secondary infection clears, and then press **go/pause** again to pause. 

 6. On the same row of the data sheet, record the duration of the secondary infection and the antibody and antigen peak levels as you did before, recording the data in their respective "Secondary" columns.  

 7. Go back to step 1 and repeat this procedure at least two more times, recording the data on subsequent lines of the data sheet. 

####Study questions:

 * Which lymphocyte color has receptors that match this antigen in each model run?
 * Are antigen specific receptors present before or only after the antigen is introduced?
 * When are memory cells produced?
 * Describe the antibody graph in terms of the strength of the immune response.
 * Describe the antigen graph in terms of the infection intensity. 
 * Based on your data, what differences do we observe between the primary and secondary immune responses?

###Vaccines

 1. Press **setup**, press **VACCINE** and then press **go/pause**. Press **go/pause** again to pause the model once the vaccine particles have cleared. As the model is running identify the vaccine particles and note that they do not reproduce like the antigens did. 

 2. Measure the peak level of antibodies produced and record it in the row "Vaccine Trial 1" on your datasheet. Note that we are not recording antigen level or the duration of infection. (No live antigens exist and vaccine particle duration is a fixed quality of the model).

 3.  Press the **ANTIGENS** button, and then press **go/pause** to restart the model. Wait until the antigen infection clears, and then press **go/pause** again to pause. 

 4. On the same row of the data sheet, record the duration of the infection and the antibody and antigen peak levels as you did before, recording the data in their respective "Secondary" columns.  

5. Go back to step 1 and repeat this procedure at least one more time, recording the data on subsequent lines of the data sheet. 

####Study questions:

 * We recorded the response to the antigens in the secondary infection columns. Why? Is this best considered a secondary or primary infection?
 * Compare your data to the adaptive immunity trials. What is different in the relationship of the two antibody peaks with and without the vaccine? To what can this difference be attributed?
 * How do duration and antigen level of the post-vaccination infections compare to the data you recorded for the adaptive trials?

###Measles

 1. Press **setup**, press **ANTIGENS** and then press **go/pause**. Press **go/pause** again to pause the model once the infection has cleared. 

 2. While the model is paused, record the data for "Clearance Time Primary," "Antibody Peak Primary," and "Antigen Peak Primary" in the row "Measles Trial 1."

 3. Press the **MEASLES** button. Observe the drop in lymphocyte populations and review the information from Mina et al. 2015. 

 4. Press **go/pause** to allow the model to move forward. Press **go/pause** again to pause the model once the red measles turtle has disappeared and the lymphocyte populations have recovered.

 5. Press the **ANTIGENS** button, and then press **go/pause** to restart the model. Wait until the secondary infection clears, and then press **go/pause** again to pause. 

 6. On the same row of the data sheet, record the duration of the secondary infection and the antibody and antigen peak levels as you did before, recording the data in their respective "Secondary" columns.  

 7. Go back to step 1 and repeat this procedure at least one more time, recording the data on subsequent lines of the data sheet. 

####Study questions:

 * What is the relationship between the primary and secondary response when measles intervenes? 
 * What are some potential medical implications of your answer to the previous question?


###Advanced  

What immune system characteristic drives the secondary response? Try adjusting the **antibody-effectiveness** from low to high. Now try to generate a secondary immune response by adding antigens twice. How does having more potent antibodies affect the dynamic of the model?
 
Now adjust the **reproduction-multiplier-when-active** slider. Try to generate a secondary response at lower and higher multipliers. How does this affect the dynamics of adaptive immunity? Can you generate an adaptive immune response if the multiplier is set to 1?

Reduce the **vaccine-load** slider and compare the secondary response to those you recorded on your datasheet using the default settings. What happens to your ability to generate a secondary immune response with the model as that number decreases? What happens as you increase the vaccine load? Can you explain this result in terms of lymphocyte populations?

## EXTENDING THE MODEL

A curve smoothing function for the plots might help students compare the graphs generated with conceptual versions presented in textbooks. On the other hand, the stochastic nature of the model is perhaps best represented by the unsmoothed line.

The model does not include many details of the immune system that might be taught in a general biology class, including the distinction between IgG and IgM antibodies, the role of helper T-cells and macrophages, or other phenomena which could potentially be modelled in Netlogo. This was intentional to keep the model focused on the process of clonal selection, which Klemens identified as a particularly difficult conceptual hurdle for his students over the years.

No attempt has been made to translate values for antibody populations, antigen and vaccine loads, or the time scale of the model into biologically meaningful parameters. Translating to meaningful units may better prepare students for future work. 



## CREDITS AND REFERENCES

Madeline Conway drew the figures included in this Info document. 

### References

Doucleff, M. (2015, May 7). Scientists Crack A 50-Year-Old Mystery About The Measles Vaccine. Retrieved August 3, 2017, from [http://www.npr.org/sections/goatsandsoda/2015/05/07/404963436/scientists-crack-a-50-year-old-mystery-about-the-measles-vaccine](http://www.npr.org/sections/goatsandsoda/2015/05/07/404963436/scientists-crack-a-50-year-old-mystery-about-the-measles-vaccine)

Mina, M. J., Metcalf, C. J. E., Swart, R. L. de, Osterhaus, A. D. M. E., & Grenfell, B. T. (2015). Long-term measles-induced immunomodulation increases overall childhood infectious disease mortality. Science, 348(6235), 694–699. [https://doi.org/10.1126/science.aaa3662](https://doi.org/10.1126/science.aaa3662)





## HOW TO CITE

Adaptive Immunity 1.0 Created by Sarah Gift and Jeffrey A. Klemens

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Gift, S. and J.A. Klemens. (2017). Netlogo Adaptive Immunity Model 1.0. [https://github.com/klemensj/Immune](https://github.com/klemensj/Immune). 

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. [http://ccl.northwestern.edu/netlogo/](http://ccl.northwestern.edu/netlogo/). Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE
![Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License] (https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)
This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).
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
