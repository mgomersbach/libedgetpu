/*
 * edgetpu-check: Verify Coral Edge TPU device detection and connectivity.
 *
 * This tool dynamically loads libedgetpu.so and:
 *   1. Prints the runtime version
 *   2. Enumerates connected Edge TPU devices
 *   3. Optionally opens a device (--test), triggering firmware upload (DFU)
 *
 * The DFU step is where bad USB cables typically fail.
 *
 * Exit codes:
 *   0 - Device(s) found (and opened successfully if --test)
 *   1 - No devices found or open failed
 *   2 - Library or symbol loading error
 */

#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum edgetpu_device_type {
    EDGETPU_APEX_PCI = 0,
    EDGETPU_APEX_USB = 1,
};

struct edgetpu_device {
    enum edgetpu_device_type type;
    const char *path;
};

struct edgetpu_option {
    const char *name;
    const char *value;
};

typedef struct edgetpu_device *(*list_devices_fn)(size_t *);
typedef void (*free_devices_fn)(struct edgetpu_device *);
typedef const char *(*version_fn)(void);
typedef void *(*create_delegate_fn)(enum edgetpu_device_type, const char *,
                                    const struct edgetpu_option *, size_t);
typedef void (*free_delegate_fn)(void *);

static const char *device_type_str(enum edgetpu_device_type type) {
    switch (type) {
    case EDGETPU_APEX_PCI: return "PCIe";
    case EDGETPU_APEX_USB: return "USB";
    default: return "Unknown";
    }
}

int main(int argc, char **argv) {
    int do_test = 0;
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--test") == 0 || strcmp(argv[i], "-t") == 0) {
            do_test = 1;
        } else if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0) {
            printf("Usage: edgetpu-check [--test]\n");
            printf("  --test, -t  Open device and trigger firmware upload (DFU)\n");
            printf("  --help, -h  Show this help\n");
            return 0;
        } else {
            fprintf(stderr, "Unknown option: %s\n", argv[i]);
            return 2;
        }
    }

    void *lib = dlopen("libedgetpu.so.1", RTLD_NOW);
    if (!lib) {
        fprintf(stderr, "Failed to load libedgetpu.so.1: %s\n", dlerror());
        fprintf(stderr, "Is libedgetpu installed?\n");
        return 2;
    }

    version_fn get_version = (version_fn)dlsym(lib, "edgetpu_version");
    list_devices_fn list_devices = (list_devices_fn)dlsym(lib, "edgetpu_list_devices");
    free_devices_fn free_devices = (free_devices_fn)dlsym(lib, "edgetpu_free_devices");

    if (!get_version || !list_devices || !free_devices) {
        fprintf(stderr, "Failed to load symbols from libedgetpu: %s\n", dlerror());
        dlclose(lib);
        return 2;
    }

    printf("Edge TPU runtime version: %s\n", get_version());

    size_t num_devices = 0;
    struct edgetpu_device *devices = list_devices(&num_devices);

    if (num_devices == 0) {
        printf("No Edge TPU devices found.\n\n");
        printf("Troubleshooting:\n");
        printf("  - Check USB cable (try a different one — many cables are charge-only)\n");
        printf("  - Check udev rules are installed\n");
        printf("  - Check your user is in the 'plugdev' group: groups $USER\n");
        printf("  - Try a different USB port (USB 3.0 preferred)\n");
        dlclose(lib);
        return 1;
    }

    printf("Found %zu Edge TPU device(s):\n", num_devices);
    for (size_t i = 0; i < num_devices; i++) {
        printf("  [%zu] %s: %s\n", i, device_type_str(devices[i].type),
               devices[i].path);
    }

    int result = 0;

    if (do_test) {
        create_delegate_fn create = (create_delegate_fn)dlsym(lib, "edgetpu_create_delegate");
        free_delegate_fn release = (free_delegate_fn)dlsym(lib, "edgetpu_free_delegate");

        if (!create || !release) {
            fprintf(stderr, "Failed to load delegate symbols: %s\n", dlerror());
            free_devices(devices);
            dlclose(lib);
            return 2;
        }

        printf("\nOpening device [0] (%s)...\n", device_type_str(devices[0].type));
        void *delegate = create(devices[0].type, devices[0].path, NULL, 0);

        if (delegate) {
            printf("Device opened successfully. Firmware is loaded and operational.\n");
            release(delegate);
        } else {
            printf("Failed to open device.\n\n");
            printf("Troubleshooting:\n");
            printf("  - Check udev rules are installed and user is in 'plugdev' group\n");
            printf("    (try running with sudo to rule out permissions)\n");
            printf("  - Try a different USB cable (data-capable, not charge-only)\n");
            printf("  - Try a USB 3.0 port directly (not through a hub)\n");
            printf("  - Unplug and re-plug the device\n");
            result = 1;
        }
    }

    free_devices(devices);
    dlclose(lib);
    return result;
}
