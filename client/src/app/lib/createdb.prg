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
    DO accesos_dbf
    DO _table('almacen')
    DO _table('aplicaci')
    DO ausencia_dbf
    DO banco_dbf
    DO barrios_dbf
    DO cabecob_dbf
    DO cabecomp_dbf
    DO cabedesc_dbf
    DO cabefluj_dbf
    DO cabeimpo_dbf
    DO cabemot_dbf
    DO cabemot2_dbf
    DO ciudades_dbf
    DO _table('depar')
    DO familias_dbf
    DO maesprod_dbf
    DO _table('marcas1')
    DO _table('marcas2')
    DO _table('proceden')
    DO proveedo_dbf
    DO _table('rubros1')
    DO _table('rubros2')
    DO unidad_dbf

    * CDX.
    DO accesos_cdx
    DO _index('almacen')
    DO _index('aplicaci')
    DO banco_cdx
    DO _index('barrios')
    DO cabecob_cdx
    DO cabecomp_cdx
    DO cabeimpo_cdx
    DO cabemot_cdx
    DO cabemot2_cdx
    DO _index('ciudades')
    DO _index('depar')
    DO _index('familias')
    DO maesprod_cdx
    DO _index('marcas1')
    DO _index('marcas2')
    DO _index('proceden')
    DO _index('proveedo')
    DO _index('rubros1')
    DO _index('rubros2')
    DO _index('unidad')

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

    DO CASE
    CASE tcTableName == 'aplicaci'
        CREATE TABLE (tcTableName) ( ;
            codigo N(4), ;
            nombre C(40), ;
            vigente L(1) ;
        )
    CASE INLIST(tcTableName, 'almacen', 'depar')
        CREATE TABLE (tcTableName) ( ;
            codigo N(3), ;
            nombre C(30), ;
            vigente L(1), ;
            id_local N(2) ;
        )
    OTHERWISE
        CREATE TABLE (tcTableName) ( ;
            codigo N(4), ;
            nombre C(30), ;
            vigente L(1), ;
            id_local N(2) ;
        )
    ENDCASE

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
* accesos_dbf() : boolean
* banco_dbf() : boolean
* ausencia_dbf() : boolean
* barrios_dbf() : boolean
* cabecob_dbf() : boolean
* cabecomp_dbf() : boolean
* cabedesc_dbf() : boolean
* cabefluj_dbf() : boolean
* cabeimpo_dbf() : boolean
* cabemot_dbf() : boolean
* cabemot2_dbf() : boolean
* ciudades_dbf() : boolean
* familias_dbf() : boolean
* maesprod_dbf() : boolean
* proveedo_dbf() : boolean
* unidad_dbf() : boolean
*/

**/
* Creates table 'accesos'.
*
* @return boolean
* accesos_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION accesos_dbf
    PRIVATE pcTableName
    pcTableName = 'accesos'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        usuario N(4), ;
        fecha_e D(8), ;
        hora_e C(8), ;
        fecha_s D(8), ;
        hora_s C(8) ;
    )
    USE
*ENDFUNC

**/
* Creates table 'ausencia'.
*
* @return boolean
* ausencia_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION ausencia_dbf
    PRIVATE pcTableName
    pcTableName = 'ausencia'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        empleado N(4), ;
        fech_desde D(8), ;
        fech_hasta D(8), ;
        medio_dia L(1), ;
        tipo N(1), ;
        motivo C(50) ;
    )
    USE
*ENDFUNC

**/
* Creates table 'banco'.
*
* @return boolean
* banco_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION banco_dbf
    PRIVATE pcTableName
    pcTableName = 'banco'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        codigo N(3), ;
        nombre C(62), ;
        abreviado C(10), ;
        ruc C(15), ;
        vigente L(1) ;
    )
    USE
*ENDFUNC

**/
* Creates table 'barrios'.
*
* @return boolean
* barrios_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION barrios_dbf
    PRIVATE pcTableName
    pcTableName = 'barrios'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        codigo N(5), ;
        nombre C(30), ;
        departamen N(3), ;
        ciudad N(5), ;
        vigente L(1), ;
        id_local N(2) ;
    )
    USE
*ENDFUNC

