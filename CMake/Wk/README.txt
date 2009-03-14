Wk CMake is aimed at defining a stable hierarchy to build projects,
along with cmake files able to build them and link them together in different ways

Wk CMake currently supports :

 - one main target per project hierarchy plus few simple tests files ( in test/ subdirectory )
 - target can be executable, library shared or static (module not tested yet, need a MAC)
 - source dependency ( in ext/ subdirectory )
 - bin dependency (in another Wk build directory )
 - 