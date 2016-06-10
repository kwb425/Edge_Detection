%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Image edge detecting function
%
%                                                  Written by Kim, Wiback,
%                                                     2016.04.01, Ver 1.1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%% Main GUI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = edge_detection()



%%%%%%%%%
% Display
%%%%%%%%%

%%% Main figure
main.fig = figure('units', 'pixels', ...
    'position', [200, 100, 880, 600], ... % [left, bottom, width, height]
    'menubar', 'none', ... % Menubar clearing
    'name', 'edge_detection', ...
    'numbertitle', 'off', ... % No number title
    'resize', 'on'); % Resize button enabled.

%%% Push button
main.push = uicontrol('style', 'pushbutton', ...
    'position', [730, 520, 100, 50], ...
    'fontsize', 12, ...
    'fontweight', 'bold', ...
    'string', 'Image(s)');

%%% Axes
main.ax_1 = axes('units', 'pixels', ...
    'position',[30, 30, 400, 400], ...
    'fontsize', 8, ...
    'nextplot', 'replacechildren');
main.ax_2 = axes('units', 'pixels', ...
    'position',[450, 30, 400, 400], ...
    'fontsize', 8, ...
    'nextplot', 'replacechildren');

%%% Texts
main.tx_1 = uicontrol('style', 'text', ...
    'position', [300, 520, 300, 50], ...
    'string', 'EDGE (choose image(s).)', ...
    'fontangle', 'normal', ...
    'fontweight', 'normal', ...
    'fontsize', 20, ...
    'foregroundcolor', 'red');
main.tx_2 = uicontrol('style', 'text', ...
    'position', [170, 430, 150, 50], ...
    'string', 'Before', ...
    'fontangle', 'normal', ...
    'fontweight', 'normal', ...
    'fontsize', 20, ...
    'foregroundcolor', 'green');
main.tx_3 = uicontrol('style', 'text', ...
    'position', [570, 430, 150, 50], ...
    'string', 'After', ...
    'fontangle', 'italic', ...
    'fontweight', 'bold', ...
    'fontsize', 20, ...
    'foregroundcolor', 'blue');

%%% Feeding the main structure to callback
set(main.push, 'callback', {@edge_detect, main}); % {@myfile, arg, ...}





%% The First Callback %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a callback, thus it needs (obj, event, arg, ...) structure.
function [] = edge_detect(~, ~, handles)



%%%%%%%%%%%%%%%%%
% Data connection
%%%%%%%%%%%%%%%%%
% Retracting main which is made above the callback function's level.
main = handles;



%%%%%%%%%%%%%%%%%%
% User interaction
%%%%%%%%%%%%%%%%%%
% Request the user input(s).
[name, path, ~] = uigetfile('*.png', 'Getting image(s)', ...
    'Get your image!', 'multiselect', 'on');
% Gathering the user input(s) in a cell name main.img
main.img = cell(length(name), 1);

%%% When the user input is singular, proceed.
if ~iscell(name)
    % Transforming strings to a cell (since this program is cell based.)
    name = cellstr(name);
    main.img = cell(length(name), 1);
end

%%% When the user inputs are plural, proceed.
for n = 1:length(name)
    main.img{n} = [path, name{n}];
    % Load the images and turn them into grayscale.
    main.img{n} = rgb2gray(imread(main.img{n}));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Derivational edge detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n = 1:length(name)
    % Zero paddings (nature of derivation will cut off 1 dimentionality.)
    deriv_col = zeros(size(main.img{n}, 1), size(main.img{n}, 2));
    deriv_row = zeros(size(main.img{n}, 1), size(main.img{n}, 2));
    % Adding column-wise first derivations
    deriv_col(2:end, :) = diff(main.img{n}, 1, 1);
    % Adding row-wise first derivations
    deriv_row(:, 2:end) = diff(main.img{n}, 1, 2);
    % Derivation of the image:
    % 1. the darker the image, the higher the derivation
    % 2. left-most-edge & top-most edge are padded with vacant spaces.
    main.deriv_of_main{n} = deriv_col + deriv_row;
    
    %%% Calling next button
    main.next_index = 0;
    % Do not verify callback right now, since main has to be up-to-date.
    main.next = uicontrol('style', 'pushbutton', ...
        'position', [730, 470, 100, 50], ...
        'fontsize', 12, ...
        'fontweight', 'bold', ...
        'string', 'Draw');
    % Verify the callback after the object is on the screen.
    set(main.next, 'callback', {@edge_draw, main})
end





%% The Second Callback %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = edge_draw(~, ~, handles)



%%%%%%%%%%%%%%%%%
% Data connection
%%%%%%%%%%%%%%%%%
% Retrieving the upper most handles
main = handles;
% Readability control
set(main.next, 'string', 'Next')



%%%%%%%%%%%
% Returning
%%%%%%%%%%%
% Escape when there is no more image.
if main.next_index == length(main.img)
    close all
    fprintf('No more image!\n')
    return
end



%%%%%%%%%
% Drawing
%%%%%%%%%
% Plotting index
main.next_index = main.next_index + 1;
% The original on the left
imshow(main.img{main.next_index}, 'parent', main.ax_1)
% The derivated on the right
imshow(main.deriv_of_main{main.next_index}, 'parent', main.ax_2)

%%% Updating the handles
set(main.next, 'callback', {@edge_draw, main})