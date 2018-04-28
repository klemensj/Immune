<style>
	hr { height: 0; page-break-after: always; }
</style>
# ADAPTIVE IMMUNITY LESSON PLAN


More details of model usage are included on the info tab of the model file. This document includes a printable lesson plan for deploying the model in the biology classroom. It is an edited version of information contained on the info tab.


###Pre-class preparation

You may find it convenient to create a data table that looks something like this. The table can be drawn on a whiteboard if the model is to be presented as an instructor-guided demonstration or handed out as a worksheet for lab or activity use.

![Example Data sheet for classroom use ](https://raw.githubusercontent.com/klemensj/Immune/master/Images/Datasheet.png)

###Background

This model is designed to demonstrate the process by which adaptive immunity arises as a result of clonal selection. The model also includes functions for simulating the dynamics of vaccination and the loss of adaptive immunity provoked by measles infection. It is intended to be used as an active learning activity in a college or high-school biology course.


<hr>Most biology textbooks demonstrate secondary immunity with something that looks like this:

![Antibody production in primary and secondary response](https://raw.githubusercontent.com/klemensj/Immune/master/Images/Antibody_curve.png)

This graph is a static version of the **Antibody Population** graphs that will be generated dynamically during this simulation.  

The model consists of five classes of agents: Lymphocytes, Antigens, Antibodies, Vaccine particles, and a Measles pathogen. 

#### Lymphocytes 

Lympohcytes in the model represent B-lymphocytes, and are depicted by circle shapes.
 
 * The diversity of lymphocyte colors included in the model corresponds to the diversity of B-lymphocte clones, or lymphocytes that bear the same antigen receptors, within the immune system. Each clone is represented by one of the 14 colors.
 * Each time that **setup** is run, one color of lymphocytes is randomly selected to be the active color. The active color lymphocyte possesses antigen receptors specific to the antigen that will be introduced in this model run.
 * Lymphocytes move randomly around the world, which represents a human body.
 * Lymphocytes have equal birth and death rates. Births and deaths are calculated probabastically for each lymphocyte at each time step, such that the population of each clone will exhibit stochastic variation (a random walk).


#### Antigens 

Antigens are any foreign body that causes an immune response. In this model they are assumed to be pathogenic organisms or viruses that are capable of reproducing. They are depicted by the black monster shapes. 

 *  Antigens are introduced into the world by the **ANTIGENS** button. The number of antigens introduced is determined by the **antigen-load** slider.
 * Antigens move randomly around the world.
 * Antigens reproduce probabalistically at each time step.
 * Antigens only die when they come into contact with an antibody.

#### Antigen-Lymphocyte interactions

When an antigen and a lymphocyte of the active color occupy the same or adjacent patches in the model the lymphocyte becomes activated. Activated lympohcytes are depicted by bold circles (same as a lymphocyte but with a bold black outline).  Activated lymphocytes increase their reproduction rate by a factor determined by the user.

![B lymphocyte developmental stages ](https://raw.githubusercontent.com/klemensj/Immune/master/Images/Lymphocytes.png)

In the immune system, activated lymphocytes then further develop into two types of cells:

  * Memory lymphocytes are depicted as lymphocytes that bear the letter "M". Memory lymphocytes are relatively long-lived cells. In the model their birth and death rates are set to an order of magnitude lower than those of typical lymphocytes. 

 * Plasma cells (the effector cell of the B-lympohcyte) are short-lived. Plasma cells produce antibodies for the duration of their activiation, and then die.     

#### Antibodies

Antibodies are produced by activated lymphocytes. 

 * Antibodies move in a straight line in a random direction away from the activated lympohcyte.
 * Antibodies live for a fixed time and then die.
 * If an antibody and an antigen occupy the same space patch at any time, the antigen dies.

#### Vaccines

Vaccines function by stimulating a secondary immune response, often using killed or inactivated viral particles. Vaccine particles in the model are depicted by grey monster shapes. Pushing the **VACCINE** button introduces a number of vaccine particles determined by the **vaccine-load** slider. 

 * Vaccine particles do not reproduce.
 * Vaccine particles persist for 10 ticks and then die.
 * Antibodies have no effect on vaccine particles.
 * Vaccine particles do not count towards the values shown in the antigen plot.
 * Lymphocytes respond to the vaccine particles in the same way as they respond to an antigen, producing activated lymphocytes, memory cells, and antibodies.

#### Measles

Measles has been demonstrated to cause long-term "immune memory loss" by depleting the overall lymphocyte population, including memory cells for non-measles diseases (Mina et al. 2015). The introduction of a measles vaccine has thus resulted in a drop in mortality rates that is larger than what can be explained by the drop in measles cases alone.

Pressing the **MEASLES** button causes the appearance of a large red `monster` turtle. This turtle does not interact with any of the other turtles in the model, but causes an immediate 95% drop in lymphocyte populations. This function is most useful to demonstrate what happens to the secondary immune response when measles intervenes between the primary and secondary response. It should be paired with a discussion of the results of Mina et al.'s (2015) study. I suggest showing students the data from Figure 1 of that paper or reading the news item about the study by Doucleff (2015). 

<hr>
##Lesson Procedure

###First Steps

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
<hr>
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
<hr>
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


###Further activities

If some students finish early, task them with one or more of the following questions:

What immune system characteristic drives the secondary response? Try adjusting the **antibody-effectiveness** from low to high. In the high setting, antibodies travel 10 patches each ticks and live for 8 ticks. In the low setting, antibodies travel 5 patches each tick and live for 4 ticks. Now try to generate a secondary immune response by adding antigens twice. How does having more potent antibodies affect the dynamic of the model?
 
Now adjust the **reproduction-multiplier-when-active** slider. Try to generate a secondary response at lower and higher multipliers. How does this affect the dynamics of adaptive immunity? Can you generate an adaptive immune response if the multiplier is set to 1?

Reduce the **vaccine-load** slider and compare the secondary response to those you recorded on your datasheet using the default settings. What happens to your ability to generate a secondary immune response with the model as that number decreases? What happens as you increase the vaccine load? Can you explain this result in terms of lymphocyte populations?




## CREDITS AND REFERENCES

This lesson plan was developed by Jeff Klemens. Madeline Conway drew the included figures. Sarah Gift helped write the text.

### References

Doucleff, M. (2015, May 7). Scientists Crack A 50-Year-Old Mystery About The Measles Vaccine. Retrieved August 3, 2017, from [http://www.npr.org/sections/goatsandsoda/2015/05/07/404963436/scientists-crack-a-50-year-old-mystery-about-the-measles-vaccine](http://www.npr.org/sections/goatsandsoda/2015/05/07/404963436/scientists-crack-a-50-year-old-mystery-about-the-measles-vaccine)

Gift, S. and J.A. Klemens. (2017). Netlogo Adaptive Immunity Model 1.0. [https://github.com/klemensj/Immune](https://github.com/klemensj/Immune). 

Mina, M. J., Metcalf, C. J. E., Swart, R. L. de, Osterhaus, A. D. M. E., & Grenfell, B. T. (2015). Long-term measles-induced immunomodulation increases overall childhood infectious disease mortality. Science, 348(6235), 694–699. [https://doi.org/10.1126/science.aaa3662](https://doi.org/10.1126/science.aaa3662)
