#include <linux/moduleparam.h>

#ifdef MODULE_PARAM_PREFIX
#undef MODULE_PARAM_PREFIX
#endif
#define MODULE_PARAM_PREFIX "lowmemorykiller."

static int enable_lmk;
module_param(enable_lmk, int, 0644);

static int adj_max_shift;
module_param(adj_max_shift, int, 0644);

static int enable_adaptive_lmk;
module_param(enable_adaptive_lmk, int, 0644);

static int lmk_fast_run;
module_param(lmk_fast_run, int, 0644);

static int vmpressure_file_min;
module_param(vmpressure_file_min, int, 0644);

static int oom_reaper;
module_param(oom_reaper, int, 0644);

static int cost;
module_param(cost, int, 0644);

static int debug_level;
module_param(debug_level, int, 0644);

static int minfree[6];
module_param_array(minfree, int, NULL, 0644);

static short adj[6];
module_param_array(adj, short, NULL, 0644);
