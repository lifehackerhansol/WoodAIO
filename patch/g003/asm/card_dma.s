/*
    card_dma.s
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

	.thumb_func
setupTransfer:
	push	{lr}
	lsr	r0, r0, #9
	ldr	r2, R4_Rom_Base
	add	r0, r2
	lsl	r0, r0, #1
	bl	sddReadSingleBlock
	mov	r1, #0xca
	lsl	r1, #24	@ 0xb7000000
	lsr	r2, r0, #8
	orr	r1, r1, r2
	lsl	r2, r0, #24
	adr	r0, buffer
	str	r1, [r0]
	str	r2, [r0, #4]
	bl	ioRpgSendCommand_init
	@add	sp, #8
	pop	{pc}

	.thumb_func
sddReadSingleBlock:
	push	{r0-r4, lr}
	@sub	sp, #8
	bl	stopSDTransmission
	mov	r4, r0
/*
	mov	r1, #0xcd
	lsl	r1, #24
	lsr	r2, r4, #8
	orr	r1, r2
	lsl	r2, r4, #24
	adr	r0, buffer
	str	r1, [r0]
	str	r2, [r0, #4]
	mov	r1, #4
	mov	r2, #0
	mov	r3, #0
	bl	ioRpgSendCommand
*/
	mov	r1, #0xc9
	lsl	r1, #24
	lsr	r2, r4, #8
	orr	r1, r2
	lsl	r2, r4, #24
	adr	r0, buffer
	str	r1, [r0]
	str	r2, [r0, #4]
	bl	cardWaitReady
	@add	sp, #8
	pop	{r0-r4, pc}

