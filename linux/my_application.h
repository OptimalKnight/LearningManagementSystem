#ifndef FLUTTER_learning_management_system_H_
#define FLUTTER_learning_management_system_H_

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(MyApplication, learning_management_system, MY, APPLICATION,
                     GtkApplication)

/**
 * learning_management_system_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #MyApplication.
 */
MyApplication* learning_management_system_new();

#endif  // FLUTTER_learning_management_system_H_