**/
* Creates table 'cabecob'.
*
* @return boolean
* cabecob_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION cabecob_dbf
    PRIVATE pcTableName
    pcTableName = 'cabecob'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        tiporeci N(1), ;
        nroreci N(7), ;
        fechareci D(8), ;
        id_local N(2), ;
        moneda N(4), ;
        tipocambio N(9,2), ;
        factura C(1), ;
        cliente N(7), ;
        cobrador N(3), ;
        comision N(6,2), ;
        monto_cobr N(12,2), ;
        fechaanu D(8), ;
        anulado L(1) ;
    )
    USE
*ENDFUNC

**/
* Creates table 'cabecomp'.
*
* @return boolean
* cabecomp_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION cabecomp_dbf
    PRIVATE pcTableName
    pcTableName = 'cabecomp'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        tipodocu N(1), ;
        nrodocu N(9), ;
        fechadocu D(8), ;
        proveedor N(5), ;
        moneda N(4), ;
        tipocambio N(9,2), ;
        qty_cuotas N(3), ;
        porcdesc N(8,4), ;
        importdesc N(12,3), ;
        descuento N(8,4), ;
        monto_fact N(12,2), ;
        monto_ndeb N(12,2), ;
        monto_ncre N(12,2), ;
        monto_pago N(12,2), ;
        consignaci L(1), ;
        id_local N(2) ;
    )
    USE
*ENDFUNC

**/
* Creates table 'cabedesc'.
*
* @return boolean
* cabedesc_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION cabedesc_dbf
    PRIVATE pcTableName
    pcTableName = 'cabedesc'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        id_desc N(10), ;
        nombre C(40), ;
        lista N(1), ;
        porcdesc N(8,4), ;
        cantidad N(5), ;
        fec_inicio D(8), ;
        fec_fin D(8), ;
        fec_alta D(8) ;
    )
    USE
*ENDFUNC

**/
* Creates table 'cabefluj'.
*
* @return boolean
* cabefluj_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION cabefluj_dbf
    PRIVATE pcTableName
    pcTableName = 'cabefluj'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        codigo I(4), ;
        orden V(5), ;
        nombre V(100), ;
        imputable C(1), ;
        desde V(5), ;
        hasta V(5), ;
        signo C(1), ;
        tot_subgru C(1) ;
    )
    USE
*ENDFUNC

**/
* Creates table 'cabeimpo'.
*
* @return boolean
* cabeimpo_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION cabeimpo_dbf
    PRIVATE pcTableName
    pcTableName = 'cabeimpo'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        tipodocu C(1), ;
        nrodocu C(15), ;
        proveedor N(5), ;
        fechadocu D(8), ;
        divisa N(4), ;
        decimales N(2), ;
        cambio_adu N(11,4), ;
        cambio_gto N(11,4), ;
        cambio_vta N(11,4), ;
        almacen N(4), ;
        porcdesc N(8,4), ;
        importdesc N(12,2), ;
        descuento N(8,4), ;
        monto_gast N(12,2), ;
        monto_fact N(12,2), ;
        monto_pago N(12,2) ;
    )
    USE
*ENDFUNC

**/
* Creates table 'cabemot'.
*
* @return boolean
* cabemot_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION cabemot_dbf
    PRIVATE pcTableName
    pcTableName = 'cabemot'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        tipobole N(1), ;
        serie C(1), ;
        nrobole N(7), ;
        fecha D(8), ;
        lstprecio N(1), ;
        almacen N(3), ;
        moneda N(4), ;
        tipocambio N(9,2), ;
        vendedor N(3), ;
        comision_1 N(6,2), ;
        comision_2 N(6,2), ;
        comision_3 N(6,2), ;
        obs1 C(45), ;
        obs2 C(45), ;
        obs3 C(45), ;
        porcdesc N(8,4), ;
        importdesc N(12,2), ;
        descuento N(8,4), ;
        monto_fact N(12,2) ;
    )
    USE
*ENDFUNC

**/
* Creates table 'cabemot2'.
*
* @return boolean
* cabemot2_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION cabemot2_dbf
    PRIVATE pcTableName
    pcTableName = 'cabemot2'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        tipobole N(1), ;
        serie C(1), ;
        nrobole N(7), ;
        fecha D(8), ;
        lstprecio N(1), ;
        almacen N(3), ;
        moneda N(4), ;
        tipocambio N(9,2), ;
        vendedor N(3), ;
        comision_1 N(6,2), ;
        comision_2 N(6,2), ;
        comision_3 N(6,2), ;
        obs1 C(45), ;
        obs2 C(45), ;
        obs3 C(45), ;
        porcdesc N(8,4), ;
        importdesc N(12,2), ;
        descuento N(8,4), ;
        monto_fact N(12,2) ;
    )
    USE
