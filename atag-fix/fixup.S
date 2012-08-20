/* Fixup the atags for dragonboard (and possibly other targets). */
/*
 * The bootloader on some targets passes an ATAG in that sets the
 * first memory region to be 2MB after the actual start of memory.
 * With newer upstream kernels, the PHYS_OFFSET must be a multiple of
 * a large boundary (currently 128MB).  Without devicetree, we work
 * around this with an early init hook, and a fixup that adds a
 * reservation.  These hooks don't run in time to fix it in Device
 * tree.
 *
 * The following code can be prepended to the zImage.  It adjusts the
 * memory atag back down to the actual start of memory.  The
 * assumption is that the device tree will describe the necessary
 * memory reservation.  The zImage is relocatable, so it is easy to
 * prepend this code.
 */

	/* Figure out what the broken mem tag would be */
	mov	r8, pc
	and	r8, r8, #0xf8000000
	add	r8, r8, #0x00200000

	/* R2 is where the atags are passed.  r5 on are scratch. */
	mov	r5, r2
	ldr	r7, .tag_mem

.next:
	/* Load the tag, and check. */
	ldr	r6, [r5, #4]
	cmp	r6, #0
	beq	.done

	/* Is the a 'mem' tag. */
	cmp	r6, r7
	bne	.not_mem

	/* Is this memory base what we want? */
	ldr	r6, [r5, #12]
	cmp	r6, r8

	subeq	r6, r6, #0x200000
	streq	r6, [r5, #12]
	ldreq	r6, [r5, #8]
	addeq	r6, r6, #0x200000
	streq	r6, [r5, #8]

.not_mem:
	/* Move r5 to the next tag. */
	ldr	r6, [r5, #0]
	add	r5, r5, r6, asl #2
	b	.next

.tag_mem:
	.word	0x54410002

.done:
