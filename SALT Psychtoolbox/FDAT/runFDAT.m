% Clear before starting program
sca;
close all;
clearvars;

% Inserting participant's number and name
participantid = input('Insert participant''s ID number and press "Enter": ');
participantname = input('Insert participant''s initial name letters and press "Enter": ','s');

% Initialize the base setup
PsychDefaultSetup(2);

%Generate screen numbers for multiple displays
screens = Screen('Screens');

%Choosing minimum will display this on the main laptop screen;
screenNumber = min(screens);

% Define black and white and grey luminance
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% This function call will give use the same information as contained in
% “windowRect��?
rect = Screen('Rect', window);

% Get the size of the on screen window in pixels, these are the last two
% numbers in “windowRect��? and “rect��?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels.
% xCenter = screenXpixels / 2
% yCenter = screenYpixels / 2
[xCenter, yCenter] = RectCenter(windowRect);

%ScreenSize as reported by the system
[width, height] = Screen('DisplaySize', screenNumber);

% Set some text properties
Screen('TextFont', window,'Times');

% Enable unified mode of KbName, so KbName accepts identical key names on
% all operating systems:
KbName('UnifyKeyNames');

% Preventing the keyboard from vomiting in command/editor window and hiding
% mouse cursor
ListenChar(2);
HideCursor;

% Building the questions an priming words cell arrays
fid = fopen('wordsFDAT.txt');
primingwords = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

resultFDAT = {};
reactimeFDAT = [];
misworcount = '0';
wordcount1 = 'Number of words inserted: ';
wordcount2 = '/10';
taskcount = 1;
numofwords = 30;

% Logging keyboard
deviceIndex = [];
introtext = ['Please write ten english nouns that are as semantically distant \n'...
  'as possible. Don''t use technical or field/area specific terms \nand'...
  'press "Enter" after each answer. Some words will \nbe presented '...
  'as distractors before each trial.\n\n Press any key to continue.'];

% Introduction
Screen('TextSize', window, 45);
DrawFormattedText(window, introtext, 'center','center',white); 

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;

for N = 1:10
  % Wordcounter
  wordcounter = [wordcount1,misworcount,wordcount2];

  % Randomizing words
  primword = randperm(numofwords);
  primword1 = primingwords{1,1}{primword(1),1};
  primword2 = primingwords{1,1}{primword(3),1};
  primword3 = primingwords{1,1}{primword(5),1};
  primword4 = primingwords{1,1}{primword(7),1};
   
  % Presenting the priming words 
  Screen('TextSize', window, 30);
  DrawFormattedText(window,primword1, screenXpixels * 0.50, screenYpixels * 0.50,...
  white);
  Screen('TextSize', window, 30);
  DrawFormattedText(window,primword2, screenXpixels * 0.50, screenYpixels * 0.60,...
  white);
    Screen('TextSize', window, 30);
  DrawFormattedText(window,primword3, screenXpixels * 0.40, screenYpixels * 0.50,...
  white);
  Screen('TextSize', window, 30);
  DrawFormattedText(window,primword4, screenXpixels * 0.40, screenYpixels * 0.60,...
  white);  
   
  % Flip to the screen
  Screen('Flip', window);
  
  % Present priming words for 500ms
  WaitSecs(0.5);
      
  % Start time recording
  reactimetrial = GetSecs;
    
  Screen('TextSize', window, 30);
  % Present the wordcount for the participant
  DrawFormattedText(window,wordcounter, 'center', screenYpixels * 0.80,...
  [1 0 0]);  
         
  %Function to get user input and display on the screen
  Screen('TextSize', window, 60);
  [response,temp] = GetEchoString(window,'Write a word: ',...
  screenXpixels * 0.25,yCenter,white,black);
      
  % Stop time recording
  reactimetrial = GetSecs - reactimetrial;

  % Flip to the screen
  Screen('Flip', window);

  % Concatenating responses
  resultFDAT(end+1) = response;
  reactimeFDAT(end+1) = reactimetrial;
  reactimelist = reactimeFDAT';
  misworcount = str2num(misworcount);
  misworcount = misworcount + 1;
  misworcount = num2str(misworcount);
  taskcount = taskcount + 1;
end
meanrtFDAT = mean(reactimelist);
% End message
endmessage = 'End of task. Press any key to finish';
Screen('TextSize', window, 35);
DrawFormattedText(window,endmessage, screenXpixels * 0.25, screenYpixels * 0.55,...
white);  
    
% Flip to the screen
Screen('Flip', window);
KbStrokeWait;

% Grouping data in cell array and saving
tableFDAT = {[participantname];[participantid];[resultFDAT];[meanrtFDAT]};

% Format and file specification
participantnumber = mat2str(participantid);
participantfile = strcat(participantnumber,'FDAT');

xlswrite(participantfile,tableFDAT)

% Release the keyboard
ListenChar(0);

% Clear screen
sca;