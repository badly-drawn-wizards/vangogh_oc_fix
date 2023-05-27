/*
 * Copyright 2014 Advanced Micro Devices, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER(S) OR AUTHOR(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 */

// All struct pointers have been replaced by void pointers

#ifndef AMDGPU_SMU_H_
#define AMDGPU_SMU_H_
#include <drm/drm_device.h>

/*
amdgpu_irq_src		irq_source; DONE
mutex			message_lock;
smu_table_context	smu_table; DONE
smu_dpm_context		smu_dpm; DONE
smu_power_context	smu_power; DONE
smu_feature		smu_feature; MAYBE
smu_baco_context		smu_baco;
smu_temperature_range	thermal_range; DONE
smu_umd_pstate_table	pstate_table; DONE
work_struct throttling_logging_work; MAYBE
work_struct interrupt_work; MAYBE
smu_user_dpm_profile user_dpm_profile; DONE
stb_context stb_context; DONE
*/

struct stb_context {
	uint32_t stb_buf_size;
	bool enabled;
	spinlock_t lock;
};

enum smu_clk_type {
	SMU_GFXCLK,
	SMU_VCLK,
	SMU_DCLK,
	SMU_VCLK1,
	SMU_DCLK1,
	SMU_ECLK,
	SMU_SOCCLK,
	SMU_UCLK,
	SMU_DCEFCLK,
	SMU_DISPCLK,
	SMU_PIXCLK,
	SMU_PHYCLK,
	SMU_FCLK,
	SMU_SCLK,
	SMU_MCLK,
	SMU_PCIE,
	SMU_LCLK,
	SMU_OD_CCLK,
	SMU_OD_SCLK,
	SMU_OD_MCLK,
	SMU_OD_VDDC_CURVE,
	SMU_OD_RANGE,
	SMU_OD_VDDGFX_OFFSET,
	SMU_CLK_COUNT,
};

struct smu_user_dpm_profile {
	uint32_t fan_mode;
	uint32_t power_limit;
	uint32_t fan_speed_pwm;
	uint32_t fan_speed_rpm;
	uint32_t flags;
	uint32_t user_od;

	/* user clock state information */
	uint32_t clk_mask[SMU_CLK_COUNT];
	uint32_t clk_dependency;
};

struct smu_freq_info {
	uint32_t min;
	uint32_t max;
	uint32_t freq_level;
};

struct pstates_clk_freq {
	uint32_t			min;
	uint32_t			standard;
	uint32_t			peak;
	struct smu_freq_info		custom;
	struct smu_freq_info		curr;
};

struct smu_umd_pstate_table {
	struct pstates_clk_freq		gfxclk_pstate;
	struct pstates_clk_freq		socclk_pstate;
	struct pstates_clk_freq		uclk_pstate;
	struct pstates_clk_freq		vclk_pstate;
	struct pstates_clk_freq		dclk_pstate;
};

struct smu_baco_context
{
	uint32_t state;
	bool platform_support;
};

struct smu_temperature_range {
	int min;
	int max;
	int edge_emergency_max;
	int hotspot_min;
	int hotspot_crit_max;
	int hotspot_emergency_max;
	int mem_min;
	int mem_crit_max;
	int mem_emergency_max;
	int software_shutdown_temp;
};

#define SMU_FEATURE_MAX	(64)
struct smu_feature
{
	uint32_t feature_num;
	DECLARE_BITMAP(supported, SMU_FEATURE_MAX);
	DECLARE_BITMAP(allowed, SMU_FEATURE_MAX);
	DECLARE_BITMAP(enabled, SMU_FEATURE_MAX);
};

struct smu_power_gate {
	bool uvd_gated;
	bool vce_gated;
	atomic_t vcn_gated;
	atomic_t jpeg_gated;
};

struct smu_power_context {
	void *power_context;
	uint32_t power_context_size;
	struct smu_power_gate power_gate;
};

enum amd_dpm_forced_level {
	AMD_DPM_FORCED_LEVEL_AUTO = 0x1,
	AMD_DPM_FORCED_LEVEL_MANUAL = 0x2,
	AMD_DPM_FORCED_LEVEL_LOW = 0x4,
	AMD_DPM_FORCED_LEVEL_HIGH = 0x8,
	AMD_DPM_FORCED_LEVEL_PROFILE_STANDARD = 0x10,
	AMD_DPM_FORCED_LEVEL_PROFILE_MIN_SCLK = 0x20,
	AMD_DPM_FORCED_LEVEL_PROFILE_MIN_MCLK = 0x40,
	AMD_DPM_FORCED_LEVEL_PROFILE_PEAK = 0x80,
	AMD_DPM_FORCED_LEVEL_PROFILE_EXIT = 0x100,
	AMD_DPM_FORCED_LEVEL_PERF_DETERMINISM = 0x200,
};

