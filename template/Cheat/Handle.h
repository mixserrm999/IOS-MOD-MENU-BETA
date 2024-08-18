#ifndef HANDLE_H
#define HANDLE_H

#include "Patches.h"

void cheatHandle() {
    for (auto& patch_info : patch_infos) {
        // Check if the setting is enabled
        if (*patch_info.setting) {
            // Apply patch
            if (!patch_info.patch.Modify()) return;

            patch_info.patch.Modify();
        } else {
            // Restore patch
            patch_info.patch.Restore();
        }
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //here add your hooks.

        //use DobbyHook, same kind of MSHookFunction but working on JIT, Dopamine!
        //HOOK_DOPA(offset, update, orig_Update);

        //normal MSHook
        //HOOK(offset, update, orig_Update);
    });
}

#endif // HANDLE_H
