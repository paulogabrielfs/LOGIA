#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "TbiConn.ch"

#Define STR_PULA   Chr(13) + Chr(10)

User Function sendELK(cxEmp, cxFili)
    Local cQuery        := ""
    Local cRet          := ""
    Local aCab          := {}
    Local aLin          := {}
    Local cRecno        := ""
    Local cJson         := ""  
    Local cURL          := ""
    Local cPATH         := ""
    Local cTable        := ""
    Local cUser         := ""
    Local cPass         := ""
    Local cAuth         := ""
    Local aHeader       := {}
    Local cResult       := ""
    Local cAuxEmp       := ""
    Local oRestClient

    DEFAULT cxEmp    := "99"
    DEFAULT cxFili   := "01"

    // If ValType(cxEmp) == "A"
    //     cAuxEmp := cxEmp[1]
    //     cxFili  := cxEmp[2]
    // Else
    //     cAuxEmp := cxEmp
    // EndIf

    // PREPARE ENVIRONMENT EMPRESA cAuxEmp FILIAL cxFili

    cURL          := ALLTRIM(SuperGetMV('ELK_TVSURL',,'http://35.184.80.233:9200'))
    cPATH         := ALLTRIM(SuperGetMV('ELK_PATH',,'/logia/protheus'))
    cTable        := ALLTRIM(SuperGetMV('ELK_TABELA',,'ZLH'))
    cUser         := ALLTRIM(SuperGetMV('ELK_USER',,'user'))
    cPass         := ALLTRIM(SuperGetMV('ELK_PASS',,'eCF6yrLBY9DX'))
    cAuth         := Encode64(cUser+":"+cPass)

    oRestClient := FWRest():New(cURL)

    cQuery := " SELECT        "                     + STR_PULA
    cQuery += "  "+cTable+"_EMP,     "              + STR_PULA
    cQuery += "  "+cTable+"_ERROR,   "              + STR_PULA
    cQuery += "  "+cTable+"_ERRMSG,  "              + STR_PULA
    cQuery += "  "+cTable+"_ERRCOD,  "              + STR_PULA
    cQuery += "  "+cTable+"_METHOD,  "              + STR_PULA
    cQuery += "  "+cTable+"_EPSTIM,  "              + STR_PULA
    cQuery += "  "+cTable+"_EPOINT,  "              + STR_PULA
    cQuery += "  "+cTable+"_LOC,     "              + STR_PULA
    cQuery += "  "+cTable+"_STATUS,  "              + STR_PULA
    cQuery += "  "+cTable+"_TSINI,   "              + STR_PULA
    cQuery += "  "+cTable+"_TSFIM,   "              + STR_PULA
    cQuery += "  "+cTable+"_TSINT,   "              + STR_PULA
    cQuery += "  "+cTable+"_OBJIN,   "              + STR_PULA
    cQuery += "  "+cTable+"_OBJOUT,   "              + STR_PULA
    cQuery += "  R_E_C_N_O_          "              + STR_PULA
    cQuery += "  FROM " +RetSQLName(cTable)         + STR_PULA
    cQuery += "  WHERE "+cTable+"_STATUS != 'I'  "  + STR_PULA
    cQuery += "  AND D_E_L_E_T_ != '*'  "           + STR_PULA
    cQuery := ChangeQuery(cQuery)


    //Executando consulta
    TCQuery cQuery New Alias "QRY_ELK"
    
    //Percorrendo os registros
    While ! QRY_ELK->(EoF())

        If UPPER(&("QRY_ELK->"+cTable+"_STATUS")) != 'P'
            DbSelectArea(cTable)
            &(cTable+"->(DBGOTO(QRY_ELK->R_E_C_N_O_))")
            RecLock(cTable, .F.)
            &(cTable+"->(dbDelete())")
            &(cTable+"->(MsUnLock())")
        EndIf

        cRecno := QRY_ELK->R_E_C_N_O_ 
        DbSelectArea(cTable)
        &(cTable+"->(DBGOTO("+cValToChar(cRecno)+"))")

        //Titulo dos campos
        aCab   :=  {"employeer", "error" , "errorMessage" , "errorCode", "method", "elapsedTime","endpoint","location","CreateDate","@timestampEnd","@timestampStart","ObjectIn","ObjectOut", "Type"}
        
        //Itens  //Montar registro
        aLin   := {{ALLTRIM(cValtoChar(&("QRY_ELK->"+cTable+"_EMP"))),IIF(UPPER(ALLTRIM(cValtoChar(&("QRY_ELK->"+cTable+"_ERROR")))) == UPPER("FALSE"),.F.,.T.),ALLTRIM(cValtoChar(&("QRY_ELK->"+cTable+"_ERRMSG"))),VAL(ALLTRIM(&("QRY_ELK->"+cTable+"_ERRCOD"))),ALLTRIM(cValtoChar(&("QRY_ELK->"+cTable+"_METHOD"))),ALLTRIM(cValtoChar(&("QRY_ELK->"+cTable+"_EPSTIM"))),ALLTRIM(cValtoChar(&("QRY_ELK->"+cTable+"_EPOINT"))),ALLTRIM(cValtoChar(&("QRY_ELK->"+cTable+"_LOC"))),ALLTRIM(cValtoChar(&("QRY_ELK->"+cTable+"_TSINI"))),ALLTRIM(cValtoChar(&("QRY_ELK->"+cTable+"_TSFIM"))),ALLTRIM(cValtoChar(&("QRY_ELK->"+cTable+"_TSINI"))), ALLTRIM(cValtoChar(&(cTable+"->"+cTable+"_OBJIN"))),ALLTRIM(cValtoChar(&(cTable+"->"+cTable+"_OBJOUT"))),ALLTRIM(cValtoChar(&(cTable+"->"+cTable+"_TYPE")))}}
            
        //Chama a funcao para gerar o JSON.
        cRet    := JSON( { cTable , aCab, aLin} )

        

        //Enviar Registro
        oRestClient := FWRest():New(cURL)
        aHeader := {}
        oRestClient:setPath(cPATH)
        // aadd(aHeader,'Authorization:  BASIC '+cAuth)
        aadd(aHeader,'Content-Type:application/json')
        cRet := EncodeUTF8(cRet)
        oRestClient:SetPostParams(cRet)
        oRestClient:Post(aHeader)
        cResult := oRestClient:CRESULT

        FWJsonDeserialize(cResult,@cJson)

        //Atualizar registro Recno atual
        if At("_id",cResult) != 0
            RecLock(cTable, .F.)
            
            &(cTable+"->"+cTable+"_TSINT")  := FWTimeStamp(5,date(),TIME())
            &(cTable+"->"+cTable+"_STATUS") := "I"
            &(cTable+"->"+cTable+"_COD")    := cJson:_ID

            &(cTable+"->(MsUnLock())")
        ENDIF 
       QRY_ELK->(DbSkip())
    EndDo
    QRY_ELK->(DbCloseArea())

    // RESET ENVIRONMENT