struct smu_dpm_context {
	uint32_t dpm_context_size;
	void *dpm_context;
	void *golden_dpm_context;
	enum amd_dpm_forced_level dpm_level;
	enum amd_dpm_forced_level saved_dpm_level;
	enum amd_dpm_forced_level requested_dpm_level;
	void *dpm_request_power_state;
	void *dpm_current_power_state;
	void *mclk_latency_table;
};

struct smu_bios_boot_up_values
{
	uint32_t			revision;
	uint32_t			gfxclk;
	uint32_t			uclk;
	uint32_t			socclk;
	uint32_t			dcefclk;
	uint32_t			eclk;
	uint32_t			vclk;
	uint32_t			dclk;
	uint16_t			vddc;
	uint16_t			vddci;
	uint16_t			mvddc;
	uint16_t			vdd_gfx;
	uint8_t				cooling_id;
	uint32_t			pp_table_id;
	uint32_t			format_revision;
	uint32_t			content_revision;
	uint32_t			fclk;
	uint32_t			lclk;
	uint32_t			firmware_caps;
};

enum smu_table_id
{
	SMU_TABLE_PPTABLE = 0,
	SMU_TABLE_WATERMARKS,
	SMU_TABLE_CUSTOM_DPM,
	SMU_TABLE_DPMCLOCKS,
	SMU_TABLE_AVFS,
	SMU_TABLE_AVFS_PSM_DEBUG,
	SMU_TABLE_AVFS_FUSE_OVERRIDE,
	SMU_TABLE_PMSTATUSLOG,
	SMU_TABLE_SMU_METRICS,
	SMU_TABLE_DRIVER_SMU_CONFIG,
	SMU_TABLE_ACTIVITY_MONITOR_COEFF,
	SMU_TABLE_OVERDRIVE,
	SMU_TABLE_I2C_COMMANDS,
	SMU_TABLE_PACE,
	SMU_TABLE_ECCINFO,
	SMU_TABLE_COUNT,
};

struct smu_table {
	uint64_t size;
	uint32_t align;
	uint8_t domain;
	uint64_t mc_address;
	void *cpu_addr;
	void *bo;
};

struct smu_table_context
{
	void				*power_play_table;
	uint32_t			power_play_table_size;
	void				*hardcode_pptable;
	unsigned long			metrics_time;
	void				*metrics_table;
	void				*clocks_table;
	void				*watermarks_table;

	void				*max_sustainable_clocks;
	struct smu_bios_boot_up_values	boot_values;
	void                            *driver_pptable;
	void                            *ecc_table;
	struct smu_table		tables[SMU_TABLE_COUNT];
	/*
	 * The driver table is just a staging buffer for
	 * uploading/downloading content from the SMU.
	 *
	 * And the table_id for SMU_MSG_TransferTableSmu2Dram/
	 * SMU_MSG_TransferTableDram2Smu instructs SMU
	 * which content driver is interested.
	 */
	struct smu_table		driver_table;
	struct smu_table		memory_pool;
	struct smu_table		dummy_read_1_table;
	uint8_t                         thermal_controller_type;

	void				*overdrive_table;
	void                            *boot_overdrive_table;
	void				*user_overdrive_table;

	uint32_t			gpu_metrics_table_size;
	void				*gpu_metrics_table;
};

struct amdgpu_irq_src {
	unsigned				num_types;
	void *enabled_types;
	void *funcs;
};

