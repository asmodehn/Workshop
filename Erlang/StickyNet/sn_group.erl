-module(sn_group).


%%
%% This module manages groups the node belongs to,
%% and neighbouring nodes' groups as well.
%% sn_group use the sn_probe_* module in order to transmit messages,
%% in the same way that sn_probe_* does it by default for nodes
%%
