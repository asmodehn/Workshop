-module(sn_route).

%%
%% This module manages StickyNet redundant routes.
%% It uses sn_probe to gather information about neighbouring nodes
%% and determine the shortest path, and the best candidate for transmission
%% backup...
%%
