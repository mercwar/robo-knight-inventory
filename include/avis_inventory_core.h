/**
 * ROBO-KNIGHT-INVENTORY — AVIS V4 CORE LAYER
 * COMPILER: MSVC RUNTIME TARGET (WIN64)
 * ZERO DIRECTORY SWITCHING PERMITTED
 */

#ifndef AVIS_INVENTORY_CORE_H
#define AVIS_INVENTORY_CORE_H

#define MAX_PATH_LEN 512
#define MAX_ASSET_COUNT 1024

typedef struct {
    char asset_name[128];
    char absolute_path[MAX_PATH_LEN];
    unsigned long file_size_bytes;
    int index_status;
} AvisInventoryAsset;

// Programmatic discovery methods for crawling agents
int AvisInitializeInventoryEngine(const char* absolute_config_route);
int AvisScanAssetRegistry(const char* absolute_target_dir, AvisInventoryAsset* out_registry);
void AvisExportInventoryManifest(const char* absolute_output_route, const AvisInventoryAsset* registry, int total_assets);

#endif // AVIS_INVENTORY_CORE_H