*ENDFUNC

**/
* Creates table 'ciudades'.
*
* @return boolean
* ciudades_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION ciudades_dbf
    PRIVATE pcTableName
    pcTableName = 'ciudades'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        codigo N(5), ;
        nombre C(30), ;
        departamen N(3), ;
        vigente L(1), ;
        id_local N(2), ;
        sifen N(5) ;
    )
    USE
*ENDFUNC

**/
* Creates table 'familias'.
*
* @return boolean
* familias_dbf returns true (.T.) if it can create the table; otherwise, it
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

**/
* Creates table 'maesprod'.
*
* @return boolean
* maesprod_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION maesprod_dbf
    PRIVATE pcTableName
    pcTableName = 'maesprod'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        codigo C(15), ;
        codigo2 C(15), ;
        codorig C(15), ;
        nombre C(40), ;
        aplicacion M(10), ;
        lista3 L(1), ;
        lista4 L(1), ;
        lista5 L(1), ;
        familia N(4), ;
        rubro N(4), ;
        subrubro N(4), ;
        marca N(4), ;
        unidad N(3), ;
        proveedor N(5), ;
        procedenci N(4), ;
        ubicacion C(37), ;
        vigente L(1), ;
        lprecio L(1), ;
        impuesto L(1), ;
        pimpuesto N(6,2), ;
        pcostog N(13,4), ;
        pcostog2 N(13,4), ;
        pcostod N(13,4), ;
        pcostogr N(13,4), ;
        pcostodr N(13,4), ;
        pcostogre N(13,4), ;
        pcostodre N(13,4), ;
        pventag1 N(13,4), ;
        pventag2 N(13,4), ;
        pventag3 N(13,4), ;
        pventag4 N(13,4), ;
        pventag5 N(13,4), ;
        pventad1 N(13,4), ;
        pventad2 N(13,4), ;
        pventad3 N(13,4), ;
        pventad4 N(13,4), ;
        pventad5 N(13,4), ;
        updprices L(1), ;
        paumento1 N(6,2), ;
        paumento2 N(6,2), ;
        paumento3 N(6,2), ;
        paumento4 N(6,2), ;
        paumento5 N(6,2), ;
        stock_min N(11,2), ;
        stock_max N(11,2), ;
        polinvsmin L(1), ;
        polinvsmax L(1), ;
        garantia C(20), ;
        caracter1 C(60), ;
        caracter2 C(60), ;
        caracter3 C(60), ;
        otros1 C(60), ;
        otros2 C(60), ;
        fecucompra D(8), ;
        fecrepo D(8), ;
        stock_actu N(11,2), ;
        stock_ot N(11,2), ;
        id_local N(2), ;
        stock_excl L(1), ;
        id_product C(20) ;
    )
    USE
*ENDFUNC

**/
* Creates table 'proveedo'.
*
* @return boolean
* proveedo_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION proveedo_dbf
    PRIVATE pcTableName
    pcTableName = 'proveedo'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        codigo N(5), ;
        nombre C(40), ;
        direc1 C(60), ;
        direc2 C(60), ;
        ciudad C(25), ;
        telefono C(40), ;
        fax C(25), ;
        e_mail C(60), ;
        ruc C(15), ;
        dias_plazo N(3), ;
        dueno C(40), ;
        teldueno C(25), ;
        gtegral C(40), ;
        telgg C(25), ;
        gteventas C(40), ;
        telgv C(25), ;
        gtemkg C(40), ;
        telgm C(25), ;
        stecnico C(40), ;
        stdirec1 C(60), ;
        stdirec2 C(60), ;
        sttel C(25), ;
        sthablar1 C(60), ;
        vendedor1 C(40), ;
        larti1 C(25), ;
        tvend1 C(25), ;
        vendedor2 C(40), ;
        larti2 C(25), ;
        tvend2 C(25), ;
        vendedor3 C(40), ;
        larti3 C(25), ;
        tvend3 C(25), ;
        vendedor4 C(40), ;
        larti4 C(25), ;
        tvend4 C(25), ;
        vendedor5 C(40), ;
        larti5 C(25), ;
        tvend5 C(25), ;
        saldo_actu N(12), ;
        saldo_usd N(12,2), ;
        vigente C(1), ;
        id_local N(2) ;
    )
    USE
