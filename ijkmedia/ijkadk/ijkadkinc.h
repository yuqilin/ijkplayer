/*****************************************************************************
 * ijkadkinc.h
 *****************************************************************************
 *
 * copyright (c) 2013-2014 Zhang Rui <bbcallen@gmail.com>
 *
 * This file is part of ijkPlayer.
 *
 * ijkPlayer is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * ijkPlayer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with ijkPlayer; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#ifndef IJKADK__IJKADKINC_H
#define IJKADK__IJKADKINC_H

#include <stdint.h>
#include <jni.h>
#include <assert.h>

#define IJKADK_VALIDATE(condition__) (assert(!!condition__))

#define IJKADK_CHECK_EXCEPTION(env__)

#define IJKADK_FIND_CLASS(env__, var__, classsign__) \
    do { \
    	var__ = (env__)->FindClass(classsign__); \
    	IJKADK_VALIDATE((var__)); \
    } while(0)

#define IJKADK_FIND_METHOD(env__, var__, clazz__, name__, sign__) \
    do { \
        var__ = (env__)->GetMethodID(clazz__, name__, sign__); \
        IJKADK_VALIDATE((var__)); \
    } while(0)

#endif /* IJKADK__IJKADKINC_H */
