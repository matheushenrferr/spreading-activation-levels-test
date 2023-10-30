% Clear the workspace and the screen
sca;
close all;
clear;

% Inserting participant's number and name
participantid = input('Insert participant''s ID number and press "Enter": ');
participantname = input('Insert participant''s initial name letters and press "Enter": ','s');

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Enable unified mode of KbName, so KbName accepts identical key names on
% all operating systems:
KbName('UnifyKeyNames');

% Escape key exits the demo
deviceIndex = [];

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% We will present each element of our sequence for two seconds
presSecs = 0;
waitframes = round(presSecs / ifi);

% Locating the images
imagefolder = 'mooney_images';
imglocation = fullfile(imagefolder,'*.jpg');
imglist = dir(imglocation);

% Establishing the number of trials in the task
N = length(imglist);

% Opening the labels file
imgorder = [randperm(N)];
stimulist = {};
congruencelist = {};
labelsCPT = {};
reactimeCPT = [];
responsesCPT = [];

% Set congruent/incongruent conditions orderfields
taskordervec = [1:N];
binarytaskvector = (taskordervec <= N/2);
taskorder = binarytaskvector(randperm(length(binarytaskvector)));

  
% Get an initial screen flip for timing
vbl = Screen('Flip', window);

% Locking keyboard and hiding mouse cursor
ListenChar(2);
HideCursor;

% Pesent instructions
introtext = ['An image and a label will be presented on the screen. You need to \n'...
    'answer if the label is congruent with the image or not. Use\n "z" for answering'...
    '"no" and "m" for "yes"\n \n'...
    'Press any key to continue.'];
Screen('TextSize', window, 35);
DrawFormattedText(window, introtext, 'center','center',white); 

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;

for trial = imgorder(1:end)
  trialcondition = taskorder(trial);
  if trialcondition == 0
    congcondition = 'Congruent';
  else
    congcondition = 'Incongruent';
  endif
  % Selecting trial image
  trialimage = imglist(trial).name;
  trialimagepath = fullfile(imglist(trial).folder,trialimage);
  trialimagenamesplit = strsplit(trialimage,'.');
  trialimagepreID = trialimagenamesplit(1,2);
  trialimageID = cell2mat(trialimagepreID);
  
  % Load the image from file
  theImage = imread(trialimagepath);
  
  % Get the size of the image
  [s1, s2, s3] = size(theImage);

  % Get the trial label
  trialprelabel1 = trialimagenamesplit(1,3);
  triallabel1 = cell2mat(trialprelabel1);
  
  if trialcondition == 0
    triallabel = triallabel1;
  else
    incongruenttrial = randi(N);
    trialimage2 = imglist(incongruenttrial).name;
    trialimagenamesplit2 = strsplit(trialimage2,'.');
    trialimagepreID2 = trialimagenamesplit2(1,2);
    trialimageID2 = cell2mat(trialimagepreID2);
    trialprelabel2 = trialimagenamesplit2(1,3);
    triallabel2 = cell2mat(trialprelabel2);
    while trialimageID2 == trialimageID
      incongruenttrial = randi(N);
      trialimage2 = imglist(incongruenttrial).name;
      trialimagenamesplit2 = strsplit(trialimage2,'.');
      trialimagepreID2 = trialimagenamesplit2(1,2);
      trialimageID2 = cell2mat(trialimagepreID2);
      trialprelabel2 = trialimagenamesplit2(1,3);
      triallabel2 = cell2mat(trialprelabel2);
    endwhile
    triallabel = triallabel2;
  endif
  % Draw the fixation cross in white, set it to the center of our screen and
  % set good quality antialiasing
  Screen('TextFont', window, 'Ariel');
  Screen('TextSize', window, 36);
  Screen('DrawLines', window, allCoords,...
      lineWidthPix, white, [xCenter yCenter], 2);
    
  % Flip to the screen
  Screen('Flip', window);
  
  %Wait for 3 seconds
  WaitSecs(3);
  
  % Draw the label
  Screen('TextSize', window, 40);
  DrawFormattedText(window, triallabel, 'center', screenYpixels * 0.95,white);
 
  % Flip to the screen
  Screen('Flip', window, [], 1, []);
  
  % Make the image into a texture
  imageTexture = Screen('MakeTexture', window, theImage);

  % Draw the image to the screen, unless otherwise specified PTB will draw
  % the texture full size in the center of the screen. We first draw the
  % image in its correct orientation.
  Screen('DrawTexture', window, imageTexture, [], [], 0);

  % Flip to the screen
  vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
  
  % Start time recording
  reactimetrial = GetSecs;
  
  while 1
    % Check the state of the keyboard.
    [ keyIsDown, seconds, keyCode ] = KbCheck();
    keyCode = find(keyCode, 1);
    % If participant pressed "z", or "no"
    if keyIsDown == 1 && keyCode == 53
      % Stop time recoding
      reactimetrial = GetSecs - reactimetrial;
      % Checking the trial condition
      if trialcondition == 0
        % Checking for false negative
        respCPT = 0;
      else
        % Checking for correct answer
        respCPT = 1;
      endif
      break
    % If participant pressed "m", or "yes"
    elseif keyIsDown == 1 && keyCode == 59
      % Stop time recoding
      reactimetrial = GetSecs - reactimetrial;
      % Checking trial condition
      if trialcondition == 0
        %Checking for correct answer
        respCPT = 1;
      else
        % Checking for false positive
        respCPT = 0;
      endif
      break
    % In case participant press "Escape"
    elseif keyIsDown == 1 && keyCode == 10
      % Close texture
      Screen('Close', [imageTexture]);
      ListenChar(0);
      sca;
      clear all;
      clc;
      break
    end
  end    
  % Close texture
  Screen('Close', [imageTexture]);
  
  % Include data in matrices
  stimulist(end+1) = trialimage;
  congruencelist(end+1) = congcondition;
  labelsCPT(end+1) = triallabel;
  reactimeCPT(end+1) = reactimetrial;
  responsesCPT(end+1) = respCPT;  
end
matresponseslist = responsesCPT';
finalresultCPT = sum(matresponseslist);
respsize = length(matresponseslist);
responselist = mat2cell(matresponseslist,[respsize]);
reactimelist1 = reactimeCPT';
reacsize = length(reactimelist1);
reactimelist = mat2cell(reactimelist1,[reacsize]);
meanrtCPT = mean(reactimelist1);

% Grouping data in cell array and saving
tableCPT = {[participantname];[participantid];[finalresultCPT];[meanrtCPT]};

% Format and file specification
participantnumber = mat2str(participantid);
participantfile = strcat(participantnumber,'CPT');

% End message
endmessage = 'End of task. Press any key to finish';
Screen('TextSize', window, 35);
DrawFormattedText(window,endmessage, screenXpixels * 0.25, screenYpixels * 0.55,...
white);  
    
% Flip to the screen
Screen('Flip', window);
KbStrokeWait;

xlswrite(participantfile,tableCPT)
  
% Clear the screen and release keyboard
ListenChar(0);
sca;