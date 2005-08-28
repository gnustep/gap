/* All Rights reserved */

#include <AppKit/AppKit.h>

@interface PPCController : NSObject
{
  id activeMaster;
  id activeSlave;
  id bootArgs;
  id bootMethod;
  id bpp;
  id fullScreen;
  id keyCodeMatrix;
  id networkMatrix;
  id panel;
  id okButton;
  id pathMaster;
  id pathSlave;
  id redrawInterval;
  id revertButton;
  id setMaster;
  id setSlave;
  id typeMaster;
  id typeSlave;
  id usbEnabled;
  id xres;
  id yres;
  id setPathToPPC;
  id setPPCUserHome;
  id pathToPPC;
  id ppcUserHome;
}
- (void) setSlavePath: (id)sender;
- (void) ok: (id)sender;
- (void) revert: (id)sender;
- (void) setMasterPath: (id)sender;
- (void) showOutput: (id)sender;
- (void) setPPCUserHome: (id)sender;
- (void) setPathToPPC: (id)sender;
- (void) startEmulator: (id)sender;
@end
