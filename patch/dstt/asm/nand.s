/*
    nand.s
    Copyright (C) 2010 yellow wood goblin

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

	.include	"sd_read.s"
	.include	"sd_write.s"

/*
in:
r0 - flash address
r1 - buffer
*/
	.thumb_func
sddReadSingleBlock_nand:
	push	{r0-r5, lr}
	sub	sp, #8
	lsr	r0, #9
	lsl	r2, r0, #25
	lsr	r2, #23
	lsr	r0, #7
	lsl	r0, #9
	bl	sddReadSingleBlock
	ldr	r0, [r1, r2]
	mov	r4, r0
	mov	r5, r1

	mov	r1, #0x53
	lsl	r1, #24
	lsr	r2, r4, #8
	orr	r1, r2
	lsl	r2, r4, #24
	str	r1, [sp]
	str	r2, [sp, #4]
	mov	r0, sp
	mov	r1, #4
	mov	r2, #0
	mov	r3, #0
	bl	ioRpgSendCommand

	mov	r1, #0x80
	lsl	r1, #24
	lsr	r2, r4, #8
	orr	r1, r2
	lsl	r2, r4, #24
	str	r1, [sp]
	str	r2, [sp, #4]
	mov	r0, sp
	bl	cardWaitReady

	mov	r1, #0x81
	lsl	r1, #24
	lsr	r2, r4, #8
	orr	r1, r2
	lsl	r2, r4, #24
	str	r1, [sp]
	str	r2, [sp, #4]
	mov	r0, sp
	mov	r1, #0x80
	lsl	r1, #2	@ #0x200
	mov	r2, #0
	mov	r3, r5
	bl	ioRpgSendCommand
	add	sp, #8
	pop	{r0-r5, pc}

/*
in:
r0 - flash address
r1 - buffer
*/
	.thumb_func
sddWriteSingleBlock_nand:
	push	{r0-r5, lr}
	sub	sp, #508
	sub	sp, #4
	mov	r5, r1
	lsr	r0, #9
	lsl	r2, r0, #25
	lsr	r2, #23
	lsr	r0, #7
	lsl	r0, #9
	mov	r1, sp
	bl	sddReadSingleBlock
	ldr	r0, [r1, r2]
	mov	r4, r0

	mov	r1, #0x51
	lsl	r1, #24
	lsr	r2, r4, #8
	orr	r1, r2
	lsl	r2, r4, #24
	ldr	r0, DSTT_Save_Add
	orr	r2, r0
	str	r1, [sp]
	str	r2, [sp, #4]
	mov	r0, sp
	mov	r1, #4
	mov	r2, #0
	mov	r3, #0
	bl	ioRpgSendCommand

	mov	r1, #0x50
	lsl	r1, #24
	lsr	r2, r4, #8
	orr	r1, r2
	lsl	r2, r4, #24
	ldr	r0, DSTT_Save_Add
	orr	r2, r0
	str	r1, [sp]
	str	r2, [sp, #4]
	mov	r0, sp
	bl	cardWaitReady

	mov	r1, #0x52
	lsl	r1, #24
	lsr	r2, r4, #8
	orr	r1, r2
	lsl	r2, r4, #24
	ldr	r0, DSTT_Save_Add
	orr	r2, r0
	str	r1, [sp]
	str	r2, [sp, #4]
	mov	r0, sp
	mov	r1, #4
	mov	r2, #0
	mov	r3, #0
	bl	ioRpgSendCommand

	mov	r1, #0x82
	lsl	r1, #24
	lsr	r2, r4, #8
	orr	r1, r2
	lsl	r2, r4, #24
	ldr	r0, DSTT_Save_Add
	orr	r2, r0
	str	r1, [sp]
	str	r2, [sp, #4]
	mov	r0, sp
	mov	r1, r5
	bl	cardWrite

	mov	r1, #0x50
	lsl	r1, #24
	lsr	r2, r4, #8
	orr	r1, r2
	lsl	r2, r4, #24
	ldr	r0, DSTT_Save_Add
	orr	r2, r0
	str	r1, [sp]
	str	r2, [sp, #4]
	mov	r0, sp
	bl	cardWaitReady

	mov	r1, #0x56
	lsl	r1, #24
	lsr	r2, r4, #8
	orr	r1, r2
	lsl	r2, r4, #24
	ldr	r0, DSTT_Save_Add
	orr	r2, r0
	str	r1, [sp]
	str	r2, [sp, #4]
	mov	r0, sp
	mov	r1, #4
	mov	r2, #0
	mov	r3, #0
	bl	ioRpgSendCommand

	mov	r1, #0x50
	lsl	r1, #24
	lsr	r2, r4, #8
	orr	r1, r2
	lsl	r2, r4, #24
	ldr	r0, DSTT_Save_Add
	orr	r2, r0
	str	r1, [sp]
	str	r2, [sp, #4]
	mov	r0, sp
	bl	cardWaitReady

/*
	mov	r1, #0xbe
	lsl	r1, #24
	lsr	r2, r4, #8
	orr	r1, r2
	lsl	r2, r4, #24
	str	r1, [sp]
	str	r2, [sp, #4]
	mov	r0, sp
	mov	r1, r5
	bl	cardWrite
	mov	r1, #0xbc
	lsl	r1, #24
	lsr	r2, r4, #8
	orr	r1, r2
	lsl	r2, r4, #24
	str	r1, [sp]
	str	r2, [sp, #4]
	mov	r0, sp
	bl	cardWaitReady
*/
	add	sp, #508
	add	sp, #4
	pop	{r0-r5, pc}
