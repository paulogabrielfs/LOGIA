#include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FwCommand.ch"
#INCLUDE 'FWMVCDef.ch'

User Function saveELK(lRecorded,aZLH,cRec)

    Local dData     := Date()
    Local cCod      := ""
    Local cPass     := ALLTRIM(SuperGetMV('ELK_PASS',,'eCF6yrLBY9DX'))
    Local cTable    := ALLTRIM(SuperGetMV('ELK_TABELA',,'ZLH'))
    Default cRec    := ""
    DbSelectArea(cTable)
    
    If empty(cRec)
        RecLock(cTable, .T.)

        &(cTable+"->"+cTable+"_TSINI")  := FWTimeStamp(5,dData,TIME())
        &(cTable+"->"+cTable+"_EMP")    := aZLH[1]
        &(cTable+"->"+cTable+"_EPOINT") := StrTran(aZLH[2],  "/", "")
        &(cTable+"->"+cTable+"_METHOD") := aZLH[3]
        &(cTable+"->"+cTable+"_LOC")    := aZLH[4]
        &(cTable+"->"+cTable+"_OBJIN")  := aZLH[5]
        &(cTable+"->"+cTable+"_TYPE")   := aZLH[6]
       
       &(cTable+"->(MsUnLock())")
       
       cCod := RECNO()
    Else
         &(cTable+"->(DBGOTO("+cValTOChar(cRec)+"))")

        RecLock(cTable, .F.)
            &(cTable+"->"+cTable+"_ERROR")  := aZLH[1]
            &(cTable+"->"+cTable+"_ERRMSG") := aZLH[2]
            &(cTable+"->"+cTable+"_ERRCOD") := aZLH[3]
            &(cTable+"->"+cTable+"_OBJOUT") := aZLH[4]
            &(cTable+"->"+cTable+"_TSFIM")  := FWTimeStamp(5,dData,TIME())
            &(cTable+"->"+cTable+"_STATUS") := "P"

            cHrIni 	:= SUBSTR(&(cTable+"->"+cTable+"_TSINI"), 12, 8)
            cHrFim  := SUBSTR(&(cTable+"->"+cTable+"_TSFIM"), 12, 8)

            //&(cTable+"->"+cTable+"_STATUS") := ElapTime(cHrIni,cHrFim)
        &(cTable+"->(MsUnLock())")
    EndIf

    MsUnLock() // Confirma e finaliza a operacao

Return cCod