
#ifndef PLATFORM_H
#define PLATFORM_H

/* Define the default processor architecture: ivy bridge is pilipili2. */
#if !defined(NEHALEM) && !defined(IVY_BRIDGE) && !defined(SANDY_BRIDGE)
#define IVY_BRIDGE
#endif

/* Include events for specific processor architecture. */
#ifdef NEHALEM
  #pragma message("Setting NEHALEM architecture.")
  #include "nehalem.h"
#endif

#ifdef IVY_BRIDGE
  #pragma message("Setting Ivy Bridge architecture.")
  #include "ivy_bridge.h"
#endif

#ifdef SANDY_BRIDGE
  #pragma message("Setting Sandy Bridge architecture.")
  #include "sandy_bridge.h"
#endif

#endif /* PLATFORM_H */
