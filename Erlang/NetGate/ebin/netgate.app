{application, netgate, [
  {description, "netgate - Erlang prototype of NetGate protocol."},
  {rev, "%REV%"},
  {modules, [
    bits_oper, node_id, avclock
  ]},
  {registered, [
  ]},
  {applications, [kernel, stdlib]},
  {mod, {netgate_app, []}},
  {start_phases, []},
  {env, []}
]}.
