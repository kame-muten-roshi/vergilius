**/
* _str() function
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
* Returns the character equivalent of a numeric expression.
*
* @param decimal tnExpression
* Specifies the numeric expression to evaluate.
*
* @return string|boolean
* _str() returns a character string equivalent to the specified
* numeric expression; otherwise, _str() returns false (.F.).
*/

#INCLUDE 'constants.h'

FUNCTION _str
    PARAMETERS tnExpression

    * begin { parameter validations }
    IF PARAMETERS() < 1 THEN
        wait_window(LOWER(PROGRAM(0)), LOWER(PROGRAM()), TOO_FEW_ARGUMENTS)
        RETURN .F.
    ENDIF

    IF TYPE('tnExpression') != 'N' THEN
        wait_window(LOWER(PROGRAM(0)), LOWER(PROGRAM()), ;
            STRTRAN(PARAM_MUST_BE_TYPE_NUMERIC, '{}', 'tnExpression'))
        RETURN .F.
    ENDIF
    * end { parameter validations }

    PRIVATE pcExpression, pcDigit
    pcExpression = ALLTRIM(STR(tnExpression, 20, 8))
    pcExpression = STRTRAN(pcExpression, ',', '.')

    DO WHILE .T.
        pcDigit = RIGHT(pcExpression, 1)

        IF pcDigit == '0' THEN
            pcExpression = LEFT(pcExpression, LEN(pcExpression) - 1)
        ELSE
            IF pcDigit == '.' THEN
                pcExpression = LEFT(pcExpression, LEN(pcExpression) - 1)
            ENDIF

            EXIT
        ENDIF
    ENDDO

    RETURN pcExpression
* ENDFUNC
