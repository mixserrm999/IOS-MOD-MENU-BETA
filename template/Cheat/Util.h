#import "../5Toubun/NakanoItsuki.h"
#import "../5Toubun//NakanoYotsuba.h"
#import "../KittyMemory/writeData.hpp"

#include <substrate.h>
#include <mach-o/dyld.h>
#include "../KittyMemory/MemoryPatch.hpp"

#define timer(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^
#define HOOK(offset, ptr, orig) MSHookFunction((void *)getRealOffset(offset), (void *)ptr, (void **)&orig)
#define HOOK_DOPA(offset, ptr, orig) DobbyHook((void *)getRealOffset(offset), (void *)ptr, (void **)&orig)
#define HOOK_NO_ORIG(offset, ptr) MSHookFunction((void *)getRealOffset(offset), (void *)ptr, NULL)

// Note to not prepend an underscore to the symbol. See Notes on the Apple manpage (https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/dlsym.3.html)
#define HOOKSYM(sym, ptr, org) MSHookFunction((void*)dlsym((void *)RTLD_DEFAULT, sym), (void *)ptr, (void **)&org)
#define HOOKSYM_NO_ORIG(sym, ptr)  MSHookFunction((void*)dlsym((void *)RTLD_DEFAULT, sym), (void *)ptr, NULL)
#define getSym(symName) dlsym((void *)RTLD_DEFAULT, symName)

MemoryPatch createUnityFrameworkPatch(uintptr_t offset, const char* patch) {
    return MemoryPatch::createWithHex("UnityFramework", offset, patch);
}

void patch(uintptr_t offset, const char* patch) {
    MemoryPatch newPatch = createUnityFrameworkPatch(offset, patch);
    if (!newPatch.isValid()) return;
    newPatch.Modify();
}