enum amd_asic_type {
	CHIP_TAHITI = 0,
	CHIP_PITCAIRN,	/* 1 */
	CHIP_VERDE,	/* 2 */
	CHIP_OLAND,	/* 3 */
	CHIP_HAINAN,	/* 4 */
	CHIP_BONAIRE,	/* 5 */
	CHIP_KAVERI,	/* 6 */
	CHIP_KABINI,	/* 7 */
	CHIP_HAWAII,	/* 8 */
	CHIP_MULLINS,	/* 9 */
	CHIP_TOPAZ,	/* 10 */
	CHIP_TONGA,	/* 11 */
	CHIP_FIJI,	/* 12 */
	CHIP_CARRIZO,	/* 13 */
	CHIP_STONEY,	/* 14 */
	CHIP_POLARIS10,	/* 15 */
	CHIP_POLARIS11,	/* 16 */
	CHIP_POLARIS12,	/* 17 */
	CHIP_VEGAM,	/* 18 */
	CHIP_VEGA10,	/* 19 */
	CHIP_VEGA12,	/* 20 */
	CHIP_VEGA20,	/* 21 */
	CHIP_RAVEN,	/* 22 */
	CHIP_ARCTURUS,	/* 23 */
	CHIP_RENOIR,	/* 24 */
	CHIP_ALDEBARAN, /* 25 */
	CHIP_NAVI10,	/* 26 */
	CHIP_CYAN_SKILLFISH,	/* 27 */
	CHIP_NAVI14,	/* 28 */
	CHIP_NAVI12,	/* 29 */
	CHIP_SIENNA_CICHLID,	/* 30 */
	CHIP_NAVY_FLOUNDER,	/* 31 */
	CHIP_VANGOGH,	/* 32 */
	CHIP_DIMGREY_CAVEFISH,	/* 33 */
	CHIP_BEIGE_GOBY,	/* 34 */
	CHIP_YELLOW_CARP,	/* 35 */
	CHIP_IP_DISCOVERY,	/* 36 */
	CHIP_LAST,
};

struct amdgpu_acp {
	void *parent;
	void *cgs_device;
	void *private;
	void *acp_cell;
	void *acp_res;
	void *acp_genpd;
};

// Warning, incomplete type for pointer offset purposes
struct amdgpu_device {
	void			*dev;
	void			*pdev;
	struct drm_device		ddev;

#ifdef CONFIG_DRM_AMD_ACP
	struct amdgpu_acp		acp;
#endif
	void *hive;
	/* ASIC */
	enum amd_asic_type		asic_type;
};

#define WORKLOAD_POLICY_MAX 7

struct smu_context {
	void *adev;
	struct amdgpu_irq_src		irq_source;

	void *ppt_funcs;
	void *message_map;
	void *clock_map;
	void *feature_map;
	void *table_map;
	void *pwr_src_map;
	void *workload_map;
	struct mutex			message_lock;
	uint64_t pool_size;

	struct smu_table_context	smu_table;
	struct smu_dpm_context		smu_dpm;
	struct smu_power_context	smu_power;
	struct smu_feature		smu_feature;
	void *display_config;
	struct smu_baco_context		smu_baco;
	struct smu_temperature_range	thermal_range;
	void *od_settings;

	struct smu_umd_pstate_table	pstate_table;
	uint32_t pstate_sclk;
	uint32_t pstate_mclk;

	bool od_enabled;
	uint32_t current_power_limit;
	uint32_t default_power_limit;
	uint32_t max_power_limit;

	/* soft pptable */
	uint32_t ppt_offset_bytes;
	uint32_t ppt_size_bytes;
	void *ppt_start_addr;

	bool support_power_containment;
	bool disable_watermark;

#define WATERMARKS_EXIST	(1 << 0)
#define WATERMARKS_LOADED	(1 << 1)
	uint32_t watermarks_bitmap;
	uint32_t hard_min_uclk_req_from_dal;
	bool disable_uclk_switch;

	uint32_t workload_mask;
	uint32_t workload_prority[WORKLOAD_POLICY_MAX];
	uint32_t workload_setting[WORKLOAD_POLICY_MAX];
	uint32_t power_profile_mode;
	uint32_t default_power_profile_mode;
	bool pm_enabled;
	bool is_apu;

	uint32_t smc_driver_if_version;
	uint32_t smc_fw_if_version;
	uint32_t smc_fw_version;

	bool uploading_custom_pp_table;
	bool dc_controlled_by_gpio;

	struct work_struct throttling_logging_work;
	atomic64_t throttle_int_counter;
	struct work_struct interrupt_work;

	unsigned fan_max_rpm;
	unsigned manual_fan_speed_pwm;

	uint32_t gfx_default_hard_min_freq;
	uint32_t gfx_default_soft_max_freq;
	uint32_t gfx_actual_hard_min_freq;
	uint32_t gfx_actual_soft_max_freq;

	/* APU only */
	uint32_t cpu_default_soft_min_freq;
	uint32_t cpu_default_soft_max_freq;
	uint32_t cpu_actual_soft_min_freq;
	uint32_t cpu_actual_soft_max_freq;
	uint32_t cpu_core_id_select;
	uint16_t cpu_core_num;

	struct smu_user_dpm_profile user_dpm_profile;

	struct stb_context stb_context;
};


#endif // AMDGPU_SMU_H_
