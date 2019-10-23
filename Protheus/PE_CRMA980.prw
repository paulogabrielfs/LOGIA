#include "protheus.ch"
#include "parmtype.ch"

User Function CRMA980()
    Local aParam     := PARAMIXB
    Local xRet       := .T.
    Local oObj       := ''
    Local cIdPonto   := ''
    Local cIdModel   := ''
    Local lIsGrid    := .F.

    Local nLinha     := 0
    Local nQtdLinhas := 0
    Local cMsg       := ""

    Local aObj       := {"TOTVS", "MATA010", "Cadastro de produtos", "", "", "WINDOWS"}

    PRIVATE TESTE := ""

    If aParam <> NIL
        oObj        := aParam[1]
        cIdPonto    := aParam[2]
        cIdModel    := aParam[3]
        lIsGrid     := ( Len( aParam ) > 3 )

        If cIdPonto == "FORMCOMMITTTSPRE" .And. cIdModel == "CRMA980"
            aObj := {"TOTVS", "MATA010", "Cadastro de produtos", "", "", "WINDOWS"}
            TESTE := U_saveELK(,aObj,"")
            SB1->B1_ZLHREC := cValToChar(TESTE)
            M->B1_ZLHREC := cValToChar(TESTE)
        ElseIf cIdPonto == "MODELCOMMITNTTS" .And. cIdModel == "CRMA980"
            aObj := {"", "", "", ""}
            cTst := SB1->B1_ZLHREC
            U_saveELK(,aObj,TESTE)
        EndIf
    EndIf
Return xRet