//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <hybrid_stack_manager/hybrid_stack_manager_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) hybrid_stack_manager_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "HybridStackManagerPlugin");
  hybrid_stack_manager_plugin_register_with_registrar(hybrid_stack_manager_registrar);
}
