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
    DO familias_dbf
    DO marcas1_dbf
    DO marcas2_dbf

    * CDX.
    DO _index('familias')
    DO _index('marcas1')
    DO _index('marcas2')

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

**/
* Returns the usage status of a file.
*
* @param string tcFileName
* Specifies the full path of the file (must include the file extension).
*
* @return integer
* file_status() returns 0 if the file is not in use, 1 if the file is in use;
* otherwise, file_status() returns 2, which means error.
*/
FUNCTION file_status
    PARAMETERS tcFileName

    * begin { parameter validations }
    IF PARAMETERS() < 1 THEN
        RETURN 2
    ENDIF

    IF TYPE('tcFileName') != 'C' OR EMPTY(tcFileName) THEN
        RETURN 2
    ENDIF

    IF !FILE(tcFileName) THEN
        RETURN 2
    ENDIF
    * end { parameter validations }

    PRIVATE pnFileHandle
    pnFileHandle = FOPEN(tcFileName, 12)    && 12 - Read and Write privileges.

    =FCLOSE(pnFileHandle)

    RETURN IIF(pnFileHandle != -1, 0, 1)
*ENDFUNC

**/
* Generates indexes on the fields 'codigo' and 'nombre'
*
* @return boolean
* _index returns true (.T.) if it can create the indexes; otherwise,
* it returns false (.F.).
*/
FUNCTION _index
    PARAMETER tcTableName

    * begin { parameter validations }
    IF TYPE('tcTableName') != 'C' OR EMPTY(tcTableName) THEN
        RETURN .F.
    ENDIF

    IF !FILE(tcTableName + '.dbf') THEN
        RETURN .F.
    ENDIF

    IF file_status(tcTableName + '.dbf') != 0 THEN
        RETURN .F.
    ENDIF
    * end { parameter validations }

    SELECT 0
    USE (tcTableName) EXCLUSIVE
    DELETE TAG ALL
    INDEX ON codigo TAG 'indice1'
    INDEX ON nombre TAG 'indice2'
    USE
* ENDFUNC

**/ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *
*                          DBF CREATION SECTION                          *
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

FUNCTION familias_dbf
    CREATE TABLE familias ( ;
        codigo N(4), ;
        nombre C(30), ;
        p1 N(6,2), ;
        p2 N(6,2), ;
        p3 N(6,2), ;
        p4 N(6,2), ;
        p5 N(6,2), ;
        vigente L(1), ;
        id_local N(2) ;
    )
    USE
* ENDFUNC

FUNCTION marcas1_dbf
    CREATE TABLE marcas1 ( ;
        codigo N(4), ;
        nombre C(30), ;
        vigente L(1), ;
        id_local N(2) ;
    )
    USE
* ENDFUNC

FUNCTION marcas2_dbf
    CREATE TABLE marcas2 ( ;
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
