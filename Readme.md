# Spreading Activation Levels Test (SALT)

## Instructions


1. Considering the uncommon nature of mooney (or two-tone) images, we advise researchers to familiarize participants with this kind of stimuli before running PT, FPT and CPT.

2. To obtain the scores for FDAT and CDAT, you have two options:
    - Visit datcreativity.com/task
    - Download python code at osf.io/bm5fd/


3. The Psychtoolbox version of SALT was mostly created using Octave, so please contact matheus.hf.15@usp.br if any imcompatibility problems occur while running it on MATLAB.


4. If the Psychtoolbox version crashes at the end of the task:
    - Delete the command line xlswrite() at the end of the code
    - Insert an alternative command (e.g. writetable)


5. If you wish to include more images in SALT: 
    - In FPT (for both Psychopy and Psychtoolbox):
      - Include the image class in wordsFPT.txt
    - In CPT:
      - If you're using psychtoolbox:
        - Change the name and number of the image according to the format order.class.name (for example: 61.32.snake)
      - If you're using Psychopy:
        - Include the image class in incongruentlables.txt   


## Credits

By Matheus Henrique Ferreira at Universidade de São Paulo.

