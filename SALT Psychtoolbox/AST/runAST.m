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
reactimePT = [];
responsesPT = {};
 
% Get an initial screen flip for timing
vbl = Screen('Flip', window);

% Locking keyboard and hiding mouse cursor
ListenChar(2);
HideCursor;

% Pesent instructions
introtext = ['An image will be presented on the screen. Your task is to answer\n'...
    'if you can see anything in it (example: dog; hammer; car). Use \n"z"'...
    'for answering "no" and "m" for "yes".\n \n'...
    'Press any key to continue.'];
Screen('TextSize', window, 35);
DrawFormattedText(window, introtext, 'center','center',white); 

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;

for trial = imgorder(1:end)  
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
      % Response is 0 because no pattern was detected
      respPT = 0;
      break
    % If participant pressed "m", or "yes"
    elseif keyIsDown == 1 && keyCode == 59
      % Stop time recoding
      reactimetrial = GetSecs - reactimetrial;
      % Response is 1 because a pattern was detected
      respPT = 1;
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
  reactimePT(end+1) = reactimetrial;
  responsesPT(end+1) = respPT;  
end  
% End message
endmessage = 'End of task. Press any key to finish';
Screen('TextSize', window, 35);
DrawFormattedText(window,endmessage, screenXpixels * 0.25, screenYpixels * 0.55,...
white);  
    
% Flip to the screen
Screen('Flip', window);

KbStrokeWait;

cellresponseslist = responsesPT';
matresponselist = cell2mat(cellresponseslist);
finalresultPT = sum(matresponselist);
respsize = length(cellresponseslist);
responselist = mat2cell(matresponselist,[respsize]);
reactimelist1 = reactimePT';
reacsize = length(reactimelist1);
reactimelist = mat2cell(reactimelist1,[reacsize]);
meanrtPT = mean(reactimePT);

% Grouping data in cell array and saving
tablePT = {[participantname];[participantid];[finalresultPT];[meanrtPT]};
% Format and file specification
participantnumber = mat2str(participantid);
participantfile = strcat(participantnumber,"PT");

xlswrite(participantfile,tablePT)

% Clear the screen and release keyboard
ListenChar(0);
sca;