#ifndef PATCHES_H
#define PATCHES_H

#include "../KittyMemory/MemoryPatch.hpp"
#include "Offset.h"
#include "Settings.h"
#include "Util.h"
#include "il2cpp.h"

struct PatchInfo {
    MemoryPatch patch;
    bool* setting;
};

std::vector<PatchInfo> patch_infos;

void addNewPatch(uintptr_t offset, const char* hexPattern, bool* setting) {
    MemoryPatch newPatch = createUnityFrameworkPatch(offset, hexPattern);
    if (!newPatch.isValid()) return;
    patch_infos.push_back({newPatch, setting});
}

void initPatch() {
    //here init your patches
    //addNewPatch(offset::test, "20008052C0035FD6", &test);

}

#endif // PATCHES_H