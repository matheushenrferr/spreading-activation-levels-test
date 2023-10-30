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

% Preventing the keyboard from vomiting in command/editor window
ListenChar(2);

% Building the questions cell array
fid = fopen('questionsRAT.txt');
C = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

phrases = randi(10,1,1);
phraseslist = {};
resultCDAT = {};
reactimeCDAT = [];
misworcount = '0';
wordcount1 = 'Number of words inserted: ';
wordcount2 = '/10';
taskcount = 1;

% Logging keyboard and hiding mouse cursor
deviceIndex = [];
ListenChar(2);
HideCursor;

% Pesent instructions
introtext = ['Please read the following sentence and write ten nouns \n'...
'that categorically fit it, using "Enter" to confirm.\n\n'...
'Press any key to continue.'];
Screen('TextSize', window, 45);
DrawFormattedText(window, introtext, 'center','center',white); 

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;

while taskcount <= 10 
  % Wordcounter
  wordcounter = [wordcount1,misworcount,wordcount2];
  
  Screen('TextSize', window, 30);
  % Present the wordcount for the participant
  DrawFormattedText(window,wordcounter, 'center', screenYpixels * 0.80,...
  [1 0 0]);
  
  % Flip to the screen
  Screen('Flip', window,[],1,[]);
      
  % Start time recording
  reactimetrial = GetSecs;
         
  %Function to get user input and display on the screen
  Screen('TextSize', window, 60);
  [response,temp] = GetEchoString(window,C{1,1}{phrases,1},...
  screenXpixels * 0.05,yCenter,white,black);
      
  % Stop time recording
  reactimetrial = GetSecs - reactimetrial;

  % Flip to the screen
  Screen('Flip', window);

  % Concatenating responses
  resultCDAT(end+1) = response;
  reactimeCDAT(end+1) = reactimetrial;
  reactimelist = reactimeCDAT';
  taskcount = taskcount + 1;
  misworcount = str2num(misworcount);
  misworcount = misworcount + 1;
  misworcount = num2str(misworcount);
end
meanrtCDAT = mean(reactimelist);
% End message
endmessage = 'End of task. Press any key to finish';
Screen('TextSize', window, 35);
DrawFormattedText(window,endmessage, screenXpixels * 0.25, screenYpixels * 0.55,...
white);  
    
% Flip to the screen
Screen('Flip', window);
KbStrokeWait;

% Grouping data in cell array and saving
tableCDAT = {[participantname];[participantid];[resultCDAT];[meanrtCDAT];C{1,1}{phrases,1}};

% Format and file specification
participantnumber = mat2str(participantid);
participantfile = strcat(participantnumber,'CDAT');

xlswrite(participantfile,tableCDAT)

% Release the keyboard
ListenChar(0);

% Clear screen
sca;