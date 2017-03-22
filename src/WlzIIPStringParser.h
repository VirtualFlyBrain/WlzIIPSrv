#if defined(__GNUC__)
#ident "University of Edinburgh $Id$"
#else
static char _WlzIIPStringParser_h[] = "University of Edinburgh $Id: f4b9c0f174dd02f7e7edf9c4b255791dddd73ff9 $";
#endif
/*!
* \file         WlzIIPStringParser.h
* \author       Bill Hill
* \date         June 2016
* \version      $Id: f4b9c0f174dd02f7e7edf9c4b255791dddd73ff9 $
* \par
* Address:
*               MRC Human Genetics Unit,
*               MRC Institute of Genetics and Molecular Medicine,
*               University of Edinburgh,
*               Western General Hospital,
*               Edinburgh, EH4 2XU, UK.
* \par
* Copyright (C), [2016],
* The University Court of the University of Edinburgh,
* Old College, Edinburgh, UK.
* 
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be
* useful but WITHOUT ANY WARRANTY; without even the implied
* warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
* PURPOSE.  See the GNU General Public License for more
* details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the Free
* Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA  02110-1301, USA.
* \brief	Prototypes of functions for parsing strings within the
* 		Woolz IIP server.
* \ingroup	WlzIIPServer
*/

#ifdef __cplusplus
extern "C"
{
#endif

extern int			WlzIIPStrParseIdxAndPos(
				  int *dstNIdx,
				  int *idx,
				  int *dstNPos, WlzDVertex3 *pos,
				  const char *str);

#ifdef __cplusplus
}
#endif

