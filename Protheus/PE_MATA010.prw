User Function ITEM()
Local aParam     := PARAMIXB
Local xRet       := .T.
Local oObj       := ''
Local cIdPonto   := ''
Local cIdModel   := ''
Local lIsGrid    := .F.

Local nLinha     := 0
Local nQtdLinhas := 0
Local cMsg       := ''

Local aObj := {"TOTVS", "MATA010", "Cadastro de produtos", "", "", "WINDOWS"}

PRIVATE TESTE := ""



If aParam <> NIL
      
       oObj       := aParam[1]
       cIdPonto   := aParam[2]
       cIdModel   := aParam[3]
       lIsGrid    := ( Len( aParam ) > 3 )
      
       // If lIsGrid
       //       nQtdLinhas := oObj:GetQtdLine()
       //       nLinha     := oObj:nLine
       // EndIf
      
       If cIdPonto == 'FORMCOMMITTTSPRE'
              aObj := {"TOTVS", "MATA010", "", "", "", "WINDOWS"}
              TESTE := U_saveELK(,aObj,"")
              SB1->B1_ZLHREC := cValToChar(TESTE)
              M->B1_ZLHREC := cValToChar(TESTE)
       ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
            aObj := {"", "Cadastro de produtos", "", ""}
            cTst := IIF(!Empty(SB1->B1_ZLHREC), SB1->B1_ZLHREC, M->B1_ZLHREC)
              cTst := M->B1_ZLHREC
            U_saveELK(,aObj,cTst)
            U_sendELK()
        EndIf

EndIf

Return xRet