#import "NakanoMiku.h"
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <CoreFoundation/CoreFoundation.h>
#include <string>

bool getType(unsigned int data) {
    int a = data & 0xffff8000;
    int b = a + 0x00008000;
    int c = b & 0xffff7fff;
    return c;
}


//Patching section, I just copy and paste it from KittyMemory of Ted2 mod menu cuz I'm lazy :D
struct MemoryFileInfo {
    uint32_t index;
    const struct mach_header *header;
    const char *name;
    long long address;
};

MemoryFileInfo getBaseInfo() {
    MemoryFileInfo _info;
    std::string applicationsPath = "/private/var/containers/Bundle/Application";
    for (uint32_t i = 0; i < _dyld_image_count(); i++)
    {
        const char *name = _dyld_get_image_name(i);
        if (!name) continue;
        std::string fullpath(name);
        if (strncmp(fullpath.c_str(), applicationsPath.c_str(), applicationsPath.size()) == 0)
        {
            _info.index = i;
            _info.header = _dyld_get_image_header(i);
            _info.name = _dyld_get_image_name(i);
            _info.address = _dyld_get_image_vmaddr_slide(i);
            break;
        }
    }
    return _info;
}

MemoryFileInfo getMemoryFileInfo(const std::string& fileName) {
    MemoryFileInfo _info;
    const uint32_t imageCount = _dyld_image_count();
    for (uint32_t i = 0; i < imageCount; i++) {
        const char *name = _dyld_get_image_name(i);
        if (!name)
            continue;
        std::string fullpath(name);
        if (fullpath.length() < fileName.length() || fullpath.compare(fullpath.length() - fileName.length(), fileName.length(), fileName) != 0)
            continue;
        _info.index = i;
        _info.header = _dyld_get_image_header(i);
        _info.name = _dyld_get_image_name(i);
        _info.address = _dyld_get_image_vmaddr_slide(i);
        break;
    }
    return _info;
}

uintptr_t getAbsoluteAddress(const char *fileName, uintptr_t address) {
    MemoryFileInfo info;
    if (fileName)
        info = getMemoryFileInfo(fileName);
    else
        info = getBaseInfo();
    if (info.address == 0)
        return 0;
    return info.address + address;
}

//change getRealOffset to another framework if you want, or NULL
uint64_t getRealOffset(uint64_t offset){
    return getAbsoluteAddress("UnityFramework", offset);
}

//Well, at here I use vm_unity for the game that contains "UnityFramework.framework/UnityFramework" file, you can change it if needed, for example: LoL WildRift, FEProj is the correct binary for you.
bool vm_unity(long long offset, unsigned int data) {
    //Change binary name here if it not UnityFramework
    const char *fileName = "UnityFramework";
    uintptr_t address = getAbsoluteAddress(fileName, offset);
    if (address == 0)
        return false;

    kern_return_t err;
    mach_port_t port = mach_task_self();

    err = vm_protect(port, (mach_vm_address_t)address, sizeof(data), false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (err != KERN_SUCCESS) {
        return false;
    }

    if (getType(data)) {
        data = CFSwapInt32(data);
        err = vm_write(port, (mach_vm_address_t)address, (vm_offset_t)&data, sizeof(data));
    } else {
        data = (unsigned short)data;
        data = CFSwapInt16(data);
        err = vm_write(port, (mach_vm_address_t)address, (vm_offset_t)&data, sizeof(data));
    }

    if (err != KERN_SUCCESS) {
        return false;
    }

    err = vm_protect(port, (mach_vm_address_t)address, sizeof(data), false, VM_PROT_READ | VM_PROT_EXECUTE);
    if (err != KERN_SUCCESS) {
        return false;
    }

    return true;
}

bool vm(long long offset, unsigned int data) {
    const char *fileName = NULL;
    uintptr_t address = getAbsoluteAddress(fileName, offset);
    if (address == 0)
        return false;

    kern_return_t err;
    mach_port_t port = mach_task_self();

    err = vm_protect(port, (mach_vm_address_t)address, sizeof(data), false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (err != KERN_SUCCESS) {
        return false;
    }

    if (getType(data)) {
        data = CFSwapInt32(data);
        err = vm_write(port, (mach_vm_address_t)address, (vm_offset_t)&data, sizeof(data));
    } else {
        data = (unsigned short)data;
        data = CFSwapInt16(data);
        err = vm_write(port, (mach_vm_address_t)address, (vm_offset_t)&data, sizeof(data));
    }

    if (err != KERN_SUCCESS) {
        return false;
    }

    err = vm_protect(port, (mach_vm_address_t)address, sizeof(data), false, VM_PROT_READ | VM_PROT_EXECUTE);
    if (err != KERN_SUCCESS) {
        return false;
    }

    return true;
}