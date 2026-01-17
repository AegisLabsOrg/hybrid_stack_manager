#include "include/hybrid_stack_manager/hybrid_stack_manager_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "hybrid_stack_manager_plugin.h"

void HybridStackManagerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  hybrid_stack_manager::HybridStackManagerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
