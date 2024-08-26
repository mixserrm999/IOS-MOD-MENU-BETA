#ifndef HANDLE_H
#define HANDLE_H

#include "Patches.h"
void (*orig_RpcAttack)(void *self, bool attacking);
void my_RpcAttack(void *self, bool attacking) {
    // ป้องกันไม่ให้ตัวละครถูกโจมตี
    attacking = false;
    orig_RpcAttack(self, attacking);
}
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
        DobbyHook((void*)0xF31924, (void*)my_RpcAttack, (void**)&orig_RpcAttack);

        //normal MSHook
        //HOOK(offset, update, orig_Update);
    });
}

#endif // HANDLE_H