*ENDFUNC

**/
* Creates table 'unidad'.
*
* @return boolean
* unidad_dbf returns true (.T.) if it can create the table; otherwise, it
* returns false (.F.).
*/
FUNCTION unidad_dbf
    PRIVATE pcTableName
    pcTableName = 'unidad'

    IF table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    CREATE TABLE (pcTableName) ( ;
        codigo N(4), ;
        nombre C(30), ;
        simbolo C(5), ;
        divisible L(1), ;
        vigente L(1), ;
        id_local N(2) ;
    )
    USE
*ENDFUNC

**/ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *
*                            CDX CREATION SECTION                            *
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

**/
* accesos_cdx() : boolean
* banco_cdx() : boolean
* cabecob_cdx() : boolean
* cabecomp_cdx() : boolean
* cabeimpo_cdx() : boolean
* cabemot_cdx() : boolean
* cabemot2_cdx() : boolean
* maesprod_cdx() : boolean
*/

**/
* Creates the indexes for the 'accesos' table.
*
* @return boolean
* accesos_cdx returns true (.T.) if it can create the indexes; otherwise, it
* returns false (.F.).
*/
FUNCTION accesos_cdx
    PRIVATE pcTableName
    pcTableName = 'accesos'

    IF !table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    IF file_status(pcTableName + '.dbf') != 0 THEN
        RETURN .F.
    ENDIF

    SELECT 0
    USE (pcTableName) EXCLUSIVE
    DELETE TAG ALL
    INDEX ON usuario TAG 'indice1'
    USE
*ENDFUNC

**/
* Creates the indexes for the 'banco' table.
*
* @return boolean
* banco_cdx returns true (.T.) if it can create the indexes; otherwise, it
* returns false (.F.).
*/
FUNCTION banco_cdx
    PRIVATE pcTableName
    pcTableName = 'banco'

    IF !table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    IF file_status(pcTableName + '.dbf') != 0 THEN
        RETURN .F.
    ENDIF

    SELECT 0
    USE (pcTableName) EXCLUSIVE
    DELETE TAG ALL
    INDEX ON codigo TAG 'indice1'
    INDEX ON nombre TAG 'indice2'
    INDEX ON ruc TAG 'indice3'
    USE
*ENDFUNC

**/
* Creates the indexes for the 'cabecob' table.
*
* @return boolean
* cabecob_cdx returns true (.T.) if it can create the indexes; otherwise, it
* returns false (.F.).
*/
FUNCTION cabecob_cdx
    PRIVATE pcTableName
    pcTableName = 'cabecob'

    IF !table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    IF file_status(pcTableName + '.dbf') != 0 THEN
        RETURN .F.
    ENDIF

    SELECT 0
    USE (pcTableName) EXCLUSIVE
    DELETE TAG ALL
    INDEX ON STR(tiporeci, 1) + STR(nroreci, 7) TAG 'indice1'
    INDEX ON DTOS(fechareci) TAG 'indice2'
    INDEX ON cliente TAG 'indice3'
    USE
*ENDFUNC

**/
* Creates the indexes for the 'cabecomp' table.
*
* @return boolean
* cabecomp_cdx returns true (.T.) if it can create the indexes; otherwise, it
* returns false (.F.).
*/
FUNCTION cabecomp_cdx
    PRIVATE pcTableName
    pcTableName = 'cabecomp'

    IF !table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    IF file_status(pcTableName + '.dbf') != 0 THEN
        RETURN .F.
    ENDIF

    SELECT 0
    USE (pcTableName) EXCLUSIVE
    DELETE TAG ALL
    INDEX ON STR(tipodocu, 1) + STR(nrodocu, 9) + STR(proveedor, 5) + DTOS(fechadocu) TAG 'indice1'
    INDEX ON DTOS(fechadocu) + STR(proveedor, 5) + STR(tipodocu, 1) + STR(nrodocu, 9) TAG 'indice2'
    INDEX ON STR(proveedor, 5) + DTOS(fechadocu) + STR(tipodocu, 1) + STR(nrodocu, 9) TAG 'indice3'
    USE
