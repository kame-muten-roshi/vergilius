**/
* createdb() function
*
* Copyright (C) 2000-2024 Jos� Acu�a <jacuna.dev@gmail.com>
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

    IF !_directory(tcPath) THEN
        RETURN .F.
    ENDIF
    * end { parameter validations }

    PRIVATE pcCurDir
    pcCurDir = SYS(5) + CURDIR()

    SET DEFAULT TO (tcPath)

    * DBF.
    DO depar_dbf
    DO familias_dbf
    DO _table('marcas1')
    DO _table('marcas2')
    DO _table('rubros1')
    DO _table('rubros2')

    * CDX.
    DO _index('depar')
    DO _index('familias')
    DO _index('marcas1')
    DO _index('marcas2')
    DO _index('rubros1')
    DO _index('rubros2')

    SET DEFAULT TO (pcCurDir)
* ENDFUNC

**/ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *
*                              FUNCTION SECTION                              *
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

**/
* _directory(tcDirectoryName) : boolean
* _index(tcTableName) : boolean
* _table(tcTableName) : boolean
* file_status(tcFileName) : integer
* table_exists(tcTableName) : boolean
*/

**/
* Locates the specified directory.
*
* @param string tcDirectoryName
* Specifies the name of the directory to locate.
*
* @return boolean
* _directory() returns true (.T.) if the specified directory is found on the
* disk; otherwise, it returns false (.F.).
*/
FUNCTION _directory
    PARAMETERS tcDirectoryName

    * begin { parameter validations }
    IF PARAMETERS() < 1 THEN
        RETURN .F.
    ENDIF

    IF TYPE('tcDirectoryName') != 'C' OR EMPTY(tcDirectoryName) THEN
        RETURN .F.
    ENDIF
    * end { parameter validations }

    PRIVATE pnFileHandle
    pnFileHandle = FCREATE(tcDirectoryName + 'tm.tmp')

    IF pnFileHandle < 0 THEN
        RETURN .F.
    ENDIF

    =FCLOSE(pnFileHandle)

    DELETE FILE tcDirectoryName + 'tm.tmp'   
*ENDFUNC

**/
* Generates indexes on the 'codigo' and 'nombre' fields called 'indice1' and
* 'indice2' respectively.
*
* @param string tcTableName
* Specifies the name of the table on which indexes will be created (do not
* include the file extension).
*
* @return boolean
* _index returns true (.T.) if it can create the indexes; otherwise, it
* returns false (.F.).
*/
FUNCTION _index
    PARAMETER tcTableName

    * begin { parameter validations }
    IF PARAMETERS() < 1 THEN
        RETURN .F.
    ENDIF

    IF !table_exists(tcTableName) THEN
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
*ENDFUNC

**/
* Generates tables with the fields 'codigo', 'nombre', 'vigente' and
* 'id_local'.
*
* @param string tcTableName
* Specifies the name of the table to create (do not include the file
* extension).
*
* @return boolean
* _table returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION _table
    PARAMETER tcTableName

    * begin { parameter validations }
    IF PARAMETERS() < 1 THEN
        RETURN .F.
    ENDIF

    IF table_exists(tcTableName) THEN
        RETURN .F.
    ENDIF
    * end { parameter validations }

    SELECT 0
    CREATE TABLE (tcTableName) ( ;
        codigo N(4), ;
        nombre C(30), ;
        vigente L(1), ;
        id_local N(2) ;
    )
    USE
*ENDFUNC

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
* Determines whether the table already exists.
*
* @param string tcTableName
* Specifies the name of the table to check (do not include the file extension).
*
* @return boolean
* table_exists returns true (.T.) if the table already exists; otherwise,
* returns false (.F.).
*/
FUNCTION table_exists
    PARAMETER tcTableName

    * begin { parameter validations }
    IF PARAMETERS() < 1 THEN
        RETURN .F.
    ENDIF

    IF TYPE('tcTableName') != 'C' OR EMPTY(tcTableName) THEN
        RETURN .F.
    ENDIF
    * end { parameter validations }

    IF !FILE(tcTableName + '.dbf') THEN
        RETURN .F.
    ENDIF
*ENDFUNC

**/ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *
*                            DBF CREATION SECTION                            *
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

**/
* depar_dbf() : boolean
* familias_dbf() : boolean
*/

**/
* Creates table 'depar'.
*
* @return boolean
* depar_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION depar_dbf
    PRIVATE pcTableName
    pcTableName = 'depar'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        codigo N(3), ;
        nombre C(30), ;
        vigente L(1), ;
        id_local N(2) ;
    )
    USE
*ENDFUNC

**/
* Creates table 'familias'.
*
* @return boolean
* depar_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION familias_dbf
    PRIVATE pcTableName
    pcTableName = 'familias'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
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
*ENDFUNC

**/ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *
*                            CDX CREATION SECTION                            *
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */