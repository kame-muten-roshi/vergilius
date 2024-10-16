**/
* _dtos() function
*
* Copyright (C) 2000-2023 José Acuña <jacuna.dev@gmail.com>
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <https://www.gnu.org/licenses/>.
*/

**/
* Returns a character-string date in a yyyy-mm-dd format from a specified Date
* or DateTime expression.
*
* @param date|datetime tdDate
* Specifies the Date expression _DTOS( ) converts to an ten-digit character
* string.
*
* @return string|boolean
* string if no error has occurred and false otherwise.
*/

#INCLUDE 'constants.h'

FUNCTION _dtos
    LPARAMETERS tdDate

    * begin {parameter validations}
    IF PARAMETERS() < 1 THEN
        wait_window(LOWER(PROGRAM(0)), LOWER(PROGRAM()), TOO_FEW_ARGUMENTS)
        RETURN .F.
    ENDIF

    IF !INLIST(VARTYPE(tdDate), 'D', 'T')  THEN
        wait_window(LOWER(PROGRAM(0)), LOWER(PROGRAM()), ;
            STRTRAN(PARAM_MUST_BE_TYPE_DATE_OR_DATETIME, '{}', 'tdDate'))
        RETURN .F.
    ENDIF
    * end {parameter validations}

    RETURN LEFT(DTOS(tdDate), 4) + '-' + ;
           SUBSTR(DTOS(tdDate), 5, 2) + '-' + ;
           RIGHT(DTOS(tdDate), 2)
ENDFUNC
