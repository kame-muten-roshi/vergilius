**/
* createdb() function
*
* Copyright (C) 2000-2024 José Acuña <jacuna.dev@gmail.com>
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
* Creates DBF (data) and CDX (index) files.
* Compatible with FoxPro 2.6a
*
* @param string tcPath
* Specifies the path where the files will be created.
*
* @return boolean
* true if no error has occurred and false otherwise.
*/

FUNCTION createdb
    PARAMETERS tcPath

    * begin { parameter validations }
    IF TYPE('tcPath') != 'C' OR EMPTY(tcPath) THEN
        tcPath = CURDIR()
    ENDIF

    tcPath = ALLTRIM(tcPath)
    tcPath = IIF(RIGHT(tcPath, 1) != '\', tcPath + '\', tcPath)

    IF !_directory() THEN
        RETURN .F.
    ENDIF
    * end { parameter validations }

    PRIVATE pcCurDir
    pcCurDir = SYS(5) + CURDIR()

    SET DEFAULT TO (tcPath)

    * DBF.
    DO marcas1_dbf

    * CDX.
    DO marcas1_cdx

    SET DEFAULT TO (pcCurDir)
* ENDFUNC

**/
* Locates the specified directory.
*
* @return boolean
* _directory() returns true (.T.) if the specified directory is found on the
* disk; otherwise, it returns false (.F.).
*/
FUNCTION _directory
    pnFileHandle = FCREATE(tcPath + 'tm.tmp')

    IF pnFileHandle < 0 THEN
        RETURN .F.
    ENDIF

    =FCLOSE(pnFileHandle)

    DELETE FILE tcPath + 'tm.tmp'   
* ENDFUNC

**/ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *
*                          DBF CREATION SECTION                          *
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

FUNCTION marcas1_dbf
    CREATE TABLE marcas1 ( ;
        codigo N(4), ;
        nombre C(30), ;
        vigente L(1), ;
        id_local N(2) ;
    )
    USE
* ENDFUNC

**/ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *
*                          CDX CREATION SECTION                          *
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
FUNCTION marcas1_cdx
    USE marcas1 EXCLUSIVE
    INDEX ON codigo TAG 'indice1'
    INDEX ON nombre TAG 'indice2'
    USE
* ENDFUNC
