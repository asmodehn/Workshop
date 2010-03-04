%% Constant for StickyNet
%% port for communication ( tcp / sctp / dccp ) : 
-define(STICKY_PORT,2611).
%% port for probe ( udp only )
-define(STICKY_PROBE_PORT,2611).

%% Multicast group, if needed
-define(STICKY_PROBE_MCIP,"224.0.26.11").

%% record for the probe messages
-record(probe_msg,{nid="unidentified",ttl=1}).

