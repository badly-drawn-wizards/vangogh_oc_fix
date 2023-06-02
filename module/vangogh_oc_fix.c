// SPDX-License-Identifier: GPL-2.0-only
/*
 * Here's a sample kernel module showing the use of kprobes to dump a
 * stack trace and selected registers when kernel_clone() is called.
 *
 * For more information on theory of operation of kprobes, see
 * Documentation/trace/kprobes.rst
 *
 * You will see the trace data in /var/log/messages and on the console
 * whenever kernel_clone() is invoked to create a new process.
 */
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/kprobes.h>
#include "amdgpu_smu.h"

static char symbol[KSYM_NAME_LEN] = "vangogh_od_edit_dpm_table";

static uint cpu_default_soft_max_freq = 3500;
module_param(cpu_default_soft_max_freq, uint, 0644);
MODULE_PARM_DESC(cpu_default_soft_max_freq, "The max CPU clock set to be allowable through powerplay");

/* For each probe you need to allocate a kprobe structure */
static struct kprobe kp = {
	.symbol_name = symbol,
};

int smu_sanity_check(struct smu_context* smu) {
    struct amdgpu_device *adev;
    enum amd_asic_type asic;
    if (!smu) {
        pr_err("'smu' is null");
    }
    adev = smu->adev;
    if (!adev) {
        pr_err("smu->adev is null");
        return -1;
    }
    asic = adev->asic_type;
    if(asic != CHIP_VANGOGH) {
        pr_err("ASIC Name is not CHIP_VANGOGH but %d. smu->cpu_default_soft_max_freq is %d", asic, smu->cpu_default_soft_max_freq);
        return -1;
    }
    return 0;
}

/* kprobe pre_handler: called just before the probed instruction is executed */
static int __kprobes handler_pre(struct kprobe *p, struct pt_regs *regs)
{
#ifdef CONFIG_X86
    struct smu_context *smu = (struct smu_context*)regs->di;
    uint32_t prev;
    if (smu_sanity_check(smu)) {
        pr_err("smu_context does look right. Refusing to modify amdgpu smu limits");
        return 0;
    }

    prev = smu->cpu_default_soft_max_freq;

    if (prev == cpu_default_soft_max_freq)
        return 0;

    pr_info("Setting cpu_default_soft_max_freq from %d to %d", prev, cpu_default_soft_max_freq);
    // Prolly don't need the lock, but w/e
    mutex_lock(&smu->message_lock);
    smu->cpu_default_soft_max_freq = cpu_default_soft_max_freq;
    mutex_unlock(&smu->message_lock);
#endif
    return 0;
}

/* kprobe post_handler: called after the probed instruction is executed */
static void __kprobes handler_post(struct kprobe *p, struct pt_regs *regs,
				unsigned long flags)
{
#ifdef CONFIG_X86
#endif
}

static int __init kprobe_init(void)
{
	int ret;
	kp.pre_handler = handler_pre;
	kp.post_handler = handler_post;

	ret = register_kprobe(&kp);
	if (ret < 0) {
		pr_err("register_kprobe failed, returned %d\n", ret);
		return ret;
	}
	pr_info("Planted kprobe at %p\n", kp.addr);
	return 0;
}

static void __exit kprobe_exit(void)
{
	unregister_kprobe(&kp);
	pr_info("kprobe at %p unregistered\n", kp.addr);
}

module_init(kprobe_init)
module_exit(kprobe_exit)

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Reuben Steenekamp <reuben.steenekamp@gmail.com>");
MODULE_DESCRIPTION("Override AMD Van Gogh APU PowerPlay limits for CPU");
