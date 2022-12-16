#include <sys/reboot.h>
#include <string.h>
#include <stdio.h>

int main(int argc, char* argv[]) {
  if (strcmp(argv[0], "/sbin/shutdown") == 0) {
    reboot(RB_POWER_OFF);
    return 0;
  } else if (strcmp(argv[0], "/sbin/reboot") == 0) {
    reboot(RB_AUTOBOOT);
    return 0;
  }
  return 1;
}
