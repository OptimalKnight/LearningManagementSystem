#include "learning_management_system.h"

int main(int argc, char** argv) {
  g_autoptr(MyApplication) app = learning_management_system_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