Return .T.

/*/{Protheus.doc} 
//TODO (PT-BR) metodo que cria e formara um Json
@author Jorge Hernandes
@version 1.0
/*/

Static function JSON(aGeraJson)
    Local cJSON  := ""                   
    Local cTable := aGeraJson[1]                    
    Local aCab   := aGeraJson[2]  
    Local aLin   := aGeraJson[3]  
    
    FOR L:= 1 TO LEN( aLin )
    
        cJSON += '{'
    
        for C:= 1 to Len( aCab ) 
        
            IF VALTYPE(aLin[L][C]) = "C"  
                If aCab[C] == "ObjectIn"
                    cConteudo := VldObj(aLin[L][C])
                ElseIf aCab[C] == "ObjectOut"
                    cConteudo := VldObj(aLin[L][C])
                ELSE
                    cConteudo := '"'+aLin[L][C]+'" '
                EndIf
            ELSEIF VALTYPE(aLin[L][C]) = "N"
                cConteudo := ALLTRIM(STR(aLin[L][C]))
            ELSEIF VALTYPE(aLin[L][C]) = "D"
                cConteudo := '"'+DTOC(aLin[L][C])+'"'
            ELSEIF VALTYPE(aLin[L][C]) = "L"
                cConteudo := IF(aLin[L][C], 'true' , 'false') 
            ELSE
                cConteudo := '"'+aLin[L][C]+'"'
            ENDIF               
    
            cJSON += '"'+aCab[C]+'":' + cConteudo
    
            IF C < LEN(aCab)
            cJSON += ','
            ENDIF
    
        Next
        cJSON += '}'
        IF L < LEN(aLin)
        cJSON += ','
        ENDIF
            
    Next
 
Return cJSON

Static Function VldObj(cXml)
Local cJson
Local wrk
Local oXml
Local cError := ""
Local cWarning := ""
Local oObj

    oXml  := XmlParser( cXml, "_", @cError, @cWarning )

    If (oXml == NIL )
        If FWJsonDeserialize(cXml,@oObj)
            cJson := cXml
        Else
            cJson := '{"errorCode":400, "errorMessage":"Bad Request"}'
        Endif
    Else
        cJson := FWJsonSerialize(oXml,.T.,.T.)
    Endif
Return cJson