*ENDFUNC

**/
* Creates the indexes for the 'cabeimpo' table.
*
* @return boolean
* cabeimpo_cdx returns true (.T.) if it can create the indexes; otherwise, it
* returns false (.F.).
*/
FUNCTION cabeimpo_cdx
    PRIVATE pcTableName
    pcTableName = 'cabeimpo'

    IF !table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    IF file_status(pcTableName + '.dbf') != 0 THEN
        RETURN .F.
    ENDIF

    SELECT 0
    USE (pcTableName) EXCLUSIVE
    DELETE TAG ALL
    INDEX ON tipodocu + nrodocu + STR(proveedor, 5) TAG 'indice1'
    INDEX ON DTOS(fechadocu) + STR(proveedor, 5) + tipodocu + nrodocu TAG 'indice2'
    INDEX ON STR(proveedor, 5) + DTOS(fechadocu) + tipodocu + nrodocu TAG 'indice3'
    USE
*ENDFUNC

**/
* Creates the indexes for the 'cabemot' table.
*
* @return boolean
* cabemot_cdx returns true (.T.) if it can create the indexes; otherwise, it
* returns false (.F.).
*/
FUNCTION cabemot_cdx
    PRIVATE pcTableName
    pcTableName = 'cabemot'

    IF !table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    IF file_status(pcTableName + '.dbf') != 0 THEN
        RETURN .F.
    ENDIF

    SELECT 0
    USE (pcTableName) EXCLUSIVE
    DELETE TAG ALL
    INDEX ON STR(tipobole, 1) + serie + STR(nrobole, 7) TAG 'indice1'
    INDEX ON DTOS(fecha) + STR(tipobole, 1) + serie + STR(nrobole, 7) TAG 'indice2'
    INDEX ON STR(tipobole, 1) + serie + STR(nrobole, 7) + DTOS(fecha) TAG 'indice3'
    USE
*ENDFUNC

**/
* Creates the indexes for the 'cabemot2' table.
*
* @return boolean
* cabemot2_cdx returns true (.T.) if it can create the indexes; otherwise, it
* returns false (.F.).
*/
FUNCTION cabemot2_cdx
    PRIVATE pcTableName
    pcTableName = 'cabemot2'

    IF !table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    IF file_status(pcTableName + '.dbf') != 0 THEN
        RETURN .F.
    ENDIF

    SELECT 0
    USE (pcTableName) EXCLUSIVE
    DELETE TAG ALL
    INDEX ON STR(tipobole, 1) + serie + STR(nrobole, 7) TAG 'indice1'
    INDEX ON DTOS(fecha) + STR(tipobole, 1) + serie + STR(nrobole, 7) TAG 'indice2'
    INDEX ON STR(tipobole, 1) + serie + STR(nrobole, 7) + DTOS(fecha) TAG 'indice3'
    USE
*ENDFUNC

**/
* Creates the indexes for the 'maesprod' table.
*
* @return boolean
* maesprod_cdx returns true (.T.) if it can create the indexes; otherwise, it
* returns false (.F.).
*/
FUNCTION maesprod_cdx
    PRIVATE pcTableName
    pcTableName = 'maesprod'

    IF !table_exists(pcTableName) THEN
        RETURN .F.
    ENDIF

    IF file_status(pcTableName + '.dbf') != 0 THEN
        RETURN .F.
    ENDIF

    SELECT 0
    USE (pcTableName) EXCLUSIVE
    DELETE TAG ALL
    INDEX ON codigo TAG 'indice1'
    INDEX ON nombre TAG 'indice2'
    INDEX ON rubro TAG 'indice3'
    INDEX ON subrubro TAG 'indice4'
    INDEX ON marca TAG 'indice5'
    INDEX ON codigo2 TAG 'indice6'
    INDEX ON codorig TAG 'indice7'
    INDEX ON VAL(codigo) TAG 'indice8'
    INDEX ON familia TAG 'indice9'
    INDEX ON nombre TAG 'indice10' FOR vigente
    INDEX ON codigo TAG 'indice11' FOR vigente
    INDEX ON codigo2 TAG 'indice12' FOR vigente
    INDEX ON codorig TAG 'indice13' FOR vigente
    INDEX ON ubicacion TAG 'indice14'
    USE
*ENDFUNC
