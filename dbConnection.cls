' ADO Abstraction Class for VBA
' Christopher Harrison

' This is meant for simple, read-only access to an ODBC database (e.g., for
' report writing in Excel, etc.). It constructs parameterised queries, with
' optional varchar parameters (ordered, not named) passed as a collection.
' (SELECT statements, at least, are weakly typed (or can be casted), so using
' strings isn't really a concern.)

' Notes:
' 1. The DSN password is encrypted in memory, for some semblance of security.
'    However, so is the encryption key, so don't rely on this!
' 2. Contains code that changes the mouse pointer to a waiting cursor (when
'    connecting and fetching data) that isn't necessarily portable between
'    applications. The code here is specific to Microsoft Excel.

' Requires:
' *  Microsoft ActiveX Data Objects Library

' Example:

' Dim myDB as dbConnection
' Dim myQuery as String
' Dim myParameters as Collection
' Dim myData as ADODB.Recordset
'
' Set myDB = New dbConnection
' If myDB.Connect("someDSN", "username", "password") Then
'     Debug.Print "Connected to " & myDB.Connected
'
'     myQuery = "select id, name from table where id > ? and id < ?"
'
'     Set myParameters = New Collection
'     myParameters.Add "1"
'     myParameters.Add "5"
'
'     Set myData = myDB.Query(myQuery, myParameters)
'     If Not myData Is Nothing Then
'         myData.MoveFirst
'         While Not myData.EOF
'             Debug.Print myData!id & ": " & myData!name
'             myData.MoveNext
'         Wend
'         Set myData = Nothing
'     Else
'         Debug.Print "No data found"
'     End If
'
'     Set myParameters = Nothing
' Else
'     Debug.Print "Cannot connect"
' End If
'
' Set myDB = Nothing

Private pDSN As String
Private pUsername As String
Private pXPassword As String
Private pKey As String

Private DB As ADODB.Connection

Public Property Get Connected() As Variant
    If DB.State = adStateOpen Then Connected = pUsername & "@" & pDSN Else Connected = False
End Property

Public Function Connect(ByVal DSN As String, ByVal Username As String, ByVal Password As String) As Boolean
    pDSN = DSN
    pUsername = Username
    pXPassword = XorC(Password, pKey)
    
    Application.Cursor = xlWait
    Connect = dbOpen
    Application.Cursor = xlDefault
End Function

Public Function Query(ByVal QuerySQL As String, Optional Parameters As Collection) As ADODB.Recordset
    Dim dbQuery As ADODB.Command
    Dim Parameter As ADODB.Parameter
    Dim Output As ADODB.Recordset
    
    Dim param As Variant
    
    If DB.State <> adStateOpen Then
        Set Query = Nothing
    Else
        Application.Cursor = xlWait
        
        Set dbQuery = New ADODB.Command
        dbQuery.ActiveConnection = DB
        dbQuery.CommandText = QuerySQL
        
        If Not Parameters Is Nothing Then
            For Each param In Parameters
                Set Parameter = dbQuery.CreateParameter(, adVarChar, adParamInput, Len(param), param)
                dbQuery.Parameters.Append Parameter
            Next
            Set Parameter = Nothing
        End If
        
        Set Output = New ADODB.Recordset
        Output.CursorType = adOpenStatic
        Output.CursorLocation = adUseClient
        Output.Open dbQuery
        
        If Output.EOF Then
            Set Query = Nothing
        Else
            Set Query = Output
        End If
        
        Set Output = Nothing
        Set Parameter = Nothing
        Set dbQuery = Nothing
        
        Application.Cursor = xlDefault
    End If
End Function

Private Sub Class_Initialize()
    pKey = XorC(Now, Environ("username"))
    Set DB = Nothing
End Sub

Private Sub Class_Terminate()
    If Not DB Is Nothing Then
        If DB.State = adStateOpen Then DB.Close
    End If
    Set DB = Nothing
End Sub

Private Function XorC(ByVal Text As String, ByVal Password As String) As String
    Dim i As Integer
    Dim iPass As Integer
    
    XorC = ""
    For i = 1 To Len(Text)
        iPass = i Mod Len(Password)
        If iPass = 0 Then iPass = Len(Password)
        XorC = XorC + Chr(Asc(Mid(Text, i, 1)) Xor Asc(Mid(Password, iPass, 1)))
    Next
End Function

Private Function dbOpen() As Boolean
    On Error Resume Next
    
    Set DB = New ADODB.Connection
    DB.Open pDSN, pUsername, XorC(pXPassword, pKey)
    
    If DB.State <> adStateOpen Then dbOpen = False Else dbOpen = True
End Function
